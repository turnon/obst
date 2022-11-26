module Obst
  class Chart
    class DailyCount
      def initialize(**opts)
        @daily_gauge = Obst::DailyGauge.new(C: opts[:C]).lazy
      end

      def to_s
        labels, data = [], []
        @daily_gauge.take(28 * 3).each do |time_count|
          labels << time_count.time.strftime('%F %a')
          data << time_count.count
        end

        <<~EOF
        # Daily count

        ```chart
        type: line
        width: 98%
        legendPosition: bottom
        labels: #{labels.reverse!}
        series:
          - title: current #{data[0]}
            data: #{data.reverse!}
        ```
        EOF
      end
    end

    class DailyChange
      def initialize(**opts)
        @daily = Obst::GroupByDays.new(C: opts[:C]).lazy
      end

      def to_s
        labels = []
        datas = {a: [], m: [], d: [], nil => []}

        @daily.take(28 * 3).each do |record|
          labels << record.date_wday
          datas.each_value{ |data| data << 0 }

          record.file_changes.each_value do |changes|
            datas[changes.final][-1] += 1
          end
        end

        <<~EOF
        # Daily change

        ```chart
        type: line
        width: 98%
        legendPosition: bottom
        labels: #{labels.reverse!}
        series:
          - title: del
            data: #{datas[:d].reverse!}
          - title: nil
            data: #{datas[nil].reverse!}
          - title: mod
            data: #{datas[:m].reverse!}
          - title: new
            data: #{datas[:a].reverse!}
        ```
        EOF
      end
    end
  end
end
