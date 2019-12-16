package battlecry;

use strict;

sub grunt {
	my (%things,@base,$line,$section,$phrase,@pos,$key);
	open( BASE, "/data/domains/thegamecrafter.com/sotf/lib/battlecries.txt" );
	@base = (<BASE>);
	chomp @base;
	close BASE;
	foreach $line (@base) {
 		if ($line =~ /^\[(.*)\]$/) {
  			$section = $1;
 		} elsif ($line eq "") { 
			$section = undef; 
		} elsif ($section) { 
			push @{$things{$section}},$line; 
		} 
	}
 	$phrase = ${$things{'TEMPLATES'}}[int rand @{$things{'TEMPLATES'}}];
 	foreach $key (keys %things) {
  		@pos = @{$things{$key}};
  		$phrase =~ s/\b$key\b/${$things{$key}}[int rand @{$things{$key}}]/g;
 	}
 	$phrase = ucfirst($phrase);
 	return $phrase;
} 

1;

