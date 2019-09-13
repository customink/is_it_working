module IsItWorking
  # This class is used to pass the status of a monitoring check. Each status can have multiple
  # messages added to it by calling the +ok+ or +fail+ methods. The status check will only be
  # considered a success if all messages are ok.
  class Status
    # This class is used to contain individual status messages. Eache method can represent either
    # an +ok+ message or a +fail+ message.
    class Message
      RESULTS = [:ok, :warn, :fail].freeze
      attr_reader :message, :result

      def initialize(message, result)
        raise ArgumentError, "Result #{result} is not recognized!" unless RESULTS.include?(result)

        @message = message
        @result = result
      end

      def ok?
        RESULTS[0..1].include?(result)
      end

      def warn?
        result == :warn
      end
    end

    # The name of the status check for display purposes.
    attr_reader :name

    # The messages set on the status check.
    attr_reader :messages

    # The amount of time it takes to complete the status check.
    attr_accessor :time

    def initialize(name)
      @name = name
      @messages = []
    end

    # Add a message indicating that the check passed.
    def ok(message)
      @messages << Message.new(message, :ok)
    end

    # Add a message indicating that the check is tolerable but not ok.
    def warn(message)
      @messages << Message.new(message, :warn)
    end

    # Add a message indicating that the check failed.
    def fail(message)
      @messages << Message.new(message, :fail)
    end

    # Returns +true+ only if all checks were OK.
    def success?
      @messages.all?{|m| m.ok?}
    end

    # Returns +true+ if all checks were OK but warnings were present.
    def warnings?
      success? && @messages.any?{|m| m.warn?}
    end
  end
end
