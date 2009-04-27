package MooseX::Lexical::Types::TypedScalar;

use strict;
use warnings;
use Carp qw/confess/;
use Variable::Magic qw/wizard cast/;
use namespace::autoclean;

my $wiz = wizard
    data => sub { $_[1]->get_type_constraint },
    set  => sub {
        if (defined (my $msg = $_[1]->validate(${ $_[0] }))) {
            confess $msg;
        }
        ();
    };

sub TYPEDSCALAR {
    cast $_[1], $wiz, $_[0];
    ();
}

1;
