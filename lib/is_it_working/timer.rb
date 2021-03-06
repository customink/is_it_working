module IsItWorking
  class Timer
    attr_reader :failure_threshold, :filter, :warning_threshold

    def initialize(warn_after: Float::INFINITY, fail_after: Float::INFINITY)
      @failure_threshold = fail_after
      @warning_threshold = warn_after
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
      time * 1000 > val
    end
  end
end
