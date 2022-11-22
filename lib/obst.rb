require "obst/version"
require "obst/git_log"

module Obst
  class ByDay
    include Enumerable

    def initialize(dir)
      @commits = GitLog.new(dir).commits
    end

    def each(&block)
      current_date = nil
      renames = {}
      files_in_one_day = {}

      @commits.each do |commit|
        current_date ||= commit.commited_date

        if current_date != commit.commited_date
          block.call([current_date, files_in_one_day.to_a])
          current_date = commit.commited_date
          files_in_one_day.clear
        end

        commit.file_statuses.each do |file_status|
          renames[file_status.old_name] = file_status.name if file_status.old_name
          newest_name = renames[file_status.name] || file_status.name
          files_in_one_day[newest_name] = file_status.status
        end
      end

      block.call([current_date, files_in_one_day.to_a])
    end
  end
end
