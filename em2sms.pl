use strict;
use warnings;

use Mail::IMAPClient;
use IO::Socket::SSL;

#Let's define Gmail IMAP server
my $imap_srv = "imap.gmail.com";
my $port = 993;
my $em = "";
my $app_pswd = ""; #We need to generate an App Password since Google blocks apps from accessing your account with normal password.
