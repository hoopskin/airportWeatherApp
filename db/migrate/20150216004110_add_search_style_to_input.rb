class AddSearchStyleToInput < ActiveRecord::Migration
  def change
    add_column :inputs, :searchStyle, :string
  end
end
