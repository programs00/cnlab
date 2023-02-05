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
set val(nn) 2
set val(stop) 20.0
set val(rp) DSDV


set ns [new Simulator]

set tracefd [open pgm6.tr w]
$ns trace-all $tracefd

set namtrace [open pgm6.nam w]
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

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns initial_node_pos $node($i) 40
}
$ns at 1.1 "$node(0) setdest 310.0 10.0 20.0"
$ns at 1.1 "$node(1) setdest 10.0 310.0 20.0"

set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $node(0) $tcp0
$ns attach-agent $node(5) $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 18.0 "$ftp0 stop"

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at $val(stop) "$node($i) reset"
}
$ns at $val(stop) "$ns halt"

puts "starting sumulation.."
$ns run
