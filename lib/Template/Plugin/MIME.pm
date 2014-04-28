package Template::Plugin::MIME;

use warnings;
use strict;

use base qw( Template::Plugin );

use MIME::Entity;
use MIME::Base64;
use Sys::Hostname;
use File::LibMagic;
use Digest::SHA;

=head1 NAME

Template::Plugin::MIME - TemplateToolkit plugin providing a interface to MIME::Entity

=head1 VERSION

Version 0.1

=cut

our $VERSION = '0.1';

our $NAME = __PACKAGE__;

=head1 SYNOPSIS

Use this plugin inside a template:

    [% USE mail = MIME %]
    
    [% cid_of_image = mail.attach('image.png') %]
    
    <img src="cid:[% cid_of_image %]" />

=cut

sub load($$) {
    my ($class, $context) = @_;
    bless {
        _CONTEXT => $context,
    }, $class;
}

sub new($$@) {
    my ($self, $context, %params) = @_;
    $context->{$NAME} = {
        attachments => {},
        hostname => $params{hostname} || hostname
    };
    $self->{magic} = File::LibMagic->new;
    return $self;
}

sub _context($) { shift()->{_CONTEXT} }

sub base64($$) {
    return encode_base64($_[1]);
}

sub attachments($$) {
    my ($self, $template) = @_;
    my $context = $template->context;
    return $context->{$NAME}->{attachments};
}

sub merge {
    my ($self, $template, $part) = @_;
    my $context = $template->context;
    my $attachments = $self->attachments($template);
    
    my $multipart = MIME::Entity->build(
        Top => 0,
        Type => 'multipart/related'
    ) or confess $@;
    
    $multipart->add_part($mail);
    
    foreach my $attachment (@$attachments) {
        $multipart->add_part($attachment);
    }
    
    return $multipart;
}
    
=head1 FUNCTIONS

=head2 insert($path [, $mimetype] )

=cut

sub insert($$;$) {
    my ($self, $path, $mimetype) = @_;
    my $context = $self->_context;
    my $this = $context->{$NAME};
    
    if (exists $this->{attachments}->{$path}) {
        return $this->{attachments}->{$path}->head->get('Content-Id');
    }
    
    my $digest = Digest::SHA->new(256);
    $digest->addfile($path);
    my $cid = $digest->hexdigest . '@' . $this->{hostname};
    
    if (exists $this->{attachments}->{$cid}) {
        $this->{attachments}->{$path} = $this->{attachments}->{$cid};
        return $cid;
    }
    
    $mimetype ||= $self->{magic}->checktype_filename($path);
    
    my $part = MIME::Entity->build(
        Path => $path,
        Id => $cid,
        Encoding => 'base64',
        Type => $mimetype,
        Top => 0
    );
    $this->{attachments}->{$cid} = $this->{attachments}->{$path} = $part;
    return $cid;
}

=head1 AUTHOR

David Zurborg, C<< <david at fakenet.eu> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-template-plugin-mime at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Template-Plugin-MIME>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Template::Plugin::MIME


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Template-Plugin-MIME>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Template-Plugin-MIME>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Template-Plugin-MIME>

=item * Search CPAN

L<http://search.cpan.org/dist/Template-Plugin-MIME/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2013 David Zurborg, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the terms of the ISC license.

=cut

1; # End of Template::Plugin::MIME
