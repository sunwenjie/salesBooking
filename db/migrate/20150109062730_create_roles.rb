class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => false, :index => true
      t.integer :rgt, :null => false, :index => true
      t.timestamps
    end

    sale = Role.create(:name => "sale")

    team_head = Role.create(:name => "team_head")

    sales_manager = Role.create(:name => "sales_manager")

    sales_president = Role.create(:name => "sales_president")

    planner = Role.create(:name => "planner")

    media_assessing_officer = Role.create(:name => "media_assessing_officer")

    product_assessing_officer = Role.create(:name => "product_assessing_officer")

    operater = Role.create(:name => "operater")

    operaters_manager = Role.create(:name => "operaters_manager")

    admin = Role.create(:name => "admin")

    sale.parent = team_head
    sale.save

    team_head.parent  = sales_manager
    team_head.save

    sales_manager.parent = sales_president
    sales_manager.save

    operater.parent = operaters_manager
    operater.save

  end

  
end
