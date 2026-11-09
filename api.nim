import std/[asyncdispatch, httpclient, json, strutils, sysrand, random]
import types

type
  LegacyClient* = ref object
    baseUrl*: string
    deviceUuid*: string
    token*: string

const
  DefaultClientRelease* = "64b3cbb920d113d0df6e8532699493e762b1332c"
  DefaultUserAgent* = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

proc toHexStr(s: openArray[byte]): string =
  result = ""
  for b in s:
    result.add(toHex(int(b), 2).toLowerAscii)

proc newUUID4*(): string =
  var bytes: array[16, byte]
  if not urandom(bytes):
    randomize()
    for i in 0 .. 15:
      bytes[i] = byte(rand(255))
  bytes[6] = (bytes[6] and 0x0F) or 0x40
  bytes[8] = (bytes[8] and 0x3F) or 0x80
  result = toHexStr(bytes[0..3]) & "-" &
           toHexStr(bytes[4..5]) & "-" &
           toHexStr(bytes[6..7]) & "-" &
           toHexStr(bytes[8..9]) & "-" &
           toHexStr(bytes[10..15])

proc newLegacyClient*(config: AccountConfig): LegacyClient =
  new(result)
  result.baseUrl = if config.credentials.origin.len > 0:
                     config.credentials.origin.strip(chars = {'/'})
                   else:
                     "https://pokelegacyonline.com.br"
  result.deviceUuid = if config.credentials.deviceUuid.len > 0: config.credentials.deviceUuid else: newUUID4()
  result.token = config.credentials.token

proc createHeaders(self: LegacyClient): HttpHeaders =
  result = newHttpHeaders([
    ("User-Agent", DefaultUserAgent),
    ("Content-Type", "application/json"),
    ("Origin", self.baseUrl),
    ("Referer", self.baseUrl & "/jogar"),
    ("X-Client-Release", DefaultClientRelease),
    ("X-Poke-Aparelho", self.deviceUuid)
  ])
  if self.token.len > 0:
    result.add("Authorization", "Bearer " & self.token)

proc fetchMe*(self: LegacyClient): Future[PlayerState] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = self.baseUrl & "/api/me"
  let resp = await client.get(url)
  if resp.code == Http200:
    let body = await resp.body
    let node = parseJson(body)
    let st = node{"state"}
    if st != nil:
      result.level = st{"level"}.getInt(1)
      result.gold = st{"gold"}.getBiggestInt(0)
      result.xp = st{"xp"}.getBiggestInt(0)
      result.activeHunt = st{"activeHunt"}.getStr("auto")
  else:
    raise newException(IOError, "Fetch me HTTP: " & $resp.code)

proc login*(self: LegacyClient, email, pass: string): Future[string] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = self.baseUrl & "/api/login"
  let body = $(%*{"login": email, "password": pass})
  let resp = await client.post(url, body)
  if resp.code == Http200:
    let bodyStr = await resp.body
    let node = parseJson(bodyStr)
    result = node{"token"}.getStr("")
    self.token = result
  else:
    raise newException(IOError, "Login HTTP: " & $resp.code)
