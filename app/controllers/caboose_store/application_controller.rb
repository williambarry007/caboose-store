
module CabooseStore
  class ApplicationController < Caboose::ApplicationController
    protect_from_forgery
    layout 'layouts/caboose/application'
    helper :all
  end
end
