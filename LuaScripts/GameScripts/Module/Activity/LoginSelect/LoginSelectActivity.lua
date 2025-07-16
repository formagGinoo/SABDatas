local BaseActivity = require("Base/BaseActivity")
local LoginSelectActivity = class("LoginSelectActivity", BaseActivity)

function LoginSelectActivity.getActivityType(_)
  return MTTD.ActivityType_LoginSelect
end

function LoginSelectActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgLoginSelect
end

function LoginSelectActivity.getStatusProto(_)
  return MTTDProto.CmdActLoginSelect_Status
end

function LoginSelectActivity:RequestGetReward(iIndex)
  local reqMsg = MTTDProto.Cmd_Act_LoginSelect_SelectReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iSelectIndex = iIndex
  RPCS():Act_LoginSelect_SelectReward(reqMsg, handler(self, self.OnRequestGetRewardSC))
end

function LoginSelectActivity:OnRequestGetRewardSC(sc, msg)
  self.m_stStatusData.iSelectIndex = sc.iSelectIndex
  local vReward = sc.vReward
  utils.popUpRewardUI(vReward)
  self:broadcastEvent("eGameEvent_Activity_LoginSelectReward")
end

function LoginSelectActivity:OnResetSdpConfig()
  self.m_vInfoList = {}
  if self.m_stSdpConfig then
    for iIndex, stInfo in pairs(self.m_stSdpConfig.mSelectReward) do
      local vReward = string.split(stInfo.sReward, ";")
      local heroID
      for k, v in ipairs(vReward) do
        local itemId = tonumber(string.split(v, ",")[1])
        if ResourceUtil:GetResourceTypeById(itemId) == ResourceUtil.RESOURCE_TYPE.HEROES then
          heroID = itemId
          break
        end
      end
      stInfo.heroID = heroID
      self.m_vInfoList[checknumber(iIndex)] = stInfo
    end
  end
  self:broadcastEvent("eGameEvent_Activity_LoginSelectUpdate")
end

function LoginSelectActivity:GetInfoList()
  return self.m_vInfoList
end

function LoginSelectActivity:OnResetStatusData()
end

function LoginSelectActivity:checkCondition()
  if not LoginSelectActivity.super.checkCondition(self) then
    return false
  end
  return true
end

function LoginSelectActivity:isInActivityTime()
  if self.m_stStatusData.iBeginTime == 0 or self.m_stStatusData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stStatusData.iBeginTime, self.m_stStatusData.iEndTime)
end

function LoginSelectActivity:getActivityRemainTime()
  if self.m_stStatusData.iBeginTime == nil or self.m_stStatusData.iEndTime == nil then
    return 0
  end
  local iServerTime = TimeUtil:GetServerTimeS()
  local iRemainTime = self.m_stStatusData.iEndTime - iServerTime
  if iRemainTime < 0 then
    iRemainTime = 0
  end
  return math.floor(iRemainTime)
end

function LoginSelectActivity:checkShowRed()
  local iCurLoginDay = self.m_stStatusData.iLoginNum or 0
  local iNeedLoginDay = self:getConfigParamIntValue("iNeedLogin") or 0
  return self.m_stStatusData.iSelectIndex == 0 and iCurLoginDay >= iNeedLoginDay
end

return LoginSelectActivity
