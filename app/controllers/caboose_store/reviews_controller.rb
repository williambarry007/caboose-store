module CabooseStore
  class ReviewsController < CabooseStore::ApplicationController  
  
    def add
      content = params[:content]
      product_id = params[:product_id]
      rating = params[:rating]
      name = params[:name]    
      r = Review.new(:content => content, :product_id => product_id, :rating => rating, :name => name)
      r.save
      render :json => true
    end
  
  end
end
