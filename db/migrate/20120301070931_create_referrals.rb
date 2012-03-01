class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.string :source
      t.string :medium
      t.text :landing_url
      t.text :referring_url

      t.timestamps
    end

    add_column :users, :referral_id, :integer
    add_index :users, :referral_id

    add_column :requests, :referral_id, :integer
    add_index :requests, :referral_id

    add_column :pledges, :referral_id, :integer
    add_index :pledges, :referral_id
  end
end
