# # SPDX-License-Identifier: MIT


# Imports.
import std/[
    asyncdispatch,
    strformat
]
import argparse, illwill

import nimippkg/main


# Primary run() procedure for the hybrid package.
proc run*(): Future[void] {.async.} =

    # The primary command-line parser.
    var
        parser = newParser:
            help("Asynchronously fetch information on IP addresses.")
            arg("address", help = "The IP address to query for.")
        ip: IPRef

    # Attempt to parse the command-line input and handle possible exceptions.
    try:
        let opts = parser.parse()
        ip = IPRef(address: opts.address)

        await ip.refreshData()

    except ShortCircuit as err:
        if err.flag == "argparse_help":
            echo err.help
            quit(1)

    except UsageError:
        stderr.writeLine getCurrentExceptionMsg()
        quit(1)

    except OSError:
        echo "Make sure you have a stable internet connection."
        quit(1)

    except IPResponseError:
        echo "Couldn\'t query the given IP address."
        quit(1)


    # Initialize an instance of illwave and run the TUI if the code above succeeds.
    # This includes a cursor-less window, so an exit procedure is also required.
    proc exitProc() {.noconv.} =
        illwillDeinit()
        showCursor()
        quit(0)

    illwillInit(fullscreen = true)
    setControlCHook(exitProc)
    hideCursor()

    # Declare the default terminal buffer to work with.
    var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

    # A custom string representing the *somewhat* full geolocation.
    let
        addressStr = fmt"{ip.city}, {ip.regionName} ({ip.region}), {ip.country} ({ip.countryCode})"
        primaryLength = len(addressStr) + 25

    # The top panel for the terminal.
    tb.setForegroundColor(fgWhite, true)
    tb.write(2, 1, "[ Press ", fgYellow, "esc", fgWhite, "/", fgYellow, "q",
            fgWhite, " to quit. ]")
    tb.drawRect(0, 0, primaryLength, 7)
    tb.drawHorizLine(2, primaryLength - 2, 2, doubleStyle = true)

    # Display IP information onto terminal.
    tb.write(4, 4, "Address     : ", fgGreen, ip.address, fgWhite)
    tb.write(4, 5, "Timezone    : ", ip.timezone, fmt" | Offset: {ip.offset}")
    tb.write(4, 6, "Location    : ", addressStr)

    tb.drawVertLine(0, 17, 1, doubleStyle = true)
    tb.write(4, 9, "Provider    : ", ip.isp)
    tb.write(18, 10, fmt"[{ip.orgAs}]")
    tb.write(4, 12, "Zip Code    : ", ip.zip)

    tb.drawHorizLine(1, primaryLength - 2, 13)
    tb.write(4, 15, "Latitude    : ", fgCyan, fmt"{ip.latitude}", fgWhite)
    tb.write(4, 16, "Longitude   : ", fgCyan, fmt"{ip.longitude}", fgWhite)

    tb.drawHorizLine(1, primaryLength - 2, 17)
    tb.write(primaryLength, 13, fgGreen, fmt"{ip.remainingRequests}", fgWhite, " remaining requests")
    tb.write(primaryLength, 17, fgGreen, fmt"{ip.timeUntilReset}s", fgWhite, " until cache reset")


    # Finally, display the entire thing.
    # This also includes checking for keypress events in order for the user to quit the interface.
    while true:
        tb.display()

        var key = getKey()
        case key
        of Key.Escape, Key.Q: exitProc()
        else: discard

        sleep(20)


# Run the program.
when isMainModule:
    waitFor run()
