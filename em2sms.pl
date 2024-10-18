use strict;
use warnings;

use Mail::IMAPClient;
use IO::Socket::SSL;
use Email::MIME;

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
            last;  # Exit the loop after finding the plain text part
        }
    }

    my $subject = $imap_cl->subject($msg_id);
    my $from = $imap_cl->get_header($msg_id, 'From');
    $from =~ m/(.*?)\</gm;
    $imap_cl->deny_seeing($msg_id); #Keep messages in UNSEEN status after script read them

    $whole_message .="From: $1\n\n"."Subject: $subject\n\n".$text_body;
    print $whole_message;
}

$imap_cl->logout;