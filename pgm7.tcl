set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(x) 500
set val(y) 400
set val(ifqlen) 50
set val(nn) 5
set val(stop) 60.0
set val(rp) AODV


set ns [new Simulator]

set tracefd [open pgm7.tr w]
$ns trace-all $tracefd

set namtrace [open pgm7.nam w]
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
		-routerTrace ON\
		-macTrace ON
		
for {set i 0} {$i < $val(nn)} {incr i} {
	set node($i) [$ns node]
	$node($i) random-motion 0
}

$node(0) set X_ 5.0
$node(0) set Y_ 5.0
$node(0) set Z_ 0.0

$node(1) set X_ 490.0
$node(1) set Y_ 285.0
$node(1) set Z_ 0.0

$node(2) set X_ 150.0
$node(2) set Y_ 240.0
$node(2) set Z_ 0.0

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns initial_node_pos $node($i) 40
}

$ns at 0.0 "$node(0) setdest 450.0 285.0 30.0"
$ns at 0.0 "$node(1) setdest 200.0 285.0 30.0"
$ns at 0.0 "$node(2) setdest 1.0 285.0 30.0"

$ns at 25.0 "$node(0) setdest 300.0 285.0 10.0"
$ns at 25.0 "$node(2) setdest 100.0 285.0 10.0"

$ns at 40.0 "$node(0) setdest 490.0 285.0 5.0"
$ns at 40.0 "$node(2) setdest 1.0 285.0 5.0"

set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $node(0) $tcp0
$ns attach-agent $node(2) $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at $val(stop) "$node($i) reset"
}
$ns at $val(stop) "$ns halt"

puts "starting sumulation.."
$ns run
