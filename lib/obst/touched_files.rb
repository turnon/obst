require "obst/group_by_days"

module Obst
  class TouchedFiles
    def initialize(**opts)
      @path = opts[:C]
      @buffer = []
    end

    def to_s
      last_7_days
      @buffer << ''
      last_4_weeks_without_last_7_days
      @buffer << ''
      last_3_months_without_last_4_weeks
      @buffer.join("\n")
    end

    def last_7_days
      @buffer << "# Last 7 days\n"

      GroupByDays.new(C: @path).take(7).each do |record|
        wday = Time.parse(record.time).strftime('%a')
        @buffer << "- #{record.time} #{wday} (#{record.file_changes.count})"
        list_files(record)
      end
    end

    def last_4_weeks_without_last_7_days
      before = (Time.now - (60 * 60 * 24 * 7)).strftime('%FT23:59:59')

      @buffer << "# 3 weeks earlier\n"

      GroupByDays.new(C: @path, before: before, days: 7).take(3).each do |record|
        @buffer << "- #{record.time} (#{record.file_changes.count})"
        list_files(record)
      end
    end

    def last_3_months_without_last_4_weeks
      before = (Time.now - (60 * 60 * 24 * 28)).strftime('%FT23:59:59')

      @buffer << "# 1 month earlier\n"

      GroupByDays.new(C: @path, before: before, days: 28).take(2).each do |record|
        @buffer << "- #{record.time} (#{record.file_changes.count})"
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
        @buffer << "\t- <font color='#{color}'>#{long} #{files.count}:</font> #{inline_str}"
      end
    end

    def inline(files)
      files.sort!.map{ |name| "[[#{name}]]" }.join(' / ')
    end
  end
end
