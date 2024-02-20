require "obst/group_by_days"

module Obst
  class TouchedFiles
    def initialize(**opts)
      @path = opts[:C]

      @pathspec =
        if cfg = opts[:cfg]
          opts[:pathspec] ||= cfg.dig_any(['pathspec'], ['touched_files', 'pathspec'])
        end

      @buffer = ["# Touch files in periods\n"]
    end

    def to_s
      last_7_days
      last_4_weeks_without_last_7_days
      last_3_months_without_last_4_weeks
      @buffer.join("\n")
    end

    def last_7_days
      @buffer << "- Last 7 days"

      GroupByDays.new(C: @path, pathspec: @pathspec).take(7).each do |record|
        @buffer << "\t- #{record.date_wday} (#{record.file_changes.count})"
        list_files(record)
      end
    end

    def last_4_weeks_without_last_7_days
      before = (Time.now - (60 * 60 * 24 * 7)).strftime('%FT23:59:59')

      @buffer << "- 1 week ago"

      GroupByDays.new(C: @path, before: before, days: 7, pathspec: @pathspec).take(3).each_with_index do |record, i|
        @buffer << "\t- #{record.time} is #{1+i}.week#{suffix_s(i)}.ago (#{record.file_changes.count})"
        list_files(record)
      end
    end

    def last_3_months_without_last_4_weeks
      before = (Time.now - (60 * 60 * 24 * 28)).strftime('%FT23:59:59')

      @buffer << "- 1 month ago"

      GroupByDays.new(C: @path, before: before, days: 28, pathspec: @pathspec).take(2).each_with_index do |record, i|
        @buffer << "\t- #{record.time} is #{1+i}.month#{suffix_s(i)}.ago (#{record.file_changes.count})"
        list_files(record)
      end
    end

    def list_files(record)
      record.group_inlines do |line|
        @buffer << "\t\t- #{line}"
      end
    end

    def suffix_s(i)
      i == 0 ? '' : 's'
    end
  end
end
