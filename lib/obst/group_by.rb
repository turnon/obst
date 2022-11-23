require "obst/pack_log"
require "time"

module Obst
  module GroupBy
    class Day
      include Enumerable

      def initialize(**opts)
        @days = Enumerator.new do |y|
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

      def each(&block)
        day_curr = @days.next
        record = @log.next

        loop do
          break unless record

          if record.time == day_curr
            block.call(record)
            record = @log.next
          else
            block.call(PackLog::Record.new(day_curr, {}))
          end

          day_curr = @days.next
        end
      end
    end
  end
end
