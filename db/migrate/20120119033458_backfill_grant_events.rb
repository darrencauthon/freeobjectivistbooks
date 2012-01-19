class BackfillGrantEvents < ActiveRecord::Migration
  def up
    Request.granted.find_each do |request|
      request.grant request.donor, happened_at: request.updated_at
    end
  end

  def down
    Event.where(type: "grant").destroy_all
  end
end
