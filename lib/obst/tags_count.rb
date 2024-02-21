require 'obst/notes'

module Obst
  class TagsCount
    def initialize(**opts)
      @notes = Notes.new(**opts)
    end

    def to_s
      buffer = ["# Tags\n"]

      @notes.map(&:tags).flatten.tally.sort do |t1, t2|
        if (compare_count = (t2[1] <=> t1[1])) == 0
          t1[0] <=> t2[0]
        else
          compare_count
        end
      end.each_with_index do |(tag, count), idx|
        buffer << "#{idx + 1}. #{tag}: #{count}"
      end

      buffer.join("\n")
    end
  end
end
