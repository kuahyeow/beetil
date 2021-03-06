module Beetil
  class Results
    attr_reader :raw_results, :results

    def initialize(raw_results)
      @raw_results = raw_results
      @results = Hashie::Mash.new(raw_results)
    end

    def has_result?(beetil_type)
      results.respond_to?(:result) && results.result.respond_to?(beetil_type)
    end

    def has_errors?
      !errors.empty?
    end

    def beetil_item(klass)
      results.result.send(klass.model_name)
    end

    # According to API docs, there'll be an "errors" element containing individual "error" items
    def errors
      errors_list.map(&:error)
    end

    # Work around very bad API design
    def not_found?
      has_errors? && !not_found_errors.empty?
    end

    def other_errors?
      has_errors? && not_found_errors.empty?
    end

    protected
    def errors_list
      if results.respond_to?(:errors)
        results.errors
      else
        []
      end
    end

    def not_found_errors
      errors.select{|e| e.scan(/E400.*found/)}
    end
  end

  class Base < Hashie::Mash
    class ApiError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
      end

      def message
        errors.join('; ')
      end
    end
    class NotFound < ApiError; end


    class << self

      def model_name(name = nil)
        @model_name ||= (name || ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self)))
      end

      def table_name(name = nil)
        @table_name ||= (name || ActiveSupport::Inflector.pluralize(model_name))
      end

      def find(id, opts = {})
        raise_on_404 = opts.delete(:raise_on_404) { false }

        result = perform_beetil_request(:get, "#{table_name}/#{id}", opts)
        raise NotFound.new(result.errors) if result.not_found? && raise_on_404
        raise ApiError.new(result.errors) if result.other_errors?
        new(result.beetil_item(self)) if result.has_result?(model_name)
      end

      def create(opts = {})
        perform_beetil_request(:post, "#{base_uri}/#{table_name}", model_name.downcase.to_sym => opts)
      end

      def update(id, opts = {})
        perform_beetil_request(:put, "#{base_uri}/#{table_name}/update", :id => id, model_name.downcase.to_sym => opts)
      end

      def all(opts = {})
        results = perform_beetil_request(:get, "#{base_uri}/#{table_name}", opts)
        results.beetil_item(model_name) if result.has_result?(model_name)
      end

      protected
      def perform_beetil_request(method, url, opts)
        @connection = Connection.new(Beetil.base_url, Beetil.api_token)
        response = @connection.send(method, url, opts)
        Results.new(response.body)
      end
    end

    # Instance Methods

    def new_record?
      self.id.nil?
    end
  end
end
