<div class="art-sidebar2">
<div class="art-Block">
<div class="art-Block-body">
<div class="art-BlockHeader">
<div class="l"></div>
<div class="r"></div>
<div class="art-header-tag-icon">
<div class="t">État du serveur</div>
</div>
</div>
<div class="art-BlockContent-body">
     <?php
     $serveur = "127.0.0.1";
     $port = 54269;
     $socket = fsockopen($serveur, $port, $codeErreur, $msgErreur);
    if (!$socket)
     {
    ?>
    <img src="images/Online.png">
    <?php
     }
    else
     {
    ?>
    <img src="images/Offline.png">
    <?php
     }
    ?>
</div>
</div>
</div>
</div>