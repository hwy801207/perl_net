package Web;
use Base;
use Exporter qw/import/;

our @EXPORT = qw/handle_connection docroot/;

my $DOCUMENT_ROOT = '/Users/huangweiyi/www/html';
my $CRLF = "\015\012";

sub handle_connection {
	my $c = shift;
	my ($fh, $type, $length, $url, $method);
    local $/ = "$CRLF$CRLF";
	my $request = <$c>;
	return  invalid_request($c)
		unless ($method, $url) = $request =~ m !^(GET|HEAD) (/.*) HTTP/1\.[01]!;
	return not_found($c) unless ($fh, $type, $length) = lookup_file($url);
	return redirect($c, "$url/") if $type eq 'directory';

	print $c "HTTP/1.0 200 OK$CRLF";
	print $c "Content-length: $length$CRLF";
	print $c "Content-type: $type$CRLF";
	print $c $CRLF;
	return unless $method eq 'GET';
	
	# print the content
	my $buffer;
	while (read($fh, $buffer, 1024)) {
		print $c $buffer;
	}
	close $fh;
}

sub redirect {
	my ($c, $url) = @_;
	my $host = $c->sockhost;
	my $port = $c->sockport;
	my $moved_to = "http://$host:$port$url";
	print $c "HTTP/1.0 301 Moved permanently$CRLF";
	print $c "Location: $moved_to$CRLF";
	print $c "Content-type: text/html$CRLF$CRLF";
	print $c <<END;
<HTML>
	<HEAD>
	<TITLE> 301 Moved </TITLE>
	</HEAD>
	<BODY>
	<p>
		The requested document has moved
	<A HREF="$moved_to">here
	</A>.
	</p>
	</BODY>
</HTML>
END
}

sub invalid_request {
	my $c = shift;
	print $c "HTTP/1.0 400 Bad request$CRLF";
	print $c "Content-type: text/html$CRLF$CRLF";
	print $c <<END;
<HTML>
	<HEAD>
	<TITLE> 400 Bad Request </TITLE>
	</HEAD>
	<BODY>
	<h1> Bad Request </h1>
	<p> Your browser sent a request that this server does not support </p>
	</BODY>
</HTML>
END
}

sub not_found {
	my $c = shift;
	print $c "HTTP/1.0 404 Document not found$CRLF";
	print $c "Content-type: text/html$CRLF$CRLF";
	print $c <<END;
<HTML>
	<HEAD>
	<TITLE> 404 Not Found</TITLE>
	</HEAD>
	<BODY>
	<h1> Not Found</h1>
	<p> The requestd document was not found on this server.</p>
	</BODY>
</HTML>
END

}
sub lookup_file {
	my $url = shift;
	my $path = $DOCUMENT_ROOT . $url;
	$path =~ s/\?.*$//;
	$path =~ s/\#.*$//;
	$path = 'index.html' if $url =~ m!/$!;
	return if $path =~ m !/\.\./!;
	return (undef, 'directory', undef) if -d $path;
	my $type = 'text/plain';
	$type = 'text/html' if $path =~  /\.html?$/i;
	$type = 'text/gif' if $path =~ /\.gif$/i;
	$type = 'text/jpeg' if $path =~ /.jpe?g$/i;
	return unless my $length = (stat(_))[7];
	return unless my $fh = IO::File->new($path, "<");
	return ($fh, $type, $length);

}

sub docroot {
	$DOCUMENT_ROOT = shift if @_;
	return $DOCUMENT_ROOT;
}

1;
