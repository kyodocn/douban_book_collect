#!/perl -w
use strict;
use db_tags; 
#这个文件用来清洗图书馆馆藏书目名称，将书名与数据库中的标签名相同的书名过滤掉
main();
sub main{
	my $tagdb=db_tags->new();
	
	my $bookList="book_title2.txt";
	open BOOKS,"<",$bookList or die "couldn't open file $bookList\n";
	my $cleanedBookList="cleanBooks.txt";
	open CLEAN ,">",$cleanedBookList or die "couldn't open file $cleanedBookList\n";
	
	my $tags=$tagdb->get_tags(0,10);
	
	for my $tag (@$tags){
		print $tag->name(),"\n";
	}
	
	while(<BOOKS>){
		my $book=$_;
		
		my $tagid=$tagdb->get_tagid_from_name($book);
		if($tagid){
			print CLEAN $book,"\n";
		}
	}
}