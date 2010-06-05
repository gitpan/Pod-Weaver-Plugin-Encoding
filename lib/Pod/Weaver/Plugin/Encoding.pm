package Pod::Weaver::Plugin::Encoding;
BEGIN {
  $Pod::Weaver::Plugin::Encoding::AUTHORITY = 'cpan:FLORA';
}
BEGIN {
  $Pod::Weaver::Plugin::Encoding::VERSION = '0.01';
}
# ABSTRACT: Add an encoding command to your POD

use Moose;
use Moose::Autobox;
use List::AllUtils 'any';
use MooseX::Types::Moose qw(Str);
use aliased 'Pod::Elemental::Node';
use aliased 'Pod::Elemental::Element::Pod5::Command';
use namespace::autoclean -also => 'find_encoding_command';

with 'Pod::Weaver::Role::Finalizer';


has encoding => (
    is      => 'ro',
    isa     => Str,
    default => 'utf-8',
);


sub finalize_document {
    my ($self, $document) = @_;

    return if find_encoding_command($document->children);

    $document->children->unshift(
        Command->new({
            command => 'encoding',
            content => $self->encoding,
        }),
    );
}

sub find_encoding_command {
    my ($children) = @_;
    return $children->grep(sub {
        return 1 if $_->isa(Command) && $_->command eq 'encoding';
        return 0 unless $_->does(Node);
        return any { find_encoding_command($_->children) };
    })->length;
}


__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=head1 NAME

Pod::Weaver::Plugin::Encoding - Add an encoding command to your POD

=head1 SYNOPSIS

In your weaver.ini:

  [-Encoding]

or

  [-Encoding]
  encoding = kio8-r

=head1 DESCRIPTION

This section will add an C<=encoding> command like

  =encoding utf-8

to your POD.

=head1 ATTRIBUTES

=head2 encoding

The encoding to declare in the C<=encoding> command. Defaults to
C<utf-8>.

=head1 METHODS

=head2 finalize_document

This method prepends an C<=encoding> command with the content of the
C<encoding> attribute's value to the document's children.

Does nothing if the document already has an C<=encoding> command.

=head1 SEE ALSO

L<Pod::Weaver::Plugin::Encoding> is very similar to this module, but
expects the encoding to be specified in a special comment within the
document that's being woven.

=head1 AUTHOR

Florian Ragwitz <rafl@debian.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Florian Ragwitz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

