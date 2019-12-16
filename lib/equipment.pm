package equipment;
# load default modules
use strict;

use gameMap;
use messageLog;
use utility;

#------------------------------------
# addItemToUser(userId, itemId, quantity)
# return: 
sub addItemToUser {
	my ($a, @data, %location);
	if (countInventoryItems($_[0])+$_[2] > 500 && $_[1] ne "1") {
		messageLog::newMessage($_[0],"game","alert","Your inventory is full. The item has been placed on the ground.");
		%location = gameMap::getLocationProperties($_[0]);
		addItemToSector($location{'sectorId'},$_[1],$_[2],0);
	} else {
		($a) = sqlQuery("select value,id from playerAttributes where uid=".$_[0]." and class='item' and type=".$_[1]);
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] > 0) {
			($a) = sqlQuery("update playerAttributes set value=value+".$_[2]." where id=".$data[1]);
			sqlFinish($a);
		} else {
			($a) = sqlQuery("insert into playerAttributes set uid=".$_[0].", class='item', type=".$_[1].", value=".$_[2]);
			sqlFinish($a);
		}	
	}
}

#------------------------------------
# addItemToSector(sectorId, itemId, quantity, hideRating)
# return: 
sub addItemToSector {
	my ($a, @data, $stealthBonus, $hide);
	($a) = sqlQuery("select value,id from mapAttributes where sectorId=".$_[0]." and class='item' and type=".$_[1]);
	@data = sqlArray($a);
	sqlFinish($a);
        ($a) = sqlQuery("select value from mapAttributes where sectorId=".$_[0]." and class='modifier' and type='stealth bonus'");
        ($stealthBonus) = sqlArray($a);
        sqlFinish($a);
	if ($data[0] > 0) {
		($a) = sqlQuery("update mapAttributes set value=value+".$_[2]." where id=".$data[1]);
		sqlFinish($a);
	} else {
		($a) = sqlQuery("insert into mapAttributes set sectorId=".$_[0].", class='item', type=".$_[1].", value=".$_[2]);
		sqlFinish($a);
		($a) = sqlQuery("select last_insert_id()");
		@data = sqlArray($a);
		sqlFinish($a);
		$hide = $_[3]+rollDice($stealthBonus,6);
		($a) = sqlQuery("insert into sectorItemAttributes set sectorItemId=".$data[0].", class='attribute', type='hide rating', value='".$hide."'");
		sqlFinish($a);
	}	
}

#------------------------------------
# addItemToStore(storeId, itemId, quantity)
# return: 
sub addItemToStore {
	my ($a, @data);
	($a) = sqlQuery("select value,id from amenityAttributes where amenityId=".$_[0]." and class='item' and type=".$_[1]);
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] > 0) {
		($a) = sqlQuery("update amenityAttributes set value=value+".$_[2]." where id=".$data[1]);
		sqlFinish($a);
	} else {
		($a) = sqlQuery("insert into amenityAttributes set amenityId=".$_[0].", class='item', type=".$_[1].", value=".$_[2]);
		sqlFinish($a);
	}	
}

#------------------------------------
# breakItem(userId, itemId)
# return: 
sub breakItem {
	my ($a, @data);
	if ($_[1] ne "") {
		if (rollDice(1,300) == 1) {
			($a) = sqlQuery("select itemAttributes.value,item.name from itemAttributes,item where itemAttributes.itemId=".$_[1]." and itemAttributes.class='version' and itemAttributes.type='junk' and itemAttributes.itemId=item.id");
			@data = sqlArray($a);
			sqlFinish($a);
			deleteItemFromUser($_[0],$_[1],1);
			addItemToUser($_[0],$data[0],1);
			messageLog::newMessage($_[0],"game","alert","You've broken your ".$data[1].".");
		}
	}
}

#------------------------------------
# buyItem(userId, storeId, itemId, quantity, pricePerItem)
# return: flag
# flag 1 = transaction completed
# flag 0 = store does not have quantity
# flag -1 = user does not have funds
sub buyItem {
	my ($flag);
	$flag = 1;
	if (deleteItemFromUser($_[0], 1, ($_[3]*$_[4]))) {
		if (deleteItemFromStore($_[1], $_[2], $_[3])) {
			addItemToStore($_[1], 1, ($_[3]*$_[4]));
			addItemToUser($_[0], $_[2], $_[3]);
		} else {
			$flag = 0;
			addItemToUser($_[0], 1, ($_[3]*$_[4]));
		}
	} else {
		$flag = -1;
	}	
	return $flag;
}

#------------------------------------
# countInventoryItems(userId)
# return: itemCount
sub countInventoryItems {
        my ($a, @data);
        ($a) = sqlQuery("select sum(value) from playerAttributes where uid=".$_[0]." and class='item' and type<>1");
        @data = sqlArray($a);
        sqlFinish($a);
	return $data[0];
}

#------------------------------------
# deleteItemFromUser(userId, itemId, quantity)
# return: flag, successful or not
sub deleteItemFromUser {
	my ($a, @data, $flag);
	($a) = sqlQuery("select value,id from playerAttributes where uid=".$_[0]." and class='item' and type=".$_[1]);
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] > $_[2]) {
		($a) = sqlQuery("update playerAttributes set value=value-".$_[2]." where id=".$data[1]); sqlFinish($a);
		$flag = 1;
	} elsif ($data[0] == $_[2]) {
		($a) = sqlQuery("delete from playerAttributes where id=".$data[1]); sqlFinish($a);
		$flag = 1;
		($a) = sqlQuery("delete from playerAttributes where uid=".$_[0]." and class='equipped' and value=".$_[1]); sqlFinish($a);
	} else {
		$flag = 0;
	}	
	return $flag
}

#------------------------------------
# deleteItemFromSector(sectorId, itemId, quantity)
# return: flag, successful or not
sub deleteItemFromSector {
	my ($a, @data, $flag);
	($a) = sqlQuery("select value,id from mapAttributes where sectorId=".$_[0]." and class='item' and type=".$_[1]);
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] > $_[2]) {
		($a) = sqlQuery("update mapAttributes set value=value-".$_[2]." where id=".$data[1]);
		sqlFinish($a);
		$flag = 1;
	} elsif ($data[0] == $_[2]) {
		($a) = sqlQuery("delete from mapAttributes where id=".$data[1]);
		sqlFinish($a);
		($a) = sqlQuery("delete from sectorItemAttributes where sectorItemId=".$data[1]);
		sqlFinish($a);
		$flag = 1;
	} elsif ($data[0] < 1) {
                ($a) = sqlQuery("delete from mapAttributes where id=".$data[1]);
                sqlFinish($a);
                ($a) = sqlQuery("delete from sectorItemAttributes where sectorItemId=".$data[1]);
                sqlFinish($a);
                $flag = 0;
	} else {
		$flag = 0;
	}	
	return $flag
}

#------------------------------------
# deleteItemFromStore(userId, itemId, quantity)
# return: flag, successful or not
sub deleteItemFromStore {
	my ($a, @data, $flag);
	($a) = sqlQuery("select value,id from amenityAttributes where amenityId=".$_[0]." and class='item' and type=".$_[1]);
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] > $_[2]) {
		($a) = sqlQuery("update amenityAttributes set value=value-".$_[2]." where id=".$data[1]);
		$flag = 1;
	} elsif ($data[0] == $_[2]) {
		($a) = sqlQuery("delete from amenityAttributes where id=".$data[1]);
		$flag = 1;
	} else {
		$flag = 0;
	}	
	sqlFinish($a);
	return $flag
}

#------------------------------------
# dropItem(userId, sectorId, itemId, quantity)
# return: flag, successful/not
sub dropItem {
	my ($flag);
	$flag = 1;
	if (deleteItemFromUser($_[0], $_[2], $_[3])) {
		addItemToSector($_[1], $_[2], $_[3], rollDice(3,5));
	} else {
		$flag = 0;
	}	
	return $flag;
}

#------------------------------------
# getMoney(userId)
# return: money
sub getMoney {
	my ($a, $money);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='item' and type='1'");
	($money) = sqlArray($a);
	sqlFinish($a);
	return $money;
}

#------------------------------------
# junkItem(userId, itemId)
# return: 
sub junkItem {
	my ($flag, $a, @data);
	$flag = 1;
	($a) = sqlQuery("select value from itemAttributes where itemId=".$_[1]." and class='version' and type='junk'");
	sqlFinish($a);
	if (deleteItemFromUser($_[0], $_[1], 1)) {
		addItemToUser($_[0], $data[0], 1);
	} else {
		$flag = 0;
	}	
	return $flag;
}

#------------------------------------
# pickUpItem(userId, sectorId, itemId, quantity)
# return: 
sub pickUpItem {
	my ($flag);
	$flag = 1;
	if (deleteItemFromSector($_[1], $_[2], $_[3])) {
		addItemToUser($_[0], $_[2], $_[3]);
	} else {
		$flag = 0;
	}
	return $flag;
}

#------------------------------------
# randomItem(minValue, maxValue)
# return: itemId, name, cost
sub randomItem {
	my ($a, @item);
	($a) = sqlQuery("select id,name,cost from item where cost>=".$_[0]." and cost<=".$_[1]." order by rand() limit 1");
	@item = sqlArray($a);
	sqlFinish($a);
	return $item[0],$item[1],$item[2];
}

#------------------------------------
# randomPlayerItem(userId)
# return: itemId, quantity, name
sub randomPlayerItem {
	my ($a, @data, @equipped, $equippedList, $i);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='equipped'");
	while (@data = sqlArray($a)) {
		$equipped[$i] = $data[0];
		$i++;
	}
	if ($equipped[0] ne "") {
		$equippedList = join(",",@equipped);
		$equippedList = "and item.id not in (".$equippedList.")";
	}
	sqlFinish($a);
	($a) = sqlQuery("select item.id, playerAttributes.value, item.name from playerAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=item.id ".$equippedList." order by rand() limit 1");
	@data = sqlArray($a);
	sqlFinish($a);
	return $data[0],$data[1],$data[2];
}

#------------------------------------
# repairItem(userId, itemId)
# return: 
sub repairItem {
	my ($flag, $a, @data);
	$flag = 1;
	($a) = sqlQuery("select value from itemAttributes where itemId=".$_[1]." and class='version' and type='fixed'");
	@data = sqlArray($a);
	sqlFinish($a);
	if (deleteItemFromUser($_[0], $_[1], 1)) {
		addItemToUser($_[0], $data[0], 1);
	} else {
		$flag = 0;
	}	
	return $flag;
}

#------------------------------------
# searchForItem(userId, itemId)
# return: flag, has it or not
sub searchForItem {
	my ($a, @data, $flag);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='item' and type='".$_[1]."' limit 1");
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] > 0) {
		$flag = 1;
	} else {
		$flag = 0;
	}
	return $flag;
}

#------------------------------------
# searchForItemType(userId, itemType)
# return: itemId 
sub searchForItemType {
        my ($a, @data);
        ($a) = sqlQuery("select playerAttributes.type from playerAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=item.id and item.type='".$_[1]."' limit 1");
        @data = sqlArray($a);
        sqlFinish($a);
        return $data[0];
}

#------------------------------------
# sellItem(userId, storeId, itemId, quantity, pricePerItem)
# return: flag
# flag 1 = transaction completed
# flag 0 = user does not have quantity
# flag -1 = store does not have funds
sub sellItem {
	my ($flag);
	$flag = 1;
	if (deleteItemFromStore($_[1], 1, ($_[3]*$_[4]))) {
		if (deleteItemFromUser($_[0], $_[2], $_[3])) {
			addItemToUser($_[0], 1, ($_[3]*$_[4]));
			addItemToStore($_[1], $_[2], $_[3]);
		} else {
			$flag = 0;
			addItemToStore($_[1], 1, ($_[3]*$_[4]));
		}
	} else {
		$flag = -1;
	}	
	return $flag;
}

#------------------------------------
# useConsumable(userId, consumableType, allowCombinations)
# return: resultingModifier, useText
sub useConsumable {
	my ($a, @data, $useText, $modifier, $limit, $b, @dataB);
	if ($_[2] ne "1") {
		$limit = " limit 1";
	}
	($a) = sqlQuery("select itemAttributes.itemId,itemAttributes.value,item.name from playerAttributes,itemAttributes,item where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=itemAttributes.itemId and itemAttributes.class='consumable' and itemAttributes.type='".$_[1]."' and itemAttributes.itemId=item.id".$limit);
	while (@data = sqlArray($a)) {
		if (equipment::deleteItemFromUser($_[0],$data[0],1)) {
			$useText .= "Using ".$data[2].".<br>";
			$modifier += $data[1];
			($b) = sqlQuery("select type,value from itemAttributes where itemId=".$data[0]." and class='consumable' and type<>'".$_[1]."'");
			while (@dataB = sqlArray($b)) {
				health::modifyAttribute($_[0],$dataB[0],$dataB[1]);
			}
			sqlFinish($b);
		}
	}
	sqlFinish($a);
	return ($modifier,$useText);
}



1;

