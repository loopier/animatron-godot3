"setup.scd".loadRelative.first;
(
x.("/load/alphabet");
x.("/write", "alo");
x.("/letters/spacing", 0.25);
x.("/letters/scale", 0.25);
)