require "obst/last_seen"

module Obst
  class LongTimeNoSee
    def initialize(**opts)
      opts = opts.merge(days: 7)
      @weekly = LastSeen.new(**opts)
    end

    def to_s
      @buffer = ["# Long time no see\n"]
      @weekly.each_with_index do |record, i|
        @buffer << "- #{record.time} #{week_count(i)} (#{record.file_changes.count})"
        list_files(record)
      end
      @buffer.join("\n")
    end

    def list_files(record)
      record.group_inlines do |line|
        @buffer << "\t- #{line}"
      end
    end

    def week_count(i)
      return 'today' if i == 0
      return '1.week.ago' if i == 1
      "#{i}.weeks.ago"
    end
  end
end
