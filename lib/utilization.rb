require 'active_record'
class Utilization < ActiveRecord::Base
  belongs_to :user
  belongs_to :application

	validates :user_id, :presence => true
  validates :application_id, :presence => true

#add the utilization if the user have not used application yet
def self.useappli?(uid,aid)
	if ut = find_by_user_id(uid)
		 if !ut.application_id == aid
		 	 new(uid,aid) 
		 else
			 true
		 end
	else
		new(uid,aid)
	end
end

end
