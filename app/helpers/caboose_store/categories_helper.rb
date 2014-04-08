module CabooseStore
  module CategoriesHelper
    def top_level_categories
      CabooseStore::Category.top_level
    end
  end
end
