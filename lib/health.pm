package health;
# load default modules
use strict;

use account;
use equipment;
use utility;

#------------------------------------
# eat(userId)
# return: flag, ate or not
sub eat {
	my ($a, $nutritionalValue, $foodUsed, $flag);
	($nutritionalValue, $foodUsed) = equipment::useConsumable($_[0],"hunger",0);
	if ($nutritionalValue > 0) {
		($a) = sqlQuery("update playerAttributes set value=value-".$nutritionalValue." where uid=".$_[0]." and class='attribute' and type='hunger'");
		sqlFinish($a);
		messageLog::newMessage($_[0],"game","notice","You feel much better after eating.");
		$flag = 1;
	} else {
		$flag = 0;
	}
	return $flag;
}

#------------------------------------
# getAttribute(userId, attribute)
# return: attributeValue
sub getAttribute {
	my ($a, $result, $attributeValue);
	($a) = sqlQuery("select sum(value) from playerAttributes where uid=".$_[0]." and (class='attribute' or class='radiation') and type='".$_[1]."'");
	($attributeValue) = sqlArray($a);
	sqlFinish($a);
	($a) = sqlQuery("select sum(itemAttributes.value) from playerAttributes,itemAttributes where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=itemAttributes.itemId and itemAttributes.class='attribute modifier' and itemAttributes.type='".$_[1]."'");
	($result) = sqlArray($a);
	sqlFinish($a);
	$attributeValue += $result;
	return $attributeValue;
}

#------------------------------------
# getInjury(userId)
# return: woundPoints
sub getInjury {
	my ($a, $result, $health);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='attribute' and type='health'");
	($health) = sqlArray($a);
	sqlFinish($a);
	return (20-$health);
}

#------------------------------------
# getUnmodifiedAttribute(userId, option)
# return: attributeValue
sub getUnmodifiedAttribute {
        my ($a, $result, $attributeValue);
        ($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='attribute' and type='".$_[1]."'");
        ($attributeValue) = sqlArray($a);
        sqlFinish($a);
        return $attributeValue;
}

#------------------------------------
# killCharacter(userId, deathByWhat, notMe)
# return: 
sub killCharacter {
	my ($a, @data, $html, %location, %player);
	%player = account::getPlayerProperties($_[0]);
	%location = gameMap::getLocationProperties($_[0]);
	($a) = sqlQuery("select type,value from playerAttributes where uid=".$_[0]." and class='item'");
	while (@data = sqlArray($a)) {
		equipment::dropItem($_[0],$location{'sectorId'},$data[0],$data[1]);
	}
	sqlFinish($a);
	($a) = sqlQuery("insert into theDestroyed set name=".quote($player{'username'}).", turnsSpent=".getAttribute($_[0],"turns spent").", dateDied=now(), killedBy=".quote($_[1]));
	sqlFinish($a);
	($a) = sqlQuery("delete from playerAttributes where uid=".$_[0]." and class<>'pay to play'");
	sqlFinish($a);
	messageLog::newMessage($_[0],"game","alert","Your body has returned to deadEarth.");
	unless ($_[2]) {
		$html .= '
			<html>
			<head>
		    	<link href="/sotfGame.css" rel="stylesheet" type="text/css">
				<title>SotF :: You are dead!</title>
			</head>
			<body>
			<br>
			<br>
			<br>
			<table align="center"><tr><td>
			<h1>You are dead.</h1>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="game.pl">Continue &raquo;</a>
			</td></tr></table>
			</body></html>
		';
		print $html;
		exit;
	}
}

#------------------------------------
# modifyAttribute(userId, attribute, amount)
# return: 
sub modifyAttribute {
	my ($a);
	($a) = sqlQuery("update playerAttributes set value=value+".$_[2]." where uid=".$_[0]." and class='attribute' and type='".$_[1]."'");
	sqlFinish($a);
}

#------------------------------------
# processHunger(userId)
# return: 
sub processHunger {
	my ($hunger);
	modifyAttribute($_[0],"hunger",1);
	$hunger = getAttribute($_[0],"hunger");
	if ($hunger > 10) {
		unless (eat($_[0])) {
			messageLog::newMessage($_[0],"game","alert","You're starving!");
			modifyAttribute($_[0],"health",(10-$hunger));
			if (getAttribute($_[0],"health") < 1) {
				killCharacter($_[0],"starvation");
			}
		}
	}
}

#------------------------------------
# processPoison(userId)
# return: 
sub processPoison {
	my ($poison);
	$poison = getAttribute($_[0],"poison");
	if ($poison > 0) {
		$poison -= getAttribute($_[0],"immunity");
		if ($poison > 0) {
			messageLog::newMessage($_[0],"game","alert","You're dying from poisonous toxins in your blood!");
			modifyAttribute($_[0],"health",$poison*-1);
		}
		if (getAttribute($_[0],"health") < 1) {
			killCharacter($_[0],"toxins");
		}
	}
}

#------------------------------------
# setAttribute(userId, attribute, value)
# return: 
sub setAttribute {
	my ($a);
	($a) = sqlQuery("update playerAttributes set value=".$_[2]." where uid=".$_[0]." and class='attribute' and type='".$_[1]."'");
	sqlFinish($a);
}


1;

