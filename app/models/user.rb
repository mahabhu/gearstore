require 'ruby_drupal_hash'

class User < ActiveRecord::Base
  set_primary_key 'id'

	has_many :rentals
  has_many :user_notes
	has_one :deposit

  has_and_belongs_to_many :roles

	def self.admins
    # 23 is the role id for gear store officers. FIXME
    Role.find(3).users.sort{|x, y| x.name <=> y.name}
	end
	
  def self.authenticate(user, pass)
    u = User.find(:first, :conditions => {:username => user}) 
    return (u.verify_password(pass) and u.admin?) ? u : nil ;
  end
  
  def verify_password(candidate_password)
    return RubyDrupalHash.new.verify(candidate_password, pass)
  end

  def admin?
     # 23 is the role id for gear store officers. FIXME    
    return roles.reject{|r| r.id != 3}.size > 0
  end

	def deposit_amount
		return (deposit.nil?)?(0):(deposit.amount)
	end

	def rental_number
		rentals.reject{|r| !r.active?}.size	
	end

	def overdue_rental_number
		rentals.reject{|r| !r.overdue?}.size
	end

	def has_overdue?
		overdue_rental_number > 0 
	end

  def has_active?
		rentals.reject{|r| !r.active?}.size > 0
  end
end
