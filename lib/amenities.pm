package amenities;
# load default modules
use strict;
use Exporter;

use equipment;
use gameMap;
use messageLog;
use renown;
use skills;
use turns;
use utility;

# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&apprentice &talkToStranger &copyMap &processQuest &rentRoom &cure &removeRad &gossip &playSlots &repair &talkToBartender &sell &buy &amenityMenu);

#------------------------------------
# amenityMenu()
# return: html
sub amenityMenu {
	my ($html, $clan, %amenity, %location, $affinity);
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	$html .= '<h1>'.$amenity{'name'}.'</h1>';
	$affinity = gameMap::processAffinity($GLOBAL{'uid'},$location{'sectorId'});
	if ($affinity eq "") {
		if ($amenity{'type'} eq "market") {
			$html .= '
			<img src="/side/market.jpg" border=1 width=180 height=400 align="right">
			You\'ve discovered a small, but bustling market. The people here have many goods to buy, and if
			you\'ve got something to sell, they\'re happy to take it off your hands for a reasonable price.
			<ul>
			<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
			<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
			</ul>
			';
                } elsif ($amenity{'type'} eq "government") {
			unless (account::paidToPlay($GLOBAL{'uid'})) {
	                        $html .= '
        	                Government is only of use to its citizens. If you want to use these features you must
				<a href="aux.pl?op=showPaymentOptions">Pay To Play</a>. If you choose to Pay To Play, you\'ll get
				a huge number of benefits over the freeplay envrionment you\'re in right now. 
				<p>
				If you were to Pay to Play right now you\'d get these features at the government building and many more
				at other places in the game:
				<ul>
				<li>You can bank items (the items stay in the bank even if you are killed).
				<li>You can join clans (which provide comradrie, specialty items, special abilities, and other help).
				</ul>
				';
			} else {
				$html .= '
                        	<ul>
                        	<li><a href="game.pl?op=bankItem&ai='.$FORM{ai}.'">Bank an item.</a>
                        	<li><a href="game.pl?op=clanSignup&ai='.$FORM{ai}.'">Join a clan.</a>
                        	<li><a href="game.pl?op=mailRead&ai='.$FORM{ai}.'">Read mail.</a>
                        	<li><a href="game.pl?op=mailRecipient&ai='.$FORM{ai}.'">Send a mail message or package.</a>
                        	<li><a href="game.pl?op=unbankItem&ai='.$FORM{ai}.'">Unbank an item.</a>
                        	</ul>
                        	';
			}
                } elsif ($amenity{'type'} eq "clanhall") {
			$clan = health::getUnmodifiedAttribute($GLOBAL{'uid'},"clan");
                        unless ($clan." Clanhall" eq $amenity{'name'}) {
                                $html .= $amenity{'name'}.' is only for its members. If you want to use this building you must
                                go to a government building and register as a member of this clan.  ';
                        } else {
                                $html .= '
                                <ul>
                                <li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
				<li><a href="game.pl?op=gossip&ai='.$FORM{ai}.'">Gossip.</a>
                                <li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
                                <li><a href="game.pl?op=viewClanhallLocations&ai='.$FORM{ai}.'">View clanhall locations.</a>
                                <li><a href="game.pl?op=viewClanMembership&ai='.$FORM{ai}.'">View clan membership.</a>
                                </ul>
                                ';
                        }
		} elsif ($amenity{'type'} eq "auction") {
			$html .= '
			The only measure of a true economy is its open market for free trade between individuals. The
			finest example of this in the deadEarth world is the auction.
			<ul>
			<li><a href="game.pl?op=bid&ai='.$FORM{ai}.'">Bid on an item.</a>
			<li><a href="game.pl?op=auction&ai='.$FORM{ai}.'">Auction off an item.</a>
			</ul>
			';
		} elsif ($amenity{'type'} eq "trade depot") {
                        unless (account::paidToPlay($GLOBAL{'uid'})) {
                                $html .= '
                                If you were to <a href="aux.pl?op=showPaymentOptions">Pay To Play</a> you\'d be able to gain access
				to all of the very rare items available in the trade depots around the map. Things like Type IV Body Armor,
				.50 Caliber Rifles, and valuable military gear. Pay to Play now!
                                ';
                        } else {
				$html .= '
				<img src="/side/tradedepot.jpg" border=1 width=180 height=400 align="right">
				You think to yourself, "Self. Holy shit!" You\'ve come across a trade depot. 
				This place is bound to be filled with all sorts of goodies, if you can only afford them.
				<ul>
				<li><a href="game.pl?op=apprentice&ai='.$FORM{ai}.'">Apprentice.</a>
				<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
				<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
				</ul>
				';
			}
		} elsif ($amenity{'type'} eq "doctor") {
			$html .= '
			This place is sure to have a cure for what\'s ailing you.
			<ul>
			<li><a href="game.pl?op=apprentice&ai='.$FORM{ai}.'">Apprentice.</a>
			<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
			<li><a href="game.pl?op=cure&ai='.$FORM{ai}.'">Cure what ales me.</a>
			<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
			</ul>
			';
		} elsif ($amenity{'type'} eq "restaurant") {
			$html .= '
			You have located a quaint little restaurant.
			<ul>
			<li><a href="game.pl?op=apprentice&ai='.$FORM{ai}.'">Apprentice.</a>
			<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
			<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
			</ul>
			';
		} elsif ($amenity{'type'} eq "tavern") {
			$html .= '
			<img src="/side/tavern.jpg" border=1 width=180 height=400 align="right">
			A tavern is a one-stop-shop for a weary traveler. Feel free to partake in any of its available 
	activities.
			<ul>
			<li><a href="game.pl?op=apprentice&ai='.$FORM{ai}.'">Apprentice.</a>
			<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
			<li><a href="game.pl?op=gossip&ai='.$FORM{ai}.'">Gossip.</a>
			<li><a href="game.pl?op=playSlots&ai='.$FORM{ai}.'">Play the slot machine.</a>
			<li><a href="game.pl?op=rentRoom&ai='.$FORM{ai}.'">Rent a room.</a>
			<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
			<li><a href="game.pl?op=talkToBartender&ai='.$FORM{ai}.'">Talk to the bartender.</a>
			<li><a href="game.pl?op=talkToStranger&ai='.$FORM{ai}.'">Talk to the stranger in the corner.</a>
			</ul>
			';
		} elsif ($amenity{'type'} eq "blacksmith") {
			$html .= '
			<img src="/side/blacksmith.jpg" border=1 width=180 height=400 align="right">
			Finally, a chance at a decent weapon and maybe even some armor.
			<ul>
			<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
			<li><a href="game.pl?op=repair&ai='.$FORM{ai}.'">Repair an item.</a>
			<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
			</ul>
			';
		} elsif ($amenity{'type'} eq "geneticist") {
                        unless (account::paidToPlay($GLOBAL{'uid'})) {
                                $html .= '
                                If you were to <a href="aux.pl?op=showPaymentOptions">Pay To Play</a> you\'d be able to gain access
                                the healing skills of a geneticist. The geneticist can manipulate mutation in ways unimagined by most.
				A very valuable asset in a world of radiated waste. Pay to Play now! 
                                ';
                        } else {
				$html .= '
				<img src="/side/geneticist.jpg" border=1 width=180 height=400 align="right">
				This place may look like something straight out of an old movie, but maybe you can
				lose your third eye here.
				<ul>
				<li><a href="game.pl?op=removeRad&ai='.$FORM{ai}.'">Be cleansed.</a>
				<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
				<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
				</ul>
				';
			}
		} elsif ($amenity{'type'} eq "library") {
			$html .= '
			<img src="/side/library.jpg" border=1 width=180 height=400 align="right">
			All the knowledge in the world could be gained here....maybe.
			<ul>
			<li><a href="game.pl?op=apprentice&ai='.$FORM{ai}.'">Apprentice.</a>
			<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy an item.</a>
			<li><a href="game.pl?op=copyMap&ai='.$FORM{ai}.'">Copy a map.</a>
			<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell an item.</a>
			</ul>
			';
		} elsif ($amenity{'type'} eq "pet store") {
			$html .= '
			<img src="/side/petstore.jpg" border=1 width=180 height=400 align="right">
			When you need a friend, humans aren\'t trustworthy. Perhaps you can find a friend here.
			<ul>
			<li><a href="game.pl?op=apprentice&ai='.$FORM{ai}.'">Apprentice.</a>
			<li><a href="game.pl?op=buy&from='.$FORM{ai}.'">Buy a pet.</a>
			<li><a href="game.pl?op=sell&to='.$FORM{ai}.'">Sell a pet.</a>
			</ul>
			';
		}
	} else {
		$html .= $affinity;
	}	
	return $html;
}

#------------------------------------
# apprentice
# return: html
sub apprentice {
	my ($output, $skill, %location, %amenity, @statement, $cost, $temp);
	$cost = 2500;
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$output = "<h1>Apprenticeship</h1>";
	if ($amenity{sectorId} eq $location{sectorId}) {
		if ($amenity{type} eq "doctor") {
			$skill = "first aid";
		} elsif ($amenity{type} eq "restaurant") {
			$skill = "domestics";
                } elsif ($amenity{type} eq "tavern") {
                        $skill = "troubadour";
		} elsif ($amenity{type} eq "library") {
			$skill = "navigate";
		} elsif ($amenity{type} eq "pet store") {
			$skill = "beast lore";
		} elsif ($amenity{type} eq "trade depot") {
			$skill = "haggle";
		} else {
			$skill = "nothing";
		}
        	@statement = ("I can train you in the art of XX for only \$$cost.",
                	"Do you wish to learn the ins and outs of XX for the low-low price of \$$cost?",
                	"For only \$$cost I can teach you much about XX.",
                	"If you are willing to learn, and have \$$cost, I'll teach you about XX.",
                	"There is much you need to know about XX. For \$$cost I'll teach you.",
			"If you wish to grow wise in XX more quickly, pay me \$$cost and I'll take you on as my apprentice.",
			"I offer an apprenticeship in XX for only \$$cost."
                	);
        	$temp = $statement[rollDice(1,($#statement+1))-1];
        	$temp =~ s/XX/$skill/ig;
		if ($skill ne "nothing") {
			$output .= '<table cellpadding=5><tr><td width="50%" valign="top">';
			$output .= $temp;
			$output .= '<p>Do you wish to pay the fee and be trained in '.$skill.'?<p>';
			$output .= '<a href="game.pl?op=apprentice&doit=Yes&ai='.$FORM{'ai'}.'">Yes, I would.</a><p>';
			$output .= '</td><td width="50%" valign="top">';
			if ($FORM{doit} eq "Yes") {
				$output .= 'Training...<br>';
				if (equipment::deleteItemFromUser($GLOBAL{uid},1,$cost)) {
					if (turns::spendTurns($GLOBAL{uid},30)) {
						equipment::addItemToStore($FORM{ai},1,$cost);
						skills::addSkillPoint($GLOBAL{uid},$skill,(80+rollDice(1,40)));	
						$output .= "You feel educated!<br>";	
					} else {
						$output .= "You don't have enough turns to train right now.<br>";
						$output .= "<i>Thanks for payin', but it's not my problem if you don't have time to train!</i><br>";
					}
				} else {
					$output .= "You don't have enough money to apprentice!<br>";
				}
			}
			$output .= '</td></tr></table>';
		} else {
                	$output .= "Cheaters can't apprentice.<p>";
                	messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to purchase an apprenticeship from a vendor that doesn't train.");
		}
	} else {
                $output .= "Cheaters can't apprentice.<p>";
                messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to purchase an apprenticeship from a nonexistant vendor.");
	}	
	$output .= '<p><a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $output;
}

#------------------------------------
# buy(fromWhere)
# return: html
sub buy {
	my ($html, %location, %amenity, $a, @data, $item, @items, $i, $haggle, $price, $flag);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'from'});
	$haggle = skills::getSkillLevel($GLOBAL{'uid'},"haggle",1);
	if ($haggle < 1) { $haggle = 1; }
	$haggle = rollDice($haggle,6);
	$html .= '<h1>Buy</h1>';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top">';
		if ($FORM{'item'} ne "") {
			$html .= "Purchasing items...<br>";
			if (turns::spendTurns($GLOBAL{'uid'},2)) {
				$haggle = skills::upSkillLevel($GLOBAL{'uid'},"haggle");
				($flag,$item,$price) = decryptPriceAndItem($FORM{'item'});
				if ($flag == 1) {
					$flag = equipment::buyItem($GLOBAL{'uid'},$FORM{'from'},$item,$FORM{'quantity'},$price);
					if ($flag == 1) {
						$html .= "Transaction completed.<br>";
						%amenity = gameMap::getAmenityProperties($FORM{'from'}); # reget amenity properties to account for sale
					} elsif ($flag == -1) {
						$html .= "You do not have enough money to complete the transaction.<br>";
					} else {
						$html .= $amenity{'name'}." does not currently have ".$FORM{'quantity'}." of that item in stock.<br>";
					}
				} else {
					$html .= "Cheaters can't purchase anything in Survival of the Fittest.<p>";
					messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to purchase an item that does not exist.");
				}
			} else {
				$html .= "You do not have enough turns to complete the transaction.<br>";
			}
			$html .= '</td><td valign="top">';
		}
		foreach $item (keys %{$amenity{'item'}}) {
			$items[$i] = $item;
			$i++;
		}
		if ($items[0] ne "") {
			$html .= 'This '.$amenity{'type'}.' has these fine items to offer you:<p>';
			$html .= '<table cellpadding=2 cellspacing=0 border=1 align="center"><tr><th>Quantity</th><th>Item</th><th>Price</th><th>Buy!</th></tr>';
			($a) = sqlQuery("select id,name,cost from item where id in (".join(",",@items).") order by name");
			while (@data = sqlArray($a)) {
				$price = hagglePurchase($GLOBAL{'uid'},$data[2],$amenity{'item'}{$data[0]});
				if ($price > 0) {
  					$html .= '<tr><form method="post"><input type="hidden" name="op" value="buy"><input type="hidden" name="from" value="'.$FORM{'from'}.'"><td align="center"><input type="hidden" name="item" value="'.encryptPriceAndItem($data[0],$price).'"><select name="quantity">';
					$html .= selectList($amenity{'item'}{$data[0]});
					$html .= '</select></td><td>'.$data[1].'</td><td align="right">$'.$price.'</td><td><input type="image" src="/buy.gif" border=0></td></form></tr>';
				}
			}
			sqlFinish($a);
			$html .= '</table><p>';
		} else {
			$html .= $amenity{'name'}." does not have anything for sale.<p>";
		}
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't purchase anything in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to purchase an item from a vendor whom you are not a patron of.");
	}	
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'from'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# completeQuest(userId, amenityId)
# return: html
sub completeQuest {
	my ($html, $a, @data, $b, @dataB);
	($a) = sqlQuery("select quests.goalItem, quests.goalQuantity, quests.prizeItem, quests.prizeQuantity, playerAttributes.id, quests.id from playerAttributes,quests where playerAttributes.uid=".$_[0]." and playerAttributes.class='quest' and playerAttributes.type=quests.id and playerAttributes.value='".$_[1]."'");
	while (@data = sqlArray($a)) {
		($b) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='item' and type='".$data[0]."'");
		@dataB = sqlArray($b);
		sqlFinish($b);		
		if ($dataB[0] >= $data[1]) {
			equipment::deleteItemFromUser($_[0],$data[0],$data[1]);
			equipment::addItemToUser($_[0],$data[2],$data[3]);
			$html = "I see you aquired the ".pluralize("item",$data[1])." I was looking for. As promised, here's a little something for you.<br>";
			($b) = sqlQuery("delete from playerAttributes where id=".$data[4]);
			sqlFinish($b);	
			renown::addDeed($_[0],"quests",$data[5],1);
		}
	}
	sqlFinish($a);					
	return $html;
}

#------------------------------------
# copyMap()
# return: html
sub copyMap {
	my ($html, %location, %amenity, $a, @data, $rollOne, $rollTwo, $rollThree, $winnings);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= '<h1>Copy A Map</h1>';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top" width="50%">';
		$html .= 'Which map would you like to copy?<p>
				<form action="game.pl" method="post">
				<input type="hidden" name="ai" value="'.$FORM{'ai'}.'">
				<input type="hidden" name="op" value="copyMap"><table width="100%">
				<tr><th>&nbsp;</th><th>Map</th><th>Cost</th></tr>
		';
		($a) = sqlQuery("select item.id,item.name,item.cost from playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type='map'");
		while (@data = sqlArray($a)) {
			$html .= '<tr><td><input type="radio" name="mapId" value="'.$data[0].'"></td><td>'.$data[1].'</td><td>$'.round($data[2]*0.95).'</td></tr>';
		}
		sqlFinish($a);
		$html .= '</table>
				<input type="submit" value="Copy!"></form><p>
				<b>Note:</b> Map copying will cost you 25 turns.
			';
		$html .= '</td><td valign="top">';
		if ($FORM{'mapId'} ne "") {
			$html .= "Copying map...<br>";
			if (equipment::searchForItem($GLOBAL{'uid'},$FORM{'mapId'})) {
				($a) = sqlQuery("select cost from item where id=".$FORM{'mapId'});
				@data = sqlArray($a);
				sqlFinish($a);
				if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,round($data[0]*0.95))) {
					if (turns::spendTurns($GLOBAL{'uid'},25)) {
						$html .= "Map copied.<br>";
						equipment::addItemToUser($GLOBAL{'uid'},$FORM{'mapId'},1);
					} else {
						$html .= "You don't have enough turns to copy the map.<p>";
						equipment::addItemToUser($GLOBAL{'uid'},1,round($data[0]*0.95));
					}
				} else {
					$html .= "You don't have enough money to copy the map.<p>";
				}
			} else {
				$html .= "You don't have that map.<p>";
				messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to copy a map that you don't have.");
			}
		}
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't copy maps in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to copy a map at a non-existant library.");
	}	
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# cure(amenityId)
# return: html
sub cure {
	my ($html, %location, %amenity, $a, @data, $wounds, $poison, $drunk);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= '<h1>Cure</h1>';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top" width="50%">';
		$html .= 'Hey there, I\'ve got the cure for what ales you. Do you have the cash?<br>';
		$html .= '<a href="game.pl?op=cure&ai='.$FORM{'ai'}.'&doit=yes">Yep, let\'s do it!</a><p>';
		$html .= '<b>Note:</b> For $75, all your wounds will be healed, and your body will be drained of all toxins.<br>';
		if ($FORM{'doit'} eq "yes") {
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,75)) {
				$html .= '</td><td valign="top">';
				equipment::addItemToStore($FORM{'ai'},1,75);
				$wounds = health::getInjury($GLOBAL{'uid'});
				$poison = health::getAttribute($GLOBAL{'uid'},"poison");
				$drunk = health::getAttribute($GLOBAL{'uid'},"drunk");
				$html .= "Healing...<br>";
				if ($wounds > 0) {
					$html .= "Wounds healed.<br>";
					health::setAttribute($GLOBAL{'uid'},"health",20);
				}	
				if ($poison > 0) {
					$html .= "Poison removed.<br>";
					health::setAttribute($GLOBAL{'uid'},"poison",0);
				}	
				if ($wounds > 0) {
					$html .= "Drunken stupor sobered.<br>";
					health::setAttribute($GLOBAL{'uid'},"drunk",0);
				}	
			}	
		}
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't be healed in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to be healed by a non-existant physician.");
	}	
	$html .= '<p><a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# decryptPriceAndItem(encryptedForm)
# return: verifiedFlag, item, price
sub decryptPriceAndItem {
	my ($price, $item, $verified, $division, $concat);
	$price = $item = $division = $concat = $_[0];
	$item =~ s/(.*aq)(.*)(wCd.*)/$2/;
	$price =~ s/(.*o89p)(.*)(ymYz.*)/$2/;
	$division =~ s/(.*wCd)(.*)o89p.*/$2/;
	$concat =~ s/(.*tog)(.*)(bud.*)/$2/;
	$verified = 0;
	if (($division == round($price/$item)) && ($concat eq ($price.$item))) {
		$verified = 1;
	}
	return ($verified, $item, $price);
}

#------------------------------------
# encryptPriceAndItem(itemId, price)
# return: encryptedForm
sub encryptPriceAndItem {
	my ($encrypted);
	$encrypted = 'kLor'.rollDice(3,3).'mDk1020fQw'.rollDice(5,5).'aq'.$_[0].'wCd'.round($_[1]/$_[0]).'o89p'.$_[1].'ymYz'.rollDice(2,10).'Mn49tB196poD'.rollDice(6,4).'tog'.$_[1].$_[0].'bud';
	return $encrypted;
}

#------------------------------------
# gossip()
# return: html
sub gossip {
	my ($a, @data, %location, %amenity, $b, $html, $troubadour, $postingLocations);
	$html .= "<h1>Gossip</h1>";
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		if ($FORM{'doit'} eq "start") {
			$html .= '
				<form method="post" action="game.pl">
				<input type="hidden" name="op" value="gossip">
				<input type="hidden" name="doit" value="finish">
				<input type="hidden" name="ai" value="'.$FORM{'ai'}.'">
				<select name="deedId">
				<option value="0">Plain old gossip!
			';
			($a) = sqlQuery("select id,description from deeds where uid=".$GLOBAL{uid}." and completed<1");
			while ((@data) = sqlArray($a)) {
				$html .= '<option value="'.$data[0].'">'.$data[1];
			}
			sqlFinish($a);
			$html .= '
				</select><br>
				<textarea name="message" cols=40 rows=5 wrap="virtual"></textarea>
				<input type="submit" value="Tell it!">
				</form>
			';
		} elsif ($FORM{'doit'} eq "finish") {
			($a) = sqlQuery("insert into gossip set amenityId=".$FORM{'ai'}.", username=".quote($GLOBAL{'username'}).", message=".quote($FORM{'message'}).", deedId=".$FORM{'deedId'}); sqlFinish($a);
			$troubadour = skills::useSkill($GLOBAL{uid},"troubadour");
			if ($FORM{'deedId'} ne "0") {
				$postingLocations = round($troubadour/12);
				if (length($FORM{'message'}) > 100) {
					($a) = sqlQuery("select id from mapAttributes where (type='tavern' or type='clanhall') order by rand() limit ".$postingLocations);
					while (@data = sqlArray($a)) {
						($b) = sqlQuery("insert into gossip set amenityId=".$data[0].", username=".quote($GLOBAL{'username'}).", message=".quote($FORM{'message'}).", deedId=".$FORM{'deedId'}); sqlFinish($b);
					}
					sqlFinish($a);
				}
				($a) = sqlQuery("select distinct count(*) from gossip where deedId=".$FORM{'deedId'});
				@data = sqlArray($a);
				sqlFinish($a);
				if ($data[0] >= 5) {
					renown::completeDeed($FORM{'deedId'});
				}
			}
			$html .= "Gossip started.<br>";
		}
		($a) = sqlQuery("select username,message from gossip where amenityId='".$FORM{'ai'}."' order by id desc limit 10");
		while (@data = sqlArray($a)) {
			$html .= $data[0].' said, "'.$data[1].'"<p>';
		}
		sqlFinish($a);
		$html .= '<a href="game.pl?op=gossip&doit=start&ai='.$FORM{'ai'}.'">Start some new gossip.</a><p>';
	} else {
		$html .= "Cheaters can't gossip in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to gossip in a non-existant tavern.");
	}	
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# hagglePurchase(haggleRoll, realCost, quantityInStock)
# return: haggledPrice
sub hagglePurchase {
	my ($price);
	# adjust for player skill
	if ($_[0] < 5) {
		$price = round($_[1]*3);
	} elsif ($_[0] < 10) {
		$price = round($_[1]*2.5);
	} elsif ($_[0] < 15) {
		$price = round($_[1]*2);
	} elsif ($_[0] < 20) {
		$price = round($_[1]*1.5);
	} elsif ($_[0] < 25) {
		$price = round($_[1]*1);
	} elsif ($_[0] < 30) {
		$price = round($_[1]*0.95);
	} elsif ($_[0] < 35) {
		$price = round($_[1]*0.85);
	} elsif ($_[0] < 40) {
		$price = round($_[1]*0.80);
	} elsif ($_[0] < 45) {
		$price = round($_[1]*0.75);
	} elsif ($_[0] < 50) {
		$price = round($_[1]*0.70);
	} elsif ($_[0] < 55) {
		$price = round($_[1]*0.65);
	} elsif ($_[0] < 60) {
		$price = round($_[1]*0.60);
	} elsif ($_[0] < 65) {
		$price = round($_[1]*0.55);
	} else {
		$price = round($_[1]*0.50);
	}        
	# adjust for supply and demand (with a small cheat factor to help vendors)
	if ($_[3] < 2) {
                $price = round($price/0.5);
        } elsif ($_[3] < 6) {
                $price = round($price/0.6);
        } elsif ($_[3] < 11 ) {
                $price = round($price/0.7);
        } elsif ($_[3] < 16 ) {
                $price = round($price/0.8);
        } elsif ($_[3] < 21 ) {
                $price = round($price/0.9);
        } elsif ($_[3] < 50 ) {
                $price = round($price/1);
        } elsif ($_[3] < 100) {
                $price = round($price/1.1);
        } else {
                $price = round($price/1.2);
        }
	return $price;
}

#------------------------------------
# haggleSale(haggleRoll, realPrice, divisor, quantityInStock)
# return: haggledPrice
sub haggleSale {
	my ($price, $modifiedHaggle);
	# adjust for vendor
	$modifiedHaggle = round($_[0]/$_[2]);
	# adjust for skill
	if ($modifiedHaggle < 5) {
		$price = round($_[1]/3);
	} elsif ($modifiedHaggle < 10) {
		$price = round($_[1]/2.5);
	} elsif ($modifiedHaggle < 15) {
		$price = round($_[1]/2);
	} elsif ($modifiedHaggle < 20) {
		$price = round($_[1]/1.5);
	} elsif ($modifiedHaggle < 25) {
		$price = round($_[1]/1);
	} elsif ($modifiedHaggle < 30) {
		$price = round($_[1]/0.95);
	} elsif ($modifiedHaggle < 35) {
		$price = round($_[1]/0.90);
	} elsif ($modifiedHaggle < 40) {
		$price = round($_[1]/0.85);
	} elsif ($modifiedHaggle < 45) {
		$price = round($_[1]/0.80);
	} elsif ($modifiedHaggle < 50) {
		$price = round($_[1]/0.75);
	} elsif ($modifiedHaggle < 55) {
		$price = round($_[1]/0.70);
	} elsif ($modifiedHaggle < 60) {
		$price = round($_[1]/0.65);
	} elsif ($modifiedHaggle < 65) {
		$price = round($_[1]/0.60);
	} else {
		$price = round($_[1]/0.55);
	}
	# adjust for supply and demand with cheat factor in favor of vendors
	if ($_[3] < 2) {
		$price = round($price/0.80);
	} elsif ($_[3] < 3) {
		$price = round($price/0.85);
	} elsif ($_[3] < 6 ) {
		$price = round($price/0.9);
	} elsif ($_[3] < 11 ) {
		$price = round($price/0.95);
	} elsif ($_[3] < 16 ) {
		$price = round($price/1);
	} elsif ($_[3] < 21 ) {
		$price = round($price/1.1);
	} elsif ($_[3] < 26 ) {
		$price = round($price/1.2);
	} else {
		$price = round($price/1.3);
	}
	return $price;
}

#------------------------------------
# playSlots()
# return: html
sub playSlots {
	my ($html, %location, %amenity, $a, @data, $rollOne, $rollTwo, $rollThree, $winnings);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= '<h1>Play Slots</h1>';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top">';
		$html .= 'Do you want to play the slots?
				<a href="game.pl?op=playSlots&ai='.$FORM{'ai'}.'&doit=yes">Yes, let me play!</a> (1 turn, 1 $tandard);
			';
		$html .= '</td><td valign="top"><img src="/side/slotmachine.jpg" border=1 width=180 height=400></td><td valign="top">';
		if ($FORM{'doit'} eq "yes") {
			$html .= "Playing Slots...<br>";
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,1)) {
				if (turns::spendTurns($GLOBAL{'uid'},1)) {
					$rollOne = rollDice(1,100); 
					$rollTwo = rollDice(1,100); 
					$rollThree = rollDice(1,100); 
					$html .= $rollOne." | ".$rollTwo." | ".$rollThree."<br>\n";
					if ($rollOne == $rollTwo && $rollTwo == $rollThree) {
						$html .= "You hit the jackpot!<br>\n";
						$winnings = $rollOne * 100;
					} elsif ($rollOne == $rollTwo || $rollTwo == $rollThree || $rollOne == $rollThree) {
						$html .= "You win!<br>\n";
						$winnings = rollDice(15,10);
					} elsif ($rollOne < 75 && $rollOne > $rollTwo && $rollTwo < $rollThree && $rollThree > 25) {
						$html .= "You win the booby prize!<br>\n";
						$winnings = rollDice(2,5);
					} else {
						$html .= "Sorry, you lose.<br>\n";	
					}
					if ($winnings > 0) {
						equipment::addItemToUser($GLOBAL{'uid'},1,$winnings);
						$html .= "You've won ".$winnings." \$tandards.<br>\n";			
					}
				} else {
					equipment::addItemToUser($GLOBAL{'uid'},1,1);
					$html .= "You don't have enough turns to play the slots.<p>";
				}
			} else {
				$html .= "You don't have enough money to play the slots.<p>";
			}
		}
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't gamble in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to play on a non-existant slot machine.");
	}	
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# processQuest()
# return: html
sub processQuest {
	my ($html, %location, %amenity, $a, @data, $ai, $questId, $questVerified, $item, @quest, $b, @dataB, $distance, $direction);
	($questVerified, $questId,$ai) = decryptPriceAndItem($FORM{'id'});
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($ai);
	$html .= "<h1>Talking to Bartender</h1>";
	$html .= '<img src="/side/bartender.jpg" border=1 width=180 height=400 align="right" hspace="5">';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		if ($questVerified) {
			$html .= "Ok, great! Get to it. I'll expect you back soon.<br>";
			($a) = sqlQuery("insert into playerAttributes set uid=".$GLOBAL{'uid'}.", class='quest', type='".$questId."', value='".$ai."'");
			sqlFinish($a);					
			($a) = sqlQuery("select trigger,goalItem,goalQuantity,last_insert_id() from quests where id=".$questId);
			@quest = sqlArray($a);
			sqlFinish($a);					
			if ($quest[0] eq "spawn in city") {
				($a) = sqlQuery("select id,name from map where type='civilization' order by rand() limit ".$quest[2]);
				$html .= "Oh yeah, before I forget. Here's where you can find the ".pluralize("item",$quest[2])." I told you about:<ul>";
				while (@data = sqlArray($a)) {
					equipment::addItemToSector($data[0],$quest[1],1,rollDice(5,5));
					$html .= "<li>".$data[1];
				}
				sqlFinish($a);					
				$html .= "</ul>You had better hurry!.<br>";
			} elsif ($quest[0] eq "find and deliver") {
				($a) = sqlQuery("select map.name,mapAttributes.id from mapAttributes,map where mapAttributes.sectorId=map.id and mapAttributes.class='amenity' and mapAttributes.type='tavern' order by rand() limit 1");
				@data = sqlArray($a);
				sqlFinish($a);					
				($a) = sqlQuery("update playerAttributes set value=".$data[1]." where id=".$quest[3]);
				sqlFinish($a);					
				$html .= "Oh yeah, before I forget. You can find my fellow bartender in ".$data[0].".<p>";
			} elsif ($quest[0] eq "give and deliver") {
				equipment::addItemToUser($GLOBAL{'uid'},$quest[1],$quest[2]);
				($a) = sqlQuery("select map.name,mapAttributes.id from mapAttributes,map where mapAttributes.sectorId=map.id and mapAttributes.class='amenity' and mapAttributes.type='tavern' order by rand() limit 1");
				@data = sqlArray($a);
				sqlFinish($a);					
				($a) = sqlQuery("update playerAttributes set value=".$data[1]." where id=".$quest[3]);
				sqlFinish($a);					
				$html .= "Here's your cargo. You can find my fellow bartender in ".$data[0].".<p>";
                        } elsif ($quest[0] eq "spawn in wilderness") {
                                ($a) = sqlQuery("select map.id,mapAttributes.value,map.x,map.y from map,mapAttributes where map.type='wilderness' and map.id=mapAttributes.sectorId and mapAttributes.class='description' order by rand() limit ".$quest[2]);
                                $html .= "Oh yeah, before I forget. Here's where you can find the ".pluralize("item",$quest[2])." I told you about:<ul>";
                                while (@data = sqlArray($a)) {
					($b) = sqlQuery("select name,x,y from map where type='civilization' order by rand() limit 1");
					@dataB = sqlArray($b);
					sqlFinish($b);
                                        equipment::addItemToSector($data[0],$quest[1],1,rollDice(5,5));
					($distance, $direction) = gameMap::findDistanceAndDirection($dataB[1],$dataB[2],$data[2],$data[3]);
                                        $html .= "<li>".$data[1]." approximately ".$distance." ".pluralize("sector",$distance)." ".$direction." of ".$dataB[0];
                                }
                                sqlFinish($a);
                                $html .= "</ul>You had better hurry!.<br>";
			}
		} else {
			$html .= "You think to yourself, why am I cheating?.<p>";
			messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to accept a quest that doesn't exist.");
		}
	} else {
		$html .= "You think to yourself, why am I cheating?.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to talk to a bartender in a non-existant bar.");
	}
	$html .= '<p><a href="game.pl?op=amenityMenu&ai='.$ai.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# removeRad()
# return: html
sub removeRad {
	my ($html, %location, %amenity, $a, @data, $i, $flag);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= '<h1>Remove A Radiation</h1>';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top">';
		if ($FORM{'doit'} eq "random") {
			$html .= "Abracadabra...<br>";
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,200)) {
				if (turns::spendTurns($GLOBAL{'uid'},15)) {
					equipment::addItemToStore($FORM{'ai'},1,200);
					($a) = sqlQuery("select id from playerAttributes where uid=".$GLOBAL{'uid'}." and class='radiation' order by rand()");
					@data = sqlArray($a);
					sqlFinish($a);
					if ($data[0] ne "") {
						($a) = sqlQuery("delete from playerAttributes where id=".$data[0]); sqlFinish($a);
						$html .= "Tada!<br>Rad removed.<br>";
					} else {
						$html .= "You do not appear to have a rad to remove!<br>";
					}
				} else {
					equipment::addItemToUser($GLOBAL{'uid'},1,200);
					$html .= "You don't have enough turns to get a rad removed.<br>";
				}
			} else {
				$html .= "You don't have enough money to get a rad removed.<br>";
			}
			$html .= '</td><td valign="top">';
		} elsif ($FORM{'doit'} eq "all") {
			$html .= "Abracadabra...<br>";
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,1500)) {
				if (turns::spendTurns($GLOBAL{'uid'},15)) {
					equipment::addItemToStore($FORM{'ai'},1,1500);
					($a) = sqlQuery("delete from playerAttributes where uid=".$GLOBAL{'uid'}." and class='radiation'"); sqlFinish($a);
					$html .= "Tada!<br>All rads removed.<br>"
				} else {
					equipment::addItemToUser($GLOBAL{'uid'},1,1500);
					$html .= "You don't have enough turns to get all your rads removed.<br>";
				}
			} else {
				$html .= "You don't have enough money to get all your rads removed.<br>";
			}
			$html .= '</td><td valign="top">';
		} elsif ($FORM{'doit'} ne "") {
			$html .= "Abracadabra...<br>";
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,5000)) {
				if (turns::spendTurns($GLOBAL{'uid'},15)) {
					equipment::addItemToStore($FORM{'ai'},1,5000);
					($a) = sqlQuery("delete from playerAttributes where id=".$FORM{'doit'}); sqlFinish($a);
					$html .= "Tada!<br>Rad removed.<br>"
				} else {
					equipment::addItemToUser($GLOBAL{'uid'},1,1000);
					$html .= "You don't have enough turns to get a rad removed.<br>";
				}
			} else {
				$html .= "You don't have enough money to get a rad removed.<br>";
			}
			$html .= '</td><td valign="top">';
		}
		$html .= 'Which rad would you have removed?<p>';
		$html .= '<a href="game.pl?op=removeRad&doit=random&ai='.$FORM{'ai'}.'">Remove a random radiation.</a><br> - OR -<br>';
		$html .= '<a href="game.pl?op=removeRad&doit=all&ai='.$FORM{'ai'}.'">Remove all your radiations.</a><br> - OR -<br>Remove a specific radiation:';
		$html .= '<form method="post"><input type="hidden" name="op" value="removeRad"><input type="hidden" name="ai" value="'.$FORM{'ai'}.'">';
		($a) = sqlQuery("select id,value,type from playerAttributes where uid=".$GLOBAL{'uid'}." and class='radiation'");
		while (@data = sqlArray($a)) {
			$html .= '<input type="radio" name="doit" value="'.$data[0].'"> '.$data[1].' '.$data[2].'<br>';
		}
		sqlFinish($a);
		$html .= '<br><input type="submit" value="Remove it!"></form>';
		$html .= '</td></tr></table>';
		$html .= "<b>Note:</b> It cost 15 turns to remove a rad. In addition you'll pay \$200 for a random rad, and \$5000 for a specific rad, and \$1500 for all your rads.<br>";
	} else {
		$html .= "Cheaters can't get anything be cleansed in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to be cleansed by a geneticist whom you are not a patron of.");
	}	
	$html .= '<p><a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# rentRoom()
# return: html
sub rentRoom {
	my ($html, %location, %amenity, $a, @data, $rollOne, $rollTwo, $rollThree, $winnings);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= '<h1>Rent A Room</h1>';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top" width="50%">';
		$html .= 'You can rent one of the rooms above the tavern 
				for your stay in town. It is probably safer than sleeping on the streets.<p>
				<a href="game.pl?op=rentRoom&ai='.$FORM{'ai'}.'&doit=yes">Yeah, I\'ll take that room.</a>
				<p>
				<b>Note:</b> Renting a room will cost you 5 turns and 200 $tandards.
			';
		$html .= '</td><td valign="top">';
		if ($FORM{'doit'} eq "yes") {
			$html .= "Renting room...<br>";
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,200)) {
				if (turns::spendTurns($GLOBAL{'uid'},5)) {
					equipment::addItemToStore($FORM{'ai'},1,200);
					$html .= "Transaction complete.<br>Have a nice stay!<br>";
					health::setAttribute($GLOBAL{'uid'},"stealth rating",rollDice(20,10));
				} else {
					equipment::addItemToUser($GLOBAL{'uid'},1,200);
					$html .= "You don't have enough turns to rent a room.<p>";
				}
			} else {
				$html .= "You don't have enough money to rent a room.<p>";
			}
		}
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't rent rooms in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to rent a non-existent room.");
	}	
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# repair()
# return: html
sub repair {
	my ($html, %location, %amenity, $a, @data, $item, @items, $i, $haggle, $price, $flag);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$haggle = skills::useSkill($GLOBAL{'uid'},"haggle");
	$html .= '<h1>Repair</h1>';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top">';
		if ($FORM{'item'} ne "") {
			$html .= "Repairing items...<br>";
			($flag,$item,$price) = decryptPriceAndItem($FORM{'item'});
			if ($flag) {
				if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,$price)) {
					if (equipment::repairItem($GLOBAL{'uid'},$item)) {
						equipment::addItemToStore($FORM{'ai'},1,$price);
						$html .= "Item repaired.<br>";
						$html .= "Transaction completed.<br>";
					} else {
						$html .= "You don't have that item.<br>";
						messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to get an item repaired that you do not own.");
					}
				} else {
					$html .= "You don't have enough money to get that item repaired.<br>";
				}
			} else {
				$html .= "Cheaters can't get anything repaired in Survival of the Fittest.<p>";
				messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to get an item repaired that does not exist.");
			}
			$html .= '</td><td valign="top">';
		}
		$html .= '<img src="/side/repair.jpg" border=1 width=180 height=400></td><td valign="top">The following items are in need of repair:<p>';
		$html .= '<table cellpadding=2 cellspacing=0 border=1 align="center"><tr><th>Cost To Repair</th><th>Item To Repair</th><th>Repair!</th></tr>';
		($a) = sqlQuery("select playerAttributes.type,item.cost,item.name from playerAttributes,item,itemAttributes where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=itemAttributes.itemId and itemAttributes.class='version' and itemAttributes.type='fixed' and itemAttributes.value=item.id order by item.name");
		while (@data = sqlArray($a)) {
			$price = hagglePurchase($GLOBAL{'uid'},round($data[1]*0.7));
			$html .= '<tr><form method="post"><input type="hidden" name="op" value="repair"><input type="hidden" name="ai" value="'.$FORM{'ai'}.'"><input type="hidden" name="item" value="'.encryptPriceAndItem($data[0],$price).'"><td align="right">$'.$price.'</td>';
			$html .= '<td>'.$data[2].'</td><td><input type="image" src="/repair.gif" border=0></td></form></tr>';
		}
		sqlFinish($a);
		$html .= '</table><p>';
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't get anything repaired in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to repair an item with a vendor whom you are not a patron of.");
	}	
	$html .= '<p><a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# sell(toWhere)
# return: html
sub sell {
	my ($html, %location, %amenity, $a, @data, $divisor, $item, $items, $haggle, $price, $flag);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'to'});
        $haggle = skills::getSkillLevel($GLOBAL{'uid'},"haggle",1);
        if ($haggle < 1) { $haggle = 1; }
	$haggle = rollDice($haggle,6);
	$html .= '<h1>Sell</h1><table width="100%"><tr><td valign="top">';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		if ($FORM{'item'} ne "") {
			if (turns::spendTurns($GLOBAL{'uid'},2)) {
				$haggle = skills::upSkillLevel($GLOBAL{'uid'},"haggle");
				$html .= "Selling items...<br>";
				($flag,$item,$price) = decryptPriceAndItem($FORM{'item'});
				if ($flag == 1) {
					$flag = equipment::sellItem($GLOBAL{'uid'},$FORM{'to'},$item,$FORM{'quantity'},$price);
					if ($flag == 1) {
						$html .= "Transaction completed.<br>";
					} elsif ($flag == -1) {
						$html .= $amenity{'name'}." does not have enough money to complete the transaction.<br>";
					} else {
						$html .= "You do not currently have ".$FORM{'quantity'}." of that item in your inventory.<br>";
					}
				} else {
					$html .= "Cheaters can't sell anything in Survival of the Fittest.<p>";
					messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to sell an item that does not exist.");
				}
			} else {
				$html .= "You don't have enough turns to complete the transaction.<br>";
			}	
			$html .= '</td><td valign="top">';
		}
		if ($amenity{'type'} eq "market") {
			$items = "'weapon','armor','clothing','food','ammunition','book','animal','unique','tool','misc','military','medical','pelt'";
			$divisor = 3.5;
		} elsif ($amenity{'type'} eq "trade depot") {
			$items = "'weapon','armor','ammunition','unique','military','medical','map'";
			$divisor = 3;
		} elsif ($amenity{'type'} eq "doctor") {
			$items = "'medical'";
			$divisor = 3;
		} elsif ($amenity{'type'} eq "pet store") {
			$items = "'animal'";
			$divisor = 2.5;
                } elsif ($amenity{'type'} eq "clanhall") {
			$items = "'weapon','armor','clan clothing','ammunition','unique','tool','military','clan item'";
                        $divisor = 4;
	         } elsif ($amenity{'type'} eq "geneticist") {
                        $items = "'medical'";
                        $divisor = 4;
		} elsif ($amenity{'type'} eq "restaurant") {
			$items = "'food'";
			$divisor = 2.5;
		} elsif ($amenity{'type'} eq "blacksmith") {
			$items = "'weapon','armor','tool','junk','ammunition'";
			$divisor = 3;
		} elsif ($amenity{'type'} eq "library") {
			$items = "'book','map'";
			$divisor = 2.5;
		} elsif ($amenity{'type'} eq "tavern") {
			$items = "'food'";
			$divisor = 3;
		}
		$html .= 'This '.$amenity{'type'}.' has an interest in these items:<p>';
		$html .= '<table cellpadding=2 cellspacing=0 border=1 align="center"><tr><th>Quantity</th><th>Item</th><th>Price</th><th>Sell!</th></tr>';
		($a) = sqlQuery("select playerAttributes.type,playerAttributes.value,item.name,item.cost from playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type in (".$items.") order by item.name");
		while (@data = sqlArray($a)) {
			$price = haggleSale($haggle,$data[3],$divisor,$amenity{'item'}{$data[0]});
			if ($price > 0) {
				$html .= '<tr><form method="post"><input type="hidden" name="op" value="sell"><input type="hidden" name="to" value="'.$FORM{'to'}.'"><td align="center"><input type="hidden" name="item" value="'.encryptPriceAndItem($data[0],$price).'"><select name="quantity">';
				$html .= selectList($data[1]);
				$html .= '</select></td><td>'.$data[2].'</td><td align="right">$'.$price.'</td><td><input type="image" src="/sell.gif" border=0></td></form></tr>';
			}
		}
		sqlFinish($a);
		$html .= '</table><p>';
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't sell anything in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to sell an item to a vendor whom you are not a patron of.");
	}	
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'to'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# talkToBartender()
# return: html
sub talkToBartender {
	my ($html, $randomNumber, %location, %amenity, $a, @data, $questResult);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$randomNumber = rollDice(1,100);
	$html .= "<h1>Talking to Bartender</h1>";
	$html .= '<img src="/side/bartender.jpg" border=1 width=180 height=400 align="right" hspace="5">';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$questResult = completeQuest($GLOBAL{'uid'},$FORM{'ai'});
		if ($questResult ne "") {
			$html .= $questResult;
		} elsif ($randomNumber >80) {
			($a) = sqlQuery("select id,description from quests order by rand() limit 1");
			@data = sqlArray($a);
			sqlArray($a);
			$html .= $data[1];
			$html .= '
				<p><div align="center">
				<a href="game.pl?op=processQuest&id='.encryptPriceAndItem($data[0],$FORM{'ai'}).'">Yes!</a>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">No, thanks.</a>
				</div><p>
			';
		} elsif ($randomNumber >65) {
			($a) = sqlQuery("select name from map where type='civilization' order by rand() limit 1");
			@data = sqlArray($a);
			sqlArray($a);
			$html .= "Seek out ".$data[0].", I think you'll like what you find there.";
                } elsif ($randomNumber >60) {
                        $html .= "What did you say?";
                } elsif ($randomNumber >55) {
                        $html .= "Ya know, me demon scotch has got a bit of a bite. It ain't fer everybody.";
		} elsif ($randomNumber >50) {
			$html .= "Go see my friend in the corner. He'll help you out.";
		} elsif ($randomNumber >45) {
			$html .= "The stranger in the corner seems to know more than most.";
		} elsif ($randomNumber >40) {
			$html .= "How would ya like to wrap yer lips around my demon scotch?";
		} elsif ($randomNumber >35) {
			$html .= "Would you like something to eat?";
		} elsif ($randomNumber >30) {
			$html .= "What will you have?";
		} elsif ($randomNumber >25) {
			$html .= "What will it be?";
		} elsif ($randomNumber >20) {
			$html .= "Welcome to my tavern.";
		} elsif ($randomNumber >15) {
			$html .= "Do you want a drink?";
		} elsif ($randomNumber >10) {
			$html .= "Can I get you something?";
		} elsif ($randomNumber >5) {
			$html .= "What can I do fer ya?";
		} else {
			$html .= "Have ya tried me ale?";
		}
		$html .= "<p>";
	} else {
		$html .= "You think to yourself, why am I cheating?.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to talk to a bartender in a non-existant bar.");
	}
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# talkToStranger()
# return: html
sub talkToStranger {
	my ($html, %location, %amenity, $a, @data);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= "<h1>Talking to Stranger</h1>";
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= ' <table width="100%"><tr><td valign="top" width="50%"> ';
		$html .= "<i>I've been known to find things for people on occasion.</i>";
		$html .= '
			<p><form><input type="hidden" name="op" value="talkToStranger">
			<input type="hidden" name="doit" value="person">
			<input type="hidden" name="ai" value="'.$FORM{'ai'}.'">
			<a href="game.pl?op=talkToStranger&doit=stash&ai='.$FORM{'ai'}.'">Do you know where I can find a stash?</a>
			<p>
			Do you know where I can find a person named <input type="text" name="name" maxlength="30"> ? <input type="submit" value="Say it!">
			<p>
			<a href="game.pl?op=talkToStranger&doit=whatElse&ai='.$FORM{'ai'}.'">What else do you know?</a>
			</form>
			</td><td>&nbsp;&nbsp;</td>
		';
		if ($FORM{'doit'} eq "stash") {
			$html .= '</td><td valign="top">';
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,100)) {
				equipment::addItemToSector(rollDice(1,1600),1,100,rollDice(8,8));
				($a) = sqlQuery("select map.x,map.y,item.cost*mapAttributes.value from mapAttributes,item,map where mapAttributes.sectorId=map.id and mapAttributes.class='item' and mapAttributes.type=item.id order by rand() limit 1");
				@data = sqlArray($a);
				sqlFinish($a);
				$html .= "<i>Yeah, I know of a stash worth \$".$data[2].". You can find it in sector ".$data[0]."-".$data[1].".</i><br>";
			} else {
				$html .= "<i>If you can't pay me, I'm not sayin' nothin'.</i><br>";
			}
		} elsif ($FORM{'doit'} eq "person" && $FORM{'name'} ne "") {
			$html .= '</td><td valign="top">';
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,100)) {
				equipment::addItemToSector(rollDice(1,1600),1,100,rollDice(8,8));
				($a) = sqlQuery("select uid from player where username like ".quote($FORM{'name'}."%")." limit 1");
				@data = sqlArray($a);
				sqlFinish($a);
				if ($data[0] ne "") {
					($a) = sqlQuery("select map.x,map.y,map.name,map.type from playerAttributes,map where playerAttributes.uid=".$data[0]." and playerAttributes.class='location' and playerAttributes.type='current' and playerAttributes.value=map.id");
					@data = sqlArray($a);
					sqlFinish($a);
					if ($data[0] ne "") {
						if ($data[3] eq "civilization") {
							$data[3] = $data[2]." (".$data[0]."-".$data[1].")";
						} else {
							$data[3] = "sector ".$data[0]."-".$data[1];
						}	
						$html .= "<i>You can find ".$FORM{'name'}." in ".$data[3].".</i><br>";
					} else {
						$html .= "<i>Yeah, I've heard of ".$FORM{'name'}.", but I don't have any idea where you can find him.</i><br>";
					}
				} else {
					$html .= "<i>I don't know who yer talkin' about. As far as I know, no one with a name anything like that has ever been around these parts.</i><br>";
				}
			} else {
				$html .= "<i>If you can't pay me, I'm not sayin' nothin'.</i><br>";
			}
		} elsif ($FORM{'doit'} eq "whatElse") {
			$html .= '</td><td valign="top">';
			if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,100)) {
				equipment::addItemToSector(rollDice(1,1600),1,100,rollDice(8,8));
				($a) = sqlQuery("select map.x,map.y,map.name,map.id,mapAttributes.type from mapAttributes,map where mapAttributes.sectorId=map.id and mapAttributes.class='description' and (map.type='civilization' or mapAttributes.type='ruins' or mapAttributes.value='a grassy clearing in a lush forest with a small pond') order by rand() limit 1");
				@data = sqlArray($a);
				sqlFinish($a);
				if ($data[4] eq "wilderness") {
					$data[4] = "great hunting spot";
				}	
				$html .= "<i>You can find a ".$data[4]." named ".$data[2]." in sector ".$data[0]."-".$data[1].".</i><br>";
				($a) = sqlQuery("select type,value from mapAttributes where sectorId=".$data[3]." and mapAttributes.class='affinity'");
				@data = sqlArray($a);
				sqlFinish($a);
				if ($data[0] ne "none" && $data[0] ne "" && $data[1] ne "none" && $data[1] ne "") {
					$html .= "<i>Be careful though, they ".$data[1]." ".$data[0].".</i><br>";
				}
			} else {
				$html .= "<i>If you can't pay me, I'm not sayin' nothin'.</i><br>";
			}
		}
		$html .= '</td></tr></table><p><b>Note:</b> It will cost you $100 to purchase information from the stranger.<p>';
	} else {
		$html .= "You think to yourself, why am I cheating?.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to talk to a stranger in a non-existant bar.");
	}
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}



1;

