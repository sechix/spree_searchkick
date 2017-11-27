class AddFilterableToSpreeOptionType < ActiveRecord::Migration
  def change
    add_column :spree_option_types, :filterable, :boolean
  end
end