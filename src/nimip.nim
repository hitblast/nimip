#[
    MIT License

    Copyright (c) 2023 HitBlast

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]#



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
            arg("address", help="The IP address to query for.")
        ip: IPRef
        is_error = false

    # Attempt to parse the command-line input and handle possible exceptions.
    try:
        let opts = parser.parse()
        ip = IPRef(address: opts.address)
        
        await ip.refreshData()

    except ShortCircuit as err:
        if err.flag == "argparse_help":
            echo err.help
            is_error = true

    except UsageError:
        stderr.writeLine getCurrentExceptionMsg()
        is_error = true

    except OSError:
        echo "Make sure you have a stable internet connection."
        is_error = true

    except IPResponseError:
        echo "Could not query the given IP address."
        is_error = true

    if is_error:
        quit(1)

    # Initialize an instance of illwave and run the TUI if the code above succeeds.
    # This includes a cursor-less window, so an exit procedure is also required.
    proc exitProc() {.noconv.} =
        illwillDeinit()
        showCursor()
        quit(0)

    illwillInit(fullscreen=true)
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
    tb.write(2, 1, "[ Press ", fgYellow, "esc", fgWhite, "/", fgYellow, "q", fgWhite, " to quit. ]")
    tb.drawRect(0, 0, primaryLength, 7)
    tb.drawHorizLine(2, primaryLength - 2, 2, doubleStyle=true)

    # Display IP information onto terminal.
    tb.write(2, 4,  "Address     : ", fgGreen, ip.address, fgWhite)
    tb.write(2, 5,  "Timezone    : ", ip.timezone)
    tb.write(2, 6,  "Location    : ", addressStr)
    tb.write(2, 9,  "Provider    : ", ip.isp)
    tb.write(16, 10, fmt"[{ip.orgAs}]")
    tb.write(2, 12, "Zip Code    : ", ip.zip)

    tb.drawHorizLine(2, primaryLength - 2, 13)
    tb.write(2, 15, "Latitude    : ", fgCyan, fmt"{ip.latitude}", fgWhite)
    tb.write(2, 16, "Longitude   : ", fgCyan, fmt"{ip.longitude}", fgWhite)


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