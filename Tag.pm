package Tag;
use strict;
our $AUTOLOAD;
my %fields=(
  id=>"",
  name=>"",
  count=>"",
  url=>"",
);

sub id;
sub name;
sub count;
sub url;
sub new{
	my $class=shift;
	my $self={
		_permitted=>\%fields,
		%fields};
	bless $self,$class;
	return $self;
	}
	
#foreach my $field(keys %fields){
#	*$field=sub {
#		my $self=shift;
#		$self->{$field}=shift if @_;
#		return $self->{$field};
#	}
#}
sub AUTOLOAD{
	my $self=shift;
	my $type=ref $self;
	my $name=$AUTOLOAD;
	return if $name=~/::DESTROY$/;
	$name=~s/.*://;
	return unless exists $self->{_permitted}->{$name};
	$self->{$name}=shift if @_;
	return $self->{$name};
}

1;