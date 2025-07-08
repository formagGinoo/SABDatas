local BaseActivity = require("Base/BaseActivity")
local WelfareShowActivity = class("WelfareShowActivity", BaseActivity)

function WelfareShowActivity.getActivityType(_)
  return MTTD.ActivityType_WelfareShow
end

function WelfareShowActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgWelfareShow
end

function WelfareShowActivity.getStatusProto(_)
  return MTTDProto.CmdActWelfareShow_Status
end

function WelfareShowActivity:OnResetSdpConfig(m_stSdpConfig)
  self.mWelfareActCfg = {}
  if m_stSdpConfig and m_stSdpConfig.stClientCfg then
    self.mWelfareActCfg = m_stSdpConfig.stClientCfg
  end
end

function WelfareShowActivity:GetWelfareCfg()
  return self.mWelfareActCfg
end

function WelfareShowActivity:OnResetStatusData()
end

function WelfareShowActivity:checkCondition()
  if not WelfareShowActivity.super.checkCondition(self) then
    return false
  end
  return true
end

function WelfareShowActivity:CheckActivityIsOpen()
  local openFlag = false
  if self:checkCondition() then
    openFlag = true
  end
  return openFlag
end

function WelfareShowActivity:checkShowRed()
  local mSystemList = self.mWelfareActCfg.vSystem or {}
  local bHaveAward = false
  for i, v in ipairs(mSystemList) do
    local strList = string.split(v.sJumpParam, ";")
    local act_id
    if ActivityManager.JumpType.Activity == v.iJumpType then
      act_id = strList[1]
    elseif v.iJumpType == ActivityManager.JumpType.System then
      act_id = strList[3]
    end
    if act_id then
      local actIns = ActivityManager:GetActivityByID(tonumber(act_id))
      if actIns and actIns.checkShowRed then
        local bShowRed = actIns:checkShowRed()
        if bShowRed == true then
          bHaveAward = true
          break
        end
      end
    end
  end
  return bHaveAward
end

function WelfareShowActivity:checkShowActivity()
  local bNeedShow = false
  local cfg = self:GetWelfareCfg()
  local mSystemList = cfg.vSystem
  for i, v in ipairs(mSystemList) do
    local actState = self:GetActState(i)
    if actState == ActivityManager.ActStateEnum.Normal or actState == ActivityManager.ActStateEnum.NotOpen then
      bNeedShow = true
      break
    end
  end
  return bNeedShow
end

function WelfareShowActivity:GetActState(iActIdx)
  local cfg = self:GetWelfareCfg()
  local mSystemList = cfg.vSystem
  local info = mSystemList[iActIdx]
  local strList = string.split(info.sJumpParam, ";")
  local act_id
  if ActivityManager.JumpType.Activity == info.iJumpType then
    act_id = strList[1]
  elseif info.iJumpType == ActivityManager.JumpType.System then
    act_id = strList[3]
  end
  if act_id then
    local actIns = ActivityManager:GetActivityByID(tonumber(act_id))
    if actIns then
      if not actIns:isInActivityTime() then
        local startTime = actIns:getActivityBeginTime()
        local endTime = actIns:getActivityEndTime()
        local iCurTime = TimeUtil:GetServerTimeS()
        if startTime > iCurTime then
          return ActivityManager.ActStateEnum.NotOpen
        elseif endTime < iCurTime then
          return ActivityManager.ActStateEnum.Locked
        end
      end
      if not actIns:checkCondition() then
        return ActivityManager.ActStateEnum.Locked
      end
    end
    if actIns and actIns.isAllTaskFinished then
      local isAllFinished = actIns:isAllTaskFinished()
      if isAllFinished then
        return ActivityManager.ActStateEnum.Finished
      else
        return ActivityManager.ActStateEnum.Normal
      end
    elseif actIns then
      return ActivityManager.ActStateEnum.Normal
    else
      return ActivityManager.ActStateEnum.Locked
    end
  else
    local is_open, is_finish = self:IsSystemOpen(tonumber(info.sJumpParam))
    if is_open then
      if is_finish then
        return ActivityManager.ActStateEnum.Finished
      else
        return ActivityManager.ActStateEnum.Normal
      end
    else
      return ActivityManager.ActStateEnum.Locked
    end
  end
end

function WelfareShowActivity:IsSystemOpen(jumpid, bIsShowTips)
  local jumpIns = ConfigManager:GetConfigInsByName("Jump")
  local jump_item = jumpIns:GetValue_ByJumpID(jumpid)
  if jump_item then
    local open_condition_id = jump_item.m_SystemID or 0
    local open_flag, tips_id = UnlockSystemUtil:IsSystemOpen(open_condition_id)
    if 0 < open_condition_id and not open_flag then
      if bIsShowTips then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
      end
      return
    end
    local systemID, windowID = jump_item.m_SystemID, jump_item.m_WindowID
    if systemID == GlobalConfig.SYSTEM_ID.Gacha then
      local itemCfg = GachaManager:GetGachaConfigByWindowId(windowID)
      if itemCfg then
        local cfg = GachaManager:GetGachaConfig(itemCfg.m_GachaID)
        if cfg.m_IsOpen == 0 then
          if bIsShowTips then
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40024)
          end
          return false
        end
        local flag = false
        local conditionTypeArray = utils.changeCSArrayToLuaTable(cfg.m_UnlockConditionType)
        for index, conditionType in ipairs(conditionTypeArray or {}) do
          local conditionData = cfg.m_UnlockConditionData[index - 1] or 999
          if conditionType == UnlockSystemUtil.GACHA_LOCK_CONDITION_TYPE.LEVEL then
            flag = conditionData <= RoleManager:GetLevel()
          elseif conditionType == UnlockSystemUtil.GACHA_LOCK_CONDITION_TYPE.CHAPTER then
            flag = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, conditionData)
          elseif conditionType == UnlockSystemUtil.GACHA_LOCK_CONDITION_TYPE.GUIDE then
            flag = GuideManager:CheckSubStepGuideCmp(conditionData)
          else
            log.warn("open_conditionType not found : " .. tostring(conditionType))
          end
          if flag == false then
            if bIsShowTips then
              StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40024)
            end
            return flag
          end
        end
        local startTime = TimeUtil:TimeStringToTimeSec2(cfg.m_StartTime) or 0
        local endTime = TimeUtil:TimeStringToTimeSec2(cfg.m_EndTime) or 0
        local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.gacha, {
          id = cfg.m_ActId,
          gacha_id = itemCfg.m_GachaID
        })
        if is_corved then
          startTime = t1
          endTime = t2
        end
        flag = TimeUtil:IsInTime(startTime, endTime)
        if not flag then
          if bIsShowTips then
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40024)
          end
          return flag
        end
        local gachaCount = GachaManager:GetGachaCountById(itemCfg.m_GachaID)
        flag = cfg.m_WishTimesRes == 0 or gachaCount < cfg.m_WishTimesRes
        return true, not flag
      else
        log.error("can not find gachaPool windowId == " .. tostring(windowID))
      end
    end
  end
end

function WelfareShowActivity:SetPushFaceGuideStep(step)
  if step == self.mWelfareActCfg.iNeedGuideId then
    self.m_bNeedPushFace = true
  end
end

function WelfareShowActivity:IsNeedPushFace()
  if self.m_bNeedPushFace then
    self.m_bNeedPushFace = false
    return true
  end
  return false
end

return WelfareShowActivity
