#-*-perl-*-
#$Id: 001_passthru.t 529 2009-10-29 18:48:14Z maj $
use strict;
use warnings;
use lib '../lib';
use Test::More tests => 15;
use File::Temp qw(tempfile);
use File::Spec;
use_ok('IO::Seekable');
use_ok('PerlIO::via::SeqIO');
use_ok('Bio::SeqIO');

use PerlIO::via::SeqIO qw(open);

# test open passthrough
no strict qw(refs);
#read
ok my ($tmph, $tmpf) = tempfile(DIR=>'.', UNLINK=>1), "make plain file";

print $tmph join("\n", qw( fourscore and seven years ago )), "\n";
$tmph->close;

ok open(my $fh, "<", $tmpf), "open plain file for reading";
my @slurp = <$fh>;
is_deeply( \@slurp, [map { $_."\n" } qw( fourscore and seven years ago )], "roundtrip plain file");
$fh->close;
undef $fh;
#write
ok open( $fh, ">:raw", $tmpf), "open plain file for writing through :raw";
print $fh join("\n", qw( fourscore and seven years ago )), "\n";
$fh->close;
undef $fh;
ok open($fh, "<", $tmpf), "open plain file for reading";
@slurp = <$fh>;
is_deeply( \@slurp, [map { $_."\n" } qw( fourscore and seven years ago )], "roundtrip plain file");
$fh->close;
undef $fh;

my $dtapos = tell(DATA);
ok open( $fh, '<&', 'DATA' ), "redirect DATA, open passthru"; 
<$fh>;
my $slurp=<$fh>;
ok $slurp =~ /^ATGGACGACAAAG/, "redirect ok, got sequence line";

seek(DATA, $dtapos, 0);
ok open('DUP', '<&', 'DATA' ), "duplicate DATA, bareword handle, open passthru";
<DUP>;$slurp=<DUP>;
ok $slurp =~ /^ATGGACGACAAAG/, "dup ok, got sequence line";
seek(DATA, $dtapos,0);
ok open( my $dup, "<&DATA"), "duplicate DATA, scalar handle, open passthru";
<$dup>;$slurp=<$dup>;
ok $slurp =~ /^ATGGACGACAAAG/, "dup ok, got sequence line";
seek(DATA, $dtapos,0);

$tmph->close;
undef $tmph;
unlink $tmpf or diag("tempfile unlink issue: $!");

__END__
>183.m01790 |||similar to unknown protein||chr_13|chr13|183
ATGGACGACAAAGAACTCGAAATACCGGTAGAACATTCCACGGCTTTCGGTCAGCTCGTG
ACGGGTCCCCCGGGAGCGGGTAAATCGACCTATTGTCATGGCTTACATCAGTTCCTTACA
GCCATCGGTAGACCAGTGCATATCATCAACCTCGATCCTGCAGTCCCAAACCCTCCGTAT
CCATGCTCTATAAACATCACGGAACTCATCACACTCGAAAGTGTTATGGAGGAATACAAT
CTAGGACCGAATGGGGCGATGCTTTATTGTATAGAATTCTTAGAGGCCAATTTTGACTGG
CTAGTGGAGAGGCTGGATGAGGTCTTGGCTGAAGAGGGGGGGAATGGATATGTGGTGTTT
GATACGCCGGGTCAAGCAGAGTTATGGACGAACCATGATAGTTTGAAGAACGTGGTCGAA
AAGTTGGTCAAGATGGACTATAGACTAGCGGCTGTGCATCTCAGCGACGCGCACTACATA
ACAGATGCCTCAAAATTCATCTCTGTAGTTTTGCTAGCTCTTCGGGCGATGCTGCAAATG
GAAATGCCGCATTTGAATGTGCTCAGCAAAATAGATTTGATATCAACTTATGGAGAGCTC
CCGTTCGACTTGAGCTATTACACAGAAGTCCAAGATCTGTCATACTTACTGGGCAGTCTG
GATTCAGACCCTCGAACAGCAAAGTACCACAAGTTAAATAAAGCGTTGGTAGAGCTTATA
GAAGGCTTTTCATTAGTCGGATTTCAAACCCTCGCTGTTGAGGACAAAGAATCAATGCTT
AATATCGTCCGTCTTGTCGATAAGATGACGGGCTACATATTTATTCCGTCTGGCGACCTC
GAAGGAACCAACGCCATCAATACCCAAGCTCTGTTTGGTAGTGCCATGTCGTCGGCGAAG
CTTACAGGAAGAGCAGGCGGGGACGTAAGAGATGTTCAGGAGAGATGGATGGATAACAAG
GAGGCTTGGGATGAATGGGAGAAGAAAGAATGGAAGAGAGAAGCAGAGATAAGAGCCCAG
ATGGGCACTGGAATACCAGAAGGGATGAAAGGCGGTGAAGATGCGGAAAGTACAGGTATA
>AAL117C location=AgChr1:complement(140329..141372)
ATGGCGTATGGACAGATTGTGATAGGTCCACCGGGGTCTGGGAAGTCGACATACTGTAAT
GGGTGCAGCCAGTTCTTTAATGCCATCGGCAGACACGCTCGGATCGTGAACATGGACCCT
GCAAACGACTCGCTGCCCTACCAATGCGATGTAGACATTCGAGACTTTATTACTCTGGAG
GAAATCATGAACGAGCAGCACCTGGGGCCCAACGGAGGGCTGGTGTATGCGTTTGAGTCG
GTGGAGCACTCACTGTCGCTGTTTGCGCTGCAGATCAAGACGCTGGTCAAGGATGAGAAC
GCATATCTCGTCTTTGACTGCCCCGGTCAGGTGGAGCTGTTCACGCATCACTCGGCGCTC
TCCAAGATATTCCAGCAGCTGGTGCGCGACTTGGACCTACGAGTGTGCGTGGTGAACTTG
ATGGACAGCATCTACATTACATCGCCGTCGCAGTATGTCTCGGTACTGCTGCTGGCGCTG
CGCTCAATGTTGATGATGGACCTGCCCCATATTAACGTTCTCTCTAAGATCGATATGCTG
AGCTCGTACGGCGACCTGCCGTTCCGGCTCGACTACTATACCGAGGTGCAAGACTTGGAG
TATCTGCAACCGCATATTGAACGCGAACACAAGGGAGCCAAGGCGTTGAGGTACCGCCGA
CTAACGGAGGCCATAGGAGAGGTGGTTTCGGACTTCAACCTGGTCGCCTTCGAGGTGCTT
TGCGTCGATGACAAACAGAGCATGATCAACTTGCAAAGCGCAATCGACAAGGCCAATGGT
TATATTTTTGGTGCCTCCGAAGTTGGTGGCGATACTGTGTGGGCGGAGGCAACCCGCCAG
GGCACTGCTGCAATTGAATATGACATTCAGGACAGATGGATCGACAACAAGGACTTTTAT
GACAAGGAGGAAGAGGCTAGGCGCAAGAAGTTACTTGAGGAGCATGAGCTTCTGGAGAAA
GAAGTTGATGTCAACCAGGATGATGAATGGGAACGCGCAGTGAAGGAATGGGAGTCCCAG
CACTCTGTGAACTTCGTTAAA
>AN2438.1 hypothetical protein (53856 - 52862)
ATGAGTGAGGATCAATTGGGTCCGAACGGCGGTGTTTTGTATGCGTTGGAAGAGCTAGAG
GAGAACTTTGACTTCTTGGAGGAAGGGTTGAAAGAGCTCGGAGAGGACTATATTATCTTC
GATTGTCCCGGCCAGGTAGAAATTTTCACTCACCATTCGTCCTTACGGAATATCTTCTTC
AAGATCCAGAAGATGGGCTATAGACTAATAGTACTACACCTAATCGACTCCTACAACCTC
ACCCTGCCATCGATGTACATCTCCTCTCTTATTCTATGCTTGCGTGCCATGCTCCAAATG
GACCTTCCACATCTCAACGTCCTAACAAAAATCGATAATTTGTCCAATTATACTTCGCTG
CCTTTCAACCTAGATTTCTACACCGAGGTTCAGGACCTTACATACCTCCTCCCCCACTTA
GAGGCAGAGTCCTCCCGGCTATCGCACGAGAAGTTCGGAGCACTGAACAACGCCATCATC
ACACTGATTGAGGAGTTTGGACTCGTGGGCTTCGAAACACTGGCTGTAGAAGATAAAAAG
AGCATGATGAATTTGCTCCGGGCCATTGACCGCGCAAGTGGATACGTGTTTGGGCCTGCA
GAAGGCGCAAATGACTCCGTTTGGCAAGTGGCTGTTCGGGAAGGAATGGGGTCCATGGAT
ATCCGTGATATTCAAGAGCGTTGGATAGATGCCAAAGACGAGTACGATGAGTTGGAACGA
CGGCAGCGAGAGGAGGAGATAAAAAATCACCAGCAAGCTGCAACCTACCAGGCAGGGAAC
GAGGACGACGACGATGATAACGATTACGAATTCGGGCGCAGGATGCCTGTACCAGACAGT
GGAGTGAAAGTGATGCGGAAG
>FG05298.1 hypothetical protein (258181 - 259340)
ATGCCTTTCGCGCAACTCGTTCTCGGTAGTCCGGGCTGCGGAAAGAGTACATACTGTGAT
GGCATACAGCTGACCGGTCAAGTGCATCAGTTCCTAGGCGCCATCGGGCGAGCCTGTTCA
GTCGTCAATCTCGATCCTGCCAACGATCATACCAACTACCCTGCAGCTCTCGACATTCGC
AGTTTGATTAAGCTCGAGGAGATTATGAAAGATGATAAATTAGGACCTAATGGCGGCATC
CTGTATGCCCTCGAAGAGTTGGAACACAATTTCGAGTGGTTGGAAGAAGGACTGAAAGAA
TTCAGCGAAGACTATATTCTTTTCGACTGTCCGGGACAAGTGGAACTATATACACACCAC
AACTCCTTGCGAAACATATTCTACAAGCTCCAGAAGATTGGATTCAGGCTTGTTTCCGTC
CACCTCTCCGACTCCTTCTGCCTCACGCAACCGTCGTTATACGTATCGAACGTCCTCCTC
TCCCTTCGTGCGATGATCCAGATGGATATGCCACACATAAATATTCTCTCCAAGATCGAC
AAAGTTGCCGACTACGACGAACTCCCTTTCAACCTCGATTACTACACAGACGTGGACGAC
CTTACATATTTGACACCCCATCTTGAGACAGAGTCGCCCGCTCTGAGGAGTGAGAAATTC
GGCAAGCTCAACGAGGCGATTGCGAATCTGATCGAGAGCTACGGTCTGGTGCGCTATGAA
GTCCTGGCTGTCGAGAACAAGAAAAGCATGATGCATATCCTCCGTGTCATTGACCGTGCT
GGTGGATACGTCTTTGGTAGTGCTGAAGGAGCCAATGATACAGTCTGGTCAGTTGCCATG
AGGAACGAGTCGTCCATGTTGGGGGTGCAGGACATCCAAGAGCGTTGGATCGACCAAAAG
GTGGAATATGATCAAATGGAGCGTGAGGCCGAAGAAGAACAGGCGCGCATCCAAGAAGAA
CAAGCCATGGAGATGGAACAATCACAGCCACCTCCTGCGCCGACAGGTGGCATGGATCCT
GATTTTGGTGACATGACGGTGCCCAAAGATAGTGGGATCAAAGTAGTTAGAAAG
>MG06110.4 hypothetical protein similar to (NCU09745.1) hypothetical protein (25629 - 24026)
ATGGGATTTCTAGGCGCAATAGGGAGAGCATGTTCCGTAGTAAACCTTGACCCGGCCAAT
GACCATACGAGCTATCCATGTGCCCTCGACATACGAAATCTTGTCACGCTGGAGGAAATC
ATGGGAGACGACAATTTGGGGCCAAACGGTGGCATCCTCTACGCTATTGAAGAGCTGGAG
CATAACTTTGAGTGGTTGGAAGATGGTCTGAAAGAGCTTGGGGACGACTACATACTATTC
GACTGCCCGGGCCAGGTCGAGCTGTACACACATCACAATTCATTGCGCAATATCTTCTTC
AAGTTACAAAAGCTCGGCTACAGACTTGTGGTTGTTCACCTCTCGGACAGCATTTGCCTC
ACTCAACCATCGTTGTACATCTCGAATCTCCTCCTCGCTTTGCGCGCCATGCTCCAGATG
GATCTTTCCCATGTCAATGTCCTCACCAAAATCGACAAGGTGTCTTCATATGACAGACTA
GCCTTCAACCTCGACTTTTATACCGAGGTCCACGATCTTTCGTACCTCCTCCCCGAGCTC
GAAGCCGAGAATCCGTCGCTACGCAGCGAAAAGTTCGCCAAGCTAAACCGAGCCGTCGCA
AACTTGATTGAAGACTTTGGGCTCGTCCGGTTCGAAGTCTTGGCTGTCGAGAATAAGAAA
AGTATGATGCATTTGCTCCGGGTCCTCGATCGTGCCAACGGGTACGTTTTTGGTGGGGCC
GAGGGAGCCAACGACACCGTTTGGCAAGTAGCCATGCGCAACGAGGGCTCCCTGATGGGG
GTCCAAGATATCCAGGAGCGCTGGATCGATAACAAAGAGGCTTATGACGAGATGGAGCAG
CGTGAATGGGAGGAACAGGTCAAGGCACAAGAAGCCATGGCCGAAGCCGATGCAGCAGCT
GCTGAAGAGGGCGACGATGACTTGATGGGAGGCCCAGGTGCTCGA
>NCU09745.1 (NCU09745.1) hypothetical protein (81475 - 83184)
ATGACCTCCCCACTGCCAGTGCAGCAGTTTATGGGCGCCATCGGGCGACAATGCTCGGTA
GTCAACCTCGACCCTGCGAACGACCACACCAACTACCCATGCGCGCTCGACATTCGCGAC
CTTGTCACTTTGGAGGAGATTATGGCAGACGACAAATTGGGTCCCAATGGCGGTATTCTG
TACGCACTTGAAGAGCTGGAAAATAACATGGAATGGCTCGAGAACGGCCTCAAGGAGCTT
GGAGAAGACTATGTGCTTTTTGACTGCCCTGGTCAAGTCGAGCTCTACACCCACCACAAC
TCGTTACGCAACATCTTTTACCGGTTACAGAAGCTGGGCTACAGGCTGGTAGTTGTCCAC
CTTTCCGACTGCTTCTGCCTCACACAACCATCGCTCTACATTTCCAACGTCCTCCTCTCT
TTGCGCGCCATGTTGCAAATGGACCTTCCCCACATCAACGTCCTGACCAAGATTGACAAG
ATCTCGTCCTACGATCCTCTTCCATTCAACCTCGACTATTACACCGAAGTACAAGACCTA
CGGTACCTCATGCCGTCCCTCGACGCGGAATCGCCTGCCCTGAAGAAAGGCAAGTTCACC
AAGCTTAACGAGGCCGTTGCGAACATGGTTGAGCAGTTCGGCCTTGTCAGCTTCGAGGTG
CTGGCAGTCGAGAACAAGAAGAGTATGATGCATCTGTTGCGCGTGATTGACCGTGCAAGT
GGGTACGTCTTTGGCGGCGCTGAGGGAACGAACGACACCGTCTGGCAGGTTGCCATGCGC
AACGAGTCATCATTGCCCGATGCTCTTGATATTCAAGAGAGGTGGATCGATAGCAAAGAA
GAGTATGACGAGATGGAGCGGAAGGAGGAGGAAGAACAAGAAAAACTGCGGGCGGAGCAG
GCACGGGCCGCTGAAGAAGCAGGTCTCGGTGACGGCTCGGTCCCTGGAGTGGCGCCACAG
TTCACCAGTGGCTCGGGAATCCGTGTGACGCTTAGCCTAGTGGCCGCTTTTACCAAATAT
AGCGATCTT
>SPAC144.07c SPAC144.07c conserved eukaryotic protein; ATP-binding protein; similar to S. cerevisiae YOR262W
ATGCCATTTTGTCAAGTGGTCGTTGGACCTCCGGGTTCTGGGAAATCAACTTACTGTTTC
GGAATGTACCAATTATTATCTGCCATAGGAAGGAGTAGTATTATCGTCAATCTTGACCCA
GCAAATGACTTTATCAAATACCCATGCGCAATTGATATTCGTAAAGTTCTCGATGTTGAG
ATGATCCAAAAAGACTATGATTTAGGACCAAATGGAGCACTTATTTATGCTATGGAAGCA
ATTGAATATCACGTTGAATGGTTGCTTAAGGAGCTAAAAAAGCATCGAGATTCATATGTG
ATATTTGATTGCCCTGGTCAAGTTGAGTTATTTACAAACCATAATTCCTTACAAAAAATA
ATCAAAACTTTGGAAAAGGAACTGGATTATAGACCTGTGTCCGTACAACTTGTAGATGCA
TATTGCTGCACGAATCCTTCTGCATATGTTAGTGCACTGCTTGTTTGCCTAAAGGGGATG
CTTCAGCTGGACATGCCACATGTAAATATTTTGTCGAAGGCTGATTTGCTTTGTACGTAT
GGAACTTTACCAATGAAACTAGATTTTTTTACCGAAGTACAAGACCTTTCATATTTGGCG
CCTTTGCTTGATAGAGATAAACGTCTTCAGCGCTATAGTGATTTAAACAAAGCTATTTGT
GAACTTGTTGAAGATTTTAATCTTGTTTCTTTTGAAGTTGTTGCAGTAGAAAATAAAGCC
AGTATGTTACGTGTTCTTCGAAAAATCGATCAAGCAGGTGGATATGCATATGGATCTACA
GAAATTGGTGGTGATGCCGTTTGGGTGAATGCCGTTCGTCAAGGTGGAGACCCTCTTCAA
GGTATTTCGCCTCAGGAAAGATGGATTGACAAGAAAGAGGAATATGACAAATATGAATGG
GAATTAGAGCAAAAATCGACCATGGACGAAGATGAAAATGAAGGG
>Sbay_Contig635.43 YOR262W, Contig c635 67551-68594
ATGCCTTTTGCTCAGATTGTTATTGGACCCCCGGGTTCAGGGAAGTCTACGTATTGTAAC
GGATGTTCACAATTTTTTAATGCTATTGGGAGACATTCTCAGGTGGTAAATATGGATCCC
GCCAATGATGCCTTACCTTATCCGTGTGCTGTGGATATCAGAGATTTTATAACTTTGGAA
GAGATCATGAAAGAGCAACACTTGGGCCCTAATGGTGGTTTGATGTATGCCGTTGAATCT
CTAGATAAGTCCATTGATTTATTTATACTACAGATCAAATCACTTGTAGAAGAAGAGAAG
GCATATGTTGTGTTTGACTGCCCGGGACAAGTTGAGCTGTTTACGCATCATTCTTCATTA
TTCAGCATTTTCAAGAAATTAGAAAAAGAACTAGATATGAGATTCTGTGTGGTGAATTTG
ATTGATTGTTTTTACATGACATCTCCTTCACAATATGTCTCGATTTTGCTCCTGGCATTA
AGGTCTATGCTGATGATGGACCTGCCCCATATCAACGTCTTTTCGAAGATAGATAAGTTG
AAATCATATGGAGAATTGCCATTTAGATTAGATTATTATACAGAAGTTCAAGATTTGGAT
TATTTGGAGCCGTATATTGAAAAAGAAGGTTCTGGTGCACTGGGAAAAAGATATAGCAAA
TTGACTGAAACGATTAGTGAGCTGGTTTCTGATTTTAACCTGGTTTCCTTTGAAGTTTTG
GCTGTGGATGACAAAGAAAGTATGATAAATCTCCAGGGTGTTATTGATAAAGCCAATGGT
TACATATTTGGTGCATCTGAAGTGGGCGGCGACACGGTATGGGCCGAGGCCTCGAGAGAA
GGTGCATTGCTAGCAAGCTATGATATTCAAGATAGGTGGATAGATAATAAAGAAAAATAT
GATAAAGAAGAACAAGAGAAACGGGCTGCAATGGTGAAAGAGCAGGAACTGCAAAATAAA
GAGGTTAATGTAGACGAAGAAGACGAGTGGGAAAATGCACTAAACGACTGGGAAGAAAAA
CAAGGCACAGATTTTGTCAGG
>Scas_Contig692.20 YOR262W, Contig c692 40768-41811
ATGCCATTTGCCCAAATTGTTATCGGACCCCCCGGTTCAGGAAAATCAACATACTGTAAC
GGGTGTTCTCAATTTTTCAACGCCATCGGCAGGCATGGCCAAATAGTGAACATGGATCCA
GCTAATGATGCTCTACCATATCCATGTGCAGTAGACATTCGAGATTTTGTGACTCTGGAG
GAGATTATGCAAGAGCAACAACTGGGCCCCAATGGAGGGTTGATGTATGCTGTGGAATCG
TTAGATGAATCCATCGATCTTTTCATACTACAAATAAAATCTCTAGTTCAAGAGGAGAAG
GCATATTTAGTCTTTGATTGTCCTGGACAAGTAGAGTTGTTTACTCATCATTCATCTCTG
TTCAAAATCTTCAAAAAATTGGAAAAGGAACTAGATATGCGATTTTGTGTGGTGAATTTG
ATTGATTCTTTCTATATTACCTCCCCATCACAGTATGTTTCCATTTTGCTGTTGGCTTTG
AGATCTATGTTAATGATGGACCTACCGCAAATCAATGTTTTCTCCAAGATTGATATGCTG
AAATCCTATGGAGAACTACCTTTTAGATTGGATTATTACACAGAAGTGCAAGATTTAGAT
TATTTACAGCCATTTATTGAGAAGGAGAGTTCCAGTGTTTTGGGTAGAAGATATAGCAAG
TTAACAGAAACGATTAGTGAATTGGTTTCCGATTTTAATTTGGTCTCATTTGAAGTCTTA
GCTGTAGATGATAAACAAAGCATGATTAATTTACAAAGTGTAGTAGACAAGGCTAATGGA
TATATATTTGGAGCATCTGAAGTAGGTGGTGATACTGTTTGGGCAGAAGCCACGCGAGAA
GGTGCAATGATGGTAAATTATGATATACAGGACAGATGGATAGATAACAAAGAAAAGTAC
GATGAAGAGGAGAGAAAAAGACAAGAGGAACAAGCCAAAGAGCAGAACATGCAAGAAAAG
GAGGTAGACGTGGATAATGAGGACGAATGGGAAAAGGCATTGAAGGATTGGGAAGAAAAA
CAAGGAACAGGCTATGTAAGG
>Sklu_Contig2277.4 YOR262W, Contig c2277 4093-5136
ATGCCCTTTGGTCAGATTGTTATCGGCCCTCCTGGTTCAGGAAAGTCTACCTATTGTAAT
GGTTGCTCCCAGTTTTTTAATGCTGTCGGTAGACATGCCCAAGTAATCAACATGGATCCA
GCAAATGATTCGTTACCTTACCCATGTGCCGTTGACATTCGAGATTTCATCACCTTAGAG
GAAATTATGACAGAACAGCAGCTGGGGCCTAATGGTGGATTGATGTACGCCCTAGAATCT
TTGGATAAATCAATCGACTTATTTGTTTTGCAGATCAAATCACTAGTTCAGGATGAACAT
GCTTACGTAGTATTTGATTGTCCGGGGCAAGTGGAGCTTTTTACGCACCATTCGTCCTTG
TTCCGCATATTCAAGAAGTTGGAAAGAGAACTAGATATGAGGTTATGCGTGGTTAATTTA
ATCGATTGTTTTTACATCACCTCTCCTTCACAGTATGTCTCTATTCTTTTGCTAGCTTTG
AGGTCGATGCTGATGATGGACTTACCACACATTAATGTCTTTTCTAAAATTGATTTGTTG
AAATCCTACGGTGAGCTGCCATTCCGACTAGATTATTATACCGAAGTTCAAGAGCTAGAT
TACTTGAAGCCACATATTGACAAGGAAGGGAGCAGCGTCCTTGGAAGGAAATATAGTAGG
TTGACAGAAACCATTAGTGAACTGGTTTCTGACTTTAATCTGGTTTCCTTTGAAGTTTTG
TGTGTTGATGATAAGCAGAGCATGATCAATTTGCAAAGTATTGTGGATAAAGCAAATGGT
TACATATTTGGTGTTTCTGAGATCGGTGGAGATACGGTATGGGCAGAGGCAACGCGACAA
GGCAGTGCAATTGCTAATTACGACATTCAAGAGAGATGGATAGATAATAAAGATATGTAC
GACAGAGAGGAACAGGAAAAACGTGAACAGTTGCTCAAAGAAGAAGAGCTACAGAATAAA
GAAGTAGACGTGGATAAAGGTGATGAGTGGGAAAATGCTTTAAAAGAATGGGAAGAAAAG
CAAGGCATGAGTTATGTAAAA
>Skud_Contig1703.7 YOR262W, Contig c1703 9292-10335 reverse complement
ATGCCATTTGCTCAAATTGTTATCGGCCCACCAGGCTCGGGAAAGTCAACGTATTGTAAC
GGGTGTTCGCAGTTCTTCAACGCCATTGGAAGACATTCTCAAGTGGTGAATATGGATCCC
GCTAATGATGCTTTGCCTTATCCGTGTGCTGTAGATATTAGAGATTTTATAACTTTGGAA
GAGGTTATGCAGGAGCAACAGTTGGGTCCTAATGGTGGTTTAATGTATGCCGTTGAATCC
CTAGATAACTCCATTGATCTATTCATATTACAGATCAAGTCACTTGTAGAAGAAGAAAAG
GCCTACCTTGTGTTTGACTGTCCTGGACAAGTTGAGCTATTCACGCACCATTCATCTTTA
TTTAGCATTTTCAAGAAAATGGAGAAAGAATTGGATATGAGATTCTGTGTCGTAAACTTG
ATTGATTGCTTTTATATGACATCTCCTTCTCAGTATGTTTCAATTTTGCTACTGGCATTA
AGGTCCATGCTAATGATGGATTTGCCTCACATAAACGTTTTTTCCAAAATAGATATGTTA
AAATCATATGGGGAATTACCCTTCAGATTGGATTATTATACAGAGGTCCAGGAGCTAGAT
CATTTGGAGCCATATATTGAAAAGGAAGGCTCTAGCGTTCTAGGAAAAAAATATAGTAAG
TTGACTGAAACGATCAAAGAATTAGTCTCCGATTTTAACTTAGTTTCTTTTGAGGTTCTG
TCCGTGGATGACAAAGAAAGTATGATAAATCTCCAGGGTGTTATTGATAAAGCGAATGGC
TACATATTCGGAGCATCCGAAGTTGGAGGTGATACAGTGTGGGCCGAAGCTTCGAGAGAA
GGTGCATTGTTAGAAAACTACGACATACAGGATAGGTGGATAGATAATAAAGAAACGTAT
GATAAAGAAGAACAAGAGAAGCGTGCATCGCTGTTAAAAGAACAAGAACTGCAGAATAAA
ACGGTTGATGTGAAAGAAGAAGATGAATGGGAAAATGCATTAAAGGAGTGGGAAGAAAAG
CAAGATACGGAGTTTGTCAGA
>Smik_Contig1103.1 YOR262W, Contig c1103 447-1490 reverse complement
ATGCCGTTTGCTCAGATTGTTATTGGCCCACCGGGTTCAGGCAAGTCCACTTATTGTAAC
GGCTGCTCACAGTTCTTCAATGCCATTGGGAGACATTCTCAGGTGGTGAACATGGATCCC
GCTAATGATGCTTTGCCTTATCCTTGTGCTGTGGATATCAGAGATTTTATAACGTTGGAA
GAGATTATGCAAGAGCAACAGTTAGGCCCCAATGGTGGTTTAATGTATGCAGTCGAATCC
TTGGATAAGTCTATTGATTTGTTTTTATTACAGATCAAATCGCTTGTAGAAGAAGAAAAA
GCCTATCTTGTATTCGACTGTCCAGGCCAGGTCGAGTTATTTACTCATCACTCATCCTTA
TTCAATATATTTAAGAAAATGGAGAAAGAATTGGACATGAGGTTCTGTGTAATAAACTTG
ATTGACTGTTTTTACATGACGTCACCCTCACAATATGTCTCAATTTTACTGCTTGCACTA
AGATCCATGTTGATGATGGATCTGCCCCACATAAATGTTTTTTCTAAGATAGATATGTTG
AAATCATATGGAGAACTACCATTTAGACTAGATTATTATACAGAGGTACAGGATCTAGAT
TATTTGGAACCGTATATTGAAAAAGAAGGCTCTAGTGTATTAGGAAAGAAATACAATAAG
TTGACCGACGCAATCAAAGAGCTTGTTTCTGATTTTAACTTGGTTTCCTTTGAGGTTTTG
TCCGTGGATGACAAAGAAAGTATGATAAATCTCCAGGGTGTGATTGATAAAGCAAATGGC
TACATATTTGGTGCGTCTGAGGTTGGTGGTGATACAGTGTGGGCAGAGGCTTCTAGGGAA
GGTGCTCTTTTAACAAGTTACGATATTCAAGATAGGTGGATAGATAATAAGGAAAAGTAT
GACAAAGAAGAAGAAGAGAAACGTGTAATCTTGTTAAAAGAGCAAGAGCTGCAAAATAAA
GCAGTTGACGTGAATGAAGACGATGAGTGGGAAAGTGCGCTCAAGGAATGGGAAGAAAAA
CAAGGTATGGATTTTGTTAGA
>Spar_21273 YOR262W, Contig c261 8817-9860
ATGCCCTTTGCTCAAATTGTTATTGGCCCACCGGGTTCAGGAAAATCAACCTATTGCAAC
GGCTGTTCACAGTTTTTCAATGCCATTGGAAGACATTCTCAGGTAGTAAATATGGACCCT
GCTAATGATGCGTTACCTTACCCATGTGCTGTGGATATTCGAGATTTTATAACTTTGGAG
GAGATTATGCAAGAGCAACAGTTAGGCCCCAATGGTGGTTTGGTGTATGCTGTTGAATCC
TTGGATAAGTCCATTGACTTGTTCATATTACAAATCAAGTCGCTTGTAGAAGAAGAAAAG
GCATATCTCGTATTTGACTGTCCCGGACAAGTGGAGTTATTTACTCATCACTCATCTTTA
TTCAGCATTTTTAAGAAAATGGAAAAAGAATTGGACATGAGATTCTGTGTAGTAAATTTG
ATAGACTGTTTTTACATGACTTCTCCTTCACAATACATCTCCATTTTGCTACTCGCATTA
AGGTCTATGTTAATGATGGATCTACCCCACATTAACGTTTTTTCTAAGATAGATATGTTG
AAATCCTACGGGGAATTACCCTTTAGATTAGATTATTATACAGAGGTTCAGGATCTAGAT
TATTTGGAGCCATATATCGAAAAGGAAGGCTCTAGTGTACTGGGAAAGAAATATAGCAAG
TTAACTGAGACAATCAAAGAGCTTGTTTCAGATTTCAATCTGGTTTCATTTGAGGTCCTG
TCTGTGGATGATAAAGAAAGTATGATAAATCTTCAAGGTGTTATAGATAAAGCAAATGGC
TACATATTCGGCGCATCTGAAGTTGGCGGTGATACAGTTTGGGCTGAGGCCTCTAGAGAA
GGTGCATTACTAGCAAATTACGACATTCAGGACAGATGGATAGACAATAAAGAGAAGTAC
GATAAAGAGGAAGAAGAGAAACGCGCGGCGTTGCTAAAAGAACAAGAGTTGCAAAATAAA
GCCGTTGATGTGAATGAAGAGGATGAGTGGGAAAATGCGCTGAAGGAATGGGAAGAAAAA
CAGGGTACGGATTTCGTTAGA
>YOR262W YOR262W SGDID:S0005788, Chr XV from 817289-818332
ATGCCCTTCGCTCAGATTGTTATTGGTCCACCAGGTTCAGGGAAGTCAACCTATTGCAAC
GGCTGCTCACAGTTCTTCAATGCCATCGGAAGACATTCCCAGGTAGTGAATATGGATCCT
GCTAATGATGCCTTACCTTACCCATGCGCTGTGGATATTCGTGATTTTATAACATTAGAG
GAGATCATGCAAGAGCAACAGTTAGGCCCTAATGGAGGTTTGATGTATGCTGTTGAATCA
TTGGATAATTCTATTGATTTGTTCATTTTACAGATCAAGTCACTTGTAGAAGAAGAAAAA
GCATATCTTGTATTCGACTGTCCGGGCCAAGTGGAGCTATTTACTCATCACTCATCTTTG
TTCAACATCTTTAAAAAAATGGAAAAGGAATTGGACATTAGGTTTTGTGTTGTAAATTTG
ATTGACTGTTTTTACATGACATCCCCTTCACAATATATCTCGATTTTGTTACTTGCATTG
AGGTCTATGTTAATGATGGATCTCCCTCACATCAACGTTTTTTCTAAAATAGATATGCTG
AAATCATACGGAGAATTACCCTTTAGATTAGACTATTATACAGAGGTCCAGGATCTGGAT
TATTTGGAGCCATATATTGAAAAGGAAGGCTCTAGTGTACTGGGAAAGAAATATAGCAAG
TTAACTGAAACAATCAAAGAGCTAGTCTCAGATTTCAACTTAGTATCATTTGAGGTTTTG
TCCGTGGATGACAAAGAAAGTATGATAAATCTTCAAGGTGTTATAGATAAAGCAAATGGC
TACATATTCGGCGCATCCGAAGTTGGTGGTGATACCGTGTGGGCTGAGGCTTCGCGAGAA
GGTGCATTAATAGCGAATTACGACATTCAAGACAGGTGGATAGACAATAAAGAGAAGTAT
GATAAAGAAGAAGAAGAAAAACGTACGGCGTTGTTAAAAGAACAAGAATTGCAAAATAAA
GCTGTTGATGTGAATGAAGAAGATGAGTGGGAAAATGCGCTGAAGGAGTGGGAAGAGAAA
CAAGGAATGGATTTTGTTAGG

