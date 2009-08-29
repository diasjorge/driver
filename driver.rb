require 'sinatra'
require 'erb'
require 'config'

get '/' do
  # Retreives a list of hosts from ghost, and their configurations.
  @hosts = {}
  counter = 1
  `ghost list`.split("\n")[1..-1].each do |host|
    key, value = host.split(" -> ")
    key.strip!
    @hosts[key] = {}
    @hosts[key][:host]   = key
    @hosts[key][:name]   = Driver.name_for(key)
    @hosts[key][:id]     = counter += 1 
    @hosts[key][:config] = Driver.config_for(@hosts[key][:name])
  end
  erb :index
end

get '/new' do
  erb :new, :layout => false
end

get '/edit/:name' do
  load_config(params[:name])
  erb :edit, :layout => false
end

post '/update' do
  load_config(params[:config])
  Driver.write_config(@config.merge!(params))
end

get '/folders/*' do
  @path = "/" + params[:splat].first
  @folders = (Dir.entries(@path) - ["."]).select { |e| File.directory?(File.join(@path, e)) }
  erb :folders, :layout => false
end

private

  def load_config(name)
    @config = Driver.parse_config(Driver.config_for(name))
  end
  
  def text_fields_for(*field)
    output = ""
    field.each do |field|
      value = @config.nil? ? "" : @config[field]
      output << "<p><label for='#{field}'>#{friendly_name(field)}:</label><input type='text' name='#{field}' id='#{field}' value='#{value}'></p>"
    end
    output
  end
  
  def friendly_name(field)
    case field
      when "ServerName" then "Name"
      when "DocumentRoot" then "Document Root"
    end
  end