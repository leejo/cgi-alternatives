use strict;
use warnings;

use example_form;

my $app = example_form->apply_default_middlewares(example_form->psgi_app);
$app;

