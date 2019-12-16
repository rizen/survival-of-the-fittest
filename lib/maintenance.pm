package maintenance;
# load default modules
use strict;
use Exporter;

use equipment;
use utility;
# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&spendCredits &releaseFromJail &transformGoods &addInterest &spawnStash &trickleTurns &deleteGarbage);

#------------------------------------
# addInterest()
# return: 
sub addInterest {
	my ($a);
	($a) = sqlQuery("update amenityAttributes set value=round(value+value*0.05) where class='item' and type='1'");
	sqlFinish($a);
}

#------------------------------------
# deleteGarbage()
# return: 
sub deleteGarbage {
	my ($a, $b, @data);
	($a) = sqlQuery("select mapAttributes.id,item.cost,mapAttributes.value from mapAttributes,item where mapAttributes.class='item' and mapAttributes.type=item.id");
	while (@data = sqlArray($a)) {
		if ($data[1] <= 0||$data[1]*$data[2] > 25000) {
			($b) = sqlQuery("delete from mapAttributes where id=".$data[0]);
			sqlFinish($b);
			($b) = sqlQuery("delete from sectorItemAttributes where sectorItemId=".$data[0]);
			sqlFinish($b);
		}	
	}	
	sqlFinish($a);
}

#------------------------------------
# releaseFromJail()
# return: 
sub releaseFromJail {
	my ($a, @data);
	($a) = sqlQuery("delete from playerAttributes where class='jail'");
	sqlFinish($a);
}

#------------------------------------
# spawnStash()
# return: 
sub spawnStash {
	my ($a, @data, @item);
	($a) = sqlQuery("select sectorId from mapAttributes where class='description' and type='ruins' order by rand() limit 1");
	while (@data = sqlArray($a)) {
		@item = equipment::randomItem(1,1000);
		equipment::addItemToSector($data[0],$item[0],1,rollDice(8,8));
	}
	sqlFinish($a);
}

#------------------------------------
# spendCredits()
# return: 
sub spendCredits {
	my ($a, $b, @data);
	($a) = sqlQuery("select player.uid,player.credits,playerAttributes.value,dayofmonth(now()) from player left join playerAttributes on (player.uid=playerAttributes.uid and playerAttributes.class='pay to play')");
	while (@data = sqlArray($a)) {
		if ($data[2] eq "" && $data[1] > 0) {
			($b) = sqlQuery("insert into playerAttributes set value=1, uid=".$data[0].", class='pay to play'");
			sqlFinish($b);
			($b) = sqlQuery("update playerAttributes set value=99999999 where uid=".$data[0]." and class='attribute' and type='turns'");
			sqlFinish($b);
			if ($data[3] < 21) {
				($b) = sqlQuery("update player set credits=credits-1 where uid=".$data[0]);
				sqlFinish($b);
			}	
		}	
	}	
	sqlFinish($a);
}

#------------------------------------
# transformGoods()
# return: 
sub transformGoods {
	my ($a, $b, @data, $numGoods);
	# animal skins
	($a) = sqlQuery("select amenityAttributes.amenityId,sum(amenityAttributes.value) from amenityAttributes,item where amenityAttributes.class='item' and amenityAttributes.type=item.id and item.type='pelt' group by amenityId");
	while (@data = sqlArray($a)) {
		$numGoods = round($data[1]/15);
		if ($numGoods > 0) {
			equipment::addItemToStore($data[0],8,$numGoods);
		}
	}	
	sqlFinish($a);
	($a) = sqlQuery("select id from item where type='pelt'");
	while (@data = sqlArray($a)) {
		($b) = sqlQuery("delete from amenityAttributes where class='item' and type=".$data[0]);
		sqlFinish($b);
	}	
	sqlFinish($a);
	# broken items
	($a) = sqlQuery("select amenityAttributes.id,itemAttributes.value from amenityAttributes,itemAttributes where amenityAttributes.class='item' and amenityAttributes.type=itemAttributes.itemId and itemAttributes.class='version' and itemAttributes.type='fixed'");
	while (@data = sqlArray($a)) {
		($b) = sqlQuery("update amenityAttributes set type=".$data[1]." where id=".$data[0]);
		sqlFinish($b);
	}	
	sqlFinish($a);
}

#------------------------------------
# trickleTurns()
# return: 
sub trickleTurns {
	my ($a, $b, @data, @data2);
	($a) = sqlQuery("select uid,value from playerAttributes where class='attribute' and (type='turns spent' or type='turns') order by uid");
	while (@data = sqlArray($a)) {
		@data2 = sqlArray($a);
		if (abs($data[1]-$data2[1]) < 500) {
			($b) = sqlQuery("update playerAttributes set value=value+5 where uid=".$data[0]." and class='attribute' and type='turns'");
			sqlFinish($b);
		}	
	}	
	sqlFinish($a);
}



1;

