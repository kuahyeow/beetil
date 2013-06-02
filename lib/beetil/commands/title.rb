module Beetil
  module Commands
    class Title < Command
      def run!
        # Run typhoeus with change + incidents :)
        change = Beetil::Change.find(args.first)
        incident = Beetil::Incident.find(args.first)
        item = change || incident
        raise CommandError.new("Title not found") unless item
        display item.title
      end
    end
  end
end
