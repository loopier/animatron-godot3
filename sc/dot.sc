(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
"setup.scd".loadRelative.first;
)

n.sendMsg("/help");
n.sendMsg("/list/assets");
n.sendMsg("/load", "dot-p-front");
n.sendMsg("/load", "dot-p-back");
n.sendMsg("/load", "dot-p-speak");
n.sendMsg("/load", "dot-p-speak-front");
n.sendMsg("/load", "dot-p-speak-right");
n.sendMsg("/load", "dot-p-01");
n.sendMsg("/load", "dot-p-02");
n.sendMsg("/load", "dot-p-03");
n.sendMsg("/load", "dot-p-04");
n.sendMsg("/load", "dot-p-07");
n.sendMsg("/load", "dot-p-08");
n.sendMsg("/load", "dot-p-09");
n.sendMsg("/load", "dot-p-10");
n.sendMsg("/load", "dot-p-11");
n.sendMsg("/load", "dot-p-12");
n.sendMsg("/load", "dot-p-13");
n.sendMsg("/load", "dot-p-14");
n.sendMsg("/load", "dot-p-15");
n.sendMsg("/load", "dot-p-16");
n.sendMsg("/load", "dot-p-17");
n.sendMsg("/load", "dot-p-18");
n.sendMsg("/load", "dot-p-20");
n.sendMsg("/create", "dot", "dot-p-01");
n.sendMsg("/create", "dot", "dot-p-02");
n.sendMsg("/create", "dot", "dot-p-03");
n.sendMsg("/create", "dot", "dot-p-04");
n.sendMsg("/create", "dot", "dot-p-07");
n.sendMsg("/create", "dot", "dot-p-08");
n.sendMsg("/create", "dot", "dot-p-10");
n.sendMsg("/create", "dot", "dot-p-11");
n.sendMsg("/create", "dot", "dot-p-12");
n.sendMsg("/create", "dot", "dot-p-13");
n.sendMsg("/create", "dot", "dot-p-14");
n.sendMsg("/create", "dot", "dot-p-15");
n.sendMsg("/create", "dot", "dot-p-16");
n.sendMsg("/create", "dot", "dot-p-17");
n.sendMsg("/create", "dot", "dot-p-18");
n.sendMsg("/create", "dot", "dot-p-20");
n.sendMsg("/create", "dot", "dot-p-speak-front");
(
n.sendMsg("/create", "dot", "dot-p-02");
n.sendMsg("/create", "dot", "dot-p-04");
n.sendMsg("/speed", "dot", 12/30);
n.sendMsg("/speed", "dot", 0.40);
n.sendMsg("/scale", "dot", 4.0);
)

n.sendMsg("/color", "dot", 0.5,0.1,0);
n.sendMsg("/stop", "dot");
n.sendMsg("/play", "dot");
n.sendMsg("/frame", "dot", 0);
n.sendMsg("/position", "dot", 0.25, 0.5, 6);
n.sendMsg("/position", "dat", 0.5, 0.6);
n.sendMsg("/fliph", "dot");