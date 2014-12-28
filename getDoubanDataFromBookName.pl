#!/perl -w
use strict;
use LWP::Simple;
use MyParser;

main();
sub main{
my $bookList="book_title2.txt";

open BOOKS,"<","$bookList" or die "couldn't open file $bookList:$!\n";
  no strict "subs";
  iterateBooks(BOOKS);
 
 
}

sub iterateBooks{
	my $FH=shift;
	
	my $count=0;
	
	while(<$FH>){
		my $url=createQuery($_);
		 queryResultProcess($url);
		#testone
		print $url,"\n";
		
		last if $count++==2; 
		
	}
}

sub createQuery{
	my $bookName=shift;
	
	my $queryUrl="http://book.douban.com/subject_search?search_text=$bookName&cat=1003";
#	http://book.douban.com/subject_search?search_text=6%E5%8F%B7%E7%89%B9%E5%B7%A5&cat=1003
   
    return $queryUrl;
	
}

sub queryResultProcess{
	my $url=shift;
	
	my $source=get($url);
        
	open SOURCE ,"<",\$source;
#       while(<SOURCE>){
#          print $_,"\n";
#       }
	

   my $parser=MyParser->new();
   no strict "subs";
   $parser->parse_file(\*SOURCE);
   
print <<END;
   
text elements:$MyParser::text_elements
start_tags   :$MyParser::start_tags
end_tags     :$MyParser::end_tags
END

	

   
   
   
	
}


