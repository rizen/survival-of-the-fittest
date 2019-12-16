package board;
# load default modules
use strict;
use Exporter;

use utility;
# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&showLoginWarning &editMessage &postReply &postNewMessage &showMessage &showBoardListing &showMessageListing);

#------------------------------------
# editMessage()
# return: html
sub editMessage {
        my ($a, @data, $html, %board, %message);
        %message = getMessageProperties($FORM{'mid'});
        %board = getBoardProperties($message{'bid'});
        if (isAllowedUser($GLOBAL{'uid'},$board{'verify table'})) {
                if ($FORM{'subject'} ne "" and $FORM{'message'} ne "") {
                        ($a) = sqlQuery("update messages set subject=".quote($FORM{'subject'}).", message=".quote("\n --- (Edited at ".localtime(time).") --- \n\n".$FORM{'message'})." where mid=".$FORM{'mid'});
                        sqlFinish($a);
                        $html .= showMessage();
                } else {
                        $html .= '<table width="100%"><tr><td style="font-size: 16pt;">'.$board{'name'}.'</td><td align="right" valign="bottom">Editing Message...</td></tr></table>';
                        $html .= '<form action="'.$GLOBAL{'program'}.'" method="post">
                                        <input type="hidden" name="op" value="editMessage">
                                        <input type="hidden" name="mid" value="'.$FORM{'mid'}.'">
                                        Subject: <input type="text" name="subject" value="'.$message{'subject'}.'" maxlength="30" size="30"><br>
                                        Message:<br>
                                        <textarea rows=6 cols=50 name="message" wrap="virtual">'.$message{'message'}.'</textarea><br>
                                        <input type="submit" value="Post Edit">
                                        </form>
                        ';
                        $html .= '<table width="100%"><tr><th>';
                        $html .= "Subject: ".$message{'subject'}."<br>";
                        $html .= "Author: ".$message{'username'}."<br>";
                        $html .= "Date: ".$message{'date of post'}."<br>";
                        $html .= "Message ID: ".$message{'bid'}."-".$message{'rid'}."-".$message{'pid'}."-".$FORM{'mid'}."<br>";
                        $html .= '</th></tr><tr><td>';
                        $message{'message'} =~ s/\n/\<br\>/g;
                        $html .= $message{'message'};
                        $html .= '</td></tr></table>';
                }
        } else {
                $html = showGroupWarning();
        }
        return $html;
}

#------------------------------------
# getBoardProperties(bid)
# return: boardHash
sub getBoardProperties {
	my ($a, @data, %board);
	($a) = sqlQuery("select name,usersAllowed,verifyTable from boards where bid=".$_[0]);
	@data = sqlArray($a);
	sqlFinish($a);
	$board{'name'} = $data[0];
	$board{'users allowed'} = $data[1];
	$board{'verify table'} = $data[2];
	return %board;
}

#------------------------------------
# getMessageProperties(mid)
# return: messageHash
sub getMessageProperties {
	my ($a, @data, %message);
	($a) = sqlQuery("select rid,bid,pid,uid,username,subject,message,date_format(dateOfPost,'%c/%e %l:%i%p') from messages where mid=".$_[0]);
	@data = sqlArray($a);
	sqlFinish($a);
	$message{'rid'} = $data[0];
	$message{'bid'} = $data[1];
	$message{'pid'} = $data[2];
	$message{'uid'} = $data[3];
	$message{'username'} = $data[4];
	$message{'subject'} = $data[5];
	$message{'message'} = $data[6];
	$message{'dateOfPost'} = $data[7];
	return %message;
}

#------------------------------------
# isAllowedUser(userId, verifyTable)
# return: flag, yes/no
sub isAllowedUser {
	my ($a, @data, $flag);
	($a) = sqlQuery("select uid from ".$_[1]." where uid=".$_[0]);
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] ne "") {
		$flag = 1;
	} else {
		$flag = 0;
	}
	return $flag;
}

#------------------------------------
# postNewMessage()
# return: html
sub postNewMessage {
	my ($a, @data, $html, %board);
	%board = getBoardProperties($FORM{'bid'});
	if (isAllowedUser($GLOBAL{'uid'},$board{'verify table'})) {
		if ($FORM{'subject'} ne "") {
	                if ($FORM{'message'} eq "") {
        	                $FORM{'subject'} .= ' (eom)';
                	}
			($a) = sqlQuery("insert into messages set uid=".$GLOBAL{'uid'}.", username=".quote($GLOBAL{'username'}).", subject=".quote($FORM{'subject'}).", message=".quote($FORM{'message'}).", bid=".$FORM{'bid'}.", pid=0, dateOfPost=now()");
			sqlFinish($a);			
			($a) = sqlQuery("select last_insert_id()");
			@data = sqlArray($a);
			sqlFinish($a);			
			($a) = sqlQuery("update messages set rid=".$data[0]." where mid=".$data[0]);
			sqlFinish($a);			
			$html .= showMessageListing();
		} else {
			$html .= '<table width="100%"><tr><td style="font-size: 16pt;">'.$board{'name'}.'</td><td align="right" valign="bottom">Posting New Message...</td></tr></table>';
			$html .= '<form action="'.$GLOBAL{'program'}.'" method="post">
					<input type="hidden" name="op" value="postNewMessage">
					<input type="hidden" name="bid" value="'.$FORM{'bid'}.'">
					Subject: <input type="text" name="subject" value="'.$FORM{'subject'}.'" maxlength="30" size="30"><br>
					Message:<br>
					<textarea rows=6 cols=50 name="message" wrap="virtual">'.$FORM{'message'}.'</textarea><br>
					<input type="submit" value="Post New Message">
					</form>
			';
		}
	} else {
		$html = showGroupWarning();
	}	
	return $html;
}

#------------------------------------
# postReply()
# return: html
sub postReply {
	my ($a, @data, $html, %board, %message);
	%message = getMessageProperties($FORM{'mid'});
	%board = getBoardProperties($message{'bid'});
	if (isAllowedUser($GLOBAL{'uid'},$board{'verify table'})) {
		if ($FORM{'subject'} ne "") {
                        if ($FORM{'message'} eq "") {
                                $FORM{'subject'} .= ' (eom)';
                        }
			($a) = sqlQuery("insert into messages set uid=".$GLOBAL{'uid'}.", username=".quote($GLOBAL{'username'}).", subject=".quote($FORM{'subject'}).", message=".quote($FORM{'message'}).", rid=".$message{'rid'}.", bid=".$message{'bid'}.", pid=".$FORM{'mid'}.", dateOfPost=now()");
			sqlFinish($a);			
			$html .= showMessage();
		} else {
			$html .= '<table width="100%"><tr><td style="font-size: 16pt;">'.$board{'name'}.'</td><td align="right" valign="bottom">Posting Reply...</td></tr></table>';
			$html .= '<form action="'.$GLOBAL{'program'}.'" method="post">
					<input type="hidden" name="op" value="postReply">
					<input type="hidden" name="mid" value="'.$FORM{'mid'}.'">
					Subject: <input type="text" name="subject" value="'.$FORM{'subject'}.'" maxlength="30" size="30"><br>
					Message:<br>
					<textarea rows=6 cols=50 name="message" wrap="virtual">'.$FORM{'message'}.'</textarea><br>
					<input type="submit" value="Post Reply">
					</form>
			';
			$html .= '<table width="100%"><tr><th>';
			$html .= "Subject: ".$message{'subject'}."<br>";
			$html .= "Author: ".$message{'username'}."<br>";
			$html .= "Date: ".$message{'date of post'}."<br>";
			$html .= "Message ID: ".$message{'bid'}."-".$message{'rid'}."-".$message{'pid'}."-".$FORM{'mid'}."<br>";
			$html .= '</th></tr><tr><td>';
			$message{'message'} =~ s/\n/\<br\>/g;
			$html .= $message{'message'};
			$html .= '</td></tr></table>';
		}
	} else {
		$html = showGroupWarning();
	}	
	return $html;
}

#------------------------------------
# showBoardListing()
# return: html
sub showBoardListing {
	my ($a, @data, $html);
	($a) = sqlQuery("select boards.bid,boards.name,boards.usersAllowed,count(messages.mid),date_format(max(dateOfPost),'%c/%e %l:%i%p') from boards left join messages on (boards.bid=messages.bid) group by boards.bid order by boards.name");
	$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
	$html .= '<tr><th>Board Name</th><th>Users Allowed</th><th># Posts</th><th>Last Post</th></tr>';
	while (@data = sqlArray($a)) {
		$html .= '<tr><td><a href="'.$GLOBAL{'program'}.'?op=showMessageListing&bid='.$data[0].'">'.$data[1].'</a></td><td>'.$data[2].'</td><td>'.$data[3].'</td><td>'.$data[4].'</td></tr>';
	}
	$html .= "</table>";
	sqlFinish($a);
	return $html;
}

#------------------------------------
# showGroupWarning()
# return: html
sub showGroupWarning {
	my ($html);
	$html = '
		<h1>Not A Member</h1>
		You are not a member of the group allowed to access this board. <a href="'.$GLOBAL{'program'}.'">Please use a board 
		you have access to.</a>	
	';
	return $html;
}

#------------------------------------
# showLoginWarning()
# return: html
sub showLoginWarning {
	my ($html);
	$html = '
		<h1>Login Required</h1>
		You must be logged in to participate in these discussions. <a href="user.pl">Please go to the account 
		page and log in now.</a>	
	';
	return $html;
}

#------------------------------------
# showMessage()
# return: html
sub showMessage {
	my ($a, @data, $html, %board, %message);
	%message = getMessageProperties($FORM{'mid'});
	%board = getBoardProperties($message{'bid'});
	if (isAllowedUser($GLOBAL{'uid'},$board{'verify table'})) {
		$html .= '<table width="100%"><tr><td style="font-size: 16pt;">'.$board{'name'}.'</td><td align="right" valign="bottom">';
                ($a) = sqlQuery("select unix_timestamp()-unix_timestamp(dateOfPost) from messages where mid=".$FORM{'mid'});
                @data = sqlArray($a);
                sqlFinish($a);
		if ($data[0] < 3600 && $message{'uid'} eq $GLOBAL{'uid'}) {
			$html .= '<a href="'.$GLOBAL{'program'}.'?op=editMessage&mid='.$FORM{'mid'}.'">Edit Message</a> &middot; ';
		}
		$html .= '<a href="'.$GLOBAL{'program'}.'?op=postReply&mid='.$FORM{'mid'}.'">Post Reply</a></td></tr></table>';
		$html .= '<table width="100%"><tr><th>';
		$html .= "Subject: ".$message{'subject'}."<br>";
		$html .= "Author: ".$message{'username'}."<br>";
		$html .= "Date: ".$message{'dateOfPost'}."<br>";
		$html .= "Message ID: ".$message{'bid'}."-".$message{'rid'}."-".$message{'pid'}."-".$FORM{'mid'}."<br>";
		$html .= '</th>';
		$html .= '</tr><tr><td colspan=2>';
		$message{'message'} =~ s/\n/\<br\>/g;
		$html .= $message{'message'};
		$html .= '</td></tr></table><p><div align="center">';
		($a) = sqlQuery("select max(mid) from messages where bid=".$message{'bid'}." and pid=0 and mid<".$message{'rid'});
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] ne "") {
			$html .= '<a href="'.$GLOBAL{'program'}.'?op=showMessage&mid='.$data[0].'">&laquo; Previous Thread</a> &middot; ';
		}
		$html .= '<a href="'.$GLOBAL{'program'}.'?op=showMessageListing&bid='.$message{'bid'}.'">Back To Message List</a>';
		($a) = sqlQuery("select min(mid) from messages where bid=".$message{'bid'}." and pid=0 and mid>".$message{'rid'});
		@data = sqlArray($a);
		sqlFinish($a);
		if ($data[0] ne "") {
			$html .= ' &middot; <a href="'.$GLOBAL{'program'}.'?op=showMessage&mid='.$data[0].'">Next Thread &raquo;</a>';
		}	
		$html .= '</div><table border=0 cellpadding=2 cellspacing=1 width="100%">';
		$html .= '<tr><th>Subject</th><th>Author</th><th>Date</th></tr>';
		($a) = sqlQuery("select mid,subject,username,date_format(dateOfPost,'%c/%e %l:%i%p') from messages where mid=".$message{'rid'});
		@data = sqlArray($a);
		sqlFinish($a);
		$html .= '<tr';
		if ($FORM{'mid'} eq $message{'rid'}) {
			$html .= ' class="highlight"';
		}
		$html .= '><td><a href="'.$GLOBAL{'program'}.'?op=showMessage&mid='.$data[0].'">'.$data[1].'</a></td><td>'.$data[2].'</td><td>'.$data[3].'</td></tr>';
		$html .= traverseReplyTree($message{'rid'},1);
		$html .= "</table>";
	} else {
		$html = showGroupWarning();
	}	
	return $html;
}

#------------------------------------
# showMessageListing()
# return: html
sub showMessageListing {
	my ($a, @data, $html, %board);
	%board = getBoardProperties($FORM{'bid'});
	if (isAllowedUser($GLOBAL{'uid'},$board{'verify table'})) {
		$html .= '<table width="100%"><tr><td style="font-size: 16pt;">'.$board{'name'}.'</td><td align="right" valign="bottom"><a href="'.$GLOBAL{'program'}.'?op=postNewMessage&bid='.$FORM{'bid'}.'">Post New Message</a></td></tr></table>';
		$html .= '<table border=0 cellpadding=2 cellspacing=1 width="100%">';
		$html .= '<tr><th>Subject</th><th>Author</th><th>Thread Started</th><th>Replies</th><th>Last Reply</th></tr>';
		($a) = sqlQuery("select mid,subject,count(mid)-1,username,date_format(dateOfPost,'%c/%e %l:%i%p'),date_format(max(dateOfPost),'%c/%e %l:%i%p'),max(mid) from messages where bid=".$FORM{'bid'}." group by rid order by mid desc limit 50");
		while (@data = sqlArray($a)) {
			$html .= '<tr><td><a href="'.$GLOBAL{'program'}.'?op=showMessage&mid='.$data[0].'">'.$data[1].'</a></td><td>'.$data[3].'</td><td>'.$data[4].'</td><td>'.$data[2].'</td><td><a href="'.$GLOBAL{'program'}.'?op=showMessage&mid='.$data[6].'">'.$data[5].'</a></td></tr>';
		}
		$html .= "</table>";
		sqlFinish($a);
	} else {
		$html = showGroupWarning();
	}	
	return $html;
}


#------------------------------------
# traverseReplyTree(pid,depth)
# return: html
sub traverseReplyTree {
	my ($a, @data, $html, $depth, $i);
	for ($i=0;$i<=$_[1];$i++) {
		$depth .= "&nbsp;&nbsp;";
	}
	($a) = sqlQuery("select mid,subject,username,date_format(dateOfPost,'%c/%e %l:%i%p') from messages where pid=".$_[0]." order by mid");
	while (@data = sqlArray($a)) {
		$html .= '<tr';
		if ($FORM{'mid'} eq $data[0]) {
			$html .= ' class="highlight"';
		}
		$html .= '><td>'.$depth.'<a href="'.$GLOBAL{'program'}.'?op=showMessage&mid='.$data[0].'">'.$data[1].'</a></td><td>'.$data[2].'</td><td>'.$data[3].'</td></tr>';
		$html .= traverseReplyTree($data[0],$_[1]+1);
	}
	sqlFinish($a);
	return $html;
}




1;

