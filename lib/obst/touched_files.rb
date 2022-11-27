require "obst/group_by_days"

module Obst
  class TouchedFiles
    def initialize(**opts)
      @path = opts[:C]
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

      GroupByDays.new(C: @path).take(7).each do |record|
        @buffer << "\t- #{record.date_wday} (#{record.file_changes.count})"
        list_files(record)
      end
    end

    def last_4_weeks_without_last_7_days
      before = (Time.now - (60 * 60 * 24 * 7)).strftime('%FT23:59:59')

      @buffer << "- 1 week ago"

      GroupByDays.new(C: @path, before: before, days: 7).take(3).each_with_index do |record, i|
        @buffer << "\t- #{record.time} is #{1+i}.week#{suffix_s(i)}.ago (#{record.file_changes.count})"
        list_files(record)
      end
    end

    def last_3_months_without_last_4_weeks
      before = (Time.now - (60 * 60 * 24 * 28)).strftime('%FT23:59:59')

      @buffer << "- 1 month ago"

      GroupByDays.new(C: @path, before: before, days: 28).take(2).each_with_index do |record, i|
        @buffer << "\t- #{record.time} is #{1+i}.month#{suffix_s(i)}.ago (#{record.file_changes.count})"
        list_files(record)
      end
    end

    def list_files(record)
      group_by_final_status = Hash.new{ |h, k| h[k] = [] }
      record.file_changes.each_pair{ |file, status| group_by_final_status[status.final] << file }

      [
        [:new, :a, '#2db7b5'],
        [:mod, :m, '#d3be03'],
        [:del, :d, '#c71585'],
        [:nil, nil, 'grey']
      ].each do |long, short, color|
        files = group_by_final_status[short]
        next if files.empty?
        inline_str = inline(files)
        @buffer << "\t\t- <font color='#{color}'>#{long} #{files.count}:</font> #{inline_str}"
      end
    end

    def inline(files)
      files.sort!.map{ |name| "[[#{name}]]" }.join(' / ')
    end

    def suffix_s(i)
      i == 0 ? '' : 's'
    end
  end
end
