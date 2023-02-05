set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) CMUPriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(x) 700
set val(y) 700
set val(ifqlen) 50
set val(nn) 6
set val(stop) 60.0
set val(rp) DSR
#set val(cp) tcp-25-8

set ns [new Simulator]

set tracefd [open pgm9.tr w]
$ns trace-all $tracefd

set namtrace [open pgm9.nam w]
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
		-macTrace ON
		
for {set i 0} {$i < $val(nn)} {incr i} {
	set node($i) [$ns node]
	$node($i) random-motion 0
}

$node(0) set X_ 150.0
$node(0) set Y_ 300.0
$node(0) set Z_ 0.0

$node(1) set X_ 300.0
$node(1) set Y_ 500.0
$node(1) set Z_ 0.0

$node(2) set X_ 500.0
$node(2) set Y_ 500.0
$node(2) set Z_ 0.0

$node(3) set X_ 300.0
$node(3) set Y_ 100.0
$node(3) set Z_ 0.0

$node(4) set X_ 500.0
$node(4) set Y_ 100.0
$node(4) set Z_ 0.0

$node(5) set X_ 650.0
$node(5) set Y_ 300.0
$node(5) set Z_ 0.0

$ns at 1.0 "$node(0) setdest 160.0 300.0 2.0"
$ns at 1.0 "$node(1) setdest 310.0 150.0 2.0"
$ns at 1.0 "$node(2) setdest 490.0 490.0 2.0"
$ns at 1.0 "$node(3) setdest 300.0 120.0 2.0"
$ns at 1.0 "$node(4) setdest 510.0 90.0 2.0"
$ns at 1.0 "$node(5) setdest 640.0 290.0 2.0"

$ns at 4.0 "$node(3) setdest 300.0 500.0 5.0"




for {set i 0} {$i < $val(nn)} {incr i} {
	$ns initial_node_pos $node($i) 40
}

puts "Loading connection file..."
#source $val(cp)

set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $node(0) $tcp0
$ns attach-agent $node(5) $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 5.0 "$ftp0 start"
$ns at 60.0 "$ftp0 stop"

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at $val(stop) "$node($i) reset"
}
$ns at $val(stop) "$ns halt"

puts "starting sumulation.."
$ns run
