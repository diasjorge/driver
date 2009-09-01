require 'sinatra'
require 'erb'
require 'config'

get '/' do
  get_hosts
  erb :index
end

get '/edit/:name' do
  load_config(params[:name])
  begin
    Driver.sudo("ls", "")
    @password_required = false
  rescue Driver::InvalidPassword
    @password_required = true
  ensure
    return(erb(:edit, :layout => false))
  end
end

post '/update' do
  begin
    load_config(params[:config])
    password = params.delete("password")
    merged_params = @config.merge!(params)
    `ghost rm #{params[:config]}`
    `ghost add #{merged_params["ServerName"]}`
    Driver.write_config(merged_params, password)
    return "Update successful!"
  rescue Driver::InvalidPassword => e
    e.message
    
  end
end

get '/new' do
  @config = {}
  begin
    Driver.sudo("ls", "")
    @password_required = false
  rescue Driver::InvalidPassword
    @password_required = true
  ensure
    return(erb(:new, :layout => false))
  end
end

post '/create' do
  password = params.delete("password")
  Driver.write_config(params, password)
  "Successfully created!"
end

post '/delete' do
  begin
    # begin sudo'ing
    Driver.sudo("ls", params[:password]) if params[:password]
    # Remove config
    if File.exist?(Driver.config_path(params[:name]))
      Driver.sudo("rm -f #{Driver.config_path(params[:name])}", params[:password])
    end
    # Remove ghost entry
    Driver.sudo("ghost rm #{params[:name]}")
    # Restart Apache
    Driver.restart_apache
    "The selected entry has been deleted."
  # For when sudo breaks.
  rescue Driver::InvalidPassword => e
    e.message
  end  
end

get '/restart' do
  erb :restart, :layout => false
end

post '/restart' do
  (Dir.entries(Driver.vhost_directory) - ['..', '.']).each do |host|
    Driver.sudo("ghost add #{host.gsub(".conf")}", params[:password])
  end
  Driver.restart_apache
end

get '/folders/*' do
  @path = "/" + params[:splat].first.gsub("//", "/")
  @folders = (Dir.entries(@path) - ["."]).select { |e| File.directory?(File.join(@path, e)) }
  erb :folders, :layout => false
end

get '/hosts' do
  get_hosts
  erb :hosts, :layout => false
end

private

  def get_hosts
    # Retreives a list of hosts from ghost, and their configurations.
     @hosts = {}
     counter = 1
     `ghost list`.split("\n")[1..-1].sort.each do |host|
       key, value = host.split(" -> ")
       key.strip!
       next if !File.exist?(Driver.config_path(key))
       @hosts[key] = {}
       @hosts[key][:host]   = key
       @hosts[key][:name]   = Driver.name_for(key)
       @hosts[key][:id]     = counter += 1 
       @hosts[key][:config] = Driver.config_for(@hosts[key][:host])
     end
   end

  def load_config(name)
    @config = Driver.parse_config(Driver.config_for(name))
  end
  
  def text_field(name)
    "<p>
  <label for='#{name}'>#{friendly_name(name)}</label>
  <input type='text' name='#{name}' id='#{name}' value='#{@config[name]}'><br>
  <span id='errors_for_#{name}' class='error_for_field'>asfd</span>
</p>"

  end
  
  def friendly_name(field)
    case field
      when "ServerName" then "Server Name:"
      when "DocumentRoot" then "Document Root:"
    end
  end