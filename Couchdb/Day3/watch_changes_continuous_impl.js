var
  http = require('http'),
  events = require('events');

  /**
   * create a CouchDB watcher based on connection criteria,
   * follows node.js EventEmitter pattern, emits 'change' events.
   */

  exports.createWatcher = function(options) { 
    var watcher = new events.EventEmitter();

    watcher.host = options.host || 'localhost';
    watcher.port = options.port || 5984
    watcher.last_seq = options.last_seq || 0;
    watcher.db = options.db || '_users';

    watcher.start = function() {
      var http_options = {
        host: watcher.host,
        port: watcher.port,
        path: '/' + watcher.db + '/_changes' + 
              '?feed=continous&include_docs=true&since=' + watcher.last_seq
      };

      var parseDataLine = function(line) {
        // Parse a single line into a JSON object
        // and emit the change.
        var output = JSON.parse(line);
        if (output.results) {
          watcher.last_seq = output.last_seq;
          output.results.forEach(function(change){
            watcher.emit('change', change);
          });
          watcher.start();
        } else {
          watcher.emit('error', output);
        }
      }

      // Parses each line in the buffer into JSON, returning any lines in the buffer that have not
      // been completely retrieved. 
      var splitBufferIntoLines = function(buffer)
      {
        // Find the position in the buffer of the last newline character.
        var indexOfLastCompleteLine = buffer.lastIndexOf("\n");

        if ( indexOfLastCompleteLine != -1 ){
          // Split the buffer into an array with each complete line
          // of JSON data.
          var lines = buffer.substr(0, indexOfLastCompleteLine).split("\n");

          // Parse each complete line in the buffer into JSON objects.
          lines.forEach( parseDataLine );

          // Move the buffer to the remaining characters after the final
          // newline.
          buffer = buffer.substr( pos + 1);
        }

        // Return characters remaining in the buffer.
        return buffer;
      }

      http.get(http_options, function(res) {
        var buffer = '';
        res.on('data', function(chunk) {
          buffer += chunk;
          buffer = splitBufferIntoLines( buffer );
        });
        res.on('end', function() {
          buffer = splitBufferIntoLines( buffer );
        })
      })
      .on('error', function(err) {
        watcher.emit('error', err);
      });
    };

    return watcher;
  };

  if (!module.parent){
    exports.createWatcher({
      db: process.argv[2],
      last_seq: process.argv[3]
    })
      .on('change', console.log)
      .on('error', console.error)
      .start();
  };
