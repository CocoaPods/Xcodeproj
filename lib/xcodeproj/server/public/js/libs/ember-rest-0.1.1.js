/**
 Ember-REST.js 0.1.1

 A simple library for RESTful resources in Ember.js

 Copyright (c) 2012 Cerebris Corporation

 Licensed under the MIT license:
   http://www.opensource.org/licenses/mit-license.php
*/

/**
  An adapter for performing resource requests

  The default implementation is a thin wrapper around jQuery.ajax(). It is mixed in to both Ember.Resource
  and Ember.ResourceController.

  To override Ember.ResourceAdapter entirely, define your own version and include it before this module.

  To override a portion of this adapter, reopen it directly or reopen a particular Ember.Resource or
  Ember.ResourceController. You can override `_resourceRequest()` entirely, or just provide an implementation of
  `_prepareResourceRequest(params)` to adjust request params before `jQuery.ajax(params)`.
*/
if (Ember.ResourceAdapter === undefined) {
  Ember.ResourceAdapter = Ember.Mixin.create({
    /**
      @private

      Performs an XHR request with `jQuery.ajax()`. Calls `_prepareResourceRequest(params)` if defined.
    */
    _resourceRequest: function(params) {
      params.url = this._resourceUrl();
      params.dataType = 'json';

      if (this._prepareResourceRequest !== undefined) {
        this._prepareResourceRequest(params);
      }

      return jQuery.ajax(params);
    }
  });
}

/**
  A model class for RESTful resources

  Extend this class and define the following properties:

  * `resourceIdField` -- the id field for this resource ('id' by default)
  * `resourceUrl` -- the base url of the resource (e.g. '/contacts');
       will append '/' + id for individual resources (required)
  * `resourceName` -- the name used to contain the serialized data in this
       object's JSON representation (required only for serialization)
  * `resourceProperties` -- an array of property names to be returned in this
       object's JSON representation (required only for serialization)

  Because `resourceName` and `resourceProperties` are only used for
    serialization, they aren't required for read-only resources.

  You may also wish to override / define the following methods:

  * `serialize()`
  * `serializeProperty(prop)`
  * `deserialize(json)`
  * `deserializeProperty(prop, value)`
  * `validate()`
*/
Ember.Resource = Ember.Object.extend(Ember.ResourceAdapter, Ember.Copyable, {
  resourceIdField: 'id',
  resourceUrl:     Ember.required(),

  /**
    Duplicate properties from another resource

    * `source` -- an Ember.Resource object
    * `props` -- the array of properties to be duplicated;
         defaults to `resourceProperties`
  */
  duplicateProperties: function(source, props) {
    var prop;

    if (props === undefined) props = this.resourceProperties;

    for(var i = 0; i < props.length; i++) {
      prop = props[i];
      this.set(prop, source.get(prop));
    }
  },

  /**
    Create a copy of this resource

    Needed to implement Ember.Copyable

    REQUIRED: `resourceProperties`
  */
  copy: function(deep) {
    var c = this.constructor.create();
    c.duplicateProperties(this);
    c.set(this.resourceIdField, this.get(this.resourceIdField));
    return c;
  },

  /**
    Generate this resource's JSON representation

    Override this or `serializeProperty` to provide custom serialization

    REQUIRED: `resourceProperties` and `resourceName` (see note above)
  */
  serialize: function() {
    var name = this.resourceName,
        props = this.resourceProperties,
        prop,
        ret = {};

    ret[name] = {};
    for(var i = 0; i < props.length; i++) {
      prop = props[i];
      ret[name][prop] = this.serializeProperty(prop);
    }
    return ret;
  },

  /**
    Generate an individual property's JSON representation

    Override to provide custom serialization
  */
  serializeProperty: function(prop) {
    return this.get(prop);
  },

  /**
    Set this resource's properties from JSON

    Override this or `deserializeProperty` to provide custom deserialization
  */
  deserialize: function(json) {
    Ember.beginPropertyChanges(this);
    for(var prop in json) {
      if (json.hasOwnProperty(prop)) this.deserializeProperty(prop, json[prop]);
    }
    Ember.endPropertyChanges(this);
    return this;
  },

  /**
    Set an individual property from its value in JSON

    Override to provide custom serialization
  */
  deserializeProperty: function(prop, value) {
    this.set(prop, value);
  },

  /**
    Request resource and deserialize

    REQUIRED: `id`
  */
  findResource: function() {
    var self = this;

    return this._resourceRequest({type: 'GET'})
      .done(function(json) {
        self.deserialize(json);
      });
  },

  /**
    Create (if new) or update (if existing) record

    Will call validate() if defined for this record

    If successful, updates this record's id and other properties
    by calling `deserialize()` with the data returned.

    REQUIRED: `properties` and `name` (see note above)
  */
  saveResource: function() {
    var self = this;

    if (this.validate !== undefined) {
      var error = this.validate();
      if (error) {
        return {
          fail: function(f) { f(error); return this; },
          done: function() { return this; },
          always: function(f) { f(); return this; }
        };
      }
    }

    return this._resourceRequest({type: this.isNew() ? 'POST' : 'PUT',
                                  data: this.serialize()})
      .done(function(json) {
        // Update properties
        if (json) self.deserialize(json);
      });
  },

  /**
    Delete resource
  */
  destroyResource: function() {
    return this._resourceRequest({type: 'DELETE'});
  },

  /**
   Is this a new resource?
  */
  isNew: function() {
    return (this._resourceId() === undefined);
  },

  /**
    @private

    The URL for this resource, based on `resourceUrl` and `_resourceId()` (which will be
      undefined for new resources).
  */
  _resourceUrl: function() {
    var url = this.resourceUrl,
        id = this._resourceId();

    if (id !== undefined)
      url += '/' + id;

    return url;
  },

  /**
    @private

    The id for this resource.
  */
  _resourceId: function() {
    return this.get(this.resourceIdField);
  }
});

/**
  A controller for RESTful resources

  Extend this class and define the following:

  * `resourceType` -- an Ember.Resource class; the class must have a `serialize()` method
       that returns a JSON representation of the object
  * `resourceUrl` -- (optional) the base url of the resource (e.g. '/contacts/active');
       will default to the `resourceUrl` for `resourceType`
*/
Ember.ResourceController = Ember.ArrayController.extend(Ember.ResourceAdapter, {
  resourceType: Ember.required(),

  /**
    @private
  */
  init: function() {
    this._super();
    this.clearAll();
  },

  /**
    Create and load a single `Ember.Resource` from JSON
  */
  load: function(json) {
    var resource = this.get('resourceType').create().deserialize(json);
    this.pushObject(resource);
  },

  /**
    Create and load `Ember.Resource` objects from a JSON array
  */
  loadAll: function(json) {
    for (var i=0; i < json.length; i++)
      this.load(json[i]);
  },

  /**
    Clear this controller's contents (without deleting remote resources)
  */
  clearAll: function() {
    this.set("content", []);
  },

  /**
    Replace this controller's contents with an request to `url`
  */
  findAll: function() {
    var self = this;

    return this._resourceRequest({type: 'GET'})
      .done(function(json) {
        self.clearAll();
        self.loadAll(json);
      });
  },

  /**
    @private

    Base URL for requests

    Will use the `resourceUrl` set for this controller, or if that's missing,
    the `resourceUrl` specified for `resourceType`.
  */
  _resourceUrl: function() {
    if (this.resourceUrl === undefined) {
      // If `resourceUrl` is not defined for this controller, there are a couple
      // ways to retrieve it from the resource. If a resource has been instantiated,
      // then it can be retrieved from the resource's prototype. Otherwise, we need
      // to loop through the mixins for the prototype to get the resourceUrl.
      var rt = this.get('resourceType');
      if (rt.prototype.resourceUrl === undefined) {
        for (var i = rt.PrototypeMixin.mixins.length - 1; i >= 0; i--) {
          var m = rt.PrototypeMixin.mixins[i];
          if (m.properties !== undefined && m.properties.resourceUrl !== undefined) {
            return m.properties.resourceUrl;
          }
        }
      }
      else {
        return rt.prototype.resourceUrl;
      }
    }
    return this.resourceUrl;
  }
});
