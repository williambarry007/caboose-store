require 'json'

module CabooseStore
  class SearchFilter < ActiveRecord::Base
        
    self.table_name = "store_search_filters"  
    attr_accessible :id, 
      :url,
      :title_like,
      :categories,
      :vendors, 
      :option1,
      :option2,
      :option3,
      :prices

    before_save :json_encode
    after_initialize :json_decode

    def json_encode    
      self.categories = self.categories.to_json if !self.categories.nil?
      self.vendors    = self.vendors.to_json    if !self.vendors.nil?        
      self.option1    = self.option1.to_json    if !self.option1.nil? 
      self.option2    = self.option2.to_json    if !self.option2.nil? 
      self.option3    = self.option3.to_json    if !self.option3.nil? 
      self.prices     = self.prices.to_json     if !self.prices.nil?
    end
    
    def json_decode
      self.categories = JSON.parse(self.categories).collect{ |hash| Caboose::StdClass.new(hash) } if !self.categories.nil?
      self.vendors    = JSON.parse(self.vendors   ).collect{ |hash| Caboose::StdClass.new(hash) } if !self.vendors.nil?      
      self.option1    = JSON.parse(self.option1   ) if !self.option1.nil? 
      self.option2    = JSON.parse(self.option2   ) if !self.option2.nil? 
      self.option3    = JSON.parse(self.option3   ) if !self.option3.nil? 
      self.prices     = JSON.parse self.prices     if !self.prices.nil?

      Caboose.log(self.option1)      
    end
      
    def self.create_from_url(url, pager)
      
      f = SearchFilter.new
      f.url = url
       
      url2 = url.split("?")[0]
      f.categories = nil
      if Category.exists?(:url => url2)
        parent = Category.where(:url => url2).first
        if parent.children && parent.children.count > 0
          f.categories = []  
          parent.children.each { |cat| f.categories << Caboose::StdClass.new({ 'id' => cat.id, 'name' => cat.name }) }
        end
      end
      
      vendor_ids = []
      option1 = Caboose::StdClass.new({ 'name' => [], 'values' => [] })
      option2 = Caboose::StdClass.new({ 'name' => [], 'values' => [] })
      option3 = Caboose::StdClass.new({ 'name' => [], 'values' => [] })      
      min = 0.0
      max = 1000000.0
      
      prices = [
        [    0,    10],
        [   10,    25],
        [   25,    50],
        [   50,    75],
        [   75,   100],
        [  100,   150],
        [  150,   200],
        [  200,   250],
        [  250,   300],
        [  300,   400],
        [  400,   500],
        [  500,  1000],
        [ 1000,  2000],
        [ 2000,  3000],
        [ 4000,  5000],
        [ 7000,  7500],
        [ 7500, 10000],
        [10000, 50000]                
      ]      
      price_counts = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      
      pager.all_items.each do |p|
        vendor_ids   << p.vendor_id
        option1.name << p.option1
        option2.name << p.option2
        option3.name << p.option3                
        p.variants.each do |v|
          option1.values << v.option1
          option2.values << v.option2
          option3.values << v.option3          
          min = v.price if v.price < min
          max = v.price if v.price > max
          prices.each_index do |i|
            minmax = prices[i]
            price_counts[i] = price_counts[i] + 1 if v.price > minmax[0] && v.price < minmax[1]
          end
        end
      end
      
      vendor_ids = vendor_ids ? vendor_ids.compact.uniq : nil       
      f.vendors = vendor_ids && vendor_ids.count > 0 ? vendor_ids.collect { |vid| Vendor.find(vid) } : nil       
      
      option1.name = option1.name ? option1.name.compact.uniq : nil
      option2.name = option2.name ? option2.name.compact.uniq : nil
      option3.name = option3.name ? option3.name.compact.uniq : nil
      
      f.option1 = option1.name && option1.name.count == 1 ? Caboose::StdClass.new({ 'name' => option1.name[0], 'values' => option1.values.compact.uniq.sort }) : nil 
      f.option2 = option2.name && option2.name.count == 1 ? Caboose::StdClass.new({ 'name' => option2.name[0], 'values' => option2.values.compact.uniq.sort }) : nil 
      f.option3 = option3.name && option3.name.count == 1 ? Caboose::StdClass.new({ 'name' => option3.name[0], 'values' => option3.values.compact.uniq.sort }) : nil       
      
      f.prices = []
      price_counts.each_index do |i| 
        f.prices << prices[i] if price_counts[i] > 0
      end
      f.prices = nil if f.prices.count == 0
      
      f.save
      return f
      
    end
    
  end
end
