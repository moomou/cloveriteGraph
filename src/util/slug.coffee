# unique id util
slug      = require 'slug'

redis     = require('../models/setup').db.redis
NumUtil   = require '../util/numUtil'
RedisKey  = require('../config').RedisKey

# entity Title + Attribute or Data Title guaranteed to be unique

exports.resolveSlug = resolveSlug = (slug, cb) ->
    if NumUtil.isNum slug
        cb null, slug
    else
        redis.hget RedisKey.slugToId, slug, cb

exports.slugify = (title) ->
    slug title
