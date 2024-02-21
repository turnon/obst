require "obst/group_by_days"

module Obst
  class Notes
    include Enumerable

    def initialize(**opts)
      location = opts[:C] || '.'

      @notes = Enumerator.new do |enum|
        note_klass = Struct.new(:name, :dates, :tags, :refs)
        files = Dir.glob(File.join(location, '*.md')).map{|n| File.basename(n)}.to_set
        file_dates = Hash.new{ |h, k| h[k] = [] }

        GroupByDays.new(**opts).each do |log|
          log.file_changes.each do |name, op|
            file_dates[name] << log.time if files.include?(name)
          end
        end

        file_dates.each_pair do |file, dates|
          lines = File.foreach(File.join(location, file))
          tags = lines.first&.scan(/#(\w+)/)&.flatten || []
          refs = lines.each_with_object([]) do |line, arr|
            line.scan(/\[\[(.+?)\]\]/).flatten.each do |n|
              arr << n if files.include?("#{n}.md")
            end
          end
          enum.yield(note_klass.new(file, dates, tags, refs))
        end
      end
    end

    def each(&block)
      @notes.each(&block)
    end
  end
end
