require "obst/pack_log"
require "time"

module Obst
  class GroupByDays
    include Enumerable

    ONE_DAY = 60 * 60 * 24

    def initialize(**opts)
      duration = ONE_DAY * (opts[:days] || 1)
      latest = opts[:before] ? Time.parse(opts[:before]) : Time.parse(Time.now.strftime('%F 23:59:59'))

      @timeline = Enumerator.new do |y|
        curr = latest
        loop do
          y << curr.strftime('%F')
          curr -= duration
        end
      end

      @log = PackLog.new(**opts) do |committed_at|
        that_time = Time.parse(committed_at)
        n_durations = ((latest - that_time) / duration).to_i
        n_durations_before = latest - (n_durations * duration)
        n_durations_before.strftime('%F')
      end.to_enum
    end

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
end
