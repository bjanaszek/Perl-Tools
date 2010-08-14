#
# This script will parse .TRX files (MSTest results files) and generate a somewhat pretty HTML page displaying the results.
#
# $Header: $
#
# This requires Perl 5.10 (5.8 _might_ work) and the packages defined below.
# Usage: perl parse_results.pl test_result_file output_file
#

#!/usr/bin/perl

use strict;
use XML::XPath;
use XML::XPath::XMLParser;
use HTML::Stream;

if( $#ARGV != 1 ) {
    print "USAGE: test_report.pl source_file output_file\n";
    exit;
}

my ( $source_file, $output_file, $xml_data, $xml, $html, $out );

$source_file = $ARGV[ 0 ];
$output_file = $ARGV[ 1 ];

print "Opening test results...\n";
$xml = XML::XPath->new( filename => $source_file );

# open output file
open( my $HTML_OUTPUT, ">$output_file" ) or die "Could not open $output_file!\n";

# Create HTML::Stream
$html = new HTML::Stream $HTML_OUTPUT;
$html -> HTML
  -> HEAD
  -> TITLE -> t( "DesignPRO Data Layer Unit Test Results" ) -> _TITLE
  -> BODY( STYLE=>"font-family: Verdana" )
  -> H1 -> t( "DesignPRO Data Layer Unit Test Results" ) -> _H1
  -> TABLE( BORDER=>"1", CELLPADDING=>"2", CELLSPACING=>"2" )
  -> TR( STYLE=>"background-color:#cccccc" )
  -> TD -> STRONG -> t( "Test Name" ) -> _STRONG -> _TD
  -> TD -> STRONG -> t( "Description" ) -> _STRONG -> _TD
  -> TD -> STRONG -> t( "Result" ) -> _STRONG -> _TD
  -> _TR;

# Retrieve list of tests:
my ( $test_name, $test_desc, $execId, $testId, $result_node, $result );
my ( $total_tests, $tests_passed, $tests_failed );

# Get list of unit tests
foreach my $tests ( $xml->find( "//TestRun/TestDefinitions/UnitTest" )->get_nodelist ) {
  $html -> TR;

  # Parse the test info:
  $test_name = $tests->find( '@name' );
  $test_desc = $tests->find( "Description" )->string_value;
  $execId = $tests->find( 'Execution/@id' );
  $testId = $tests->find( '@id' );

  # Get the test results
  $result = $xml->find( "//TestRun/Results/UnitTestResult[\@testName='$test_name']/\@outcome" )->string_value;

  $html -> TD -> t( $test_name ) -> _TD;
  $html -> TD -> t( $test_desc ) -> _TD;
  $html -> TD;
  if( $result eq "Passed" ) {
    $html -> SPAN( STYLE=>'color:green;font-weight:bold' ) -> t( $result ) -> _SPAN;
  } else {
    $html -> SPAN( STYLE=>'color:red;font-weight:bold' ) -> t( $result ) -> _SPAN;
  }
  
  $html -> _TD
    -> _TR;
}

$html -> _TABLE
  -> BR -> BR
  -> TABLE( CELLPADDING=>"2", CELLSPACING=>"2" )
  -> TR -> TD -> STRONG -> t( "Tester:" ) -> _STRONG -> _TD -> _TR
  -> TR -> TD -> STRONG -> t( "Signature:" ) -> _STRONG -> _TD -> _TR
  -> TR -> TD -> STRONG -> t( "Date:" ) -> _STRONG -> _TD -> _TR
  -> _TABLE
  -> _BODY
  -> _HTML;

print "Result processing complete!\n";

# All done, close output
close( $HTML_OUTPUT );
