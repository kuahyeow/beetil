require 'beetil'
require 'beetil/commands'
require 'optparse'
require 'shellwords'

module Beetil
  class Runner
    attr_reader :options

    def self.run!
      new(ARGV)
    end

    def initialize(args)
      @options = {}
      extract_arguments!(args)
      configure_beetil!
      Beetil::Commands::Command.run!(options[:command], args)
    rescue Beetil::Commands::CommandError => e
      error_out(e.message)
    end

    protected
    def extract_arguments!(args)
      option_file_args = parse_options_file!
      option_parser.parse!(option_file_args)
      option_parser.parse!(args)
      options[:command] = args.shift unless options[:command]

      print_out_command_list(true) if options[:command].nil? || !Beetil::Commands::Command.available_commands.keys.include?(options[:command])
      error_out("Missing token") if options[:token].nil?
    end

    def configure_beetil!
      Beetil.configure do |config|
        config.api_token = options[:token]
      end
    end

    def option_parser
      @option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: beetil command [options] [arguments]"

        opts.on("--help", "Prints out this message") do
          puts "Install: Make sure to confirm your API token from your user details."
          puts "         All options should be readable from ~/.beetil if you so wish."
          puts

          puts opts
          exit
        end

        opts.on("-h", "Help") do
          puts opts
          exit
        end

        opts.on("-l", "--list-comands", "List of commands available") do
          print_out_command_list
          exit
        end

        opts.on("-t", "--token TOKEN", "API Token to use") do |token|
          options[:token] = token
        end

        opts.on("-e", "--execute COMMAND", "Command to execute") do |command|
          options[:command] = command
        end
      end
    end

    def parse_options_file!
      path = global_options_file
      return [] unless path && File.exist?(path)
      File.read(global_options_file).split(/\n+/).map {|l| Shellwords.shellwords(l) }.flatten
    end

    def error_out(message)
      puts "Error: #{message}"
      exit 1
    end

    private
    def global_options_file
      File.join(File.expand_path("~"), ".beetil")
    end

    def print_out_command_list(error = false)
      message = "List of commands: \n"
      message = "Specify a command. Perhaps you meant:\n" if error
      message << Beetil::Commands::Command.available_commands.map do |trigger, (klass, description)|
        "  #{trigger} - #{description}"
      end.join("\n")
      error_out(message)
    end
  end
end
