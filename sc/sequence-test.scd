a = Animatron();

a.sendMsg("/free", "*");
(
a.sendMsg("/new", "na", "numbers");
a.sendMsg("/load", "square");
a.sendMsg("/speed", "na", 2/12);
a.sendMsg("/scale", "na", 0.25);

a.sendMsg("/onframe", "na", 4, "/position/x", "na", 0.2);
a.sendMsg("/onframe", "na", 7, "/position/x", "na", 0.7);
a.sendMsg("/onframe", "na", 2, "/scale", "na", 0.4);
a.sendMsg("/onframe", "na", 8, "/scale", "na", 0.2);
a.sendMsg("/onframe", "na", 9, "/create", "na", "square");
a.sendMsg("/onframe", "na", 3, "/create", "na", "numbers");
)
a.sendMsg("/onframe/free", "na", 4, "/position/x", "na");
a.sendMsg("/onframe/free", "na", 7, "/position/x", "na");
a.sendMsg("/create", "la", "letter-a")
a.sendMsg("/list/assets");