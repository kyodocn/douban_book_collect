package db_books;

use db_base;
use Book;
use BookTag;  
 
sub new{
	my $class=shift;
	
	my $self->{'dbh'}=db_base->new()->get_dbh();
	
	bless $self,$class;
	return $self;
}

sub get_books{
	my $self=shift;
	my ($start,$offset)=@_;
	my $sql="select id,url from books limit ?,?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($start,$offset);
	my $result_ref=$self->{'sth'}->fetchall_arrayref();
#	my @url;
#	foreach (@$result_ref){
#		push @url,$_->[0];
#	}
	return $result_ref;
	
}

#bookname
sub get_bookid_from_name{
	my $self=shift;
	my $bookName=shift;
	
	my $sql="select id from books where name like ?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($bookName);
	my $bookid=$self->{'sth'}->fetchrow_array();
	return $bookid;
}

sub is_book_exists{
	my $self=shift;
	my $bookName=shift;
	
	my $flag=$self->get_bookid_from_name($bookName);
	if($flag){
		return $flag;
	}else{
		return 0;
	}
}

sub saveBook{
	my $self=shift;
	my Book $book=shift;
	
	print "save book!\n";
	
	my $flag=$self->is_book_exists($book->name());
	return $flag if $flag;
	my $sql="insert into books(name,url,author,pages,date,price,score,critical,isbn,brief) values(?,?,?,?,?,?,?,?,?,?)";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	
#		print $sql,"\n";
		$self->{'sth'}->execute($book->name(),$book->url(),$book->author(),$book->pages(),$book->date(),$book->price(),
		$book->score(),$book->critical(),$book->isbn(),$book->brief());
	
	 
	return $self->{'dbh'}->last_insert_id(undef,undef,"books","id");
}

sub save_book_tag{
	my $self=shift;
	my BookTag $bookTag=shift;
	my $flag=$self->is_book_tag_exists($bookTag->bookid(),$bookTag->tagid());
	my $sql;
	if ($flag){
		$sql="update book_tag set count=count+? where id=$flag";
		$self->{'sth'}=$self->{'dbh'}->prepare($sql);
		$self->{'sth'}->execute($bookTag->count());
		return $flag;
	}else{
	$sql="insert into book_tag(bookid,tagid,count) values(?,?,?)";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($bookTag->bookid(),$bookTag->tagid(),$bookTag->count());
	my $id=$self->{'dbh'}->last_insert_id(undef,undef,"`book_tag`","id");
	return $id;
	}
}
sub is_book_tag_exists{
	my $self=shift;
	my ($bookid,$tagid)=@_;
	my $sql="select id from book_tag where bookid=? and tagid=?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($bookid,$tagid);
	my $id=$self->{'sth'}->fetchrow_array();
	return $id;
}

1;