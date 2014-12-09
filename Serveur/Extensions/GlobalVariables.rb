module RMXOS
  
  def self.load_current_extension
    return GlobalSwitchesVariables
  end
  
  module Data
    GlobalSwitchChange = 'Client \'CLIENT\' change interrupteur \'ID\' à \'STATE\'.'
    GlobalVariableChange = 'Client \'CLIENT\' change variable \'ID\' à \'STATE\'.'
  end
  
end

#======================================================================
# module GlobalSwitchesVariables
#======================================================================

module GlobalSwitchesVariables
  
  VERSION = 1.3
  RMXOS_VERSION = 2.0
  SERVER_THREAD = false
  IDENTIFIER = 'Global Switches and Variables'
  
  # START Configuration
  GLOBAL_SWITCHES = [1, 2] # make sure this matches the configuration in the client
  GLOBAL_VARIABLES = [1, 2] # make sure this matches the configuration in the client
  SWITCHES_FILENAME = './gswitches.dat' # filename for global switch saving
  VARIABLES_FILENAME = './gvariables.dat' # filename for global variable saving
  SERVER_DISPLAY = true # show log in command prompt screen
  LOG_FILENAME = './logs/gswivar.log' # leave empty if no log file should be created
  DELETE_LOG_ON_START = false
  # END Configuration
  
  def self.initialize
    @mutex = Mutex.new
    @switches = {}
    GLOBAL_SWITCHES.each {|id| @switches[id] = false}
    if FileTest.exist?(SWITCHES_FILENAME)
      file = File.open(SWITCHES_FILENAME, 'r')
      ids = Marshal.load(file)
      file.close
      (ids & GLOBAL_SWITCHES).each {|id| @switches[id] = true}
    end
    @variables = {}
    GLOBAL_VARIABLES.each {|id| @variables[id] = 0}
    if FileTest.exist?(VARIABLES_FILENAME)
      file = File.open(VARIABLES_FILENAME, 'r')
      hash = Marshal.load(file)
      file.close
      (hash.keys & GLOBAL_VARIABLES).each {|id| @variables[id] = hash[id]}
    end
    if LOG_FILENAME != ''
      File.delete(LOG_FILENAME) if DELETE_LOG_ON_START && FileTest.exist?(LOG_FILENAME)
      RMXOS::Logs[IDENTIFIER] = LOG_FILENAME
    end
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
  end
  
  def self.client_update(client)
    case client.message
    when /\ALGDAT\Z/ # load global data
      client.send('LGSWI', @switches.inspect.sub(' ', ''))
      client.send('LGVAR', @variables.inspect.sub(' ', ''))
      return true
    when /\AGSWI\t(.+)\t(.+)/ # global switch change
      id = $1.to_i
      value = ($2 != '0')
      @switches[id] = value
      self.save_switches
      client.sender.send_to_all(client.message, true)
      message = RMXOS::Data.args(RMXOS::Data::GlobalSwitchChange, {'CLIENT' => client.player.username, 'ID' => id.to_s, 'STATE' => value.to_s})
      self.log(message)
      return true
    when /\AGVAR\t(.+)\t(.+)/ # global variable change
      id = $1.to_i
      value = $2.to_i
      @variables[id] = value
      self.save_variables
      client.sender.send_to_all(client.message, true)
      message = RMXOS::Data.args(RMXOS::Data::GlobalVariableChange, {'CLIENT' => client.player.username, 'ID' => id.to_s, 'STATE' => value.to_s})
      self.log(message)
      return true
    end
    return false
  end
  
  def self.save_switches
    ids = @switches.keys.find_all {|id| @switches[id]}
    file = File.open(SWITCHES_FILENAME, 'w')
    Marshal.dump(ids, file)
    file.close
  end
  
  def self.save_variables
    hash = {}
    @variables.each_key {|id| hash[id] = @variables[id] if @variables[id] != 0}
    file = File.open(VARIABLES_FILENAME, 'w')
    Marshal.dump(hash, file)
    file.close
  end
  
  def self.log(message)
    puts message if SERVER_DISPLAY
    RMXOS.log('Log', IDENTIFIER, message)
  end
  
end