local BaseActivity = require("Base/BaseActivity")
local OperationActivityGuideActivity = class("OperationActivityGuideActivity", BaseActivity)
local ShowType = {
  UpActivity = 1,
  UpSubActivity = 2,
  GMActivity = 3,
  GachaType = 4,
  MainChapter = 5,
  FourteenUpTask = 6,
  AllianceRaid = 7,
  Night = 8,
  TrialActivity = 9
}

function OperationActivityGuideActivity.getActivityType(_)
  return MTTD.ActivityType_OperationActivityGuide
end

function OperationActivityGuideActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgOperationActivityGuide
end

function OperationActivityGuideActivity.getStatusProto(_)
  return MTTDProto.CmdActOperationActivityGuide_Status
end

function OperationActivityGuideActivity:OnResetSdpConfig()
  self.m_clientCfg = {}
  if self.m_stSdpConfig then
    self.m_clientCfg = self.m_stSdpConfig.stClientCfg
  end
end

function OperationActivityGuideActivity:GetActClientCfg()
  return self.m_stSdpConfig.stClientCfg
end

function OperationActivityGuideActivity:checkCondition()
  if not OperationActivityGuideActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  return true
end

function OperationActivityGuideActivity:GetActJumpList()
  if self.m_clientCfg then
    return self.m_clientCfg.mActivityCfg
  end
end

function OperationActivityGuideActivity:DealJump(data, fc)
  if data.iActivityType == ShowType.UpSubActivity then
    local params = {
      main_id = data.sActivityParam[1],
      sub_id = data.sActivityParam[2]
    }
    HeroActivityManager:GotoHeroActivity(params)
  elseif data.iActivityType == ShowType.UpActivity then
    local params = {
      main_id = data.sActivityParam[1],
      sub_id = data.sActivityParam[2],
      isPlayTimeLine = true
    }
    HeroActivityManager:GotoHeroActivity(params)
    if data.sActivityParam[1] then
      local reportStr = "click_" .. tostring(data.sActivityParam[1]) .. "_1"
      local params = {Event_id = reportStr}
      ReportManager:ReportMessage(CS.ReportDataDefines.Client_click_event, params)
      LocalDataManager:SetIntSimple("HeroActHallEntry_Red_Point" .. data.sActivityParam[1], TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()), true)
    end
  elseif data.iActivityType == ShowType.FourteenUpTask then
    if data.sActivityParam[1] then
      QuickOpenFuncUtil:JumpUpActivity14DayTaskForm(data.sActivityParam[1])
    end
  elseif data.iActivityType == ShowType.GMActivity then
    if data.sActivityParam[1] then
      local act = ActivityManager:GetActivityByType(data.sActivityParam[1])
      if act and data.vJumpId[1] then
        QuickOpenFuncUtil:OpenFunc(data.vJumpId[1], {
          activityId = act:getID()
        })
      else
        log.error("Guide Activity Data is NULL ActType == " .. tostring(data.sActivityParam[1]))
      end
    end
  elseif data.iActivityType == ShowType.TrialActivity then
    local activity = ActivityManager:GetActivityListByType(MTTD.ActivityType_Train)
    if activity then
      for i, stActivity in pairs(activity) do
        if stActivity and stActivity:checkCondition() then
          local commonCfgData = stActivity:GetTrianCommonData()
          if data.sActivityParam[1] and commonCfgData.iStoreId and data.sActivityParam[1] == commonCfgData.iStoreId then
            StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW, {
              iStoreId = data.sActivityParam[1]
            })
          else
            StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW)
            log.error("Guide Jump Mall StoreId is error")
          end
        end
      end
    end
  else
    QuickOpenFuncUtil:OpenFunc(data.vJumpId[1])
  end
  LocalDataManager:SetIntSimple("GuideActJump" .. self:getID() .. data.Index, 1)
end

function OperationActivityGuideActivity:DealHallRed()
  for index, shopCfg in pairs(self.m_clientCfg.mActivityCfg) do
    local isShowRed = self:DealRedWithAct(index)
    if isShowRed then
      return true
    end
  end
  return false
end

function OperationActivityGuideActivity:DealRedWithAct(index, fc)
  local actJumpData = self.m_clientCfg.mActivityCfg[index]
  local isRed = false
  if actJumpData then
    local isOpen = TimeUtil:IsInTime(actJumpData.iOpenTime, actJumpData.iCloseTime)
    if not isOpen then
      return false
    end
    if actJumpData.iPos == 1 and LocalDataManager:GetIntSimple("GuideActJump" .. self:getID() .. index, 0) == 0 then
      return true, true
    end
    if actJumpData.iActivityType == ShowType.UpActivity then
      local param = {
        config = {
          m_ActivityID = actJumpData.sActivityParam[1]
        }
      }
      isRed = 0 < HeroActivityManager:HeroActHallEntryHaveRedDot(param)
    elseif actJumpData.iActivityType == ShowType.GMActivity then
      if actJumpData.sActivityParam[1] then
        local act = ActivityManager:GetActivityByType(actJumpData.sActivityParam[1])
        if act and act.checkShowRed then
          isRed = act:checkShowRed()
        end
      end
    elseif actJumpData.iActivityType == ShowType.GachaType then
      if actJumpData.sActivityParam[1] then
        isRed = GachaManager:CheckGachaPoolHaveRedDotById(actJumpData.sActivityParam[1])
      end
    elseif actJumpData.iActivityType == ShowType.MainChapter then
      return false
    elseif actJumpData.iActivityType == ShowType.FourteenUpTask then
      local act_list = ActivityManager:GetActivityListByType(MTTD.ActivityType_CommonQuest)
      if act_list then
        for _, act in pairs(act_list) do
          if act:GetUIType() == GlobalConfig.CommonQuestActType.DayTask_14 and act:GetUpActivityID() == actJumpData.sActivityParam[1] then
            if act.checkShowRed then
              isRed = act:checkShowRed()
            end
            break
          end
        end
      end
    elseif actJumpData.iActivityType == ShowType.AllianceRaid then
      isRed = 0 < GuildManager:GuildBossIsHaveRedDot()
    elseif actJumpData.iActivityType == ShowType.Night then
      isRed = 0 < HuntingRaidManager:IsHaveRedDot()
    elseif actJumpData.iActivityType == ShowType.TrialActivity then
      local activity = ActivityManager:GetActivityListByType(MTTD.ActivityType_Train)
      if activity then
        for i, stActivity in pairs(activity) do
          if stActivity and stActivity:checkCondition() then
            local commonCfgData = stActivity:GetTrianCommonData()
            if actJumpData.sActivityParam[1] and commonCfgData.iStoreId and actJumpData.sActivityParam[1] == commonCfgData.iStoreId then
              isRed = stActivity:checkShowRed()
            end
          end
        end
      end
    end
  end
  return isRed
end

function OperationActivityGuideActivity:GetActHallCfg()
  return self.m_clientCfg
end

function OperationActivityGuideActivity:OnResetStatusData()
end

return OperationActivityGuideActivity
