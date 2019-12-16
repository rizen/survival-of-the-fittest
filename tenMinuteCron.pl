#!/usr/bin/perl 

BEGIN {
        unshift (@INC, "./lib");
}

use auction;
use createGame;
use maintenance;
use utility;
init();
spendCredits();
#trickleTurns();
releaseFromJail();
deleteGarbage();
spawnStash();
#addInterest();
transformGoods();
auction::finishAuctions();
evolveWorld();
cleanup();

#------------------------------
sub evolveWorld {
	my (%map, $rand, %amenity);
	%map = sqlQuickHash("select * from map order by rand() limit 1");
	if ($map{type} eq "impassible") {
		# do nothing
	} elsif ($map{type} eq "civilization") {
		$rand = rollDice(1,3);
		if ($rand == 1) {
			%amenity = sqlQuickHash("select * from mapAttributes where sectorId=$map{id} and class='amenity' order by rand() limit 1");
			deleteAmenity($amenity{id});
		} elsif ($rand == 2) {
			populateAmenity($map{id});
		} elsif ($rand == 3) {
			deleteSector($map{id});
			($a) = sqlQuery("update map set type='wilderness' where id=$map{id}"); sqlFinish($a);
		        $baseQuery = "insert into mapAttributes set sectorId=".$map{id};
                	($a) = sqlQuery($baseQuery.", class='description', type='ruins', value='the desolate remains of a city fallen to the war'"); sqlFinish($a);
                	($a) = sqlQuery($baseQuery.", class='modifier', type='radiation level', value=".rollDice(1,20)); sqlFinish($a);
                	($a) = sqlQuery($baseQuery.", class='modifier', type='hunting difficulty', value=50"); sqlFinish($a);
                	($a) = sqlQuery($baseQuery.", class='modifier', type='stealth bonus', value=1"); sqlFinish($a);
                	addGoalItems($map{id});
		}
	} elsif ($map{type} eq "wilderness") {
		$rand = rollDice(1,4);
		deleteSector($map{id});
		if ($rand == 1) {
			($a) = sqlQuery("update map set type='civilization' where id=$map{id}"); sqlFinish($a);
			populateCivilization($map{id});
		} elsif ($rand > 1) {
			populateWilderness($map{id});
		}
	}
}




