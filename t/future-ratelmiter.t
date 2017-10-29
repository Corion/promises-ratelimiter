#!perl -w
use strict;
use Test::More tests => 1;
use Future;
use AnyEvent::Future;
#use Future::RateLimiter;
use RateLimiter::Bucket;
use Data::Dumper;

my $limiter = RateLimiter::Bucket->new(
    burst => 5,
    rate  => 30/60, # 0.5/s
);

my $started = time;
my @elements = Future->wait_all( map {
    my $i = $_;
    $limiter->limit()
    ->then(sub {
          diag "$i done\n";
          return Future->done($i);
    });
} 1..10)->get;
#@elements = sort { $a<=>$b } map { $_->get } @elements;
@elements = map { $_->get } @elements;
is_deeply( \@elements, [1..10], "We get the expected results, in order")
    or diag Dumper \@elements;