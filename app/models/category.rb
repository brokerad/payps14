class Category < ActiveRecord::Base

  has_many :ad_has_categories
  has_many :ads, :through => :ad_has_categories

  validates  :name_it,
            :name_en,
            :name_pt_BR, :presence => true

  scope :active_categories, where(:active => true)

  public

  # Return the name of the publisher's language
  def get_category_name_for_publisher(publisher)
    case publisher.language.code

      when "it"
        name = self.name_it

      when "pt-BR"
        name = self.name_pt_BR

      else
        name = self.name_en
    end
    return name
  end

end
