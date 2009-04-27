use strict;
use warnings;

package MooseX::Lexical::Types;

use Class::MOP;
use Carp qw/confess/;
use Lexical::Types ();
use MooseX::Types::Util qw/has_available_type_export/;
use MooseX::Lexical::Types::TypeDecorator;
use MooseX::Lexical::Types::TypedScalar;

use namespace::autoclean;

sub import {
    my ($class, @types) = @_;

    my $caller = caller();
    my $meta = Class::MOP::class_of($caller) || Class::MOP::Class->initialize($caller);

    for my $type_name (@types) {
        my $tc = has_available_type_export($caller, $type_name);
        confess "${type_name} is not an exported MooseX::Types constraint in ${caller}"
            unless $tc;

        # create a custom type decorator. it's similar to
        # MX::Types::TypeDecorator, but stringifies to the class implementing
        # TYPEDSCALAR for a given type instead of just the type name.
        my $decorator = MooseX::Lexical::Types::TypeDecorator->new($tc);

        $class->create_type_package($decorator->type_package, $tc);

        # the new decorator needs to be inlineable so perl will invoke it
        # during compile time for C<< my Int $foo >>. hence the empty
        # prototype. the blessing is to not break
        # MooseX::Lexical::Types::TypeDecorator::has_available_type_export. I'm
        # surprised it's still inlineable that way :-)
        my $export = bless sub () { $decorator } => 'MooseX::Types::EXPORTED_TYPE_CONSTRAINT';

        $meta->add_package_symbol('&'.$type_name => $export);
    }

    Lexical::Types->import;
}

sub create_type_package {
    my ($class, $package, $tc) = @_;
    Class::MOP::Class->create(
        $package => (
            superclasses => ['MooseX::Lexical::Types::TypedScalar'],
            methods      => {
                get_type_constraint => sub { $tc },
            },
        ),
    );
}

1;
