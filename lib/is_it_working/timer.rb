module IsItWorking
  class Timer
    attr_reader :failure_threshold, :filter, :warning_threshold

    def initialize(threshold = Float::INFINITY, warn: Float::INFINITY)
      @failure_threshold = threshold
      @warning_threshold = warn
      @filter = yield
    end

    def call
      status = filter.status
      if fail_timeout_exceeded?(status.time)
        status.fail("runtime exceeded critical threshold: #{failure_threshold}ms")
      elsif warn_timeout_exceeded?(status.time)
        status.warn("runtime exceeded warning threshold: #{warning_threshold}ms")
      end
    end

    class << self
      def run_timers(timers)
        timers.each(&:call)
      end
    end

    private

    def warn_timeout_exceeded?(time)
      timeout_exceeded? time, warning_threshold
    end

    def fail_timeout_exceeded?(time)
      timeout_exceeded? time, failure_threshold
    end

    def timeout_exceeded?(time, val)
      # binding.pry if time == nil
      time * 1000 > val
    end
  end
end