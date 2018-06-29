<?php

function OpenCon()
{
	echo "testing"
	$dbhost = "aavwvrcgrz00x0.crwyqjzsyfsx.us-west-2.rds.amazonaws.com:3306"
	$dbuser = "xbaotha";
	$dbpass = "Thaibao14";
	
	// Create connection
	$conn = new mysqli($dbhost, $dbuser, $dbpass);
	
	// Check connection
	if ($conn->connect_error) {
		die("Connection failed: " . $conn->connect_error);
	}
	echo "Connected successfully";
	return $conn
}
 
function CloseCon($conn)
{
	$conn -> close();
}

function Sound()
{
	echo "Entering Sound";
}

?>
