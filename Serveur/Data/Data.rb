#==========================================================================
# module RMXOS
#==========================================================================

module RMXOS
	
	#======================================================================
	# module RMXOS::Data
	#----------------------------------------------------------------------
	# Contains constants.
	#======================================================================
	
	module Data
		
		Delimiter	= '--------------------------------------------------------------------------'
		GameVersion	= 'NAME vVERSION'
		Header		= '=========================================================================='
		PressEnter	= 'Appuyez sur ENTREE pour continuer.'
		Version		= 'Shark Engine Serveur vVERSION (using Ruby vRUBY_VERSION)'
		# basic constants
		AreYouSure			= 'Êtes-vous sûr ?'
		BuddyNoAdd			= 'Vous avez refusé une invitation de la liste de contacts.'
		CommandPrompt		= 'Ruby Prompt active.'
		CommandPromptSign	= '>> '
		CTRLC				= 'Appuyez sur CTRL + C pour arrêter Shark Engine Serveur.'
		DoYouAccept			= 'Acceptez-vous ?'
		ExtensionsLoading	= 'Chargement des extensions...'
		GuildNoJoin			= 'Vous ne avez pas accepté une invitation de la guilde.'
		GuildNoTransfer		= 'Vous ne avez pas accepté la demande de transfert de la direction de la guilde.'
		Host				= 'Hôte'
		InvalidSyntax		= 'Syntaxe Invalide !'
		Kickall				= 'Tous les joueurs ont été déconnectées.'
		MySQLOptimizing		= '> Optimisation des tables de base de données...'
		NewPMs				= 'Vous avez de nouveaux MP.'
		NoExtensions		= 'Aucune extensions trouvée.'
		NoPendingAction		= 'Il y a actuellement aucune action qui nécessite une réponse de votre part.'
		PasswordChanged		= 'Le mot de passe a été changé.'
		PasswordChanging	= 'Vous êtes sur le point de changer votre mot de passe.'
		PasswordNoChange	= 'Le mot de passe a pas été changé.'
		PendingActions		= 'Les actions suivantes sont actuellement actifs:'
		PMDeletedAll		= 'Vous avez supprimé tous les MP de votre boîte de réception.'
		PMDeletingAll		= 'Vous êtes sur le point de supprimer tous les MP de votre boîte de réception.'
		PMDeletingUnreadAll	= 'Vous êtes sur le point de supprimer tous les MP dans votre boîte de réception. Certains sont lus.'
		PMNoDeletion		= 'Aucun MP supprimés.'
		PMRequested			= 'Ces MP sont dans votre boîte de réception:'
		PMRequestedUnread	= 'Ces MP sont lus:'
		Restart				= 'Redémarre dans:'
		ScriptExecuted		= 'Script exécuté avec succès.'
		Server				= 'Serveur'
		ShuttingDown		= 'Shark Engine Serveur est en cours arrêt...'
		ShuttingDownForced	= 'Shark Engine Serveur force la fermeture...'
		Shutdown			= 'Shark Engine Serveur est arrêté.'
		ShutdownForced		= 'Shark Engine Serveur a été interrompue.'
		StartingServer		= 'Shark Engine Serveur est en cours de démarrage...'
		TradeCanceled		= 'Echange annulée.'
		TradeNoRequest		= 'Vous ne avez pas accepté la demande échange.'
		TradeSuccessful		= 'Echange réusis.'
		
		# constants with arguments
		ActionCanceled_ACTION			= 'Annulé: ACTION'
		ActionSuccess_ACTION			= 'La commande \'ACTION\' a été exécuté.'
		ActionSuccess_ACTION_ENTITY		= 'La commande \'ACTION\' a été exécuté sur \'ENTITY\'.'
		BuddyAdd_PLAYER					= '\'PLAYER\' veut vous ajouter à sa liste de contact'
		BuddyAdded_PLAYER				= 'Vous êtes amis avec \'PLAYER\''
		BuddyAdding_PLAYER				= 'Vous avez demandé à ajouter \'PLAYER\' à votre liste de contact.'
		BuddyRemoving_PLAYER			= 'Vous êtes sur le point de supprimer \'PLAYER\' de votre liste de contact.'
		BuddyNoAdd_PLAYER				= '\'PLAYER\' a pas accepté votre invitation de la liste de contacts.'
		BuddyNoRemove_PLAYER			= '\'PLAYER\' à pas été supprimé de votre liste de contacts.'
		BuddyRemove_PLAYER				= 'Le joueur \'PLAYER\' à été supprimé de votre liste de contact.'
		ExtensionLoaded_FILE_VERSION	= '\'FILE\' vVERSION chargé et initialisé.'
		GroupChanged_PLAYER				= 'Le groupe utilisateurs du joueur \'PLAYER\' a été modifié.'
		GuildCreated_GUILD				= 'La guilde \'GUILD\' a été créé.'
		GuildDisbanded_GUILD			= 'La guilde \'GUILD\' a été dissous.'
		GuildDisbanding_GUILD			= 'Vous êtes sur le point de se dissoudre la guilde \'GUILD\'.'
		GuildInvitation_GUILD			= 'Vous avez été invité à rejoindre la guilde \'GUILD\'.'
		GuildInvited_PLAYER				= 'Vous avez invité \'PLAYER\' à rejoindre votre guilde.'
		GuildJoined_GUILD				= 'Vous avez rejoint la guilde \'GUILD\'.'
		GuildJoined_PLAYER				= '\'PLAYER\' a rejoint la guilde.'
		GuildLeader_GUILD				= 'Vous êtes le nouveau chef de la guilde \'GUILD\'.'
		GuildLeader_PLAYER				= '\'PLAYER\' est le nouveau chef de guilde \'GUILD\'.'
		GuildLeaving_GUILD				= 'Vous êtes sur le point de quitter la guilde \'GUILD\'.'
		GuildNoDisband_GUILD			= 'La guilde \'GUILD\' a pas été dissoute.'
		GuildNoJoin_PLAYER				= '\'PLAYER\' na pas accepté votre invitation.'
		GuildNoLeave_GUILD				= 'Vous êtes toujours un membre de la guilde \'GUILD\'.'
		GuildNoRemove_PLAYER			= '\'PLAYER\' est toujours un membre de votre guilde.'
		GuildNoTransfer_PLAYER			= '\'PLAYER\' a pas accepté la demande de transfert de direction de la guilde.'
		GuildRemoving_PLAYER			= 'Vous êtes sur le point de supprimer \'PLAYER\' de votre guilde.'
		GuildRemoved_GUILD				= 'Vous êtes pas un membre de la guilde \'GUILD\'.'
		GuildRemoved_PLAYER				= 'Joueur \'PLAYER\' est pas un membre de la guilde \'GUILD\'.'
		GuildTransferring_GUILD_PLAYER	= 'Vous êtes sur le point de transférer la direction de votre guilde \'GUILD\' à \'PLAYER\'.'
		GuildTransfer_PLAYER			= 'Votre chef de guilde \'PLAYER\' veut vous transférer la direction.'
		PMInboxStatus_CURRENT_SIZE		= 'Statut de votre boîte de réception: NOW / MAX'
		MySQLConnecting_DATABASE		= '> Connexion à la base de données MySQL \'DATABASE\'...'
		PasswordForcing_ENTITY			= 'Vous êtes sur le point de changer le mot de passe de \'ENTITY\'.'
		PMDeleted_MESSAGEID				= 'Vous avez supprimé le MP MESSAGEID.'
		PMDeleting_MESSAGEID			= 'Vous êtes sur le point de supprimer le MP MESSAGEID.'
		PMDeletingUnread_MESSAGEID		= 'Vous êtes sur le point de supprimer le MP MESSAGEID.'
		PMSent_PLAYER					= 'MP envoyé au joueur \'PLAYER\'.'
		ServerStart_TIME				= 'Shark Engine Serveur a démarré correctement à TIME.'
		SocketStarting_IP_PORT			= '> Démarrage TCP Server sur \'IP:PORT\'...'
		TableOptimizing_TABLE			= '    > Optimisation table \'TABLE\'...'
		TradeNoRequest_PLAYER			= '\'PLAYER\' a pas accepté la demande'
		TradeRequested_PLAYER			= 'Vous avez demandé à échanger avec \'PLAYER\'.'
		TradeRequest_PLAYER				= '\'PLAYER\' a demandé à échanger avec vous.'
		
		# Other data constants
		ColorError	= "FFBF3F"
		ColorInfo	= "BFBFFF"
		ColorOk		= "1FFF1F"
		ColorNo		= "3F7FFF"
		ColorNormal	= "FFFFFF"
		
		#------------------------------------------------------------------
		# Evaluates named arguments in messages.
		#  string - string with embedded named arguments
		#  args - hash with named arguments
		# Returns: Processed string.
		#------------------------------------------------------------------
		def self.args(string, args)
			string = string.clone
			args.each {|key, value| string.sub!(key, value)} if args != nil
			return string
		end
		
	end
		
end
