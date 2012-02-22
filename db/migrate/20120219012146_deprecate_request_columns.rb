class DeprecateRequestColumns < ActiveRecord::Migration
  def change
    rename_column :requests, :donor_id, :donor_id_deprecated
    rename_column :requests, :flagged, :flagged_deprecated
    rename_column :requests, :thanked, :thanked_deprecated
    rename_column :requests, :status, :status_deprecated

    rename_column :events, :donor_id, :donor_id_deprecated
  end
end
