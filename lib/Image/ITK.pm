package Image::ITK;

use strict;
use warnings;

sub import {
        my ($self, $opt) = @_;
        if( $opt eq ':python' ) {
                eval {
                        require Image::ITK::Backend::InlinePython;
                        *itk::AUTOLOAD = \&Image::ITK::Backend::InlinePython::AUTOLOAD;
                        1;
                } or do {
                        my $error = $@;
                        die "Could not load Inline::Python: $error";
                }
        }
}

1;
