require "obst/git_log"
require "time"

module Obst
  class GroupByTimeRange
    include Enumerable

    def initialize(dir, &block)
      @commits = GitLog.new(dir).commits
      @time_fix = block
    end

    def each(&block)
      current_time = nil
      renames = {}
      files_in_one_day = {}

      @commits.each do |commit|
        commited_at = @time_fix.call(commit.commited_at)
        current_time ||= commited_at

        if current_time != commited_at
          block.call([current_time, files_in_one_day.to_a])
          current_time = commited_at
          files_in_one_day.clear
        end

        commit.file_statuses.each do |file_status|
          renames[file_status.old_name] = file_status.name if file_status.old_name
          newest_name = renames[file_status.name] || file_status.name
          files_in_one_day[newest_name] = file_status.status
        end
      end

      block.call([current_time, files_in_one_day.to_a])
    end
  end

  class GroupByDay
    include Enumerable

    def initialize(dir)
      @days = Enumerator.new do |y|
        curr = Time.now
        one_day = 86400
        loop do
          y << curr.strftime('%F')
          curr -= one_day
        end
      end

      @log = GroupByTimeRange.new(dir) do |commited_at|
        Time.parse(commited_at).strftime('%F')
      end.to_enum
    end

    def each(&block)
      day_curr = @days.next
      log_curr, file_statuses = @log.next

      loop do
        break unless log_curr

        if log_curr == day_curr
          block.call([day_curr, file_statuses])
          log_curr, file_statuses = @log.next
        else
          block.call([day_curr, []])
        end

        day_curr = @days.next
      end
    end
  end
end
