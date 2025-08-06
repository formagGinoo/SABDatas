local BaseManager = require("Manager/Base/BaseManager")
local DirtyCharManager = class("DirtyCharManager", BaseManager)
local gmatch = string.gfind or string.gmatch

function DirtyCharManager:OnCreate()
  self.m_mDirtyWordChat = {}
end

function DirtyCharManager:OnInitNetwork()
end

function DirtyCharManager:IsDigit(str)
  local isdigit = string.isdigit(str)
  return isdigit
end

return DirtyCharManager
