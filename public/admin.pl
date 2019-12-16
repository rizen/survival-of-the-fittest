#!/usr/bin/perl 

BEGIN {
        unshift (@INC, "../lib");
}

use account;
use admin;
use createGame;
use utility;
init();
print httpHeader();
if (account::checkLogin() && ($GLOBAL{'uid'} == 1 || $GLOBAL{'uid'} == 10 || $GLOBAL{'uid'} == 11)) {
	page();
} else {
	print "What the fuck do you think you are doing? Your ip address has been recorded and this incident has been reported to TGC.";
}	
cleanup();

#------------------------------------
# mainMenu()
# return: htmlPage
sub mainMenu {
	my ($html);
	$html = '
	<h1>Admin Menu</h1>
	<ul>';
        if ($GLOBAL{'uid'} == 1 || $GLOBAL{'uid'} == 10) {
		$html .= '<li><a href="admin.pl?op=addQuest">Add</a> / <a href="admin.pl?op=editQuest">Edit</a> Quest';
	}
	if ($GLOBAL{'uid'} == 1) {
		$html .= '
		<li><a href="admin.pl?op=viewSurveyResults">View Survey Results</a>
		<li><a href="admin.pl?op=addCredits">Add Credits</a>
		<hr>
		<li><a href="admin.pl?op=startNewGame">Start New Game</a>';
	}
	$html .= '<hr><li><a href="game.pl">Back to the game!</a> </ul> ';
	print $html;
}

#------------------------------------
# page()
# return: htmlPage
sub page {
	if ($FORM{'op'} ne "") {
		$FORM{'op'}();
		print '<hr><a href="admin.pl">back to menu</a>';
	} else {
		mainMenu();
	}
}

#------------------------------------
# startNewGame()
# return: htmlPage
sub startNewGame {
	print <<EOF;
	<SCRIPT LANGUAGE="JavaScript">
<!--BEGIN Script

var y = 0;

function scrollit() {
                window.scroll(0,y);
                y = y + 5;
                setTimeout('scrollit()', 20);
}
scrollit();
// -->
</SCRIPT>

EOF
 
	my $startTime = time; 
	my $wayPoint = time;
	print httpHeader();
	print "<b>Started at: ".localtime($startTime)."</b><br>\n";
	print "Declaring winner...<br>\n";
	$wayPoint = time;
	declareWinner();
	print time-$wayPoint." seconds<br>\n";
	print "Deleting old game information...<br>\n";
	$wayPoint = time;
	deleteOldGameInfo();
	print time-$wayPoint." seconds<br>\n";
	print "Creating a new map...<br>\n";
	$wayPoint = time;
	createMap();
	print time-$wayPoint." seconds<br>\n";
#	print "Adding items and bankroll to stores...<br>\n";
#	$wayPoint = time;
#	populateStores();
#	print time-$wayPoint." seconds<br>\n";
	print "Done!<br>\n";
	print "<b>Ended at: ".localtime(time)."</b><br>\n";
}

