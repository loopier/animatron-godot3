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

# Installation

- Download `animatron-YOUR_PLATFORM-vX.X.X_X.zip` from the [latest release](https://github.com/loopier/animatron/releases).
- Download `animatron-assets-vX.X.X_X.zip` from the [latest release](https://github.com/loopier/animatron/releases) 

## Linux 
- Uncompress `animatron-linux-vX.X.X_X.zip`
- Uncompress `animatron-assets-vX.X.X_X.zip`
- Move the **CONTENTS** of the `animatron-assets-vX.X.X_X` directory (not the directory itself) into `animatron-linux-vX.X.X_X`. You should end up with a structure similar to this:

```
animatron-linux-vX.X.X_X/
├── animations/
├── commands/
├── config/
├── docs/
├── fonts/
├── icons/
├── scripts/
├── ...
├── Animatron.pck
├── Animatron.x86_64
├── libgdosc.so
```
Run `Animatron.x86_64` executable by double-clicking it. 
Alternatively: open a terminal and run the command:

```
$ path/to/animatron/Animatron.x86_64
```

## Windows
- Uncompress `animatron-windows-vX.X.X_X.zip`
- Uncompress `animatron-assets-vX.X.X_X.zip`
- Move the **CONTENTS** of the `animatron-assets-vX.X.X_X` folder (not the folder itself) into `animatron-windows-vX.X.X_X`. You should end up with a structure similar to this:

```
animatron-windows-vX.X.X_X/
├── animations/
├── commands/
├── config/
├── docs/
├── fonts/
├── icons/
├── scripts/
├── ...
├── Animatron.pck
├── Animatron.exe
├── libgdosc.dll
```

Run `Animatron.exe` by double-clicking it. 

If you see an error like "Can't open dynamic library ... The specified module could not be found", you may need to install the [MSVC Redistributable package](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170).

## MacOS

- Uncompress the `animatron-macos-vX.X.X.zip` file. This should unpack an `Animatron.app` bundle.
- CTRL + CLICK (or RIGHT-CLICK) on `Animatron.app` and select `Show package contents` from the popup menu.
- Navigate to `Contents/MacOS`
- Uncompress the `animatron-assets-VX.X.X.zip` file.
- Move the **CONTENTS** of the assets folder (not the folder itself) into `Animatron.app/Contents/MacOs`. You should end up with a structure similar to this:

```
Animatron.app
└── Contents
    ├── ...
    ├── MacOS
    │   └── Animatron
        ├── animations/
        ├── commands/
        ├── config/
        ├── docs/
        ├── fonts/
        ├── icons/
        ├── scripts/
```

Run `Animatron.app` by double-clicking it. The first time you run it, it may be prevented from opening by the macOS Gatekeeper. In this case, you should right-click (or Control-click) the app and select *Open*. If a security warning dialog appears, click the *Open* button to explicitly give permission to run it (only do this if you're sure you've downloaded Animatron from a reliable source). Once you've given your permission, it will remember it for future runs.

If `Animatron.app` fails to run even after following the above steps, it may have the "quarantine" extended attribute set. This can happen if the program you used to download it (e.g. Safari, Chrome, Telegram) is not trusted. If you are sure it's from a safe place, you may remove the quarantine flag by opening the *Terminal* app and changing to the directory where you have `Animatron.app`. From that directory, run the following command:

```
$ cd ~/Downloads   # change to wherever you have the app installed
$ xattr -d -r com.apple.quarantine Animatron.app
```

# Compile from source

Clone or download this repository.

1. Install [Godot](https://godotengine.org/download) (currently Animatron only works with Godot v3.X).

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

See also the [OSC Reference](docs/Reference.md.html) for a list of commands and their usage.

# Remote

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

# License

Animatron is Copyright &copy; 2021 by Glen Fraser, Roger Pibernat and
contributors.

Animatron is distributed under the terms of the GNU Public license version 3 (or
later). See [LICENSE](LICENSE) for all the details.

