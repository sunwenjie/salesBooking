class Role < ActiveRecord::Base
  
  acts_as_nested_set

  has_many :users,inverse_of: :role

  validates :name, presence: true, uniqueness: true

  def has_parent?
    !parent_id.nil? && parent_id != 0
  end

  def parent_ids
    ids = []
    parent_id = self.parent_id
    while parent_role = Role.find_by_id(parent_id)
      if parent_role
        ids << parent_role.id
        parent_id = parent_role.parent_id
      else
        break
      end
    end
    ids
  end

  def children_ids
    ids = []
    parent_id = self.id
    while child_role = Role.find_by_parent_id(parent_id)
      if child_role
        ids << child_role.id
        parent_id = child_role.id
      else
        break
      end
    end
    ids
  end

  class<<self


  def user_role(role_name)
  	 find_by_name(role_name).id
  end

  def super_admin
    ["admin","super_user"]
  end


  %w{planner legal_officer sales_manager sales_president operater operaters_manager}.each do |_|
      eval %Q(
        def #{_}_function_group
          ["admin","super_user","#{_}"]
        end
      )
  end


  def sale_function_group
    ["sale","team_head","admin","super_user"]
  end
  

  end

end
