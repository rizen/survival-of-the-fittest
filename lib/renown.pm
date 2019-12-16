package renown;
# load default modules
use strict;
use health;
use messageLog;
use utility;

#------------------------------------
# addDeed(userId, deed type, deed identifier, renown)
# return: 
sub addDeed {
	my ($a, $desc);
	unless (deedExists($_[0],$_[1],$_[2])) {
		if ($_[1] eq "quests") {
			($a) = sqlQuery("select name from quests where id=".$_[2]);
			($desc) = sqlArray($a);
			sqlFinish($a);
			$desc = "completed ".$desc;
		} elsif ($_[1] eq "player") {
	                ($a) = sqlQuery("select username from player where uid=".$_[2]);
                        ($desc) = sqlArray($a);
                        sqlFinish($a);
                        $desc = "killed ".$desc;
                } elsif ($_[1] eq "event") {
                        $desc = "survived ".$_[2];
		} elsif ($_[1] eq "wildAnimal") {
	                ($a) = sqlQuery("select name from wildAnimal where id=".$_[2]);
                        ($desc) = sqlArray($a);
                        sqlFinish($a);
                        $desc = "killed ".aVSan($desc);
		}
		($a) = sqlQuery("insert into deeds set uid=".$_[0].", class='".$_[1]."', type='".$_[2]."', renown=".$_[3].", description=".quote($desc));
		sqlFinish($a);
	}
}

#------------------------------------
# completeDeed(deedId)
# return:
sub completeDeed {
        my ($a, @data);
	($a) = sqlQuery("select uid,renown,completed from deeds where id=".$_[0]);
	@data = sqlArray($a);
        sqlFinish($a);
	if ($data[2] < 1) {
		($a) = sqlQuery("update deeds set completed=1 where id=".$_[0]);
		sqlFinish($a);
		messageLog::newMessage($data[0],"game","advancement","You just gained some renown.");
	}
}

#------------------------------------
# deedExists(userId, deed type, deed identifier)
# return:
sub deedExists {
	my ($a, @data);
	($a) = sqlQuery("select count(*) from deeds where uid=".$_[0]." and class='".$_[1]."' and type='".$_[2]."'");
	@data = sqlArray($a);
	sqlFinish($a);
	return $data[0];
}

#------------------------------------
# getRenown(userId)
# return:
sub getRenown {
        my ($a, @data);
        ($a) = sqlQuery("select sum(renown)+0 from deeds where uid=".$_[0]." and completed=1");
        @data = sqlArray($a);
        sqlFinish($a);
	$data[0]+0;
        return $data[0];
}


1;

