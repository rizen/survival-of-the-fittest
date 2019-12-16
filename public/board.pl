#!/usr/bin/perl 

BEGIN {
        unshift (@INC, "../lib");
}

use account;
use board;
use utility;

init();
print httpHeader();
print readInFile("../public/header.include");
print page();
print readInFile("../public/footer.include");
cleanup();

#------------------------------------
# page()
# return: htmlPage
sub page {
	my ($html, %board);
	if (account::checkLogin($GLOBAL{'uid'})) {
		if ($FORM{'op'} ne "") {
			($html) = $FORM{'op'}();
		} else {
			($html) = showBoardListing();
		}
	} else {
		$html .= showLoginWarning();
	}
	return $html;
}


