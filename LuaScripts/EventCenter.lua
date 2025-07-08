local csEvents = CS.EventCenterUtility
local csharpEventTypes = {}
local EventCenter = {}
local listeners = {}
local nextHandleId = 0
local countTable = {}

local function getHandlerId()
  local ret = nextHandleId
  nextHandleId = nextHandleId + 1
  return ret
end

local function broadcastLua(eventId, ...)
  if eventId == nil then
    return nil
  end
  local audiance = listeners[eventId]
  if audiance ~= nil then
    for k, v in pairs(audiance) do
      v(...)
    end
  end
end

local function markCSharpEvent(eventId, hasCSharp)
  if hasCSharp then
    csharpEventTypes[eventId] = true
  else
    csharpEventTypes[eventId] = nil
  end
end

csEvents.SetMarkEventCenterChangeCallback(markCSharpEvent)

function EventCenter.AddListener(eventId, callback, tag)
  if eventId == nil then
    return nil
  end
  local handleId = getHandlerId()
  if listeners[eventId] == nil then
    listeners[eventId] = {}
  end
  listeners[eventId][handleId] = callback
  local oldCount = countTable[eventId] or 0
  if oldCount == 0 then
    csEvents.MarkHasLuaListener(eventId, true)
  end
  countTable[eventId] = oldCount + 1
  return handleId
end

function EventCenter.RemoveListener(eventId, handle)
  if eventId == nil then
    return nil
  end
  if listeners[eventId] ~= nil then
    listeners[eventId][handle] = nil
    local count = countTable[eventId]
    count = count - 1
    countTable[eventId] = count
    if count == 0 then
      csEvents.MarkHasLuaListener(eventId, false)
    end
  end
end

function EventCenter.Broadcast(eventId, ...)
  broadcastLua(eventId, ...)
  if csharpEventTypes[eventId] then
    csEvents.InverseBroadcast(eventId, ...)
  end
end

function EventCenter.IsValidEventHandle(eventId, handle)
  if eventId == nil then
    return nil
  end
  if listeners[eventId] ~= nil then
    return listeners[eventId][handle] ~= nil
  end
  return nil
end

function _EventCenter_Broadcast(eventId, ...)
  broadcastLua(eventId, ...)
end

return EventCenter
