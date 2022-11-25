require "obst/group_by_days"

module Obst
  class TouchedFiles
    def initialize(**opts)
      @path = opts[:C]
      @buffer = []
    end

    def to_s
      last_7_days
      @buffer << "\n"
      last_4_weeks_without_last_7_days
      @buffer << "\n"
      last_3_months_without_last_4_weeks
      @buffer.join("\n")
    end

    def last_7_days
      @buffer << "# Last 7 days\n"

      GroupByDays.new(C: @path).take(7).each do |record|
        @buffer << "- #{record.time} (#{record.statuses.size})"
        record.statuses.each_key do |name|
          @buffer << "\t- [[#{name}]]"
        end
      end
    end

    def last_4_weeks_without_last_7_days
      before = (Time.now - (60 * 60 * 24 * 6)).strftime('%FT00:00:00')

      @buffer << "# 3 weeks earlier\n"
      GroupByDays.new(C: @path, before: before, days: 7).take(3).each do |record|
        @buffer << "- #{record.time} (#{record.statuses.size})"
        record.statuses.each_key do |name|
          @buffer << "\t- [[#{name}]]"
        end
      end
    end

    def last_3_months_without_last_4_weeks
      before = (Time.now - (60 * 60 * 24 * 27)).strftime('%FT00:00:00')

      @buffer << "# 1 month earlier\n"
      GroupByDays.new(C: @path, before: before, days: 28).take(2).each do |record|
        @buffer << "- #{record.time} (#{record.statuses.size})"
        record.statuses.each_key do |name|
          @buffer << "\t- [[#{name}]]"
        end
      end
    end
  end
end
