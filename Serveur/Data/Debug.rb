#======================================================================
# module RMXOS
#======================================================================

module RMXOS
	
	#==================================================================
	# module RMXOS::Debug
	#------------------------------------------------------------------
	# Contains debug constants.
	#==================================================================
	
	module Debug
		
		# Debug constants
		ClientConnect		= 'Client connecté.'
		ClientDisconnect	= 'Client déconnecté.'
		ClientFailed		= 'Problème du client détecté.'
		ClientLogout		= 'Client connecté avec force.'
		ConnectionReceived	= 'Nouvelle connexion reçue.'
		DbConnectionBusy	= 'Reconnexion à la base de données...'
		DbConnectionOk		= 'Reconnexion à la base de données réusis.'
		ExtensionFail		= 'Erreur extension détectée.'
		MaintenanceThread	= 'Maintenance Thread'
		MainThread			= 'Main Thread'
		PingFailed			= 'Ping sur le client a échoué.'
		ServerForceStopped	= 'Le serveur est arrêté.'
		ServerForceStopping	= 'Fermeture du serveur...'
		ServerStarted		= 'Démarrage du serveur.'
		ServerStarting		= 'Le serveur démarre...'
		ServerStopped		= 'Serveur arrêté.'
		ServerStopping		= 'Fermeture du serveur...'
		ThreadStart			= 'Thread démarrer.'
		ThreadStop			= 'Thread arrêté.'
		
		# special constants
		ClientLogin_CLIENTS_MAXIMUM			= 'Client connecté: CLIENTS / MAXIMUM'
		ClientDisconnect_CLIENTS_MAXIMUM	= 'Client déconnecté: CLIENTS / MAXIMUM'
		
	end

end
