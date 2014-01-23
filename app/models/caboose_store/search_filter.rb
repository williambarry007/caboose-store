require 'json'

module CabooseStore
  class SearchFilter < ActiveRecord::Base
        
    self.table_name = "store_search_filters"  
    attr_accessible :id, 
      :url,
      :title_like,
      :category_id,
      :category,
      :vendors, 
      :option1,
      :option2,
      :option3,
      :prices

    before_save :json_encode
    after_initialize :json_decode

    def json_encode
      self.category = self.category.to_json if !self.category.nil?
      self.vendors  = self.vendors.to_json  if !self.vendors.nil?        
      self.option1  = self.option1.to_json  if !self.option1.nil? 
      self.option2  = self.option2.to_json  if !self.option2.nil? 
      self.option3  = self.option3.to_json  if !self.option3.nil? 
      self.prices   = self.prices.to_json   if !self.prices.nil?
    end
    
    def json_decode
      if !self.category.nil?
        cat = JSON.parse(self.category)
        self.category = Caboose::StdClass.new({
          'id' => cat['id'],
          'name' => cat['name'],
          'children' => cat['children'].collect { |cat2| Caboose::StdClass.new(cat2) }
        })
      end
         
      #self.category = JSON.parse(self.category).collect{ |hash| Caboose::StdClass.new(hash) } if !self.category.nil?
      self.vendors  = JSON.parse(self.vendors ).collect{ |hash| Caboose::StdClass.new(hash) } if !self.vendors.nil?
      self.option1  = JSON.parse(self.option1 ) if !self.option1.nil? 
      self.option2  = JSON.parse(self.option2 ) if !self.option2.nil? 
      self.option3  = JSON.parse(self.option3 ) if !self.option3.nil? 
      self.prices   = JSON.parse self.prices    if !self.prices.nil?

      Caboose.log(self.option1)      
    end
      
    def self.exclude_params_from_url(url, exclude_params = nil)
      return url if exclude_params.nil? || exclude_params.count == 0
      
      url2 = "#{url}"
      url2[0] = '' if url2.starts_with?('/')
      
      if Caboose.use_url_params
        arr = url2.split('/')
        arr2 = []
        i = arr.count - 1
        while i >= 1 do
          k = arr[i-1]
          v = arr[i]
          arr2 << "#{k}/#{v}" if !exclude_params.include?(k)
          i = i - 2
        end
        arr2 << arr[0] if i == 0
        url2 = arr2.reverse.join('/')
      else
        # TODO: Handle removing parameters from the querystring
      end        
      
      url2 = "/#{url2}" if !url2.starts_with?('/')
      return url2
    end
    
    def self.find_from_url(url, pager, exclude_params = nil)
      
      url2 = self.exclude_params_from_url(url, exclude_params)
      Caboose.log("url2 = #{url2}")
      
      if SearchFilter.exists?(:url => url2)
        return SearchFilter.where(:url => url2).first
      end

      f = SearchFilter.new
      f.url = url2
      
      url2 = url2.split("?")[0] if url2.include?('?')     
      parent = nil
      selected_cat_id = nil
      
      if Category.exists?(:url => url2)
        parent = Category.where(:url => url2).first
        f.category_id = parent.id if parent
        parent = Category.find(parent.parent_id) if parent && parent.children && parent.children.count == 0
      elsif pager.params['category_id'] && pager.params['category_id'] != ''
        cat_id = pager.params['category_id'].kind_of?(Array) ? pager.params['category_id'][0] : pager.params['category_id'] 
        cat = Category.find(cat_id)
        parent = cat.parent
        f.category_id = cat.id if !pager.params['category_id'].kind_of?(Array)
      elsif pager.params['category_slug'] && pager.params['category_slug'] != ''
        slug = pager.params['category_slug'].kind_of?(Array) ? pager.params['category_slug'][0] : pager.params['category_slug'] 
        cat = Category.where(:slug => slug).first
        parent = cat.parent
        f.category_id = cat.id if !pager.params['category_slug'].kind_of?(Array)
      end
      f.category = nil
      if parent && parent.children && parent.children.count > 0
        f.category = { 
          'id'        => parent.id,
          'name'      => parent.name,
          'selected'  => parent.id == f.category_id,
          'children'  => parent.children.collect { |cat| { 
              'id'       => cat.id, 
              'name'     => cat.name, 
              'url'      => cat.url, 
              'selected' => cat.id == f.category_id 
            }
          }
        }
      end
      pager.params['category_id'] = f.category_id if pager.params['category_id'].nil? || pager.params['category_id'] == ''
      
      f.title_like = pager.params['title_like'] if pager.params['title_like']
            
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
      return SearchFilter.find(f.id)
      
    end
    
  end
end
