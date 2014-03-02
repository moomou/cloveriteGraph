# Data.coffee
#
# Model for data.

_und       = require 'underscore'
Logger     = require 'util'

Slug       = require '../util/slug'
Neo        = require './neo'
SchemaUtil = require './stdSchema'

INDEX_NAME = 'nData'
Indexes = [
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'name',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'srcUrl',
        INDEX_VALUE: ''
    },
    {
        INDEX_NAME: INDEX_NAME,
        INDEX_KEY: 'dataType',
        INDEX_VALUE: ''
    }
]

DataSchema =
    name     : ''
    dataType : '' # text, image, video, fixed numeric, timeseries, file
    srcUrl   : '' # src url
    srcType  : '' # data type - Binary, DOM, or json
    selector : '' # a CSS selector if applicable
    value    : ''

#Private constructor
module.exports = class Data extends Neo
    constructor: (@_node) ->
        super @_node

Data.Name       = 'nData'
Data.INDEX_NAME = INDEX_NAME
Data.Indexes    = Indexes

Data.SrcType =
    JSON   : 'json'
    DOM    : 'dom'
    BINARY : 'binary'

Data.DataType =
    IMAGE       : 'image'
    VIDEO       : 'video'
    NUMBER      : 'number'
    TIME_SERIES : 'timeseries'
    FILE        : 'file'

Data.getSlugTitle = (data) ->
    Slug.slugify data.name

Data.deserialize = (data) ->
    Neo.deserialize DataSchema, data

Data.create = (reqBody, cb) ->
    Neo.create Data, reqBody, Indexes, cb

Data.get = (id, cb) ->
    Neo.get Data, id, cb

Data.getOrCreate = (reqBody, cb) ->
    Neo.getOrCreate Data, reqBody, cb

Data.put = (nodeId, reqBody, cb) ->
    Neo.put Data, nodeId, reqBody, cb
