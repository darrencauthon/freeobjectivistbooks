class CreateCampaignTargets < ActiveRecord::Migration
  def change
    create_table :campaign_targets do |t|
      t.string :name
      t.string :email
      t.string :group
      t.string :last_campaign
      t.datetime :emailed_at

      t.timestamps
    end
  end
end
