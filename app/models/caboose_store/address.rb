module CabooseStore
  class Address < ActiveRecord::Base
    self.table_name = "store_addresses"
    
    attr_accessible :id,
      :name,
      :first_name,
      :last_name,
      :street,
      :address1,
      :address2,
      :company,
      :city,
      :state,
      :province,
      :province_code,
      :zip,
      :country,
      :country_code,
      :phone
  
    #validates :street, presence: true
    #validates :address1, presence: true
    #validates :city, presence: true
    #validates :zip, numericality: true
    #validates :phone, uniqueness: true
    #validates :company, presence: true
      
  end
end
