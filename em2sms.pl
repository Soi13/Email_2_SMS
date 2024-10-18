use strict;
use warnings;

use Mail::IMAPClient;
use IO::Socket::SSL;
use Email::MIME;
use HTTP::Tiny;

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

#Create IMAP client
my $imap_cl = Mail::IMAPClient->new(Server => $imap_srv, Port => $port, User => $em, Password => $app_pswd, Ssl => 1, Uid => 1) or die "Could not connect to IMAP server: $@";

#Connect to server
$imap_cl->select("INBOX") or die "Could not select INBOX folder: ", $imap_cl->LastError;

#Get unseen emails
my @em_messages = $imap_cl->search("FROM", $sender, "UNSEEN");

foreach my $msg_id (@em_messages) {
    my $whole_message = "";
    my $raw_message = $imap_cl->message_string($msg_id);

    my $email_mime = Email::MIME->new($raw_message);
    # Get the text part of the email (ignoring HTML)
    my $text_body = "";
    for my $part ($email_mime->parts) {
        if ($part->content_type =~ m{text/plain}i) {
            $text_body = $part->body_str;
            last;
        }
    }

    my $subject = $imap_cl->subject($msg_id);
    my $from = $imap_cl->get_header($msg_id, 'From');
    $from =~ m/(.*?)\</gm;
    my $from_name = $1;
    #$text_body =~ s/<(.+)>//gm;
    #$text_body =~ s/\w+@\w+\.\w+//gm;
    $text_body =~ s/sincerely.*//gmsi;
    $imap_cl->deny_seeing($msg_id); #Keep messages in UNSEEN status after script read them

    $whole_message .="From: $from_name\n\n"."Subject: $subject\n\n".$text_body;
    print $whole_message;

    #Preparing data for sending text message
    my $data = {
        phone => "0000000000",
        message => $whole_message,
        key => $sms_gate_API,
    };

    my $response = $http->post_form($url, $data);

    if ($response->{success}) {
        print "Response: ", $response->{content}, "\n";
    } else {
        die "HTTP POST error: $response->{status} $response->{reason}";
    }
}

$imap_cl->logout;