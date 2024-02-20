require 'obst/notes'

module Obst
  class TagsCount
    def initialize(**opts)
      @notes = Notes.new(**opts)
    end

    def to_s
      buffer = ["# Tags\n"]
      @notes.map(&:tags).flatten.tally.sort{ |t1, t2| [t2[1], t2[0]] <=> [t1[1], t1[0]] }.each do |(tag, count)|
        buffer << "- #{tag}: #{count}"
      end
      buffer.join("\n")
    end
  end
end
