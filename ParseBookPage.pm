package ParseBookPage;


@EXPORT=qw/parse_source_page/;

use strict;
use Book;
use BookTag;
use db_books;
use LWP::Simple;
use db_tags;
use db_books;


my ($start_tag,$offset,$tags,$baseUrl,$nextUrl,$tagid,$bookid,$sleeptime);
my $tagdb=db_tags->new();
my $bookdb=db_books->new();
#my $tagdb=db_tags->new();
my ($pageCount,$bookCount,$allBook);
my ($bookName,$bookScore,$bookCritical);
my ($author,$date,$pages,$price,$isbn);

#配置文件功能
sub config{
	$start_tag=5000;
	$offset=500;
	$allBook=0;
	$sleeptime=11;
}

#还原之前的配置
sub clean{
	
}

#得到进行处理的标签集合
sub get_tags{
	$tags=$tagdb->get_tags($start_tag,$offset);
	foreach my $tag (@$tags){ 
#		print $tag->name()," ",$tag->url(),"\n";
		$pageCount=0;
		$baseUrl=$tag->url();
		$tagid=$tag->id();
		get_source_page_of_tag($tag->url());
		
	}
}

#根据tag的url递归查询标签的资源
sub get_source_page_of_tag{
	my $url=shift;
	$bookCount=0;
	$pageCount++;
	my $doc=get($url);
	parse_source_page($doc);
}

#处理每一个tag的页面
sub parse_source_page{
	my $doc=shift;
	my $found=0;
	open SOURCE,"<",\$doc or die "couldn't open file $!";
	while (<SOURCE>){
		
		if(/ul first/){
			$found=1;
			while(<SOURCE>){
				last if /aside/;
				if(/<a class="nbg" href="(.*?)"/){
					my $bookUrl=$1;
					$bookCount++;
					parse_book_page($bookUrl);
				}
			}
		}
		
	}
	
	if($bookCount>=20&&$found){
#		print "found!\n";
		$nextUrl=$baseUrl."?start=".(20*$pageCount)."&type=T";
#		print $nextUrl,"\n";
		sleep  $sleeptime;
		get_source_page_of_tag($nextUrl);
		#http://book.douban.com/tag/%E6%96%87%E5%AD%A6?start=40&type=T
	}else{
		return;
	}
}

sub init_book{
	$author="";
	$date="";
	$price="";
	$pages="";
	$isbn="";
}
#处理书籍的页面，得到书籍的相关信息并存储
sub parse_book_page{
	my $bookUrl=shift;
	init_book();
	print $bookUrl,"\n";
	my $bookDoc=get($bookUrl);
#print $bookUrl,"\n";
	open BOOK,"<",\$bookDoc or die "couldn't open file $!";
	
	my $str;
	my $brief="";
	my $bookTags="";
	while(<BOOK>){
		if(/<title>(.*?)\(/){
			$bookName=$1;
			while(<BOOK>){
				if(/id="info"/){
					$str=$_;
					while(<BOOK>){
						$str.=$_;
						last if /interest_sectl/;
					}
				}
				if(/v:average">(.*?)<\/strong/){
					$bookScore=$1;
				}
				if(/v:votes">(.*?)<\//){
					$bookCritical=$1;
				}
				if(/related_info/){
					
					while(my $line=<BOOK>){
						$brief.=$line;
						
						if(/div/){
							$brief.=$line;
							last;
						}
					}
			}  
				if(/id="db-tags-section"/){
					
					while(my $line=<BOOK>){
						$bookTags.=$line;
						
						last if $line=~/id="db-rec-section"/;
					}
				}
			   
		}
	}
#	my $bookBrief=$brief=~m/indent">(.*?)</;
	}
	$brief=~s/.*indent.*?>//;
	$brief=~s/<.*//g;
	$brief=~split "  ",$brief;
	$str=~s/<.*?>/  /g;
#	print "show the string of booktags: ",$bookTags;
	parse_bookTags($bookTags);
	
	parse_bookDetails($str);
	
#	print $author,"  ",$date,"  ",$price,"  ",$pages,"  ",$isbn,"\n";
	
#	print $bookName," ",$bookUrl," ",$bookScore," ",$bookCritical," \n",$brief,"\n";
	my Book $book=Book->new();
	$book->author($author);
	$book->date($date);
	$book->price($price);
	$book->pages($pages);
	$book->isbn($isbn);
	$book->name($bookName);
	$book->url($bookUrl);
	$book->score($bookScore);
	$book->critical($bookCritical);
	$book->brief($brief);
#	print $bookName,"\n";
#	print $book->name()," " ,$bookUrl,"\n";
	
	$bookid=$bookdb->saveBook($book);

#	print $bookid,"\n";
#	my BookTag $booktag=BookTag->new();
#	$booktag->bookid($bookid);
#	$booktag->tagid($tagid);
#	$booktag->count(1);
#	
#	$bookdb->save_book_tag($booktag);
	
	
}

sub parse_bookTags{
	
	my $str=shift;
	my @tags=split "&nbsp;",$str;
	my $tag_base_url="http://book.douban.com/tag/";
	foreach(@tags){
	if(/<a .*?>(.*?)<\/a>\((.*?)\)/){
		print $1,"  ",$2,"\n";
		my Tag $tag=Tag->new();
		my $name=$1;
		my $count=$2;
		$tag->name($name);
		$tag->url($tag_base_url.$name);
		$tag->count($count);
		my $tid=$tagdb->save_tag($tag);
		my BookTag $bookTag=BookTag->new();
		$bookTag->bookid($bookid);
		$bookTag->tagid($tid);
		$bookTag->count($count);
		$bookdb->save_book_tag($bookTag);
	}
	}
	
}

sub parse_bookDetails{
	my $bookStr=shift;
	my @details=split "    ",$bookStr;
	foreach my $ele(@details){
		if($ele =~ /作者\s*:(.*)/){
			$author.=$1;
		}elsif($ele=~/译者\s*:(.*)/){
			my $tmp=$1;
			if($tmp=~/\//){
				my @translaters=split "\/",$tmp;
				foreach my $translater(@translaters){
					$translater=~s/ //g;
					$author.="--".$translater;
				}
			}else{
				$tmp=~s/ //g;
				$author.="--".$tmp;
			}
		}elsif($ele=~/出版年\s*:(.*)/){
			$date=$1;
		}elsif($ele=~/页数\s*:(.*)/){
			$pages=$1;
		}elsif($ele=~/定价\s*:(.*)/){
			$price=$1;
		}elsif($ele=~/ISBN\s*:(.*)/){
			$isbn=$1;
		}else{
			
		}
	}
}

1;