set ns [new Simulator]

set tf [open ex3.tr w]
$ns trace-all $tf

set nf [open ex3.nam w]
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]

$n0 label 'Server'
$n1 label 'Client'

$ns duplex-link $n0 $n1 10Mb 22ms DropTail
$ns duplex-link-op $n0 $n1 orient right

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp 
$tcp set packetSize_ 1500

set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 0.5 "$ftp start"
$ns at 10.0 "finish"

proc finish {} {
	global ns tf nf
	$ns flush-trace
	close $tf
	close $nf
	exec nam ex3.nam &
	exec awk -f ex3transfer.awk ex3.tr &
	exec awk -f ex3convert.awk ex3.tr > convert.tr &
	exec xgraph convert.tr -geometry 800*400 -t "bytes_client" -x "time_in_secs" -y "bytes_in_bps" &
	exit 0
}
$ns run
