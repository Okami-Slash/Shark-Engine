<?php include("header.php"); ?>

<div class="art-contentLayout">

<?php include("sidebar-left.php"); ?>

<div class="art-content">
<div class="art-Post">
<div class="art-Post-tl"></div>
<div class="art-Post-tr"></div>
<div class="art-Post-bl"></div>
<div class="art-Post-br"></div>
<div class="art-Post-tc"></div>
<div class="art-Post-bc"></div>

<div class="art-Post-cl"></div>
<div class="art-Post-cr"></div>
<div class="art-Post-cc"></div>
<div class="art-Post-body">
<div class="art-Post-inner">
<div class="art-PostMetadataHeader">
<h2 class="art-PostHeader">Inscription</h2>
</div>

<div class="art-PostContent"><br/><div class="art-PostContent">

     <?php
	if (isset($_POST['passe'])) //On vérifie si la variable 'passe' éxiste
	 {
	 $password=$_POST['passe']; //La varraible '$password' prendra la valeur de 'passe'
	 $password_verification=$_POST['passe_verification']; //La varraible '$password_verification' prendra la valeur de 'passe_verification'
	 $Pseudo=$_POST['pseudo']; //La varraible '$Pseudo' prendra la valeur de 'pseudo'
	 
	 if ($password == $password_verification) //Si le mot de passe correspond au mot de passe de vérification
	 {
     $salt="XS"; //On choisi la méthode de cryptage
     $encryptedPassword=crypt($password,$salt); //On crypte la variable '$password'
     $Crypt_Password = $encryptedPassword; //La variable 'Crypt_Password' aura la valeur de '$encryptedPassword'
     $Crypt_Password = strrev(substr($Crypt_Password,strpos($Crypt_Password,"SX")+2)); //On positionne le curseur pour une suppression de caractère
     $Crypt_Password = strrev($Crypt_Password);//On supprime les deux premier caractère
	 try
	 {
	 $pdo_options[PDO::ATTR_ERRMODE] = PDO::ERRMODE_EXCEPTION; //On ajoute une exception à la connexion en cas d'erreur
	 include("config.php"); //On inclue la page 'config.php', ou seront stocké toutes les varaibles de configuration
	 $mysql = new PDO("mysql:host=$DB_HostName;dbname=$Name_DB", $DB_User, $DB_Password); // On se connecte à la base de donnée grâce au variables de configuration
	 $check = $mysql->prepare('SELECT username FROM users WHERE username = ?'); //On effectue une requête pour vérifier si l'utilisateur choisi n'éxiste pas de la base de donnée
	 $check->execute(array($Pseudo)); //On éxécute la requête SQL
     $donnees = $check->fetch(); //On récupère le contenue de la requête SQL
	 $check->closeCursor(); //On ferme le curseur pour éviter toute erreur
	 
     if ($donnees['username'] != $Pseudo)
	 {
	 $ID =''; //On attribue la valeur pour la variable '$ID'
	 $Groupe= 0; //On attribue la valeur pour la variable '$Groupe'
	 $Banned= 0; //On attribue la valeur pour la variable '$Banned'
     $req = $mysql->prepare('INSERT INTO users(user_id, username, password, usergroup, banned) VALUES(:ID, :Pseudo, :Password, :Groupe, :Banned)'); //On prépare la requête SQL
	 $req->execute(array(
	'ID' => $ID,
	'Pseudo' => $Pseudo,
	'Password' => $Crypt_Password,
	'Groupe' => $Groupe,
	'Banned' => $Banned
	));
     $Users_ID = $mysql->prepare('SELECT user_id FROM users WHERE username = ?'); //On prépare une requête SQL
	 $Users_ID->execute(array($Pseudo));
     $Users_Data = $Users_ID->fetch();
	 $Users_ID->closeCursor(); //On ferme le curseur pour éviter toute erreur
	 $UserID= $Users_Data['user_id']; //On attribue la valeur pour la variable '$UserID'
	 $Login= '2011-09-14 16:29:10'; //On attribue la valeur pour la variable '$Login'
	 $req2 = $mysql->prepare('INSERT INTO user_data(user_id, lastlogin) VALUES(:UserID, :Login)'); //On prépare une requête SQL
	 $req2->execute(array(
	'UserID' => $UserID,
	'Login' => $Login,
	));
	
	 echo 'Votre compte a été enregistré avec succès. Vous pouvez dès à présent vous connecter au jeu.';
	 }
	 else
	 {
	 echo "Une erreur s’est produite : Le nom de compte que vous avez saisi est déjà utilisé !";
	 }
	 }
	 catch (Exception $e)
     {
     die('Erreur : ' . $e->getMessage()); //On affiche le message d'erreur
	 }
	 }
	 else
	 {
	 echo "Une erreur s’est produite : Les deux mots de passe que vous avez saisis ne correspondent pas !";
	 }
     }
	 else
	 {
	  ?>
	 <form method="post" action="register.php">
	 <table>
     <tbody><tr><td>Pseudo :</td>
     <td><input type="text" size ="30" name="pseudo"/></td></tr>
	 <tr><td>Mot de passe :</td>
     <td><input type="text" size="30" name="passe"/></td></tr>
	 <tr><td>Vérification :</td>
	 <td><input type="text" size="30" name="passe_verification"/></td></tr>
	 </tbody></table>
	 <br/>
	<input type ="submit" value="Enregistrer"/>
 
    </form>
	<?php
	 }
	 ?>

</div>
<p>&nbsp;</p>
</div>

<div class="cleared"></div>

</div>
                 
<div class="cleared"></div>

</div>

</div>

</div>
					
<?php include("sidebar-right.php"); ?>

</div>

<?php include("footer.php"); ?>