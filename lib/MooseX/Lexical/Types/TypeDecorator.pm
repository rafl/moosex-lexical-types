package MooseX::Lexical::Types::TypeDecorator;

use Moose;
use MooseX::Types::Moose qw/Str/;
use namespace::autoclean;

use overload '""' => \&type_package;

extends 'MooseX::Types::TypeDecorator';

has type_namespace => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => sub { 'MooseX::Lexical::Types::TYPE::' },
);

sub type_package {
    my ($self) = @_;
    if (blessed $self) {
        return $self->type_namespace . $self->__type_constraint->name;
    }
    else {
        return "$self";
    }
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
