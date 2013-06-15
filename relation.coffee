###
    Relationship Schema
###

class Vote
    constructor: (
        @type,      #vote type: pos, neg
        @ipAddr,    #ip address of the vote
        @user,      #username or unknown
        @time,      #timestamp when vote was registered
        @lang,      #language of the user
        @agent,     #browser type
        @rating     #numerical value for rating - unused right now
    ) ->

class Relation
    constructor: (
        @linkName      # 
    ) ->
