module RMXOS
  
  def self.load_current_extension
    return BlizzABS
  end
  
  module Data
    GlobalMasterActivate_CLIENT_MAPID = 'Client \'CLIENT\' active G-Master sur la carte \'MAPID\'.'
    GlobalMasterDeactivate_CLIENT_MAPID = 'Client \'CLIENT\' desactive G-Master sur la carte \'MAPID\'.'
    GlobalMasterRelease_MAPID = 'Map \'MAPID\' a été diffusé.'
    PartyDisbanded = 'La groupe à bien été banni.'
    PartyInvitation_PLAYER = '\'PLAYER\' vous invite à rejoindre son groupe.'
    PartyInvited_PLAYER = 'Vous inviter \'PLAYER\' à joindre votre groupe.'
    PartyJoin_PLAYER = 'Vous rejoingnez le groupe de \'PLAYER\'.'
    PartyJoined_PLAYER = '\'PLAYER\' rejoint le groupe.'
    PartyNoJoin = 'Vous avez refuser de rejoindre le groupe.'
    PartyNoJoinPlayer_PLAYER = '\'PLAYER\' à refuser de rejoindre le groupe.'
    PartyRemoved = 'Vous quittez le groupe.'
    PartyRemoved_PLAYER = '\'PLAYER\' quitte le groupe.'
  end
  
  module Error
    PartyFull = 'Votre groupe est complet.'
    PartyAlready_PLAYER = '\'PLAYER\' est déjà dans un groupe.'
  end
  
end

#==========================================================================
# module BlizzABS
#==========================================================================

module BlizzABS
  
  VERSION = 3.02
  RMXOS_VERSION = 2.04
  SERVER_THREAD = true
  IDENTIFIER = 'Blizz-ABS'
  
  # START Configuration
  MAX_ONLINE_PARTY = 4
  GMASTER_TIMEOUT = 5 # after how much time an inactive time global master client should be released (you should set the PING_TIMEOUT value in RMX-OS to 1!)
  SERVER_DISPLAY = false # show log in command prompt screen
  LOG_FILENAME = 'logs/blizzabs.log' # leave empty if no log file should be created
  DELETE_LOG_ON_START = true
  # END Configuration
  
  def self.initialize
    @mutex = Mutex.new
    @client_times = {}
    @gmasters = {}
    @capable_clients = {}
    @battlers = {}
    @dead = {}
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
      sleep(0.01)
    end
  end
  
  def self.server_update
    time = Time.now
    logged_in_clients = RMXOS.clients.get
    old_clients = @client_times.keys - logged_in_clients
    old_clients.each {|client|
      @client_times.delete(client)
      @capable_clients.delete(@capable_clients.key(client))
      self.try_deactivate_gmaster(client)
      if client.player.partyleader != ''
        client.action.execute_party_remove(client.player.username, client.player.partyleader)
      end
    }
    new_clients = logged_in_clients - @client_times.keys
    new_clients.each {|client| @client_times[client] = time}
    @capable_clients.keys.each {|key|
      if time - @client_times[@capable_clients[key]] > GMASTER_TIMEOUT
        client = @capable_clients[key]
        @capable_clients.delete(key)
        self.try_deactivate_gmaster(client)
      end
    }
    (@capable_clients.values - logged_in_clients).each {|client| @capable_clients.delete(@capable_clients.key(client))}
    map_ids = []
    logged_in_clients.each {|client| map_ids.push(client.player.map_id)}
    map_ids |= map_ids # removes duplicates
    (@battlers.keys - map_ids).each {|map_id| @battlers.delete(map_id)}
    (@dead.keys - map_ids).each {|map_id| @dead.delete(map_id)}
    (@gmasters.keys - map_ids).each {|map_id| self.release_map(map_id)}
    (map_ids - @gmasters.keys).each {|map_id| self.try_activate_gmaster(map_id)}
  end
  
  def self.client_update(client)
    case client.message
    when /\AABSGMD\Z/ # deactivate capable global master client
      @capable_clients.delete(client.player.user_id) if @capable_clients.has_key?(client.player.user_id)
      self.try_deactivate_gmaster(client, client.player.map_id) if client == @gmasters[client.player.map_id]
      return true
    when /\APNG\Z/ # client ping
      if client.player.user_id != 0
        @client_times[client] = Time.now
        @capable_clients[client.player.user_id] = client
      end
      return false
    when /\AMEN\t(.+)/ # enter map
      map_id = $1.to_i
      if @battlers.has_key?(map_id)
        @battlers[map_id].each_key {|id|
          client.send('ABSMEE', id, @battlers[map_id][id].get_exchange_variables)
        }
      end
      if @dead.has_key?(map_id)
        @dead[map_id].each {|id| client.send('ABSMED', id)}
      end
      return false
    when /\AABSMEE\t(.+)\t(.+)/ # exchange variables for enemies
      if @gmasters[client.player.map_id] == client
        id = $1.to_i
        variables = eval($2)
        @battlers[client.player.map_id] = {} if !@battlers.has_key?(client.player.map_id)
        @battlers[client.player.map_id][id] = Player.new(nil) if !@battlers[client.player.map_id].has_key?(id)
        @battlers[client.player.map_id][id].evaluate(variables)
        client.sender.send_to_map(client.message)
      end
      return true
    when /\AABSBED\t(.+)\t(.+)/ # broadcast enemy death
      if @gmasters[client.player.map_id] == client
        id = $1.to_i
        client.sender.send_to_map(client.message, true)
        @dead[client.player.map_id] = [] if !@dead.has_key?(client.player.map_id)
        @dead[client.player.map_id].push(id) if !@dead[client.player.map_id].include?(id)
      end
      return true
    when /\AABSBER\t(.+)/ # broadcast enemy respawn
      if @gmasters[client.player.map_id] == client
        id = $1.to_i
        client.sender.send_to_map(client.message, true)
        @dead[client.player.map_id] = [] if !@dead.has_key?(client.player.map_id)
        @dead[client.player.map_id].delete(id) if @dead[client.player.map_id].include?(id)
      end
      return true
    when /\AABSADM\t(.+)\t(.+)/ # actor damage variables
      if @gmasters[client.player.map_id] == client
        client.sender.send_to_map(client.message)
      end
      return true
    when /\AABSEDM\t(.+)\t(.+)/ # enemy damage variables
      if @gmasters[client.player.map_id] == client
        client.sender.send_to_map(client.message)
      end
      return true
    when /\AABSACM\t(.+)/ # attack consume
      if @gmasters[client.player.map_id] == client
        user_id = $1.to_i
        client.sender.send_to_id(user_id, 'ABSACM')
      end
      return true
    when /\AABSSCM\t(.+)\t(.+)/ # skill consume
      if @gmasters[client.player.map_id] == client
        user_id = $1.to_i
        skill_id = $2.to_i
        client.sender.send_to_id(user_id, RMXOS.make_message('ABSSCM', skill_id))
      end
      return true
    when /\AABSICM\t(.+)\t(.+)/ # item consume
      if @gmasters[client.player.map_id] == client
        user_id = $1.to_i
        item_id = $2.to_i
        client.sender.send_to_id(user_id, RMXOS.make_message('ABSICM', item_id))
      end
      return true
    when /\AABSPIN\t(.+)/ # party invitation
      username = $1
      client._process_result(client.action.prepare_party_invite(username))
      return true
    when /\AABSPLE\Z/ # party leave
      client.action.execute_party_leave
      return true
    when /\AABSPRM\t(.+)/ # party remove
      username = $1
      client.action.execute_party_remove(username)
      return true
    when /\AABSPME\t(.+)/ # party message
      client.sender.send_to_party(RMXOS.make_message('CHT', $1), true)
      return true
    end
    return false
  end
  
  def self.try_activate_gmaster(map_id)
    return if @gmasters.has_key?(map_id)
    clients = @capable_clients.values.find_all {|client| client.player.map_id == map_id}
    return if clients.size == 0
    client = clients[0]
    client.send('ABSGMA')
    @gmasters[map_id] = client
    @dead[map_id] = [] if !@dead.has_key?(map_id)
    if !@battlers.has_key?(map_id)
      @battlers[map_id] = {}
      client.send('ABSMDR')
    end
    message = RMXOS::Data.args(RMXOS::Data::GlobalMasterActivate_CLIENT_MAPID, {'CLIENT' => client.player.username, 'MAPID' => map_id.to_s})
    self.log(message)
  end
  
  def self.try_deactivate_gmaster(client, map_id = nil)
    if map_id == nil
      @gmasters.each_key {|key|
        if client == @gmasters[key]
          map_id = key
          break
        end
      }
    end
    return if map_id == nil
    @gmasters.delete(map_id)
    client.send('ABSGMD')
    message = RMXOS::Data.args(RMXOS::Data::GlobalMasterDeactivate_CLIENT_MAPID, {'CLIENT' => client.player.username, 'MAPID' => map_id.to_s})
    self.log(message)
    self.try_activate_gmaster(map_id)
    self.release_map(map_id) if !@gmasters.has_key?(map_id)
  end
  
  def self.release_map(map_id)
    @gmasters.delete(map_id) if @gmasters.has_key?(map_id)
    message = RMXOS::Data.args(RMXOS::Data::GlobalMasterRelease_MAPID, {'MAPID' => map_id.to_s})
    self.log(message)
  end
  
  def self.log(message)
    puts message if SERVER_DISPLAY
    RMXOS.log('Log', IDENTIFIER, message)
  end
  
end

#==========================================================================
# Player
#==========================================================================

class Player

  IGNORE_VARIABLES.push('@battler|@damage')
  IGNORE_VARIABLES.push('@battler|@hpdamage')
  IGNORE_VARIABLES.push('@battler|@spdamage')
  IGNORE_VARIABLES.push('@ai|@act|@kind')
  IGNORE_VARIABLES.push('@ai|@act|@id')
  
  attr_accessor :party
  attr_accessor :partyleader
  
  alias initialize_blizzabsrmxos_later initialize
  def initialize(client)
    initialize_blizzabsrmxos_later(client)
    self.reset_party
  end
  
  def reset_party
    @partyleader = ''
    @party = []
  end
  
end

#==========================================================================
# Action
#==========================================================================

class Action
  
  TYPE_ABS_PARTY_JOIN = 1001
  
end
  
#==========================================================================
# Result
#==========================================================================

module RMXOS

  class Result
  
    ABS_PARTY_FULL = 1001
    ABS_PLAYER_ALREADY_IN_PARTY = 1002
    
    class << self
      alias error_blizzabsrmxos_later error
    end

    def self.error(code, message)
      result = Result.new(RMXOS::Data::ColorError)
      case code
      when RMXOS::Result::ABS_PARTY_FULL        then result.message = RMXOS::Error::PartyFull
      when RMXOS::Result::ABS_PLAYER_ALREADY_IN_PARTY  then result.message = RMXOS::Error::PartyAlready_PLAYER
      else
        return error_blizzabsrmxos_later(code, message)
      end
      return result
    end
  
  end
  
end
  
#==========================================================================
# ActionHandler
#==========================================================================

class ActionHandler
  
  def prepare_party_invite(username)
    @args = {'PLAYER' => username}
    return RMXOS::Result::ABS_PARTY_FULL if @client.player.party.size >= BlizzABS::MAX_ONLINE_PARTY - 1
    check = RMXOS.server.sql.query("SELECT COUNT(*) AS count FROM users WHERE username = '#{RMXOS.sql_string(username)}'")
    hash = check.fetch_hash
    return RMXOS::Result::PLAYER_NOT_EXIST if hash['count'].to_i == 0
    client = RMXOS.clients.get_by_name(username)
    return RMXOS::Result::PLAYER_NOT_ONLINE if client == nil
    return RMXOS::Result::PLAYER_NOT_ON_MAP if client.player.map_id != @client.player.map_id
    return RMXOS::Result::ABS_PLAYER_ALREADY_IN_PARTY if client.player.party.size > 0
    # prepare invitation
    sender_messages = Action::MessagePack.new(RMXOS::Data::PartyInvited_PLAYER,
      '', RMXOS::Data::GuildNoJoin_PLAYER, @args)
    receiver_messages = Action::MessagePack.new(self.make_accept_message(RMXOS::Data::PartyInvitation_PLAYER),
      RMXOS::Data::PartyJoined_PLAYER, RMXOS::Data::PartyNoJoin, {'PLAYER' => @client.player.username})
    self.create_interaction(Action::TYPE_ABS_PARTY_JOIN, sender_messages, [client], @client.player.user_id, receiver_messages)
    return RMXOS::Result::SUCCESS
  end
  
  def execute_party_join(action)
    user_id = action.data
    leader = RMXOS.clients.get_by_id(user_id)
    return RMXOS::Result::NO_ACTION if leader == nil
    leader.player.party |= [@client.player.username]
    @client.player.party = leader.player.party.clone
    @client.player.partyleader = leader.player.partyleader = leader.player.username
    @client.send('ABSPIN', leader.player.username, leader.player.party.inspect)
    message = RMXOS::Data.args(RMXOS::Data::PartyJoined_PLAYER, {'PLAYER' => @client.player.username})
    joinMessage = RMXOS.make_message('ABSPIN', leader.player.username, leader.player.party.inspect)
    message = RMXOS.make_message('CHT', RMXOS::Data::ColorOk, 0, message)
    RMXOS.clients.get_in_party(@client).each {|client|
      client.send(joinMessage)
      client.send(message)
      client.player.party = leader.player.party.clone
    }
    return RMXOS::Result::SUCCESS
  end
  
  def execute_party_leave
    if @client.player.partyleader == @client.player.username # leader left, disband party
      clients = RMXOS.clients.get_in_party(@client, true)
      clients.each {|client|
        client.send('ABSPRE')
        client.send_chat(RMXOS::Data::ColorInfo, RMXOS::Data::PartyDisbanded)
        client.player.reset_party
      }
      return
    end
    clients = RMXOS.clients.get_in_party(@client)
    @client.send('ABSPRE')
    @client.send_chat(RMXOS::Data::ColorInfo, RMXOS::Data::PartyRemoved)
    @client.player.reset_party
    leaveMessage = RMXOS.make_message('ABSPRM', @client.player.username)
    message = RMXOS::Data.args(RMXOS::Data::PartyRemoved_PLAYER, {'PLAYER' => @client.player.username})
    message = RMXOS.make_message('CHT', RMXOS::Data::ColorOk, 0, message)
    clients.each {|client|
      client.send(leaveMessage)
      client.send(message)
      client.player.party -= [@client]
    }
  end
  
  def execute_party_remove(username)
    client = RMXOS.clients.get_by_name(username)
    client.action.execute_party_leave if client != nil
  end
  
  alias execute_custom_yes_blizzabsrmxos_later execute_custom_yes
  def execute_custom_yes(action)
    return case action.type
    when Action::TYPE_ABS_PARTY_JOIN then self.execute_party_join(action)
    else
      execute_custom_yes_blizzabsrmxos_later(action)
    end
  end
  
  alias execute_custom_no_blizzabsrmxos_later execute_custom_no
  def execute_custom_no(action)
    return case action.type
    when Action::TYPE_ABS_PARTY_JOIN then RMXOS::Result::SUCCESS
    else
      execute_custom_no_blizzabsrmxos_later(action)
    end
  end
  
end

#==========================================================================
# ClientHandler
#==========================================================================

class ClientHandler
  
  def get_in_party(current, including = false)
    clients = RMXOS.clients.get.find_all {|client| client.player.partyleader == current.player.partyleader}
    clients.delete(current) if !including
    return clients
  end
  
end

#==========================================================================
# Sender
#==========================================================================

class Sender
  
  def send_to_party(message, including = false)
    self.send_to_clients(RMXOS.clients.get_in_party(@client, including), message)
  end
  
end