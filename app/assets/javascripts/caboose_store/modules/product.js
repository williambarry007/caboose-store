//
// Product
//

Caboose.Store.Modules.Product = (function() {
  var self = {
    templates: {
      images: JST['caboose_store/product/images'],
      options: JST['caboose_store/product/options']
    }
  };
  
  //
  // Initialize
  //
  
  self.initialize = function() {
    self.render();
  };
  
  //
  // Render
  //
  
  self.render = function() {
    self.$product = $('#product');
    self.$images = $('#product-images', self.$product);
    self.$options = $('#product-options', self.$product);
    self.$form = $('form[caboose-cart=add]');
    
    // Do nothing if the product container doesn't exist
    if (!self.$product.length) return false;
    
    $.get('/products/' + self.$product.data('id') + '/info', function(product) {
      self.product = product;
      
      // Render options and images html
      self.$images.html(self.templates.images({ images: self.product.images }));
      self.$options.html(self.templates.options({ options: self.getOptionsWithAllValues() }));
      
      // Set initial variant
      self.variant = self.getInitialVariant();
      self.setOptionsFromVariant(self.variant);
      
      // Bind option events
      self.$options.find('select').on('change', self.selectChangeHandler);
      self.$images.find('ul > li > figure').on('click', self.thumbClickHandler);
      self.$images.children('figure').on('click', self.imageClickHandler);
    });
  };
  
  //
  // Out of Stock
  //
  
  self.outOfStock = function() {
    self.$form.after($('<p/>').addClass('error').text('Out of Stock')).remove();
  };
  
  //
  // Event Handlers
  //
  
  self.selectChangeHandler = function(event) {
    var $targetSelect = $(event.target)
      , $targetOption = $targetSelect.find('option:selected');
    
    self.$options.find('select').not($targetSelect).each(function(index, element) {
      var $otherSelect = $(element);
      
      $otherSelect.find('option').each(function(index, element) {
        var $otherOption = $(element);
        if (!$otherOption.val()) return true;
        
        variant = self.getVariantFromOptions([
          { name: $targetSelect.attr('name'), value: $targetOption.val() },
          { name: $otherSelect.attr('name'), value: $otherOption.val() }
        ]);
        
        self.toggleOption($otherOption, variant && variant.quantity > 0);
      });
    });
    
    self.setVariantFromOptions();
  };
  
  self.thumbClickHandler = function(event) {
    self.$images.children('figure').css('background-image', 'url(' + $(event.target).data('url-large') + ')');
  };
  
  self.imageClickHandler = function(event) {
    window.location = $(event.target).css('background-image').match(/^url\("(.*)"\)$/)[1];
  };
  
  //
  // Option Methods
  //
  
  self.getOptionsFromProduct = function() {
    return _.compact([
      self.product.option1 ? self.product.option1 : undefined,
      self.product.option2 ? self.product.option2 : undefined,
      self.product.option3 ? self.product.option3 : undefined
    ]);
  };
  
    
  self.getOptionsFromVariant = function(variant) {
    return _.compact([
      self.product.option1 ? { name: self.product.option1, value: variant.option1 } : undefined,
      self.product.option2 ? { name: self.product.option2, value: variant.option2 } : undefined,
      self.product.option3 ? { name: self.product.option3, value: variant.option3 } : undefined
    ]);
  };
  
  self.getOptionsWithAllValues = function() {
    return _.map(self.getOptionsFromProduct(), function(optionName) {
      return {
        name: optionName,
        values: _.uniq(_.map(self.product.variants, function(variant) {
          return variant[self.getOptionAttribute(optionName)];
        }))
      };
    });
  };
  
  self.getOptionAttribute = function(option) {
    optionName = _.isObject(option) ? option.name : option;
    
    if (self.product.option1 == optionName) {
      return 'option1';
    } else if (self.product.option2 == optionName) {
      return 'option2';
    } else if (self.product.option3 == optionName) {
      return 'option3';
    }
  };
  
  self.getCurrentOptions = function() {
    var options = [];
    
    self.$options.find('select').each(function(index, element) {
      var $select = $(element);
      
      options.push({
        name: $select.attr('name'),
        value: element.value
      });
    });
    
    return options;
  };
  
  self.toggleOption = function($option, on) {
    if (on) {
      $option.removeClass('unavailable');
      
      if ($option.prop('tagName') == 'OPTION') $option.prop('selected', true);
    } else {
      $option.addClass('unavailable');
      
      if ($option.prop('selected')) {
        $option.prop('selected', false);
        $option.siblings('[value=""]').first().prop('selected', true);
      }
    }
  };
  
  //
  // Variant Methods
  //
  
  self.getInitialVariant = function () {
    var variant = _.find(self.product.variants, function(variant) {
      return variant.quantity > 0;
    });
    
    if (!variant) {
      variant = _.first(self.product.variants);
      self.outOfStock();
    }
    
    return variant;
  };
 
  
  self.getVariantFromOptions = function(options) {
    var attributes = _.object(_.map(options || self.getCurrentOptions(), function(option) {
      return [self.getOptionAttribute(option.name), option.value]
    }));
    
    return _.first(_.where(self.product.variants, attributes));
  };
  
  self.setVariantFromOptions = function(options) {
    var options = self.getCurrentOptions();
    
    // Clear the variant if there is a blank option value
    if (_.contains(_.pluck(options, 'value'), "")) {
      self.variant = undefined;
      self.setVariantId();
    } else {
      self.variant = self.getVariantFromOptions(options);
      self.setImageFromVariant(self.variant);
      self.setVariantId(self.variant.id);
    }
  };
  
  self.setOptionsFromVariant = function(variant) {
    self.$options.find('select').each(function(index, element) {
      var $select = $(element)
        , $option = $select.find('option[value=' + variant[$select.attr('id')] + ']');
      
      self.toggleOption($option, true);
    });
    
    self.setImageFromVariant(variant);
    self.setVariantId(variant.id);
  };
  
  self.setVariantId = function(variantId) {
    if (self.$form.length) self.$form.find('input[name=variant_id]').val(variantId || "");
  };
  
  //
  // Image Methods
  //
  
  self.setImageFromVariant = function(variant) {
    var $figure = self.$images.children('figure');
    
    if (variant.images.length > 0) {
      $figure.css('background-image', 'url(' + variant.images[0].urls.large + ')');
    } else if ($figure.css('background-image').toLowerCase() == 'none') {
      $figure.css('background-image', 'url(' + _.first(self.product.images).urls.large + ')');
    }
  };
  
  return self;
}).call(Caboose.Store);

