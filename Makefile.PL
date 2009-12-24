use inc::Module::Install;

name     'DBIx-Class-QueryProfiler';
all_from 'lib/DBIx/Class/QueryProfiler.pm';
author   q{Andrey Kostenko <andrey@kostenko.name>};
license  'perl';

build_requires 'Test::More';
requires 'parent';
requires 'DBIx::Class';
test_requires 'Test::Perl::Critic';

auto_install;

WriteAll;

