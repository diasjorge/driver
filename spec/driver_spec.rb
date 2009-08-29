require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Driver
  class << self 
    def vhost_directory
      File.join(current_path, "fixtures", "vhosts")
    end
    
    def apache_config_directory
      File.join(current_path, "fixtures", "config")
    end
  end
end

describe Driver do
  before do
    @config = File.read(File.join(current_path, "fixtures", "example_vhost"))
  end
  
  it "should correctly parse the config" do
    config = Driver.parse_config(@config)
    config["RailsEnv"].should eql("production")
    config["ServerName"].should eql("driver.local")
    config["DocumentRoot"].should eql("/Users/ryanbigg/Sites/driver")
  end
  
  it "should correctly write the config" do
    path = File.join(Driver.vhost_directory, "otherdriver.local.conf")
    FileUtils.rm(path) rescue nil
    config = { "ServerName" => "otherdriver.local", "DocumentRoot" => "/Users/ryanbigg/Sites/driver", "config" => "driver.local" }
    Driver.write_config(config)
    new_config = File.read(path)
    new_config.should eql("<VirtualHost *:80>\nServerName otherdriver.local\nDocumentRoot /Users/ryanbigg/Sites/driver\n\n</VirtualHost>")
  end
end