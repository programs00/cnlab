set ns [new Simulator]

set tf [open ex2.tr w]
$ns trace-all $tf

set nf [open ex2.nam w]
$ns namtrace-all $nf

set cwind [open win2.tr w]

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n2 5Mb 2ms DropTail
$ns duplex-link $n1 $n2 0.4Mb 5ms DropTail
$ns duplex-link $n2 $n3 2Mb 5ms DropTail
$ns duplex-link $n3 $n4 2Mb 2ms DropTail
$ns duplex-link $n3 $n5 2Mb 2ms DropTail
#$ns queue-limit $n2 $n3 10

set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1
set ftp1 [new Application/FTP]
$ns connect $tcp1 $sink1
$ftp1 attach-agent $tcp1
$ns at 1.2 "$ftp1 start"

set tcp2 [new Agent/TCP]
$ns attach-agent $n1 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n4 $sink2
set telnet1 [new Application/Telnet]
$ns connect $tcp2 $sink2
$telnet1 attach-agent $tcp2
$ns at 5.1 "$telnet1 start"

$ns at 5.0 "$ftp1 stop"
$ns at 10.0 "finish"

proc plotWindow {tcpSource file} {
	global ns
	set time 0.01
	set now [$ns now]
	set cwd [$tcpSource set cwnd_]
	puts $file "$now $cwd"
	$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
	
	
$ns at 2.0 "plotWindow $tcp1 $cwind"
$ns at 5.5 "plotWindow $tcp2 $cwind"

proc finish {} {
	global ns tf nf cwind
	$ns flush-trace
	close $tf
	close $nf
	#close $cwind
	puts "running nam.."
	puts "FTP PAKETS...."
	puts "Telnet PACKETS..."
	#exec nam ex2.nam &
	#exec xgraph win2.tr &
	exit 0	
}
$ns run
