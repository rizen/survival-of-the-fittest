package createGame;
# load default modules
use strict;
use Exporter;

use equipment;
use utility;

# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&deleteSector &addGoalItems &populateCivilization &populateWilderness &populateAmenity &populateAmenities &createMap &deleteOldGameInfo &declareWinner &populateMap &populateStore);

#------------------------------------
# addGoalItems(sectorId)
# return: 
sub addGoalItems {
	my (@item);
	@item = equipment::randomItem(1000,99999);
	equipment::addItemToSector($_[0],$item[0],1,60);
	@item = equipment::randomItem(100,99999);
	equipment::addItemToSector($_[0],$item[0],1,45);
	@item = equipment::randomItem(100,4000);
	equipment::addItemToSector($_[0],$item[0],1,30);
	@item = equipment::randomItem(0,1000);
	equipment::addItemToSector($_[0],$item[0],1,15);
}

#------------------------------------
# createMap()
# return: 
sub createMap {
	my ($x, $y, $a, $i, @names, $name, $sectorType, $sectorId);
	($a) = sqlQuery("select name from citygen.citynames order by rand() limit 1600");
	$i = 0;
	while (($name) = sqlArray($a)) {
		$names[$i] = $name;
		$i++;
	}
	sqlFinish($a);
	$i = 0;
	$x = "Z";
   	while ($x ne "BN") {
   		$x = ++$x;
		for ($y=1; $y <= 40; $y++) {
			if ($y == 1 || $y == 40 || $x eq "AA" || $x eq "BN") {
				$sectorType = "impassible";
			} else {
				$sectorType = sectorType();
			}
			($a) = sqlQuery("insert into map set x='".$x."', y=".$y.", type='".$sectorType."', name=".quote($names[$i])."");
			sqlFinish($a);
			($a) = sqlQuery("select last_insert_id()");
			($sectorId) = sqlArray($a);
			sqlFinish($a);
			populateSector($sectorId, $sectorType);
			$i++;
		}	
   	}  
}

#------------------------------------
# declareWinner()
# return: 
sub declareWinner {
	my (@data, $a, $b, $i, $test);
        ($a) = sqlQuery("select player.uid, player.username, (playerAttributes.value+0) as turns, sum(deeds.renown) as renown, (playerAttributes.value+0)*(sum(deeds.renown)+1) as rank from player left join playerAttributes on (player.uid=playerAttributes.uid) left join deeds on (player.uid=deeds.uid and deeds.completed=1) where playerAttributes.class='attribute' and playerAttributes.type='turns spent' group by player.uid order by rank desc limit 5");
	while (@data = sqlArray($a)) {
		if ($i < 1) {
			($b) = sqlQuery("insert into theSurvivors set name=".quote($data[1]).", turnsSpent=".$data[2].", renown=".$data[3].", dateWon=now()"); sqlFinish($b);
			#($b) = sqlQuery("update player set credits=credits+2 where uid=".$data[0]); sqlFinish($b);
		}
		($b) = sqlQuery("update player set credits=credits+1 where uid=".$data[0]); sqlFinish($b);
		$i++;
	}
	sqlFinish($a);
}

#------------------------------------
sub deleteAmenity {
	my ($a);
	($a) = sqlQuery("delete from mapAttributes where id=$_[0]");
	sqlFinish($a);
        ($a) = sqlQuery("delete from amenityAttributes where amenityId=$_[0]");
        sqlFinish($a);
}

#------------------------------------
sub deleteSector {
        my ($a);
        ($a) = sqlQuery("delete from mapAttributes where sectorId=$_[0]");
        sqlFinish($a);
}

#------------------------------------
# deleteOldGameInfo()
# return: 
sub deleteOldGameInfo {
	my ($query, @list, $a);
	@list = (
		"delete from playerAttributes",
		"delete from messageLog",
		"delete from map",
		"delete from postOffice",
		"delete from mapAttributes",
		"delete from auction",
		"delete from bank",
		"delete from deeds",
		"delete from gossip",
		"delete from amenityAttributes",
		"delete from theDestroyed"
		);
	foreach $query (@list) {
		($a) = sqlQuery($query);
		sqlFinish($a);
	}
}

#------------------------------------
sub populateAmenities {
	my ($type, $a, $numberOfAmenities);
        ($a) = sqlQuery("select type from mapAttributes where class='description' and sectorId=".$_[0]);
        ($type) = sqlArray($a);
        sqlFinish($a);
        if ($type eq "large city") {
                $numberOfAmenities = 14;
        } elsif ($type eq "city") {
                $numberOfAmenities = 9;
        } elsif ($type eq "small city") {
                $numberOfAmenities = 6;
        } elsif ($type eq "large town") {
                $numberOfAmenities = 6;
        } elsif ($type eq "town") {
                $numberOfAmenities = 4;
        } elsif ($type eq "small town") {
                $numberOfAmenities = 3;
        } else {
                $numberOfAmenities = 1;
        }
        while($numberOfAmenities > 0) {
		populateAmenity($_[0]);
		$numberOfAmenities--;
	}
}


#------------------------------------
sub populateAmenity {
	my ($amenityName, $amenityId, $a, $roll, $baseQuery, $type, $numberOfAmenities, @clans, @auction, @government, @petstore, @blacksmith, @library, @market, @tradedepot, @geneticist, @casino, @tavern, @restaurant, @doctor);
	$baseQuery = "insert into mapAttributes set sectorId=".$_[0];
	@tavern = ("Joe\'s Pub","Diamond Lounge","Stave &amp; Hoop","Houligans","The Bloody Bucket","Grand Illusion","Brothers","The Lighthouse","Flannigan\'s Tavern","Mark\'s Brewhouse","Coyote Ugly","The Plaza","The Library","Shortstop Pub","The Pioneer","Sloopy\'s","Poor Nate\'s Tavern","Dante\'s Inferno","The Inferno","The Cardinal","Blue Moon","The Joint","Bottle &amp; Barrel");
	@restaurant = ("Mike\'s Smokehouse","Ritten House","Sam\'s Grill","Apocalypse Cafe","Salina\'s Eatery","Mel\'s Diner","Brothers","Vivian\'s Place","The Opus Lounge","Bluefish Joint","Old Mill Restaurant","The 410 Club","Coach House","Zerphlew\'s","The Greasy Spoon","Freight House","Sammy\'s","Black Rose","Fanny Hill","The Triangle Restaurant","The Ridge","Visions","Capitol Cafe","Northwoods Grill","The Tornado Room","The Spitfire Grill");
	@doctor = ("Wasteland Healthcare","Emergency Surgery","Human Patchwork","Venerable Hospital","Erin\'s Stitchery","dE Doc","General Hospital","Dr. Matheson","Dr. Jones","Dr. Johnson","Dr. Holiday","Dr. Matheson","Dr. Avery","Doc\'s Place","Kattia\'s Nursewerks","Apoclinic");
	@geneticist = ("The Undoer","RadAway","Total Human","The Humanist","Pure Life","Rad Doctor","Dr. Smythe");
	@casino = ("Bet Your Life","New Fortunes","Grand Casino","\$tandards Tap","Golden Hills","Starlight","dE Grand","Lady Luck","Pot-O-Gold","Irish Horseshoe","The Broken Mirror","13th Street Casino","The Rabbit's Foot","The Treasury");
	@market = ("The Farmer\'s Market","The Bazzar","The Flea Market","Tradin\' Zone","The Market Square","The Local Market","The Market","Trafalgar Square","Yuseomg Market","Moran Market","Covent Garden Market","The Plaza","El Rasto","Liege Market","Mother Redcap\'s Market","Place Du Jeu-de-Balle","Waterlooplien","Feira du Ladro","Porta Portese","March aux Puces","Flohmarkt","The Community Marketplace");
	@tradedepot = ("Prewar Antiquities","Sally\'s Trade Depot","Dave\'s Trade Depot","Cal\'s GearShop","The General\'s Store","Gecko\'s Rare Trade","Trades \'R Us","Barter Zone","Swindler\'s List","Worth It","Worthy Geary","Gadgets &amp; Goods","The Gadget Store","Equip-It","Gear Deals");
	@blacksmith = ("Metalwerks","Alan\'s Scrap","Meg\'s Forge","Troy\'s Anvil","Heavy Metalshop","Useful Junk","The Junktaker","Scrapyard Supplies","Torch\'s Place","Vrbsky\'s Hammer &amp; Anvil","Weld &amp; Torch","Forge This","Horseshoe Metalsmiths","The Smithery");
	@library = ("The Literary","Read Me","Reading Railroad","The Library","The Bookshelf","Noble Barney","Nile","Read Me First","Table of Contents","Forward","Booketeer","Book \'Em","The Study","The President\'s Library","Bordello of Books");
	@auction = ("The Auctioneer","Sell It All","The Stock Exchange","Seller\'s Market","Trade Away","Rummage Sale","Bid Your Life","Trader\'s Way","The Gavel","Lot 316");
	@government = ("Court House","Governor\'s Mansion","Town Hall","Village Mall","Community Trust","Board of Regents","County Seat","Senate","The House","Constable","Capitol Square","Town Square","City Hall");
	@petstore = ("Farmecon","The People\'s Pets","Animalia","Man\'s Best","Wild!","The Pound","Pets \'R Us","The Pet Store","New Friends","Santa\'s Little Helpers","The Stockade");
	@clans = ("AlphaPrime","Godsbane","The Wraiths","Wasteland Rogues","dEad Men Walking","Fyth Dogg Pack","Null","Famiglia di Santione");
	$roll = rollDice(1,37);
	if ($roll < 6) {	
		($a) = sqlQuery($baseQuery.", class='amenity', type='market', value=".quote($market[rollDice(1,($#market+1))-1])); sqlFinish($a);
		($amenityId) = sqlQuickArray("select last_insert_id()");
		populateStore($amenityId,"market");
	} elsif ($roll < 11) {
		($a) = sqlQuery($baseQuery.", class='amenity', type='tavern', value=".quote($tavern[rollDice(1,($#tavern+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"tavern");
        } elsif ($roll < 14) {
		($a) = sqlQuery($baseQuery.", class='amenity', type='government', value=".quote($government[rollDice(1,($#government+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"government");
        } elsif ($roll < 17) {
		($a) = sqlQuery($baseQuery.", class='amenity', type='auction', value=".quote($auction[rollDice(1,($#auction+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"auction");
        } elsif ($roll < 20) {	
                ($a) = sqlQuery($baseQuery.", class='amenity', type='clanhall', value='".$clans[rollDice(1,($#clans+1))-1]." Clanhall'"); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"clanhall");
	} elsif ($roll < 23) {	
		($a) = sqlQuery($baseQuery.", class='amenity', type='restaurant', value=".quote($restaurant[rollDice(1,($#restaurant+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"restaurant");
	} elsif ($roll < 26) {	
		($a) = sqlQuery($baseQuery.", class='amenity', type='pet store', value=".quote($petstore[rollDice(1,($#petstore+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"pet store");
	} elsif ($roll < 29) {	
		($a) = sqlQuery($baseQuery.", class='amenity', type='blacksmith', value=".quote($blacksmith[rollDice(1,($#blacksmith+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"blacksmith");
	} elsif ($roll < 32) {	
		($a) = sqlQuery($baseQuery.", class='amenity', type='library', value=".quote($library[rollDice(1,($#library+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"library");
		$numberOfAmenities--;
	} elsif ($roll < 35) {
		($a) = sqlQuery($baseQuery.", class='amenity', type='doctor', value=".quote($doctor[rollDice(1,($#doctor+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"doctor");
        } elsif ($roll < 37) {	
		($a) = sqlQuery($baseQuery.", class='amenity', type='trade depot', value=".quote($tradedepot[rollDice(1,($#tradedepot+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"trade depot");
	} elsif ($roll < 38) {	
                ($a) = sqlQuery($baseQuery.", class='amenity', type='geneticist', value=".quote($geneticist[rollDice(1,($#geneticist+1))-1])); sqlFinish($a);
                ($amenityId) = sqlQuickArray("select last_insert_id()");
                populateStore($amenityId,"geneticist");
	}
}

#------------------------------------
# populateCivilization(sectorId)
# return: 
sub populateCivilization {
	my ($a, $roll, $baseQuery, @affinity, @affinityReaction);
	@affinityReaction = ('kill','maime','fine','shame','none','jail','jail and fine','jail and maime','warn');
	@affinity = ('murderers','mutants','gunslingers','none','thieves');
	$baseQuery = "insert into mapAttributes set sectorId=".$_[0];
	$roll = rollDice(1,100);
	if ($roll >= 99) {	
		($a) = sqlQuery($baseQuery.", class='description', type='large city', value='one of the largest cities you have ever seen'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=999"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=5"); sqlFinish($a);
		addGoalItems($_[0]);
	} elsif ($roll >= 95) {	
		($a) = sqlQuery($baseQuery.", class='description', type='city', value='a booming metropolis'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=999"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=5"); sqlFinish($a);
	} elsif ($roll >= 92) {	
		($a) = sqlQuery($baseQuery.", class='description', type='small city', value='a city of sizable population'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=99"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=4"); sqlFinish($a);
	} elsif ($roll >= 88) {	
		($a) = sqlQuery($baseQuery.", class='description', type='large town', value='a town ready to bust at its seams'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=99"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=3"); sqlFinish($a);
	} elsif ($roll >= 83) {	
		($a) = sqlQuery($baseQuery.", class='description', type='town', value='a bustling town'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=80"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=2"); sqlFinish($a);
	} elsif ($roll >= 70) {	
		($a) = sqlQuery($baseQuery.", class='description', type='town', value='an average town'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=80"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=2"); sqlFinish($a);
	} elsif ($roll >= 60) {	
		($a) = sqlQuery($baseQuery.", class='description', type='small town', value='a town just barely worthy of being called so'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=70"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 45) {	
		($a) = sqlQuery($baseQuery.", class='description', type='village', value='a rural community'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=40"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 30) {	
		($a) = sqlQuery($baseQuery.", class='description', type='village', value='a small village quietly tucked into the countryside'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=50"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 15) {	
		($a) = sqlQuery($baseQuery.", class='description', type='village', value='an out-of-the-way village'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=50"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} else {	
		($a) = sqlQuery($baseQuery.", class='description', type='village', value='a small quiet community'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=50"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	}	
	($a) = sqlQuery($baseQuery.", class='affinity', type='".$affinity[rollDice(1,($#affinity+1))-1]."', value='$affinityReaction[rollDice(1,($#affinityReaction+1))-1]'"); sqlFinish($a);
	($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
	populateAmenities($_[0]);
}

#------------------------------------
# populateImpassible(sectorId)
# return: 
sub populateImpassible {
	my ($a, $roll, $baseQuery);
	$baseQuery = "insert into mapAttributes set sectorId=".$_[0];
	$roll = rollDice(1,10);
	if ($roll == 1) {	
		($a) = sqlQuery($baseQuery.", class='description', type='water', value='a raging river creates an impassible torrent'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=999"); sqlFinish($a);
	} elsif ($roll == 2) {	
		($a) = sqlQuery($baseQuery.", class='description', type='water', value='a large lake is in your way'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=999"); sqlFinish($a);
	} elsif ($roll == 3) {	
		($a) = sqlQuery($baseQuery.", class='description', type='hole', value='a ravine that stretches as far as the eye can see divides this land'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=999"); sqlFinish($a);
	} elsif ($roll == 4) {	
		($a) = sqlQuery($baseQuery.", class='description', type='hill', value='a sheer cliff impedes your travel'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=999"); sqlFinish($a);
	} elsif ($roll == 5) {	
		($a) = sqlQuery($baseQuery.", class='description', type='hole', value='there is a gorge before you'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=999"); sqlFinish($a);
	} else {	
		($a) = sqlQuery($baseQuery.", class='description', type='hill', value='a huge mountain stands in your way'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=999"); sqlFinish($a);
	}	
}

#------------------------------------
# populateSector(sectorId, sectorType)
# return: 
sub populateSector {
	if ($_[1] eq "wilderness") {
		print "<b>wilderness</b> ";
		populateWilderness($_[0]);
	} elsif ($_[1] eq "impassible") {
		print "<b>impassible</b> ";
		populateImpassible($_[0]);
	} elsif ($_[1] eq "civilization") {
		print "<b>civilization</b> ";
		populateCivilization($_[0]);
	}
}

#------------------------------------
# populateStores()
# return: 
sub populateStore {
	my ($a, $amenityId, $amenityType, $amenityName, @clanhallItem, @geneticistItem, @doctorItem, @marketItem, @blacksmithItem, @libraryItem, @tradeDepotItem, @petStoreItem, $i, $limit, $funds, @item);
	$amenityId = $_[0];
	$amenityType = $_[1];
	@clanhallItem = (2,107,108,109,110,111,27,184);
	@marketItem = (7,8,9,2,27,32,64,65,66,67,68,81,102,103,105,106,144,6,78,44,109,111,110);
	@blacksmithItem = (21,3,4,5,6,10,12,14,16,17,36,38,40,41,71,72,101,110,109,111,108,107);
	@libraryItem = (48,49,50,51,52,53,54,55,56,57,58,59,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,33);
	@petStoreItem = (42,43,44,45,78,147);
	@tradeDepotItem = (20,10,11,13,14,17,23,31,32,33,34,35,37,37,39,52,69,70,72,74,75,76,77,79,80,107,108,109,110,111);
	@doctorItem = (27,28,29,30,183,184);
	@geneticistItem = (29,13,183,196,184);
#	($a) = sqlQuery("select id,type,value from mapAttributes where class='amenity'");
#	while (($amenityId, $amenityType, $amenityName) = sqlArray($a)) {
		@item = ();
		print $amenityType." ";
		if ($amenityType eq "market") {
			$limit = rollDice(5,40);
			$funds = rollDice(50,1000);
			@item = @marketItem;
                } elsif ($amenityType eq "clanhall") {
			($amenityName) = sqlQuickArray("select value from mapAttributes where id=$amenityId");
                        $limit = rollDice(1,20);
                        $funds = rollDice(50,1000);
			@item = @clanhallItem;
			if ($amenityName eq "AlphaPrime Clanhall") {
				equipment::addItemToStore($amenityId,198,rollDice(5,10));
			} elsif ($amenityName eq "Null Clanhall") {	
				equipment::addItemToStore($amenityId,202,rollDice(5,10));
			} elsif ($amenityName eq "The Wraiths Clanhall") {	
				equipment::addItemToStore($amenityId,197,rollDice(5,10));
			} elsif ($amenityName eq "dEad Men Walking Clanhall") {	
				equipment::addItemToStore($amenityId,203,rollDice(5,10));
			} elsif ($amenityName eq "Godsbane Clanhall") {	
				equipment::addItemToStore($amenityId,204,rollDice(5,10));
			} elsif ($amenityName eq "Wasteland Rogues Clanhall") {	
				equipment::addItemToStore($amenityId,205,rollDice(5,10));
			} elsif ($amenityName eq "Fyth Dogg Pack Clanhall") {	
				equipment::addItemToStore($amenityId,201,rollDice(5,10));
			} else { # the family	
				equipment::addItemToStore($amenityId,200,rollDice(5,10));
			}
		} elsif ($amenityType eq "library") {
			$limit = rollDice(5,4);
			$funds = rollDice(50,500);
			@item = @libraryItem;
		} elsif ($amenityType eq "pet store") {
			$limit = rollDice(5,4);
			$funds = rollDice(10,70);
			@item = @petStoreItem;
		} elsif ($amenityType eq "trade depot") {
			$limit = rollDice(5,10);
			$funds = rollDice(50,50);
			@item = @tradeDepotItem;
		} elsif ($amenityType eq "blacksmith") {
			$limit = rollDice(5,10);
			$funds = rollDice(50,50);
			@item = @blacksmithItem;
		} elsif ($amenityType eq "doctor") {
			$limit = rollDice(2,10);
			$funds = rollDice(10,500);
			@item = @doctorItem;
		} elsif ($amenityType eq "geneticist") {
			$limit = rollDice(5,5);
			$funds = rollDice(10,50);
			@item = @geneticistItem;
		} elsif ($amenityType eq "tavern") {
			$limit = -1;
			@item = (1,2);
			$funds = rollDice(10,50);
			equipment::addItemToStore($amenityId,151,rollDice(10,10));
			equipment::addItemToStore($amenityId,150,rollDice(10,100));
			equipment::addItemToStore($amenityId,152,rollDice(10,10));
		} elsif ($amenityType eq "restaurant") {
			$limit = -1;
			@item = (1,2);
			$funds = rollDice(10,50);
			equipment::addItemToStore($amenityId,149,rollDice(10,100));
			equipment::addItemToStore($amenityId,150,rollDice(10,10));
			equipment::addItemToStore($amenityId,144,rollDice(10,10));
			equipment::addItemToStore($amenityId,105,rollDice(10,10));
			equipment::addItemToStore($amenityId,106,rollDice(10,10));
			equipment::addItemToStore($amenityId,102,rollDice(10,10));
			equipment::addItemToStore($amenityId,2,rollDice(10,10));
                } else {
                        $limit = -1;
                        @item = (1,2);
                        $funds = rollDice(10,50);
		}		
		for ($i=0;$i<=$limit;$i++) {
			print ". ";
			equipment::addItemToStore($amenityId,$item[rollDice(1,($#item+1))-1],1);
		}
		equipment::addItemToStore($amenityId,1,$funds);
#	}
#	sqlFinish($a);
}

#------------------------------------
# populateWilderness(sectorId)
# return: 
sub populateWilderness {
	my ($a, $roll, $baseQuery);
	$baseQuery = "insert into mapAttributes set sectorId=".$_[0];
	$roll = rollDice(1,100);
	if ($roll == 100) {	
		($a) = sqlQuery($baseQuery.", class='description', type='ruins', value='the desolate remains of a city fallen to the war'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,20)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=50"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
		addGoalItems($_[0]);
	} elsif ($roll == 99) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a grassy clearing in a lush forest with a small pond'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=5"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=3"); sqlFinish($a);
	} elsif ($roll >= 98) {	
		($a) = sqlQuery($baseQuery.", class='description', type='ruins', value='a toxic waste dump'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(5,20)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=80"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 96) {	
		($a) = sqlQuery($baseQuery.", class='description', type='ruins', value='a pre-war scrap heap'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,20)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=60"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
		addGoalItems($_[0]);
	} elsif ($roll == 95) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a tall timbered forest with little underbrush'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=10"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=5"); sqlFinish($a);
	} elsif ($roll == 94) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='an open plain with short grass'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=12"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=5"); sqlFinish($a);
	} elsif ($roll == 93) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a thriving prairie'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=12"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=4"); sqlFinish($a);
	} elsif ($roll >= 89) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a green woods'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=15"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=2"); sqlFinish($a);
	} elsif ($roll >= 85) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a clear valley'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=14"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=2"); sqlFinish($a);
	} elsif ($roll >= 81) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a rocky forest'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=18"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 77) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a light swamp'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=20"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 75) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a murky marsh'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=22"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 73) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a foggy valley'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=35"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 69) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a dense swamp'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=35"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 65) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a dense brushland'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=35"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 61) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a barren wilderness of rock and brush'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=40"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 57) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wilderness', value='a briar thicket'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=55"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=12"); sqlFinish($a);
	} elsif ($roll >= 40) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wasteland', value='a dry and unfriendly plains'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=50"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=0"); sqlFinish($a);
	} elsif ($roll >= 30) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wasteland', value='a field of shale'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=60"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
	} elsif ($roll >= 20) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wasteland', value='a sandy plateau'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=40"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=0"); sqlFinish($a);
	} elsif ($roll >= 10) {	
		($a) = sqlQuery($baseQuery.", class='description', type='wasteland', value='an old strip mine quarry'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=60"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=0"); sqlFinish($a);
	} else {	
		($a) = sqlQuery($baseQuery.", class='description', type='wasteland', value='an arid wasteland'"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,10)); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=60"); sqlFinish($a);
		($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=0"); sqlFinish($a);
	}	
}

#------------------------------------
# sectorType()
# return: 
sub sectorType {
	my ($type, $roll);
	$roll = rollDice(1,25);
	if ($roll <= 2) {
		$type = "civilization";
	} elsif ($roll == 25) {
		$type = "impassible";
	} else {
		$type = "wilderness";
	}
	return $type;
}

1;

