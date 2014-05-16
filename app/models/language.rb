class Language < ActiveRecord::Base
  EN = "en"
  IT = "it"
  PT_BR = "pt-BR"
  has_many :publishers
  has_many :banners

  validates :code, :presence => true,
                   :uniqueness => true

  validates :name, :presence => true,
                   :uniqueness => true

  def translation_available?
     self.code == EN || self.code == IT
  end  
end
