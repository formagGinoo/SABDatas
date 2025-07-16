local BaseActivity = require("Base/BaseActivity")
local LoginSendItemActivity = class("LoginSendItemActivity", BaseActivity)

function LoginSendItemActivity.getActivityType(_)
  return MTTD.ActivityType_LoginSendItem
end

function LoginSendItemActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgLoginSendItem
end

function LoginSendItemActivity.getStatusProto(_)
  return MTTDProto.CmdActLoginSendItem_Status
end

function LoginSendItemActivity:OnResetStatusData()
end

function LoginSendItemActivity:checkShowRed()
  if not self:checkCondition() then
    return false
  end
  return self.m_stStatusData.iTakeNum == 0
end

function LoginSendItemActivity:isAllTaskFinished()
  return not self:checkShowRed()
end

function LoginSendItemActivity:checkCondition(bIsShow)
  if not LoginSendItemActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if bIsShow and self.m_stStatusData.iTakeNum > 0 then
    return false
  end
  return true
end

function LoginSendItemActivity:RequestLoginReward()
  if self:checkShowRed() then
    local reqMsg = MTTDProto.Cmd_Act_LoginSendItem_TakeReward_CS()
    reqMsg.iActivityId = self:getID()
    RPCS():Act_LoginSendItem_TakeReward(reqMsg, function(sc, msg)
      self:broadcastEvent("eGameEvent_Activity_LoginSendItem", {
        iActivityID = self:getID(),
        vReward = sc.vReward
      })
    end)
  end
end

function LoginSendItemActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_LoginSendItem
end

return LoginSendItemActivity
