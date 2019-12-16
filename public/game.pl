#!/usr/bin/perl 

BEGIN {
        unshift (@INC, "../lib");
}

use account;
use actions;
use amenities;
use auction;
use character;
use gameMap;
use government;
use messageLog;
use nearbyPlayer;
use utility;
use gameLayout;

my $html;
init();
print httpHeader();
my $login = account::checkLogin();
if ($login) {
	$html = page();
} else {
	$html = 'You must be logged in to play. <a href="/user.pl" target="_top">Click here to login.</a>';
}	
print gameLayout::htmlHeader();
print $html;
print gameLayout::htmlFooter();
cleanup();

#------------------------------------
# page()
# return: htmlPage
sub page {
	my ($html);
	if (checkCharacter($GLOBAL{'uid'})) {
		if ($FORM{'op'} ne "") {
			($html) = $FORM{'op'}();
		} else {
			($html) = showMessageLog();
		}
	} else {
		($html) = createCharacter($GLOBAL{'uid'});
	}
	$html .= gameLayout::subMenu();
	return $html;
}

