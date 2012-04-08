class AddStatusUpdatedAtToDonations < ActiveRecord::Migration
  def up
    add_column :donations, :status_updated_at, :timestamp

    say_with_time "Backfilling status update times" do
      Donation.find_each do |donation|
        donation.status_updated_at = donation.updated_at_for_status donation.status
        donation.save!
      end
    end
  end

  def down
    remove_column :donations, :status_updated_at
  end
end
