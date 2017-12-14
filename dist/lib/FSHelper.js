(function() {
  var FSHelper, fs;

  fs = require('fs');

  FSHelper = (function() {
    function FSHelper(_path) {
      this._path = _path;
    }

    FSHelper.prototype.isDirectory = function() {
      var stats;
      stats = this.pathStats(this.getPath());
      if (!stats) {
        return false;
      }
      return stats != null ? stats.isDirectory() : void 0;
    };

    FSHelper.prototype.isFile = function() {
      var stats;
      stats = this.pathStats(this.getPath());
      if (!stats) {
        return false;
      }
      return stats != null ? stats.isFile() : void 0;
    };

    FSHelper.prototype.pathStats = function() {
      var e;
      try {
        return fs.lstatSync(this.getPath());
      } catch (error) {
        e = error;
        return false;
      }
    };

    FSHelper.prototype.setPath = function(_path) {
      this._path = _path;
    };

    FSHelper.prototype.getPath = function() {
      return this._path;
    };

    return FSHelper;

  })();

  module.exports = FSHelper;

}).call(this);
