var Collection;

Collection = (function() {
  function Collection(_type, _collection) {
    this._type = _type;
    this._collection = _collection != null ? _collection : [];
    if (!this._type) {
      throw Error('type needs to be specified on first argument of constructor');
    }
    if (this._collection instanceof Array === false) {
      throw Error('collection must be an array');
    }
  }

  Collection.prototype.set = function(_collection) {
    this._collection = _collection;
  };

  Collection.prototype.get = function() {
    return this._collection;
  };

  Collection.prototype.find = function(item) {
    return this._collection.filter(function(el) {
      return el === item;
    });
  };

  Collection.prototype.findByKey = function(key, value) {
    var keys;
    keys = key.split('.');
    if (!value) {
      return this._collection.filter(function(el) {
        var e, j, k, len;
        e = el;
        for (j = 0, len = keys.length; j < len; j++) {
          k = keys[j];
          e = e[k];
        }
        return e;
      });
    }
    return this._collection.filter(function(el) {
      var e, j, k, len;
      e = el;
      for (j = 0, len = keys.length; j < len; j++) {
        k = keys[j];
        e = e[k];
      }
      return e === value;
    });
  };

  Collection.prototype.register = function(item) {
    if (this._type instanceof Object === true) {
      if (item instanceof this._type === false) {
        throw Error('item is not instance of @_type');
      }
    } else {
      if (typeof item !== this._type) {
        throw Error('item is not instance of @_type');
      }
    }
    return this._collection.push(item);
  };

  Collection.prototype.remove = function(items) {
    var i, index, j, len;
    if (items instanceof Array) {
      for (j = 0, len = items.length; j < len; j++) {
        i = items[j];
        this.remove(i);
      }
    } else {
      index = this._collection.indexOf(items);
      this._collection.splice(index, 1);
    }
    return this;
  };

  return Collection;

})();

module.exports = Collection;
