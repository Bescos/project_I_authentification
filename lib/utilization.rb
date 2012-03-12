class Utilization < ActiveRecord::Base
  belongs_to :user
  belongs_to :application
end
