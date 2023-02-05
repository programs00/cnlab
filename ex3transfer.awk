BEGIN{
      count = 0;
      time = 0;
      bytes_sent = 0;
      bytes_recieved = 0;      
}
{
	if($1 == "r" && $4 == 1 && $5 == "tcp")
		bytes_recieved += $6;
	if($1 == "+" && $3 == 0 && $5 == "tcp")
		bytes_sent += $6;
}
END{
	printf("time taken to transfer :- %f \n", $2);
	printf("total bytes sent from the server in MB:- %f \n", bytes_sent/1000000);
	printf("total bytes recieved by the cient in MB:- %f \n", bytes_recieved/1000000);
}

     
