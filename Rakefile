require 'config'
#TODO: Make the tld configurable (currently defaults to .local)

task :install do
  if `whoami`.strip != 'root'
    puts "\e[0;31mThis installer must be ran by root. We promise not to do anything nasty!\e[0m"
    exit!
  else
    config_yml = YAML::load_file("config.yml")
    config_yml["tld"] = tld = "local"
    # Mac OS X
    if RUBY_PLATFORM =~ /darwin/
      
      # Set the config directory so we can retreive it later on.
      config_yml["apache_config_directory"] = "/etc/apache2"
      
      # Start by writing out the Driver configuration
      driver_conf = "/etc/apache2/other/driver.conf"
      if !File.exist?(driver_conf)
        File.open(driver_conf, "w+") do |file|
          file.write(Driver.config)
        end
      end
      
      vhost_directory = "/etc/apache2/other/drivers"
      config_yml["vhost_directory"] = vhost_directory
      
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
    File.open("config.yml", "w+") do |config|
      config.write(config_yml.to_yaml)
    end
    
    # Ghost, do your thing!
    `ghost rm driver.local`
    `ghost add driver.local`
  
    # Apache, rollover!
    `apachectl -k restart`
    `open http://driver.local`
  end
end