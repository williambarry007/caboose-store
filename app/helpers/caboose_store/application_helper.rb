module CabooseStore
  module ApplicationHelper
    def parent_categories
      CabooseStore::Category.find(1).children
    end
  end
end

