package actions;
# load default modules
use strict;
use Exporter;

use combat;
use equipment;
use gameMap;
use messageLog;
use renown;
use skills;
use turns;
use utility;

# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&track &sneak &applyFirstAid &displayLocation &scavenge &move &showMap);

#------------------------------------
# applyFirstAid()
# return: html
sub applyFirstAid {
	my ($a, @data, $html, $firstAid, $poisonLevel, $injuries, $heal, $equipmentModifier, $useText);
	$html .= '
		<h1>Apply First Aid</h1>
		<table><tr><td valign=top width="50%">
		Apply first aid to yourself. If you have any medical supplies, they will be 
		used while you are attempting first aid.
		<p>
		Would you like to apply first aid?
		<p>
		<a href="game.pl?op=applyFirstAid&doit=yes">Yes, I want to heal myself.</a>
		<p>
		<b>Note:</b> Applying first aid costs 5 turns for each attempt.
		</td><td width="10%"></td><td valign=top width="40%">
	';
	if ($FORM{'doit'} eq "yes") {
		$injuries = health::getInjury($GLOBAL{'uid'});
		if ($injuries > 0) {
			if (turns::spendTurns($GLOBAL{'uid'},5)) {
				$html .= "Applying first aid...<br>";
				$poisonLevel = health::getAttribute($GLOBAL{'uid'},"poison");
				if ($poisonLevel > 0) {
					($equipmentModifier, $useText) = equipment::useConsumable($GLOBAL{'uid'},"anti-toxin",1);
					if ($equipmentModifier > 0) {
						$html .= $useText;
						if ($poisonLevel < $equipmentModifier) {
							health::setAttribute($GLOBAL{'uid'},"poison",0);
						} else {
							health::modifyAttribute($GLOBAL{'uid'},"poison",$equipmentModifier*-1);
						}
					}
				}	
				$firstAid = skills::useSkill($GLOBAL{'uid'},"first aid");
				($equipmentModifier, $useText) = equipment::useConsumable($GLOBAL{'uid'},"first aid",1);
				if ($equipmentModifier > 0) {
					$firstAid += rollDice($equipmentModifier,6);
					$html .= $useText;
				}	
				$heal = round($firstAid/15);
				if ($heal >= $injuries) {
					health::setAttribute($GLOBAL{'uid'},"health",20);
					$html .= "You've been fully healed.<br>";
				} elsif ($heal > 0) {
					health::modifyAttribute($GLOBAL{'uid'},"health",$heal);
					$html .= "You've restored ".$heal." health.<br>";
				} else {
					$html .= "You're not sure what you can do to help yourself.<br>";
				}
			} else {
				$html .= 'You do not have enough turns to apply first aid.';
			}
		} else {
			$html .= 'You have no wounds to heal.';
		}
	}
	$html .= '</td></tr></table>';
	return $html;
}

#------------------------------------
# displayLocation(incrementalMessage)
# return: 
sub displayLocation {
my ($html, $a, %location, $navigate, @data);
	$navigate = rollDice(skills::getSkillLevel($GLOBAL{'uid'},"navigate",1),6);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	$html =	"<h1>Travel</h1>";
	$html .= '
	<table width="100%"><tr>
	<td valign=top>
	'.$_[0];
	if ($location{'class'} eq "civilization") {
		$html .= "You are in ".$location{'name'}." (".$location{'x'}."-".$location{'y'}."), ".$location{'description'}.". ";
		($a) = sqlQuery("select type,value from mapAttributes where sectorId=".$location{'sectorId'}." and class='affinity'");
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] eq "mutants" || $data[0] eq "gunslingers") {
			$html .= '<p><img src="/sotfGame/no'.$data[0].'.jpg" border="0" alt="Go Away">';
		}
		$html .= "<p>This ".$location{'type'}." has these fine amenities to offer: <br>";
		$html .= gameMap::listAmenities($location{'sectorId'});
	} elsif ($navigate > 15) {
		$html .= "You are in sector ".$location{'x'}."-".$location{'y'}.", ".$location{'description'}.". ";
	} else {
		$html .= "You are unsure where you are, but you know that you are in ".$location{'description'}.". ";
	}
	$html .= gameMap::travelEvent($GLOBAL{'uid'},%location);
	$html .= '<P><a href="game.pl?op=showMap&map=cartography">Try to remember where I\'ve been.</a>';
	if (equipment::searchForItem($GLOBAL{'uid'},33)) {
		$html .= '<br><a href="game.pl?op=showMap&map=area">Take a look at my map of the area.</a>';
	}
	if (equipment::searchForItem($GLOBAL{'uid'},182)) {
		$html .= '<br><a href="game.pl?op=showMap&map=scavenging">Take a look at my scavenging map.</a>';
	}
	if (equipment::searchForItem($GLOBAL{'uid'},181)) {
		$html .= '<br><a href="game.pl?op=showMap&map=hunting">Take a look at my hunting map.</a>';
	}
	$html .= '
	</td><td valign=top align=right>
	<map name="compass">
	<area alt="North" shape="poly" coords="77,14,122,124,170,12,126,3" href="game.pl?op=move&dir=north">
	<area alt="NorthEast" shape="poly" coords="121,124,170,13,210,46,229,78" href="game.pl?op=move&dir=north-east">
	<area alt="East" shape="poly" coords="122,123,229,79,239,122,231,169" href="game.pl?op=move&dir=east">
	<area alt="SouthEast" shape="poly" coords="122,122,229,171,204,210,168,234" href="game.pl?op=move&dir=south-east">
	<area alt="South" shape="poly" coords="123,124,166,233,123,242,75,233" href="game.pl?op=move&dir=south">
	<area alt="SouthWest" shape="POLY" coords="124,124,76,233,36,212,14,168" href="game.pl?op=move&dir=south-west">
	<area alt="West" shape="poly" coords="120,122,10,168,4,126,13,83" href="game.pl?op=move&dir=west">
	<area alt="NorthWest" shape="POLY" coords="76,14,121,121,12,80,36,39" href="game.pl?op=move&dir=north-west">
	</map>
	<img src="/sotfGame/compass.jpg" width="250" height="250" border="0" usemap="#compass">
	</td>
	</tr></table>
	';
	return $html;
}

#------------------------------------
# move()
# return: html
sub move {
	my ($a, @data, %location, $html, $navigate, $direction, $nextX, $nextY, $message);
	if (turns::spendTurns($GLOBAL{'uid'},3)) {
		$navigate = skills::useSkill($GLOBAL{'uid'},"navigate");
		if ($navigate > 10) {
			$direction = $FORM{'dir'};
		} else {
			$message .= "You've gotten yourself lost. ";
			$direction = gameMap::randomDirection();
		}
		%location = gameMap::getLocationProperties($GLOBAL{'uid'});
		if ($direction eq "north") {
			$nextX = $location{'x'};
			$nextY = --$location{'y'};
		} elsif ($direction eq "north-west") {
			$nextX = gameMap::stringSubtract($location{'x'},1);
			$nextY = --$location{'y'};
		} elsif ($direction eq "south-west") {
			$nextX = gameMap::stringSubtract($location{'x'},1);
			$nextY = ++$location{'y'};
		} elsif ($direction eq "south") {
			$nextX = $location{'x'};
			$nextY = ++$location{'y'};
		} elsif ($direction eq "south-east") {
			$nextX = gameMap::stringAdd($location{'x'},1);
			$nextY = ++$location{'y'};
		} elsif ($direction eq "north-east") {
			$nextX = gameMap::stringAdd($location{'x'},1);
			$nextY = --$location{'y'};
		} elsif ($direction eq "east") {
			$nextX = gameMap::stringAdd($location{'x'},1);
			$nextY = $location{'y'};
		} elsif ($direction eq "west") {
			$nextX = gameMap::stringSubtract($location{'x'},1);
			$nextY = $location{'y'};
		}
		($a) = sqlQuery("select map.id,map.type,mapAttributes.type,mapAttributes.value from map,mapAttributes where map.id=mapAttributes.sectorId and mapAttributes.class='description' and map.x='".$nextX."' and map.y=".$nextY."");
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[1] eq "impassible") {
			#messageLog::newMessage($GLOBAL{'uid'},"game","notice","You cannot go any further ".$direction.", because ".$data[3].".");
			$message .= "You cannot go any further ".$direction.", because ".$data[3].". ";
		} else {
			health::setAttribute($GLOBAL{'uid'},"stealth rating",0);
			($a) = sqlQuery("update playerAttributes set type='past' where uid=".$GLOBAL{'uid'}." and class='location'");
			sqlFinish($a);
			($a) = sqlQuery("insert into playerAttributes set uid=".$GLOBAL{'uid'}.", class='location', type='current', value='".$data[0]."'");
			sqlFinish($a);
		}
	} else {
		messageLog::newMessage($GLOBAL{'uid'},"game","notice","You don't have enough turns to travel.");
	}	
	$html .= displayLocation($message);
	return $html;
}

#------------------------------------
# scavenge()
# return: html
sub scavenge {
	my ($clanBonus, $a, @data, %location, $html, $senses, $i, $item, $stash, $hideRating, $timesToSearch);
	$html .= '
		<h1>Scavenge</h1>
		<table><tr><td valign=top width="50%">
		The life of a scavenger is tedious, dirty, and dangerous, but if you\'re good at it,
		you can become filthy rich. Do you wish to scavenge this location?
		<p>
		<form method="post">
		<input type="hidden" name="op" value="scavenge">
		<input type="hidden" name="doit" value="yes">
		<input type="submit" value="Yes">, I\'d like to 
		scavenge for <select name="turnsToSpend"><option';
		if ($FORM{'turnsToSpend'} == 6) {
			$html .= ' selected';		
		}
		$html .= '>6	<option';
		if ($FORM{'turnsToSpend'} == 12) {
			$html .= ' selected';		
		}
		$html .= '>12<option';
		if ($FORM{'turnsToSpend'} == 18) {
			$html .= ' selected';		
		}
		$html .= '>18	<option';
		if ($FORM{'turnsToSpend'} == 24) {
			$html .= ' selected';		
		}
		$html .= '>24</select> turns.</form>
		</td><td width="10%"></td><td valign=top width="40%">
		';
		if ($FORM{'doit'} eq "yes") {
			if ($FORM{'turnsToSpend'} == 6||$FORM{'turnsToSpend'} == 12||$FORM{'turnsToSpend'} == 18||$FORM{'turnsToSpend'} == 24) {
				if (turns::spendTurns($GLOBAL{'uid'},$FORM{'turnsToSpend'})) {
					%location = gameMap::getLocationProperties($GLOBAL{'uid'});
					$html .= "Scavenging...<br>";
					$timesToSearch = ($FORM{'turnsToSpend'}/6);
					if (health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan") eq "Null") {
						$clanBonus = $location{'hide rating'};
					}
					for ($i=1;$i<=$timesToSearch;$i++) {
						$senses = skills::useSkill($GLOBAL{'uid'},"senses")+rollDice($clanBonus,6);
						($a) = sqlQuery("select type,value,id from mapAttributes where sectorId=".$location{'sectorId'}." and class='item' order by rand() limit 1");
						@data = sqlArray($a);
						sqlFinish($a);
						if ($data[0] ne "") {
							($a) = sqlQuery("select value from sectorItemAttributes where sectorItemId=".$data[2]." and class='attribute' and type='hide rating'");
							($hideRating) = sqlArray($a);
							sqlFinish($a);
							if ($hideRating < $senses) {
								if ($data[0] == 1) {
									# pick up the whole pile of money 
								} elsif ($data[1] > 25) {
									$data[1] = rollDice(1,25);
								} else {
									$data[1] = rollDice(1,$data[1]);
								}
								if (equipment::pickUpItem($GLOBAL{'uid'},$location{'sectorId'},$data[0],$data[1])) {
									($a) = sqlQuery("select name from item where id=".$data[0]);
									($item) = sqlArray($a);
									sqlFinish($a);
									$stash .= "You found ".$data[1]." ".pluralize($item,$data[1]).".<br>"; 
								} else {
									$stash .= "There is a problem with the item you just tried to pick up. Perhaps the item is corrupt or another user has already grabbed it.<br>";
								}
							}
						}
					}
					($a) = sqlQuery("select player.uid, player.username from playerAttributes, player where playerAttributes.uid=player.uid and playerAttributes.class='location' and playerAttributes.type='current' and playerAttributes.value=".$location{'sectorId'}." and player.uid<>".$GLOBAL{'uid'}." order by player.username");
					while (@data = sqlArray($a)) {
						if (health::getAttribute($data[0],"stealth rating") < $senses) {
							$stash .= 'You found <a href="game.pl?op=nearbyPlayer&uid='.$data[0].'">'.$data[1].'</a>.<br>';
						}	
					}
					sqlFinish($a);
					if ($stash ne "") {
						$html .= $stash;
					} else {
						$html .= "You found nothing.<br>";
					}
				} else {
					$html .= 'You do not have enough turns to scavenge that long.';
				}
			} else {
				$html .= 'You must choose a valid number of turns for scavenging.';
				messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to scavenge for an invalid number of turns.");
		}
	}
	$html .= '</td></tr></table>';
	return $html;
}

#------------------------------------
# showMap()
# return: html
sub showMap {
	my ($a, @data, $html,$name, $yLabels);
	$html .= "<h1>Viewing Map</h1>";
	if (turns::spendTurns($GLOBAL{'uid'},1)) {
		if ($FORM{'map'} eq "cartography") {
			$html .= gameMap::mapCartography($GLOBAL{'uid'});
		} elsif ($FORM{'map'} eq "area" && equipment::searchForItem($GLOBAL{'uid'},33)) {
			$html .= gameMap::mapArea();
		} elsif ($FORM{'map'} eq "scavenging" && equipment::searchForItem($GLOBAL{'uid'},182)) {
			$html .= gameMap::mapScavenging();
		} elsif ($FORM{'map'} eq "hunting" && equipment::searchForItem($GLOBAL{'uid'},181)) {
			$html .= gameMap::mapHunting();
		} else {
			$html .= "How can you use a map you don't have?<br>";
			messageLog::caughtCheating($GLOBAL{'uid'},"You've been caught trying to look at the map when you didn't have one.");
			$html .= '<p><a href="game.pl?op=displayLocation">Go back to traveling.</a>';
		}
		$html .= '<p><a href="game.pl?op=displayLocation">Ok, I\'ve seen what I needed to see.</a>';
	} else {
		$html .= "You don't have enough turns to look at your map right now.";
	}
	return $html;
}

#------------------------------------
# sneak()
# return: html
sub sneak {
	my ($html, $stealth, %location);
	$html .= '
		<h1>Sneak</h1>
		<table><tr><td valign=top width="50%">
		Sneaking can be a very useful tactic to help avoid being attacked or stolen from. Each time you 
		enter a new sector you\'ll need to sneak if you wish to try to be undetected.
		<p>
		Would you like to start sneaking?
		<p>
		<a href="game.pl?op=sneak&doit=yes">Yes, I want to sneak.</a>
		<p>
		<b>Note:</b> Sneaking costs 5 turns for each attempt.
		</td><td width="10%"></td><td valign=top width="40%">
	';
	if ($FORM{'doit'} eq "yes") {
		if (turns::spendTurns($GLOBAL{'uid'},5)) {
			$html .= "Sneaking...<br>";
			%location = gameMap::getLocationProperties($GLOBAL{'uid'});
			$stealth = skills::useSkill($GLOBAL{'uid'},"stealth") + rollDice($location{'stealth bonus'},6);
			health::setAttribute($GLOBAL{'uid'},'stealth rating',$stealth);
			$html .= "You believe you've gone into stealth mode.";
		} else {
			$html .= 'You do not have enough turns to sneak.';
		}
	}
	$html .= '</td></tr></table>';
	return $html;
}

#------------------------------------
# track()
# return: html
sub track {
	my (%location, $html, $result, $i, %animal, $beastlore);
	$html .= '
		<h1>Hunt</h1>
		<table><tr><td valign=top width="50%">
		You\'ve got the skills; you\'re in the wild; it\'s only natural that you\'d go hunting, right? The
		animals are near, you can feel them, and you can almost smell the food cooking already.
		<p>
		<a href="game.pl?op=track&doit=go">Sounds good, let\'s go hunting!</a>
		<p>
		<b>Note:</b> Tracking costs 4 turns per attempt. Attacking an animal costs 5 turns per attempt.
		';
	if ($FORM{'doit'} eq "go") {
		$html .= "</td><td>&nbsp;</td><td valign=top>";
		if (turns::spendTurns($GLOBAL{'uid'},4)) {
			%location = gameMap::getLocationProperties($GLOBAL{'uid'});
			$html .= "Hunting...<br>";
			$result = round((skills::useSkill($GLOBAL{'uid'},"tracking")-$location{'hunting difficulty'})/6);
			if ($result > 0) {
				$html .= "You tracked down ".$result." ".pluralize("animal",$result).":<p>";
				for ($i=1;$i<=$result;$i++) {
					%animal = combat::pickAnimal(rollDice(1,100));
					$html .= '&nbsp;&nbsp;&nbsp;<a href="game.pl?op=track&doit=attackAnimal&an='.$animal{'id'}.'">'.$animal{'name'}.'</a><br>';
					%animal = combat::getAnimalProperties($animal{'id'});
					$beastlore = skills::useSkill($GLOBAL{'uid'},"beast lore");
					if ($beastlore > 1/$animal{'threshold'}*1000) {
						if ($animal{'poison'} > 0) {
							$html .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;poisonous<br>';
						}
						$html .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$animal{'combat'}.' combat<br>';
						if ($beastlore > 1/$animal{'threshold'}*1500) {
							$html .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$animal{'hit points'}.' hit points<br>';
						}
						if ($beastlore > 1/$animal{'threshold'}*2000) {
							$html .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$animal{'armor rating'}.' armor rating<br>';
						}	
					} else {
						$html .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;You know nothing about this animal.<br>';
					}	
				}	
			} else {
				$html .= "You were unable to track any animals.<br>";
			}
		} else {
			$html .= 'You do not have enough turns to hunt that long.';
		}
	}
	if ($FORM{'doit'} eq "attackAnimal") {
		$html .= "</td><td valign=top>";
		$html .= combat::attackAnimal();
	}
	$html .= '</td></tr></table>';
	return $html;
}




1;

