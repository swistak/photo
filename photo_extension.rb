# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PhotoExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/photo"

  # Please use photo/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate
    base = File.dirname(__FILE__)
    Dir.glob(File.join(base, "app/**/*_decorator.rb")){|c| load(c)}

    FileUtils.cp Dir.glob(File.join(base, "public/stylesheets/*.css")), File.join(RAILS_ROOT, "public/stylesheets/")
    FileUtils.cp Dir.glob(File.join(base, "public/javascripts/*.js")), File.join(RAILS_ROOT, "public/javascripts")

    LineItem.class_eval do
      has_many :order_images, :as => :viewable, :order => :position, :dependent => :destroy

      def description
        result = variant.product.name

        unless variant.option_values.empty?
          result +="(" + variant.options_text + ")"
        end
        result
      end
    end
  end
end
