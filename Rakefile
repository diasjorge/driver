require 'config'
#TODO: Make the tld configurable (currently defaults to .local)

task :install do
  if `whoami`.strip != 'root'
    puts "\e[0;31mThis installer must be ran by root. We promise not to do anything!\e[0m"
    exit!
  else
    # Mac OS X
    if RUBY_PLATFORM =~ /darwin/
      
      # Start by writing out the Driver configuration
      driver_conf = "/etc/apache2/other/driver.conf"
      if !File.exist?(driver_conf)
        File.open(driver_conf, "w+") do |file|
          puts "Writing: #{Driver.config}"
          file.write(Driver.config)
        end
      end
      
      # Next, we add a vhost config for the app itself.
      FileUtils.mkdir_p("/etc/apache2/other/drivers")
        
      File.open("driver_vhost_config") do |file|
        contents = file.read
        contents = contents.gsub("REPLACE_ME", File.join(File.expand_path(File.dirname(__FILE__)), "public"))
        File.open("/etc/apache2/other/drivers/driver.conf", "w+") do |vhost|
          vhost.write(contents)
        end
      end
    end
    
    # Ghost, do your thing!
    `ghost rm driver.local`
    `ghost add driver.local`
  
    # Apache, rollover!
    `apachectl -k restart`
    `open http://driver.local`
  end
end