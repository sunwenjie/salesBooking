class AddProofStateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :proof_state, :string
  end
end
