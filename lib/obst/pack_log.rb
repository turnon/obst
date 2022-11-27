require "obst/git_log"

module Obst
  class PackLog
    include Enumerable

    def initialize(**opts, &block)
      @commits = GitLog.new(**opts).commits
      @time_fix = block
    end

    class Changes
      def <<(st)
        @arr ||= []
        @arr << st if @arr.last != st
      end

      def inspect
        @arr
      end

      def final
        if @arr[0] == :d
          return @arr[-1] == :a ? nil : :d
        end

        @arr[-1] == :a ? :a : :m
      end
    end

    Record = Struct.new(:time, :file_changes) do
      def date_wday
        Time.parse(time).strftime('%F %a')
      end

      def increment
        file_changes.each_value.reduce(0) do |sum, changes|
          sum +=
            case changes.final
            when :a
              1
            when :d
              -1
            else
              0
            end
        end
      end

      def group_by_final_status
        groups = Hash.new{ |h, k| h[k] = [] }
        file_changes.each_pair{ |file, changes| groups[changes.final] << file }
        groups
      end

      def group_inlines(&block)
        gbfs = group_by_final_status

        [
          [:new, :a, '#2db7b5'],
          [:mod, :m, '#d3be03'],
          [:del, :d, '#c71585'],
          [:nil, nil, 'grey']
        ].each do |long, short, color|
          files = gbfs[short]
          next if files.empty?
          inline_str = files.sort!.map{ |name| "[[#{name}]]" }.join(' / ')
          block.call("<font color='#{color}'>#{long} #{files.count}:</font> #{inline_str}")
        end
      end
    end

    # yield PackLog::Record(
    #   time:Any,
    #   file_changes:Hash{
    #     name1 => [:m, :a],
    #     name2 => [:d, :m],
    #     ...
    #   }
    # )
    def each(&block)
      return self unless block

      current_time = nil
      renames = {}
      files_in_one_day = Hash.new{ |files, name| files[name] = Changes.new }

      @commits.each do |commit|
        committed_at = @time_fix.call(commit.committed_at)
        current_time ||= committed_at

        if current_time != committed_at
          block.call(Record.new(current_time, files_in_one_day.dup))
          current_time = committed_at
          files_in_one_day.clear
        end

        commit.file_statuses.each do |file_status|
          renames[file_status.old_name] = file_status.name if file_status.old_name
          newest_name = renames[file_status.name] || file_status.name
          files_in_one_day[newest_name] << file_status.status
        end
      end

      block.call(Record.new(current_time, files_in_one_day.dup))
    end
  end
end
