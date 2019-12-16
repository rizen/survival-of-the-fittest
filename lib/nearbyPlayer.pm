package nearbyPlayer;
# load default modules
use strict;
use Exporter;

use account;
use battlecry;
use gameMap;
use messageLog;
use turns;
use utility;

# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&healPlayer &stealFromPlayer &attackPlayer &nearbyPlayerSubmenu &nearbyPlayer &shoutAtPlayer);

#------------------------------------
# attackPlayer()
# return: html
sub attackPlayer {
	my ($defenderReaction, @data, $html, $result, $i, $other, %yourLocation, %theirLocation, %player, $food, $msg, $myClan);
	$defenderReaction = health::getUnmodifiedAttribute($FORM{uid},'react');
	$other = '<p><a href="game.pl?op=nearbyPlayer&uid='.$FORM{'uid'}.'">I want to do something else with this player.</a><p>';
	%yourLocation = gameMap::getLocationProperties($GLOBAL{'uid'});
	%theirLocation = gameMap::getLocationProperties($FORM{'uid'});
	%player = account::getPlayerProperties($FORM{'uid'});
	$html .= '<h1>Attacking '.$player{'username'}.'</h1>';
	if ($yourLocation{'sectorId'} eq $theirLocation{'sectorId'}) {
		unless (turns::isNewbie($FORM{'uid'}) && health::getUnmodifiedAttribute($FORM{'uid'},"clan") eq "AlphaPrime" && health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan") eq "AlphaPrime") {
			if (turns::spendTurns($GLOBAL{'uid'},5)) {
				$myClan = health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan");
				if (health::getUnmodifiedAttribute($FORM{'uid'},"clan") eq $myClan && $myClan ne "") {
					($a) = sqlQuery("select uid from playerAttributes where class='attribute' and type='clan' and value='".$myClan."'");
					while (@data = sqlArray($a)) {
						messageLog::newMessage($data[0],"clan","alert",$GLOBAL{'username'}." attacked a clanmate ".$player{'username'}."!");
					}
					sqlFinish($a);
				}
				if (turns::isNewbie($GLOBAL{'uid'})) {
					health::setAttribute($GLOBAL{'uid'},"turns spent", "1000");
				}
				$i = 0;
				$result = 0;
				$msg .= $GLOBAL{username}.' crys "'.battlecry::grunt().'"<br>';
				while ($result == 0) {
					@data = combat::fight($GLOBAL{'username'},skills::useSkill($GLOBAL{'uid'},"combat"),combat::getArmorRating($GLOBAL{'uid'}),$player{'username'},skills::useSkill($FORM{'uid'},"combat"),combat::getArmorRating($FORM{'uid'}));
					$msg .= $data[0];
					$i++;
					if ($data[1] > 0) {
						health::modifyAttribute($GLOBAL{'uid'},"health",($data[1]*-1));
						if (health::getAttribute($GLOBAL{'uid'},"health") <= 0) {
							$msg .= $player{'username'}." killed ".$GLOBAL{'username'}.".<br>";
							messageLog::newMessage($GLOBAL{'uid'},"game","alert",$msg);
							messageLog::newMessage($FORM{'uid'},"game","alert",$msg);
							health::killCharacter($GLOBAL{'uid'},$player{'username'});
							$result = 1;
						}
					} elsif ($data[2] > 0) {
						health::modifyAttribute($FORM{'uid'},"health",($data[2]*-1));
						if (health::getAttribute($FORM{'uid'},"health") <= 0) {
							$msg .= $GLOBAL{'username'}." killed ".$player{'username'}.".<br>";
							messageLog::newMessage($GLOBAL{'uid'},"game","notice",$msg);
							messageLog::newMessage($FORM{'uid'},"game","alert",$msg);
							health::modifyAttribute($GLOBAL{'uid'},"murders",1);
							health::killCharacter($FORM{'uid'},$GLOBAL{'username'},1);
							$result = 1;
							renown::addDeed($GLOBAL{'uid'},"player",$FORM{'uid'},1);
							$food = skills::repetitiveSuccessTest($GLOBAL{'uid'},"domestics",20,rollDice(4,2));
							if ($food > 0) {
								equipment::addItemToUser($GLOBAL{'uid'},104,$food);
								$html .= $msg."You've decided that ".$player{'username'}." would make a nice snack.<br>You you've prepared ".$food." human ".pluralize("steak",$food).".<br>";
							}
						}
					} 
					if ($i > 3 && $result < 1) {
						if ($defenderReaction ne "fight") {
							$result = 1;
							messageLog::newMessage($FORM{'uid'},"game","alert",$msg);
							$html .= $msg.'You were unable to kill '.$player{'username'}.'.<br>';
							if ($defenderReaction eq "run") {
								runAway($FORM{uid});
								$html .= $player{username}.' has run away.<br>';
							} else {
								$html .= '<a href="game.pl?op=attackPlayer&uid='.$FORM{'uid'}.'">Attack '.$player{'username'}.' again.</a><br>';
							}
							$html .= $other;
						} else {
							$msg .= 'As '.$GLOBAL{username}.' stops to take a breather, '.$player{username}.' decides to continue the fight.<br>';
						}
					}
				}
				$html .= gameMap::processAffinity($FORM{'uid'},$theirLocation{'sectorId'});
			} else {
				$html .= 'You do not have enough turns to attack '.$player{'username'}.'.<br>'.$other;
			}
		} else {
			$html .= "This player is immune to attacks.<br>";
		}
	} else {
		$html .= "How can you attack a player who's not near you?<br>".$other;
		messageLog::caughtCheating($GLOBAL{'uid'},"Tried to attack a player who's not in the same sector as you.");
	}
	return $html;
}

#------------------------------------
# healPlayer()
# return: html
sub healPlayer {
	my ($html, %yourLocation, %theirLocation, %player, $poisonLevel, $heal, $injuries, $firstAid, $equipmentModifier, $useText);
	%yourLocation = gameMap::getLocationProperties($GLOBAL{'uid'});
	%theirLocation = gameMap::getLocationProperties($FORM{'uid'});
	%player = account::getPlayerProperties($FORM{'uid'});
	$html .= '<h1>Healing '.$player{'username'}.'</h1>';
	if ($yourLocation{'sectorId'} eq $theirLocation{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top">';
		$html .= 'Are you sure you want to heal '.$player{'username'}.'?
				<p>
				<a href="game.pl?op=healPlayer&uid='.$FORM{'uid'}.'&doit=yes">Yeah, let\'s do it.</a><br>
		';
		if ($FORM{'doit'} eq "yes") {
			$html .= '</td><td valign="top" width="50%">';
			if (turns::spendTurns($GLOBAL{'uid'},5)) {
				$html .= "Applying first aid...<br>";
				$injuries = health::getInjury($FORM{'uid'});
				if ($injuries > 0) {
					if (turns::spendTurns($GLOBAL{'uid'},5)) {
						$poisonLevel = health::getAttribute($FORM{'uid'},"poison");
						if ($poisonLevel > 0) {
							($equipmentModifier, $useText) = equipment::useConsumable($GLOBAL{'uid'},"anti-toxin",1);
							if ($equipmentModifier > 0) {
								$html .= $useText;
								if ($poisonLevel < $equipmentModifier) {
									health::setAttribute($FORM{'uid'},"poison",0);
								} else {
									health::modifyAttribute($FORM{'uid'},"poison",$equipmentModifier*-1);
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
							health::modifyAttribute($FORM{'uid'},"health",$injuries);
							$html .= $player{'username'}." has been fully healed.";
							messageLog::newMessage($FORM{'uid'},"game","notice",$GLOBAL{'username'}." bandaged your wounds.");
						} else {
							health::modifyAttribute($FORM{'uid'},"health",$heal);
							$html .= "You've restored ".$heal." health.";
							messageLog::newMessage($FORM{'uid'},"game","notice",$GLOBAL{'username'}." applied first aid to you.");
						}
					} else {
						$html .= 'You do not have enough turns to apply first aid.';
					}
				} else {
					$html .= $player{'username'}.' has no wounds to heal.';
				}
			} else {
				$html .= 'You do not have enough turns to heal '.$player{'username'}.'.<br>';
			}
		}	
		$html .= "</td><tr></table>";
	} else {
		$html .= "How can you heal a player who's not near you?<br>";
		messageLog::caughtCheating($GLOBAL{'uid'},"Tried to heal a player who's not in the same sector as you.");
	}
	$html .= '<p><a href="game.pl?op=nearbyPlayer&uid='.$FORM{'uid'}.'">I want to do something else with this player.</a><p>';
	return $html;
}

#------------------------------------
# nearbyPlayer(userId)
# return: 
sub nearbyPlayer {
	my ($clan, $a, @data, $renowned, $html, %yourLocation, %theirLocation, %player, %me);
	%yourLocation = gameMap::getLocationProperties($GLOBAL{'uid'});
	%theirLocation = gameMap::getLocationProperties($FORM{'uid'});
	%me = account::getPlayerProperties($GLOBAL{'uid'});
	%player = account::getPlayerProperties($FORM{'uid'});
	$html .= '<h1>'.$player{'username'}.'</h1>';
	$html .= $player{'username'}.' is a '.health::getAttribute($FORM{'uid'},"age").' year old '.health::getUnmodifiedAttribute($FORM{'uid'},"gender");
	$clan = health::getUnmodifiedAttribute($FORM{'uid'},"clan");
	if ($clan ne "") {
		$html .= ", and is a part of the clan ".$clan;
	}
	$html .= ".<p>";
	($a) = sqlQuery("select description from deeds where uid=".$FORM{'uid'}." and completed=1");
        while (@data = sqlArray($a)) {
                $renowned .= '<li>'.$data[0];
        }
        sqlFinish($a);
	if ($renowned ne "") {
		$html .= $player{'username'}." is renowned for these reasons:<ul>".$renowned."</ul>";
	}
	if ($yourLocation{'sectorId'} eq $theirLocation{'sectorId'}) {
		if ($player{'icq'} ne "") {
			$html .= '
			<table border=1 cellpadding=0 cellspacing=0 bgcolor="#333333" align="right"><tr><td align="center">
			<img src="http://wwp.icq.com/scripts/online.dll?icq='.$player{'icq'}.'&img=3"><br>
			<a href="http://wwp.icq.com/scripts/contact.dll?msgto='.$player{'icq'}.'">ICQ Me</a><br>
			<a href="http://wwp.icq.com/scripts/contact.dll?chatto='.$player{'icq'}.'">Chat Me</a><br>
			<a href="http://wwp.icq.com/scripts/search.dll?to='.$player{'icq'}.'">Add Me</a><br>
			<a href="http://wwp.icq.com/scripts/srch.dll?Uin='.$player{'icq'}.'">Zoom Me</a><br>
			<form action="http://wwp.icq.com/scripts/WWPMsg.dll" method="post">
			<input type="hidden" name="from" value="'.$GLOBAL{'username'}.'">
			<input type="hidden" name="fromemail" value="'.$me{'email'}.'">
			<input type="hidden" name="subject" value="Message from SotF player">
			Send a quick message:<br>
			<textarea name="body" rows="6" cols="27" wrap="Virtual"></textarea><br>
			<input type="HIDDEN" name="to" value="'.$player{'icq'}.'">
			<input type="SUBMIT" name="Send" value="Send Message">
			</form>
			</td></tr></table>	
			';
		}	
		$html .= 'How do you wish to interact with '.$player{'username'}.'?
		<ul>
			<li><a href="game.pl?op=healPlayer&uid='.$FORM{'uid'}.'">Apply first aid.</a>
		';
		($a) = sqlQuery("select player.uid, player.username, playerAttributes.value+0 as rank from player,playerAttributes where player.uid=playerAttributes.uid and playerAttributes.class='attribute' and playerAttributes.type='turns spent' order by rank desc");
        	@data = sqlArray($a);
        	sqlFinish($a);	
		if (health::getUnmodifiedAttribute($FORM{'uid'},"clan") eq "AlphaPrime" && $data[0] ne $FORM{uid}) {
			$html .= '<li>The clan AlphaPrime is immune to player attack.';
		} elsif (health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan") eq "AlphaPrime") {
			$html .= '<li>Because you are in clan AlphaPrime, you will not attack a human being.';
		} elsif (turns::isNewbie($FORM{'uid'})) {
			$html .= '<li>Newbies are immune to player attack.';
		} else {
			$html .= '<li><a href="game.pl?op=attackPlayer&uid='.$FORM{'uid'}.'">Attack.</a>';
		}
		$html .= '<li><a href="game.pl?op=shoutAtPlayer&uid='.$FORM{'uid'}.'">Give a shout.</a>';
                if (turns::isNewbie($FORM{'uid'})) {
                        $html .= '<li>Newbies are immune to player theft.';
                } else {
			$html .= '<li><a href="game.pl?op=stealFromPlayer&uid='.$FORM{'uid'}.'">Steal from.</a>';
                }
		$html .= '</ul>';	
	} else {
		$html .= "How can you interact with a player who's not near you?";
		messageLog::caughtCheating($GLOBAL{'uid'},"Tried to interact with a player who's not in the same sector as you.");
	}
	return $html;
}

#------------------------------------
# nearbyPlayerSubmenu(userId, sectorId)
# return: html
sub nearbyPlayerSubmenu {
	my ($a, @data, $html, $playerList, $senses);
	$senses = rollDice(skills::getSkillLevel($_[0],"senses",1),4);
	($a) = sqlQuery("select player.uid, player.username from playerAttributes, player where playerAttributes.uid=player.uid and playerAttributes.class='location' and playerAttributes.type='current' and playerAttributes.value=".$_[1]." and player.uid<>".$_[0]." order by player.username");
	while (@data = sqlArray($a)) {
		if (health::getAttribute($data[0],"stealth rating") < $senses) {
			$playerList .= '&nbsp;&nbsp;<a href="game.pl?op=nearbyPlayer&uid='.$data[0].'">'.$data[1].'</a><br>';
		}	
	}
	sqlFinish($a);
	if ($playerList ne "") {
		$html .= "Nearby Players<br>".$playerList;
	}
	return $html;
}

#------------------------------------
sub runAway {
	my (@map, $nextX, $nextY, %location);
	%location = gameMap::getLocationProperties($_[0]);
	$nextX = rollDice(1,5)-3;
	if ($nextX < 0) {
		$nextX = gameMap::stringSubtract($location{x},$nextX);
	} elsif ($nextX > 0) {
		$nextX = gameMap::stringAdd($location{x},$nextX);
	} else {
		$nextX = $location{x};
	}	
	$nextY = rollDice(1,5)-3+$location{y};
	@map = sqlQuickArray("select id,type from map where x='".$nextX."' and y=".$nextY);
        if ($map[1] eq "impassible" or $map[1] eq "") {
		runAway($_[0]);
        } else {
        	health::setAttribute($_[0],"stealth rating",0);
                ($a) = sqlQuery("update playerAttributes set type='past' where uid=".$_[0]." and class='location'");
                sqlFinish($a);
                ($a) = sqlQuery("insert into playerAttributes set uid=".$_[0].", class='location', type='current', value='".$map[0]."'");
                sqlFinish($a);
		messageLog::newMessage($_[0],"game","notice","You've run away.");
        }
}

#------------------------------------
# shoutAtPlayer()
# return: html
sub shoutAtPlayer {
	my ($a, @data, $html, %yourLocation, %theirLocation, %player);
	%yourLocation = gameMap::getLocationProperties($GLOBAL{'uid'});
	%theirLocation = gameMap::getLocationProperties($FORM{'uid'});
	%player = account::getPlayerProperties($FORM{'uid'});
	$html .= '<h1>Shout At '.$player{'username'}.'</h1>';
	if ($yourLocation{'sectorId'} eq $theirLocation{'sectorId'}) {
		$html .= '
			<table><tr><td valign="top">
			What would you like to say?
			<form action="game.pl" method="post">
			<input type="hidden" name="op" value="shoutAtPlayer">
			<input type="hidden" name="uid" value="'.$FORM{'uid'}.'">
			<input type="hidden" name="doit" value="send">
			<textarea cols="35" rows="5" name="message"></textarea>
			<br><input type="submit" value="Shout It!">
			</form>
		';	
		if ($FORM{'doit'} eq 'send') {
			messageLog::newMessage($FORM{'uid'},"player","shout",$GLOBAL{'username'}.' shouted, "'.$FORM{'message'}.'"');
			$html .= '</td><td valign="top">Shouting...'.$FORM{'message'}.'<br>Done.<br>';
		}
		$html .= "</tr></td></table>";
	} else {
		$html .= "How can you shout at a player who's not near you?";
	#	messageLog::caughtCheating($GLOBAL{'uid'},"Tried to shout at a player who's not in the same sector as you.");
	}
	$html .= '<a href="game.pl?op=nearbyPlayer&uid='.$FORM{'uid'}.'">I want to do something else with this player.</a><p>';
	return $html;
}

#------------------------------------
# stealFromPlayer()
# return: html
sub stealFromPlayer {
	my ($defenderReaction, $a, @data, $myClan, $html, $msg, %yourLocation, %theirLocation, %player, @item, $amount);
	$defenderReaction = health::getUnmodifiedAttribute($FORM{uid},'react');
	%yourLocation = gameMap::getLocationProperties($GLOBAL{'uid'});
	%theirLocation = gameMap::getLocationProperties($FORM{'uid'});
	%player = account::getPlayerProperties($FORM{'uid'});
	$html .= '<h1>Stealing From '.$player{'username'}.'</h1>';
	if ($yourLocation{'sectorId'} eq $theirLocation{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top">';
		$html .= 'Are you sure you want to steal from '.$player{'username'}.'?
				<p>
				<a href="game.pl?op=stealFromPlayer&uid='.$FORM{'uid'}.'&doit=yes">Yeah, I want it all!</a><br>
		';
		if ($FORM{'doit'} eq "yes") {
			$html .= '</td><td valign="top" width="50%">';
			$html .= "Stealing...<br>";
			unless (turns::isNewbie($FORM{'uid'})) {
				if (turns::spendTurns($GLOBAL{'uid'},5)) {
       	                         	$myClan = health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan");
                                	if (health::getUnmodifiedAttribute($FORM{'uid'},"clan") eq $myClan && $myClan ne "") {
                                        	($a) = sqlQuery("select uid from playerAttributes where class='attribute' and type='clan' and value='".$myClan."'");
                                        	while (@data = sqlArray($a)) {
                                                	messageLog::newMessage($data[0],"clan","alert",$GLOBAL{'username'}." stole from a clanmate ".$player{'username'}."!");
                 	                       	}
						sqlFinish($a);
                        	        }
	                                if (turns::isNewbie($GLOBAL{'uid'})) {
        	                                health::setAttribute($GLOBAL{'uid'},"turns spent", "1000");
                	                }
					@item = equipment::randomPlayerItem($FORM{'uid'});
					if (skills::useSkill($GLOBAL{'uid'},"hork") > skills::useSkill($FORM{'uid'},"senses") && $item[0] ne "") {
						$amount = rollDice(1,$item[1]);
						equipment::deleteItemFromUser($FORM{'uid'},$item[0],$amount);
						equipment::addItemToUser($GLOBAL{'uid'},$item[0],$amount);
						$html .= "You horked ".$amount." ".pluralize($item[2],$amount)." from ".$player{'username'}.".<br>";
						messageLog::newMessage($FORM{'uid'},"game","notice",$GLOBAL{'username'}." stole ".$amount." of your ".$item[2]."s!");
						health::modifyAttribute($GLOBAL{'uid'},"thefts",1);
					} else {
						messageLog::newMessage($FORM{'uid'},"game","notice",$GLOBAL{'username'}." attempted to steal from you, but failed.");
						$html .= $player{'username'}." has nothing to steal.<br>";
					}
					if ($defenderReaction eq "run") {
						$html .= $player{username}." has run away.<br>";
						runAway($FORM{uid});
					}
					if ($defenderReaction eq "fight") {
						$msg = $player{username}.' attacks '.$GLOBAL{username}.' in retaliation.<br>';
						@data = combat::fight($GLOBAL{'username'},skills::useSkill($GLOBAL{'uid'},"combat"),combat::getArmorRating($GLOBAL{'uid'}),$player{'username'},skills::useSkill($FORM{'uid'},"combat"),combat::getArmorRating($FORM{'uid'}));
                                        	$msg .= $data[0];
                                                messageLog::newMessage($GLOBAL{'uid'},"game","alert",$msg);
                                                messageLog::newMessage($FORM{'uid'},"game","alert",$msg);
						$html .= $msg;	
                                       		if ($data[1] > 0) {
                                                	health::modifyAttribute($GLOBAL{'uid'},"health",($data[1]*-1));
                                                	if (health::getAttribute($GLOBAL{'uid'},"health") <= 0) {
                                                        	$msg = $player{'username'}." killed ".$GLOBAL{'username'}.".<br>";
                                                        	messageLog::newMessage($GLOBAL{'uid'},"game","alert",$msg);
                                                        	messageLog::newMessage($FORM{'uid'},"game","alert",$msg);
                                                        	health::killCharacter($GLOBAL{'uid'},$player{'username'});
                                        	        }
                                        	} elsif ($data[2] > 0) {
                                                	health::modifyAttribute($FORM{'uid'},"health",($data[2]*-1));
                                                	if (health::getAttribute($FORM{'uid'},"health") <= 0) {
                                                        	$msg = $GLOBAL{'username'}." killed ".$player{'username'}.".<br>";
                                                        	messageLog::newMessage($GLOBAL{'uid'},"game","notice",$msg);
                                                        	messageLog::newMessage($FORM{'uid'},"game","alert",$msg);
                                                        	health::modifyAttribute($GLOBAL{'uid'},"murders",1);
                                                        	health::killCharacter($FORM{'uid'},$GLOBAL{'username'},1);
								$html .= $msg;	
                                                        }
						}
					}
					$html .= gameMap::processAffinity($FORM{'uid'},$theirLocation{'sectorId'});
				} else {
					$html .= 'You do not have enough turns to steal from '.$player{'username'}.'.<br>';
				}
			} else {
				$html .= "Sorry you can't steal from newbies.<br>";
			}
		}	
		$html .= "</td><tr></table>";
	} else {
		$html .= "How can you steal from a player who's not near you?<br>";
		messageLog::caughtCheating($GLOBAL{'uid'},"Tried to steal from a player who's not in the same sector as you.");
	}
	$html .= '<p><a href="game.pl?op=nearbyPlayer&uid='.$FORM{'uid'}.'">I want to do something else with this player.</a><p>';
	return $html;
}



1;

