package admin;
# load default modules
use strict;
use Exporter;

use account;
use utility;
# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&viewSurveyResults &addCredits &addQuest &editQuest);

#------------------------------------
# addCredits()
# return: htmlPage
sub addCredits {
	my ($html, $a, @data);
	$html .= '<h1>Add Credits</h1>';
	if ($FORM{'doit'} eq "find") {
		$html .= '
		<form action="admin.pl" method="post">
		<input type="hidden" name="op" value="addCredits">
		<input type="hidden" name="doit" value="add">
		Amount:		<input type="text" name="amount"><br>Add to: 
		<select name="uid">
		';
		($a) = sqlQuery("select uid,username from player where username like '".$FORM{'username'}."\%' order by username");
		while (@data = sqlArray($a)) {
			$html .= '<option value="'.$data[0].'">'.$data[1];
		}
		sqlFinish($a);
		$html .= '
		</select>
		<input type="submit" name="add">
		</form>
		';
	} elsif ($FORM{'doit'} eq "add") {
		($a) = sqlQuery("update player set credits=credits+".$FORM{'amount'}." where uid=".$FORM{'uid'});
		sqlFinish($a);
		$html .= '
			Credits added.
			<p>
			<a href="admin.pl?op=addCredits">Give credits to someone else?</a>
		';
	} else {
		$html .= '
		What is the user\'s name?
		<form action="admin.pl" method="post">
		<input type="hidden" name="op" value="addCredits">
		<input type="hidden" name="doit" value="find">
		<input type="text" name="username">
		<input type="submit" name="search">
		</form>
		';
	}
	print $html;
}

#------------------------------------
# addQuest()
# return: htmlPage
sub addQuest {
	my ($html, $a, @data, $items);
	$html .= '<h1>Add Quest</h1>';
	if ($FORM{'doit'} eq "add") {
		($a) = sqlQuery("insert into quests set trigger='".$FORM{'trigger'}."', name=".quote($FORM{'name'}).", prizeItem='".$FORM{'prizeItem'}."', prizeQuantity='".$FORM{'prizeQuantity'}."', goalItem='".$FORM{'goalItem'}."', goalQuantity='".$FORM{'goalQuantity'}."', description=".quote($FORM{'description'}));
		sqlFinish($a);
		$html .= 'Quest saved.<p>';
	}
	($a) = sqlQuery("select id,name from item order by name");
	while (@data = sqlArray($a)) {
		$items .= '<option value="'.$data[0].'">'.$data[1];
	}
	sqlFinish($a);
	$html .= '
	<form action="admin.pl" method="post">
	<input type="hidden" name="op" value="addQuest">
	<input type="hidden" name="doit" value="add">
	<table>
	<tr><td>Quest Name</td><td><input type="text" name="name" size="20" maxlength="30"></td></tr>
	<tr><td>Description</td><td><textarea cols="40" rows="5" name="description"></textarea></td></tr>
	<tr><td>Goal Item</td><td><select name="goalItem">'.$items.'</select></td></tr>
	<tr><td>Goal Quantity</td><td><input type="text" name="goalQuantity" size="4" maxlength="4" value="1"></td></tr>
	<tr><td>Prize Item</td><td><select name="prizeItem">'.$items.'</select></td></tr>
	<tr><td>Prize Quantity</td><td><input type="text" name="prizeQuantity" size="4" maxlength="4" value="1"></td></tr>
	<tr><td>Trigger</td><td><select name="trigger"><option value="find and return">find and return<option value="spawn in city">spawn in city<option value="find and deliver">find and deliver<option value="give and deliver">give and deliver<option value="spawn in wilderness">spawn in wilderness</select></td></tr>
	</table>
	<input type="submit" value="save">
	</form>

	<h3>Triggers</h3>
	<dl>
	<dt>find and return
	<dd>No item(s) will be spawned. The player will need to find an item that is already in game and return to this bartender to collect.
	<p>

	<dt>spawn in city
        <dd>Item(s) will be spawned in random cities. The player will have to go collect the items and bring them back to this bartender.
        <p>

        <dt>find and deliver
        <dd>No item(s) will be spawned. The player will have to find an existing item and deliver it to a bartender that will be chosen at random.
        <p>

        <dt>give and deliver
        <dd>Item(s) will be added to the player\'s inventory. The items must be delivered to a bartender that will be chosen at random.
        <p>

        <dt>spawn in wilderness
        <dd>Item(s) will be spawned in random wilderness areas. The player will have to go collect the items and bring them back to this bartender. <b>Due to the absolutely huge nature of this quest (especially with multiple items) the prize should be equally large</b>.
        <p>

	</dl>
	';
	print $html;
}

#------------------------------------
# editQuest()
# return: htmlPage
sub editQuest {
        my ($html, $a, @data, $name);
        $html .= '<h1>Edit Quest</h1>';
        if ($FORM{'doit'} eq "add") {
                ($a) = sqlQuery("update quests set name=".quote($FORM{'name'}).", prizeQuantity='".$FORM{'prizeQuantity'}."', goalQuantity='".$FORM{'goalQuantity'}."', description=".quote($FORM{'description'})." where id=".$FORM{'id'});
                sqlFinish($a);
                $html .= 'Quest saved.<p>';
        }
	if ($FORM{'id'} ne "") {
        	($a) = sqlQuery("select description,goalItem,goalQuantity,prizeItem,prizeQuantity,trigger,name from quests where id=".$FORM{'id'});
        	@data = sqlArray($a);
        	sqlFinish($a);
        	$html .= '
        	<form action="admin.pl" method="post">
        	<input type="hidden" name="op" value="editQuest">
        	<input type="hidden" name="doit" value="add">
        	<input type="hidden" name="id" value="'.$FORM{'id'}.'">
        	<table>
        	<tr><td>Quest Name</td><td><input type="text" name="name" size="20" maxlength="30" value="'.$data[6].'"></td></tr>
        	<tr><td>Description</td><td><textarea cols="40" rows="5" name="description">'.$data[0].'</textarea></td></tr>
		';
        	($a) = sqlQuery("select name from item where id=".$data[1]);
        	($name) = sqlArray($a);
        	sqlFinish($a);
        	$html .= '
        	<tr><td>Goal Item</td><td>'.$name.'</td></tr>
        	<tr><td>Goal Quantity</td><td><input type="text" name="goalQuantity" size="4" maxlength="4" value="'.$data[2].'"></td></tr>
		';
                ($a) = sqlQuery("select name from item where id=".$data[3]);
                ($name) = sqlArray($a);
                sqlFinish($a);
        	$html .= '
        	<tr><td>Prize Item</td><td>'.$name.'</td></tr>
        	<tr><td>Prize Quantity</td><td><input type="text" name="prizeQuantity" size="4" maxlength="4" value="'.$data[4].'"></td></tr>
        	<tr><td>Trigger</td><td>'.$data[5].'</td></tr>
        	</table>
        	<input type="submit" value="save">
        	</form>
        	';
	}
        $html .= "<ul>";
        ($a) = sqlQuery("select id,substring(description,1,100) from quests");
        while (@data = sqlArray($a)) {
                $html .= '<li><a href="admin.pl?op=editQuest&id='.$data[0].'">'.$data[1].' . . .</a>';
        }
        sqlFinish($a);
        $html .= "</ul>";
        print $html;
}

#------------------------------------
# viewSurveyResults()
# return: htmlPage
sub viewSurveyResults {
        my ($html, $a, @A, $b, @B);
        $html .= '<h1>View Survey Results</h1>';
        ($a) = sqlQuery("describe survey");
        while (@A = sqlArray($a)) {
		if ($A[0] ne "id" && $A[0] ne "uid") {
			$html .= $A[0]."<br>\n";
       			($b) = sqlQuery("select ".$A[0].",count(".$A[0].") as tally from survey group by ".$A[0]." order by tally desc");
			while (@B = sqlArray($b)) {
				$html .= "&nbsp;&nbsp;&nbsp;".$B[1]." - ".$B[0]."\n<br>";
			}
			sqlFinish($b);
			$html .= "<p>";
		}
	}
        sqlFinish($a);
        print $html;
}








1;

