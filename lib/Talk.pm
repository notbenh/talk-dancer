package Talk;
use Dancer ':syntax';
use YAML;
use FindBin qw($Bin);
use Data::Dumper; sub D (@){ debug Dumper(@_)};

our $VERSION = '0.1';
my $slides  = Load(join '', <Talk::DATA>);
my $last    = scalar(@$slides)-1; 

get '/' => sub {
    template 'index';
};

get '/slide'       => sub{ return forward q{/slide/first} };
get '/slide/first' => sub{ return forward q{/slide/0} };
get '/slide/last'  => sub{ return forward qq{/slide/$last} };
get '/slide/prev'  => sub{ 
  my $prev = (session 'page' || 0 ) - 1;
  $prev = $prev >=0 ? $prev : 0;
  return forward qq{/slide/$prev};
};
get '/slide/next'  => sub{ 
  my $next = (session 'page' || -1 ) +1 ;
  $next = $next >= $last ? $last : $next;
  return forward qq{/slide/$next};
};
get '/slide/:page' => sub{ 
  session  page => params->{page};
  my $slide = $slides->[params->{page}];
  my ($slide_type,$code_type) = split /:/, $slide =~ m/^</      ? 'HTML'
                                         : $slide =~ s/^~YAML// ? 'CODE:PLAIN' # YAML
                                         : $slide =~ s/^~HTML// ? 'CODE:HTML'
                                         : $slide =~ s/^~//     ? $slide =~ m/^>/ ? 'PROMPT' : 'CODE:PERL'
                                         :                        'P'
                                         ; 
  
  template talk => { slide      => $slide
                   , page       => params->{page}
                   , last_page  => $last
                   , slide_type => $slide_type
                   , code_type  => $code_type
                   };
};

true;
__DATA__
---
- |
  meta-dancer: lets talk about dancer about dancer from with in dancer
- |
  Sinatra clone, not MVC... rather just VC
  <ul>
    <li>yes : routes</li>
    <li>yes : templates</li>
    <li>no  : ORM</li>
  </ul>
- sold... so how do I start?
- ~> cpanm Dancer 
- ~> cd git 
- ~> dancer -a Talk 
- ~> cd Talk && git init
- ~> git add *
- ~> git commit -m 'you have to start somewhere' -a
- ~> ln -s bin/app.pl app.psgi
- ~> plackup
- http://0.0.0.0:5000/ <br> <img src='/images/fresh-install.png' height=50% width=50%>
- TADA, but what got built?
- |
  ~
  [FILE: ./lib/Talk.pm]
  package Talk;
  use Dancer ':syntax';
  
  our $VERSION = '0.1';
  
  get '/' => sub {
      template 'index';
  };
  
  true;
- |
  ~YAML
  [FILE: ./config.yaml]
  # This is the main configuration file of your Dancer app
  # env-related settings should go to environments/$env.yml
  # all the settings in this file will be loaded at Dancer's startup.
  
  # Your application's name
  appname: "Talk"
  
  # The default layout to use for your application (located in
  # views/layouts/main.tt)
  layout: "main"
  
  # when the charset is set to UTF-8 Dancer will handle for you
  # all the magic of encoding and decoding. You should not care
  # about unicode within your app when this setting is set (recommended).
  charset: "UTF-8"
  
  # template engine
  # simple: default and very basic template engine
  # template_toolkit: TT
  
  template: "simple"
  
  # template: "template_toolkit"
  # engines:
  #   template_toolkit:
  #     encoding:  'utf8'
  #     start_tag: '[%'
  #     end_tag:   '%]'
- change our template to TT2 
- | 
  ~YAML
  [FILE: ./config.yaml]
  #template: "simple"
  
  template: "template_toolkit"
  engines:
    template_toolkit:
      encoding:  'utf8'
      start_tag: '[%'
      end_tag:   '%]'

- good time to talk about the view/layout stuff
- in dancer a view is wrapped in a layout
- | 
  ~HTML
  [FILE: ./views/layout/main.tt]
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <meta http-equiv="Content-type" content="text/html; charset=<% settings.charset %>" />
  <title>Talk</title>
  <link rel="stylesheet" href="<% request.uri_base %>/css/style.css" />

  <!-- Grab Google CDN's jQuery. fall back to local if necessary -->
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript"></script>
  <script type="text/javascript">/* <![CDATA[ */
      !window.jQuery && document.write('<script type="text/javascript" src="<% request.uri_base %>/javascripts/jquery.js"><\/script>')
  /* ]]> */</script>

  </head>
  <body>
  <% content %>
  <div id="footer">
  Powered by <a href="http://perldancer.org/">Dancer</a> <% dancer_version %>
  </div>
  </body>
  </html>
- then each route tends to call a template that gets shoved in to content
- |
  ~HTML
  [FILE: ./views/index.tt]
  <!-- 
      Credit goes to the Ruby on Rails team for this page 
      has been heavily based on the default Rails page that is 
      built with a scaffolded application.

      Thanks a lot to them for their work.

      See Ruby on Rails if you want a kickass framework in Ruby:
      http://www.rubyonrails.org/
  -->

  <div id="page">
        <div id="sidebar">
          <ul id="sidebar-items">
            <li>
              <h3>Join the community</h3>
              <ul class="links">

                <li><a href="http://perldancer.org/">PerlDancer</a></li>
                <li><a href="http://twitter.com/PerlDancer/">Official Twitter</a></li>
                <li><a href="http://github.com/sukria/Dancer/">GitHub Community</a></li>
              </ul>
            </li>
            
            <li>
              <h3>Browse the documentation</h3>

              <ul class="links">
                <li><a
                href="http://search.cpan.org/dist/Dancer/lib/Dancer/Introduction.pod">Introduction</a></li>
                <li><a href="http://search.cpan.org/dist/Dancer/lib/Dancer/Cookbook.pod">Cookbook</a></li>
                <li><a href="http://search.cpan.org/dist/Dancer/lib/Dancer/Deployment.pod">Deployment Guide</a></li>
                <li><a
                href="http://search.cpan.org/dist/Dancer/lib/Dancer/Tutorial.pod"
                title="a tutorial to build a small blog engine with Dancer">Tutorial</a></li>
              </ul>
            </li>

            <li>
              <h3>Your application's environment</h3>

              <ul>
                  <li>Location: <code>/tmp/Talk</code></li>
                  <li>Template engine: <code><% settings.template %></code></li>
                  <li>Logger: <code><% settings.logger %></code></li>
                  <li>Environment: <code><% settings.environment %></code></li>
              </ul>

            </li>
          </ul>

        </div>

        <div id="content">
          <div id="header">
            <h1>Perl is dancing</h1>
            <h2>You&rsquo;ve joined the dance floor!</h2>
          </div>

          <div id="getting-started">
            <h1>Getting started</h1>
            <h2>Here&rsquo;s how to get dancing:</h2>
                      
            <h3><a href="#" id="about_env_link">About your application's environment</a></h3>

            <div id="about-content" style="display: none;">
              <table>
                  <tbody>
                  <tr>
                      <td>Perl version</td>
                      <td><tt><% perl_version %></tt></td>
                  </tr>
                  <tr>
                      <td>Dancer version</td>
                      <td><tt><% dancer_version %></tt></td>
                  </tr>
                  <tr>
                      <td>Backend</td>
                      <td><tt><% settings.apphandler %></tt></td>
                  </tr>
                  <tr>
                      <td>Appdir</td>
                      <td><tt>/tmp/Talk</tt></td>
                  </tr>
                  <tr>
                      <td>Template engine</td>
                      <td><tt><% settings.template %></tt></td>
                  </tr>
                  <tr>
                      <td>Logger engine</td>
                      <td><tt><% settings.logger %></tt></td>
                  </tr>
                  <tr>
                      <td>Running environment</td>
                      <td><tt><% settings.environment %></tt></td>
                  </tr>
                  </tbody>
              </table>
            </div>

      <script type="text/javascript">
      $('#about_env_link').click(function() {
          $('#about-content').slideToggle('fast', function() {
              // ok
          });
          return( false );
      });
      </script>


            <ol>          
              <li>
                <h2>Tune your application</h2>

                <p>
                Your application is configured via a global configuration file,
                <tt>config.yml</tt> and an "environment" configuration file,
                <tt>environments/development.yml</tt>. Edit those files if you
                want to change the settings of your application.
                </p>
              </li>

              <li>
                <h2>Add your own routes</h2>

                <p>
                The default route that displays this page can be removed,
                it's just here to help you get started. The template used to
                generate this content is located in 
                <code>views/index.tt</code>.
                You can add some routes to <tt>lib/Talk.pm</tt>. 
                </p>
              </li>

              <li>
                  <h2>Enjoy web development again</h2>

                  <p>
                  Once you've made your changes, restart your standalone server
                  (bin/app.pl) and you're ready to test your web application.
                  </p>
              </li>

            </ol>
          </div>
        </div>
      </div>
- but we should s/<%(.*?)%>/[%$1%]/g as we changed the bracket type in the config
- before we get started... any questions thus far?
- ok so this is a talk about buidling a slide deck
- PLAN, all slides are items in an array, stored as YAML
- ~use YAML;
- PLAN, YAML is stored in DATA (simple)
- | 
  ~
  __DATA__
  - cd git 
- ~ my $slides  = Load(join '', <Talk::DATA>);
- now the code can access the data, but the user can't.
- lets create a route
- ~ get URL-PATTERN => sub{...};
- | 
  ~
  get '/slide/:page' => sub{ 
    my $slide = $slides->[params->{page}];
    template slide => { slide => $slide
                      , page  => params->{page}
                      };
  };
- but this will fail... we need to create  template 'slide'
- |
  ~HTML
  [FILE: ./views/slide.tt]
  <p>
  [% slide %]
  </p>
- ~> plackup
- point browser at http://0.0.0.0:5000/slide/0
- horray first slide! 
- now lets get crafty and have pagination, though to make this really work we should have a session to pass the current page around
- ~ session: 'YAML'
- |
  ~
  [FILE: ./lib/Talk.pm]

  get '/slide/:page' => sub{ 
    session  page => params->{page}; # hook up the session to our route 
    my $slide = $slides->[params->{page}];
    template talk => { slide      => $slide
                     , page       => params->{page}
                     , last_page  => scalar(@$slides)-1
                     };
  };
- |
  ~
  get '/slide/prev'  => sub{ 
    my $prev = (session 'page' || 0 ) - 1;
    $prev = $prev >=0 ? $prev : 0;
    return forward qq{/slide/$prev};
  };
  get '/slide/next'  => sub{ 
    my $next = (session 'page' || -1 ) +1 ;
    $next = $next >= $last ? $last : $next;
    return forward qq{/slide/$next};
  };
- ~> plackup
- point browser at http://0.0.0.0:5000/slide/next
- questions, that's the basics
- what else I did
- alias ./public/javascripts to ./public/js for simplicity
- ~> cd javascripts && ln -s javascripts js && cd ..
- update jquery, dancer ships with 1.4.2
- ~> wget http://code.jquery.com/jquery-1.7.2.min.js -o ./public/jquery.js
- update the call in ./views/layouts/main.tt
- add hot keys via jquery
- |
  ~HTML
  [FILE: ./views/layouts/main.tt]
  <script type='text/javascript'>
  $(document).ready(function() {
    $(document).keydown( function(e){                                                                                                                                                                               
     var key = String.fromCharCode(e.keyCode);
     if ( key== 'N' || e.keyCode == 190) {
        window.location = $('a#next').attr('href');
     }
     else if (key == 'P' || e.keyCode == 188) {
        window.location = $('a#prev').attr('href');
     }
  });
  });
  </script>
- plug in SyntaxHighlighter
- provide syntax hooks for simplicity
- first/last routes
- |
  <h1>Thanks:</h1>
  <pre>
  + <a href='https://github.com/sukria/Dancer'>sukria & team dancer</a>
  + <a href='https://github.com/yaml'>ingy & team YAML</a>
  + <a href='https://github.com/alexgorbatchev/SyntaxHighlighter'>alexgorbatchev for SyntaxHighlighter</a>
  + <a href='https://twitter.com/#!/ericsbrain'>ewilhelm for nominating me</a>
  + you for listening to me yammer on about dancer
  </pre>
 
  










