#==========================================================================
# module RMXOS
#==========================================================================

module RMXOS
	
	#======================================================================
	# module RMXOS::Error
	#----------------------------------------------------------------------
	# Contains error messages.
	#======================================================================
	
	module Error
		
		# basic constants
		ActionNotExist		= 'Une erreur est survenue dans le traitement des données.'
		ConfigFile			= 'Erreur: Le fichier de configuration est invalide !'
		GameUndefined		= 'Erreur: \'NAME\' est non définie dans le fichier de configuration.'
		PasswordIncorrect	= 'Le mot de passe est incorrect.'
		PasswordSame		= 'Le nouveau mot de passe est indentique au précèdant'
		PMInboxEmpty		= 'Votre boîte de réception est vide.'
		PMInboxFull			= 'Votre boîte de réception est pleine MP.'
		PMNoUnread			= 'Il y a pas de MP non lus dans votre boîte de réception.'
		SaveFailed			= 'Erreur: les données du jeu ne peuvent pas être sauvés!'
		UnexpectedError		= 'Une erreur inattendue est survenue !'
		UnknownError		= 'Une erreur inconnue est survenue !'
		
		# constants with arguments
		ActionDenied_ACTION					= 'Vous êtes pas autorisé à utiliser \'ACTION\'.'
		ActionDenied_ACTION_ACTION_ENTITY	= 'Vous êtes pas autorisé à utiliser \'ACTION\' sur \'ENTITY\'.'
		ActionIdNotExist_ACTIONID			= 'Action avec ID ACTIONID inexistant'
		ClientCrash_ID_NAME_TIME			= 'Client ID (NAME) à TIME a provoqué une erreur:'
		ExtensionFileNotFound_FILE			= 'Erreur: \'FILE\' introuvable.'
		ExtensionInitError_FILE				= 'Erreur: \'FILE\' non initialisé.'
		ExtensionLoadError_FILE				= 'Erreur: \'FILE\' non chargé.'
		ExtensionRunError_FILE				= 'Erreur: \'FILE\' provoque une erreur.'
		ExtensionVersionError_FILE_VERSION	= 'Erreur: \'FILE\' nécessite au moins Pyrite Serveur Version VERSION.'
		GuildAlreadyExist_GUILD				= 'Guilde \'GUILD\' existe déjà.'
		GuildNotExist_GUILD					= 'Guilde \'GUILD\' inexistant.'
		MessageNotHandled_MESSAGE			= 'Attention: un message entrant non traité: MESSAGE'
		PlayerAlreadyGuild_PLAYER			= 'Joueur \'PLAYER\' est déjà membre dans une autre guilde.'
		PlayerNotExist_PLAYER				= 'Joueur \'PLAYER\' inexistant'
		PlayerNotOnline_PLAYER				= 'Joueur \'PLAYER\' est hors ligne.'
		PlayerNotOnMap_PLAYER				= 'Joueur \'PLAYER\' est pas sur la même map.'
		PMNotExist_MESSAGEID				= 'MP MESSAGEID inexistant.'
		PMInboxFull_PLAYER					= 'La boîte de réception du joueur \'PLAYER\' est pleine.'
		UnknownClientCrash_TIME				= 'Un client à TIME a provoqué une erreur:'
		WrongRubyVersion_VERSION			= 'LE Serveur ne supporte pas cette version de Ruby: VERSION'
		
	end
		
end
