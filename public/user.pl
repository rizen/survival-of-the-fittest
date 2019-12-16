#!/usr/bin/perl 

BEGIN {
        unshift (@INC, "../lib");
}

use utility;
use account;

init();
my ($html, $cookie) = page();
print httpHeader($cookie);
print readInFile("header.include");
print $html;
print readInFile("footer.include");
cleanup();

#------------------------------------
# page()
# return: htmlPage, cookieInfo
sub page {
	my ($html, $cookie);
	if ($FORM{'op'} ne "") {
		($html, $cookie) = $FORM{'op'}();
	} else {
		($html, $cookie) = updateAccount();
	}
	return $html, $cookie;
}

#------------------------------------
# createAccount()
# return: html, cookie
sub createAccount {
	my ($html, $cookie, $error, $a, $uid, $junk);
	$html =	"<h1>Create an Account</h1>";
	if ($FORM{'doit'} eq "Create Account") {
		$error = validateAccount($FORM{'username'},$FORM{'password'});
		if ($error eq "") {
			($a) = sqlQuery("insert into player set username=".quote($FORM{'username'}).", identifier=".quote($FORM{'password'}).", email=".quote($FORM{'email'}).", icq=".quote($FORM{'icq'}).", pager=".quote($FORM{'pager'}));
			sqlFinish($a);
			($a) = sqlQuery("select last_insert_id()");
			($uid) = sqlArray($a);
			sqlFinish($a);
			$cookie = buildCookie("sgid",$uid."|".account::encrypt($FORM{'password'}),$FORM{'rememberpassword'});
			$html .= "<ul>\n<li>Account created.\n\n</ul>\n";
			$COOKIES{'sgid'} = $uid."|".account::encrypt($FORM{'password'});
			($junk) = updateAccount();
			$html .= $junk;
		} else {
			$FORM{'doit'} = "";
			$html .= "<ul>\n".$error."</ul>\n";
			($junk) = createAccount();
			$html .= $junk;
		}
	} else {
		$html .= '
		Please note that your username will be yours from this point forward. You will not have an opportunity to change it.
		<form method="post">
		<input type="hidden" name="op" value="createAccount">
		<table>
		<tr>
		<td valign="top">Username</td>
		<td valign="top"><input type="text" name="username" size="30" maxlength="30" value="'.$FORM{'username'}.'"><span class="formNote"><br>This is the name you\'ll be known by.</span></td>
		</tr>
		<tr>
		<td valign="top">Password</td>
		<td valign="top"><input type="password" name="password" size="30" maxlength="30"></td>
		</tr>
		<tr>
		<td valign="top">Password Retention</td>
		<td valign="top"><select name="rememberpassword"><option value="1" selected>Yes, please remember my password.<option value="0">No, don\'t remember my password.</select></td>
		</tr>
		<tr>
		<td valign="top">Email Address</td>
		<td valign="top"><input type="text" name="email" size="30" maxlength="255" value="'.$FORM{'email'}.'"><span class="formNote"><br>Your email address is necessary only if you wish to use features that require an email account.</span></td>
		</tr>
		<tr>
		<td valign="top">ICQ Number</td>
		<td valign="top"><input type="text" name="icq" size="30" maxlength="30" value="'.$FORM{'icq'}.'"><span class="formNote"><br>Your ICQ number is necessary only if you wish to use features that require ICQ.</span></td>
		</tr>
		<tr>
		<td valign="top">Pager Address</td>
		<td valign="top"><input type="text" name="pager" size="30" maxlength="255" value="'.$FORM{'pager'}.'"><span class="formNote"><br>Your pager\'s email address is only necessary if you wish to use features that require your pager.</span></td>
		</tr>
		<tr>
		<td valign="top"></td>
		<td valign="top"><input type="submit" name="doit" value="Create Account"></td>
		</tr>
		</table>
		</form>
		<ul>
		<li><a href="user.pl?op=recoverPassword">Forgot your password?</a>
		<li><a href="user.pl?op=login">Login.</a>
		</ul>
		';
	}
	return $html, $cookie;
}

#------------------------------------
# deactivateAccount()
# return: html, cookie
sub deactivateAccount {
	my ($html, $cookie, $a, $junk);
	if (account::checkLogin()) {
		$html =	"<h1>Deactivate Your Account</h1>";
		if ($FORM{'doit'} eq "yes") {
			$FORM{'doit'} = "";
			($a) = sqlQuery("update player set password='deactivated', email='', username=concat(username,' (deactivated)')"); sqlFinish($a);
			$cookie = buildCookie("sgid","",0);
			$html .= "<ul><li>Your account has been disabled.</ul>";
			($junk) = createAccount();
			$html .= $junk;
		} else {
			$html .= '
			Do you really wish to deactivate your account? 
				<a href="user.pl?op=deactivateAccount&doit=yes">Yes</a>
				<a href="user.pl?op=updateAccount">No</a>
			<p>	
			Please note that once an account is deactivated, it cannot be reactivated and all information associated with the account
			will be lost permanently.
			<ul>
			<li><a href="user.pl?op=logout">Logout.</a>
			</ul>
			';
		}
	} else { 
		$html .= login();
	}
	return $html, $cookie;
}

#------------------------------------
# isUsernameUnique(username)
# return: true or false
sub isUsernameUnique {
	my ($a, @data, $flag);
	($a) = sqlQuery("select uid from player where username=".quote($_[0]));
	@data = sqlArray($a);
	sqlFinish($a);
	if ($data[0] eq "") {
		$flag = 1;
	} else {
		$flag = 0;
	}
	return $flag;
}

#------------------------------------
# login()
# return: html, cookie
sub login {
	my ($html, $cookie, $a, $uid, $junk);
	$html = "<h1>Login</h1>\n";
	if ($FORM{'doit'} eq "login") {
		$FORM{'doit'} = "";
		($a) = sqlQuery("select uid from player where username=".quote($FORM{'username'})." and identifier=".quote($FORM{'password'}));
		($uid) = sqlArray($a);
		sqlFinish($a);
		if ($uid > 0) {
			$html .= "<ul><li>You have been logged in.</ul>\n";
			$cookie = buildCookie("sgid",$uid."|".account::encrypt($FORM{'password'}),$FORM{'rememberpassword'});
			$COOKIES{'sgid'} = $uid."|".account::encrypt($FORM{'password'});
			($junk) = updateAccount();
			$html .= $junk;
		} else {
			$html .= "<ul><li>You could not be identified by the information you supplied.</ul>\n";
			($junk) = login();
			$html .= $junk;
		}	
	} else {
		$html .= '
		<form method="post">
		<input type="hidden" name="op" value="login">
		<table>
		<tr>
		<td valign="top">Username</td>
		<td valign="top"><input type="text" name="username" size="30" maxlength="30" value="'.$FORM{'username'}.'"></td>
		</tr>
		<tr>
		<td valign="top">Password</td>
		<td valign="top"><input type="password" name="password" size="30" maxlength="30"></td>
		</tr>
		<tr>
		<td valign="top">Password Retention</td>
		<td valign="top"><select name="rememberpassword"><option value="1" selected>Yes, please remember my password.<option value="0">No, don\'t remember my password.</select></td>
		</tr>
		<tr>
		<td valign="top"></td>
		<td valign="top"><input type="submit" name="doit" value="login"></td>
		</tr>
		</table>
		</form>
		';
		if ($FORM{minimal} != 1) {
			$html .= '
			<ul>
			<li><a href="user.pl?op=recoverPassword">Forgot your password?</a>
			<li><a href="user.pl?op=createAccount">Create a new account.</a>
			</ul>
			';
		}
	}
	return $html, $cookie;
}

#------------------------------------
# logout()
# return: html, cookie
sub logout {
	my ($html, $cookie, $junk);
	$html = "<h1>Logout</h1>\n<ul>\n";
	$html .= "<li>You are now logged out of the system.\n";
	$html .= "</ul>\n";
	$cookie = buildCookie("sgid","",0);
	($junk) = login();
	$html .= $junk;
	return $html, $cookie;
}

#------------------------------------
# recoverPassword()
# return: html
sub recoverPassword {
	my ($html, $informationSent, $a, @data, $message, $junk);
	$html =	"<h1>Recover Your Password</h1>";
	if ($FORM{'doit'} eq "Send It!") {
		$FORM{'doit'} = "";
		($a) = sqlQuery("select username,identifier from player where lcase(email)=".quote(lc($FORM{'email'})));
		while (@data = sqlArray($a)) {
			$informationSent = 1;
			$message = "As you requested, your account information is provided below. Please\nkeep it in a safe place.\n\nUsername: ".$data[0]."\nPassword: ".$data[1]."\n\n ~ The Game Crafter Staff\n http://www.thegamecrafter.com\n";
			sendMail($FORM{'email'},"Account Information",$message);
		}
		sqlFinish($a);	
		if ($informationSent) {
			$html .= "<ul>\n<li>Account information sent.\n</ul>\n";
			($junk) = login();
		} else {
			$html = "<ul><li>The email address you entered was not found in our database.</ul>\n";
			($junk) = recoverPassword();
		}
		$html .= $junk;
	} else {
		$html .= '
		If you\'ve previously created an account, and cannot remember your login information, simply enter your
		email address below and click on the "Send It!" button. Your account information will be emailed to you.
		<form method="post" action="user.pl">
		<input type="hidden" name="op" value="recoverPassword">
		<input type="text" name="email" size="30" maxlength="255">
		<input type="submit" name="doit" value="Send It!">
		</form>
		<ul>
		<li><a href="user.pl?op=login">Login.</a>
		<li><a href="user.pl?op=createAccount">Create a new account.</a>
		</ul>
		';
	}
	return $html;
}

#------------------------------------
# updateAccount()
# return: html, cookie
sub updateAccount {
	my ($html, $cookie, $error, $a, @data, $junk);
	if (account::checkLogin()) {
		$html =	"<h1>Update Your Account</h1>";
		if ($FORM{'doit'} eq "Save") {
			$FORM{'doit'} = "";
			$error = validateAccount("not needed",$FORM{'password'});
			if ($error eq "") {
				($a) = sqlQuery("update player set identifier=".quote($FORM{'password'}).", email=".quote($FORM{'email'}).", icq=".quote($FORM{'icq'}).", pager=".quote($FORM{'pager'})." where uid=".$GLOBAL{'uid'});
				sqlFinish($a);
				$cookie = buildCookie("sgid",$GLOBAL{'uid'}."|".account::encrypt($FORM{'password'}),$FORM{'rememberpassword'});
				$html .= "<ul>\n<li>Account information saved.\n</ul>\n";
			} else {
				$FORM{'doit'} = "";
				$html .= "<ul>\n".$error."</ul>\n";
			}
			($junk) = updateAccount();
			$html .= $junk;
		} else {
			($a) = sqlQuery("select username, identifier, email, icq, pager, credits from player where uid=".$GLOBAL{'uid'});
			@data = sqlArray($a);
			sqlFinish($a);
			$html .= '
			<form method="post">
			<input type="hidden" name="op" value="updateAccount">
			<table>
			<tr>
			<td valign="top">Username</td>
			<td valign="top"><b>'.$data[0].'</b></td>
			</tr>
			<tr>
			<td valign="top">Password</td>
			<td valign="top"><input type="password" name="password" size="30" maxlength="30" value="'.$data[1].'"></td>
			</tr>
			<tr>
			<td valign="top">Password Retention</td>
			<td valign="top"><select name="rememberpassword"><option value="1" selected>Yes, please remember my password.<option value="0">No, don\'t remember my password.</select></td>
			</tr>
			<tr>
			<td valign="top">Email Address</td>
			<td valign="top"><input type="text" name="email" size="30" maxlength="255" value="'.$data[2].'"><span class="formNote"><br>Your email address is necessary only if you wish the game to contact you via email.</span></td>
			</tr>
			<tr>
			<td valign="top">ICQ Number</td>
			<td valign="top"><input type="text" name="icq" size="30" maxlength="30" value="'.$data[3].'"><span class="formNote"><br>Your ICQ number is necessary only if you wish the game to contact you via ICQ.</span></td>
			</tr>
			<tr>
			<td valign="top">Pager Address</td>
			<td valign="top"><input type="text" name="pager" size="30" maxlength="255" value="'.$data[4].'"><span class="formNote"><br>Your pager\'s email address is only necessary if you wish the game to contact you via your pager.</span></td>
			</tr>
                        <tr>
                        <td valign="top">Credits Remaining</td>
                        <td valign="top">'.$data[5].'</td>
                        </tr>
			<tr>
			<td valign="top"></td>
			<td valign="top"><br><br><input type="submit" name="doit" value="Save"></td>
			</tr>
			</table>
			</form>
			<ul>
			<li><a href="user.pl?op=logout">Logout.</a>
			</ul>
			';
		}
	} else {
		($junk) = login();
		$html .= $junk;
	}	
	return $html, $cookie;
}

#------------------------------------
# validateAccount(username, password)
# return: errorMessage
sub validateAccount {
	my ($error);
	if ($_[0] eq "") {
		$error = "<li>Your username cannot be blank.\n";
	} elsif ($_[1] eq "") {
		$error .= "<li>Your password cannot be blank.\n";
	} elsif (!(isUsernameUnique($_[0]))) {
		$error .= "<li><b>".$_[0]."</b> is already in use. Please try a variation like ".$_[0]."_2k1, or ".$_[0]."_too. You may also try another username all together.\n";
	}	
	return $error;
}

1;

