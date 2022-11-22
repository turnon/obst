require "obst/version"

module Obst
  class Log
    def initialize(dir)
      @dir = dir
    end

    def to_s
      `git -C #{@dir} log --name-status --pretty=format:%ad --date='format:%Y-%m-%d %H:%M:%S' ':*.md'`
    end

    class Commit
      def initialize(lines)
        @commited_at = lines.shift.strip
        @files = lines.map{ |l| FileStatus.new(l) }
      end

      # https://git-scm.com/docs/git-diff#Documentation/git-diff.txt---diff-filterACDMRTUXB82308203
      class FileStatus
        def initialize(line)
          @line = line
        end
      end
    end

    def commits
      Enumerator.new do |y|
        batch = []
        to_s.each_line do |line|
          next batch << line unless line == "\n"
          y << Commit.new(batch)
          batch.clear
        end
        y << Commit.new(batch)
      end
    end
  end
end
