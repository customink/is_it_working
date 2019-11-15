module IsItWorking
  # Wrapper around a status check.
  class Filter
    class AsyncRunner < Thread
      attr_accessor :filter_status
    end

    class SyncRunner
      attr_accessor :filter_status

      def initialize
        yield
      end

      def join
      end
    end

    attr_reader :async, :name, :runner, :status

    # Create a new filter to run a status check. The name is used for display purposes.
    def initialize(name, check, async = true)
      @name = name
      @check = check
      @async = async
    end

    # Run a status check. This method keeps track of the time it took to run
    # the check and will trap any unexpected exceptions and report them as failures.
    def run
      @status = Status.new(name)
      @runner = (async ? AsyncRunner : SyncRunner).new do
        t = Time.now
        begin
          @check.call(status)
        rescue Exception => e
          status.fail("#{name} error: #{e.inspect}")
        end
        status.time = Time.now - t
      end
      runner.filter_status = status
      runner
    end

    class << self
      # Run a list of filters and return their status objects
      def run_filters(filters)
        filters.map(&:run).each(&:join)
        filters.map(&:status)
      end
    end
  end
end
