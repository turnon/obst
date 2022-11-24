require "obst/pack_log"
require "time"

module Obst
  module GroupBy
    module Enum
      include Enumerable

      def each(&block)
        current_time = @timeline.next
        record = @log.next

        loop do
          break unless record

          if record.time == current_time
            block.call(record)
            record = @log.next
          else
            block.call(PackLog::Record.new(current_time, {}))
          end

          current_time = @timeline.next
        end
      end
    end

    class Day
      include Enum

      def initialize(**opts)
        @timeline = Enumerator.new do |y|
          curr = Time.now
          one_day = 86400
          loop do
            y << curr.strftime('%F')
            curr -= one_day
          end
        end

        @log = PackLog.new(**opts) do |committed_at|
          Time.parse(committed_at).strftime('%F')
        end.to_enum
      end
    end
  end
end
