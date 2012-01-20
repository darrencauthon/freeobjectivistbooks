class Admin::CampaignTargetsController < AdminController
  include ActionView::Helpers::TextHelper

  def index
    @targets = CampaignTarget.order('updated_at desc')
  end

  def create
    created = 0
    updated = 0

    attribute_hashes = ActiveSupport::JSON.decode params[:targets_json]
    attribute_hashes.each do |attributes|
      target = CampaignTarget.find_or_initialize_by_email attributes['email']
      target.attributes = attributes
      if !target.id
        created += 1
      elsif target.changed?
        updated += 1
      end
      target.save!
    end

    if created > 0
      notice = "#{pluralize created, 'target'} created"
      if updated > 0
        notice += ", #{updated} updated"
      end
    elsif updated > 0
      notice = "#{pluralize updated, 'target'} updated"
    else
      notice = "No changes."
    end
    flash[:notice] = notice

    redirect_to action: :index
  end

  def destroy
    @target = CampaignTarget.find params[:id]
    @target.destroy
    flash[:notice] = "Deleted #{@target.name} (#{@target.email})."
    redirect_to action: :index
  end
end
