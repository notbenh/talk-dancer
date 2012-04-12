package Talk;
use Dancer ':syntax';
use YAML qw{LoadFile};
use FindBin qw($Bin);

our $VERSION = '0.1';
our $slides  = LoadFile(qq{$Bin/slides.yaml});

get '/' => sub {
    template 'index';
};

get '/talk' => sub{ forward q{/talk/0} };
get '/talk/:page' => sub{ 
  template talk => {slide => $slides->[params->{page}] };
};
  

true;
