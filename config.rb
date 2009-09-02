require 'fileutils'
require 'yaml'

class Driver
  class InvalidPassword < Exception
    def message
      "Error: You have specified an incorrect password. Please try again."
    end
  end
  
  class << self 
    def config(options)
      File.read("driver_conf").gsub("PATH", "#{options['apache_config_directory']}/other/drivers/*.conf")
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
    
    def vhost_config(config)
      vhost = File.read("vhost_conf")
      vhost.gsub!("CONFIG", "#{output_config(config)}")
      vhost.gsub!("DIRECTORY", config["ServerName"].gsub(/\/public\/?$/, ''))
    end
  
    # Ugliest method of this entire bastard application.
    # I apologise.  
    def write_config(config, password)
      # Since we can run both Rack apps and Rails apps (same thing?) through passenger, we can set both variables.
      config["RackEnv"] = config["RailsEnv"]
      output = vhost_config.split("\n")
      # Start the sudo
      sudo_output = sudo("ls", password)
      `sudo sh -c  \"echo "" > #{config_path(config["ServerName"])}\"`
      output.each do |line|
        command = "sudo sh -c \"echo '  #{replace_quotes(line)}' >> #{config_path(config["ServerName"])}\""
        `#{command}`
      end
      sudo("ghost rm #{config["ServerName"]}")
      sudo("ghost add #{config["ServerName"]}")
      restart_apache
    end
    
    def restart_apache
      # Fork this process, let it finish running and then in 3 seconds time kick apache in the balls.
      # Why 3? It came to me in a dream. It's also the longest I'm willing to wait.
      fork do
        sleep(3)
        sudo("apachectl -k restart")
      end
    end
    
    
    def sudo(command, password='')
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