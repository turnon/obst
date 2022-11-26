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
        @buffer << "- #{record.time} #{wday} (#{record.statuses.size})"
        list_files(record)
      end
    end

    def last_4_weeks_without_last_7_days
      before = (Time.now - (60 * 60 * 24 * 7)).strftime('%FT23:59:59')

      @buffer << "# 3 weeks earlier\n"

      GroupByDays.new(C: @path, before: before, days: 7).take(3).each do |record|
        @buffer << "- #{record.time} (#{record.statuses.size})"
        list_files(record)
      end
    end

    def last_3_months_without_last_4_weeks
      before = (Time.now - (60 * 60 * 24 * 28)).strftime('%FT23:59:59')

      @buffer << "# 1 month earlier\n"

      GroupByDays.new(C: @path, before: before, days: 28).take(2).each do |record|
        @buffer << "- #{record.time} (#{record.statuses.size})"
        list_files(record)
      end
    end

    def list_files(record)
      new_files, mod_files = [], []
      record.statuses.each_pair do |name, status|
        (status.final == :a ? new_files : mod_files) << name
      end

      new_inlined = inline_files(new_files)
      @buffer << "\t- new: #{new_inlined}" unless new_inlined.empty?

      mod_inlined = inline_files(mod_files)
      @buffer << "\t- mod: #{mod_inlined}" unless mod_inlined.empty?
    end

    def inline_files(files)
      files.sort!.map{ |name| "[[#{name}]]" }.join(' / ')
    end
  end
end
