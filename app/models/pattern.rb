class Pattern < ActiveRecord::Base
	has_many :logs, dependent: :destroy
	has_many :tags, dependent: :destroy
	validates :text, :uniqueness => true

	def self.search(search)
    if search
      where("LOWER(text) LIKE :search", search: "%#{search.downcase}%") 
    else
      []
    end
  end 

end
