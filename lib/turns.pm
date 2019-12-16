package turns;
# load default modules
use strict;

use event;
use health;
use utility;

#------------------------------------
# getTurns(userId)
# return: turns
sub getTurns {
	my ($a, $turns, $turnsSpent);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='attribute' and type='turns'");
	($turns) = sqlArray($a);
	sqlFinish($a);
	$turnsSpent = getTurnsSpent($_[0]);
	return $turns-$turnsSpent;
}

#------------------------------------
# getTurnsSpent(userId)
# return: turnsSpent
sub getTurnsSpent {
	my ($a, $turnsSpent);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='attribute' and type='turns spent'");
	($turnsSpent) = sqlArray($a);
	sqlFinish($a);
	return $turnsSpent;
}

#------------------------------------
# isNewbie(userId)
# return: turnsSpent
sub isNewbie {
	my ($flag);
	if (getTurnsSpent($_[0]) >= 1000) {
		$flag = 0;
	} else {
		$flag = 1;
	}
	return $flag;
}

#------------------------------------
# spendTurns(userId, numberOfTurnsToSpend)
# return: $flag, successful or not
sub spendTurns {
	my ($a, @data, $flag);
	if (getTurns($_[0]) >= $_[1]) {
		($a) = sqlQuery("update playerAttributes set value=value+".$_[1]." where uid=".$_[0]." and class='attribute' and type='turns spent'"); sqlFinish($a);
		health::processHunger($_[0]);
		health::processPoison($_[0]);
		event::event($_[0]);
		$flag = 1;
	} else {
		$flag = 0;
	}
	return $flag;
}



1;

