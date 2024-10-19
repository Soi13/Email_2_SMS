#!/usr/bin/perl
use strict;
use warnings;
use Mail::IMAPClient;
use IO::Socket::SSL;
use HTTP::Tiny;
use DateTime;

my $dt = DateTime->now(time_zone => 'local');
my $filename = "/home/oleg/Documents/Email_2_SMS/log.txt";

#SMS gate API
my $sms_gate_API = "";

#Let's create HTTP::Tiny client
my $http = HTTP::Tiny->new;
my $url = "https://textbelt.com/text";

#Let's define Gmail IMAP server
my $imap_srv = "imap.gmail.com";
my $port = 993;
my $em = "";
my $app_pswd = ""; #We need to generate an App Password since Google blocks apps from accessing your account with normal password.

my $sender = "";
my $recepient_phone = "+10000000000";

#Create IMAP client
my $imap_cl = Mail::IMAPClient->new(Server => $imap_srv, Port => $port, User => $em, Password => $app_pswd, Ssl => 1, Uid => 1) or die "Could not connect to IMAP server: $@";

#Connect to server
$imap_cl->select("INBOX") or die "Could not select INBOX folder: ", $imap_cl->LastError;

#Get unseen emails
my @em_messages = $imap_cl->search("FROM", $sender, "UNSEEN");

if (@em_messages) {
    foreach my $msg_id (@em_messages) {
        my $whole_message = "";
        my $subject = $imap_cl->subject($msg_id);
        my $from = $imap_cl->get_header($msg_id, 'From');
        $from =~ m/(.*?)\</gm;
        my $from_name = $1;
        $imap_cl->deny_seeing($msg_id); #Keep messages in UNSEEN status after script read them
        $whole_message .="From: $from_name\n\n"."Subject: $subject\n\n";

        #Preparing data for sending text message
        my $data = {
            phone => $recepient_phone,
            message => $whole_message,
            key => $sms_gate_API,
        };

        my $response = $http->post_form($url, $data);

        open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";

        if ($response->{success}) {
            print $fh "Response: ", $response->{content}, " : ", join(" ", $dt->ymd, $dt->hms), "\n";
        } else {
            print $fh "HTTP POST error: $response->{status} $response->{reason} : ", , join(" ", $dt->ymd, $dt->hms), "\n";
        }
        close $fh;
    }
    $imap_cl->logout;
}

