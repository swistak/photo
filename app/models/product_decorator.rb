Product.class_eval do
  AVAILABLE_SIZES = ["Small", "Large", "XL", "XXL"]
  AVAILABLE_FACES = ["one photo", "two photos", "couple photo", "four photos", "two couple photos"]

  validates_uniqueness_of :size, :scope => [:name, :size], :message => "needs changing. There is already one product with this name and size"

  def other_sizes
    Product.find(:all, :conditions => {
        :name => self.name,
        :faces => self.faces,
      }, :order => "size ASC")
  end

  def other_faces
    Product.find(:all, :conditions => {
        :name => self.name,
        :size => self.size,
      }, :order => "faces ASC")
  end

  def related_products
    Product.find(:all, :conditions => ["name = ? AND id != ?", self.name, self.id])
  end

  def before_save
    if self.name_changed?
      old_name, new_name = *self.name_change
      Product.update_all({:name => new_name}, {:name => old_name})
    end
    if self.description_changed?
      Product.update_all({:description => self.description}, {:name => self.name})
    end
  end

  def clone_attributes
    attrs = [
      :name, :available_on, :price, :sku, :size, :faces, :photo_required,
      :create_variants, :prototype_id
    ].map{|a| [a, send(a)]}
    Hash[*attrs.flatten]
  end

  def to_param
    return permalink unless permalink.blank?
    [name, faces, size].compact.map(&:to_url).join("-")
  end
end