(function() {
  var DoLater, EventEmitter, mongoPool, now;

  mongoPool = require('mongo-pool2');

  EventEmitter = require('events').EventEmitter;

  now = function() {
    return +new Date();
  };

  module.exports = DoLater = (function() {
    function DoLater(config) {
      this.config = config;
      this._runningCheck = false;
      this._poolReady = false;
      this._buffer = [];
      this._eventsHub = new EventEmitter;
      this._pool = mongoPool.create(this.config, (function(_this) {
        return function() {
          return _this._onPoolReady();
        };
      })(this));
      this._checkInterval = this.config.interval || 1000;
      this._pollInterval = 100;
    }

    DoLater.prototype.doLater = function(waitSec, jobName) {
      var job, params, tm;
      params = Array.prototype.slice.call(arguments, 1);
      tm = now();
      console.log('DoLater adding job', jobName, 'at', Date(tm));
      job = {
        createdAt: tm,
        when: tm + waitSec * 1000,
        jobName: jobName,
        params: params
      };
      if (!this._poolReady) {
        return this._addBuffered(job);
      } else {
        return this._addJob(job);
      }
    };

    DoLater.prototype._addBuffered = function(job) {
      return this._buffer.push(job);
    };

    DoLater.prototype._onPoolReady = function() {
      var jobSpec, _i, _len, _ref;
      this._poolReady = true;
      _ref = this._buffer;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        jobSpec = _ref[_i];
        this._addJob(jobSpec);
      }
      this._buffer = [];
      return this._check();
    };

    DoLater.prototype._coll = function() {
      var conn;
      conn = this._pool.acquire();
      return conn.collection(this.config.collection);
    };

    DoLater.prototype._addJob = function(job) {
      var coll;
      if (!this._poolReady) {
        return this._addBuffered(job);
      }
      coll = this._coll();
      return coll.insert(job, function() {
        var tm;
        tm = now();
        return console.log('DoLater job', job.jobName, 'added at', Date(tm));
      });
    };

    DoLater.prototype._check = function() {
      var checkFn, coll, query, sort;
      checkFn = this._check.bind(this);
      if (this._runningCheck) {
        return setTimeout(checkFn, this._pollInterval);
      }
      this._runningCheck = true;
      coll = this._coll();
      query = {
        when: {
          $lt: now()
        }
      };
      sort = [['when', 1], ['createdAt', 1]];
      return coll.findAndRemove(query, sort, (function(_this) {
        return function(err, job) {
          _this._runningCheck = false;
          if (err) {
            console.log('DoLater error', err);
            return setTimeout(checkFn, _this._pollInterval);
          } else if (job) {
            _this._onJob(job);
            return setTimeout(checkFn, _this._pollInterval);
          } else {
            return setTimeout(checkFn, _this._checkInterval);
          }
        };
      })(this));
    };

    DoLater.prototype._onJob = function(job) {
      var tm;
      tm = now();
      console.log('DoLater executing job', job.jobName, 'at', Date(tm));
      return this._eventsHub.emit.apply(this._eventsHub, job.params);
    };

    DoLater.prototype.on = function(jobName, fn) {
      return this._eventsHub.on(jobName, fn);
    };

    return DoLater;

  })();

}).call(this);