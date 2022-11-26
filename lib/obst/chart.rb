module Obst
  class Chart
    class DailyCount
      def initialize(**opts)
        @daily_gauge = Obst::DailyGauge.new(C: opts[:C], days: 1).lazy
      end

      def to_s
        labels, data = [], []
        @daily_gauge.take(28 * 3).each do |time_count|
          labels << time_count.time.strftime('%F %a')
          data << time_count.count
        end

        <<~EOF
        # Daily count

        - current: #{data[0]}

        ```chart
        type: line
        width: 98%
        legend: false
        labels: #{labels.reverse!}
        series:
          - data: #{data.reverse!}
        ```
        EOF
      end
    end
  end
end
