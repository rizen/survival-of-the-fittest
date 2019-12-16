package systemTools;
# load default modules
use strict;
use Exporter;

use utility;
# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&inviteFriend &showPaymentOptions &survey);

#------------------------------------
# inviteFriend()
# return: html
sub inviteFriend {
	my ($html, $subject, $message);
	$html .= '<h1>Invite a Friend</h1>';
	if ($FORM{'doit'} eq "send") {
		$subject = "Invitation from ".$GLOBAL{'username'}."!";
		$message .= '
		Your friend, who identified his/her-self as '.$GLOBAL{'username'}.', has
		cordially invited you to join the online game Survival of the Fittest.
		';
		if ($FORM{'comments'} ne "") {
			$message .= '
			Your friend had these additional comments: 
			'.$FORM{'comments'};
		}
		$message .= '

		Please come checkout Survival of the Fittest. We at The Game Crafter
		(and your friend) believe you won\'t be disappointed.

		http://sotf.thegamecrafter.com
		';
		sendMail($FORM{'email'},$subject,$message);
		$html .= '<ul><li>Message sent.</ul>';
	}
	$html .= '
		<form method="post" action="'.$GLOBAL{'program'}.'">
		<input type="hidden" name="op" value="inviteFriend">
		<input type="hidden" name="doit" value="send">
		To: <input type="text" name="email"><br>
		From: info@thegamecrafter.com<br>
		Subject: Invitation from '.$GLOBAL{'username'}.'!<br>
		<br>
		Your friend, who identified his/her-self as '.$GLOBAL{'username'}.', has
		cordially invited you to join the online game Survival of the Fittest.
		<p>
		Your friend had these additional comments:<br>
		<textarea cols="40" rows="6" name="comments"></textarea>
		<p>
		Please come checkout Survival of the Fittest. We at The Game Crafter
		(and your friend) believe you won\'t be disappointed.
		<p>
		http://sotf.thegamecrafter.com
		<p>
		<input type="submit" value="Send to my friend!">
		</form>
	';
	return $html;
}

#------------------------------------
# showPaymentOptions()
# return: html
sub showPaymentOptions {
	my ($html);
	$html .= '
<h1>Announcement</h1>
It is likely that SotF will be discontinued after this month of gameplay due to lack of funding to keep it alive. If the game does shut down, credits will not be refunded. Purchase at your own risk.
<hr>
<br><br><BR><BR><BR>
	<A HREF="https://www.paypal.com/verified/pal=payments%40thegamecrafter.com" target="_blank"><IMG align="right" SRC="/verification_seal.gif" BORDER="0" ALT="Official PayPal Seal"></A>
	<h1>Payment Options</h1>
	Note: Remember that when you pay to play, you not only get unlimited turns, but the banners are removed, and you get some extra features, and
	you give us incentive to continue developing this system.
	<p>
	<a href="https://www.paypal.com/affil/pal=payments%40thegamecrafter.com">Click here to become a PayPal member.</a>
	<p><table>
	<tr>
		<td valign="top">
		<FORM ACTION="https://www.paypal.com/cgi-bin/webscr" METHOD="POST">
		<INPUT TYPE="hidden" NAME="cmd" VALUE="_xclick">
		<INPUT TYPE="hidden" NAME="business" VALUE="payments@thegamecrafter.com">
		<INPUT TYPE="hidden" NAME="return" VALUE="http://sotf.thegamecrafter.com/thankyou.shtml">
		<INPUT TYPE="hidden" NAME="item_name" VALUE="3 months of SotF">
		<INPUT TYPE="hidden" NAME="item_number" VALUE="SotF-'.$GLOBAL{'username'}.'">
		<INPUT TYPE="hidden" NAME="amount" VALUE="6.00">
		<INPUT TYPE="image" SRC="http://images.paypal.com/images/x-click-but6.gif" NAME="submit" ALT="Make payments with PayPal - it\'s fast, free and secure!">
		</FORM>
		</td>
		<td>I would like 3 months of game play for US$6.00.</td>
	</tr>
	<tr><td colspan=2>&nbsp;</td></tr>
	<tr>
		<td valign="top">
		<FORM ACTION="https://www.paypal.com/cgi-bin/webscr" METHOD="POST">
		<INPUT TYPE="hidden" NAME="cmd" VALUE="_xclick">
		<INPUT TYPE="hidden" NAME="business" VALUE="payments@thegamecrafter.com">
		<INPUT TYPE="hidden" NAME="return" VALUE="http://sotf.thegamecrafter.com/thankyou.shtml">
		<INPUT TYPE="hidden" NAME="item_name" VALUE="6 months of SotF">
		<INPUT TYPE="hidden" NAME="item_number" VALUE="SotF-'.$GLOBAL{'username'}.'">
		<INPUT TYPE="hidden" NAME="amount" VALUE="12.00">
		<INPUT TYPE="image" SRC="http://images.paypal.com/images/x-click-but6.gif" NAME="submit" ALT="Make payments with PayPal - it\'s fast, free and secure!">
		</FORM>
		</td>
		<td>I would like 6 months of game play for US$12.00.</td>
	</tr>
	<tr><td colspan=2>&nbsp;</td></tr>
	<tr>
		<td valign="top">
		<FORM ACTION="https://www.paypal.com/cgi-bin/webscr" METHOD="POST">
		<INPUT TYPE="hidden" NAME="cmd" VALUE="_xclick">
		<INPUT TYPE="hidden" NAME="business" VALUE="payments@thegamecrafter.com">
		<INPUT TYPE="hidden" NAME="return" VALUE="http://sotf.thegamecrafter.com/thankyou.shtml">
		<INPUT TYPE="hidden" NAME="item_name" VALUE="9 months of SotF">
		<INPUT TYPE="hidden" NAME="item_number" VALUE="SotF-'.$GLOBAL{'username'}.'">
		<INPUT TYPE="hidden" NAME="amount" VALUE="15.00">
		<INPUT TYPE="image" SRC="http://images.paypal.com/images/x-click-but6.gif" NAME="submit" ALT="Make payments with PayPal - it\'s fast, free and secure!">
		</FORM>
		</td>
		<td>I would like 9 months of game play for the discounted price of US$15.00.</td>
	</tr>
	<tr><td colspan=2>&nbsp;</td></tr>
	<tr>
		<td valign="top">
		<FORM ACTION="https://www.paypal.com/cgi-bin/webscr" METHOD="POST">
		<INPUT TYPE="hidden" NAME="cmd" VALUE="_xclick">
		<INPUT TYPE="hidden" NAME="business" VALUE="payments@thegamecrafter.com">
		<INPUT TYPE="hidden" NAME="return" VALUE="http://sotf.thegamecrafter.com/thankyou.shtml">
		<INPUT TYPE="hidden" NAME="item_name" VALUE="12 months of SotF">
		<INPUT TYPE="hidden" NAME="item_number" VALUE="SotF-'.$GLOBAL{'username'}.'">
		<INPUT TYPE="hidden" NAME="amount" VALUE="18.00">
		<INPUT TYPE="image" SRC="http://images.paypal.com/images/x-click-but6.gif" NAME="submit" ALT="Make payments with PayPal - it\'s fast, free and secure!">
		</FORM>
		</td>
		<td>I would like 12 months of game play for the discounted price of US$18.00.</td>
	</tr>
	</table><p>
	<div class="formNote">
	By purchasing playtime on Survival of the Fittest, you agree to the terms of the play contract:
	<ol>
	<li>Neither The Game Crafter, LLC nor any of its constituents, holders, or subsidiaries can be held
	 libel for any psychological or physical damages you may suffer as a player of Survival of the Fittest.
	<li>You are paying for credits of service. One credit shall represent one month of unlimited play on 
	Survival of the Fittest. One credit shall be debited from your account each month
	until there are no remaining credits. The credits shall be debited every month whether you play or not.
	<li>Should you purchase credits past the 20th of the current month, you\'ll not be charged a credit for
	the remainder of that month.
	<li>The Game Crafter, LLC shall only provide refunds where it deems necessary. It makes no guarantees or
	warranties of any kind for Survival of the Fittest.
	</ol>
	</div>
	';
	return $html;
}

#------------------------------------
# survey()
# return: html
sub survey {
	my ($html, $a, @data);
	$html .= '<h1>Survey</h1>';
	if ($FORM{'doit'} eq "save") {
		($a) = sqlQuery("insert into survey set uid=".$GLOBAL{'uid'}.", heardAboutUs=".quote($FORM{'heardAboutUs'}).", age=".quote($FORM{'age'}).", likeIt=".quote($FORM{'likeIt'}).", education=".quote($FORM{'education'}).", likeMost=".quote($FORM{'likeMost'}).", gender=".quote($FORM{'gender'}).", likeLeast=".quote($FORM{'likeLeast'}).", whereFrom=".quote($FORM{'whereFrom'}).", playedDE=".quote($FORM{'playedDE'}).", purchasedTime=".quote($FORM{'purchasedTime'}));
		sqlFinish($a);
	}
	($a) = sqlQuery("select uid from survey where uid=".$GLOBAL{'uid'});
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] ne "") {
		$html .= 'Thanks for taking part in our survey. Your input will help us make
			SotF a better game.';
	} else {
		$html .= '
		<form method="post" action="'.$GLOBAL{'program'}.'">
		<input type="hidden" name="op" value="survey">
		<input type="hidden" name="doit" value="save">
		<dl>
		<dt>How did you hear about Survival of the Fittest?
		<dd><select name="heardAboutUs">
		<option value="">---</option>
		<option value="friend">a friend</option>
		<option value="dE Site">deadEarth web site</option>
		<option value="TGC Site">The Game Crafter web site</option>
		<option value="search engine">search engine</option>
		<option value="ad">advertisement</option>
		<option value="dumb luck">just surfing</option></select>
		<p>
		<dt>How old are you?
		<dd><select name="age">
		<option value="">---</option>
		<option value="under 18">under 18</option>
		<option value="18-30">18-30</option>
		<option value="31-45">31-45</option>
		<option value="46-65">46-65</option>
		<option value="over 65">over 65</option>
		</select>
		<p>
		<dt>How do you like SotF now that you\'ve found it?
		<dd><select name="likeIt">
		<option value="">---</option>
		<option value="cool">way cool</option>
		<option value="good">not bad</option>
		<option value="bad">not good</option>
		<option value="ugly">hate it!</option>
		</select>
		<p>
		<dt>How edjubicated is ya?
		<dd><select name="education">
		<option value="">---</option>
		<option value="not">i like pi with cherries on top (none)</option>
		<option value="high school">pi = 3.14 (high school)</option>
		<option value="college">pi = 3.14159265358979 (college)</option>
		<option value="graduate +">pi = 4 * atan2(1,1) (graduate +)</option>
		</select>
		<p>
		<dt>What do you like most about SotF?
		<dd><select name="likeMost">
		<option value="">---</option>
		<option value="pvp">player interaction</option>
		<option value="setting">the setting</option>
		<option value="free play">free play</option>
		<option value="pay to play">unlimited turns (via pay to play)</option>
		<option value="evolution">evolving world</option>
		<option value="character stuff">character creation / advancement</option>
		<option value="quests">quests</option>
		<option value="nothing">nothing</option>
		</select>
		<p>
		<dt>Your gender?
		<dd><select name="gender">
		<option value="">---</option>
		<option value="female">sugar and spice (female)</option>
		<option value="male">snips and snails (male)</option>
		</select>
		<p>
		<dt>What do you like least about SotF?
		<dd><select name="likeLeast">
		<option value="">---</option>
		<option value="pvp">player interaction</option>
		<option value="setting">the setting</option>
		<option value="free play">free play</option>
		<option value="pay to play">unlimited turns (via pay to play)</option>
		<option value="evolution">evolving world</option>
		<option value="character stuff">character creation / advancement</option>
		<option value="quests">quests</option>
		<option value="nothing">nothing</option>
		</select>
		<p>
		<dt>Where U at?
		<dd><select name="whereFrom">
		<option value="">---</option>
		<option value="USA">USA</option>
		<option value="Canada">North America (outside USA)</option>
		<option value="South America">South America</option>
		<option value="Europe">Europe</option>
		<option value="Asia">Asia</option>
		<option value="Africa">Africa</option>
		<option value="Australia">Australia</option>
		</select>
		<p>
		<dt>Have you ever played deadEarth?
		<dd><select name="playedDE">
		<option value="">---</option>
		<option value="Yes">Yes</option>
		<option value="No">No</option>
		</select>
		<p>
		<dt>Have you purchased Pay To Play time on SotF?
		<dd><select name="purchasedTime">
		<option value="">---</option>
		<option value="Yes">Yes</option>
		<option value="No - cheap bastard">No, I\'m a cheap bastard</option>
		<option value="No - bad game">No, the game isn\'t worth $2</option>
		<option value="No - no internet purchase">No, I\'m afraid the Internet demons will snatch my credit card</option>
		<option value="No - just testing">No, I\'m still checking it out</option>
		</select>
		<p>
		</dl>
		<input type="submit" value="Save my answers!">
		</form>
		';
	}	
	return $html;
}



1;

