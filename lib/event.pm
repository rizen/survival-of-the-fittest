package event;
# load default modules
use strict;

use combat;
use equipment;
use gameMap;
use health;
use messageLog;
use radiation;
use utility;

#------------------------------------
# animalAttack(uid)
# return: 
sub animalAttack {
	my ($a, @data, $combatResolved, $pelts, $food, %animal, $i, $msg);
	($a) = sqlQuery("select id from wildAnimal order by rand() limit 1");	@data = sqlArray($a);	sqlFinish($a);
	%animal = combat::getAnimalProperties($data[0]);
	$i = 0;
	$combatResolved = 0;
	while ($combatResolved == 0) {
		@data = combat::fight($GLOBAL{'username'},skills::useSkill($_[0],"combat"),combat::getArmorRating($_[0]),"the ".$animal{'name'},rollDice($animal{'combat'},6),$animal{'armor rating'});
		$msg .= $data[0];
		$i++;
		if ($data[1] > 0) {
			health::modifyAttribute($_[0],"health",$data[1]*-1);
			health::modifyAttribute($_[0],"poison",$animal{'poison'});
			messageLog::newMessage($_[0],"game","alert","The animal struck with a poisonous attack.");
			if (health::getAttribute($_[0],"health") <= 0) {
				$msg .= "You've been killed by the ".$animal{'name'}.".<br>";
				messageLog::newMessage($_[0],"game","event",$msg);
				health::killCharacter($_[0],aVSan($animal{'name'})." attack");
				$combatResolved = 1;
			}
		} else {
			$animal{'hit points'} = $animal{'hit points'} - $data[2];
			if ($animal{'hit points'} <= 0) {
				$msg .= "You've killed the ".$animal{'name'}.".<br>";
				renown::addDeed($GLOBAL{'uid'},"wildAnimal",$animal{id},1);
				$combatResolved = 1;
				$food = skills::repetitiveSuccessTest($_[0],"domestics",15,$animal{'meat quantity'});
				if ($food > 0) {
					($a) = sqlQuery("select name from item where id=".$animal{'meat'});
					@data = sqlArray($a);
					sqlFinish($a);
					equipment::addItemToUser($_[0],$animal{'meat'},$food);
					$msg .= "You you've prepared ".$food." ".pluralize($data[0],$food).".<br>";
				} else {
					$msg .= "You were unable to prepare any food.<br>";
				}
				$pelts = skills::repetitiveSuccessTest($_[0],"domestics",30,1);
				if ($pelts > 0) {
					($a) = sqlQuery("select name from item where id=".$animal{'pelt'});
					@data = sqlArray($a);
					sqlFinish($a);
					equipment::addItemToUser($_[0],$animal{'pelt'},$pelts);
					$msg .= "You you've prepared ".$pelts." ".pluralize($data[0],$pelts).".<br>";
				} else {
					$msg .= "You were unable to prepare any pelts.<br>";
				}
			}
		} 
		if ($i > 3 && $combatResolved < 1) {
			$msg .= "The animal has retreated its attack.<br>";
			$combatResolved = 1;
		}
	}
	messageLog::newMessage($_[0],"game","event",$msg);
}

#------------------------------------
# event(uid)
# return: 
sub event {
	my (%location, $randomNumber);
	#$randomNumber = 16;
	$randomNumber = rollDice(1,1000);
	%location = gameMap::getLocationProperties($_[0]);
	if ($randomNumber == 1) {
		spoilFood($_[0]);
	} elsif ($randomNumber == 2) {
		misplaceItem($_[0]);
	} elsif ($randomNumber == 3) {
		thief($_[0]);
	} elsif ($randomNumber == 4) {
		massiveRad($_[0]);
	} elsif ($randomNumber == 5) {
		normal($_[0]);
	} elsif ($randomNumber == 6 && $location{'class'} eq "civilization") {
		victim($_[0]);
	} elsif ($randomNumber == 7) {
		radRelief($_[0]);
	} elsif ($randomNumber == 8 && $location{'class'} eq "wilderness") {
		animalAttack($_[0]);
	} elsif ($randomNumber == 9 && $location{'class'} eq "civilization") {
		thugAttack($_[0]);
	} elsif ($randomNumber == 10 && $location{'class'} eq "civilization") {
		mugging($_[0]);
	} elsif ($randomNumber == 11) {
		strayPet($_[0]);
	} elsif ($randomNumber == 12 && $location{'class'} eq "wilderness") {
		mushroomField($_[0]);
	} elsif ($randomNumber == 13 && $location{'class'} eq "wilderness") {
		trip($_[0]);
	} elsif ($randomNumber == 14 && $location{'class'} eq "wilderness") {
		findBody($_[0]);
	} elsif ($randomNumber == 15 && $location{'class'} eq "wilderness") {
		quicksand($_[0]);
	} elsif ($randomNumber == 16) {
		runAway($_[0]);
	} elsif ($randomNumber == 17 && $location{'class'} eq "civilization") {
		lynchMob($_[0]);
	} elsif ($randomNumber == 18 && $location{'class'} eq "civilization") {
		travelingSalesman($_[0]);
	}
}

#------------------------------------
# findBody(uid)
# return: 
sub findBody {
	my (@item);
	@item = equipment::randomItem(1,3000);
	messageLog::newMessage($_[0],"game","event","You discover a body in some weeds. From the smell you think it's been there a while. You take one ".$item[1]." from the body.");
	equipment::addItemToUser($_[0],$item[0],1);
}

#------------------------------------
# lynchMob(uid)
# return:
sub lynchMob {
       	if (health::getAttribute($_[0],"murders") > 1) {
		messageLog::newMessage($_[0],"game","alert","A lynch mob has finally tracked you down and brought justice for your victims. You were executed on sight."); 
		health::killCharacter($_[0],"a lynch mob");
	}
}

#------------------------------------
# massiveRad(uid)
# return: 
sub massiveRad {
	my ($a, @affect, $amount);
	@affect = ('haggle','beast lore','troubadour','combat','navigate','first aid','senses','hork','stealth','tracking','domestics','hunger','health','shielding','armor rating','immunity');
	$amount = rollDice(3,3);		
	if (rollDice(1,2) == 2) {
		$amount = $amount*-1;
	}
	($a) = sqlQuery("insert into playerAttributes set uid=".$_[0].", class='radiation', type='".$affect[rollDice(1,($#affect+1))-1]."', value='".$amount."'");
	sqlFinish($a);
	messageLog::newMessage($_[0],"game","radiation","You notice an erie green glow around you.");
	if (health::getAttribute($_[0],"health") <= 0) {
		messageLog::newMessage($_[0],"game","alert","Radiation killed you.");
		health::killCharacter($_[0],"radiation");
	}
}

#------------------------------------
# misplaceItem(uid)
# return: 
sub misplaceItem {
	my ($msg, $a, @data, $amount, $sectorId, @previous, @item);
	@item = equipment::randomPlayerItem($_[0]);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='location' and type='past' order by id desc limit 3");
	@data = sqlArray($a);
	$previous[0] = $data[0];
	@data = sqlArray($a);
	if ($data[0] ne "") {
		$previous[1] = $data[0];
		@data = sqlArray($a);
		if ($data[0] ne "") {
			$previous[2] = $data[0];
		}	
	}
	sqlFinish($a);
	if ($item[0] ne "" && $previous[0] ne "") {
		$amount = rollDice(1,$item[1]);
		equipment::deleteItemFromUser($_[0],$item[0],$amount);
		$msg = "You just realized that you left ".$amount." of your ".$item[2]."s somewhere, but where.";
		messageLog::newMessage($_[0],"game","event",$msg);
		equipment::addItemToSector($previous[rollDice(1,($#previous+1))-1],$item[0],$amount,rollDice(5,6));
	}
}

#------------------------------------
# mugging(uid)
# return: 
sub mugging {
	my ($a, @data, $msg, $thugHP);
	$msg .= "You've been attacked from behind by a mugger.<br>";
	$thugHP = 20;
	@data = combat::fight($GLOBAL{'username'},skills::useSkill($_[0],"combat"),combat::getArmorRating($_[0]),"the mugger",rollDice(skills::getSkillLevel($_[0],"combat",1),7),rollDice(1,7)-3);
	$msg .= $data[0];
	if ($data[1] > 0) {
		health::modifyAttribute($_[0],"health",$data[1]*-1);
		if (health::getAttribute($_[0],"health") <= 0) {
			$msg .= "You've been killed by the mugger.<br>";
			messageLog::newMessage($_[0],"game","event",$msg);
			health::killCharacter($_[0],"a mugger");
		} else {
			@data = equipment::randomPlayerItem($_[0]);
			if ($data[0] eq "") {
				$msg .= "The mugger has knocked you down, but found nothing to take, so ran off.";
			} else {
				$msg .= "The mugger has knocked you down and taken ".$data[1]." ".$data[2]."s from you.";
				equipment::deleteItemFromUser($_[0],$data[0],$data[1]);
				equipment::addItemToSector(rollDice(1,1600),$data[0],$data[1]);
			}
		}
	} else {
		$thugHP -= $data[2];
		if ($thugHP <= 0) {
			renown::addDeed($GLOBAL{'uid'},"event","a thug attack",1);
			$msg .= "You've killed the mugger.<br>";
			@data = equipment::randomItem(1,1000);
			equipment::addItemToUser($_[0],$data[0],1);
			$msg .= "You've taken one ".$data[1]." from the mugger's body.<br>";
		} else {
			renown::addDeed($GLOBAL{'uid'},"event","a thug attack",1);
			$msg .= "You've run the mugger off. He won't be bothering you anytime soon.<br>";
		}
	} 
	messageLog::newMessage($_[0],"game","event",$msg);
}

#------------------------------------
# mushroomField(uid)
# return: 
sub mushroomField {
	messageLog::newMessage($_[0],"game","event","As you look around you see that you're in a mushroom field with pink elephants.");
	health::modifyAttribute($_[0],"drunk",rollDice(5,5));
}

#------------------------------------
# normal(uid)
# return: 
sub normal {
	my ($a);
	($a) = sqlQuery("delete from playerAttributes where uid=".$_[0]." and class='radiation'"); sqlFinish($a);
	messageLog::newMessage($_[0],"game","event","You feel the pain of 100 deaths as you fall to the ground motionless. When you wake up you feel a lot better.");
	health::modifyAttribute($_[0],"turns spent",50);
	health::modifyAttribute($_[0],"health",-5);
	if (health::getAttribute($_[0],"health") <= 0) {
		messageLog::newMessage($_[0],"game","alert","Radiation killed you.");
		health::killCharacter($_[0],"radiation");
	}
}

#------------------------------------
# quicksand(uid)
# return: 
sub quicksand {
	my (@item, $msg);
	$msg = "Wouldn't you know it. You've stepped in a pool of quicksand. ";
	@item = equipment::randomPlayerItem($_[0]);
	if (skills::useSkill($_[0],"senses") < 10) {
		$msg .= "You weren't able to keep your thoughts straight and you fell victim to the quicksand.";
		messageLog::newMessage($_[0],"game","alert",$msg);
		health::killCharacter($_[0],"quicksand");
	} else {
		$msg .= "You kept your wits about you and found a branch to pull yourself out.";
		if ($item[0] ne "") {
			equipment::deleteItemFromUser($_[0],$item[0],$item[1]);
			equipment::addItemToSector(rollDice(1,1600),$item[0],$item[1],rollDice(6,6));
			$msg .= " However, you lost all of your ".pluralize($item[2],2).".";
		}
		messageLog::newMessage($_[0],"game","event",$msg);
	}	
}

#------------------------------------
# radRelief(uid)
# return: 
sub radRelief {
	my ($a);
	($a) = sqlQuery("delete from playerAttributes where uid=".$_[0]." and class='radiation' limit 1"); sqlFinish($a);
	messageLog::newMessage($_[0],"game","event","You feel a little strange, but somehow more normal.");
	if (health::getAttribute($_[0],"health") <= 0) {
		messageLog::newMessage($_[0],"game","alert","Radiation killed you.");
		health::killCharacter($_[0],"radiation");
	}
}

#------------------------------------
# runAway(uid)
# return:
sub runAway {
        my ($a, @data, $animalId);
	$animalId = equipment::searchForItemType($_[0],"animal");
	if ($animalId ne "") {
        	($a) = sqlQuery("select name from item where id=".$animalId);
        	@data = sqlArray($a);
        	sqlFinish($a);
        	equipment::deleteItemFromUser($_[0],$animalId,1);
        	messageLog::newMessage($_[0],"game","event","Your ".$data[0]." has run away.");
	}
}

#------------------------------------
# spoilFood(uid)
# return: 
sub spoilFood {
	my ($msg, $a, @data, $amount);
	($a) = sqlQuery("select item.id, playerAttributes.value, item.name from playerAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type='food' and item.id<>2 order by rand() limit 1");
	@data = sqlArray($a);
	sqlFinish($a);
	$amount = rollDice(1,$data[1]);
	if ($amount > 0 && $data[0] ne "") {
		equipment::deleteItemFromUser($_[0],$data[0],$amount);
		$msg = $amount." of your ".pluralize($data[2],2)." spoiled.";
		messageLog::newMessage($_[0],"game","event",$msg);
	}
}

#------------------------------------
# strayPet(uid)
# return: 
sub strayPet {
	my ($a, @data);
	($a) = sqlQuery("select id,name from item where type='animal' order by rand() limit 1");
	@data = sqlArray($a);
	sqlFinish($a);
	equipment::addItemToUser($_[0],$data[0],1);
	messageLog::newMessage($_[0],"game","event","A tired and dirty ".$data[1]." has decided that you are its new owner.");
}

#------------------------------------
# thief(uid)
# return: 
sub thief {
	my ($msg, $a, @data, $amount);
	@data = equipment::randomPlayerItem($_[0]);
	if ($data[0] ne "") {
		$amount = rollDice(1,$data[1]);
		equipment::deleteItemFromUser($_[0],$data[0],$amount);
		equipment::addItemToSector(rollDice(1,1600),$data[0],$amount,rollDice(5,6));
		$msg = "A thief stole ".$amount." of your ".pluralize($data[2],2)." while you were asleep.";
		messageLog::newMessage($_[0],"game","event",$msg);
	}	
}

#------------------------------------
# thugAttack(uid)
# return: 
sub thugAttack {
	my ($a, @data, $combatResolved, $i, $msg, $thugHP);
	$thugHP = 20;
	$i = 0;
	$combatResolved = 0;
	while ($combatResolved == 0) {
		@data = combat::fight($GLOBAL{'username'},skills::useSkill($_[0],"combat"),combat::getArmorRating($_[0]),"the thug",rollDice(rollDice(4,4),6),rollDice(1,7)-3);
		$msg .= $data[0];
		$i++;
		if ($data[1] > 0) {
			health::modifyAttribute($_[0],"health",$data[1]*-1);
			if (health::getAttribute($_[0],"health") <= 0) {
				$msg .= "You've been killed by the thug.<br>";
				messageLog::newMessage($_[0],"game","event",$msg);
				health::killCharacter($_[0],"a thug");
				$combatResolved = 1;
			}
		} else {
			$thugHP -= $data[2];
			renown::addDeed($GLOBAL{'uid'},"event","a thug attack",1);
			if ($thugHP <= 0) {
				$msg .= "You've killed the thug.<br>";
				$combatResolved = 1;
				@data = equipment::randomItem(1,1000);
				equipment::addItemToUser($_[0],$data[0],1);
				$msg .= "You've taken one ".$data[1]." from the thug's body.<br>";
			}
		} 
		if ($i > 3 && $combatResolved < 1) {
			renown::addDeed($GLOBAL{'uid'},"event","a thug attack",1);
			$msg .= "You've run the thug off.<br>";
			$combatResolved = 1;
		}
	}
	messageLog::newMessage($_[0],"game","event",$msg);
}

#------------------------------------
# travelingSalesman(uid)
# return: 
sub travelingSalesman {
	my (@item, $msg, $a, @data, $spent, $didFirst);
	$msg = 'A man runs up to you and says, "I\'ve got something for you." ';
	@item = equipment::randomItem(5,5000);
	if (skills::useSkill($_[0],"haggle") < 25) {
		$msg .= "Before you know it he's taken all of your ";
		($a) = sqlQuery("select item.id, item.name, item.cost, playerAttributes.value from playerAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=item.id order by item.cost desc");
		while(@data = sqlArray($a)) {
			unless ($spent >= 2*$item[2]) {
				$spent += $data[2]*$data[3];
				equipment::deleteItemFromUser($_[0],$data[0],$data[3]);
				equipment::addItemToSector(rollDice(1,1600),$data[0],$data[3],rollDice(5,5));
				if ($didFirst == 0) {
					$didFirst = 1;
					$msg .= " ".$data[1]."s";
				} else {
					$msg .= " and all of your ".$data[1]."s";
				}
			}
		}
		sqlFinish($a);
		$msg .= " in exchange for this ".$item[1].".";
		equipment::addItemToUser($_[0],$item[0],1);
	} else {
		$msg .= "Luckily you have a great knack for negotiation and realize he's trying to swindle you. You walk away.";
	}	
	messageLog::newMessage($_[0],"game","event",$msg);
}

#------------------------------------
# trip(uid)
# return: 
sub trip {
	my ($a);
	messageLog::newMessage($_[0],"game","event","You tripped, stumbled, and hit your head on a rock.");
	health::modifyAttribute($_[0],"health",rollDice(1,5)*-1);
	if (health::getAttribute($_[0],"health") <= 0) {
		messageLog::newMessage($_[0],"game","alert","The bump on the head killed you.");
		health::killCharacter($_[0],"a nasty fall");
	}
}

#------------------------------------
# victim(uid)
# return: 
sub victim {
	my ($msg, $a, @data, %location, $randomNumber);
	($a) = sqlQuery("select player.uid,player.username from playerAttributes left join player on (playerAttributes.uid=player.uid) where playerAttributes.class='location' and playerAttributes.type='current' and player.uid<>".$_[0]." order by rand() limit 1");
	@data = sqlArray($a);
	sqlFinish($a);
	%location = gameMap::getLocationProperties($data[0]);
	$randomNumber = rollDice(1,4);
	if ($randomNumber == 1) {
		$msg = 'A woman comes running up to you in the street crying and says, "'.$data[1].'" raped and beat me, and left me to die. You can find '.$data[1].' in ('.$location{'x'}.'-'.$location{'y'}.')';
	} elsif ($randomNumber == 2) {
		$msg = 'You bump into a man who says, "'.$data[1].'" beat me at a game of cards and took everything I owned. You can find '.$data[1].' in ('.$location{'x'}.'-'.$location{'y'}.')';
	} elsif ($randomNumber == 3) {
		$msg = 'A broken down old man walks up to you and says, "'.$data[1].'" attacked me on my way into town and took all my money. Will you get my stuff back for me? You can find '.$data[1].' in ('.$location{'x'}.'-'.$location{'y'}.')';
	} else {
		$msg = 'You overhear a rumor that the town sheriff is putting up a reward for '.$data[1].'\'s head. '.$data[1].'\'s last known location was in ('.$location{'x'}.'-'.$location{'y'}.')';
	}	
	if ($location{'class'} eq "civilization") {
		$msg .= ", a ".$location{'type'}." named ".$location{'name'};
	}
	$msg .= '."';
	messageLog::newMessage($_[0],"game","event",$msg);
}



1;

