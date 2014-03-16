# Embed.coffee
#
# This is the route responsible for embedded content when
# provided with ids of resources.
#

_und            = require 'underscore'
fs              = require 'fs'
redis           = require('../models/setup').db.redis

Logger          = require 'util'

Handlebars      = require 'handlebars'
Remote          = require '../remote/remote'

Neo             = require '../models/neo'

User            = require '../models/user'
Entity          = require '../models/entity'
Attribute       = require '../models/attribute'
Data            = require '../models/data'
Tag             = require '../models/tag'

Vote            = require '../models/vote'
Link            = require '../models/link'

Constants       = require('../config').Constants

EntityUtil      = require './entity/util'

DataRoute       = require './data'

Cypher          = require './util/cypher'
CypherBuilder   = Cypher.CypherBuilder
CypherLinkUtil  = Cypher.CypherLinkUtil

Response        = require './util/response'
ErrorDevMessage = Response.ErrorDevMessage

Permission      = require './permission'

# Setting templates

cardTemplate = Handlebars.compile(
    fs.readFileSync("#{__dirname}/../templates/cardTemplate.handlebars").toString())
imageTemplate = Handlebars.compile(
    fs.readFileSync("#{__dirname}/../templates/sa_content_image.handlebars").toString())
infoTemplate = Handlebars.compile(
    fs.readFileSync("#{__dirname}/../templates/sa_content_field.handlebars").toString())
textTemplate = Handlebars.compile(
    fs.readFileSync("#{__dirname}/../templates/sa_content_textbox.handlebars").toString())
ratingTemplate = Handlebars.compile(
    fs.readFileSync("#{__dirname}/../templates/sa_content_rating.handlebars").toString())
paddingTemplate = Handlebars.compile(
    fs.readFileSync("#{__dirname}/../templates/sa_content_field.handlebars").toString())
embedJSTemplate = Handlebars.compile(
    fs.readFileSync("#{__dirname}/../templates/embed.js").toString())

templates =
    numberRowTemplate  : infoTemplate
    textRowTemplate    : textTemplate
    imageRowTemplate   : imageTemplate
    ratingTemplate     : ratingTemplate
    paddingRowTemplate : paddingTemplate
    videoRowTemplate   : paddingTemplate

renderStarRating = (upVote, downVote) ->
    starGen = (stars) ->
        starDOM = (className) ->
            '<i class="goldStar fa fa-'+className+'"></i>'
        result = ''

        for i in [0..5]
            if stars >= 1
                result += starDOM('star')
            else if stars >= 0.5
                result += starDOM('star-half-full')
            else
                result += starDOM('star-o')
            stars -= 1
        result

    score = upVote / (upVote + downVote)
    stars = score * 5

    starGen(stars)

renderContributorIcon = (contributor) ->
    "<li>" +
        '<div class="profile profile-rounded pull-left js-profile" style="background-image: url("' +
            "https://secure.gravatar.com/avatar/#{contributor}?s=240" +
        '")>' +
    "</li>"

renderTags = (tag) ->
    "<li>#{tag}</li>"

_show = (req, res, next) ->
    style       = 1
    scriptTagId = req.query.scriptId || ""
    entityIds   = (req.query.entity || "").split(",").filter (i) -> i
    attrIds     = (req.query.rating || "").split(",").filter (i) -> i
    dataIds     = (req.query.data || "").split(",").filter (i) -> i

    entityObjs = []
    attrObjs   = []
    dataObjs   = []
    errs       = []
    fsErr      = null

    await
        for entityId, ind in entityIds
            Entity.get entityId, defer errs[ind], entityObjs[ind]
        for attrId, ind in attrIds
            Attribute.get attrId, defer errs[ind], attrObjs[ind]
        for dataId, ind in dataIds
            Data.get dataId, defer errs[ind], dataObjs[ind]

    headEntity = entityObjs[0].serialize()

    attrTemplates = []
    for attr, ind in attrObjs
        await attr.serialize(defer(blob), headEntity.id)
        blob.info = renderStarRating blob.upVote, blob.downVote
        attrTemplates[ind] = templates.ratingTemplate blob

    dataTemplates = []
    for data, ind in dataObjs
        blob = data.serialize()
        template = templates["#{blob.dataType}RowTemplate"]
        dataTemplates[ind] = template(blob)

    templateValues = headEntity

    templateValues.tags         = templateValues.tags.map renderTags
    templateValues.content      = attrTemplates.join("")  + dataTemplates.join("")
    templateValues.contributors = templateValues.contributors.map renderContributorIcon
    console.log templateValues

    renderedCard = cardTemplate templateValues

    jsFile = embedJSTemplate {
        SCRIPTE_ID : scriptTagId
        DIV_ID     : ""+Math.floor(Math.random()*167772159999999).toString(16)
        RENDERED   : renderedCard.replace(/(\r\n|\n|\r)/gm,"")
    }

    Response.JSResponse(res)(200, jsFile)

exports.show = _show
