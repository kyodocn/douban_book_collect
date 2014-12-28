package MyParser;
use ParseBookPage;
use base qw/HTML::Parser/;

our($text_elements,$start_tags,$end_tags)=(0,0,0);
our($count)=(0);
sub text{
	$text_elements++;
}

sub init{
	my $self=shift;
	$count=0;
}

sub start{
	my ($self,$tagname,$attr,$attrseq,$origtext)=@_;
	return if $count++>0;
	if($tagname eq 'a' && $attr->{class} eq 'nbg' && $attr->{href}=~m|/subject/*|)
	{
#		print "BookDetailUrl: ",$attr->{href},"\n";
		my $bookParser=ParseBookPage->new();
		$bookParser->parse_book_detail($attr->{href});
	}
}

sub end{
	$end_tags++;
}

1;