package db_tags;
use db_base;
use Tag;
  
sub new{
	
	my $class=shift;
	my $self={};
	$self->{'dbh'}=db_base->new()->get_dbh();
	bless $self,$class;
	return $self
}

sub get_tags{
	my $self=shift;
	my ($start,$offset)=@_;
	my $sql="select * from tags limit $start,$offset";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute();
	my $result_ref=$self->{'sth'}->fetchall_arrayref();
	my @tags;
	foreach my $u(@$result_ref){
		my Tag $tag=Tag->new();
		$tag->id($u->[0]);
		$tag->name($u->[1]);
		$tag->url($u->[2]);
		$tag->count($u->[3]);
		push @tags,$tag;
	}
	
	return \@tags;
	
}

sub get_tagid_from_name{
	my $self=shift;
	my $tagName=shift;
	my $sql="select id from tags where name like ?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($tagName);
	my $tagid=$self->{'sth'}->fetchrow_array();
	return $tagid;
}
sub is_tag_exists{
	my $self=shift;
	my $tagName=shift;
	my $flag=$self->get_tagid_from_name($tagName);
	return $flag;
}

sub save_tag{
	my $self=shift;
#	my  ($name,$url,$count)=@_;
	my Tag $tag=shift;
#	my ($tagName,$tagUrl,$tagTimes)=@_;
	my $flag=$self->is_tag_exists($tag->name());
	return $flag  if $flag;
	my $sql="insert into tags(name,url,count) values (?,?,?)";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($tag->name(),$tag->url(),$tag->count());
#	$self->{'sth'}->execute($name,$url,$count);
	my $id=$self->{'dbh'}->last_insert_id(undef,undef,"`tags`","id");
	return $id;
}
1;