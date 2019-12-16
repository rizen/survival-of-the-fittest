package drunk;

sub drunkify {
	my ($output, $in, $count, $char);
       	$in = $_[0];
       	$count = 0;
        while (substr($in,$count,1)) {
                $char = substr($in,$count,1);
                $output .= &convert($char);
                $count++;
        }
	return $output;
}

sub convert {
	my (%drunk, $rint, $return);
        $drunk{'a'} = [("a", "a", "a", "A", "aa", "ah", "Ah", "ao", "aw", "oa", "ahhhh")];
        $drunk{'b'} = [("b", "b", "b", "B", "B", "vb")];
        $drunk{'c'} = [("c", "c", "C", "cj", "sj", "zj")];
        $drunk{'d'} = [("d", "d", "D")];
        $drunk{'e'} = [("e", "e", "eh", "E")];
        $drunk{'f'} = [("f", "f", "ff", "fff", "fFf", "F")];
        $drunk{'g'} = [("g", "g", "G")];
        $drunk{'h'} = [("h", "h", "hh", "hhh", "Hhh", "HhH", "H")];
        $drunk{'i'} = [("i", "i", "Iii", "ii", "iI", "Ii", "I")];
        $drunk{'j'} = [("j", "j", "jj", "Jj", "jJ", "J")];
        $drunk{'k'} = [("k", "k", "K")];
        $drunk{'l'} = [("l", "l", "L")];
        $drunk{'m'} = [("m", "m", "mm", "mmm", "mmmm", "mmmmm", "MmM", "mM", "M")];
        $drunk{'n'} = [("n", "n", "nn", "Nn", "nnn", "nNn", "N")];
        $drunk{'o'} = [("o", "o", "ooo", "ao", "aOoo", "Ooo", "ooOo")];
        $drunk{'p'} = [("p", "p", "P")];
        $drunk{'q'} = [("q", "q", "Q", "ku", "ququ", "kukeleku")];
        $drunk{'r'} = [("r", "r", "R")];
        $drunk{'s'} = [("s", "ss", "zzZzssZ", "ZSssS", "sSzzsss", "sSss")];
        $drunk{'t'} = [("t", "t", "T")];
        $drunk{'u'} = [("u", "u", "uh", "Uh", "Uhuhhuh", "uhU", "uhhu")];
        $drunk{'v'} = [("v", "v", "V")];
        $drunk{'w'} = [("w", "w", "W")];
        $drunk{'x'} = [("x", "x", "X", "ks", "iks", "kz", "xz")];
        $drunk{'y'} = [("y", "y", "Y")];
        $drunk{'z'} = [("z", "z", "ZzzZz", "Zzz", "Zsszzsz", "szz", "sZZz", "ZSz", "zZ", "Z")];
        if ($drunk{$_[0]}) {
                $rint = rand($#{ $drunk{$_[0]} });
                $return = $drunk{$_[0]}[$rint];
        } else {
                $return = $_[0];
        }
        $return;

}



1;

