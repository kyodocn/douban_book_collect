package BookTag;

use strict; 
our $AUTOLOAD;
my %fields=(
	id=>"",
	bookid=>"",
	tagid=>"",
	count=>"",
);

#sub id{};
#sub bookid{};
#sub tagid{};
#sub count{};

sub new{
	my $class=shift;
	my $self={
		_permitted=>\%fields,
		%fields};
	bless $self,$class;
	return $self;
}

sub AUTOLOAD{
	my $self=shift;
	my $type=ref $self;
	my $name=$AUTOLOAD;
	return if $name=~/::DESTROY$/;
	$name=~s/.*://;
#	print $name,"\n";
	return unless exists $self->{_permitted}->{$name};
	$self->{$name}=shift if @_;
	return $self->{$name};
}
#foreach my $field (keys %fields){
#	*$field=sub{
#		my $self=shift;
#		$self->{$field}=shift if @_;
#		return $self->{$field};
#	}
#}

1;