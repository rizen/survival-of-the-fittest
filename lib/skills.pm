package skills;
use strict;

use equipment;
use health;
use messageLog;
use radiation;
use utility;

#------------------------------------
# addSkillPoint(userId, skillName, numSkillPoints)
# return: 
sub addSkillPoint {
	my ($a, $skillPoints);
	if ($_[2] eq "") {
		$skillPoints = 1;
	} else {
		$skillPoints = $_[2];
	}
	($a) = sqlQuery("update playerAttributes set value=value+$skillPoints where uid=".$_[0]." and class='skill points' and type='".$_[1]."'");
	sqlFinish($a);	
}

#------------------------------------
# getPureSkillLevel(userId, skillName)
# return: skillLevel
sub getPureSkillLevel {
	my ($a, $skillLevel, @data);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='skill' and type='".$_[1]."'");
	($skillLevel) = sqlArray($a);
	sqlFinish($a);
	return $skillLevel;
}

#------------------------------------
# getSkillLevel(userId, skillName, skipRequirements)
# return: skillLevel
sub getSkillLevel {
	my ($a, $skillLevel, @data, $drunk);
	($a) = sqlQuery("select sum(value) from playerAttributes where uid=".$_[0]." and (class='skill' or class='radiation') and type='".$_[1]."'");
	($skillLevel) = sqlArray($a);
	sqlFinish($a);
	if ($_[1] eq "combat") {
		($a) = sqlQuery("select itemAttributes.value,itemAttributes.itemId from playerAttributes,itemAttributes where playerAttributes.uid=".$_[0]." and playerAttributes.class='equipped' and playerAttributes.type='weapon' and playerAttributes.value=itemAttributes.itemId and itemAttributes.class='requirement' and itemAttributes.type='ammunition'");
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] ne "" && $_[2] ne "1") {
			if (equipment::deleteItemFromUser($_[0],$data[0],1)) {
				($a) = sqlQuery("select itemAttributes.value from playerAttributes,itemAttributes where playerAttributes.uid=".$_[0]." and playerAttributes.class='equipped' and playerAttributes.type='weapon' and playerAttributes.value=itemAttributes.itemId and itemAttributes.class='skill modifier' and itemAttributes.type='".$_[1]."'");
				@data = sqlArray($a);
				sqlFinish($a);
				$skillLevel += $data[0];
			} else {
				messageLog::newMessage($_[0],"game","alert","You're out of ammunition.");
			}
		} else {
			($a) = sqlQuery("select itemAttributes.value from playerAttributes,itemAttributes where playerAttributes.uid=".$_[0]." and playerAttributes.class='equipped' and playerAttributes.type='weapon' and playerAttributes.value=itemAttributes.itemId and itemAttributes.class='skill modifier' and itemAttributes.type='".$_[1]."'");
			@data = sqlArray($a);
			sqlFinish($a);
			$skillLevel += $data[0];
		}
		if ($_[2] ne "1") {
			equipment::breakItem($_[0],$data[1]);
		}
		($a) = sqlQuery("select sum(itemAttributes.value) from playerAttributes,itemAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=itemAttributes.itemId and itemAttributes.class='skill modifier' and itemAttributes.type='".$_[1]."' and itemAttributes.itemId=item.id and item.type<>'weapon'");
		@data = sqlArray($a);
		sqlFinish($a);
		$skillLevel += $data[0];
	} else {
		($a) = sqlQuery("select sum(itemAttributes.value) from playerAttributes,itemAttributes where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=itemAttributes.itemId and itemAttributes.class='skill modifier' and itemAttributes.type='".$_[1]."'");
		@data = sqlArray($a);
		sqlFinish($a);
		$skillLevel += $data[0];
	}
	$drunk = health::getAttribute($_[0],"drunk");
	if ($drunk > 0 && $_[2] != 1) {
		$skillLevel -= rollDice($drunk,6);
		health::modifyAttribute($_[0],"drunk",-1);
		messageLog::newMessage($_[0],"game","notice","*hic*");
	}	
	if ($skillLevel < 1) {
		$skillLevel = 1;
	}
	return $skillLevel;
}

#------------------------------------
# getSkillPoints(userId, skillName)
# return: skillPoints
sub getSkillPoints {
	my ($a, $skillPoints);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='skill points' and type='".$_[1]."'");
	($skillPoints) = sqlArray($a);
	sqlFinish($a);	
	return $skillPoints;
}

#------------------------------------
# repetitiveSuccessTest(userId, skill, successNumber, timesToRepeat)
# return: numberOfSuccesses
sub repetitiveSuccessTest {
	my ($i, $result);
	$result=0;
	for ($i=1;$i<=$_[3];$i++) {
		if (skills::useSkill($_[0],$_[1]) >= $_[2]) {
			$result++;
		}
	}
	return $result;
}

#------------------------------------
# upSkillLevel(userId, skillName)
# return: 
sub upSkillLevel {
	my ($a, $skillPoints, $nextLevel, $skillLevel);
	addSkillPoint($_[0],$_[1]);
	$skillPoints = getSkillPoints($_[0],$_[1]);
	$skillLevel = getPureSkillLevel($_[0],$_[1]);
	$nextLevel = ($skillLevel+1)*($skillLevel)*($skillLevel+2);
	if ($skillPoints >= $nextLevel) {
		($a) = sqlQuery("update playerAttributes set value=value-".$nextLevel." where uid=".$_[0]." and class='skill points' and type='".$_[1]."'");
		sqlFinish($a);	
		($a) = sqlQuery("update playerAttributes set value=value+1 where uid=".$_[0]." and class='skill' and type='".$_[1]."'");
		sqlFinish($a);	
		messageLog::newMessage($_[0],"game","advancement","You've gained a level in ".$_[1].".");
	}	
}

#------------------------------------
# useSkill(userId, skillName)
# return: rollResult
sub useSkill {
	my $skillRoll = rollDice(getSkillLevel($_[0],$_[1],0),6);
	upSkillLevel($_[0],$_[1]);
	radiation::rollRadiation($_[0]);
	return $skillRoll;
}


1;

