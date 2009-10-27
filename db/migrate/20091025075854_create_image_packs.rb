class CreateImagePacks < ActiveRecord::Migration
  def self.up
    create_table :image_packs do |t|
      t.column :order_id, :integer
      t.column :pack_type, :string
    end

    add_column :assets, :notes, :text
  end

  def self.down
    drop_table :image_packs
    remove_column :assets, :notes
  end
end