#/usr/bin/env perl

use MaxMind::DB::Writer::Tree;
use Net::Works::Network;
use open qw(:std :utf8);

if(@ARGV != 2){
    print "Usage: perl csv_file output_mmdb_file.\n";
}

open (FILE, @ARGV[0]) || die "Can not open file: @ARGV[0]\n";
@line=<FILE>;

my %types = (
    city                => 'map',
    country             => 'map',
    county              => 'map',
    registered_country  => 'map',
    subdivisions        => 'map',
    location            => 'map',
    continent           => 'map',
    geoname_id          => 'uint32',
    id                  => 'uint32',
    names               => 'map',
    isp                 => 'map',
    en                  => 'utf8_string',
    zh_CN               => 'utf8_string',
    de                  => 'utf8_string',
    fr                  => 'utf8_string',
    ru                  => 'utf8_string',
    spa                 => 'utf8_string',
    jp                  => 'utf8_string',
    pt                  => 'utf8_string',
    code                => 'utf8_string',
    iso_code            => 'utf8_string',
    org                 => 'utf8_string',
    latitude            => 'double',
    longitude           => 'double',
    time_zone           => 'utf8_string',
    states              => [ 'array', 'utf8_string' ],
);

my $tree = MaxMind::DB::Writer::Tree->new(
    ip_version    => 4,
    record_size   => 32,
    database_type => 'GeoIP',
    languages     => ['en'],
    description   => { en => 'GeoIP database' },
    map_key_type_callback => sub { $types{ $_[0] } },
);
my $i = 0;

foreach (@line){
    $i++;
    if($i != 1){
        my $linestr = $_;
        my @arr = ();
        my $position = 0;
        my $end = -1;
        my $start = 0;
        if(substr($linestr, 0, 1) eq '"'){
            $linestr = substr($linestr, 1, length($linestr)-1);
            $end = index($linestr, '"');
            $start = 1;
        }
        else{
            $end = index($linestr, ',');
        }
        while($end != -1){
            if($end == 0){
                $str = "";
            }
            else{
                $str = substr($linestr, 0, $end);
            }
            push(@arr, $str);
            $end++;
            $linestr = substr($linestr, $end+$start, length($linestr)-$end);
            if(substr($linestr, 0, 1) eq '"'){
                $linestr = substr($linestr, 1, length($linestr)-1);
                $end = index($linestr, '"');
                $start = 1;
            }
            else{
                $end = index($linestr, ',');
                $start = 0;
            }
        }
        $linestr =~ s/\"//g;
        push(@arr, $linestr);

        $scalar = @arr;
        print "$arr[0]\n";
        if($arr[0] != "" && $scalar == 22){
            my $network
                = Net::Works::Network->new_from_string( string => $arr[0] );
            $arr[21] =~ s/\n//;
            $tree->insert_network(
                $network,
                {
                    continent => {
                        code        => $arr[1],
                        names       => {
                            en      => $arr[2],
                            zh_CN   => $arr[3],
                        },
                    },
                    country   => {
                        iso_code    => $arr[4],
                        names       => {
                            en      => $arr[5],
                            zh_CN   => $arr[6],
                        },
                    },
                    subdivisions => {
                        iso_code    => $arr[7],
                        names       => {
                            en      => $arr[8],
                            zh_CN   => $arr[9],
                        },
                    },
                    city      => {
                        id          => $arr[10]+0,
                        names       => {
                            en      => $arr[11],
                            zh_CN   => $arr[12],
                        },
                    },
                    county    => {
                        id          => $arr[13]+0,
                        names       => {
                            en      => $arr[14],
                            zh_CN   => $arr[15],
                        },
                    },
                    isp       => {
                        id          => $arr[16]+0,
                        names       => {
                            zh_CN   => $arr[17],
                        },
                    },
                    location  => {
                        time_zone   => $arr[18],
                        org         => $arr[19],
                        latitude    => $arr[20]+0.0,
                        longitude   => $arr[21]+0.0,
                    },
                },
          );
        }
        else{
            print $line;
        }
    }
}

close FILE;
open my $fh, '>:raw', "@ARGV[1]";
$tree->write_tree($fh);
close $fh;
