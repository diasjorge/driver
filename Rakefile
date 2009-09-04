require 'config'
#TODO: Make the tld configurable (currently defaults to .local)

desc "Installs Driver, must be ran as root."
task :install do
  check_who_am_i

  load_config

  # Ensure the other/drivers directory exists.
  `mkdir -p #{other_drivers}`
 
  # Ensure driver config exists
  if !File.exist?(driver_conf)
    File.open(driver_conf, "a+") do |file|
      file.write(Driver.config(config))
    end
  end
  
  # Include all the config files in the other directory.
  if File.read(config["apache_config_file"]).grep(Regexp.new("Include #{config["apache_config_directory"]}/other/\*\.")).empty?
    `echo "Include #{config["apache_config_directory"]}/other/*.conf" >> #{config["apache_config_file"]}`
  end
  
  vhost_directory = config["vhost_directory"] = File.join(config["apache_config_directory"] , "other/drivers")
  
  File.open("driver_vhost_config") do |file|
    contents = file.read
    contents = contents.gsub("REPLACE_ME", File.join(File.expand_path(File.dirname(__FILE__)), "public"))
    File.open(File.join(vhost_directory, "driver.#{tld}.conf"), "w+") do |vhost|
      vhost.write(contents)
    end
  end
  
  # Write out the config.
  File.open("config.yml", "w+") do |config_out|
    config_out.write(config.to_yaml)
  end
  
  # Ghost, do your thing!
  `ghost rm driver.local`
  `ghost add driver.local`
  
  # Apache, rollover!
  `#{config["apachectl"]} -k restart`
  
  `open http://driver.local`
end

task :uninstall do
  check_who_am_i

  load_config

  #Delete other/drivers directory
  FileUtils.rm_rf other_drivers

  #Delete driver conf
  driver_conf = File.join(config["apache_config_directory"], "other/driver.conf")
  FileUtils.rm driver_conf, :force => true

  config_file_escaped = config["apache_config_directory"].gsub("/","\\/")
  
  sed_cmd = %(sed -i 's/Include #{config_file_escaped}\\/other\\/\\*\\.conf//' #{config["apache_config_file"]})
  
  `#{sed_cmd}`

  `ghost rm driver.local`
end

def check_who_am_i
  if `whoami`.strip != 'root'
    puts "\e[0;31mThis installer must be ran by root. We promise not to do anything nasty!\e[0m"
    exit!
  end
end

# Path to where the driver config is going to be.
def driver_conf
  File.join(config["apache_config_directory"], "other/driver.conf")
end

def other_drivers
  "#{config["apache_config_directory"]}/other/drivers"
end

def config
  @config ||= YAML::load_file("config.yml")
end

def load_config
  config["tld"] = "local" # See TODO at top of file
  config["apachectl"] = if `which apachectl` != ""
                          "apachectl"
                        elsif `which apache2ctl`
                          "apache2ctl"
                        else
                          puts "Could not find apachectl! Please ensure this is in your path."
                          exit!
                        end

  # Set the config directory so we can retreive it later on.
  config["apache_config_file"] = /SERVER_CONFIG_FILE="(.*?)"/.match(`#{config["apachectl"]} -V`)[1]
  config["apache_config_directory"] = File.dirname(config["apache_config_file"])
end

def tld
  config["tld"]
end
