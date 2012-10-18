var Set = Parse.Object.extend('Set');
var Listener = Parse.Object.extend('Listener');
var Request = Parse.Object.extend('Request');

var defaultErr = function(response) {
  return function(object, error) { response.error(error); };
};
delegateTo = function(response) {
  return {
    success: function(object) { response.success(); },
    error: defaultErr(response)
  };
};


var upsert = function(klass, phone, defaults, func) {
  var query = new Parse.Query(klass);
  query.equalTo('phone', phone);
  query.first({
    success: function(object) {
      if (!object) {
        object = new klass();
        object.set('phone', phone);
        if (defaults) {
          Parse._.each(defaults, function(value, key) {
            object.set(key, value);
          });
        }
        object.save({
          success: func,
          error: function() { console.log('error'); }
        });
      } else {
        func(object);
      }
    },
    error: function(error) {
      var object = new klass();
      object.set('phone', phone);
      func(object);
    }
  });
};

Parse.Cloud.define("on_sms", function(request, response) {
  Parse.Cloud.useMasterKey();
  from = request.params.from;
  to = request.params.to;
  message = request.params.message;
  if (!to) {
    request.error("Missing to");
  } else if (!from) {
    response.error("Missing from");
  } else if (!message) {
    request.error("Missing message");
  }

  split = message.indexOf(' ');
  if (split !== -1) {
    command = message.substring(0, split);
    args = message.substring(split + 1);
  } else {
    command = message;
  }
  command = command.toLowerCase();
  switch (command) {
  case 'nick':
    upsert(Listener, from, {karma: 0}, function(listener) {
      listener.set('nick', args);
      listener.save(null, delegateTo(response));
    });
    break;

  case 'play':
    upsert(Listener, from, {karma: 0}, function(listener) {
      console.log("Upsert set");
      upsert(Set, to, null, function(set) {
        console.log("Create request");
        var req = new Request();
        req.set('listener', listener);
        req.set('set', set);
        req.set('song', args);
        req.set('karma', listener.get('karma'));
        req.save(/*{
          success: function() {
            console.log("Set current song");
            if (!set.get('currentSong')) {
              set.set('currentSong', req);
              set.save(delegateTo(response));
            } else {
              resonse.success();
            }
          },
          error: defaultErr(response)
        }*/ delegateTo(response));
      });
    });
    break;

  case 'like':
    break;
  case 'boo':
    break;

  default:
    response.error("Invalid command " + command + ". Valid commands are NICK, PLAY, LIKE, and BOO");
  }
});
