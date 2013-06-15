#entity.coffee
#Routes to CRUD entities

Entity = require('../models/entity')

#POST /entity
exports.create = (req, res, next) ->
    data = {
        name: req.body['name'],
        description: req.body['description'],
        type: req.body['type'],
    }

    tags = req.body['tags']
        
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
        otherId: entityId,
    }
###
exports.relation = (req, res, next) ->
    results = []
    save = (err, res) ->
        results.push(res)
        
    await
        Entity.get req.param.id, defer results[0]
        Entity.get req.body.otherId, defer results[1]
    
    [entity, other] = results

    switch req.body.action
        when "add" then entity.linkEntity other, req.param.relation, (err) -> console.log(err)
        when "remove" then entity.unlinkEntity other, req.param.relation, (err) -> console.log(err)

# GET /entity/:id/:relation
###
    List all entity related to this entity through [relation]
###
