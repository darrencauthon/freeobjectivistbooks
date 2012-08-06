class AddTypeAndPriorityToTestimonials < ActiveRecord::Migration
  def change
    change_table :testimonials do |t|
      t.string :type
      t.float :priority, null: false, default: 0
    end
  end
end
