class Parser < ActiveRecord::Base
	def self.search(search)
    if search
      where("LOWER(name) LIKE :search OR LOWER(expression) LIKE :search OR LOWER(source_group) LIKE :search", search: "%#{search.downcase}%") 
    else
      []
    end
  end 
end
