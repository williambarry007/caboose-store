module CabooseStore
  class CabooseStoreHelper
    def initialize(app_path, force = false)
      @app_path = app_path
      @force = force
    end
    
    def init_all
      init_routes
    end
     
    # Adds the routes to the host app to point everything to caboose
    def init_routes
      puts "Adding the caboose store routes..."
    
      filename = File.join(@app_path,'config','routes.rb')
      return if !File.exists?(filename)
      return if !@force
    
      str = "" 
      str << "\t# Catch everything with caboose\n"  
      str << "\tmount CabooseStore::Engine => '/'\n"
    
      file = File.open(filename, 'rb')
      contents = file.read
      file.close    
      if (contents.index(str).nil?)
        arr = contents.split('end', -1)
        str2 = arr[0] + "\n" + str + "\nend" + arr[1]
        File.open(filename, 'w') {|file| file.write(str2) }
      end    
    end
  end
end