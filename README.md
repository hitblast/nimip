<div align="center">

# <img src="https://raw.githubusercontent.com/nim-lang/assets/master/Art/logo-crown.png" height="30px"/> nimip <br>

### Asynchronously lookup IP addresses with this tiny, hybrid Nim application.

[![Build](https://github.com/hitblast/nimip/actions/workflows/build.yml/badge.svg)](https://github.com/hitblast/nimip/actions/workflows/build.yml)
[![Deploy to Pages](https://github.com/hitblast/nimip/actions/workflows/pages.yml/badge.svg)](https://github.com/hitblast/nimip/actions/workflows/pages.yml)

<img src="https://github.com/hitblast/nimip/blob/main/static/demo.png" alt="Demo Terminal Image">

</div>

## Table of Contents

- [Installation](#-installation)
- [Usage](#-usage)
    - [as a CLI application](#-as-a-cli-application)
    - [as a Nim library](#-as-a-nim-library)
- [Building](#-building)
- [License](#-license)

<br>

## 📦 Installation

- Install the package using [Nimble](https://github.com/nim-lang/nimble):

```bash
# Requires Nim v1.6 or greater.
$ nimble install nimip
```

- or, you can manually download the packages required from the latest release in the [Releases](https://github.com/hitblast/nimip/releases) section. The [build artifacts](https://github.com/hitblast/nimip/actions/workflows/builds.yml) are also stored for you to download as well.

<br>

## ⚡ Usage

This project is written as a [hybrid package](https://github.com/nim-lang/nimble#hybrids). Meaning that it can be used as both a Nim library and a standalone CLI application inside your terminal. The choice is yours. <br>

### ... as a CLI application

After installing the package [(see this section)](#-installation), the binary for nimip should be in your `PATH` variable depending on how you've installed it. This means, a new `mcsrvstat` command will be added to your shell environment.

```bash
# Add binary to PATH.
$ export PATH="path/to/nimip/binary:$PATH"
```

Afterwards, simply run it using the following command snippets:

```bash
# The default help command.
$ nimip --help  # -h also works

# Lookup an IP.
$ nimip 104.21.29.128
```

### ... as a Nim library

This project can also be used as a Nim library. Here's an example snippet for you to have a look at. For more information on the different procedure, try having a look at [the official documentation](https://hitblast.github.io/nimip/).

```nim
# Sample imports.
import std/[
    asyncdispatch,
    strformat
]
import nimippkg/main

# Creating a new IP reference object.
let ip = IPRef(
    address: "104.21.29.128",
    locale: Locale.EN
)

# The main procedure.
proc main() {.async.} =

    # Checks if the IP address can be queried.
    try:
        await ip.refreshData()
    except IPResponseError:
        echo "Could not query for IP address."
        quit(1)

    # If everything goes well, display the information.
    echo fmt"IP Location: {ip.latitude}, {ip.longitude}"

# Running it.
waitFor main()
```

<br>

## 🔨 Building

The default build configuration (both for development and production) for this project is kept in the [nimip.nimble](https://github.com/hitblast/nimip/blob/main/nimip.nimble) file. You can easily build binaries using the following command:

```bash
# Build using the built-in task.
$ nimble release
```

The various third-party libraries and dependancies used for developing this project are mentioned below:

- Internal dependencies:
    1. The [argparse (>= 4.0)](https://nimble.directory/pkg/argparse) library, for parsing command-line arguments for the CLI binary.
    2. The [illwill (>= 0.3)](https://nimble.directory/pkg/illwill) library, for the terminal user interface (TUI).

- External dependencies (noted in the [root .nimble](https://github.com/hitblast/nimip/blob/main/nimip.nimble) file):
    1. [OpenSSL](https://www.openssl.org) for connection and making API calls.

<br>

## 🔖 License

This project is licensed under the [MIT License](https://github.com/hitblast/nimip/blob/main/LICENSE).