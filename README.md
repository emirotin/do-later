do-later
========

A delayed job implementation for Node

Usage:

    DoLater = require('do-later');
    doLater = new DoLater({
        host: 'localhost',
        port: 27017,
        db: 'db-name',
        collection: '_dolater'
        /*
        add user and password if required
        */
    });

    doLater.on('some-job', function (param1, params2) {
      // do something with params
    });

    doLater.doLater(10, 'some-job', 1, 2); // in 10 seconds do the job with arguments 1 and 2
