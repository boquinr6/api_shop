class CreateInventories < ActiveRecord::Migration[7.2]
  def change
    create_table :inventories do |t|
      t.string :code, :null => false
      t.string :name
      t.float :price, :null => false
      t.text :description

      t.timestamps
    end
    add_index :inventories, :code, unique: true
  end
end
