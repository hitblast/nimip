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
    httpclient,
    json,
    options,
    strformat,
]


# Different type declarations related to exceptions and reference objects.
type
    IPRef* = ref object
        ## An object representing an IP address.
        ## This is the core object which can be used to interact with the application's base.

        address*: string
        locale*: Locale
        resp: Option[JsonNode]

    Locale* {.pure.} = enum
        ## An enum representing different types of locales.
        ## These can be used to modify the language in which the application receives data.

        EN = "en"
        DE = "de"
        ES = "es"
        PT_BR = "pt-BR"
        FR = "fr"
        JA = "ja"
        ZH_CN = "zh-CN"
        RU = "ru"

    IPResponseError* = object of HttpRequestError ## Raised if the code can't communicate with the API due to unstable internet connection or other circumstances.
    IPDefect* = object of IPResponseError ## Raised if the provided IP is defected or invalid.
    NotInitializedError* = object of KeyError ## Raised if the developer has not initialized the data inside the `IPRef` object with `IPRef.refreshData()`.


#[
    This section contains the internal procedures.
    These are mostly used by the internal operations of the library, but some like `refreshData()` can be used by the end developer.
]#


proc refreshData*(self: IPRef): Future[void] {.async.} =
    ## Query the API for the provided IP and load the returned data to the `IPRef` instance if successful.

    # Declaring a mutable, empty JsonNode instance for storing the response.
    var resp: JsonNode

    # Constants related to the HTTP client and the locale for the query.
    let
        client = newAsyncHttpClient()
        locale = if self.locale is void: Locale.EN else: self.locale

    # A try-except block has been used to ensure stable internet connection before execution.
    try:
        resp = parseJson(await client.getContent(
                fmt"http://ip-api.com/json/{self.address}?lang={locale}?fields=status,message,country,countryCode,region,regionName,city,zip,lat,lon,timezone,offset,isp,org,as,asname,query"))
    except OSError:
        raise IPResponseError.newException("A stable internet connection is required for IP lookups.")

    # This if-else block checks if the requested IP address returns a failed query.
    if resp["status"].getStr() == "fail":
        let
            message = resp["message"].getStr()
            query = resp["query"].getStr()

        raise IPDefect.newException(fmt"Query failed for IP {query}: '{message}'")

    else:
        self.resp = some(resp)


proc retrieveData(self: IPRef, key: string): JsonNode =
    ## Returns the value of a provided key within the initialized data. Returned in JsonNode.

    if not self.resp.isSome:
        raise NotInitializedError.newException("Initialize the IP information with IPRef.refreshData() first.")
    else:
        return self.resp.get()[key]


#[
    This sections contain the external procedures.
    These are meant to be used by the end developer to access different parts of the API response.
]#


proc country*(self: IPRef): string =
    ## The country from which the given IP address originates.
    return self.retrieveData("country").getStr()

proc countryCode*(self: IPRef): string =
    ## The two-letter country code **(ISO 3166-1 alpha-2)** of the IP address.
    return self.retrieveData("countryCode").getStr()

proc region*(self: IPRef): string =
    ## The region of the IP address.
    return self.retrieveData("region").getStr()

proc regionName*(self: IPRef): string =
    ## The name of the region of the IP address.
    return self.retrieveData("regionName").getStr()

proc city*(self: IPRef): string =
    ## The city in which the IP address is located.
    return self.retrieveData("city").getStr()

proc zip*(self: IPRef): string =
    ## The ZIP code of the IP address.
    return self.retrieveData("zip").getStr()

proc latitude*(self: IPRef): float =
    ## The coordinates **(latitude)** of the IP address.
    return self.retrieveData("lat").getFloat()

proc longitude*(self: IPRef): float =
    ## The coordinates **(longitude)** of the IP address.
    return self.retrieveData("lon").getFloat()

proc timezone*(self: IPRef): string =
    ## The timezone of the area in which the IP address is located.
    return self.retrieveData("timezone").getStr()

proc offset*(self: IPRef): int =
    ## Timezone UTC DST offset in seconds.
    return self.retrieveData("offset").getInt()

proc isp*(self: IPRef): string =
    ## The Internet Service Provider (ISP) of the IP address.
    return self.retrieveData("isp").getStr()

proc org*(self: IPRef): string =
    ## The organization handling the IP address.
    return self.retrieveData("org").getStr()

proc orgAs*(self: IPRef): string =
    ## The AS number and organization related to the IP address.
    ## Empty for IP blocks not being announced in BGP tables.
    return self.retrieveData("as").getStr()

proc asName*(self: IPRef): string =
    ## The AS name **(RIR)** of the IP address. 
    ## Empty for IP blocks not being announced in BGP tables.
    return self.retrieveData("asname").getStr()
