// Generated by IcedCoffeeScript 1.6.3-e
(function() {
  var Attribute, Constants, Cypher, CypherBuilder, CypherLinkUtil, Data, DataRoute, Entity, EntityUtil, ErrorDevMessage, Handlebars, Link, Logger, Neo, Permission, Remote, Response, Tag, User, Vote, cardTemplate, embedJSTemplate, fs, iced, imageTemplate, infoTemplate, paddingTemplate, ratingTemplate, redis, renderContributorIcon, renderStarRating, renderTags, templates, textTemplate, __iced_k, __iced_k_noop, _show, _und;

  iced = require('iced-coffee-script').iced;
  __iced_k = __iced_k_noop = function() {};

  _und = require('underscore');

  fs = require('fs');

  redis = require('../models/setup').db.redis;

  Logger = require('util');

  Handlebars = require('handlebars');

  Remote = require('../remote/remote');

  Neo = require('../models/neo');

  User = require('../models/user');

  Entity = require('../models/entity');

  Attribute = require('../models/attribute');

  Data = require('../models/data');

  Tag = require('../models/tag');

  Vote = require('../models/vote');

  Link = require('../models/link');

  Constants = require('../config').Constants;

  EntityUtil = require('./entity/util');

  DataRoute = require('./data');

  Cypher = require('./util/cypher');

  CypherBuilder = Cypher.CypherBuilder;

  CypherLinkUtil = Cypher.CypherLinkUtil;

  Response = require('./util/response');

  ErrorDevMessage = Response.ErrorDevMessage;

  Permission = require('./permission');

  cardTemplate = Handlebars.compile(fs.readFileSync("" + __dirname + "/../templates/cardTemplate.handlebars").toString());

  imageTemplate = Handlebars.compile(fs.readFileSync("" + __dirname + "/../templates/sa_content_image.handlebars").toString());

  infoTemplate = Handlebars.compile(fs.readFileSync("" + __dirname + "/../templates/sa_content_field.handlebars").toString());

  textTemplate = Handlebars.compile(fs.readFileSync("" + __dirname + "/../templates/sa_content_textbox.handlebars").toString());

  ratingTemplate = Handlebars.compile(fs.readFileSync("" + __dirname + "/../templates/sa_content_rating.handlebars").toString());

  paddingTemplate = Handlebars.compile(fs.readFileSync("" + __dirname + "/../templates/sa_content_field.handlebars").toString());

  embedJSTemplate = Handlebars.compile(fs.readFileSync("" + __dirname + "/../templates/embed.js").toString());

  templates = {
    numberRowTemplate: infoTemplate,
    textRowTemplate: textTemplate,
    imageRowTemplate: imageTemplate,
    ratingTemplate: ratingTemplate,
    paddingRowTemplate: paddingTemplate,
    videoRowTemplate: paddingTemplate
  };

  renderStarRating = function(upVote, downVote) {
    var score, starGen, stars;
    starGen = function(stars) {
      var i, result, starDOM, _i;
      starDOM = function(className) {
        return '<i class="goldStar fa fa-' + className + '"></i>';
      };
      result = '';
      for (i = _i = 0; _i <= 5; i = ++_i) {
        if (stars >= 1) {
          result += starDOM('star');
        } else if (stars >= 0.5) {
          result += starDOM('star-half-full');
        } else {
          result += starDOM('star-o');
        }
        stars -= 1;
      }
      return result;
    };
    score = upVote / (upVote + downVote);
    stars = score * 5;
    return starGen(stars);
  };

  renderContributorIcon = function(contributor) {
    return "<li>" + '<div class="profile-mini profile-rounded pull-left" style=\'background-image: url("' + ("https://secure.gravatar.com/avatar/" + contributor + "?s=240") + '\')>' + "</li>";
  };

  renderTags = function(tag) {
    return "<li>" + tag + "</li>";
  };

  _show = function(req, res, next) {
    var attr, attrId, attrIds, attrObjs, attrTemplates, blob, data, dataId, dataIds, dataObjs, dataTemplates, entityId, entityIds, entityObjs, errs, fsErr, headEntity, ind, jsFile, renderedCard, scriptTagId, style, template, templateValues, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    style = 1;
    scriptTagId = req.query.scriptId || "";
    entityIds = (req.query.entity || "").split(",").filter(function(i) {
      return i;
    });
    attrIds = (req.query.rating || "").split(",").filter(function(i) {
      return i;
    });
    dataIds = (req.query.data || "").split(",").filter(function(i) {
      return i;
    });
    entityObjs = [];
    attrObjs = [];
    dataObjs = [];
    errs = [];
    fsErr = null;
    (function(__iced_k) {
      var _i, _j, _k, _len, _len1, _len2;
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "embed.coffee",
        funcname: "_show"
      });
      for (ind = _i = 0, _len = entityIds.length; _i < _len; ind = ++_i) {
        entityId = entityIds[ind];
        Entity.get(entityId, __iced_deferrals.defer({
          assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
            return function() {
              __slot_1[__slot_2] = arguments[0];
              return __slot_3[__slot_4] = arguments[1];
            };
          })(errs, ind, entityObjs, ind),
          lineno: 112
        }));
      }
      for (ind = _j = 0, _len1 = attrIds.length; _j < _len1; ind = ++_j) {
        attrId = attrIds[ind];
        Attribute.get(attrId, __iced_deferrals.defer({
          assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
            return function() {
              __slot_1[__slot_2] = arguments[0];
              return __slot_3[__slot_4] = arguments[1];
            };
          })(errs, ind, attrObjs, ind),
          lineno: 114
        }));
      }
      for (ind = _k = 0, _len2 = dataIds.length; _k < _len2; ind = ++_k) {
        dataId = dataIds[ind];
        Data.get(dataId, __iced_deferrals.defer({
          assign_fn: (function(__slot_1, __slot_2, __slot_3, __slot_4) {
            return function() {
              __slot_1[__slot_2] = arguments[0];
              return __slot_3[__slot_4] = arguments[1];
            };
          })(errs, ind, dataObjs, ind),
          lineno: 116
        }));
      }
      __iced_deferrals._fulfill();
    })(function() {
      headEntity = entityObjs[0].serialize();
      attrTemplates = [];
      (function(__iced_k) {
        var _i, _len, _ref, _results, _while;
        _ref = attrObjs;
        _len = _ref.length;
        ind = 0;
        _results = [];
        _while = function(__iced_k) {
          var _break, _continue, _next;
          _break = function() {
            return __iced_k(_results);
          };
          _continue = function() {
            return iced.trampoline(function() {
              ++ind;
              return _while(__iced_k);
            });
          };
          _next = function(__iced_next_arg) {
            _results.push(__iced_next_arg);
            return _continue();
          };
          if (!(ind < _len)) {
            return _break();
          } else {
            attr = _ref[ind];
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "embed.coffee",
                funcname: "_show"
              });
              attr.serialize(__iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    return blob = arguments[0];
                  };
                })(),
                lineno: 122
              }), headEntity.id);
              __iced_deferrals._fulfill();
            })(function() {
              blob.info = renderStarRating(blob.upVote, blob.downVote);
              return _next(attrTemplates[ind] = templates.ratingTemplate(blob));
            });
          }
        };
        _while(__iced_k);
      })(function() {
        var _i, _len;
        dataTemplates = [];
        for (ind = _i = 0, _len = dataObjs.length; _i < _len; ind = ++_i) {
          data = dataObjs[ind];
          blob = data.serialize();
          template = templates["" + blob.dataType + "RowTemplate"];
          dataTemplates[ind] = template(blob);
        }
        templateValues = headEntity;
        templateValues.tags = templateValues.tags.map(renderTags);
        templateValues.content = attrTemplates.join("") + dataTemplates.join("");
        templateValues.contributors = templateValues.contributors.map(renderContributorIcon);
        console.log(templateValues);
        renderedCard = cardTemplate(templateValues);
        jsFile = embedJSTemplate({
          SCRIPT_ID: scriptTagId,
          DIV_ID: "" + Math.floor(Math.random() * 167772159999999).toString(16),
          RENDERED: renderedCard.replace(/(\r\n|\n|\r)/gm, "")
        });
        return Response.JSResponse(res)(200, jsFile);
      });
    });
  };

  exports.show = _show;

}).call(this);
