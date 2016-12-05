class User < ActiveRecord::Base
	has_secure_password

	def self.search(search)
    if search
      where("LOWER(name) LIKE :search", search: "%#{search.downcase}%") 
    else
      []
    end
  end 
end
