local BaseManager = require("Manager/Base/BaseManager")
local ChannelManager = class("ChannelManager", BaseManager)

function ChannelManager:OnCreate()
  self.m_versionContext = CS.VersionContext.GetContext()
end

function ChannelManager:IsChinaChannel()
  return self.m_versionContext:IsChinaChannel()
end

function ChannelManager:IsEUChannel()
  return self.m_versionContext:IsEUChannel()
end

function ChannelManager:IsAPChannel()
  return self.m_versionContext:IsAPChannel()
end

function ChannelManager:IsUsingQSDK()
  return not self.m_versionContext:IsUsingQSDK() and self:IsWindows() and self:IsChinaChannel()
end

function ChannelManager:GetContext()
  return self.m_versionContext
end

function ChannelManager:IsWindows()
  return self.m_versionContext:IsWindows()
end

function ChannelManager:IsIOS()
  return self.m_versionContext:IsIOS()
end

function ChannelManager:IsAndroid()
  return self.m_versionContext:IsAndroid()
end

function ChannelManager:IsUSChannel()
  return self.m_versionContext:IsUSChannel()
end

function ChannelManager:IsDMMChannel()
  return self.m_versionContext:IsDMMChannel()
end

return ChannelManager
