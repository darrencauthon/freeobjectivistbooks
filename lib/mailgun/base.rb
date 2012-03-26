module Mailgun
  class Base
    cattr_accessor :test_mode

    class << self
      @@stub_data = {}

      def base_url
        "https://api.mailgun.net/v2/#{Rails.application.config.mailgun_domain}"
      end

      def user
        "api"
      end

      def password
        Rails.application.config.mailgun_api_key
      end

      def site
        @@site ||= RestClient::Resource.new base_url, user: user, password: password do |response, request, result, &block|
          case response.code
          when 200..299 then JSON.parse response
          else response.return! request, result, &block
          end
        end
      end

      def path
        name.demodulize.tableize
      end

      def client
        site[path]
      end

      def all
        return @@stub_data.values if test_mode
        Rails.logger.info "GET #{client}"
        client.get
      end

      def find id
        object = new id: id
        object.load
      end

      def add object
        return stub(object) if test_mode
        Rails.logger.info "POST #{client} #{object.attributes}"
        response = client.post object.attributes
        attributes = response[name.demodulize.underscore]
        object.attributes = attributes if attributes
        object
      end

      def create attributes
        object = new attributes
        add object
      end

      def stub(object)
        @@stub_data[object.id] = object
      end
    end

    def initialize attributes = {}
      self.attributes = attributes
    end

    def attributes
      @attributes ||= {}
    end

    def attributes= attributes
      @attributes = attributes.symbolize_keys
    end

    def client
      self.class.client[id]
    end

    def load
      return @@stub_data[id] || (raise RestClient::ResourceNotFound.new) if test_mode
      Rails.logger.info "GET #{client}"
      self.attributes = client.get
      self
    end

    def create
      self.class.add self
    end

    def destroy
      return @@stub_data.delete id if test_mode
      Rails.logger.info "DELETE #{client}"
      client.delete
    end

    private

    def method_missing method, *args, &block
      key = method.to_sym
      if attributes.has_key? method
        self.class.send :define_method, method do
          |*args, &block| attributes[method]
        end
        send method
      else
        super
      end
    end
  end
end
