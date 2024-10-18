use strict;
use warnings;

use Mail::IMAPClient;
use IO::Socket::SSL;

#Let's define Gmail IMAP server
my $imap_srv = "imap.gmail.com";
my $port = 993;
my $em = "";
my $app_pswd = ""; #We need to generate an App Password since Google blocks apps from accessing your account with normal password.

#Create IMAP client
my $imap_cl = Mail::IMAPClient->new(Server => $imap_srv, Port => $port, User => $em, Password => $app_pswd, Ssl => 1, Uid => 1) or die "Could not connect to IMAP server: $@";

#Connect to server
$imap_cl->select("INBOX") or die "Could not select INBOX folder: ", $imap_cl->LastError;

#Get unseen emails
my @em_messages = $imap_cl->search("UNSEEN");

foreach my $msg_id (@em_messages) {
    my $subject = $imap_cl->subject($msg_id);
    my $from = $imap_cl->get_header($msg_id, 'From');
    my $body = $imap_cl->body_string($msg_id);

    print "From: $from\n";
    print "Subject: $subject\n";
    print "Body: $body\n\n";
}

$imap_cl->logout;