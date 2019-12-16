package government;
# load default modules
use strict;
use Exporter;

use equipment;
use gameMap;
use messageLog;
use turns;
use utility;

# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&mailRead &mailRecipient &mailItem &mailMessage &mailSend &viewClanhallLocations &viewClanMembership &unbankItem &clanSignup &bankItem);

#------------------------------------
# bankItem()
# return: html
sub bankItem {
        my ($html, %location, %amenity, $a, @data, $msg);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $html .= '<h1>Bank An Item</h1> You can bank items here that will be kept in storage for you regardless of how many times you die. This is a great way to protect yourself from the "unimaginable" event.';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		if (account::paidToPlay($GLOBAL{'uid'})) {
	                $html .= '<table width="100%"><tr><td valign="top">';
        	        if ($FORM{'item'} ne "") {
                	        $html .= "Banking item...<br>";
				if (equipment::deleteItemFromUser($GLOBAL{'uid'},$FORM{'item'},1)) {
					@data = sqlQuickArray("select count(*) from bank where uid=".$GLOBAL{'uid'});
					if ($data[0] < 3) {
						$html .= "Done.<br>";
					        ($a) = sqlQuery("insert into bank set uid=".$GLOBAL{'uid'}.", itemId=".$FORM{'item'});
                                        	sqlFinish($a);
					} else {
						$html .= "You already have three items banked.<br>";
						equipment::addItemToUser($GLOBAL{'uid'},$FORM{'item'},1);
					}
				} else {
					$html .= "You can't bank an item you don't have.<br>";
				}
	                	$html .= '</td><td valign="top">';
			}
                	$html .= '<table cellpadding=2 cellspacing=0 border=1 align="center"><tr><th>Item</th><th>Bank!</th></tr>';
                	($a) = sqlQuery("select playerAttributes.type,item.name from playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=item.id order by item.name");
                	while (@data = sqlArray($a)) {
                               	$html .= '<tr><form method="post"><input type="hidden" name="op" value="bankItem"><input type="hidden" name="ai" value="'.$FORM{'ai'}.'"><td align="center"><input type="hidden" name="item" value="'.$data[0].'">'.$data[1].'</td><td><input type="image" src="/bank.gif" border=0></td></form></tr>';
                	}
                	sqlFinish($a);
        	        $html .= '</table><p>';
       	         	$html .= '</td></tr></table><p>';
			$html .= '<i><b>Note:</b> Banking an item costs you nothing, but you can only bank up to three items at a time.</i><p>';	
		} else {
			$msg = 'You must Pay to Play to use the bank.';
                	messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                	$html .= $msg."<p>";
		}
	} else {
		$msg = "You cannot use a bank that you are not near.";
		messageLog::caughtCheating($GLOBAL{'uid'},$msg);
		$html .= $msg."<p>";
	}
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
# clanSignup()
# return: html
sub clanSignup {
        my ($html, %location, %amenity, $a, @data, $msg, $clan);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $html .= '<h1>Clan Registration</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if (account::paidToPlay($GLOBAL{'uid'})) {
                        $html .= '<table width="100%"><tr><td valign="top">';
			$clan = health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan");
                	if ($clan eq "") {
                        	if ($FORM{'clan'} ne "") {
                                	$html .= "Joining Clan...<br>";
                                	($a) = sqlQuery("insert into playerAttributes set uid=".$GLOBAL{'uid'}.", class='attribute', type='clan', value='".$FORM{'clan'}."'");
                                	sqlFinish($a);
                                	if ($FORM{'clan'} eq "dEad Men Walking") {
						health::modifyAttribute($GLOBAL{'uid'},"immunity","100");
                                	} elsif ($FORM{'clan'} eq "Wasteland Rogues") {
                                        	($a) = sqlQuery("update playerAttributes set value=value+200 where uid=".$GLOBAL{'uid'}." and class='skill points' and (type='hork' or type='senses')"); sqlFinish($a);
                                	} elsif ($FORM{'clan'} eq "Fyth Dogg Pack") {
                                        	($a) = sqlQuery("update playerAttributes set value=value+100 where uid=".$GLOBAL{'uid'}." and class='skill points'"); sqlFinish($a);
                                        	($a) = sqlQuery("update playerAttributes set value=value+300 where uid=".$GLOBAL{'uid'}." and class='skill points' and type='beast lore'"); sqlFinish($a);
                                	}
                                       	$html .= "Done joining ".$FORM{'clan'}.".<br>";
					$clan = $FORM{'clan'};
                                	$html .= '</td><td valign="top">';
				} else {
					$html .= '
						Becoming a member of a clan can be very beneficial. Choose a clan that you wish to belong to:
						<form method="post"><input type="hidden" name="op" value="clanSignup">
						<input type="hidden" name="ai" value="'.$FORM{'ai'}.'"><table>
						 <tr><td><input type="radio" name="clan" value="AlphaPrime"></td><td>
						AlphaPrime is the first deadEarth clan to be created. They have immunity from being player killed (except if you\'re the #1 player), however, they also have the respect not to take human life (except in self-defense).	
						</td><tr>
                                                <tr><td><input type="radio" name="clan" value="Famiglia di Santione"></td><td>
						Famiglia di Santione is the ultimate crime family in deadEarth. They have immunity from theft related affinities.
                                                </td><tr>
                                                <tr><td><input type="radio" name="clan" value="The Wraiths"></td><td>
						The Wraiths are a well armed alliance of like minded people, sworn enemies of the Power. They have immunity from gunslinger related affinities.
                                                </td><tr>
                                                <tr><td><input type="radio" name="clan" value="Null"></td><td>
						Inventors of many fine deadEarth goods, Null can always find or build something from virtually nothing. Null has excellent scavenging abilities.
                                                </td><tr>
                                                <tr><td><input type="radio" name="clan" value="Godsbane"></td><td>
						Godsbane is the home of the mutant clan and is based in Denver (the largest population of mutants in the world). They have immunity from mutant related affinities.
                                                </td><tr>
                                                <tr><td><input type="radio" name="clan" value="dEad Men Walking"></td><td>
						dEad Men Walking are a marvel, seeming almost impossible to kill. They have great immunity to poison.
                                                </td><tr>
                                                <tr><td><input type="radio" name="clan" value="Fyth Dogg Pack"></td><td>
					        Fyth Dogg Pack is quite possibly the largest clan ever. In being the largest clan they tend to have more knowledge than most.	
                                                </td><tr>
                                                <tr><td><input type="radio" name="clan" value="Wasteland Rogues"></td><td>
						Wasteland Rogues (affiliates of Famiglia di Santione) are the among the best thieves in the world.
                                                </td><tr>

						</table><input type="submit" value="Join Up!"></form>
					';
				}
                        }
			if ($clan ne "") {
				$html .= 'You are part of '.$clan.'.<p>';
				$html .= '
					There is an unwritten code of conduct in most clans. 
					<ul><li>You do not bad mouth your clanmates.
					<li>You do not steal from your clanmates.
					<li>And most of all, you do not attack your clanmates.</ul>
					<ul>
					<li><a href="game.pl?op=viewClanhallLocations&ai='.$FORM{'ai'}.'">Tell me where I can find my clanhall.</a>
					</ul>
					';
			}
                        $html .= '</td></tr></table><p>';
                } else {
                        $msg = "You must Pay to Play to use clans.";
                        messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                        $html .= $msg."<p>";
                }
        } else {
                $msg = "You use a government building you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
# mailItem()
# return: html
sub mailItem {
        my ($html, %location, %amenity, $a, @data, $temp, $msg);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= '<p><b>From:</b> '.$GLOBAL{username};
	($temp) = sqlQuickArray("select username from player where uid='$FORM{uid}'");
	$html .= '<br><b>To:</b> '.$temp;
	$html .= '<h1>Step 2: Choose an Item</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if (account::paidToPlay($GLOBAL{'uid'})) {
                        $html .= '<table width="100%"><tr><td valign="top">';
                        $html .= '<table cellpadding=2 cellspacing=0 border=1 align="center"><tr><th>Item</th><th>Send!</th></tr>';
                        ($a) = sqlQuery("select playerAttributes.type,item.name from playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=item.id order by item.name");
                        while (@data = sqlArray($a)) {
                                $html .= '
				<tr><form method="post"><input type="hidden" name="op" value="mailMessage">
				<input type="hidden" name="ai" value="'.$FORM{ai}.'">
				<input type="hidden" name="uid" value="'.$FORM{uid}.'">
				<td align="center">
				<input type="hidden" name="item" value="'.$data[0].'">
				'.$data[1].'</td><td>
				<input type="image" src="/send.gif" border=0></td></form></tr>
				';
                        }
                        $html .= '
                                <tr><form method="post"><input type="hidden" name="op" value="mailMessage">
                                <input type="hidden" name="ai" value="'.$FORM{ai}.'">
                                <input type="hidden" name="uid" value="'.$FORM{uid}.'">
                                <td align="center">
                                <input type="hidden" name="item" value="none">
                                No package this time.</td><td>
                                <input type="image" src="/send.gif" border=0></td></form></tr>
                        ';
                        sqlFinish($a);
                        $html .= '</table><p>';
                        $html .= '</td></tr></table><p>';
                } else {
                        $msg = 'You must Pay to Play to use the postal system.';
                        messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                        $html .= $msg."<p>";
                }
        } else {
                $msg = "You cannot use a post office that you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
# mailMessage()
# return: html
sub mailMessage {
        my ($html, %location, %amenity, $a, @data, $temp, $msg);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $html .= '<p><b>From:</b> '.$GLOBAL{username};
        ($temp) = sqlQuickArray("select username from player where uid='$FORM{uid}'");
        $html .= '<br><b>To:</b> '.$temp;
	if ($FORM{item} eq "none") {
		$temp = "None";
	} else {
        	($temp) = sqlQuickArray("select name from item where id='$FORM{item}'");
	}
        $html .= '<br><b>Package:</b> '.$temp;
        $html .= '<h1>Step 3: Write A Message</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if (account::paidToPlay($GLOBAL{'uid'})) {
                        $html .= '<form method="post"><input type="hidden" name="op" value="mailSend">';
			$html .= '<input type="hidden" name="ai" value="'.$FORM{ai}.'">';
			$html .= '<input type="hidden" name="uid" value="'.$FORM{uid}.'">';
			$html .= '<input type="hidden" name="item" value="'.$FORM{item}.'">';
			$html .= '<textarea name="message" rows=6 cols=40></textarea>';
			$html .= '<input type="image" src="/send.gif" border=0></form>';
                } else {
                        $msg = 'You must Pay to Play to use the postal system.';
                        messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                        $html .= $msg."<p>";
                }
        } else {
                $msg = "You cannot use a post office that you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
sub mailRead {
        my ($html, %location, %amenity, $a, @data, $msg);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $html = '<h1>Read Your Mail</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if (account::paidToPlay($GLOBAL{'uid'})) {
			if ($FORM{messageId} ne "") {
				@data = sqlQuickArray("select postOffice.messageId, player.username, postOffice.message, postOffice.package from postOffice,player where postOffice.messageId=$FORM{messageId} and postOffice.sender=player.uid and postOffice.recipient=$GLOBAL{uid}");
				if ($data[0] > 0) {
					$html .= '<b>From:</b> '.$data[1].'<br>';
					$html .= '<b>To:</b> '.$GLOBAL{username}.'<br>';
					$html .= '<b>Message:</b> '.$data[2].'<br>';
					if ($data[3] > 0) {
						equipment::addItemToUser($GLOBAL{uid},$data[3],1);
						@data = sqlQuickArray("select name from item where id='$data[3]'");
						$html .= '<p>This package contained '.aVSan($data[0]).', which has been added to your inventory.<p>';
					}
					($a) = sqlQuery("delete from postOffice where messageId=$FORM{messageId}"); 
					sqlFinish($a);
				} else {
					$msg = "You can't view messages that aren't yours.";
                        		messageLog::caughtCheating($GLOBAL{'uid'},$msg);
				}
			}
			$html .= '<p><table border=1>';
			$a = sqlQuery("select postOffice.messageId, player.username, substring(postOffice.message,1,50) from postOffice,player where postOffice.sender=player.uid and postOffice.recipient=$GLOBAL{uid}");
			while (@data = sqlArray($a)) {
				$html .= '<tr><td><a href="game.pl?op=mailRead&ai='.$FORM{ai}.'&messageId='.$data[0].'">'.$data[1].'</a></td><td>'.$data[2].'</td></tr>';
			}
			$html .= '</table><p>';
                } else {
                        $msg = 'You must Pay to Play to use the postal system.';
                        messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                        $html .= $msg."<p>";
                }
        } else {
                $msg = "You cannot use a post office that you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
# mailRecipient()
# return: html
sub mailRecipient {
        my ($html, %location, %amenity, $a, $temp, @data, $msg);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $html = '<h1>Send Mail</h1> You can send mail messages and packages using the local postal service. Your messages and packages will be available to the recipient at any local government building. Each message or package you send will cost you 5 $tandards.';
	$html .= '<p><b>From:</b> '.$GLOBAL{username};
        $html .= '<h1>Step 1: Choose A Recipient</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if (account::paidToPlay($GLOBAL{'uid'})) {
        		if ($FORM{'doit'} eq "find") {
                		$html .= '
                		<form action="game.pl" method="post">
                		<input type="hidden" name="op" value="mailItem">
                        	<input type="hidden" name="ai" value="'.$FORM{ai}.'">
                		';
                		($a) = sqlQuery("select uid,username from player where username like '".$FORM{'username'}."\%' order by username");
                		while (@data = sqlArray($a)) {
                        		$temp .= '<option value="'.$data[0].'">'.$data[1];
                		}
                		sqlFinish($a);
				if ($temp ne "") {
					$html .= '<select name="uid">'.$temp.'</select><input type="image" src="/send.gif">';
				} else {
					$html .= '<b>There are no players by that name.</b><p>';
				}
                		$html .= ' </form> ';
        		}
                	$html .= '
                	Who would you like to send a package or message to?
                	<form action="game.pl" method="post">
                	<input type="hidden" name="op" value="mailRecipient">
                       	<input type="hidden" name="ai" value="'.$FORM{ai}.'">
                	<input type="hidden" name="doit" value="find">
                	<input type="text" name="username">
                	<input type="submit" value="search for this user">
                	</form>
                	';
                } else {
                        $msg = 'You must Pay to Play to use the postal system.';
                        messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                        $html .= $msg."<p>";
                }
        } else {
                $msg = "You cannot use a post office that you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
sub mailSend {
        my ($html, %location, %amenity, $a, @data, $temp, $msg);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $html .= '<p><b>From:</b> '.$GLOBAL{username};
        ($temp) = sqlQuickArray("select username from player where uid='$FORM{uid}'");
        $html .= '<br><b>To:</b> '.$temp;
        if ($FORM{item} eq "none") {
                $temp = "None";
        } else {
                ($temp) = sqlQuickArray("select name from item where id='$FORM{item}'");
        }
        $html .= '<br><b>Package:</b> '.$temp;
        $html .= '<br><b>Message:</b> '.$FORM{message};
        $html .= '<h1>Step 4: Sending Message</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if (account::paidToPlay($GLOBAL{'uid'})) {
			if (equipment::deleteItemFromUser($GLOBAL{uid},1,5)) {
				if ($FORM{item} eq "none") {
					$a = sqlQuery("insert into postOffice set sender=$GLOBAL{uid}, recipient=$FORM{uid}, message=".quote($FORM{message})); sqlFinish($a);
					$html .= "Message sent!<p>";
					messageLog::newMessage($FORM{uid},"player","mail","You have a message waiting for you at the post office.");
				} elsif (equipment::deleteItemFromUser($GLOBAL{uid},$FORM{item},1)) {
					$a = sqlQuery("insert into postOffice set sender=$GLOBAL{uid}, recipient=$FORM{uid}, package=$FORM{item}, message=".quote($FORM{message})); sqlFinish($a);
					$html .= "Package delivered!<p>";
					messageLog::newMessage($FORM{uid},"player","mail","You have a package waiting for you at the post office.");
				} else {
					$html .= "You can't send an item you don't have.<p>";
				}
			} else {
				$html .= "You don't have enough money to send a message via the post office.<p>";
			}
                } else {
                        $msg = 'You must Pay to Play to use the postal system.';
                        messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                        $html .= $msg."<p>";
                }
        } else {
                $msg = "You cannot use a post office that you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
# unbankItem()
# return: html
sub unbankItem {
        my ($html, %location, %amenity, $a, @data, $msg);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $html .= '<h1>Unbank An Item</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if (account::paidToPlay($GLOBAL{'uid'})) {
                        $html .= '<table width="100%"><tr><td valign="top">';
                        if ($FORM{'item'} ne "") {
                                $html .= "Unbanking item...<br>";
                                ($a) = sqlQuery("select id from bank where uid=".$GLOBAL{'uid'}." and itemId=".$FORM{'item'});
                                @data = sqlArray($a);
                                sqlFinish($a);
                                if ($data[0] ne "") {
                                        $html .= "Done.<br>";
                                        ($a) = sqlQuery("delete from bank where id=".$data[0]);
                                        sqlFinish($a);
					equipment::addItemToUser($GLOBAL{'uid'},$FORM{'item'},1);
                                } else {
                                	$html .= "You can't unbank an item that's not yours.<br>";
                                }
                                $html .= '</td><td valign="top">';
                        }
                        $html .= '<table cellpadding=2 cellspacing=0 border=1 align="center"><tr><th>Item</th><th>Unbank!</th></tr>';
                        ($a) = sqlQuery("select bank.itemId,item.name from bank,item where bank.uid=".$GLOBAL{'uid'}." and bank.itemId=item.id order by item.name");
                        while (@data = sqlArray($a)) {
                                $html .= '<tr><form method="post"><input type="hidden" name="op" value="unbankItem"><input type="hidden" name="ai" value="'.$FORM{'ai'}.'"><td align="center"><input type="hidden" name="item" value="'.$data[0].'">'.$data[1].'</td><td><input type="image" src="/unbank.gif" border=0></td></form></tr>';
                        }
                        sqlFinish($a);
                        $html .= '</table><p>';
                        $html .= '</td></tr></table><p>';
                        $html .= '<i><b>Note:</b> Unbanking an item costs you nothing.</i><p>';
                } else {
                        $msg = "You must Pay to Play to use the bank.";
                        messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                        $html .= $msg."<p>";
                }
        } else {
                $msg = "You cannot use a bank that you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
# viewClanhallLocations()
# return: html
sub viewClanhallLocations {
        my ($html, %location, %amenity, $a, @data, $msg, $clan);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $clan = health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan");
        $html .= '<h1>'.$clan.' Clanhall Locations</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if ($clan ne "") {
                        ($a) = sqlQuery("select map.name,map.x,map.y from map,mapAttributes where mapAttributes.sectorId=map.id and mapAttributes.class='amenity' and mapAttributes.type='clanhall' and mapAttributes.value='".$clan." Clanhall'");
                        $html .= '<table align="center"><tr><th>City</th><th>Sector</th></tr>';
                        while (@data = sqlArray($a)) {
                                $html .= '<tr><td>'.$data[0].'</td><td>'.$data[1].'-'.$data[2].'</td></tr>';
                        }
                        sqlFinish($a);
                        $html .= '</table><p>';
                }
        } else {
                $msg = "You use a building you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}

#------------------------------------
# viewClanMembership()
# return: html
sub viewClanMembership {
        my ($html, %location, %amenity, $a, @data, $msg, $clan);
        %location = gameMap::getLocationProperties($GLOBAL{'uid'});
        %amenity = gameMap::getAmenityProperties($FORM{'ai'});
        $clan = health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan");
        $html .= '<h1>'.$clan.' Membership</h1>';
        if ($amenity{'sectorId'} == $location{'sectorId'}) {
                if ($clan ne "") {
			($a) = sqlQuery("select player.username,player.email,player.icq from player,playerAttributes where player.uid=playerAttributes.uid and playerAttributes.class='attribute' and playerAttributes.type='clan' and playerAttributes.value='".$clan."'");
			$html .= '<table align="center"><tr><th>Player</th><th>Email Address</th><th>ICQ Number</th></tr>';
			while (@data = sqlArray($a)) {
				$html .= '<tr><td>'.$data[0].'</td><td>'.$data[1].'</td><td>'.$data[2].'</td></tr>';
			}
			sqlFinish($a);
			$html .= '</table><p>';
                }
        } else {
                $msg = "You use a building you are not near.";
                messageLog::caughtCheating($GLOBAL{'uid'},$msg);
                $html .= $msg."<p>";
        }
        $html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
        return $html;
}



1;

