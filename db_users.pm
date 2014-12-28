package db_users;
use strict;
use db_base;
use User;  

sub new{
	my $class=shift;
	my $self->{'dbh'}=db_base->new()->get_dbh();
	bless $self,$class;
	return $self;
}

sub save_user{
	my $self=shift;
	my User $user=shift;
	my $flag=$self->is_user_exists($user->name());
	return $flag if $flag;
	my $sql="insert into users (name,url,address) values(?,?,?)";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($user->name(),$user->url(),$user->address());
	my $id=$self->{'dbh'}->last_insert_id(undef,undef,"`users`","id");
	return $id;
	
}

sub is_user_exists{
	my $self=shift;
	my $name=shift;
	my $flag=$self->get_id_from_name($name);
	return $flag;
}

sub get_id_from_name{
	my $self=shift;
	my $userName=shift if @_;
	my $sql="select id from users where name like ?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($userName);
	my $userid=$self->{'sth'}->fetchrow_array();
	return $userid;
}

sub get_users{
	my $self=shift;
	my ($start,$offset)=@_;
	my $sql="select id,url from users limit ?,?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($start,$offset);
	my $users_ref=$self->{'sth'}->fetchall_arrayref();
#	my @users;
#	foreach my  $u(@$users_ref){
#		my User $user=User->new();
#		$user->id($u->[0]);
#		$user->name($u->[1]);
#		$user->url($u->[2]);
#		push @users,$user;
#	}
	return $users_ref;
}

sub save_user_book{
	my $self=shift;
	my ($userid,$bookid,$date)=@_;
	my $flag=$self->is_user_book_exists($userid,$bookid,$date);
	return $flag if $flag;
	
	my $sql="insert into book_user(userid,bookid,`date`) values(?,?,?)";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($userid,$bookid,$date);
	my $id=$self->{'dbh'}->last_insert_id(undef,undef,"`user_book`","id");
	return $id;
}

sub is_user_book_exists{
	my $self=shift;
	my ($userid,$bookid)=@_;
	my $sql="select id from book_user where userid =? and bookid=?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($userid,$bookid);
	my $id=$self->{'sth'}->fetchrow_array();
	return $id;
}

sub save_user_tag{
	my $self=shift;
	my ($userid,$bookid,$count,$url)=@_;
	my $flag=$self->is_user_tag_exists($userid,$bookid);
	return $flag if $flag;
	
	my $sql="insert into user_tag(userid,tagid,count,url) values(?,?,?,?)";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($userid,$bookid,$count,$url);
	my $id=$self->{'dbh'}->last_insert_id(undef,undef,"`user_tag`","id");
	return $id;
}

sub is_user_tag_exists{
	my $self=shift;
	my ($userid,$tagid)=@_;
	my $sql="select id from user_tag where userid=? and tagid=?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($userid,$tagid);
	my $id=$self->{'sth'}->fetchrow_array();
	return $id;
	
}
sub save_user_tag_book{
	my $self=shift;
	my ($userid,$tagid,$bookid,$date)=@_;
	my $flag=$self->is_user_tag_book_exists($userid,$tagid,$bookid);
	return $flag if $flag;
	
	my $sql="insert into user_tag_book(userid,tagid,bookid,date) values(?,?,?,?)";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($userid,$tagid,$bookid,$date);
	my $id=$self->{'dbh'}->last_insert_id(undef,undef,"`user_tag_book`","id");
	return $id;
}
sub is_user_tag_book_exists{
	my $self=shift;
	my ($userid,$tagid,$bookid)=@_;
	my $sql="select id from user_tag_book where userid=? and tagid=? and bookid=?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($userid,$tagid,$bookid);
	my $id=$self->{'sth'}->fetchrow_array();
	return $id;
}

sub get_user_tags{
	my $self=shift;
	my ($start,$offset)=@_;
	my $sql="select userid,tagid,url from user_tag limit ?,?";
	$self->{'sth'}=$self->{'dbh'}->prepare($sql);
	$self->{'sth'}->execute($start,$offset);
	return $self->{'sth'}->fetchall_arrayref();
}

1;
