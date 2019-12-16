package account;
use strict;
use utility;

#------------------------------------
# checkLogin()
# return: true/false
sub checkLogin {
	my ($flag, @cookie, $a, $password, $username);
	@cookie = split(/\|/,$COOKIES{'sgid'});
	($a) = sqlQuery("select identifier, username from player where uid='".$cookie[0]."'");
	($password, $username) = sqlArray($a);
	sqlFinish($a);
	if (encrypt($password) eq $cookie[1] && $cookie[0] > 0) {
		$flag = 1;
		$GLOBAL{'uid'} = $cookie[0];
		$GLOBAL{'username'} = $username;
		($a) = sqlQuery("update player set lastActive=now(), lastIP='$ENV{REMOTE_ADDR}' where uid=$GLOBAL{uid}"); sqlFinish($a);
	} else {
		$flag = 0;
	}	
	return $flag;
}

#------------------------------------
# encrypt(password)
# return: cryptedPassword
sub encrypt {
        my ($encryptedPassword);
        $encryptedPassword = crypt($_[0],"Zq");
        return $encryptedPassword;
}

#------------------------------------
# getPlayerProperties(userId)
# return: playerHash
sub getPlayerProperties {
	my (%player, $a, @data);
	($a) = sqlQuery("select username,identifier,email,icq,pager from player where uid=".$_[0]);
	@data = sqlArray($a);
	sqlFinish($a);
	$player{'username'} = $data[0];
	$player{'password'} = $data[1];
	$player{'email'} = $data[2];
	$player{'icq'} = $data[3];
	$player{'pager'} = $data[4];
	return %player;
}

#------------------------------------
# paidToPlay(uid)
# return: flag, yes or no
sub paidToPlay {
	my ($flag, $a, @data);
	($a) = sqlQuery("select value from playerAttributes where uid=".$_[0]." and class='pay to play'");
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] == 1) {
		$flag = 1;
	} else {
		$flag = 0;
	}
	return $flag;
}

1;

