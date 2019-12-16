package messageLog;
# load default modules
use strict;

use drunk;
use health;
use utility;

#------------------------------------
# caughtCheating(uid, message)
# return: 
sub caughtCheating {
	my (@data, $a);
	newMessage($_[0],"game","cheating",$_[1]);
	($a) = sqlQuery("select count(*) from messageLog where uid=".$_[0]." and class='game' and type='cheating'");
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] >= 10) {
		($a) = sqlQuery("update messageLog set type='cheating (punished)' where uid=".$_[0]." and class='game' and type='cheating'");
		sqlFinish($a);
		newMessage($_[0],"game","notice","After being caught for your tenth offense of cheating, it has been deemed that you are not a worthy player. Your character has been killed.");
		health::killCharacter($_[0],"cheating");
	}
}

#------------------------------------
# newMessage(uid, messageClass, messageType, message)
# return: 
sub newMessage {
	my (@data, $a, $errors, $message);
	$message = $_[3];
	if ($_[0] eq "") {
		$errors .= "<li>There was no user specified for which this message was to be delivered to.";
	}	
	if ($_[1] eq "") {
		$errors .= "<li>There was no message class specified to be sent to the message log.";
	}	
	if ($_[2] eq "") {
		$errors .= "<li>There was no message type specified to be sent to the message log.";
	}	
	if ($_[3] eq "") {
		$errors .= "<li>There was no message specified to be sent to the message log.";
	}	
	if ($errors eq "") {
		if (health::getAttribute($_[0],"drunk")) {
			$message = drunk::drunkify($message);
		}
		($a) = sqlQuery("insert into messageLog set time=now(), uid=".$_[0].", class='".$_[1]."', type='".$_[2]."', message=".quote($message));
		sqlFinish($a);
	} else {
		printError("<ul>".$errors."</ul>");
	}
}

#------------------------------------
# messageBar(uid)
# return: html
sub messageBar {
	my ($html, @data, $a);
	$html .= '<table align="center" class="quickStats" border=0 cellpadding=2 cellspacing=1><tr><td colspan=2 class="quickStatsHeader"><a href="game.pl?op=showMessageLog">Recent Messages</a></td></tr><tr><td class="quickStatsData">';
	($a) = sqlQuery("select date_format(time,'%c/%e %l:%i %p'), message,class,type from messageLog where uid=".$GLOBAL{'uid'}." order by id desc limit 3");
	while (@data = sqlArray($a)) {
		$html .= '<span class="'.$data[2].'_'.$data[3].'"><b>'.$data[0].'</b> '.$data[1].'</span><br>';
	}
	sqlFinish($a);
	$html .= "</tr></table>";
	return $html;
}

1;
