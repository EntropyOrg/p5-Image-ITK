use Test::Most tests => 2;
use Data::TestImage;

use strict;
use warnings;

BEGIN { use_ok('Image::ITK', ':python' ) }

my $mandrill_path = Data::TestImage->get_image('mandrill');

my $pix_type = itk::F(); # float
my $image_type = itk::Image( $pix_type, 2 );

my $image_reader = itk::ImageFileReader( $image_type )->New();
$image_reader->SetFileName( "$mandrill_path" );
$image_reader->Update();

my $image = $image_reader->GetOutput();

my $size = $image->GetLargestPossibleRegion->GetSize;
is( "$size", 'itkSize2 ([512, 512])', 'size of image is 512 by 512');

done_testing;
