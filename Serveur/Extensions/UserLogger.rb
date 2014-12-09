module RMXOS
  
  def self.load_current_extension
    return UserLogger
  end
  
  module Data
    CurrentUsersOnline = 'Utilisateurs en ligne: NOW / ALL'
    ClientConnected = 'Client \'CLIENT\' est connecté.'
    ClientDisconnected = 'Client \'CLIENT\' est deconnecté.'
    OnlineListNotCreated = 'Attention: la liste a pas pu être créé cette fois!'
  end
  
end

#======================================================================
# module UserLogger
#======================================================================

module UserLogger

  VERSION = 1.2
  RMXOS_VERSION = 2.0
  SERVER_THREAD = true
  IDENTIFIER = 'User Logger'
  
  # START Configuration
  SERVER_DISPLAY = true # show log in command prompt screen
  LOG_FILENAME = 'logs/users.log' # leave empty if no log file should be created
  ONLINELIST_FILENAME = 'online.txt' # leave empty if no online user list should be generated
  DELETE_LOG_ON_START = false
  # END Configuration
  
  def self.initialize
    @mutex = Mutex.new
    @clients = []
    if LOG_FILENAME != ''
      File.delete(LOG_FILENAME) if DELETE_LOG_ON_START && FileTest.exist?(LOG_FILENAME)
    end
    RMXOS::Logs[IDENTIFIER] = LOG_FILENAME
  end
  
  def self.mutex
    return @mutex
  end
  
  def self.main
    while RMXOS.server.running
      @mutex.synchronize {
        self.server_update
      }
      sleep(0.1)
    end
  end
  
  def self.server_update
    logged_in_clients = RMXOS.clients.get
    new_clients = logged_in_clients - @clients
    old_clients = @clients - logged_in_clients
    if new_clients.size > 0 || old_clients.size > 0
      @clients = logged_in_clients
      time = Time.now.getutc.to_s
      displays = []
      new_clients.each {|client|
        displays.push(RMXOS::Data.args(RMXOS::Data::ClientConnected, {'CLIENT' => client.player.username}))
      }
      old_clients.each {|client|
        displays.push(RMXOS::Data.args(RMXOS::Data::ClientDisconnected, {'CLIENT' => client.player.username}))
      }
      displays.push(RMXOS::Data.args(RMXOS::Data::CurrentUsersOnline, {'NOW' => @clients.size.to_s, 'ALL' => MAXIMUM_CONNECTIONS.to_s}))
      displays = displays.join("\n") + "\n"
      self.log(displays)
    end
  end
  
  def self.log(message)
    puts (Time.now.getutc.to_s + ': ' + message) if SERVER_DISPLAY
    RMXOS.log('Log', IDENTIFIER, message)
    return if ONLINELIST_FILENAME == ''
    begin
      usernames = []
      @clients.each {|client| usernames.push(client.player.username)}
      usernames = usernames.join(',')
      file = File.open(ONLINELIST_FILENAME, 'w')
      file.write(usernames)
      file.close
    rescue
      puts RMXOS::Data::OnlineListNotCreated
    end
  end
  
  def self.client_update(client)
    return false
  end
  
end