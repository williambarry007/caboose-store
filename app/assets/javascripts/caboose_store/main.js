//
// Main
//

var delay = (function() {
  var timer = 0;
  
  return function(callback, ms) {
    clearTimeout(timer);
    timer = setTimeout(callback, ms);
  };
})();

var Caboose = (function() {
  return {};
})();

Caboose.Store = (function(caboose) {
  var self = {
    Modules: {}
  };
  
  self.initialize = function() {
    _.each(self.Modules, function(module) {
      if (module.initialize) module.initialize();
    });
  };
  
  $(document).ready(self.initialize);
  return self;
}).call(Caboose);

