"setup.scd".loadRelative.first;
x.("/list/assets");
(
~char = "letter-"++("abcdefghijklmnopqrstuvwxyz".choose);
x.("/load", ~char);
x.("/new", "char", ~char);
x.("/speed", "char", 0.3);
x.("/scale", "char", 0.2);
x.("/action", "char", "particles", 5, 2, 192);
)
x.("/free", "*");
x.("/exit");
(
x.("/load", "leaf");
x.("/new", "aleaf", "leaf");
x.("/speed", "aleaf", 0.5);
x.("/color", "aleaf", 1,1,1);
x.("/action", "aleaf", "particles", 5, 2, 192);
)