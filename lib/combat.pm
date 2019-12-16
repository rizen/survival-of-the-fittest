package combat;
# load default modules
use strict;

use battlecry;
use utility;
use health;
use turns;
use skills;
use equipment;


#------------------------------------
# damageLanguage(damageAmount)
# return: language
sub damageLanguage {
	my $msg;
	if ($_[0] > 29) {	
		$msg = "summoned the god of war upon";
	} elsif ($_[0] > 27) {
		$msg = "struck with thunder upon";
	} elsif ($_[0] > 25) {
		$msg = "brought down the thunder upon";
	} elsif ($_[0] > 23) {
		$msg = "kicked a whole pile of ass on";
	} elsif ($_[0] > 21) {
		$msg = "opened a can of whoopass on";
	} elsif ($_[0] > 19) {
		$msg = "beset a crushing injury upon";
	} elsif ($_[0] > 17) {
		$msg = "delivered a serious blow to";
	} elsif ($_[0] > 15) {
		$msg = "pummeled";
	} elsif ($_[0] > 13) {
		$msg = "hammered";
	} elsif ($_[0] > 11) {
		$msg = "beat down";
	} elsif ($_[0] > 9) {
		$msg = "thrashed";
	} elsif ($_[0] > 7) {
		$msg = "slammed";
	} elsif ($_[0] > 5) {
		$msg = "gashed";
	} elsif ($_[0] > 3) {
		$msg = "damaged";
	} elsif ($_[0] > 2) {
		$msg = "wounded";
	} elsif ($_[0] > 1) {
		$msg = "injured";
	} else {
		$msg = "barely hit";
	}
}

#------------------------------------
# getAnimalProperties(animalId)
# return: animalHash
sub getAnimalProperties {
	my ($a, @data, %animal);
	($a) = sqlQuery("select name, meat, meatQuantity, pelt, poison, combat, hitPoints, armorRating, threshold, id from wildAnimal where id=".$_[0]);
	@data = sqlArray($a);
	sqlFinish($a);
	$animal{'name'} = $data[0];
	$animal{'meat'} = $data[1];
	$animal{'meat quantity'} = $data[2];
	$animal{'pelt'} = $data[3];
	$animal{'poison'} = $data[4];
	$animal{'combat'} = $data[5];
	$animal{'hit points'} = $data[6];
	$animal{'armor rating'} = $data[7];
	$animal{'threshold'} = $data[8];
	$animal{'id'} = $data[9];
	return %animal;
}

#------------------------------------
# getArmorRating(userId, don't break armor)
# return: armorRating
sub getArmorRating {
	my ($a, @data, $armorRating);
	($a) = sqlQuery("select sum(value) from playerAttributes where uid=".$_[0]." and (class='attribute' or class='radiation') and type='armor rating'");
	($armorRating) = sqlArray($a);
	sqlFinish($a);
	($a) = sqlQuery("select itemAttributes.value,itemAttributes.itemId from playerAttributes,itemAttributes where playerAttributes.uid=".$_[0]." and playerAttributes.class='equipped' and playerAttributes.type='armor' and playerAttributes.value=itemAttributes.itemId and itemAttributes.class='attribute modifier' and itemAttributes.type='armor rating'");
	@data = sqlArray($a);
	sqlFinish($a);
	$armorRating += $data[0];
	($a) = sqlQuery("select sum(itemAttributes.value) from playerAttributes,itemAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=itemAttributes.itemId and itemAttributes.class='attribute modifier' and itemAttributes.type='armor rating' and itemAttributes.itemId=item.id and item.type<>'armor'");
	@data = sqlArray($a);
	sqlFinish($a);
	$armorRating += $data[0];
	unless ($_[1] eq "1") {
		equipment::breakItem($_[0],$data[1]);
	}
	return $armorRating;
}

#------------------------------------
# fight(combatant1Name, combatant1CombatRoll, combatant1ArmorRating, combatant2Name, combatant2CombatRoll, combatant2ArmorRating)
# return: combatDescription, combatant1Injury,combatant2Injury
sub fight {
	my ($combatDescription, $combatant1Injuries, $combatant2Injuries);
	if ($_[1] > $_[4]) {
		$combatant2Injuries = $_[1]-$_[4];
		$combatDescription .= $_[0]." ".damageLanguage($combatant2Injuries)." ".$_[3];
		if ($_[5] >= $combatant2Injuries) {
			$combatant2Injuries = 0;
			$combatDescription .= ", but ".$_[3]."'s armor prevented injury.<br>";
		} elsif ($_[5] > 0) {
			$combatant2Injuries -= $_[5];
			$combatDescription .= ", but ".$_[3]."'s armor provided some protection against the injury.<br>";
		} elsif ($_[5] < 0) {
			$combatant2Injuries += $_[5];
			$combatDescription .= ", and ".$_[3]." sustained additional injuries due to frailty.<br>";
		} else {
			$combatDescription .= ".<br>";
		}
	} else {
		$combatant1Injuries = $_[4]-$_[1];
		$combatDescription .= $_[3]." ".damageLanguage($combatant1Injuries)." ".$_[0];
		if ($_[2] >= $combatant1Injuries) {
			$combatant1Injuries = 0;
			$combatDescription .= ", but ".$_[0]."'s armor prevented injury.<br>";
		} elsif ($_[2] > 0) {
			$combatant1Injuries -= $_[2];
			$combatDescription .= ", but ".$_[0]."'s armor provided some protection against the injury.<br>";
		} elsif ($_[2] < 0) {
			$combatant1Injuries += $_[2];
			$combatDescription .= ", and ".$_[0]." sustained additional injuries due to frailty.<br>";
		} else {
			$combatDescription .= ".<br>";
		}
	}
	return ($combatDescription, $combatant1Injuries, $combatant2Injuries);
}

#------------------------------------
# pickAnimal(threshold)
# return: animalHash
sub pickAnimal {
	my ($a, @data, %animal);
	($a) = sqlQuery("select id, name from wildAnimal where threshold>=".$_[0]." order by rand() limit 1");
	@data = sqlArray($a);
	sqlFinish($a);
	$animal{'id'} = $data[0];
	$animal{'name'} = $data[1];
	return %animal;
}



#------------------------------------
# attackAnimal()
# return: html
sub attackAnimal {
	my (@data, $html, $result, $pelts, $food, %animal, $i, $msg, $a);
	%animal = getAnimalProperties($FORM{'an'});
	if (turns::spendTurns($GLOBAL{'uid'},5)) {
		$html .= "Hunting...<br>";
		if (rollDice(1,100) > 60) {
			$html .= 'You shout, "'.battlecry::grunt().'"<br>';
		}
		$i = 0;
		while ($result == 0) {
			@data = combat::fight($GLOBAL{'username'},skills::useSkill($GLOBAL{'uid'},"combat"),getArmorRating($GLOBAL{'uid'}),"the ".$animal{'name'},rollDice($animal{'combat'},6),$animal{'armor rating'});
			$msg .= $data[0];
			$i++;
			if ($data[1] > 0) {
				health::modifyAttribute($GLOBAL{'uid'},"health",$data[1]*-1);
				if ($animal{'poison'} > 0) {
					health::modifyAttribute($GLOBAL{'uid'},"poison",$animal{'poison'});
					messageLog::newMessage($GLOBAL{'uid'},"game","alert","The animal struck with a poisonous attack.");
				}	
				if (health::getAttribute($GLOBAL{'uid'},"health") <= 0) {
					$msg .= "You've been killed by the ".$animal{'name'}.".<br>";
					messageLog::newMessage($GLOBAL{'uid'},"game","alert",$msg);
					health::killCharacter($GLOBAL{'uid'},aVSan($animal{'name'}));
					$result = 1;
				}
			} else {
				$animal{'hit points'} = $animal{'hit points'} - $data[2];
				if ($animal{'hit points'} <= 0) {
					$html .= $msg."You've killed the ".$animal{'name'}.".<br>";
					renown::addDeed($GLOBAL{'uid'},"wildAnimal",$FORM{'an'},1);
					$result = 1;
					$food = skills::repetitiveSuccessTest($GLOBAL{'uid'},"domestics",15,$animal{'meat quantity'});
					if ($food > 0) {
						($a) = sqlQuery("select name from item where id=".$animal{'meat'});
						@data = sqlArray($a);
						sqlFinish($a);
						equipment::addItemToUser($GLOBAL{'uid'},$animal{'meat'},$food);
						$html .= "You've prepared ".$food." ".pluralize($data[0],$food).".<br>";
					} else {
						$html .= "You were unable to prepare any food.<br>";
					}
					$pelts = skills::repetitiveSuccessTest($GLOBAL{'uid'},"domestics",30,1);
					if ($pelts > 0) {
						($a) = sqlQuery("select name from item where id=".$animal{'pelt'});
						@data = sqlArray($a);
						sqlFinish($a);
						equipment::addItemToUser($GLOBAL{'uid'},$animal{'pelt'},$pelts);
						$html .= "You've prepared ".$pelts." ".pluralize($data[0],$pelts).".<br>";
					} else {
						$html .= "You were unable to prepare any pelts.<br>";
					}
				}
			} 
			if ($i > 3 && $result < 1) {
				$result = 1;
				$html .= $msg.'You were unable to kill the '.$animal{'name'}.'.<br>';
			}
		}
	} else {
		$html .= 'You do not have enough turns to hunt that long.';
	}
	return $html;
}


1;


