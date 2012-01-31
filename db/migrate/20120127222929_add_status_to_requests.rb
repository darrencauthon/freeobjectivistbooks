class AddStatusToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :status, :string
    execute "update requests set status='not_sent' where donor_id is not null"
  end
end
