#------------------------------------------------------------------------------
#                  RMX-OS Player Shops                                            
#                     by Wizered67                                                          
#                          V 0.89                                                               
# All errors should be reported at www.chaos-project.com.                   
#------------------------------------------------------------------------------
module RMXOS

#------------------------------------------------------------------
# Passes the extension's main module to RMX-OS on the top
# level so it can handle this extension.
# Returns: Module of this extension for update.
#------------------------------------------------------------------
def self.load_current_extension
return PlayerShops
end

end

#======================================================================
# module PlayerShops
#======================================================================

module PlayerShops

# extension version
VERSION = 1.0
# required RMX-OS version
RMXOS_VERSION = 2.0
# whether the server should update this extension in an idividual thread or not
SERVER_THREAD = true
# the extension's name/identifier
IDENTIFIER = 'Player Shops'

SHOPS_CREATED_FILENAME = './createdshops.dat'
SHOPS_DATA_FILENAME = './shopsdata.dat'
MONEY_OWED_FILENAME = './moneyowed.dat'
# :::: START Configuration
# - YOUR CONFIGURATION HERE
# :::: END Configuration

#------------------------------------------------------------------
# Initializes the extension (i.e. instantiation of classes).
#------------------------------------------------------------------
def self.initialize
# create mutex
@mutex = Mutex.new
@shops_created = {}
if FileTest.exist?(SHOPS_CREATED_FILENAME)
file = File.open(SHOPS_CREATED_FILENAME, 'r')
created = Marshal.load(file)
file.close
created.each_key {|map| @shops_created[map] = created[map]}
end
@max_shop_id = 1
if @shops_created != {}
for map in @shops_created.keys
for id in @shops_created[map]
@max_shop_id = id + 1 if id >= @max_shop_id
end
end
end
@shop_data = {}
if FileTest.exist?(SHOPS_DATA_FILENAME)
file = File.open(SHOPS_DATA_FILENAME, 'r')
data = Marshal.load(file)
file.close
for map in @shops_created.keys
for id in @shops_created[map]
@shop_data[id] = data[id]
end
end
end
@money_owed = {}
if FileTest.exist?(MONEY_OWED_FILENAME)
file = File.open(MONEY_OWED_FILENAME, 'r')
money = Marshal.load(file)
file.close
money.each_key {|p| @money_owed[p] = money[p]}
end
#puts @shop_data
end
#------------------------------------------------------------------
# Gets the local extension mutex.
#------------------------------------------------------------------
def self.mutex
return @mutex
end
#------------------------------------------------------------------
# Calls constant updating on the server.
#------------------------------------------------------------------
def self.main
# while server is running
while RMXOS.server.running
@mutex.synchronize {
self.server_update
}
sleep(0.1) # 0.1 seconds pause, decreases server load
end
end
#------------------------------------------------------------------
# Handles the server update.
#------------------------------------------------------------------
def self.server_update
user_ids = []
RMXOS.clients.get.each {|c| user_ids.push(c.player.user_id) if c.player.user_id > 0}
for shop in @shop_data.keys
if !user_ids.include?(@shop_data[shop][2])
@shop_data[shop][2] = 0 #if a player isn't online, change it so no one is using the shop they were previously using
end
end
end
#------------------------------------------------------------------
# Handles updating from a client.
# client - Client instance (from Client.rb)
# Returns: Whether to stop check the message or not.
#------------------------------------------------------------------
def self.client_update(client)
case client.message
when /\AENT\Z/ # enter server, send login money
user_id = client.player.user_id
if @money_owed.keys.include?(user_id) && @money_owed[user_id] != 0
client.send('RMPS', @money_owed[user_id])
@money_owed[user_id] = 0
self.save_money_owed
end


when /\ATSES\t(.+)/ #try editting a shop
shop_id = $1.to_i
if !@shop_data.keys.include?(shop_id)
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorError, 0, "There is no shop with that id."))
client.send('EIS')
return true
end
if client.player.user_id != @shop_data[shop_id][1]
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorError, 0, "You do not own that shop."))
client.send('EIS')
return true
end
if @shop_data[shop_id][2] != 0
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorError, 0, "Selected shop is already in use."))
return true
end
@shop_data[shop_id][2] = client.player.user_id
client.send('OESC', @shop_data[shop_id][0], @shop_data[shop_id][4])
return true

when /\ASMP\t(.+)\t(.+)/ #send money to da people (if not online, add to money owed hash)
user_id = $1.to_i
amount = $2.to_i
user_ids = []
return if user_id == client.player.user_id
RMXOS.clients.get.each {|c| user_ids.push(c.player.user_id) if c.player.user_id > 0}
if user_ids.include?(user_id)
client.sender.send_to_id(user_id, RMXOS.make_message('RMPS', amount))
else
if @money_owed.include?(user_id)
@money_owed[user_id] += amount
else
@money_owed[user_id] = amount
end
self.save_money_owed
#puts @money_owed
end
return true

when /\ACNPS\t(.+)\t(.+)\t(.+)\t(.+)/ #create new player shop
owner_name = $1
owner_id = $2.to_i
map_id = $3.to_i
shop_name = $4
@shops_created[map_id] = [] if @shops_created[map_id] == nil
@shops_created[map_id].push(@max_shop_id)
@shop_data[@max_shop_id] = [owner_name, owner_id, 0, {}, shop_name]
client.send('NSI', @max_shop_id)
puts "New shop created by " + client.player.username + " on map " + map_id.to_s + " with id " + @max_shop_id.to_s + " and name " + shop_name
@max_shop_id += 1
self.save_shop_data
self.save_shop_list

return true

when /\ARPS\t(.+)\t(.+)/ #remove player shop
shop_id = $1.to_i
map_id = $2.to_i
if !@shops_created.keys.include?(shop_id) || !@shop_data.keys.include?(shop_id)
return true
end
@shops_created[map_id].delete(shop_id)
@shop_data[shop_id] = nil
self.save_shop_data
self.save_shop_list
return true


when /\ASMSM\t(.+)/
#puts "Request to send shop list"
map_id = $1.to_i
message = []
puts @shop_data
if @shops_created[map_id] != nil
for sid in @shops_created[map_id]
message.push(" " + @shop_data[sid][0] + "'s " + @shop_data[sid][4] + " [" + sid.to_s + "]") if @shop_data[sid] != nil
end
end
if message == []
text = "No shops on this map."
else
text = "Shops on map: " + message.join(',')
end
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorOk, 0, text))
#puts text
return true


when /\ASMDS\t(.+)/ #send map data on shops
map_id = $1.to_i
if !@shops_created.keys.include?(map_id)
return true
end
client.send('LMDS', [@shops_created[map_id].inspect])
return true

when /\ASSD\t(.+)\t(.+)/ #send specific shop data
shop_id = $1.to_i
map_id = $2.to_i
if !@shop_data.keys.include?(shop_id)
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorError, 0, "Selected shop does not exist."))
client.send('EISB')
return true
end
if @shops_created[map_id] == nil || !@shops_created[map_id].include?(shop_id)
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorError, 0, "Selected shop is not on the same map."))
return true
end
#puts @shop_data[shop_id][2]
self.server_update
if @shop_data[shop_id][2] != 0
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorError, 0, "Selected shop is already in use."))
return true
end
@shop_data[shop_id][2] = client.player.user_id
client.send('LSSD', @shop_data[shop_id].inspect)
return true

when /\ASIU\t(.+)\t(.+)/ #change shop in use
shop_id = $1.to_i
user = $2.to_i
if !@shop_data.keys.include?(shop_id)
return true
end
@shop_data[shop_id][2] = user
return true

when /\ASSO\t(.+)\t(.+)\t(.+)/ #set shop owner
owner_name = $1
owner_id = $2.to_i
shop_id = $3.to_i
if !@shop_data.keys.include?(shop_id)
return true
end
data = @shop_data[shop_id]
data[0] = owner_name
data[1] = owner_id
return true


when /\ASCD\t(.+)\t(.+)\t(.+)\t(.+)\t(.+)/ #change shop data
shop_id = $1.to_i
item_id = $2
amount = $3.to_i
price = $4.to_i
type = $5.to_i
if !@shop_data.keys.include?(shop_id)
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorError, 0, "Selected shop does not exist."))
client.send('EIS')
return true
end
self.server_update
if @shop_data[shop_id][2] != 0 && @shop_data[shop_id][2] != client.player.user_id
client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorError, 0, "Selected shop is already in use. Please wait until the current user is done."))
return true
end
data = @shop_data[shop_id]
items = data[3]
access_id = item_id + "-" + type.to_s 
if items[access_id] == nil
items[access_id] = []
items[access_id][1] = amount
items[access_id][0] = price
items[access_id][2] = type
items[access_id][3] = item_id.to_i
else
items[access_id][1] += amount
items[access_id][0] = price
items[access_id][2] = type
items[access_id][3] = item_id.to_i
if items[access_id][1] <= 0
@shop_data[shop_id][3].delete(access_id)
end
end
#puts @shop_data
self.save_shop_data
if (amount > 0)
#client.send(RMXOS.make_message('CHT', RMXOS::Data::ColorOk, 0, "Item(s) placed for sale."))
end
#puts "Item " + item_id + "-" + type.to_s + " is in quantity " + item[1].to_s + " at price " + item[0].to_s + " in shop " + shop_id.to_s

return true
end
return false

end

def self.save_shop_data
file = File.open(SHOPS_DATA_FILENAME, 'w')
Marshal.dump(@shop_data, file)
file.close
end

def self.save_money_owed
file = File.open(MONEY_OWED_FILENAME, 'w')
Marshal.dump(@money_owed, file)
file.close
end

def self.save_shop_list
file = File.open(SHOPS_CREATED_FILENAME, 'w')
Marshal.dump(@shops_created, file)
file.close
end

end
