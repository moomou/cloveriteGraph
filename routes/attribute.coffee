#entity.coffee
#Routes to CRUD entities

Entity = require('../models/entity')

#POST /entity
exports.create = (req, res, next) ->
    data = {
        name: req.body['name']
    }
    Entity.create data, (err, entity) ->
        return next(err) if err
        res.json(entity)

# GET /entity/?q=
# ...

# GET /entity/:id
exports.show = (req, res, next) ->
    Entity.get req.params.id,
                (err, entity) ->
                    return next(err) if err
                    res.json(entity)

# PUT /entity/:id
exports.edit = (req, res, next) ->
    Entity.get req.params.id,
                (err, entity) ->
                    #update params here...
                    return next(err) if err
                    res.json(entity)

#DELETE /entity/:id
exports.del = (req, res, next) ->
    Entity.get req.params.id,
               (err, entity) ->
                    return next(err) if err
                    entity.del (err) ->
                        return next(err) if err
                        res.json({})

# POST /entity/:id/:relation
###
    Connect another entity to current one using [relation]
    DATA : {
        action: add/rm
        other: entityId,
    }
###

# GET /entity/:id/:relation
###
    List all entity related to this entity through [relation]
###
