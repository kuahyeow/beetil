require 'beetil/commands/command'
require 'beetil/commands/title'

# Do a little config dance here for commands
module Beetil
  module Commands
    module CommandList
      def available_commands
        {
          "title" => [Title, "returns the title of the beetil"]
        }
      end
    end

    Command.extend(CommandList)
  end
end
