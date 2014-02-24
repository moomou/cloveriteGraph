# unique id util
Setup = require './setup'
slug = require 'slug'
redis = Setup.db.redis

SchemaUtil = require './stdSchema'
Constants = SchemaUtil.Constants

# entity Title + Attribute or Data Title guaranteed to be unique
exports.getUniqueId = (entityTitle, title, cb) ->
    slugified = slug "##{entityTitle}##{title}"

    await redis.hexists Constants.AUTO_COMPLETE, slugified, defer err, exists

    if not exists
        await redis.hset Constants.AUTO_COMPLETE, slugified, "", defer err

    cb err, slugified
