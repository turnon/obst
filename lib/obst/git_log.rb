module Obst
  class GitLog
    def initialize(dir)
      @dir = dir
    end

    def to_s
      `git -C #{@dir} log --name-status --pretty=format:%ad --date='format:%Y-%m-%d %H:%M:%S'`
    end

    class Commit
      SPACE = "\s"

      attr_reader :file_statuses, :commited_date, :commited_at

      def initialize(lines)
        @commited_at = lines.shift
        @file_statuses = lines.map{ |l| FileStatus.new(l) }
      end

      # https://git-scm.com/docs/git-diff#Documentation/git-diff.txt---diff-filterACDMRTUXB82308203
      class FileStatus
        TAB = /\t/
        AMD = /^[AMD]/
        RENAME = /^R/


        attr_reader :status, :name, :old_name

        def initialize(line)
          if line =~ AMD
            @status, @name = line.split(TAB)
            @status = @status.downcase.to_sym
          elsif line =~ RENAME
            @score, @old_name, @name = line.split(TAB)
            @status = :r
          end
          @name.strip! if @name
        end
      end
    end

    EMPTY_LINE = "\n"

    def commits
      Enumerator.new do |y|
        batch = []
        to_s.each_line do |line|
          next batch << line unless line == EMPTY_LINE
          y << Commit.new(batch)
          batch.clear
        end
        y << Commit.new(batch)
      end
    end
  end
end
