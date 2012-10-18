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


var upsert = function(klass, phone, func) {
  var query = new Parse.Query(klass);
  query.equalTo('phone', phone);
  query.first({
    success: function(object) {
      if (!object) {
        object = new klass();
        object.set('phone', phone);
      }
      func(object);
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
    upsert(Listener, from, function(listener) {
      if (listener.isNew()) {
       listener.set('karma', 0);
      }
      listener.set('nick', args);
      listener.save(null, delegateTo(response));
    });
    break;

  case 'play':
    upsert(Listener, from, function(listener) {
      var addRequest = function() {
        upsert(Set, to, function(set) {
          var request = new Request();
          request.set('listener', listener);
          request.set('set', set);
          request.set('song', args);
          request.set('karma', listener.get('karma'));
          request.save({
            success: function() {
              if (set.isNew()) {
                set.set('currentSong', request);
                set.save(delegateTo(response));
              } else {
                response.success();
              }
            },
            error: defaultErr(response)
          });
        });
      };

      if (listener.isNew()) {
        listener.set('karma', 0);
        listener.save({
          success: function() { addRequest(); },
          error: defaultErr(response)
        });
      } else {
        addRequest();
      }
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
