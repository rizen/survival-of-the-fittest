package gameMap;
# load default modules
use strict;

use health;
use messageLog;
use utility;

#------------------------------------
# findDistanceAndDirection (x1,y1,x2,y2)
# return: distance, direction
sub findDistanceAndDirection {
        my ($distance, $direction, $vertical, $horizontal, $x, $y);
        $x = stringEvaluate($_[0])-stringEvaluate($_[2]);
        $y = $_[1]-$_[3];
        $distance = round(sqrt(abs($x*$x)+abs($y*$y)));
        if ($y < 0) {
                $vertical = "north";
        } elsif ($y > 0) {
                $vertical = "south";
        }
        if ($x < 0) {
                $horizontal = "west";
        } elsif ($x > 0) {
                $horizontal = "east";
        }
        if ($horizontal ne "" && $vertical ne "") {
                $direction = $vertical."-".$horizontal;
        } else {
                $direction = $vertical.$horizontal;
        }
        return $distance,$direction;
}

#------------------------------------
# getAmenityProperties(amenityId)
# return: amenityHash
sub getAmenityProperties {
	my ($a, %amenity, @data);
	($a) = sqlQuery("select sectorId,type,value from mapAttributes where id=".$_[0]);
	@data = sqlArray($a);
	sqlFinish($a);
	$amenity{'sectorId'} = $data[0];
	$amenity{'type'} = $data[1];
	$amenity{'name'} = $data[2];
	($a) = sqlQuery("select type,value from amenityAttributes where amenityId=".$_[0]." and class='item'");
	while (@data = sqlArray($a)) {
		if ($data[0] eq "1") {
			$amenity{'funds'} = $data[1];
		} else {
			$amenity{'item'}{$data[0]} = $data[1];
		}
	}
	sqlFinish($a);
	return %amenity;
}

#------------------------------------
# getLocationProperties(userId)
# return: locationHash
sub getLocationProperties {
	my ($a, %location, @data);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='location' and type='current'");
	@data = sqlArray($a);
	sqlFinish($a);
	$location{'sectorId'} = $data[0];
	($a) = sqlQuery("select name,type,x,y from map where id='".$location{'sectorId'}."'");
	@data = sqlArray($a);
	sqlFinish($a);
	$location{'name'} = $data[0];
	$location{'class'} = $data[1];
	$location{'x'} = $data[2];
	$location{'y'} = $data[3];
	($a) = sqlQuery("select class,type,value from mapAttributes where sectorId='".$location{'sectorId'}."'");
	while (@data = sqlArray($a)) {
		if ($data[0] eq "description") {
			$location{'description'} = $data[2];
			$location{'type'} = $data[1];
		} elsif ($data[0] eq "modifier") {
			$location{$data[1]} = $data[2];
		}
	}
	sqlFinish($a);
	return %location;
}

#------------------------------------
# isInJail(userId)
# return: flag, yes/no
sub isInJail {
	my ($a, @data, $flag);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='jail'");
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] == 1) {
		$flag = 1;
	} else {
		$flag = 0;
	}
	return $flag;
}

#------------------------------------
# listAmenities(sectorId)
# return: html
sub listAmenities {
	my ($a, $html, @data);
	($a) = sqlQuery("select type,value,id from mapAttributes where sectorId=".$_[0]." and class='amenity' order by value");
	while (@data = sqlArray($a)) {
		$html .= '&nbsp;&nbsp;<a href="game.pl?op=amenityMenu&ai='.$data[2].'" title="'.$data[0].'">'.$data[1].'</a><br>';
	}
	sqlFinish($a);
	return $html;
}

#------------------------------------
# mapArea()
# return: html
sub mapArea {
	my ($a, @data, $html, $name, $yLabels);
	$yLabels = "<table border=0 cellpadding=0 cellspacing=0 class=\"mapCoords\" width=510 align=center><tr><td width=15></td>";
	($a) = sqlQuery("select x from map where y='1' order by x");
  	while (@data = sqlArray($a)) {
		$yLabels .= "<td>".$data[0]."</td>";
	}
	sqlFinish($a);
	$yLabels .= "<td width=15></td></tr></table>";
	$html .= $yLabels."<table border=0 cellpadding=0 cellspacing=0 class=\"mapCoords\" align=center>";
	($a) = sqlQuery("select map.x,map.y,map.type,map.name,mapAttributes.type from map,mapAttributes where map.id=mapAttributes.sectorId and mapAttributes.class='description' order by y,x");
 	while (@data = sqlArray($a)) {
		$data[4] =~ s/ //g;
		if ($data[0] eq "AA") {
			$html .= "<tr><td>".$data[1]."</td><td>";
		}	
		if ($data[2] eq "civilization") {
			$name = $data[3];
		} else {
			$name = "";	
		}	
		$html .= "<img src=\"/m/".$data[4].".gif\" alt=\"".$name." ".$data[0]."-".$data[1]."\">";
		if ($data[0] eq "BN") {
			$html .= "</td><td>".$data[1]."</td></tr>";
			#$html .= "<br>";
		}	
   	}  
	sqlFinish($a);
	$html .= "</table>".$yLabels;
	return $html;
}

#------------------------------------
# mapCartography()
# return: html
sub mapCartography {
	my ($a, @data, $html, $temp, $beenThere, $hereNow, $navigate);
	$navigate = skills::useSkill($_[0],"navigate");
	$html .= "\n".'<table border=0 cellpadding=20 cellspacing=0 width=500 background="/sotfGame/cartography.jpg" align="center"><tr><td>'."\n";
	($a) = sqlQuery("select value,type from playerAttributes where uid=".$_[0]." and class='location'");
	$beenThere = ":";
	while (@data = sqlArray($a)) {
		if ($data[1] eq "current") {
			$hereNow = $data[0];
		}
		$beenThere .= $data[0].":";
	}
	sqlFinish($a);
	($a) = sqlQuery("select x,y,type,name,id from map order by y,x");
	while (@data = sqlArray($a)) {
		$temp = ":".$data[4].":";
		if ($beenThere =~ /$temp/ && $navigate > 20) {
			if ($data[4] == $hereNow) {
				$html .= "<img src=\"/o.gif\" alt=\"".$data[3]." ".$data[0]."-".$data[1]."\">";
			} elsif ($data[2] eq "civilization") {
				$html .= "<img src=\"/x.gif\" alt=\"".$data[3]." ".$data[0]."-".$data[1]."\">";
			} else {
				$html .= "<img src=\"/cd.gif\">";
			}	
		} else {
				$html .= "<img src=\"/s.gif\">";
		}
		if ($data[0] eq "BN") {
			$html .= "<br>\n";
		}	
  	}  
	sqlFinish($a);
	$html .= "</td></tr></table>\n";
	$html .= "<p><b>Note:</b> If you don't see anything on your map, that means you aren't very good at cartography yet. Raise your navigate skill and try again.";
	return $html;
}

#------------------------------------
# mapHunting()
# return: html
sub mapHunting {
	my ($a, @data, $html, $yLabels);
	$yLabels = "<table border=0 cellpadding=0 cellspacing=0 class=\"mapCoords\" width=510 align=center><tr><td width=15></td>";
	($a) = sqlQuery("select x from map where y='1' order by x");
  	while (@data = sqlArray($a)) {
		$yLabels .= "<td>".$data[0]."</td>";
	}
	sqlFinish($a);
	$yLabels .= "<td width=15></td></tr></table>";
	$html .= $yLabels."<table border=0 cellpadding=0 cellspacing=0 class=\"mapCoords\" align=center>";
	($a) = sqlQuery("select map.x,map.y,mapAttributes.value from map,mapAttributes where map.id=mapAttributes.sectorId and mapAttributes.type='hunting difficulty' order by y,x");
 	while (@data = sqlArray($a)) {
		if ($data[0] eq "AA") {
			$html .= "<tr><td>".$data[1]."</td><td>";
		}
		if ($data[2] < 15) {	
			$html .= "<img src=\"/m/1.gif\" alt=\"".$data[0]."-".$data[1]."\">";
		} elsif ($data[2] < 30) {	
			$html .= "<img src=\"/m/2.gif\" alt=\"".$data[0]."-".$data[1]."\">";
		} elsif ($data[2] < 45) {	
			$html .= "<img src=\"/m/3.gif\" alt=\"".$data[0]."-".$data[1]."\">";
		} elsif ($data[2] < 60) {	
			$html .= "<img src=\"/m/4.gif\" alt=\"".$data[0]."-".$data[1]."\">";
		} else {	
			$html .= "<img src=\"/m/5.gif\" alt=\"".$data[0]."-".$data[1]."\">";
		}	
		if ($data[0] eq "BN") {
			$html .= "</td><td>".$data[1]."</td></tr>";
		}	
   	}  
	sqlFinish($a);
	$html .= "</table>".$yLabels;
	return $html;
}

#------------------------------------
# mapScavenging()
# return: html
sub mapScavenging {
	my ($a, @data, $html, $yLabels);
	$yLabels = "<table border=0 cellpadding=0 cellspacing=0 class=\"mapCoords\" width=510 align=center><tr><td width=15></td>";
	($a) = sqlQuery("select x from map where y='1' order by x");
  	while (@data = sqlArray($a)) {
		$yLabels .= "<td>".$data[0]."</td>";
	}
	sqlFinish($a);
	$yLabels .= "<td width=15></td></tr></table>";
	$html .= $yLabels."<table border=0 cellpadding=0 cellspacing=0 class=\"mapCoords\" align=center>";
	($a) = sqlQuery("select map.x,map.y,map.type,map.name,mapAttributes.value,mapAttributes.type from map,mapAttributes where map.id=mapAttributes.sectorId and mapAttributes.class='description' order by y,x");
 	while (@data = sqlArray($a)) {
		$data[4] =~ s/ //g;
		$data[4] = substr($data[4],0,5);
		if ($data[0] eq "AA") {
			$html .= "<tr><td>".$data[1]."</td><td>";
		}
		if ($data[5] eq "ruins") {	
			$html .= "<img src=\"/m/".$data[4].".gif\" alt=\"".$data[0]."-".$data[1]."\">";
		} else {	
			$html .= "<img src=\"/m/wilderness.gif\" alt=\"".$data[0]."-".$data[1]."\">";
		}	
		if ($data[0] eq "BN") {
			$html .= "</td><td>".$data[1]."</td></tr>";
		}	
   	}  
	sqlFinish($a);
	$html .= "</table>".$yLabels;
	return $html;
}

#------------------------------------
# processAffinity(userid, sectorId)
# return: html
sub processAffinity {
	my ($a, @data, @affinity, $html, $is);
	($a) = sqlQuery("select type,value from mapAttributes where sectorId=".$_[1]." and class='affinity'");
	@affinity = sqlArray($a);
	sqlFinish($a);
	if ($affinity[0] eq "murderers") {
		if (health::getAttribute($_[0],"murders") > 1) {
			$is = 1;
		}
	} elsif ($affinity[0] eq "thieves") {
		if (health::getAttribute($_[0],"thefts") > 4 && health::getUnmodifiedAttribute($_[0],"clan") ne "Famiglia di Santione") {
			$is = 1;
		}
	} elsif ($affinity[0] eq "gunslingers") {
		($a) = sqlQuery("select count(*) from playerAttributes where uid=".$_[0]." and class='item' and type in (20,37,69,70)");
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] > 0 && health::getUnmodifiedAttribute($_[0],"clan") ne "The Wraiths") {
			$is = 1;
		}
	} elsif ($affinity[0] eq "mutants") {
		($a) = sqlQuery("select count(*) from playerAttributes where uid=".$_[0]." and class='radiation'");
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] > 10 && health::getUnmodifiedAttribute($_[0],"clan") ne "Godsbane") {
			$is = 1;
		}
	}
	if ($is && $affinity[1] eq "kill") {
		$html .= "<i>We don't tolerate ".$affinity[0]." here.<br>";
		$html .= "May the soulkeeper have mercy on you.</i><br>";
		messageLog::newMessage($_[0],"game","alert",$html);
		health::killCharacter($_[0],"affinity");
	} elsif ($is && $affinity[1] eq "warn") {
		$html .= "<i>We don't take too kindly to ".$affinity[0]." here.<br>";
		$html .= "Leave!</i><br>";
	} elsif ($is && $affinity[1] eq "maime") {
		$html .= "<i>We don't tolerate ".$affinity[0]." here.<br>";
		$html .= "You're lucky we didn't kill you.<br>";
		$html .= "Now get out!</i><br>";
		$data[0] = health::getAttribute($_[0],"health");
		health::modifyAttribute($_[0],"health",($data[0]-3)*-1);
		if (health::getAttribute($_[0],"health") <= 0) {
			messageLog::newMessage($_[0],"game","alert","The wounds from being beaten result in your death.");
			health::killCharacter($_[0],"affinity");
		}
	} elsif ($is && $affinity[1] eq "jail") {
		$html .= "<i>We don't tolerate ".$affinity[0]." here.</i><br>";
		$html .= "You have been jailed. (For approximately 10 minutes.)<br>";
		($a) = sqlQuery("insert into playerAttributes set uid=".$_[0].", class='jail', value=1");
		sqlFinish($a);
		health::setAttribute($_[0],"stealth rating",999);
	} elsif ($is && $affinity[1] eq "jail and maime") {
		$html .= "<i>We don't tolerate ".$affinity[0]." here.</i><br>";
		$html .= "You have been jailed (for approximately 10 minutes) and beaten to within an inch of your life. <br>";
		($a) = sqlQuery("insert into playerAttributes set uid=".$_[0].", class='jail', value=1");
		sqlFinish($a);
		$data[0] = health::getAttribute($_[0],"health");
		health::setAttribute($_[0],"stealth rating",999);
		health::modifyAttribute($_[0],"health",($data[0]-3)*-1);
                if (health::getAttribute($_[0],"health") <= 0) {
                        messageLog::newMessage($_[0],"game","alert","The wounds from being beaten result in your death.");
                        health::killCharacter($_[0],"affinity");
                }
	} elsif ($is && $affinity[1] eq "jail and fine") {
		health::setAttribute($_[0],"stealth rating",999);
		$html .= "<i>We don't tolerate ".$affinity[0]." here.</i><br>";
		($a) = sqlQuery("insert into playerAttributes set uid=".$_[0].", class='jail', value=1");
		sqlFinish($a);
		$data[0] = equipment::getMoney($_[0]);
		if ($data[0] > 500) {
			equipment::deleteItemFromUser($_[0],1,500);
			$html .= "You have been fined and jailed. (For approximately 10 minutes.)<br>";
		} elsif ($data[0] > 0) {
			equipment::deleteItemFromUser($_[0],1,$data[0]);
			$html .= "You have been fined and jailed. (For approximately 10 minutes.)<br>";
		} else {
			$html .= "You have been jailed. (For approximately 10 minutes.)<br>";
		}		
	} elsif ($is && $affinity[1] eq "fine") {
		$html .= "<i>We don't tolerate ".$affinity[0]." here.</i><br>";
		$data[0] = equipment::getMoney($_[0]);
		if ($data[0] > 500) {
			equipment::deleteItemFromUser($_[0],1,500);
			$html .= "You have been fined and asked to leave town immediately.<br>";
		} elsif ($data[0] > 0) {
			equipment::deleteItemFromUser($_[0],1,$data[0]);
			$html .= "You have been fined and asked to leave town immediately.<br>";
		} else {
			$html .= "You have been asked to leave town immediately.<br>";
		}		
	} elsif ($is && $affinity[1] eq "shame") {
		$html .= "<i>We don't tolerate ".$affinity[0]." here.</i><br>";
		($a) = sqlQuery("select playerAttributes.type,playerAttributes.value from playerAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type<>'food'");
		while (@data = sqlArray($a)) {
			equipment::deleteItemFromUser($_[0],$data[0],$data[1]);
			equipment::addItemToSector($_[1],$data[0],$data[1],rollDice(6,6));
		}
		sqlFinish($a);
		$html .= "You have been stripped of all your equipment, and escorted out of town.<br>";
		($a) = sqlQuery("select min(map.id) from map left join mapAttributes on (map.id=mapAttributes.sectorId) where map.type<>'impassible' and map.id>".$_[1]);
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] eq "") {
			($a) = sqlQuery("select max(map.id) from map left join mapAttributes on (map.id=mapAttributes.sectorId) where map.type<>'impassible' and map.id<".$_[1]);
			@data = sqlArray($a);
			sqlFinish($a);
		}
		($a) = sqlQuery("update playerAttributes set value=".$data[0]." where uid=".$_[0]." and class='location' and type='current'");	sqlFinish($a);
	}
	return $html;
}

#------------------------------------
# randomDirection()
# return: direction
sub randomDirection {
	my ($randomNumber, $direction);
	$randomNumber = rollDice(1,8);
	if ($randomNumber == 1) {
		$direction = "north";
	} elsif ($randomNumber == 2) {
		$direction = "north-east";
	} elsif ($randomNumber == 3) {
		$direction = "north-west";
	} elsif ($randomNumber == 4) {
		$direction = "west";
	} elsif ($randomNumber == 5) {
		$direction = "east";
	} elsif ($randomNumber == 6) {
		$direction = "south-east";
	} elsif ($randomNumber == 7) {
		$direction = "south-west";
	} else {
		$direction = "south";
	}
	return $direction;
}

#------------------------------------
# stringAdd(string, amountToAdd)
# return: stringResult
sub stringAdd {
        my ($i, $string);
	$string = $_[0];
        for ($i=1; $i<=$_[1]; $i++) {
		$string = ++$string; 
	}
        return $string;
}

#------------------------------------
# stringEvaluate(string)
# return: value 
sub stringEvaluate {
        my ($i,$j);
        $i = "A";
        $j = 1;
        while ($i ne $_[0]) {
        	$i = ++$i;
        	$j++;
        }
        return $j;
}

#------------------------------------
# stringSubtract(string, amountToSubtract)
# return: stringResult 
sub stringSubtract {
	my ($i,$previous,$j,$string);
	$string = $_[0];
	for ($j=1; $j<=$_[1]; $j++) {
		$i = "A";
		while ($i ne $string) {
			$previous = $i;
			$i = ++$i;
		}
		$string = $previous;
	}
	return $string;
}

#------------------------------------
# travelEvent(uid,locationHash)
# return: html
sub travelEvent {
	my ($a, @data, $randomNumber, $html);
	$randomNumber = rollDice(1,250);
	if ($randomNumber == 1) {
		$html = "You see a glimmer on the horizon toward the ".randomDirection().".";
		messageLog::newMessage($_[0],"game","event",$html);
	} elsif ($randomNumber == 2) {
		$html = "You hear what sounds like gunfire coming from the ".randomDirection().".";
		messageLog::newMessage($_[0],"game","event",$html);
	} elsif ($randomNumber == 3) {
		($a) = sqlQuery ("select name,x,y from map order by rand() limit 1");
		@data = sqlArray($a);
		sqlFinish($a);
		$html = "You see a sign that reads &quot;".$data[0]." (".$data[1]."-".$data[2].")&quot;.";
		messageLog::newMessage($_[0],"game","event",$html);
	}
	return $html;
}





1;

