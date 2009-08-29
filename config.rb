require 'fileutils'

class Driver
  def self.config
    File.read("driver_conf")
  end
  
end