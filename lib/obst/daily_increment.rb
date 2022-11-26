require "obst/group_by_days"

module Obst
  class DailyIncrement
    include Enumerable

    def initialize(**opts)
      @group_by_day = GroupByDays.new(**opts)
    end

    def each(&block)
      return self unless block

      @group_by_day.each do |pack_log_record|
        block.call(pack_log_record.increment)
      end
    end
  end
end
