class AddLanguageToExaminations < ActiveRecord::Migration
  def change
    add_column :examinations, :language, :string
  end
end
