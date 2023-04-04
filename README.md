# Animatron

A tool for real-time visual poetry.

## What is it?

**Animatron** is an experimental environment (very much "work in
progress") that enables creation of "visual poetry," in the form of
animations and images, created in real-time through live coding.  It
implemented using the open-source [Godot
engine](https://godotengine.org/), and communicates with any "client"
application or live coding language &mdash; such as
[SuperCollider](https://supercollider.github.io/) &mdash; via the
network, using the Open Sound Control (OSC) protocol.

## Installation

- Download **both** the [latest release](https://github.com/loopier/animatron/releases) for your platform **and the animatron-assets-vX.X.X_X.zip file**.
- Uncompress both.
- Move the **contents** of the executable into the uncompressed assets folder. You should end up with a structure similar to this:

```
animatron/
├── animations/
├── commands/
├── config/
├── docs/
├── fonts/
├── icons/
├── scripts/
├── Animatron.pck
# linux
├── Animatron.x86_64
├── libgdosc.so
# windows
├── Animatron.exe
├── libgdosc.dll
```

Run either the `.x86_64` file if you're on Linux, or the `.exe` if you're on Windows.

To start the tutorial, write `/tutorial` on the editor and press `CTRL + ENTER`.

## Compile from source

Clone or download this repository.

1. Install [Godot](https://godotengine.org/download) (normally the
   latest version, e.g. v3.3.4 or v3.4).

1. Clone or download [this
   repository](https://github.com/loopier/animatron).

1. Copy some image files (`.jpg` or `.png`) into the `animations/`
   directory in the repository. These will be available to use as
   animation sources.

1. Run Godot, choose *Scan* from the Project Manager and navigate to
   the location of the downloaded/cloned `animatron` project. Click
   "Select Current Folder," then open the Animatron project from the
   list of available projects.

1. Run it using the *Play* button in the upper-right corner of the
   Godot window (on Windows, press F5).

1. Using an external program (such as the
   [SuperCollider](https://supercollider.github.io/) language), send
   OSC messages to the program, by default on port 56101). You can
   find some examples in [osc-test.scd](sc/osc-test.scd).

Refer to the [OSC command reference](docs/Reference.md.html) &mdash;
note that this file can be opened on your local machine in any web
browser and it will appear correctly formatted.

# Usage

The best way to learn how it works is running through the tutorial. Type `/tutorial` and press `CTRL + ENTER`. Follow the instructions and you'll get the hang of it pretty quickly.

## Remote

Animatron can also be used remotely via OSC messages. The commands are the same. The exact syntax of the message depends on the software you're using to send the messages.

But first, we need to set up the communication system. Animatron is listening for OSC messages on port `56101`. Following is an example for SuperCollider running on the same machine as Animatron.

```
a = NetAdress("localhost", 56101);
a.sendMsg("/bg", 0, 0, 0.2);
a.sendMsg("/new", "sq", "square");
a.sendMsg("/color", "sq", 1,0,0);
// ... etc
```

To get replies, an OSC listener needs to be set up on the client side:

```
a = NetAdress("localhost", 56101);

OSCdef(\listActorsReply, { arg msg;
    "Actors: %".format(msg[1..]).postln;
    oscReply = msg.debug("oscdef");
}, "/list/actors/reply");
OSCdef(\listAnimsReply, { arg msg;
    "Available animations:\n\t%".format(join(msg[1..], "\n\t")).postln;
}, "/list/anims/reply");
OSCdef(\listAssetsReply, { arg msg;
    "Available assets:\n\t%".format(join(msg[1..], "\n\t")).postln;
}, "/list/assets/reply");
OSCdef(\errorReply, { arg msg;
    "Error: %".format(msg[1]).postln;
    oscReply = msg;
}, "/error/reply");
OSCdef(\statusReply, { arg msg;
    "Status: %".format(msg[1]).postln;
}, "/status/reply");
```

If you're going to use SuperCollider often, you can copy the `Animatron/` folder you'll find in the `sc/` directory to your SuperCollider `Extensions/` folder. When creating an instance, a listener for the replies is automatically set up:

```
a = Animatron();
a.sendMsg("/list/assets"); // see the post window
```

## License

Animatron is Copyright &copy; 2021 by Glen Fraser, Roger Pibernat and
contributors.

Animatron is distributed under the terms of the GNU Public license version 3 (or
later). See [LICENSE](LICENSE) for all the details.

