require "obst/git_log"

module Obst
  class PackLog
    include Enumerable

    def initialize(**opts, &block)
      @commits = GitLog.new(**opts).commits
      @time_fix = block
    end

    class Statuses
      def <<(st)
        @arr ||= []
        @arr << st if @arr.last != st
      end

      def inspect
        @arr
      end
    end

    Record = Struct.new(:time, :statuses)

    def each(&block)
      current_time = nil
      renames = {}
      files_in_one_day = Hash.new{ |files, name| files[name] = Statuses.new }

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
