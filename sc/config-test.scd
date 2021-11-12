(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
"setup.scd".loadRelative.first;
)

n.sendMsg("/list/assets")
n.sendMsg("/load/config", "res://config/config.osc");
n.sendMsg("/config");
n.sendMsg("/assets/path"); // report the current path
n.sendMsg("/assets/path", "myanimations/");
n.sendMsg("/assets/path", "animations/");
n.sendMsg("/assets/path", "res://animations/"); // should do same as previous line
n.sendMsg("/window/screen", 1);
n.sendMsg("/window/position", 1500, 200);
n.sendMsg("/window/center"); // works only on display 1 (?)
n.sendMsg("/window/fullscreen", 1);
n.sendMsg("/window/fullscreen", 0);
n.sendMsg("/window/size", 640, -1);
n.sendMsg("/window/top");
n.sendMsg("/window/top", false);
n.sendMsg("/window/top", true);
n.sendMsg("/window/top", 0);
n.sendMsg("/window/top", 1);
