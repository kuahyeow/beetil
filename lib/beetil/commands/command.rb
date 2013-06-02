module Beetil
  module Commands
    class CommandError < StandardError; end

    class Command
      attr_reader :args
      def initialize(args)
        @args = args
      end

      def self.run!(command, args)
        raise "No commands configured!" unless respond_to?(:available_commands)
        command_class = available_commands[command].first
        command_class.new(args).run!
      end

      protected
      # TODO use different output
      def display(message)
        puts message
      end
    end
  end
end
