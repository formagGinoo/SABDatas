local BaseManager = require("Manager/Base/BaseManager")
local DeeplinkManager = class("DeeplinkManager", BaseManager)

function DeeplinkManager:OnCreate()
  self:Initialize()
end

function DeeplinkManager:OnUpdate(dt)
end

function DeeplinkManager:Initialize()
  self:Register()
end

function DeeplinkManager:OnInitNetwork()
  self:ParseDeepLinkParams(CS.UnityEngine.Application.absoluteURL)
end

function DeeplinkManager:OnDestroy()
end

function DeeplinkManager:Register()
  CS.UnityEngine.Application.deepLinkActivated("+", handler(self, self.OnDeepLinkActivated))
end

function DeeplinkManager:ParseDeepLinkParams(sUrl)
  if sUrl == nil or sUrl == "" then
    return nil
  end
  local params = {}
  local parts = string.split(sUrl, "?")
  if 1 < #parts then
    local query = parts[2]
    local pairs = string.split(query, "&")
    for _, pair in ipairs(pairs) do
      local keyValue = string.split(pair, "=")
      if #keyValue == 2 then
        params[keyValue[1]] = keyValue[2]
      end
    end
  end
  if params.jumpId ~= "" then
    PushFaceManager:PushCustomFacePanel(params.jumpId, params)
  end
end

function DeeplinkManager:OnDeepLinkActivated(sUrl)
  self:ParseDeepLinkParams(sUrl)
  self:broadcastEvent("eGameEvent_OnDeepLinkActivated")
end

return DeeplinkManager
