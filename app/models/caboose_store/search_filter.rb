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
      
      # Filter any specified parameters from the url
      filtered_url = self.exclude_params_from_url(url, exclude_params)
      
      search_filter = if SearchFilter.exists?(url: filtered_url)
        SearchFilter.where(url: filtered_url).first
      else
        
        # Create a new search filter
        search_filter     = SearchFilter.new
        search_filter.url = filtered_url
        
        # Remove url params from filtered_url if they exist
        category_url = if filtered_url.include?('?') then filtered_url.split('?')[0] else filtered_url end
      
        # Find category with url, pager.category_id or pager.category_slug respectively
        category = if Category.exists?(url: category_url)
          Category.where(url: category_url).first
        elsif pager.params['category_id'] and not pager.params['category_id'].empty?
          category_id = if pager.params['category_id'].kind_of?(Array)
            pager.params['category_id'].first
          else
            pager.params['category_id']
          end
        
          Category.find(category_id)
        elsif pager.params['category_slug'] and not pager.params['categroy_slug'].empty?
          category_slug = if pager.params['category_slug'].kind_of?(Array)
            pager.params['category_slug'].first
          else
            pager.params['category_slug']
          end
        
          Category.where(slug: category_slug).first
        end
        
        # Define the search filter's category_id
        search_filter.category_id = category.id
        
        # Set the search filter's title_like if it exist's in the pager
        search_filter.title_like = pager.params['title_like'] if pager.params['title_like']
        
        # Define the category inforation included with the search filter
        search_filter.category         = Hash.new
        search_filter.category['id']   = category.id
        search_filter.category['name'] = category.name
        
        # Iterate over category children
        search_filter.category['children'] = category.children.collect do |child_category|
          child         = Hash.new
          child['id']   = child_category.id
          child['name'] = child_category.name
          child['url']  = child_category.url
        
          child
        end
      
        # Define default results values
        vendor_ids = []
        option1    = { 'name' => [], 'values' => [] }
        option2    = { 'name' => [], 'values' => [] }
        option3    = { 'name' => [], 'values' => [] }
        min        = 0.0
        max        = 1000000.0
      
        prices_ranges = [
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
      
        price_range_matches = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      
        # Iterate over pager results for product and variant info
        pager.all_items.each do |product|
          vendor_ids   << product.vendor_id
          option1['name'] << product.option1
          option2['name'] << product.option2
          option3['name'] << product.option3                
        
          product.variants.each do |variant|
            option1['values'] << variant.option1
            option2['values'] << variant.option2
            option3['values'] << variant.option3          
          
            # Go to next variant if the price is nil
            next if variant.price.nil?
          
            # Iterate over price ranges
            prices_ranges.each_with_index do |price_range, index|
              min = price_range.first
              max = price_range.last
            
              # Increment price count at index if the varaint is within the price range
              price_range_matches[index] = price_range_matches[index] + 1 if variant.price > min and variant.price < max
            end
          end
        end
      
        # Remove nil and duplicate values from vendor_ids array
        vendor_ids = vendor_ids.compact.uniq
      
        # Define search filter's vendors
        search_filter.vendors = if vendor_ids.any? then vendor_ids.collect { |vendor_id| Vendor.find(vendor_id) } else nil end
      
        # Remove nil and duplicate values from option name arrays
        option1['name'] = option1['name'].compact.uniq
        option2['name'] = option2['name'].compact.uniq
        option3['name'] = option3['name'].compact.uniq
      
        # ?? If option name array have exactly 1 value then set the search filter's option values
        search_filter.option1 = if option1['name'].count == 1 then { 'name' => option1['name'][0], 'values' => option1['values'].compact.uniq.sort } else nil end
        search_filter.option2 = if option2['name'].count == 1 then { 'name' => option2['name'][0], 'values' => option2['values'].compact.uniq.sort } else nil end
        search_filter.option3 = if option3['name'].count == 1 then { 'name' => option3['name'][0], 'values' => option3['values'].compact.uniq.sort } else nil end
      
        # Define search filter prices
        search_filter.prices = []
        price_range_matches.each_index { |index| search_filter.prices << prices_ranges[index] if price_range_matches[index] > 0 }
        search_filter.prices = nil if search_filter.prices.empty?
      
        # Inject the search filter into the database
        search_filter.save
      
        # Finally, return the filter; NOTE: find out of the database so the hashes get serialized correctly
        SearchFilter.find(search_filter.id)
      end
      
      # Redefine the pager's base_url
      pager.options['base_url'] = search_filter.url
      
      # Define the pager's category_id if it doesn't already exist
      pager.params['category_id'] = search_filter.category_id if pager.params['category_id'].nil? or pager.params['category_id'].empty? and not search_filter.category_id == 1
      
      return search_filter
      
      #######################
      # 
      # 
      # # Filter any specified parameters from the url
      # filtered_url = self.exclude_params_from_url(url, exclude_params)
      # 
      # # Redefine the pager's base_url
      # pager.options['base_url'] = filtered_url
      # 
      # # Check to see if a search filter already exists with the filtered url
      # return SearchFilter.where(url: filtered_url).first if SearchFilter.exists?(url: filtered_url)
      # 
      # # Create a new search filter
      # search_filter     = SearchFilter.new
      # search_filter.url = filtered_url
      # 
      # # Remove url params from filtered_url if they exist
      # category_url = if filtered_url.include?('?') then filtered_url.split('?')[0] else filtered_url end
      # 
      # # Find category with url, pager.category_id or pager.category_slug respectively
      # category = if Category.exists?(url: category_url)
      #   Category.where(url: category_url).first
      # elsif pager.params['category_id'] and not pager.params['category_id'].empty?
      #   category_id = if pager.params['category_id'].kind_of?(Array)
      #     pager.params['category_id'].first
      #   else
      #     pager.params['category_id']
      #   end
      #   
      #   Category.find(category_id)
      # elsif pager.params['category_slug'] and not pager.params['categroy_slug'].empty?
      #   category_slug = if pager.params['category_slug'].kind_of?(Array)
      #     pager.params['category_slug'].first
      #   else
      #     pager.params['category_slug']
      #   end
      #   
      #   Category.where(slug: category_slug).first
      # end
      # 
      # # Define the search filter's category_id
      # search_filter.category_id = category.id
      # 
      # # Define the pager's category_id if it doesn't already exist
      # pager.params['category_id'] = search_filter.category_id if pager.params['category_id'].nil? or pager.params['category_id'].empty?
      # 
      # # Set the search filter's title_like if it exist's in the pager
      # search_filter.title_like = pager.params['title_like'] if pager.params['title_like']
      # 
      # # Define the category inforation included with the search filter
      # search_filter.category         = Hash.new
      # search_filter.category['id']   = category.id
      # search_filter.category['name'] = category.name
      # 
      # # Iterate over category children
      # search_filter.category['children'] = category.children.collect do |child_category|
      #   child         = Hash.new
      #   child['id']   = child_category.id
      #   child['name'] = child_category.name
      #   child['url']  = child_category.url
      #   
      #   child
      # end
      # 
      # # Define default results values
      # vendor_ids = []
      # option1    = { 'name' => [], 'values' => [] }
      # option2    = { 'name' => [], 'values' => [] }
      # option3    = { 'name' => [], 'values' => [] }
      # min        = 0.0
      # max        = 1000000.0
      # 
      # prices_ranges = [
      #   [    0,    10],
      #   [   10,    25],
      #   [   25,    50],
      #   [   50,    75],
      #   [   75,   100],
      #   [  100,   150],
      #   [  150,   200],
      #   [  200,   250],
      #   [  250,   300],
      #   [  300,   400],
      #   [  400,   500],
      #   [  500,  1000],
      #   [ 1000,  2000],
      #   [ 2000,  3000],
      #   [ 4000,  5000],
      #   [ 7000,  7500],
      #   [ 7500, 10000],
      #   [10000, 50000]                
      # ]
      # 
      # price_range_matches = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      # 
      # # Iterate over pager results for product and variant info
      # pager.all_items.each do |product|
      #   vendor_ids   << product.vendor_id
      #   option1['name'] << product.option1
      #   option2['name'] << product.option2
      #   option3['name'] << product.option3                
      #   
      #   product.variants.each do |variant|
      #     option1['values'] << variant.option1
      #     option2['values'] << variant.option2
      #     option3['values'] << variant.option3          
      #     
      #     # Go to next variant if the price is nil
      #     next if variant.price.nil?
      #     
      #     # Iterate over price ranges
      #     prices_ranges.each_with_index do |price_range, index|
      #       min = price_range.first
      #       max = price_range.last
      #       
      #       # Increment price count at index if the varaint is within the price range
      #       price_range_matches[index] = price_range_matches[index] + 1 if variant.price > min and variant.price < max
      #     end
      #   end
      # end
      # 
      # # Remove nil and duplicate values from vendor_ids array
      # vendor_ids = vendor_ids.compact.uniq
      # 
      # # Define search filter's vendors
      # search_filter.vendors = if vendor_ids.any? then vendor_ids.collect { |vendor_id| Vendor.find(vendor_id) } else nil end
      # 
      # # Remove nil and duplicate values from option name arrays
      # option1['name'] = option1['name'].compact.uniq
      # option2['name'] = option2['name'].compact.uniq
      # option3['name'] = option3['name'].compact.uniq
      # 
      # # ?? If option name array have exactly 1 value then set the search filter's option values
      # search_filter.option1 = if option1['name'].count == 1 then { 'name' => option1['name'][0], 'values' => option1['values'].compact.uniq.sort } else nil end
      # search_filter.option2 = if option2['name'].count == 1 then { 'name' => option2['name'][0], 'values' => option2['values'].compact.uniq.sort } else nil end
      # search_filter.option3 = if option3['name'].count == 1 then { 'name' => option3['name'][0], 'values' => option3['values'].compact.uniq.sort } else nil end
      # 
      # # Define search filter prices
      # search_filter.prices = []
      # price_range_matches.each_index { |index| search_filter.prices << prices_ranges[index] if price_range_matches[index] > 0 }
      # search_filter.prices = nil if search_filter.prices.empty?
      # 
      # # Inject the search filter into the database
      # search_filter.save
      # 
      # # Finally, return the filter; NOTE: find out of the database so the hashes get serialized correctly
      # return SearchFilter.find(search_filter.id)
      
      ########################################
      
      # url2 = self.exclude_params_from_url(url, exclude_params)
      # 
      # if SearchFilter.exists?(:url => url2)
      #   return SearchFilter.where(:url => url2).first
      # end
      # 
      # f = SearchFilter.new
      # f.url = url2
      # 
      # Caboose.log url2
      # url2 = url2.split("?")[0] if url2.include?('?')     
      # Caboose.log url2
      # 
      # parent = nil
      # # selected_cat_id = nil
      # 
      # Caboose.log("url2 = #{url2}")
      # 
      # pager.options['base_url'] = url2
      # 
      # if Category.exists?(:url => url2)
      #   
      #   parent = Category.where(:url => url2).first
      #   f.category_id = parent.id #if parent
      #   parent = Category.find(parent.parent_id) if parent && parent.children && parent.children.count == 0
      #   
      # elsif pager.params['category_id'] && pager.params['category_id'] != ''
      #   
      #   cat_id = pager.params['category_id'].kind_of?(Array) ? pager.params['category_id'][0] : pager.params['category_id'] 
      #   cat = Category.find(cat_id)
      #   parent = cat.parent
      #   f.category_id = cat.id if !pager.params['category_id'].kind_of?(Array)
      #   
      # elsif pager.params['category_slug'] && pager.params['category_slug'] != ''
      #   
      #   slug = pager.params['category_slug'].kind_of?(Array) ? pager.params['category_slug'][0] : pager.params['category_slug'] 
      #   cat = Category.where(:slug => slug).first
      #   parent = cat.parent
      #   f.category_id = cat.id if !pager.params['category_slug'].kind_of?(Array)
      #   
      # end
      # 
      # f.category = nil
      # 
      # if parent && parent.children && parent.children.count > 0
      #   f.category = { 
      #     'id'        => parent.id,
      #     'name'      => parent.name,
      #     'selected'  => parent.id == f.category_id,
      #     'children'  => parent.children.collect { |cat| { 
      #         'id'       => cat.id, 
      #         'name'     => cat.name, 
      #         'url'      => cat.url, 
      #         'selected' => cat.id == f.category_id 
      #       }
      #     }
      #   }
      # end
      # pager.params['category_id'] = f.category_id if pager.params['category_id'].nil? || pager.params['category_id'] == ''
      # 
      # f.title_like = pager.params['title_like'] if pager.params['title_like']
      #       
      # vendor_ids = []
      # option1 = Caboose::StdClass.new({ 'name' => [], 'values' => [] })
      # option2 = Caboose::StdClass.new({ 'name' => [], 'values' => [] })
      # option3 = Caboose::StdClass.new({ 'name' => [], 'values' => [] })      
      # min = 0.0
      # max = 1000000.0
      # 
      # prices = [
      #   [    0,    10],
      #   [   10,    25],
      #   [   25,    50],
      #   [   50,    75],
      #   [   75,   100],
      #   [  100,   150],
      #   [  150,   200],
      #   [  200,   250],
      #   [  250,   300],
      #   [  300,   400],
      #   [  400,   500],
      #   [  500,  1000],
      #   [ 1000,  2000],
      #   [ 2000,  3000],
      #   [ 4000,  5000],
      #   [ 7000,  7500],
      #   [ 7500, 10000],
      #   [10000, 50000]                
      # ]      
      # price_counts = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      # 
      # pager.all_items.each do |p|
      #   vendor_ids   << p.vendor_id
      #   option1.name << p.option1
      #   option2.name << p.option2
      #   option3.name << p.option3                
      #   p.variants.each do |v|
      #     option1.values << v.option1
      #     option2.values << v.option2
      #     option3.values << v.option3          
      #     
      #     next if v.price.nil?
      #     
      #     min = v.price if v.price < min
      #     max = v.price if v.price > max
      #     prices.each_index do |i|
      #       minmax = prices[i]
      #       price_counts[i] = price_counts[i] + 1 if v.price > minmax[0] && v.price < minmax[1]
      #     end
      #   end
      # end
      # 
      # vendor_ids = vendor_ids ? vendor_ids.compact.uniq : nil       
      # f.vendors = vendor_ids && vendor_ids.count > 0 ? vendor_ids.collect { |vid| Vendor.find(vid) } : nil
      # 
      # option1.name = option1.name ? option1.name.compact.uniq : nil
      # option2.name = option2.name ? option2.name.compact.uniq : nil
      # option3.name = option3.name ? option3.name.compact.uniq : nil
      # 
      # f.option1 = option1.name && option1.name.count == 1 ? Caboose::StdClass.new({ 'name' => option1.name[0], 'values' => option1.values.compact.uniq.sort }) : nil 
      # f.option2 = option2.name && option2.name.count == 1 ? Caboose::StdClass.new({ 'name' => option2.name[0], 'values' => option2.values.compact.uniq.sort }) : nil 
      # f.option3 = option3.name && option3.name.count == 1 ? Caboose::StdClass.new({ 'name' => option3.name[0], 'values' => option3.values.compact.uniq.sort }) : nil       
      # 
      # f.prices = []
      # 
      # price_counts.each_index do |i| 
      #   f.prices << prices[i] if price_counts[i] > 0
      # end
      # 
      # f.prices = nil if f.prices.count == 0
      # f.save
      # 
      # return SearchFilter.find(f.id)
    end
  end
end
