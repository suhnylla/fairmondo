module Auction::Images
  extend ActiveSupport::Concern

  included do
    # ---- IMAGES ------
  
    has_many :images , :dependent => :destroy
    accepts_nested_attributes_for :images, :allow_destroy => true
 
    def title_image
      if images.empty?
        return nil
      else
        return images[0]
      end
    end

  end
end