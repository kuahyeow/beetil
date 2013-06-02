module Beetil
  class Connection
    attr_reader :base_url
    attr_reader :faraday
    attr_reader :token

    def initialize(base_url, token)
      @base_url = base_url
      @token = token
      @faraday = create_faraday_connection(base_url)
      @faraday.basic_auth 'x', token
    end

    def get(*args)
      faraday.get(*args)
    end

    protected
    def create_faraday_connection(base_url)
      Faraday.new(:url => base_url) do |conn|
        conn.request :json                    # Beetil accepts json or xml, so request JSON
        conn.request  :url_encoded            # form-encode POST params, as required by Beetil

        conn.response :json                   # requires json gem install in 1.8.7

        conn.adapter Faraday.default_adapter  # make http requests with Net::HTTP
      end
    end
  end
end
