package documentation;
# load default modules
use strict;
use Exporter;

use utility;
# define global variables
our @ISA = qw(Exporter);
our @EXPORT = qw(&skillsDoc &clansDoc &futureAdditions &affinitiesDoc &eventsDoc &recentChanges &winningDoc &actionsDoc &equipmentDoc &amenityDoc);

#------------------------------------
# actionsDoc()
# return: html
sub actionsDoc {
	my ($html);
	$html .= '
		<h1>Actions</h1>
		<dl>
		<dt>Apply First Aid</dt>
		<dd>Use this feature to heal your wounds.  <p>Applying first aid uses, you guessed it, your first aid skill.</dd>
		<p>
		<dt>Hunt</dt>
		<dd>Use the hunt option to track down animals and other players. Once you\'ve tracked them
		down you\'ll have to choose what you want to do, but at least you\'ll know where they are.
		<p>
		Hunting can prove to be more or less difficult depending upon the terrain you\'re in.
		<p>
		Hunting uses your tracking, combat, and domestics skills.</dd>
		<p>
		<dt>Scavenge</dt>
		<dd>Scavenging can be used to search the area for hidden items.
		<p>
		Scavenging takes advantage of your senses skill.</dt>
		<p>
		<dt>Sneak</dt>
		<dd>Sneaking is used to hide yourself from other players and prevent theft and attacks. 
		You\'ll have to go into sneak (or
		stealth) mode for each sector you enter, but once you\'re in stealth mode, you\'ll stay in
		stealth mode until you leave the sector.
		<p>
		Sneaking makes use of your stealth skill.</dd>
		<p>
		<dt>Travel</dt>
		<dd>Travel lets you move around the map. This is how you\'ll know where you are. You\'ll also
		be able to use cartography to draw a map of where you\'ve been. If you have a map, you\'ll
		also be able to use it here.
		Travel makes use of your navigate skill.</dd>
		</dl>
	';
	return $html;
}

#------------------------------------
# affinitiesDoc()
# return: html
sub affinitiesDoc {
	my ($html);
	$html .= "
		<h1>Affinities</h1>
	Affinities are perceptions that villages, towns, and cities have of certain groups of people. Examples of those
	groups of people are murderers, mutants, thieves, and people that carry guns. 
	<p>
	If you fit into a category that
	a particular community may apply to you, then they will take some reaction upon you. Examples of those reactions
	may be to run you out of town, fine you, or even kill you. Pray that you don't meet their criteria.
	<p>
	You may wish to post gossip in taverns about your experiences in various communities.
	";
	return $html;
}

#------------------------------------
# amenityDoc()
# return: html
sub amenityDoc {
	my ($html);
	$html .= '
		<h1>Amenities</h1>
                <dl>
                <dt>Auction</dt>
                <dd>Auctions are a network of traveling traders who sell your wares for you. The items on sale are on sale in every
		town that holds auctions. The towns provide this as a free service to you in order to attract people to their town
		as a means of gaining additional business for their local businesses. </dd>
		<p>
		<dt>Blacksmith</dt>
		<dd>In addition to being able to buy and sell weapons and armor, you should also seek out
		a blacksmith if you need an item repaired.</dd>
		<p>
                <dt>Clanhall</dt>
              	<dd>Clanhalls are the hangouts and basecamps for the clans of this area. If a clan is strong in a given area they may have
		more than one clanhall. If they are not strong in the area they may have no clanhalls. Clanhalls provide many benefits
		to those who belong to the clan. (<a href="aux.pl?op=showPaymentOptions">Pay To Play Only</a>) </dd>
		<p>
		<dt>Doctor</dt>
		<dd>You can stop by to replenish your medical supplies, or get your injuries treated. Also,
		the doctor is the best way to eliminate toxins in your body.</dd>
		<p>
		<dt>Geneticist</dt>
		<dd>Though extraordinarily rare, if you can find the geneticist. He can remove those 
		pesky radiations.</dd>
		<p>
		<dt>Government Buildings</dt>
		<dd>Government buildings are only of use to the citizens of the town. They provide services such as banking, clan membership, postal services, and
		citizenship. (<a href="aux.pl?op=showPaymentOptions">Pay To Play Only</a>)</dd>
		<p>
		<dt>Library</dt>
		<dd>At the library you\'ll find books of all sorts. Perhaps you\'ll even find some that will
		help you further your skills.</dd>
		<p>
		<dt>Market</dt>
		<dd>The market is the only place where you can buy and sell <b>anything</b>.</dd>
		<p>
		<dt>Pet Store</dt>
		<dd>If you need a pal, the pet store is a great place to find one.</dd>
		<p>
		<dt>Restaurant</dt>
		<dd>The restaurant provides excellent food, and maybe even a place to work.</dd>
		<p>
		<dt>Tavern</dt>
		<dd>The tavern is your basic one-stop shop for the weary traveller. You could get a bite to eat,
		do a little gambling, get some information, or even have a little chat.</dd>
		<p>
		<dt>Trade Depot</dt>
		<dd>At the trade depot you\'ll be able to buy and sell the very rarest of items. </dd>
		</dl>
	';
	return $html;
}

#------------------------------------
# clansDoc()
# return: html
sub clansDoc {
        my ($html);
        $html .= '
        <h1>Clans</h1>
	Clans are a major part of the deadEarth storyline. They unite people of varying backgrounds for protection and wealth.
	In SotF clans provide you with some special abilities. Each one has a unique form of protection. Everything from Player Killing
	to Poison can be nullified. In addition you can get access to the Clanhall for extra support. 
	(<a href="aux.pl?op=showPaymentOptions">Pay To Play Only</a>)
        ';
        return $html;
}

#------------------------------------
# equipmentDoc()
# return: html
sub equipmentDoc {
	my ($a, $b, $html, @item, @attribute);
	$html = "<h1>Equipment List</h1>\n";
	$html .= "The following is a list of equipment you may hope to find in Survival of the Fittest. Keep in mind that actual street prices may not be the same as the costs listed here. Also note that this is by no means a listing of all the equipment in the game.<p>\n";
	$html .= "<table cellpadding=0 cellspacing=0 border=0 align='center'>\n";
	($a) = sqlQuery("select id,name,cost from item where type not in ('ammunition','junk','quest','unique','pelt','food') order by name");
	while (@item = sqlArray($a)) {
		$html .= "<tr><td>".$item[1]."</td><td align=right>\$".$item[2]."</td><td></td></tr>\n";
		($b) = sqlQuery("select type,value from itemAttributes where class<>'version' and class<>'requirement' and itemId=".$item[0]." order by type");
		while (@attribute = sqlArray($b)) {
			$html .= "<tr><td colspan=3>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;".$attribute[1]." ".$attribute[0]."</td></tr>\n";
		}
		sqlFinish($b);
		$html .= "<tr><td colspan=3>&nbsp;</td></tr>\n";
	}
	sqlFinish($a);
	$html .= "</table>\n";
	return $html;
}

#------------------------------------
# eventsDoc()
# return: html
sub eventsDoc {
	my ($html);
	$html .= "
		<h1>Events</h1>
	Occasionally you'll notice an orange message show up in your message log. This is to let you know that an event
	has occured. Events are special scenarios that we threw into the game just to keep you on your toes. Some events
	can be beneficial, but most are detrimental. You'll have to read your recent messages to find out which is the case
	for you.
	";
	return $html;
}

#------------------------------------
# futureAdditions()
# return: html
sub futureAdditions {
	my ($html);
	$html .= "
		<h1>Future Additions</h1>
	The following is a list of ideas we're considering as additions to the game. There is no guarantee that we'll
	ever implement these features, but we thought we'd post them here so you can see what may be on the horizon.
	If you have an idea, drop us a note at <a href=\"mailto:info\@thegamecrafter.com\">info\@thegamecrafter.com</a>
	<ul>
	<li>Hidden extended parts of the world like an extensive cave system.
	<li>A repair skill. Tools will need to be added for this.
	<li>Add the use of boats in order to cross lakes.
	<li>Add fishing skill and action.
	<li>Add character equipping locations. Therefore you can equip boots on your feet, and clothes and armor on your body, and weapons in your hands. etc.
	<li>Add climbing gear or hang gliders to get over mountains and gorges.
	<li>Random weather patterns.
	<li>Barter items instead of money.
	<li>In-game games that players could play against the computer or each other.
	<li>Amenity based events. When you're in a bar a bar brawl might break out, etc.
	<li>Player drawn maps that could be sold, traded, and stolen.
	<li>Requirement of pen and paper before you could use the cartography function.
	<li>Personalized markings on cartography map.
	<li>Player-on-player combat arenas.
	<li>Reaction triggers so that if your character is attacked or stolen from, it can react without your intervention.
	<li>Add rescue and defend types of quests.
	<li>Added ability to set up traps and also poison food.
	<li>Destroy terrain perhaps through burning it.
	<li>Sail cars and beasts of burden.
	<li>Foraging for food. Perhaps through the use of an herb lore skill.
	<li>Guile/Charisma skill for talking to NPCs. Perhaps they give you better or worse information and prices based upon skill roles.
	<li>Roving NPCs like merchants etc.
	<li>AI NPCs who act like players in the game. This technology could be applied to wild animals as well.
	<li>Player tracking.
	</ul>
	";
	return $html;
}

#------------------------------------
# recentChanges()
# return: html
sub recentChanges {
	my ($html);
	$html .= "
		<h1>Recent Changes</h1>
                <b>3.1.0</b>
                <ul>
                <li>When you get drunk, your message log get's drunk as well. =)
		<li>Added an experimental battle cry system to player-vs-player combat and hunting combat. If it works out well, the technology
			may be added to NPCs throughout the game for a diverse conversational system.
                </ul>
		<b>3.0.1</b>
		<ul>
		<li>Message boards are now working again.
		</ul>
                <b>3.0.0</b>
                <ul>
		<li>More equipment, creatures, and quests.
		<li>First place winners now get a free copy of the deadEarth Player's Handbook or 4 deadEarth supplements of choice.
		<li>Players may now choose a reaction to take toward other players who are stealing or attacking them.
		<li>Amenities now evolve over the course of the month.
		<li>Terrain now evolves over the course of the month.
                <li>Streamlined the interface for better ease of use and even more speed.
		<li>You are no longer a newbie after 1000 turns (instead of 1800).
		<li>Added a new postal system to the government buildings.
		<li>Tweaked the buy/sell negotiations for even greater realism.
		<li>Restructured the code-base for greater security and speed.
		<li>Added new sorting features on message log.
		<li>Non-PTP players no longer get trickle turns, only the 5000 upon creating their character.
                </ul>
                <b>2.6.5</b>
                <ul>
                <li>Fixed the dreaded drunk bug that would cause the game to slow way down (or even stall) for characters that were drunk.
                </ul>
                <b>2.6.4</b>
                <ul>
                <li>Fixed a few bugs (documented on the bug board).
                <li>Fixed a few bugs where events that delete items could cause the game to produce an error if the player had no items to delete.
                </ul>
                <b>2.6.3</b>
                <ul>
                <li>Fixed many database handling bugs, which could have lead to game instability.
		<li>Committing suicide now removes your deeds and renown.
                </ul>
                <b>2.6.2</b>
                <ul>
                <li>Removed Quidnunc Tavern, it is now housed back at the deadEarth site.
		<li>Increased the top prize to three free months of SotF.
		<li>Added some more error trapping code in order to find out what's slowing down the game lately.
                </ul>
                <b>2.6.1</b>
                <ul>
                <li>Fixed a few bugs (documented on the bug board).
		<li>New, more distributed dice roller added.
		<li>Deeds are now added for random animal attacks and thug attacks (if you are successful).
                </ul>
                <b>2.6.0</b>
                <ul>
                <li>Non-PTP players now have 5000 turns to start to give them a better feel for the game. 
			However, they can no longer use Rad Doctors or Trade Depots.
		<li>Some amenities now have apprenticeship opportunties.
		<li>Updated some documentation.
                </ul>
                <b>2.5.2</b>
                <ul>
                <li>Fixed a few bugs (documented on the bug board). Most notably, <b>the godmode bug</b>!
		<li>Changed the internal game error message to instruct the user to post the message to the bug board.
                </ul>
                <b>2.5.1</b>
                <ul>
                <li>Fixed a few bugs (documented on the bug board).
                </ul>
                <b>2.5.0</b>
                <ul>
		<li>Renown descriptions added to nearby player description.
		<li>Deeds/Renown menu item added under the character menu.
		<li>Renown now has a significant impact on the ranking system, thus it also has a significant impact on the winner.
		<li>Affinities are now processed just after you attack or thieve from a player in town....just in case you are breaking the law.
		<li>Better handling of ordinals like A and AN.
		<li>Better handling of plurals.
		<li>Added more descriptive messages to auction updates.
                <li>Renown now stays with your character between deaths.
                <li>Updated more documentation to a new format for easier readablity.
                <li>Fixed a few bugs (documented on the bug board).
                </ul>
                <b>2.4.0</b>
                <ul>
		<li>Added a troubadour skill.
		<li>Added a renown attribute.
		<li>Added renown accumulation for deeds.
		<li>Added names to quests.
		<li>Added story telling system to gossip boards for renown gain.
                <li>Added a lot more documentation including documentation of clans and skills.
                <li>Fixed a few bugs (documented on the bug board).
                </ul>
                <b>2.3.1</b>
                <ul>
                <li>If a member of AlphaPrime is in first place s/he is no longer immune from attack.
                <li>Fixed a few bugs (documented on the bug board).
                </ul>
                <b>2.3.0</b>
                <ul>
                <li>Newbie status has been lowered to 1800 turns.
                <li>Added a Quests submenu under Character.
		<li>Added clanhalls to the game creation system.
		<li>Added clanhalls to the amenities system.
		<li>Added clanhall listings to the government buildings.
                <li>Fixed a few bugs (documented on the bug board).
                </ul>
                <b>2.2.4</b>
                <ul>
                <li>A few text changes.
                <li>Updated geneticist prices.
                <li>Fixed the slowness on the front page.
                <li>Fixed a few bugs (documented on the bug board).
                </ul>
                <b>2.2.3</b>
                <ul>
                <li>Fixed a few bugs (documented on the bug board).
                </ul>
                <b>2.2.2</b>
                <ul>
                <li>Player name is now added to the status bar.
                <li>Item count has been added to the inventory page.
                <li>Password on account creation is now privacy protected.
                <li>Fixed a few bugs (documented on the bug board).
                </ul>
                <b>2.2.1</b>
                <ul>
                <li>AlphaPrime may not attack other players.
		<li>Gender and clan now show up in attributes listing.
                <li>The Wraiths now have a new special ability and description.
                <li>Added clan membership statistics to Interesting Tidbits.
                <li>Added clan membership listing to government buildings.
                <li>Fixed a bug with password recovery.
                <li>Fixed many bugs (documented on the bug board).
                </ul>
                <b>2.2.0</b>
                <ul>
                <li>Added some ICQ related features to the Nearby Player system.
                <li>Provided a description of a nearby player.
                <li>Renting a room now provides better protection.
                <li>You are now told in advance if you can or cannot attack or steal from someone, and why.
                <li>You can now choose your gender at character creation.
                <li>Pay To Play members can now gain extra abilities by joining clans. This system is in limited use this month, but will be available in every town starting next month.
                <li>Fixed some bugs (documented on the bug board).
                </ul>
                <b>2.1.0</b>
                <ul>
                <li>Added the 'bank an item' feature and one government building. In next month's game, all civilization will have government buildings.
                <li>Geneticist now reveals his prices.
                <li>Animal attack events are now not only big badass creatures, but are sometimes small creatures as well. This should change the frequency of unsurvivable animal attacks.
                <li>Fixed some bugs (documented on the bug board).
                </ul>
                <b>2.0.5</b>
                <ul>
                <li>Newbies are no longer newbies if they attack or steal from someone. Instead they'll immediately be bumped up to 2000 turns spent.
                <li>Items dropped in sectors now take on hide ratings congruent with that sector.
                <li>Added more info to the FAQ.
                <li>Added another quest trigger.
                <li>Made the chances of getting a quest 10 times more likely.
                <li>Fixed the stranger bug.
                </ul>
                <b>2.0.4</b>
                <ul>
                <li>Added a few message board updates.
                <li>Added some more equipment.
                <li>Upped the number of cheats you're allowed before you're killed.
                <li>Fixed the 'You found 1 .' bug.
                <li>Fixed some textual mistakes.
                <li>Fixed the stranger bug.
                </ul>
                <b>2.0.3</b>
                <ul>
                <li>Added banners for free-play. When you pay to play the banners go away.
                <li>Fixed a couple bugs.
                </ul>
                <b>2.0.2</b>
                <ul>
                <li>Made some message board improvements.
                <li>The game now imposes an inventory limit of 500 items (not counting \$tandards).
		<li>Added a lynch mob event.
                </ul>
                <b>2.0.1</b>
                <ul>
                <li>Fixed spelling error 'barren' for the next map gen.
		<li>Chance of getting quest from bartender is now double.
		<li>Added a new option for the survey item 'did you pay to play'.
		<li>We have 2 new quest writers.
                </ul>
                <b>2.0.0</b>
                <ul>
                <li>Polished and ready for the public. (With any luck!)
                </ul>
	";
	return $html;
}

#------------------------------------
# skillsDoc()
# return: html
sub skillsDoc {
        my ($html);
        $html .= '
        <h1>Skills</h1>
	Your character has many skills that s/he can improve over the course of the game. As your skills get better and better you\'ll be able to
	do more and more with them. These are the skills currently available in the game:
	<dl>
	<dt>beast lore</dt>
	<dd>The knowledge and application of knowledge to understand the creatures in the wilderness and their properties.</dd>
	<p>
	<dt>combat</dt>
	<dd>The knowledge and use of weapons and hand-to-hand combat for your own protection and well-being.</dd>
	<p>
	<dt>domestics</dt>
	<dd>The general life-skills of everyday consequnce. These include things like cooking and sewing.</dd>
	<p>
	<dt>first aid</dt>
	<dd>The knowledge and application of basic medical skills to heal wounds and apply medicines.</dd>
	<p>
	<dt>haggle</dt>
	<dd>Skill in appraisal and negotiation for the trade of goods and services.</dd>
	<p>
	<dt>hork</dt>
	<dd>The old five-finger-discount or slight of hand used to steal items.</dd>
	<p>
	<dt>navigate</dt>
	<dd>Skill in the use of maps, compasses, and natural markings to determine direction and distance.</dd>
	<p>
	<dt>senses</dt>
	<dd>The mastering of ones own natural five senses: touch, smell, sound, taste, and sight.</dd>
	<p>
	<dt>stealth</dt>
	<dd>Skill in moving silently and finding good hiding places, both for you and items you carry or wish to leave behind.</dd>
	<p>
	<dt>tracking</dt>
	<dd>Skill in finding what remains after a person or animal passes through an area, and to determine where they might have gone.</dd>
	<p>
	<dt>troubadour</dt>
	<dd>General skill in storytelling and entertainment.</dd>
	</dl>
        ';
        return $html;
}

#------------------------------------
# winningDoc()
# return: html
sub winningDoc {
	my ($html);
	$html .= '
		<h1>Winning</h1>
		<dl>
		<dt>Turns</dt>
		<dd>Turns are the measure of how much you can do and how much you have done over the course of a game. In freeplay mode you only have 5000
		turns. In <a href="aux.pl?op=showPaymentOptions">Pay To Play</a> mode you have unlimited
		turns to work with (and don\'t forget about all the extra features).</dd>
		<p>
		<dt>Credits</dt>
		<dd>Credits are representative of how many months of unlimited play you have remaining. When you 
		<a href="aux.pl?op=showPaymentOptions">Pay To Play</a> you get one credit for each month of unlimited play that you purchase.
		If you are lucky enough to be in the top five at the end of any game, you\'ll earn one free credit, which will be added to 
		your total credits at the end of the month.</dd>
		<p>
		<dt>Deeds</dt>
		<dd>Deeds are unique actions that you\'ve completed in the game. Each time you kill an animal you haven\'t killed before, a deed will be
		logged for you. Likewise, each time you complete a quest you haven\'t completed before, you\'ll get another deed. Deeds remain with 
		you even if your character dies.</dd>
		<p>
		<dt>Renown</dt>
		<dd>Renown is gained for telling stories about your deeds. (Tell your story on the gossip boards in taverns and clanhalls.) Once you\'ve
		told your story in enough places, you\'ll gain some renown for your deed. Most deeds are worth one point of renown, but there are certain
		special deeds that are worth more. Renown also stays with your character even if you die and create a new character. Renown has a
		significant impact on your ranking. You could be far behind in turns and still win based upon renown.</dd>
		</dl>
		<p>
		Winning Survival of the Fittest is not easy. It is a very difficult game, and many quit before they\'ve even given it a chance. If you want to
		win, you need to build up your renown, and then get as many turns under your belt as possible.<p>
		Good luck. You\'ll need it.
	';
	return $html;
}



1;

