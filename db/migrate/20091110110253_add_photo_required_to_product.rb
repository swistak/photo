class AddPhotoRequiredToProduct < ActiveRecord::Migration
  def self.up
    add_column :products,  :photo_required, :boolean, :default => false
    add_column :products,  :size,   :string
    add_column :products,  :faces,  :string
  end

  def self.down
    remove_column :products, :photo_required
  end
end