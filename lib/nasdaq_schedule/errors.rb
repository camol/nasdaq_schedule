module NasdaqSchedule
  module Errors
    class NotWorkingDay < StandardError
      def initialize(msg = "Nasdaq is not working on passed date")
        super
      end
    end
  end
end
