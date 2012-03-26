module Mailgun
  class Campaign < Base
    class << self
      def campaign_limit_error? e
        return false unless e.response && e.response.code == 500
        begin
          hash = JSON.parse e.response.body
          return false unless hash['message']
          hash['message'] =~ /campaigns limit.* reached/i
        rescue
          false
        end
      end

      def last
        campaigns = all
        count = campaigns['total_count']
        if campaigns['items'].size < count
          campaigns = all skip: (count-1)
        end
        new campaigns['items'].last
      end

      def prune_campaigns
        last.destroy
      end

      def prune_if_needed_and_add campaign
        retried = false
        begin
          add campaign
        rescue => e
          if !retried && campaign_limit_error?(e)
            prune_campaigns
            retried = true
            retry
          else
            raise e
          end
        end
      end

      def prune_if_needed_and_create attributes
        campaign = new attributes
        prune_if_needed_and_add campaign
      end
    end
  end
end
