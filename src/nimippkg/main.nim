# Imports.
import std/[
    asyncdispatch,
    httpclient,
    json,
    options,
    strformat,
]


# Types.
type 
    IPRef* = ref object
        address*: string
        locale*: Locale
        data: Option[JsonNode]

    Locale* {.pure.} = enum
        EN = "en"
        DE = "de"
        ES = "es"
        PT_BR = "pt-BR"
        FR = "fr"
        JA = "ja"
        ZH_CN = "zh-CN"
        RU = "ru"

    IPResponseError* = object of HttpRequestError
    NotInitializedError* = object of KeyError


# Primarily internal procedures.
proc refreshData*(self: IPRef): Future[void] {.async.} =
    let 
        client = newAsyncHttpClient()
        locale = if self.locale is void: Locale.EN else: self.locale
        resp = parseJson(await client.getContent(fmt"http://ip-api.com/json/{self.address}?lang={locale}"))

    if resp["status"].getStr() == "fail":
        let 
            message = resp["message"].getStr()
            query = resp["query"].getStr()

        raise IPResponseError.newException(fmt"Query failed for IP {query}: '{message}'")

    else:
        self.data = some(resp)


proc retrieveData(self: IPRef, key: string): JsonNode =
    if not self.data.isSome:
        raise NotInitializedError.newException("Initialize the IP information with IPRef.refreshData() first.")
    else:
        return self.data.get()[key]


# Primarily external procedures.
proc country*(self: IPRef): string = 
    return self.retrieveData("country").getStr()

proc countryCode*(self: IPRef): string = 
    return self.retrieveData("countryCode").getStr()

proc region*(self: IPRef): string =
    return self.retrieveData("region").getStr()

proc regionName*(self: IPRef): string =
    return self.retrieveData("regionName").getStr()

proc city*(self: IPRef): string =
    return self.retrieveData("city").getStr()

proc zip*(self: IPRef): string =
    return self.retrieveData("zip").getStr()

proc latitude*(self: IPRef): float = 
    return self.retrieveData("lat").getFloat()

proc longitude*(self: IPRef): float =
    return self.retrieveData("lon").getFloat()

proc timezone*(self: IPRef): string =
    return self.retrieveData("timezone").getStr()

proc isp*(self: IPRef): string =
    return self.retrieveData("isp").getStr()

proc org*(self: IPRef): string =
    return self.retrieveData("org").getStr()

proc orgAs*(self: IPRef): string =
    return self.retrieveData("as").getStr()