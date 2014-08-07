//
// Main
//


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

