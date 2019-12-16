package utility;
# load default modules
use strict;
use Lingua::EN::Inflect qw ( PL AN );
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use Exporter;
use FileHandle;
use Net::SMTP;

# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(%GLOBAL %COOKIES %FORM &sqlQuickArray &sqlQuickHash &sqlBuildHash &sqlBuildArray &pluralize &aVSan &readInFile &httpRedirect &selectList &sendMail &round &buildCookie &rollDice &cleanup &init &quote &httpHeader &sqlQuery &sqlFinish &sqlArray &printError );
our %COOKIES = ();
our %GLOBAL = ();
our %FORM = ();

#------------------------------------
# aVSan (word)
# return: a or an + word
sub aVSan {
        return AN($_[0]);
}

#------------------------------------
# buildCookie(name, value, never_expire)
# return: cookie
sub buildCookie {
	my ($cookie);
	if ($_[2]) {
		$cookie = cookie(	-name=>$_[0],
							-value=>$_[1],
							-expires=>'+10y',
							-path=>'/'
						);
	} else {
		$cookie = cookie(	-name=>$_[0],
							-value=>$_[1],
							-path=>'/'
						);
	}					
	return $cookie;
}

#------------------------------------
# cleanup()
# return:
sub cleanup {
	# disconnect from databases
	$GLOBAL{'dbh'}->disconnect if ($GLOBAL{'dbh'});
	# destroy variables
	undef %COOKIES;
	undef %GLOBAL;
	undef %FORM;
}

#------------------------------------
# httpHeader(cookieInfo)
# return: httpHeaderBlock
sub httpHeader {
	return $GLOBAL{'cgi'}->header( -expires=>'-1d', -cookie=>$_[0]	);
}
	
#------------------------------------
# httpRedirect(URL)
# return: httpRedirectBlock
sub httpRedirect {
	return redirect(-URL=>$_[0]);
}
	
#------------------------------------
# init()
# return: 
sub init {
	# don't buffer anything
	$|=1;
	# read form variables
	$GLOBAL{program} = $ENV{SCRIPT_NAME};
  	$GLOBAL{'cgi'} = CGI->new();
    $GLOBAL{'cgi'} = new CGI;
	foreach ($GLOBAL{'cgi'}->param) { 
		$FORM{$_} = $GLOBAL{'cgi'}->param($_);
	}
	# read form variables
	foreach ($GLOBAL{'cgi'}->cookie) { 
		$COOKIES{$_} = $GLOBAL{'cgi'}->cookie($_);
	}
	# make database connections
 	my $user="sotf";
  	my $pass="sotf";
  	my $gamedb ="sotf3";
  	$GLOBAL{'dbh'} = DBI->connect('DBI:mysql:'.$gamedb.'', $user, $pass) or printError("Couldn't open database ". DBI->errstr);
}

#------------------------------------
# pluralize (word,count)
# return: plural form 
sub pluralize {
        return PL($_[0],$_[1]);
}

#------------------------------------
# printError(errorMessage)
# return: 
sub printError {
	my ($key, $file);
	$file = FileHandle->new(">>/data/domains/thegamecrafter.com/sotf/logs/sotf-error.log");
	print "<h1>Internal Game Error</h1>\n";
	print $file "\n\n---------------------------------------------\n".localtime(time)."\n";
	print "In order to help us correct this issue, please post this message to <a href=\"http://sotf.thegamecrafter.com/sotf/board.pl?op=showMessageListing&bid=4\">the support board</a>.<hr>";
	print $0." at ".localtime(time)." reported:<br>";
	print $file "\n\n---------------------------------------------\n".localtime(time)."\n";
	print $_[0];
	print $file $0." reported: ".$_[0]."\n";
	print "<p><h3>Caller</h3><table border=1><tr><td valign=top>";
	print "CALLER INFO:\n";
	print "<b>Level 1</b><br>".join("<br>",caller(1));
	print "</td><td valign=top>"."<b>Level 2</b><br>".join("<br>",caller(2));
	print "</td><td valign=top>"."<b>Level 3</b><br>".join("<br>",caller(3));
	print "</td><td valign=top>"."<b>Level 4</b><br>".join("<br>",caller(4));
	print $file caller(1)."\n".caller(2)."\n".caller(3)."\n".caller(4)."\n";
	print "</td></tr></table><p><h3>Form Variables</h3>";
	print $file "FORM VARS:\n";
	foreach $key (keys %FORM) {
		print $key." = ".$FORM{$key}."<br>";
		print $file $key." = ".$FORM{$key}."\n";
	}
	print "<p><h3>Global Variables</h3>";
	print $file "GLOBAL VARS:\n";
	foreach $key (keys %GLOBAL) {
		print $key." = ".$GLOBAL{$key}."<br>";
		print $file $key." = ".$GLOBAL{$key}."\n";
	}
	$file->close;
	exit;
}

#------------------------------------
# quote(text)
# return: text
sub quote {
	return $GLOBAL{'dbh'}->quote($_[0]);
}

#------------------------------------
# readInFile(fileAndPath)
# return: fileContents
sub readInFile {
	my ($file, $contents);
	$file = new FileHandle;
    if ($file->open("< ".$_[0])) {
 	   	while (<$file>) {
			$contents .= $_;
		}
    	$file->close;
    } else {
		$contents = "Couldn't open file ".$_[0].".";
	}
	return $contents;
}

#------------------------------------
# rollDice (numberOfDice, sidesPerDie)
# return: total
sub rollDice {
	my $number = shift || 1;
	my $sides = shift || 6;
	my $total;
	$total += (int(rand($sides))+1) while $number--;
	return $total;
}

#------------------------------------
# round (decimalNumber)
# return: integer
sub round {
	my ($integer);
	$integer = sprintf "%.0f", $_[0];
	return $integer;
}

#------------------------------------
# selectList (number)
# return: list
sub selectList {
	my ($html, $i, $number, $k);
	if ($_[0] > 1000) {
		$number = $_[0] % 1000;
		if ($number > 0) {
			$html .= '<option>'.$_[0];
		}	
		$k = ($_[0]-$number)/1000;
		for ($i=$k;$i>0;$i--) {
			$html .= '<option>'.$i*1000;
		}
	} else {
		$number = $_[0];
	}
	for ($i=$number;$i>0;$i--) {
		$html .= '<option>'.$i;
	}
	return $html;
}

#------------------------------------
# sendMail(toAddress, subject, message)
# return: 
sub sendMail {
	my ($smtp);
	$smtp = Net::SMTP->new("mail.anarchyink.com"); # connect to an SMTP server
	$smtp->mail("info\@thegamecrafter.com");     # use the sender's address here
	$smtp->to($_[0]);             # recipient's address
	$smtp->data();              # Start the mail
	# Send the header.
	$smtp->datasend("To: ".$_[0]."\n");
	$smtp->datasend("From: The Game Crafter <info\@thegamecrafter.com>\n");
#		$smtp->datasend("CC: $cc\n") if ($cc);
	$smtp->datasend("Subject: ".$_[1]."\n");
	$smtp->datasend("\n");
	# Send the body.
	$smtp->datasend($_[2]);
	$smtp->dataend();           # Finish sending the mail
	$smtp->quit;                # Close the SMTP connection
}

#-------------------------------------------------------------------
sub sqlBuildArray {
        my ($sth, $data, @array, $i);
        $sth = sqlQuery($_[0]);
        $i=0;
        while (($data) = sqlArray($sth)) {
                $array[$i] = $data;
                $i++;
        }
        sqlFinish($sth);
        return @array;
}

#-------------------------------------------------------------------
sub sqlBuildHash {
        my ($sth, %hash, @data);
        #tie %hash, "Tie::IxHash";
        $sth = sqlQuery($_[0]);
        while (@data = sqlArray($sth)) {
                if ($data[1] eq "") {
                        $hash{$data[0]} = $data[0];
                } else {
                        $hash{$data[0]} = $data[1];
                }
        }
        sqlFinish($sth);
        return %hash;
}

#------------------------------------
# sqlArray(pointer)
# return: dataArray
sub sqlArray {
	return $_[0]->fetchrow_array();
}

#------------------------------------
# sqlHash(pointer)
# return: dataHash
sub sqlHash {
	return $_[0]->fetchrow_hashref();
}

#-------------------------------------------------------------------
sub sqlQuickArray {
        my ($sth, @data);
        $sth = sqlQuery($_[0]);
        @data = sqlArray($sth);
        sqlFinish($sth);
        return @data;
}

#-------------------------------------------------------------------
sub sqlQuickHash {
        my ($sth, $data);
        $sth = sqlQuery($_[0]);
        $data = sqlHash($sth);
        sqlFinish($sth);
        if (defined $data) {
                return %{$data};
        }
}

#------------------------------------
# sqlFinish(pointer)
# return: 
sub sqlFinish {
	$_[0]->finish;
}

#------------------------------------
# sqlQuery(sql_statment)
# return: pointer
sub sqlQuery {
	my ($sth);
	$sth = $GLOBAL{'dbh'}->prepare($_[0]) or printError("Couldn't prepare statement: ".$_[0]." : ". DBI->errstr);
	$sth->execute or printError("Couldn't execute statement: ".$_[0]." : ". DBI->errstr);
	return $sth;
}


1;



