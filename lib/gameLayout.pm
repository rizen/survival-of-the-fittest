package gameLayout;

use strict;
use character;
use gameMap;
use nearbyPlayer;
use utility;

#------------------------------------
# htmlFooter()
# return: htmlFooter
sub htmlFooter {
	my $html;
	$html = '
	</td></tr>
	</table>
	<div class="version">Survival of the Fittest - v3.1.0<br>&copy;2000-2001 <a href="http://www.thegamecrafter.com">The Game Crafter</a></div>
	</body>
	</html>
	';
	return $html;
}

#------------------------------------
# htmlHeader()
# return: htmlHeader
sub htmlHeader {
	my $html;
	$html = '
	<html>
		<head>
			<title>Survival of the Fittest</title>
			<link href="/sotf.css" rel="stylesheet" type="text/css">
		</head>
	<body bgcolor="#000000" text="#B19D8F" link="#dddddd" alink="#ffffff" vlink="#dddddd">
	<table width="100%" cellpadding=5>	<tr>
	<td valign="top" class="mainContent">
	';
	if ($GLOBAL{uid} > 0) {
		if (checkCharacter($GLOBAL{uid})) {
			$html .= statusBar($GLOBAL{uid})
		}
	}
	return $html;
}

#------------------------------------
# subMenu()
# return: html
sub subMenu {
	my ($html, %location);
	$html = '</td><td valign=top width=110 class="menu">';
	if (checkCharacter($GLOBAL{'uid'})) {
		$html .= messageLog::messageBar($GLOBAL{uid});
		unless (gameMap::isInJail($GLOBAL{'uid'})) {
			%location = gameMap::getLocationProperties($GLOBAL{'uid'});
			$html .= nearbyPlayerSubmenu($GLOBAL{'uid'},$location{'sectorId'});
			$html .= '
			Actions<br>
			&nbsp;&nbsp;<a href="game.pl?op=applyFirstAid">Apply First Aid</a><br>
			&nbsp;&nbsp;<a href="game.pl?op=track">Hunt</a><br>
			&nbsp;&nbsp;<a href="game.pl?op=scavenge">Scavenge</a><br>
			&nbsp;&nbsp;<a href="game.pl?op=sneak">Sneak</a><br>
			&nbsp;&nbsp;<a href="game.pl?op=displayLocation">Travel</a><br>
			';
			if ($location{'class'} eq "civilization") {
				$html .= "Amenities<br>";
				$html .= gameMap::listAmenities($location{'sectorId'});
			}
		} else {
			$html .= "<p>You being in jail negates the posibility of needing the menu options that should have been here.<p>";
		}	
		$html .= '
		Character<br>
		&nbsp;&nbsp;<a href="game.pl?op=showAttributes">Attributes</a><br>
		&nbsp;&nbsp;<a href="game.pl?op=showDeeds">Deeds / Renown</a><br>
		&nbsp;&nbsp;<a href="game.pl?op=showInventory">Inventory</a><br>
		&nbsp;&nbsp;<a href="game.pl?op=showMessageLog">Message Log</a><br>
		&nbsp;&nbsp;<a href="game.pl?op=showQuests">Quests</a><br>
		&nbsp;&nbsp;<a href="game.pl?op=showRadiations">Radiations</a><br>
		&nbsp;&nbsp;<a href="game.pl?op=showSkills">Skills</a><br>
		';
		$html .= '
		Careful<br>
		&nbsp;&nbsp;<a href="game.pl?op=commitSuicide">Commit Suicide</a><br>
		';
	} else {
		$html .= '
		<p>	Since you have no character, you have no additional options at this time.
		';
	}
	$html .= "</td>";
	return $html;
}


1;

