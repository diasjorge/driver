require 'config'
#TODO: Make the tld configurable (currently defaults to .local)

task :install do
  if `whoami`.strip != 'root'
    puts "\e[0;31mThis installer must be ran by root. We promise not to do anything nasty!\e[0m"
    exit!
  else
    config = YAML::load_file("config.yml")
    config["tld"] = tld = "local" # See TODO at top of file
    config["apachectl"] = if `which apachectl` != ""
      "apachectl"
    elsif `which apache2ctl`
      "apache2ctl"
    else
      puts "Could not find apachectl! Please ensure this is in your path."
      exit!
    end
    # Set the config directory so we can retreive it later on.
    config["apache_config_directory"] = File.dirname(/SERVER_CONFIG_FILE="(.*?)"/.match(`#{config["apachectl"]} -V`)[1])
    # Mac OS X
    if RUBY_PLATFORM =~ /darwin/
      # Start by writing out the Driver configuration
      driver_conf = File.join(config["apache_config_directory"], "other/driver.conf")
      if !File.exist?(driver_conf)
        File.open(driver_conf, "w+") do |file|
          file.write(Driver.config)
        end
      end
      
      vhost_directory = File.join(config["apache_config_directory"] , "other/drivers")
      config["vhost_directory"] = vhost_directory
      
      # Next, we add a vhost config for the app itself.
      FileUtils.mkdir_p(vhost_directory)
        
      File.open("driver_vhost_config") do |file|
        contents = file.read
        contents = contents.gsub("REPLACE_ME", File.join(File.expand_path(File.dirname(__FILE__)), "public"))
        File.open(File.join(vhost_directory, "driver.#{tld}.conf"), "w+") do |vhost|
          vhost.write(contents)
        end
      end
    else
      # Oh, this is going to be such a large can of worms.
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
end