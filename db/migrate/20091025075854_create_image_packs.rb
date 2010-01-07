class CreateImagePacks < ActiveRecord::Migration
  def self.up
    add_column :assets, :notes, :text
    add_column :assets, :author_id, :integer
    add_column :orders, :has_user_images, :boolean
  end

  def self.down
    remove_column :orders, :has_user_images
    remove_column :assets, :author_id
    remove_column :assets, :notes
  end
end