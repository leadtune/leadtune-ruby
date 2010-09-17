require "singleton"

module Leadtune
  class Config 

    def initialize(config_file=nil)
      @config = {}
      load_config_file(config_file)
    end

    def [](key)
      @config[key]
    end


    private

    def load_config_file(config_file) #:nodoc:
      find_config_file(config_file) do |config_file|
        @config = YAML::load(config_file)
      end
    end

    def find_config_file(config_file) #:nodoc:
      case config_file
      when String
        yield File.open(config_file)
      when File, StringIO
        yield config_file
      when nil
        if File.exist?("leadtune.yml")
          yield File.open("leadtune.yml") 
        end
      end
    end

  end
end
