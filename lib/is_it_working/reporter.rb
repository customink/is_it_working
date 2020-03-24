module IsItWorking
  class Reporter
    attr_reader :name, :filters, :func

    def initialize(filters, func)
      @filters = filters
      @func = func
    end

    def report_on?(filter)
      filters.include? filter.name
    end

    def report(filter)
      func.call(filter.name, filter.status && filter.status.time.to_f)
    end

    class << self
      # Run reporters for each named filter in their respective lists
      def run_reporters(reporters, filters)
        reporters.each do |reporter|
          filters.each do |filter|
            reporter.report(filter) if reporter.report_on? filter
          end
        end
      end
    end
  end
end
