package statistics;
# load default modules
use strict;
use Exporter;

use utility;
# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&interestingTidbits &theDestroyed &currentRanks &theSurvivors);

#------------------------------------
# currentRanks()
# return: html
sub currentRanks {
	my ($a, @data, $count, $playerFound, $html);
	$html = "<h1>Current Ranks</h1>";
	$html .= "The following is the list of the top 20 players in the current game.<p>";
	$html .= '<table cellpadding=2 cellspacing=0 border=1 width="100%"><tr><th>Rank</th><th>Player Name</th><th>Turns Spent</th><th>Renown</th></tr>';
	#($a) = sqlQuery("select player.uid, player.username, playerAttributes.value+0 as rank from player,playerAttributes where player.uid=playerAttributes.uid and playerAttributes.class='attribute' and playerAttributes.type='turns spent' order by rank desc");
	($a) = sqlQuery("select player.uid, player.username, (playerAttributes.value+0) as turns, sum(deeds.renown) as renown, (playerAttributes.value+0)*(sum(deeds.renown)+1) as rank from player left join playerAttributes on (player.uid=playerAttributes.uid) left join deeds on (player.uid=deeds.uid and deeds.completed=1) where playerAttributes.class='attribute' and playerAttributes.type='turns spent' group by player.uid order by rank desc");
	while (@data = sqlArray($a)) {
		$count++;
		if ($count < 21 || $data[0]==$GLOBAL{'uid'}) {
			if ($data[0] == $GLOBAL{'uid'}) {
				$html .= "<tr bgcolor=\"#333322\">";
				$playerFound = 1;
			} else {
				$html .= "<tr>";
			}
			$html .= "<td align=right>".$count." </td><td>".$data[1]."</td><td align=right>".$data[2]."</td><td align=right>".$data[3]."</td></tr>";
		}	
		if ($playerFound == 0 && $count == 21) {
			$html .= "<tr><td colspan=3> . . . </td></tr>\n";
		}
	}
	sqlFinish($a);
	$html .= "</table>\n";
	return $html;
}

#------------------------------------
# interestingTidbits()
# return: html
sub interestingTidbits {
	my ($a, @data, $html, @itemList, $item);
	$html = "<h1>Interesting Tidbits</h1>";
	$html .= '<b>Life and Death</b><br>';
	($a) = sqlQuery("select count(*) from playerAttributes where class='location' and type='current'");	@data = sqlArray($a); sqlFinish($a);
	$html .= '<li>There are currently '.$data[0].' characters still surviving in the current game.';
	($a) = sqlQuery("select name,format(turnsSpent,0),date_format(dateDied,'%c/%d %l:%i%p'),killedBy from theDestroyed order by id desc limit 1");	@data = sqlArray($a);	sqlFinish($a);
	$html .= '<li>'.$data[0].' died at '.$data[2].' after having spent '.$data[1].' turns, and was killed by '.$data[3].'.';
	($a) = sqlQuery("select name,format(avg(turnsSpent),0),date_format(max(dateDied),'%c/%d %l:%i%p'),count(id) as deaths from theDestroyed group by name order by deaths desc limit 1");	@data = sqlArray($a);	sqlFinish($a);
	$html .= '<li>'.$data[0].' has died '.$data[3].' times, which is the most deaths this game, with an average of '.$data[1].' turns spent.';
	($a) = sqlQuery("select count(*) from theDestroyed");	@data = sqlArray($a);	sqlFinish($a);
	$html .= '<li>'.$data[0].' characters have died so far this game.<p>';
	$html .="<b>Time</b><br>";
	($a) = sqlQuery("select date_format(date_add(now(),interval 23 year),'%l:%i%p on %M %D, %Y'), (to_days(date_add(date_sub(now(), interval dayofmonth(now())-1 day), interval 1 month))-to_days(now()))");
	@data = sqlArray($a);
	sqlFinish($a);
	$html .= "The current game time is ".$data[0].". (Yes we know the date is 23 years in the future.)<br>";
	$html .= "The current game will end in ".$data[1]." days.<P>";
	$html .= '<b>Top Attributes</b> (This listing does not include equipment modifiers.)<table cellpadding=2 cellspacing=0 border=1 width="100%"><tr><th>Attribute</th><th>Level</th><th>Player</th></tr>';
	@itemList = ('health','hunger','immunity','armor rating','murders','thefts');
	foreach $item (@itemList) {
		($a) = sqlQuery("select playerAttributes.type,sum(playerAttributes.value) as total,player.username from playerAttributes left join player on (playerAttributes.uid=player.uid) where (playerAttributes.class='attribute' or playerAttributes.class='radiation') and playerAttributes.type='".$item."' group by player.uid,playerAttributes.type order by total desc limit 1");	@data = sqlArray($a);	sqlFinish($a);
		$html .= '<tr><td>'.$data[0].'</td><td align="right">'.$data[1].'</td><td>'.$data[2].'</td></tr>';
	}
	($a) = sqlQuery("select count(playerAttributes.id) as rads,player.username from playerAttributes left join player on (playerAttributes.uid=player.uid) where class='radiation' group by playerAttributes.uid order by rads desc limit 1");	@data = sqlArray($a);	sqlFinish($a);
	$html .= '<tr><td># of radiations</td><td align="right">'.$data[0].'</td><td>'.$data[1].'</td></tr>';
	$html .= "</table><p>";
	$html .= '<b>Top Skills</b> (This listing does not include equipment modifiers.)<table cellpadding=2 cellspacing=0 border=1 width="100%"><tr><th>Skill</th><th>Level</th><th>Player</th></tr>';
	@itemList = ('beast lore','combat','domestics','first aid','haggle','hork','navigate','senses','stealth','tracking','troubadour');
	foreach $item (@itemList) {
		($a) = sqlQuery("select playerAttributes.type,sum(playerAttributes.value) as total,player.username from playerAttributes left join player on (playerAttributes.uid=player.uid) where (playerAttributes.class='skill' or playerAttributes.class='radiation') and playerAttributes.type='".$item."' group by player.uid,playerAttributes.type order by total desc limit 1");	@data = sqlArray($a);	sqlFinish($a);
		$html .= '<tr><td>'.$data[0].'</td><td align="right">'.$data[1].'</td><td>'.$data[2].'</td></tr>';
	}
	$html .= "</table><p>";
        $html .= '<b>Clan Membership</b><table cellpadding=2 cellspacing=0 border=1 width="100%"><tr><th>Clan Name</th><th>Number of Members</th></tr>';
        ($a) = sqlQuery("select value,count(*) from playerAttributes where class='attribute' and type='clan' group by value");
        while (@data = sqlArray($a)) {
                $html .= '<tr><td>'.$data[0].'</td><td align="right">'.$data[1].'</td></tr>';
        }
        sqlFinish($a);
        $html .= "</table><p>";
	$html .= '<b>Sector Distribution</b><table cellpadding=2 cellspacing=0 border=1 width="100%"><tr><th>Sector Type</th><th>Quantity</th><th>Distribution Percentage</th></tr>';
	($a) = sqlQuery("select type,count(*),format((count(*)/1600)*100,2) from mapAttributes where class='description' group by type");	
	while (@data = sqlArray($a)) { 	
		$html .= '<tr><td>'.$data[0].'</td><td align="right">'.$data[1].'</td><td align="right">'.$data[2].'%</td></tr>';
	}
	sqlFinish($a);
	$html .= "</table><p>";
	$html .= '<b>Miscellaneous Tidbits</b><table cellpadding=2 cellspacing=0 border=1 width="100%"><tr><th>Item</th><th>Description</th></tr>';
	($a) = sqlQuery("select count(owner),sum(itemQuantity) from auction where finished<>1");	@data = sqlArray($a);	sqlFinish($a);
	$html .= '<tr><td>auctions</td><td>There are currently '.$data[0].' auctions on-going.</td></tr>';
	($a) = sqlQuery("select format(avg(value+0),2),format(min(value+0),2),format(max(value+0),2) from mapAttributes where class='modifier' and type='radiation level'");	@data = sqlArray($a);	sqlFinish($a);
	$html .= '<tr><td>radiation level</td><td>The map has an average radiation level of '.$data[0].'% with the lowest level at '.$data[1].'%, and the highest level at '.$data[2].'%.</td></tr>';
	($a) = sqlQuery("select count(*),format(avg(item.cost*mapAttributes.value),2) from mapAttributes,item where mapAttributes.class='item' and mapAttributes.type=item.id");	@data = sqlArray($a);	sqlFinish($a);
	$html .= '<tr><td>stashes</td><td>There are '.$data[0].' stashes currently hiding out with an average value of $'.$data[1].'.</td></tr>';
	$html .= "</table><p>";
	return $html;
}

#------------------------------------
# theDestroyed()
# return: html
sub theDestroyed {
	my ($a, @data, $html);
	$html = "<h1>The Destroyed</h1>";
	$html .= "The following is the list of the top 20 dead players so far this game.<p>";
	$html .= '<table cellpadding=2 cellspacing=0 border=1 width="100%"><tr><th>Player Name</th><th>Turns Spent</th><th>Date Killed</th><th>Killed By</th></tr>';
	($a) = sqlQuery("select name,turnsSpent,date_format(dateDied,'%c/%d %l:%i%p'),killedBy from theDestroyed order by turnsSpent desc limit 20");
	while (@data = sqlArray($a)) {
		$html .= "<tr><td>".$data[0]."</td><td align=right>".$data[1]."</td><td>".$data[2]."</td><td>".$data[3]."</td></tr>";
	}
	sqlFinish($a);
	$html .= "</table>\n";
	return $html;
}

#------------------------------------
# theSurvivors()
# return: html
sub theSurvivors {
        my ($a, @data, $html);
        $html = "<h1>The Survivors</h1>";
        $html .= "The following is the list of the top 20 greatest winners of all time.<p>";
        $html .= '<table cellpadding=2 cellspacing=0 border=1 width="100%"><tr><th>Player Name</th><th>Turns Spent</th><th>Date Won</th></tr>';
        ($a) = sqlQuery("select name,turnsSpent,date_format(dateWon,'%c/%d %l:%i%p') from theSurvivors order by turnsSpent desc limit 20");
        while (@data = sqlArray($a)) {
                $html .= "<tr><td>".$data[0]."</td><td align=right>".$data[1]."</td><td>".$data[2]."</td></tr>";
        }
        sqlFinish($a);
        $html .= "</table>\n";
        return $html;
}



1;

