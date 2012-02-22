class CreateDonations < ActiveRecord::Migration
  def initialize
    super
    @warn = 0
    @error = 0
  end

  def warn(message)
    say "WARN  #{message}", true
    @warn += 1
  end

  def error(message)
    say "ERROR #{message}", true
    @error += 1
  end

  def up
    create_table :donations do |t|
      t.references :request
      t.references :user
      t.string :status
      t.boolean :flagged, null: false, default: false
      t.boolean :thanked, null: false, default: false
      t.boolean :canceled, null: false, default: false

      t.timestamps
    end
    add_index :donations, :request_id
    add_index :donations, :user_id

    change_table :requests do |t|
      t.references :donation
    end
    add_index :requests, :donation_id

    change_table :events do |t|
      t.references :donation
    end
    add_index :events, :donation_id

    say_with_time "Creating donations" do
      Request.find_each do |request|
        donation = nil

        request.events.order(:happened_at).each do |event|
          donor = event.donor

          if !donor
            say "Skipping #{event.type} event #{event.id} with no donor", true
            next
          end

          if donation.nil? || event.type == "grant" || request != donation.request
            donation = request.donations.create user: donor, created_at: event.happened_at
            say "Created new donation #{donation.id} from event #{event.id}: #{donor.name} grants #{request.book} to #{request.user.name}", true
          end

          if request.user.address.blank?
            donation.flagged = true
            say "    flagging donation #{donation.id} because address is missing", true if donation.changed?
            donation.save!
          end

          donation.thanked = true if event.is_thanks?
          donation.flagged = true if event.type == "flag" && request.flagged?
          donation.status = event.detail if event.type == "update_status"
          donation.canceled = true if event.type == "cancel"
          say "    updating donation #{donation.id} from #{event.type} event #{event.id}: #{donation.changes}", true if donation.changed?
          donation.save!

          event.donation = donation
          event.save!
        end

        if donation
          request.donation = donation unless donation.canceled?
          say "Request #{request.id} donation is now #{donation.id}", true if request.changed?
          request.save!
        end
      end
    end

    say_with_time "Canceling donations as needed" do
      Donation.find_each do |donation|
        if !donation.canceled? && donation != donation.request.donation
          say "Canceling donation #{donation.id} because request #{donation.request.id} points to donation #{donation.request.donation.id}", true
          donation.canceled = true
          donation.save!
        end
      end
    end

    say_with_time "Checking data integrity: granted requests" do
      Request.granted.find_each do |request|
        donation = request.donation
        if !donation
          error "Request #{request.id} is granted but has no donation"
          next
        end

        error "Request #{request.id}: donation is for request #{donation.request.id}!" if request != donation.request
        error "Request #{request.id}: donor is nil" if !request.donor
        error "Request #{request.id}: expected donor #{request.donor.name}, got #{donation.user.name}" if request.donor && request.donor != donation.user

        if request.flagged? != donation.flagged?
          warn "Request #{request.id}: expected flagged #{request.flagged?}, got #{donation.flagged?}"
          donation.flagged = request.flagged?
        end

        if request.thanked? != donation.thanked?
          warn "Request #{request.id}: expected thanked #{request.thanked?}, got #{donation.thanked?}"
          donation.thanked = request.thanked?
        end

        if request.status != donation.status
          warn "Request #{request.id}: expected status #{request.status}, got #{donation.status}"
          donation.status = request.status
        end

        donation.save!
      end
    end

    say_with_time "Checking data integrity: open requests" do
      Request.open.find_each do |request|
        if request.donation
          warn "Request #{request.id} is open but has donation #{request.donation.id}"
          request.donation = nil
          request.save!
        end
      end
    end

    say_with_time "Checking data integrity: donation canceled status" do
      Donation.find_each do |donation|
        canceled = donation != donation.request.donation
        if donation.canceled? != canceled
          warn "Donation #{donation.id}: expected canceled #{canceled}, got #{donation.canceled?}"
          donation.canceled = canceled
          donation.save!
        end
      end
    end

    say_with_time "Checking data integrity: events" do
      Event.find_each do |event|
        donor = event.donor
        donation = event.donation
        if donor && !donation
          error "Event #{event.id} has a donor (#{donor.name}) but no donation"
        elsif donation && !donor
          warn "Event #{event.id} has no donor but has donation from #{donation.user.name}"
          event.donation = nil
          event.save!
        elsif donation && donor != donation.user
          error "Event #{event.id}: expected donor #{donor.name}, got #{donation.user.name}"
        end
      end
    end

    say "Data integrity errors: #{@error}, warnings: #{@warn}"
  end

  def down
    drop_table :donations
    remove_column :requests, :donation_id
    remove_column :events, :donation_id
  end
end
