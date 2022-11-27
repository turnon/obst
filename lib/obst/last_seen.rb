require "set"
require "obst/group_by_days"

module Obst
  class LastSeen
    include Enumerable

    def initialize(**opts)
      @groups = Obst::GroupByDays.new(**opts)
    end

    def each(&block)
      return self unless block

      seen = Set.new
      @groups.each do |record|
        record.file_changes.keys.each do |file|
          if seen.include?(file)
            record.file_changes.delete(file)
          else
            seen << file
          end
        end
        block.call(record)
      end
    end
  end
end
