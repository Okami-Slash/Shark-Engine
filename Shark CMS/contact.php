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
<h2 class="art-PostHeader">Contact</h2>
</div>

<div class="art-PostContent"><br/><div class="art-PostContent">
Vous voulez entrez en contact avec l'équipe, pour un doute, une question ou
une proposition, complétez le formulaire si dessous. Envoyer votre message a l'adresse suivante :<br /><br />
<form method="post" action="formmail.php">
<input name="subject" value="formmail" type="hidden" />
<table>
<tbody><tr><td>Votre Nom :</td>
    <td><input name="realname" size="30" type="text" /></td></tr>
<tr><td>Votre Email :</td>
    <td><input name="email" size="30" type="text" /></td></tr>
<tr><td>Sujet :</td>
    <td><input name="title" size="30" type="text" /></td></tr>
<tr><td colspan="2">Commentaires :<br />
  <textarea cols="50" rows="6" name="comments"></textarea>
</td></tr>
</tbody></table>
<br /> <input value="Envoyer" type="submit" /> -
     <input value="Annuler" type="reset" />
</form>
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