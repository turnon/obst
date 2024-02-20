require "open3"

module Obst
  class GitLog
    def initialize(**opts)
      path = opts[:C] || '.'
      @cmd = ['git', '-C', path, 'log', '--name-status', '--pretty=format:%ad', "--date=format:'%Y-%m-%dT%H:%M:%S'"]
      @cmd << '--after' << opts[:after] if opts[:after]
      @cmd << '--before' << opts[:before] if opts[:before]
      Array(opts[:pathspec]).each{ |s| @cmd << s }
    end

    def to_s
      `#{@cmd.join(' ')}`
    end

    class Commit
      SPACE = "\s"

      attr_reader :file_statuses, :committed_at

      def initialize(lines)
        @committed_at = lines.shift
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
        Open3.popen2(*@cmd) do |stdin, stdout, status_thread|
          stdout.each_line do |line|
            next batch << line unless line == EMPTY_LINE
            y << Commit.new(batch)
            batch.clear
          end
          raise 'fail to loop git log' unless status_thread.value.success?
        end
        y << Commit.new(batch)
      rescue => e
        puts @cmd
        raise e
      end
    end
  end
end
