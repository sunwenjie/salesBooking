class AddAdmeasureStateToAdvertisements < ActiveRecord::Migration
  def change
    add_column :advertisements, :admeasure_state, :string
  end
end
