require "open3"
require "obst/daily_increment"

module Obst
  class DailyGauge
    include Enumerable

    def initialize(**opts)
      @path = opts[:C] || '.'
    end

    ONE_DAY = 60 * 60 * 24
    TimeCount = Struct.new(:time, :count)

    def each(&block)
      return self unless block

      time = Time.parse(Time.now.strftime('%F'))
      tot = total_now
      block.call(TimeCount.new(time, tot))

      DailyIncrement.new(C: @path).each do |incr|
        time -= ONE_DAY
        tot -= incr
        block.call(TimeCount.new(time, tot))
      end
    end

    def total_now
      total = 0
      Open3.pipeline_r(['git', '-C', @path, 'ls-files'], ['wc', '-l']){ |stdout| total = stdout.read.to_i }
      total
    end
  end
end
