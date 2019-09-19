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

    attr_reader :name, :async, :warn_timeout, :timeout

    # Create a new filter to run a status check. The name is used for display purposes.
    def initialize(name, check, async = true, options = {})
      @name = name
      @check = check
      @async = async
      @warn_timeout = options[:warn_timeout] || Float::INFINITY
      @timeout = options[:timeout] || Float::INFINITY
    end

    # Run a status check. This method keeps track of the time it took to run
    # the check and will trap any unexpected exceptions and report them as failures.
    def run
      status = Status.new(name)
      runner = (async ? AsyncRunner : SyncRunner).new do
        t = Time.now
        begin
          @check.call(status)
        rescue Exception => e
          status.fail("#{name} error: #{e.inspect}")
        end
        status.time = Time.now - t
        handle_timing! status
      end
      runner.filter_status = status
      runner
    end

    class << self
      # Run a list of filters and return their status objects
      def run_filters(filters)
        runners = filters.collect{|f| f.run}
        statuses = runners.collect{|runner| runner.filter_status}
        runners.each{|runner| runner.join}
        statuses
      end
    end

    private

    def handle_timing!(status)
      if fail_timeout_exceeded?(status.time)
        status.fail("runtime exceeded critical threshold: #{timeout}ms")
      elsif warn_timeout_exceeded?(status.time)
        status.warn("runtime exceeded warning threshold: #{warn_timeout}ms")
      end
    end

    def warn_timeout_exceeded?(time)
      timeout_exceeded? time, warn_timeout
    end

    def fail_timeout_exceeded?(time)
      timeout_exceeded? time, timeout
    end

    def timeout_exceeded?(time, val)
      # binding.pry if time == nil
      time * 1000 > val
    end
  end
end
