class Log < ActiveRecord::Base
	belongs_to :pattern

	def self.search(search)
    if search
      where("LOWER(text) LIKE :search", search: "%#{search.downcase}%") 
    else
      []
    end
  end 
end
