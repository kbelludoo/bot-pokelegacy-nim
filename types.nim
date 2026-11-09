import std/json

type
  GameCredentials* = object
    email*: string
    username*: string
    password*: string
    token*: string
    deviceUuid*: string
    origin*: string

  GameSettings* = object
    huntTarget*: string
    autoHunt*: bool
    autoCatch*: bool
    autoSell*: bool
    autoDaily*: bool
    autoHeal*: bool
    focusPokedex*: bool
    exploitWeakness*: bool
    preferredBall*: string
    minHpPercent*: int
    saveIntervalSec*: int

  AccountConfig* = object
    id*: string
    name*: string
    enabled*: bool
    credentials*: GameCredentials
    settings*: GameSettings

  PlayerState* = object
    level*: int
    gold*: int64
    xp*: int64
    activeHunt*: string

proc parseAccountConfig*(n: JsonNode): AccountConfig =
  result.id = n{"id"}.getStr("")
  result.name = n{"name"}.getStr(result.id)
  result.enabled = n{"enabled"}.getBool(true)

  if n.hasKey("credentials"):
    let c = n["credentials"]
    result.credentials.email = c{"email"}.getStr("")
    result.credentials.username = c{"username"}.getStr("")
    result.credentials.password = c{"password"}.getStr("")
    result.credentials.token = c{"token"}.getStr("")
    result.credentials.deviceUuid = c{"deviceId"}.getStr(c{"deviceUuid"}.getStr(""))
    result.credentials.origin = c{"origin"}.getStr("https://pokelegacyonline.com.br")
  else:
    result.credentials.email = n{"email"}.getStr("")
    result.credentials.username = n{"username"}.getStr("")
    result.credentials.password = n{"password"}.getStr("")
    result.credentials.token = n{"token"}.getStr("")
    result.credentials.deviceUuid = n{"deviceId"}.getStr("")
    result.credentials.origin = n{"origin"}.getStr("https://pokelegacyonline.com.br")

  if n.hasKey("settings"):
    let s = n["settings"]
    result.settings.huntTarget = s{"huntTarget"}.getStr("auto")
    result.settings.autoHunt = s{"autoHunt"}.getBool(true)
    result.settings.autoCatch = s{"autoCatch"}.getBool(false)
    result.settings.autoSell = s{"autoSell"}.getBool(true)
    result.settings.autoDaily = s{"autoDaily"}.getBool(true)
    result.settings.autoHeal = s{"autoHeal"}.getBool(true)
    result.settings.focusPokedex = s{"focusPokedex"}.getBool(false)
    result.settings.exploitWeakness = s{"exploitWeakness"}.getBool(true)
    result.settings.preferredBall = s{"preferredBall"}.getStr("pokeball")
    result.settings.minHpPercent = s{"minHpPercent"}.getInt(25)
    result.settings.saveIntervalSec = s{"saveIntervalSec"}.getInt(30)
  else:
    result.settings.huntTarget = "auto"
    result.settings.autoHunt = true
    result.settings.autoSell = true
    result.settings.autoHeal = true
    result.settings.autoDaily = true
    result.settings.minHpPercent = 25
    result.settings.saveIntervalSec = 30
