# CobolCraft

[![Build](https://github.com/meyfa/CobolCraft/actions/workflows/build.yml/badge.svg)](https://github.com/meyfa/CobolCraft/actions/workflows/build.yml)
[![Test](https://github.com/meyfa/CobolCraft/actions/workflows/test.yml/badge.svg)](https://github.com/meyfa/CobolCraft/actions/workflows/test.yml)

A Minecraft server written in COBOL. It supports Minecraft 1.21.4 (the latest version at time of writing).

## Features

The following features are already working:

- [X] infinite terrain generation and dynamic chunk loading
- [X] persisting world and player data to disk
- [X] support for Minecraft's file formats (import existing worlds)
- [X] multiplayer (configurable number of concurrent players)
- [X] ping/server status (i.e., show as online in the server list)
- [X] breaking and placing blocks
- [X] block interaction (right-clicking, e.g., to open doors)
- [X] player inventory (limited to creative mode)
- [X] chat
- [X] commands (in-game and via an interactive console)
- [X] configuration via server.properties
- [X] whitelist (persistent; stored in whitelist.json)

Note that blocks with multiple states, orientations, or interactive blocks require large amounts of specialized code
to make them behave properly, which is way beyond the scope of this project.
Some are supported, however:

- torches (all variants)
- slabs (all variants)
- stairs (non-connecting)
- rotated pillars, such as logs or basalt
- buttons (non-interactive)
- doors (including interaction)
- trapdoors (including interaction)
- beds

## How-to

CobolCraft was developed using GnuCOBOL and is meant to be run on Linux.
Support for other operating systems such as Windows has not been tested.
However, it is possible to use Docker for a platform-independent deployment.

To deploy on Linux, make sure all prerequisites are installed:

* GnuCOBOL 3.1.2 or later (e.g., from the `gnucobol` package on Debian/Ubuntu)
    - 3.2 or later is highly recommended for performance reasons - check `cobc -version`
* `make`
* `gcc`, `g++`
* `zlib` (e.g. `zlib1g-dev` on Debian/Ubuntu)
* `curl` (needed to download the official server .jar)
* Java 21 or later (needed to extract data from the server .jar)

Run the following commands to build and run CobolCraft:

```sh
# GnuCOBOL 3.2 or later
make -j$(nproc) GCVERSION=32

# GnuCOBOL 3.1
make -j$(nproc)

# start the server
make run
```

Or, run CobolCraft using Docker:

```sh
# pull the image from Docker Hub
docker pull meyfa/cobolcraft:latest

# or build it yourself
git clone https://github.com/meyfa/CobolCraft.git cobolcraft && cd cobolcraft
docker build --tag meyfa/cobolcraft .

docker run --rm --interactive --tty \
     --publish 25565:25565 \
     --volume "$(pwd)/server.properties:/app/server.properties" \
     --volume "$(pwd)/whitelist.json:/app/whitelist.json" \
     --volume "$(pwd)/save:/app/save" \
    meyfa/cobolcraft
```

To configure the server, edit the `server.properties` file.
This file is generated automatically on first run with default values for all supported options:

* `server-port` (default: 25565)
* `white-list` (default: false)
* `motd` (default: "CobolCraft")
* `max-players` (default: 10; maximum: 100)

Note: By default, the server is only accessible via localhost (i.e., only on your own system via `localhost:25565`).
To make it accessible from the outside (your local network, via VPN, port forwarding, on a rented server, ...), you
can start the Docker container like this:

```sh
docker run --rm -it -p 0.0.0.0:25565:25565 meyfa/cobolcraft
```

## Why?

Well, there are quite a lot of rumors and stigma surrounding COBOL.
This intrigued me to find out more about this language, which is best done with some sort of project, in my opinion.
You heard right - I had no prior COBOL experience going into this.

Writing a Minecraft server was perhaps not the best idea for a first COBOL project, since COBOL is intended for
business applications, not low-level data manipulation (bits and bytes) which the Minecraft protocol needs lots of.
However, quitting before having a working prototype was not on the table! A lot of this functionality had to be
implemented completely from scratch, but with some clever programming, data encoding and decoding is not just fully
working, but also quite performant.

If you too have never written COBOL before but are interested in CobolCraft, I recommend reading the GnuCOBOL
Programmer's Guide:
https://gnucobol.sourceforge.io/HTML/gnucobpg.html

To learn more about the Minecraft protocol, you can refer to the wiki.vg documentation:
https://minecraft.wiki/w/Minecraft_Wiki:Projects/wiki.vg_merge/Protocol
In some cases, it may be helpful to look at real server traffic to better understand the flow of information.

## Program Overview

This section provides a high-level overview of CobolCraft from a software design viewpoint.

### Source Components

The program entrypoint is `main.cob`.
The remaining COBOL sources are located in the `src/` directory, including `src/server.cob`, which contains the bulk
of CobolCraft.

Only functionality that is not feasible in COBOL is implemented in C++, such as low-level TCP socket management,
precise timing, or process signal handling, and is located in the `cpp/` directory.

All sources (COBOL and C++) are compiled into a single `cobolcraft` binary.

### Packet Blobs

CobolCraft makes use of network data captured from an instance of the official server application via Wireshark.
This data is located in the `blobs/` directory and is decoded at run-time.

### Data Extraction

The official Minecraft (Java Edition) server and client applications contain large amounts of data such as:

* block and item types
* entity types
* biomes

Fortunately, the freely available server .jar offers a command-line interface for extracting this data as JSON.
The CobolCraft `Makefile` has a target that downloads the .jar and extracts the JSON data from it.
The JSON files are evaluated at runtime using a custom-built generic JSON parser, such that CobolCraft can
inter-operate successfully with the Minecraft client without distributing potentially copyrighted material.

## Legal Notices

This project is licensed under the MIT License; see LICENSE for further information.

"Minecraft" is a trademark of Mojang Synergies AB.
CobolCraft is neither affiliated with nor endorsed by Mojang.
