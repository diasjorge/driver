require 'fileutils'
require 'yaml'

class Driver
  class InvalidPassword < Exception; end;
  
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
      config.strip.split("\n")[2..-2].map! { |l| l.strip.split(" ") }.each do |key, value|
        real_config[key] = value
      end
      real_config
    end
  
    # Ugliest method of this entire bastard application.
    # I apologise.  
    def write_config(config, password)
      output = "NameVirtualHost *:80\n<VirtualHost *:80>\n#{output_config(config)}\n</VirtualHost>".split("\n")
      # Start the sudo
      sudo_output = sudo("ls", password)
      puts sudo_output
      `sudo sh -c  \"echo "" > #{config_path(config["ServerName"])}\"`
      output.each do |line|
        command = "sudo sh -c \"echo '#{replace_quotes(line)}' >> #{config_path(config["ServerName"])}\""
        `#{command}`
      end
      fork do
        sleep(3)
        sudo("ghost rm #{config["ServerName"]}", password)
        sudo("ghost add #{config["ServerName"]}", password)
        restart_apache(password)
      end
    end
    
    def delete(config)
      sudo("ls", password)
    end
    
    def restart_apache(password)
      sudo("apachectl -k restart", password)
    end
    
    
    def sudo(command, password)
      output = `(echo \"#{password}\" | sudo -S #{command}) 2>&1` 
      raise Driver::InvalidPassword if output.include?("incorrect password attempts")
    end
    
    def replace_quotes(line)
      line.gsub("\"", "\\\"")
    end
    
    def output_config(config)
      config.delete("password")
      config.delete("config")
      config.delete("selected")
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