class Event < ActiveRecord::Base
	has_many :synonyms, dependent: :destroy

	def self.search(search)
    if search
      where("LOWER(tag) LIKE :search OR LOWER(clasification) LIKE :search", search: "%#{search.downcase}%") 
    else
      []
    end
  end
end
