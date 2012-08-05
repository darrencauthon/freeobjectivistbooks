class AddSourceToTestimonials < ActiveRecord::Migration
  def change
    change_table :testimonials do |t|
      t.references :source, polymorphic: true
    end
  end
end
