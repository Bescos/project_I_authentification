require 'active_record'
class Utilization < ActiveRecord::Base
  belongs_to :user
  belongs_to :application

	validates :user_id, :presence => true
  validates :application_id, :presence => true

#add the utilization if the user have not used application yet
def self.useappli?(uid,aid)
	if ut = find_by_user_id_and_application_id(uid,aid)
		 true
	else
		u = User.new
		u = create(uid,aid)
	end
end


end
