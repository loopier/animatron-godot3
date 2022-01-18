(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
"setup.scd".loadRelative.first;
)

n.sendMsg("/help");
n.sendMsg("/list/assets");
n.sendMsg("/load", "dot-p-01");
n.sendMsg("/load", "dot-p-02");
n.sendMsg("/load", "dot-p-09");
n.sendMsg("/load", "dot-p-11");
n.sendMsg("/create", "dot", "dot-p-01");
n.sendMsg("/create", "dat", "dot-p-09");
n.sendMsg("/create", "dot", "dot-p-11");
n.sendMsg("/create", "dat", "dot-p-01");
n.sendMsg("/speed", "dot", 12/30);
n.sendMsg("/speed", "dat", 10/30);
n.sendMsg("/speed", "dat", 0.50);
n.sendMsg("/scale", "dot", 4.0);
n.sendMsg("/scale", "dat", 3.0);
n.sendMsg("/color", "dot", 0.5,0.1,0);
n.sendMsg("/stop", "dot");
n.sendMsg("/play", "dot");
n.sendMsg("/frame", "dot", 0);
n.sendMsg("/position", "dot", 0.25, 0.5, 6);
n.sendMsg("/position", "dat", 0.5, 0.6);
n.sendMsg("/fliph", "dot");