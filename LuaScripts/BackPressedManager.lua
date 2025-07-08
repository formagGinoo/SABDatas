local BaseManager = require("Manager/Base/BaseManager")
local BackPressedManager = class("BackPressedManager", BaseManager)

function BackPressedManager:OnCreate()
  self.m_triggerTime = 0
end

function BackPressedManager:OnUpdate(dt)
  if self.m_triggerTime > 0 then
    self.m_triggerTime = self.m_triggerTime - dt
    return
  end
  if ChannelManager:IsAndroid() and U3DUtil and U3DUtil:Input_GetKeyDown("ESC") then
    if ChannelManager:IsUsingQSDK() then
      if QSDKManager:GetParentChannelType() == "23" then
        CS.DeviceUtil.KillMain()
      end
      QSDKManager:Exit()
    end
    self.m_triggerTime = 0.2
  end
end

return BackPressedManager
