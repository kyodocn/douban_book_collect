package db_base;

use DBI;

sub new{
	my $class=shift;
	my $self={};
	
	#$self->{'dbh'}=DBI->connect("dbi:mysql:host=localhost;port=3306;database=book","root","mysql");
	#print "connect success\n";
	bless $self,$class;
	return $self;
}

sub get_dbh{
	my $self=shift;
	$self->{'dbh'}=DBI->connect("dbi:mysql:host=localhost;port=3306;database=book","root","mysql");
	print "connect success\n";
	return $self->{'dbh'};
	
	
}


1; 