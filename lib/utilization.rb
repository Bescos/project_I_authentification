require 'active_record'
class Utilization < ActiveRecord::Base
  belongs_to :user
  belongs_to :application

	validates :user_id, :presence => true
  validates :application_id, :presence => true

end
