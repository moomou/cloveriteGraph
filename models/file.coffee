#file.coffee

_und = require 'underscore'

Setup = require './setup'
Neo = require './neo'
Meta = require './meta'
redis = Setup.db.redis

FileSchema = {
    name: "Name of file",
    type: "", #image, file, txt, etc.
    tags: [""],
    content: "",
    url: "",
    version: 0,
    private: false
}

module.exports = class File extends Neo
    constructor: (@_node) ->
        super @_node
