set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(x) 500
set val(y) 500
set val(ifqlen) 50
set val(nn) 5
set val(stop) 50.0
set val(rp) AODV
#set val(cp) tcp-25-8

set ns [new Simulator]

set tracefd [open pgm10.tr w]
$ns trace-all $tracefd

set namtrace [open pgm10.nam w]
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

set prop [new $val(prop)]

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god [create-god $val(nn)]

$ns node-config -adhocRouting $val(rp)\
		-llType $val(ll)\
		-macType $val(mac)\
		-ifqType $val(ifq)\
		-ifqLen $val(ifqlen)\
		-antType $val(ant)\
		-propType $val(prop)\
		-phyType $val(netif)\
		-channelType $val(chan)\
		-topoInstance $topo\
		-agentTrace ON\
		routerTrace ON\
		-macTrace ON\
		-IncomingErrProc "uniformErr"\
		-OutgoingErrProc "uniformErr"
		
proc uniformErr {} {
	set err [new ErrorModel]
	$err unit pkt
	$err set rate_ 0.01
	return $err
}

		
for {set i 0} {$i < $val(nn)} {incr i} {
	set node($i) [$ns node]
	$node($i) random-motion 0
}


for {set i 0} {$i < $val(nn)} {incr i} {
	$ns initial_node_pos $node($i) 40
}

$ns at 1.0 "$node(0) setdest 10.0 10.0 50.0"
$ns at 1.0 "$node(1) setdest 10.0 100.0 50.0"
$ns at 1.0 "$node(2) setdest 100.0 100.0 50.0"
$ns at 1.0 "$node(3) setdest 100.0 10.0 50.0"
$ns at 1.0 "$node(4) setdest 50.0 50.0 50.0"


puts "Loading connection file..."
#source $val(cp)

set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $node(0) $tcp0
$ns attach-agent $node(2) $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 50.0 "$ftp0 stop"

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns attach-agent $node(1) $tcp1
$ns attach-agent $node(2) $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 1.0 "$ftp1 start"
$ns at 50.0 "$ftp1 stop"

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at $val(stop) "$node($i) reset"
}
$ns at $val(stop) "$ns halt"

puts "starting sumulation.."
$ns run
