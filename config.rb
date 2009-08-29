require 'fileutils'
require 'yaml'

class Driver
  class << self 
    def config
      File.read("driver_conf")
    end
    
    def config_path(name)
      File.join(Driver.vhost_directory, "#{name}.conf")
    end
  
    def config_for(name)
      File.read(config_path(name))
    end
    
    def parse_config(config)
      real_config = {}
      config.split("\n")[1..-2].map! { |l| l.strip.split(" ") }.each do |key, value|
        real_config[key] = value
      end
      real_config
    end
    
    def write_config(config)
      FileUtils.rm(config_path(config["config"])) rescue nil
      File.open(config_path(config["ServerName"]), "w+") do |f|
        f.write("<VirtualHost *:80>\n#{output_config(config)}\n</VirtualHost>")
      end
    end
    
    def output_config(config)
      config.delete("config")
      output = ""
      config.each do |key, value|
        output << "#{key} #{value}\n"
      end
      output
    end
    
    def name_for(host)
      host.split(".")[0]
    end
  
    def apache_config_directory
      YAML::load_file("config.yml")["apache_config_directory"]
    end
  
    def vhost_directory
      YAML::load_file("config.yml")["vhost_directory"]
    end
  end
  
end