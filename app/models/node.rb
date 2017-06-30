class Node < ActiveRecord::Base
has_many :approval_flows,:inverse_of => :node
has_many :permissions, :inverse_of => :node
has_many :examinations, :inverse_of => :node
end
