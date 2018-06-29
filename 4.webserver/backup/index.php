<?php

function Sound()
{
    echo "Entering Sound";
}

?>

<?php

//include "/var/app/current/config.php";
//require  __DIR__ . '/config.php';

$dbhost = "aavwvrcgrz00x0.crwyqjzsyfsx.us-west-2.rds.amazonaws.com:3306";
$dbuser = "xbaotha";
$dbpass = "Thaibao14";

// Create connection
$conn = new mysqli($dbhost, $dbuser, $dbpass);
//$conn = mysqli_connect($_SERVER['RDS_HOSTNAME'], $_SERVER['RDS_USERNAME'], $_SERVER['RDS_PASSWORD'], $_SERVER['RDS_DB_NAME'], $_SERVER['RDS_PORT']);


Sound();
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully abc";

$result = mysqli_query($mysqli, "SELECT * FROM users ORDER BY id DESC");

?>

<html>
<head>
        <title>Homepage</title>
</head>

<body>
<a href="add.html">Add New Data</a><br/><br/>

        <table width='80%' border=0>

        <tr bgcolor='#CCCCCC'>
                <td>Name</td>
                <td>Age</td>
                <td>Email</td>
                <td>Update</td>
        </tr>
        <?php
        //while($res = mysql_fetch_array($result)) { // mysql_fetch_array is deprecated, we need to use mysqli_fetch_array
        while($res = mysqli_fetch_array($result)) {
                echo "<tr>";
                echo "<td>".$res['name']."</td>";
                echo "<td>".$res['age']."</td>";
                echo "<td>".$res['email']."</td>";
                echo "<td><a href=\"edit.php?id=$res[id]\">Edit</a> | <a href=\"delete.php?id=$res[id]\" onClick=\"return confirm('Are you sure you want to delete?')\">Delete</a></td>";
        }
        ?>
        </table>
</body>
</html>

