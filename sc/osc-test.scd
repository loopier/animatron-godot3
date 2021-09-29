n = NetAddr("localhost", 56101);
n.sendMsg("/stop", "runner")
n.sendMsg("/play", "runner")
n.sendMsg("/play", "fox")
n.sendMsg("/stop", "fox")
n.sendMsg("/stop", "frog")
n.sendMsg("/play", "frog")
n.sendMsg("/invalid", "frog")