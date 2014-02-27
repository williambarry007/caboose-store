//
// Main
//
// :: Initialize

var CabooseStore = function() {
	var self = this;
	
	//
	// Initialize
	//
	
	self.initialize = function() {
		//..
	};
	
	// Init and return
	$(document).ready(self.initialize);
	return self;
};

Caboose.Store = new CabooseStore();
