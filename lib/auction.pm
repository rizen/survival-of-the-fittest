package auction;
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
our @EXPORT = qw(&bid &auction);

#------------------------------------
# auction()
# return: html
sub auction {
	my ($html, %location, %amenity, $a, @data);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= '<h1>Auction</h1><table width="100%"><tr><td valign="top">';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		if ($FORM{'item'} ne "") {
			if (turns::spendTurns($GLOBAL{'uid'},2)) {
				$html .= "Auctioning item...<br>";
				if (equipment::deleteItemFromUser($GLOBAL{'uid'},$FORM{'item'},$FORM{'quantity'})) {
					($a) = sqlQuery("insert into auction set owner=".$GLOBAL{'uid'}.", itemId=".$FORM{'item'}.", itemQuantity=".$FORM{'quantity'}.", auctionEnds=date_add(now(),interval 12 hour), minimumBid=".$FORM{'minimumBid'});
					sqlFinish($a);
				} else {
					$html .= "You don't have enough items to sell.<br>";
				}	
			} else {
				$html .= "You don't have enough turns to complete the transaction.<br>";
			}	
			$html .= '</td><td valign="top">';
		}
		$html .= 'Which item do you wish to auction off:<p>';
		$html .= '<table cellpadding=2 cellspacing=0 border=1 align="center"><tr><th>Quantity</th><th>Item</th><th>Minimum Bid</th><th>Sell!</th></tr>';
		($a) = sqlQuery("select playerAttributes.value,item.name,item.id,round(item.cost,0) from playerAttributes,item where playerAttributes.uid=".$GLOBAL{'uid'}." and playerAttributes.class='item' and playerAttributes.type=item.id and item.id<>1 order by item.name");
		while (@data = sqlArray($a)) {
			$html .= '<tr><form method=post><input type=hidden name="op" value="auction"><input type="hidden" name="ai" value="'.$FORM{'ai'}.'"><input type=hidden name="item" value="'.$data[2].'"><td align=center><select name="quantity">';
			$html .= selectList($data[0]);
			$html .= '</select></td><td>'.$data[1].'</td><td align=right>$<input type="text" name="minimumBid" size="5" maxlength="5" value="'.$data[3].'"></td><td><input type="image" src="/auction.gif" border=0></td></form></tr>';
		}
		sqlFinish($a);
		$html .= '</table><p>';
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't sell anything in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to sell an item to a vendor whom you are not a patron of.");
	}	
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# bid()
# return: html
sub bid {
	my ($html, %location, %amenity, $a, @data, $flag, $money);
	%location = gameMap::getLocationProperties($GLOBAL{'uid'});
	%amenity = gameMap::getAmenityProperties($FORM{'ai'});
	$html .= '<h1>Bid</h1>';
	if ($amenity{'sectorId'} == $location{'sectorId'}) {
		$html .= '<table width="100%"><tr><td valign="top">';
		if ($FORM{'item'} ne "" && $FORM{'bid'} ne "") {
			$html .= "Bidding...<br>";
			if (turns::spendTurns($GLOBAL{'uid'},2)) {
				($a) = sqlQuery("select auction.currentBid,auction.currentBidder,auction.owner,item.name from auction,item where auction.id=".$FORM{'item'}." and auction.auctionEnds>now() and auction.itemId=item.id");
				@data = sqlArray($a);
				sqlFinish($a);
				if ($FORM{'bid'} > $data[0] && $data[2] ne "") {
					if (equipment::deleteItemFromUser($GLOBAL{'uid'},1,$FORM{'bid'})) {
						if ($data[1] ne "") {
							messageLog::newMessage($data[1],"player","auction","You have been outbid on the ".$data[3]." auction.");
							equipment::addItemToUser($data[1],1,$data[0]);
						}	
						($a) = sqlQuery("update auction set currentBidder=".$GLOBAL{'uid'}.", currentBid=".$FORM{'bid'}." where id=".$FORM{'item'});
						sqlFinish($a);
						$html .= "Bid accepted.<br>";
						messageLog::newMessage($data[2],"player","auction","A bid has been placed on your ".$data[3].".");
					} else {
						$html .= "You don't have enough money to bid on the ".$data[3].".<br>";
					}	
				} else {
					$html .= "That auction has already completed.<br>";
				}				
			} else {
				$html .= "You do not have enough turns to complete the transaction.<br>";
			}
			$html .= '</td><td valign="top">';
		}
		$html .= 'The auction has these items up for bid:<p>';
		$html .= '<table cellpadding=2 cellspacing=0 border=1 align="center"><tr><th>Quantity</th><th>Item</th><th>Time Remaining</th><th>Bid Amount</th><th>Bid!</th></tr>';
		$money = equipment::getMoney($GLOBAL{'uid'});
		($a) = sqlQuery("select auction.id,item.name,auction.itemQuantity,auction.minimumBid,auction.currentBid,round((unix_timestamp(auction.auctionEnds)-unix_timestamp())/60) from auction left join item on (auction.itemId=item.id) where auction.auctionEnds>now() order by auction.auctionEnds");
		while (@data = sqlArray($a)) {
			$html .= '<tr><form method="post"><input type="hidden" name="op" value="bid"><input type="hidden" name="ai" value="'.$FORM{'ai'}.'"><td align="center"><input type="hidden" name="item" value="'.$data[0].'">'.$data[2].'</td><td>'.$data[1].'</td><td align="right">'.$data[5].' minutes</td><td align="right">';
			if ($money > $data[3] && $money > $data[4]) {
				$html .= '<select name="bid">';
				if ($data[4] ne "") {
					$html .= bidSelectList($data[4],$money);
				} else {
					$html .= bidSelectList($data[3],$money);
				}
				$html .= '</select>';
			} else {
				$html .= "insufficient funds";
			}	
			$html .= '</td><td><input type="image" src="/bid.gif" border=0></td></form></tr>';
		}
		sqlFinish($a);
		$html .= '</table><p>';
		$html .= '</td></tr></table>';
	} else {
		$html .= "Cheaters can't purchase anything in Survival of the Fittest.<p>";
		messageLog::caughtCheating($GLOBAL{'uid'},"You were caught trying to bid at a non-existant auction.");
	}	
	$html .= '<a href="game.pl?op=amenityMenu&ai='.$FORM{'ai'}.'">I want to do something else here.</a><p>';
	return $html;
}

#------------------------------------
# bidSelectList (start, max)
# return: list
sub bidSelectList {
        my ($html, $i, $number, $max);
        $max = round(($_[1]-$_[0]+10)/10);
        if ($max > 20) {
                $max = 20;
        }
        for ($i=1;$i<=$max;$i++) {
                $number = $_[0]+($i*10);
                $html .= "<option>".$number."\n";
        }
	return $html;
}

#------------------------------------
# finishAuctions()
# return: html
sub finishAuctions {
	my ($a, @data, $b);
	($a) = sqlQuery("select auction.owner,auction.itemId,auction.itemQuantity,auction.currentBidder,auction.currentBid,auction.id,item.name from auction,item where unix_timestamp(auction.auctionEnds)<unix_timestamp() and auction.finished=0 and auction.itemId=item.id");
	while (@data = sqlArray($a)) {
		if ($data[3] ne "") {
			equipment::addItemToUser($data[0],1,$data[4]);
			equipment::addItemToUser($data[3],$data[1],$data[2]);
			messageLog::newMessage($data[0],"player","auction","You've sold your ".$data[6]." for \$".$data[4].".");
			messageLog::newMessage($data[3],"player","auction","You've won the bid on the ".$data[6]." for \$".$data[4].".");
		} else {
			equipment::addItemToUser($data[0],$data[1],$data[2]);
			messageLog::newMessage($data[0],"player","auction","The auction for ".$data[6]." completed without a bidder.");
		}	
		($b) = sqlQuery("update auction set finished=1 where id=".$data[5]);
		sqlFinish($b);
	}
	sqlFinish($a);
}

1;

