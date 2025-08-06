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
  return self.m_versionContext:IsUsingQSDK()
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

function ChannelManager:IsWegameChannel()
  return self.m_versionContext:IsWegameChannel()
end

function ChannelManager:IsTapTapChannel()
  return self.m_versionContext:IsTapTapChannel()
end

function ChannelManager:IsQSDKWindowsChannel()
  return self.m_versionContext:IsQSDKWindowsChannel()
end

function ChannelManager:IsExeVerBig(targetVer)
  local strBigVer = CS.VersionUtil.GetBigVer(self.m_versionContext.ClientStreamVersion)
  return CS.VersionUtil.CompareBigVerPart(strBigVer, targetVer)
end

return ChannelManager
