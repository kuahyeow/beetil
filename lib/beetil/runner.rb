require 'beetil'
require 'beetil/commands'
require 'optparse'

module Beetil
  class Runner
    attr_reader :options

    def self.run!
      new(ARGV)
    end

    def initialize(args)
      @options = {}
      # FIXME extract api_token from options file
      # extract_options_file!
      extract_arguments!(args)
      configure_beetil!
      Beetil::Commands::Command.run!(options[:command], args)
    end

    protected
    def extract_arguments!(args)
      options[:command] = args.shift
      option_parser.parse!(args)
      print_out_command_list if options[:command].nil? || !Beetil::Commands::Command.available_commands.keys.include?(options[:command])

      error_out("Missing token") if options[:token].nil?
    end

    def configure_beetil!
      Beetil.configure do |config|
        config.api_token = options[:token]
      end
    end

    def option_parser
      @option_parser = OptionParser.new do |opts|
        opts.on("-t", "--token TOKEN", "API Token") do |t|
          options[:token] = t
        end
      end
    end

    def error_out(message)
      puts message
      exit 1
    end

    private
    def print_out_command_list
      message = "Specify a command. Perhaps you meant: \n"
      message << Beetil::Commands::Command.available_commands.map do |trigger, (klass, description)|
        "  #{trigger} - #{description}"
      end.join("\n")
      error_out(message)
    end
  end
end
