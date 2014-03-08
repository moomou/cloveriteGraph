# Config.coffee
#
# Contains constants and other misc. settings for the api server.

os      = require 'os'
Hashids = require 'hashids'

exports.Winston =
    customLevels :
        debugging : 0
        debug     : 1
        info      : 2
        error     : 3
    color:
        silly     : 'white'
        debug     : 'white'
        info      : 'green'
        error     : 'red'
        debugging : 'blue'
    logLevel     : "debug"
    logFile      : "#{os.tmpdir()}api.log"

exports.Security =
    hashids: new Hashids("Trust.Aspire.Succeed.Profit", 10)

exports.RedisKey =
    shareToken : "_sharetoken_"
    slugToId   : "_slug_to_id_"
    superToken : "_supertoken_"

exports.Constants = Constants =
    API_VERSION                          : 'v0'
    AUTO_COMPLETE                        : '__auto__complete__'
    TAG_GLOBAL                           : '#__global__'

    # Generic Relation
    REL_LOCATION                         : '_LOCATION'
    REL_AWARD                            : '_AWARD'
    REL_ATTRIBUTE                        : '_ATTRIBUTE'
    REL_COMPOSED                         : '_COMPOSED'
    REL_DATA                             : '_DATA'
    REL_FORKED                           : '_FORKED'
    REL_PARENT                           : '_PARENT'
    REL_CHILD                            : '_CHILD'
    REL_CONTAINER                        : '_CONTAINER'
    REL_RESOURCE                         : '_RESOURCE'

    REL_TAG                              : '_TAG'
    REL_ACCESS                           : '_ACCESS'
    REL_RANK                             : '_RANK'
    REL_RANKING                          : '_RANKING'

    # Action
    # User to Entity, Attribute, or User
    REL_VOTED                            : '_VOTED'
    REL_COMMENTED                        : '_COMMENTED'
    REL_CREATED                          : '_CREATED'

    # this is a generic relationship
    # that indicate a user has done
    # one of the following
    # 1) Voted
    # 2) Created
    # 3) Modified (ie put)
    # 4) Commented
    REL_MODIFIED                         : '_MODIFIED'

    # Attr Type
    ATTR_NUMERIC                         : "attr_numeric"
    ATTR_REFERENCE                       : "attr_ref"
