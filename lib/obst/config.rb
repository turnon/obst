require "json"

module Obst
  class Config
    def initialize(dir)
      @cfg = nil
      location = File.join(dir, '.obst.json')
      return @cfg = {} unless File.exist?(location)

      File.open(location) do |f|
        @cfg = JSON.parse(f.read)
      end
    end

    def dig(*path)
      @cfg.dig(*path)
    end

    def dig_any(*paths)
      paths.each do |path|
        v = dig(*path)
        return v if v
      end
      nil
    end
  end
end
