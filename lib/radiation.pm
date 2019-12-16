package radiation;
# load default modules
use strict;

use gameMap;
use health;
use messageLog;
use utility;

#------------------------------------
# getShielding(userId)
# return: shielding
sub getShielding {
	my ($a, @data, $shielding);
	($a) = sqlQuery("select sum(value) from playerAttributes where uid=".$_[0]." and (class='attribute' or class='radiation') and type='shielding'");
	($shielding) = sqlArray($a);
	sqlFinish($a);
	($a) = sqlQuery("select sum(itemAttributes.value) from playerAttributes,itemAttributes where playerAttributes.uid=".$_[0]." and playerAttributes.class='item' and playerAttributes.type=itemAttributes.itemId and itemAttributes.class='attribute modifier' and itemAttributes.type='shielding'");
	@data = sqlArray($a);
	sqlFinish($a);
	$shielding += $data[0];
	return $shielding;
}

#------------------------------------
# rollRadiation(userId)
# return: 
sub rollRadiation {
	my ($a, @data, $randomNumber, %location, @affect, $amount);
	%location = gameMap::getLocationProperties($_[0]);
	$randomNumber = rollDice(1,1000)+getShielding($_[0]);
	if ($randomNumber < $location{'radiation level'}) {
		@affect = ('troubadour','haggle','beast lore','combat','navigate','first aid','senses','hork','stealth','tracking','domestics','hunger','health','shielding','armor rating','immunity');
		$amount = rollDice(1,3);		
		if (rollDice(1,2) == 2) {
			$amount = $amount*-1;
		}
		($a) = sqlQuery("insert into playerAttributes set uid=".$_[0].", class='radiation', type='".$affect[rollDice(1,($#affect+1))-1]."', value='".$amount."'");
		sqlFinish($a);
		messageLog::newMessage($_[0],"game","radiation","You feel a little strange.");
		if (health::getAttribute($_[0],"health") <= 0) {
			messageLog::newMessage($_[0],"game","alert","Radiation killed you.");
			health::killCharacter($_[0],"radiation");
		}
	}
}



1;

