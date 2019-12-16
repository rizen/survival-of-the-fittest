package character;
# load default modules
use strict;
use account;
use equipment;
use health;
use messageLog;
use turns;
use utility;
use Exporter;
# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&showDeeds &showQuests &commitSuicide &createCharacter &showSkills &equipWeapon &showAttributes &equipArmor &showMessageLog &showInventory &dropFromInventory &showRadiations &checkCharacter &statusBar);

#------------------------------------
# checkCharacter(userId)
# return: flag, alive/dead
sub checkCharacter {
	my ($flag, @data);
	@data = sqlQuickArray("select value from playerAttributes where uid=".$_[0]." and class='location' and type='current'");
	if ($data[0] ne "") {
		$flag = 1;
	} else {
		$flag = 0;
	}
	return $flag;
}


#------------------------------------
# statusBar(userId)
# return: html
sub statusBar {
	my ($a, @data, $html, $banner, $style, %location, $rand);
	%location = gameMap::getLocationProperties($_[0]);
	$html .= '<table align="center" class="quickStats" border=0 cellpadding=2 cellspacing=1><tr><td class="quickStatsHeader">'.$GLOBAL{'username'}.'</td>';
	if (health::getInjury($_[0]) > 0) {
		$style = "quickStatsDataAlert";
	} else {
		$style = "quickStatsData";
	}
	$html .= '<td class="'.$style.'"><b>Health:</b> '.health::getAttribute($_[0],"health").'</td>';
	$html .= '<td class="quickStatsData"><b>Hunger:</b> '.health::getAttribute($_[0],"hunger").'</td>';
	($a) = sqlQuery("select sum(playerAttributes.value) from playerAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type='food'");
	@data = sqlArray($a);
	sqlFinish($a);
	$html .= '<td class="quickStatsData"><b>Food:</b> '.$data[0].'</td>';
	$html .= '<td class="quickStatsData"><b>$tandards:</b> '.equipment::getMoney($_[0]).'</td>';
	unless (account::paidToPlay($_[0])) {
		$rand = round(rand(9999999));
		$html .= '<td class="quickStatsData"><b>Turns:</b> '.turns::getTurns($_[0]).'</td>';
		$banner = '<!-- BEGIN LINKEXCHANGE CODE --><center><iframe src="http://leader.linkexchange.com/X1596405/showiframe?" width=468 height=60 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no><a href="http://leader.linkexchange.com/X1596405/clickle" target="_top"><img width=468 height=60 border=0 ismap alt="" src="http://leader.linkexchange.com/X1596405/showle?"></a></iframe><br><a href="http://leader.linkexchange.com/X1596405/clicklogo" target="_top"><img src="http://leader.linkexchange.com/X1596405/showlogo?" width=468 height=16 border=0 ismap alt=""></a><br></center><!-- END LINKEXCHANGE CODE -->';
		$banner .= '<div align="center"><a href="aux.pl?op=showPaymentOptions">This banner will go away when you pay to play! Click here for details.</a></div>';
	}
	if (equipment::searchForItem($_[0],79)) {
		$html .= '<td class="quickStatsData"><b>Rad Level:</b> '.$location{'radiation level'}.'%</td>';
	}
	if (equipment::searchForItem($_[0],80)) {
		$html .= '<td class="quickStatsData"><b>Sector:</b> '.$location{'x'}.'-'.$location{'y'}.'</td>';
	}
	if ($location{'class'} eq "civilization") {
		$html .= '<td class="quickStatsData"><b>In:</b> '.$location{'name'}.'</td>';
	}
	$html .= '</tr></table>';
	$html .= $banner;
	return $html;
}

#------------------------------------
# createCharacter()
# return: 
sub createCharacter {
	my ($html, $a, %skill, $baseQuery, @data, @item, $message);
	$html =	"<h1>Create Your Character</h1>";
	if ($FORM{'doit'} eq "Create Character") {
		($a) = sqlQuery("select value from playerAttributes where uid=".$GLOBAL{'uid'}." and class='location' and type='current'");
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] eq "") {
			$baseQuery = "insert into playerAttributes set uid=".$_[0];
			$skill{'beast lore'} = rollDice(2,3);
			$skill{'combat'} = rollDice(2,3);
			$skill{'domestics'} = rollDice(2,3);
			$skill{'first aid'} = rollDice(2,3);
			$skill{'haggle'} = rollDice(2,3);
			$skill{'hork'} = rollDice(2,3);
			$skill{'navigate'} = rollDice(2,3);
			$skill{'senses'} = rollDice(2,3);
			$skill{'tracking'} = rollDice(2,3);
			$skill{'stealth'} = rollDice(2,3);
			$skill{'troubadour'} = rollDice(2,3);
			$skill{$FORM{'skill'}} += rollDice(1,6);
			($a) = sqlQuery($baseQuery.", class='skill', type='beast lore', value=".$skill{'beast lore'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='beast lore', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='combat', value=".$skill{'combat'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='combat', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='domestics', value=".$skill{'domestics'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='domestics', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='first aid', value=".$skill{'first aid'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='first aid', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='haggle', value=".$skill{'haggle'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='haggle', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='hork', value=".$skill{'hork'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='hork', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='navigate', value=".$skill{'navigate'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='navigate', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='stealth', value=".$skill{'stealth'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='stealth', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='senses', value=".$skill{'senses'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='senses', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='tracking', value=".$skill{'tracking'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='tracking', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill', type='troubadour', value=".$skill{'troubadour'}); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='skill points', type='troubadour', value=0"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='gender', value='".$FORM{'gender'}."'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='react', value=".quote($FORM{react})); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='health', value='20'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='drunk', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='poison', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='murders', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='immunity', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='shielding', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='armor rating', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='thefts', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='stealth rating', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='hunger', value='0'"); sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='attribute', type='turns spent', value='0'"); sqlFinish($a);
			if (account::paidToPlay($GLOBAL{'uid'})) {
				($a) = sqlQuery($baseQuery.", class='attribute', type='turns', value='99999999'"); sqlFinish($a);
			} else {
				($a) = sqlQuery($baseQuery.", class='attribute', type='turns', value='5000'"); sqlFinish($a);
			}	
			($a) = sqlQuery($baseQuery.", class='attribute', type='age', value=".$FORM{'age'}); sqlFinish($a);
			if ($FORM{'age'} <= 20) {
				($a) = sqlQuery($baseQuery.", class='radiation', type='health', value=".rollDice(1,4)); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=1 where uid=".$_[0]." and class='attribute' and type='immunity'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=".rollDice(1,8)." where uid=".$_[0]." and class='attribute' and type='armor rating'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=value-1 where uid=".$_[0]." and class='skill'"); sqlFinish($a);
			} elsif ($FORM{'age'} <= 30) {
				($a) = sqlQuery($baseQuery.", class='radiation', type='health', value=".rollDice(1,4)); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=1 where uid=".$_[0]." and class='attribute' and type='immunity'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=".rollDice(1,4)." where uid=".$_[0]." and class='attribute' and type='armor rating'"); sqlFinish($a);
			} elsif ($FORM{'age'} <= 40) {
				# do nothing
			} elsif ($FORM{'age'} <= 50) {
				($a) = sqlQuery($baseQuery.", class='radiation', type='health', value=-".rollDice(1,4)); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=-".rollDice(1,4)." where uid=".$_[0]." and class='attribute' and type='immunity'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=-".rollDice(1,4)." where uid=".$_[0]." and class='attribute' and type='armor rating'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=value+1 where uid=".$_[0]." and class='skill'"); sqlFinish($a);
			} elsif ($FORM{'age'} <= 60) {
				($a) = sqlQuery($baseQuery.", class='radiation', type='health', value=-".rollDice(1,8)); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=-".rollDice(1,8)." where uid=".$_[0]." and class='attribute' and type='immunity'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=-".rollDice(1,8)." where uid=".$_[0]." and class='attribute' and type='armor rating'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=value+2 where uid=".$_[0]." and class='skill'"); sqlFinish($a);
			} else {
				($a) = sqlQuery($baseQuery.", class='radiation', type='health', value=-".rollDice(1,12)); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=-".rollDice(1,12)." where uid=".$_[0]." and class='attribute' and type='immunity'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=-".rollDice(1,12)." where uid=".$_[0]." and class='attribute' and type='armor rating'"); sqlFinish($a);
				($a) = sqlQuery("update playerAttributes set value=value+3 where uid=".$_[0]." and class='skill'"); sqlFinish($a);
			}
			($a) = sqlQuery("select id from map where type='".$FORM{'location'}."' order by rand() limit 1");
			@data = sqlArray($a);
			sqlFinish($a);
			($a) = sqlQuery($baseQuery.", class='location', type='current', value=".$data[0]); sqlFinish($a);
			sqlFinish($a);
			if ($FORM{'equipment'} eq "food") {
				equipment::addItemToUser($_[0],2,rollDice(6,6));
			} elsif ($FORM{'equipment'} eq "money") {
				equipment::addItemToUser($_[0],1,rollDice(10,10));
			} else {
				@item = (4,5,6,7,8,9,17,32,31,35,36,39,40,71,72,101,70,3,29,98,14,73,12,107,108);
				equipment::addItemToUser($_[0],$item[rollDice(1,($#item+1))-1],1);
			}
			equipment::addItemToUser($_[0],112,1);
			equipment::addItemToUser($_[0],113,1);
			equipment::addItemToUser($_[0],106,rollDice(5,5));
			equipment::addItemToUser($_[0],1,rollDice(3,5));
			$message = "Character creation successful.";
			$html .= "<ul><li>".$message."</ul>";
			messageLog::newMessage($_[0],"game","notice",$message);
		} else {
			$html .= "<ul><li>You can't create a character when you already have one.</ul>";
		}
		($html) .= showInventory();
	} else {
		$html .= '
		You need to make some choices about how your character will start out in this 
		world. Choose carefully, you\'ll not get to alter your choices after your
		character has been created.
		<form method="post" action="game.pl">
		<input type="hidden" name="op" value="createCharacter">
		<table><tr><td valign="top">
		Which of these skills do you perceive to be the most important?<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="beast lore"> Beast Lore<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="combat" checked> Combat<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="domestics"> Domestics<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="first aid"> First Aid<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="haggle"> Haggle<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="hork"> Hork<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="navigate"> Navigate<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="senses"> Senses<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="stealth"> Stealth<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="tracking"> Tracking<br>
		&nbsp;&nbsp;<input type="radio" name="skill" value="troubadour"> Troubadour<br>
		<p>
                If you were attacked, what would you do?<br>
                &nbsp;&nbsp;<input type="radio" name="react" value="nothing" checked> Nothing<br>
                &nbsp;&nbsp;<input type="radio" name="react" value="run"> Run<br>
                &nbsp;&nbsp;<input type="radio" name="react" value="fight"> Fight Back<br>
                <p>
		</td><td>&nbsp;</td><td valign="top">
		Where would you rather be?<br>
		&nbsp;&nbsp;<input type="radio" name="location" value="civilization" checked> Civilization<br>
		&nbsp;&nbsp;<input type="radio" name="location" value="wilderness"> Wilderness<br>
		<p>
		Which is most important?<br>
		&nbsp;&nbsp;<input type="radio" name="equipment" value="food" checked> Food<br>
		&nbsp;&nbsp;<input type="radio" name="equipment" value="money"> Money<br>
		&nbsp;&nbsp;<input type="radio" name="equipment" value="tools"> Tools<br>
		<p>
		How old do you wish to be?<br>
		&nbsp;&nbsp;&nbsp;&nbsp;<select name="age">
		<option>16<option>17<option>18<option>19<option>20
		<option>21<option>22<option>23<option>24<option>25
		<option>26<option>27<option>28<option>29<option>30
		<option>31<option>32<option>33<option>34<option selected>35
		<option>36<option>37<option>38<option>39<option>40
		<option>41<option>42<option>43<option>44<option>45
		<option>46<option>47<option>48<option>49<option>50
		<option>51<option>52<option>53<option>54<option>55
		<option>56<option>57<option>58<option>59<option>60
		<option>61<option>62<option>63<option>64<option>65
		</select>
                <p>
                Which gender would you prefer to be?<br>
                &nbsp;&nbsp;<input type="radio" name="gender" value="man"> Man<br>
                &nbsp;&nbsp;<input type="radio" name="gender" value="woman" checked> Woman<br>
		<p>
		</td></tr></table>
		<input type="submit" name="doit" value="Create Character">
		</form>
		';
	}
	return $html;
}

#------------------------------------
# commitSuicide()
# return: html
sub commitSuicide {
	my ($html, @data, $a);
	$html .= "<h1>Commit Suicide</h1>";
	if ($FORM{'doit'} eq "yes") {
		($a) = sqlQuery("select type,value from playerAttributes where uid=".$GLOBAL{'uid'}." and class='item'");
		while (@data = sqlArray($a)) {
			equipment::addItemToSector(rollDice(1,1600),$data[0],$data[1],rollDice(8,8));
		}
		sqlFinish($a);
		($a) = sqlQuery("delete from playerAttributes where uid=".$GLOBAL{'uid'}." and class<>'pay to play'");
		sqlFinish($a);
		($a) = sqlQuery("delete from deeds where uid=".$GLOBAL{'uid'});
		sqlFinish($a);
		$html .= "<ul><li>Suicide successful!</ul>";
		messageLog::newMessage($GLOBAL{'uid'},"game","notice","You have successfully committed suicide.");
		$html .= createCharacter();
	} else {
		$html .= '
			Are you absolutely certain you want to commit suicide? There will be no resuscitation, and
			the world will continue as though you had never existed at all.
			<p>
			<a href="game.pl?op=commitSuicide&doit=yes">Yes, I\'m absolutely sure I want to kill my character.</a>
		';
	}
	return $html;
}

#------------------------------------
# dropFromInventory()
# return: html
sub dropFromInventory {
	my ($html,%location);
	if (turns::spendTurns($GLOBAL{'uid'},1)) {
		%location = gameMap::getLocationProperties($GLOBAL{'uid'});
		if (equipment::dropItem($GLOBAL{'uid'},$location{'sectorId'},$FORM{'itemId'},$FORM{'quantity'})) {
			messageLog::newMessage($GLOBAL{'uid'},"game","notice","Item(s) dropped.");
		} else {
			messageLog::newMessage($GLOBAL{'uid'},"game","notice","Insufficient item(s) to drop.");
		}	
	} else {
		messageLog::newMessage($GLOBAL{'uid'},"game","notice","You do not have enough turns to drop any items.");
	}
	$html = showInventory();
	return $html;
}

#------------------------------------
# equipArmor()
# return: html
sub equipArmor {
	my ($a, @data, $html);
	if (turns::spendTurns($GLOBAL{'uid'},1)) {
		($a) = sqlQuery("delete from playerAttributes where uid=".$GLOBAL{'uid'}." and class='equipped' and type='armor'");
		sqlFinish($a);
		($a) = sqlQuery("insert into playerAttributes set uid=".$GLOBAL{'uid'}.", class='equipped', type='armor', value='".$FORM{'itemId'}."'");
		@data = sqlArray($a);
		sqlFinish($a);
		messageLog::newMessage($GLOBAL{'uid'},"game","notice","Different armor equipped.");
	} else {
		messageLog::newMessage($GLOBAL{'uid'},"game","notice","You do not have enough turns to equip different armor.");
	}
	$html = showInventory();
	return $html;
}

#------------------------------------
# equipWeapon()
# return: html 
sub equipWeapon {
	my ($a, @data, $html);
	if (turns::spendTurns($GLOBAL{'uid'},1)) {
		($a) = sqlQuery("delete from playerAttributes where uid=".$GLOBAL{'uid'}." and class='equipped' and type='weapon'");
		sqlFinish($a);
		($a) = sqlQuery("insert into playerAttributes set uid=".$GLOBAL{'uid'}.", class='equipped', type='weapon', value='".$FORM{'itemId'}."'");
		@data = sqlArray($a);
		sqlFinish($a);
		messageLog::newMessage($GLOBAL{'uid'},"game","notice","Different weapon equipped.");
	} else {
		messageLog::newMessage($GLOBAL{'uid'},"game","notice","You do not have enough turns to equip a different weapon.");
	}
	$html = showInventory();
	return $html;
}

#------------------------------------
# showAttributes()
# return: html
sub showAttributes {
	my ($html, $data);
	$html = "<h1>Character Attributes</h1>";
	$html .= '<table border=1 width="50%" cellpadding=2 cellspacing=0 align=center>';
	$html .= '<tr><th>Name:</th><td align=center>'.$GLOBAL{'username'}.'</td></tr>';
	$html .= '<tr><th>Renown:</th><td align=center>'.(renown::getRenown($GLOBAL{'uid'})+0).'</td></tr>';
	$html .= '<tr><th>Age:</th><td align=center>'.health::getAttribute($GLOBAL{'uid'},"age").'</td></tr>';
	$html .= '<tr><th>Gender:</th><td align=center>'.health::getUnmodifiedAttribute($GLOBAL{'uid'},"gender").'</td></tr>';
	$html .= '<tr><th>Health:</th><td align=center>'.health::getAttribute($GLOBAL{'uid'},"health").'</td></tr>';
	$html .= '<tr><th>Hunger:</th><td align=center>'.health::getAttribute($GLOBAL{'uid'},"hunger").'</td></tr>';
	$html .= '<tr><th>Shielding:</th><td align=center>'.health::getAttribute($GLOBAL{'uid'},"shielding").'</td></tr>';
	$html .= '<tr><th>Immunity:</th><td align=center>'.health::getAttribute($GLOBAL{'uid'},"immunity").'</td></tr>';
        $data = health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan");
        if ($data ne "") {
                $html .= '<tr><th>Clan:</th><td align=center>'.$data.'</td></tr>';
        }
	$data = health::getAttribute($GLOBAL{'uid'},"poison");
	if ($data > 0) {
		$html .= '<tr><th>Blood-Toxin Level:</th><td align=center>'.$data.'</td></tr>';
	}
	$data = health::getAttribute($GLOBAL{'uid'},"drunk");
	if ($data > 0) {
		$html .= '<tr><th>Blood-Alcohol Level:</th><td align=center>'.$data.'</td></tr>';
	}
	$html .= '<tr><th>Armor Rating:</th><td align=center>'.combat::getArmorRating($GLOBAL{'uid'},"armor rating").'</td></tr>';
	if (account::paidToPlay($GLOBAL{'uid'})) {
		$data = "unlimited";
	} else {
		$data = turns::getTurns($GLOBAL{'uid'});
	}
	$html .= '<tr><th>Turns Remaining:</th><td align=center>'.$data.'</td></tr>';
	$html .= '<tr><th>Turns Spent:</th><td align=center>'.turns::getTurnsSpent($GLOBAL{'uid'}).'</td></tr>';
	$html .= "</table>";
	return $html;
}

#------------------------------------
# showDeeds()
# return: html
sub showDeeds {
        my ($html, $a, @data);
        $html = "<h1>Deeds</h1>The following is a list of deeds you've recorded and some details about them.<p>";
        $html .= '<table width="100%" cellpadding=2 cellspacing=0 border=1><tr><th>Deed</th><th>Renown</th><th>Aquired renown from this deed?</th></tr>';
	($a) = sqlQuery("select description,renown,completed from deeds where uid=".$GLOBAL{'uid'});
        while (@data = sqlArray($a)) {
	        $html .= '<tr><td>'.$data[0].'</td><td align=right>'.$data[1].'</td><td>';
		if ($data[2] == 1) {
			$html .= 'Yes</td></tr>';
		} else {
			$html .= 'No</td></tr>';
		}
        }
	sqlFinish($a);
        $html .= '</table><p>';
        return $html;
}

#------------------------------------
# showInventory()
# return: html
sub showInventory {
	my ($a, @data, $equipped, $html);
	$html = "<h1>Inventory</h1> The following is a list of the items in your inventory. You are carrying ".equipment::countInventoryItems($GLOBAL{'uid'})." of 500 possible items.<p>";
	($a) = sqlQuery("select value from playerAttributes where uid=".$GLOBAL{'uid'}." and class='equipped' and type='weapon'");
	($equipped) = sqlArray($a);
	sqlFinish($a);
	$html .= "<b>Weapons</b>";
	$html .= '<table border=1 cellpadding=3 cellspacing=0 width="100%"><tr><th width="10%">Equipped</th><th width="15%">Quantity</th><th width="60%">Item</th><th  width="15%">Value (each)</th></tr>';
	($a) = sqlQuery("select playerAttributes.value,item.name,item.cost,item.id from playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type='weapon' order by item.name");
	while (@data = sqlArray($a)) {
		$html .= '<tr><form method=post><input type=hidden name="op" value="equipWeapon"><td align=center>';
	    if ($equipped == $data[3]) {
		    $html .= "<input type=radio name=itemId value=".$data[3]." checked onClick=\"this.form.submit()\">";
	    } else {
		    $html .= "<input type=radio name=itemId value=".$data[3]." onClick=\"this.form.submit()\">";
	    }		
		$html .= '</td></form><form method=post><input type=hidden name="op" value="dropFromInventory"><input type=hidden name="itemId" value="'.$data[3].'"><td align=center><select name="quantity">';
		$html .= selectList($data[0]);
		$html .= '</select><input type="image" src="/sotfGame/drop.gif" border=0></td></form><td>'.$data[1].'</td><td align=right>$'.$data[2].'</td></tr>';
	}
	sqlFinish($a);
	$html .= "</table><p>";
	($a) = sqlQuery("select value from playerAttributes where uid=".$GLOBAL{'uid'}." and class='equipped' and type='armor'");
	($equipped) = sqlArray($a);
	sqlFinish($a);
	$html .= "<b>Armor</b>";
	$html .= '<table border=1 cellpadding=3 cellspacing=0 width="100%"><tr><th width="10%">Equipped</th><th width="15%">Quantity</th><th width="60%">Item</th><th  width="15%">Value (each)</th></tr>';
	($a) = sqlQuery("select playerAttributes.value,item.name,item.cost,item.id from playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type='armor' order by item.name");
	while (@data = sqlArray($a)) {
		$html .= '<tr><form method=post><input type=hidden name="op" value="equipArmor"><td align=center>';
	    if ($equipped == $data[3]) {
		    $html .= "<input type=radio name=itemId value=".$data[3]." checked onClick=\"this.form.submit()\">";
	    } else {
		    $html .= "<input type=radio name=itemId value=".$data[3]." onClick=\"this.form.submit()\">";
	    }		
		$html .= '</td></form><form method=post><input type=hidden name="op" value="dropFromInventory"><input type=hidden name="itemId" value="'.$data[3].'"><td align=center><select name="quantity">';
		$html .= selectList($data[0]);
		$html .= '</select><input type="image" src="/sotfGame/drop.gif" border=0></td></form><td>'.$data[1].'</td><td align=right>$'.$data[2].'</td></tr>';
	}
	sqlFinish($a);
	$html .= "</table><p>";
	$html .= "<b>Other</b>";
	$html .= '<table border=1 cellpadding=3 cellspacing=0 width="100%"><tr><th width="25%">Quantity</th><th width="60%">Item</th><th  width="15%">Value (each)</th></tr>';
	($a) = sqlQuery("select playerAttributes.value,item.name,item.cost,item.id from playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type<>'weapon' and item.type<>'armor' order by item.name");
	while (@data = sqlArray($a)) {
		$html .= '<tr><form method=post><input type=hidden name="op" value="dropFromInventory"><input type=hidden name="itemId" value="'.$data[3].'"><td align=center><select name="quantity">';
		$html .= selectList($data[0]);
		$html .= '</select><input type="image" src="/sotfGame/drop.gif" border=0></td></form><td>'.$data[1].'</td><td align=right>$'.$data[2].'</td></tr>';
	}
	sqlFinish($a);
	$html .= "</table><p><b>Note:</b> Dropping or equipping an item will cost you one turn.";
	return $html;
}

#------------------------------------
# showMessageLog()
# return: html
sub showMessageLog {
	my ($html, @data, $a, $whereExtension);
	$html = "<h1>Message Log</h1>";
	$html .= '<table width="100%" border=1 cellpadding=2 cellspacing=0>';
	$html .= '<tr class="tableHeader"><th>Time</th><form name="selecter1"><th>';
	$html .= '
		<script language="JavaScript" type="text/javascript">
			<!--
		function go1(){
			if (document.selecter1.select1.options[document.selecter1.select1.selectedIndex].value != "none") {
				location = document.selecter1.select1.options[document.selecter1.select1.selectedIndex].value
			}
		}
		// end hiding contents -->
		</script>
		<select name="select1" size=1 onChange="go1()">
		<option value="game.pl?op=showMessageLog">Type (All)
	';
	if ($FORM{'messageType'} eq "alert") {
		$whereExtension = " and type='alert'";
		$html .= '<option value="game.pl?op=showMessageLog&messageType=alert" selected>Alerts';
	} else {
		$html .= '<option value="game.pl?op=showMessageLog&messageType=alert">Alerts';
	}
	if ($FORM{'messageType'} eq "cheating") {
		$whereExtension = " and type='cheating'";
		$html .= '<option value="game.pl?op=showMessageLog&messageType=cheating" selected>Cheating';
	} else {
		$html .= '<option value="game.pl?op=showMessageLog&messageType=cheating">Cheating';
	}
        if ($FORM{'messageType'} eq "event") {
                $whereExtension = " and type='event'";
                $html .= '<option value="game.pl?op=showMessageLog&messageType=event" selected>Events';
        } else {
                $html .= '<option value="game.pl?op=showMessageLog&messageType=event">Events';
        }
        if ($FORM{'messageType'} eq "mail") {
                $whereExtension = " and type='mail'";
                $html .= '<option value="game.pl?op=showMessageLog&messageType=mail" selected>Mail';
        } else {
                $html .= '<option value="game.pl?op=showMessageLog&messageType=mail">Mail';
        }
        if ($FORM{'messageType'} eq "notice") {
                $whereExtension = " and type='notice'";
                $html .= '<option value="game.pl?op=showMessageLog&messageType=notice" selected>Notice';
        } else {
                $html .= '<option value="game.pl?op=showMessageLog&messageType=notice">Notice';
        }
        if ($FORM{'messageType'} eq "shout") {
                $whereExtension = " and type='shout'";
                $html .= '<option value="game.pl?op=showMessageLog&messageType=shout" selected>Shout';
        } else {
                $html .= '<option value="game.pl?op=showMessageLog&messageType=shout">Shout';
        }
	$html .= '
		</select>
		
		';	
	$html .='</th></form><th>Message</th></tr>';
	($a) = sqlQuery("select date_format(time,'%c/%e %l:%i %p'), type, message from messageLog where uid=".$GLOBAL{'uid'}.$whereExtension." order by id desc limit 20");
	while (@data = sqlArray($a)) {
		$html .= '<tr><td>'.$data[0].'</td><td>'.$data[1].'</td><td>'.$data[2].'</td></tr>';
	}
	sqlFinish($a);
	$html .= "</table>";
	return $html;
}

#------------------------------------
# showQuests()
# return: html
sub showQuests {
        my ($html, @data, $a, $whereExtension);
        $html = "<h1>Pending Quests</h1>";
        $html .= '<table width="100%" border=1 cellpadding=2 cellspacing=0>';
        $html .= '<tr class="tableHeader"><th>Quest Name</th><th>Quest Item</th><th>Return To</th></tr>';
        ($a) = sqlQuery("select quests.goalQuantity,item.name,mapAttributes.value,map.name,quests.name from quests,mapAttributes,map,playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='quest' and playerAttributes.type=quests.id and playerAttributes.value=mapAttributes.id and mapAttributes.sectorId=map.id and mapAttributes.class='amenity' and quests.goalItem=item.id");
        while (@data = sqlArray($a)) {
                $html .= '<tr><td>'.$data[4].'</td><td>'.$data[0].' '.pluralize($data[1],$data[0]).'</td><td>'.$data[2].' in '.$data[3].'</td></tr>';
        }
        sqlFinish($a);
        $html .= "</table>";
        return $html;
}

#------------------------------------
# showRadiations()
# return: html
sub showRadiations {
	my ($a, @data, $html);
	$html = "<h1>Radiations</h1>The following is the list of side-effects you are suffering due to radiation.<p>";
	$html .= '<table width="100%" border=1 cellpadding=2 cellspacing=0><tr><th valign=top>Individual Effects</th><th valign=top>Cumulative Effects</th></tr><tr><td valign=top><table>';
	($a) = sqlQuery("select type,value from playerAttributes where uid=".$GLOBAL{'uid'}." and class='radiation'");
	while (@data = sqlArray($a)) {
		$html .= "<tr><td align=right>".$data[1]."</td><td>".$data[0]."</td></tr>";
	}
	sqlFinish($a);
	$html .= '</table></td><td valign=top><table>';
	($a) = sqlQuery("select type,sum(value) from playerAttributes where uid=".$GLOBAL{'uid'}." and class='radiation' group by type order by type");
	while (@data = sqlArray($a)) {
		$html .= "<tr><td align=right>".$data[1]."</td><td>".$data[0]."</td></tr>";
	}
	sqlFinish($a);
	$html .= '</table></td></tr></table>';
	return $html;
}

#------------------------------------
# showSkills()
# return: html
sub showSkills {
	my ($html, $level, $points, $percent, $skill, @skillList);
	$html = "<h1>Skills</h1>The following is a listing of your skills and the levels you've achieved.<p>";
	$html .= '<table width="100%" cellpadding=2 cellspacing=0 border=1><tr><th>Skill</th><th>Level</th><th>% to Next Level</th><th>Total</th></tr>';
	@skillList = ('beast lore','combat','domestics','first aid','haggle','hork','navigate','senses','stealth','tracking','troubadour');
	foreach $skill (@skillList) {
		$level = skills::getPureSkillLevel($GLOBAL{'uid'},$skill);
		$points = skills::getSkillPoints($GLOBAL{'uid'},$skill);
		$percent = round(($points*100)/(($level+1)*($level)*($level+2)));
		$html .= '<tr><td>'.$skill.'</td><td align=right>'.$level.'</td><td align=right>'.$percent.'%</td><td align=right>'.skills::getSkillLevel($GLOBAL{'uid'},$skill,1).'</td></tr>';
	}
	$html .= '</table><p><b>Note:</b> Total includes advancements, radiation, and equipment modifiers.';
	return $html;
}


1;

