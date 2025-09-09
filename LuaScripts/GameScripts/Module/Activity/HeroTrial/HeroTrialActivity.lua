local BaseActivity = require("Base/BaseActivity")
local HeroTrialActivity = class("HeroTrialActivity", BaseActivity)

function HeroTrialActivity.getActivityType(_)
  return MTTD.ActivityType_HeroTrial
end

function HeroTrialActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgHeroTrial
end

function HeroTrialActivity.getStatusProto(_)
  return MTTDProto.CmdActHeroTrial_Status
end

function HeroTrialActivity:RequestGetReward(iLevelId)
  local reqMsg = MTTDProto.Cmd_Act_HeroTrial_TakeLevelReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iLevelId = iLevelId
  RPCS():Act_HeroTrial_TakeLevelReward(reqMsg, handler(self, self.OnRequestGetRewardSC))
end

function HeroTrialActivity:OnRequestGetRewardSC(sc, msg)
  local vReward = sc.vReward
  if self.m_stStatusData.mLevelStatus[sc.iLevelId] then
    self.m_stStatusData.mLevelStatus[sc.iLevelId] = sc.iStatus
  end
  utils.popUpRewardUI(vReward)
  self:broadcastEvent("eGameEvent_Activity_HeroTrialUpdate", self:getID())
end

function HeroTrialActivity:OnResetSdpConfig(m_stSdpConfig)
  if m_stSdpConfig and m_stSdpConfig.stCommonCfg then
    self.mTrialLevelData = m_stSdpConfig.stCommonCfg.mTrialLevel
    self.levelData = nil
    self:GetOpenLevelData()
  end
  self:broadcastEvent("eGameEvent_Activity_HeroTrialUpdate", self:getID())
end

function HeroTrialActivity:OnResetStatusData()
  self:ReSetLevelData()
end

function HeroTrialActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_HeroTrialActivity
end

function HeroTrialActivity:checkCondition(bIsShow)
  if not HeroTrialActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if table.getn(self:GetOpenLevelData()) == 0 then
    return false
  end
  return true
end

function HeroTrialActivity:checkShowRed()
  if self.levelData then
    local isAllFinish = true
    for _, v in pairs(self.levelData) do
      if v.RedShow then
        return true
      end
      if not v.IsFinish then
        isAllFinish = false
      end
    end
    if isAllFinish then
      return false
    end
  end
  local nextDayResetTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
  local bIsNewDay = nextDayResetTime - 1000 > LocalDataManager:GetIntSimple("HeroTrialActivity_Red_Point", 0)
  if bIsNewDay then
    return true
  end
  return false
end

function HeroTrialActivity:GeStatusByLevelId(levelID)
  if self.m_stStatusData and self.m_stStatusData.mLevelStatus then
    return self.m_stStatusData.mLevelStatus[levelID]
  end
  return 0
end

function HeroTrialActivity:GetOpenLevelData()
  if not self.levelData then
    if not self.m_allCfg then
      self.m_allCfg = {}
      self.allTableCfg = ConfigManager:GetConfigInsByName("CharacterTrialLevel"):GetAll()
      local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
      for i, v in pairs(self.allTableCfg) do
        local heroCfg = CharacterInfoIns:GetValue_ByHeroID(tonumber(v.m_HeroID))
        if not heroCfg:GetError() then
          local reward = {}
          local rewards = utils.changeCSArrayToLuaTable(v.m_FirstRewards)
          for _, r in pairs(rewards) do
            local temp = {}
            for _, k in pairs(r) do
              temp[#temp + 1] = k
            end
            reward[#reward + 1] = temp
          end
          local data = {
            LevelID = i,
            IsFinish = false,
            RedShow = false,
            OpenTime = nil,
            EndTime = nil,
            HeroCfg = heroCfg,
            FirstRewards = reward,
            AttrPathData = self:GetAttrPathByHeroCfg(heroCfg)
          }
          table.insert(self.m_allCfg, data)
        end
      end
    end
    self:ReSetLevelData()
  end
  return self.levelData
end

function HeroTrialActivity:ReSetLevelData()
  self.levelData = {}
  for _, v in pairs(self.m_allCfg) do
    if self:CheckLevelIsOpen(v.LevelID) then
      v.IsFinish = self:CheckLevelIsFinishByLevelId(v.LevelID)
      v.RedShow = self:CheckLevelIsShowRed(v.LevelID)
      v.OpenTime, v.EndTime = self:GetLevelTime(v.LevelID)
      table.insert(self.levelData, v)
    end
  end
  table.sort(self.levelData, function(a, b)
    if a.IsFinish ~= b.IsFinish then
      return not a.IsFinish
    end
    return a.OpenTime > b.OpenTime
  end)
end

function HeroTrialActivity:RemoveLevelDataByIndex(index)
  table.remove(self.levelData, index)
end

function HeroTrialActivity:GetAttrPathByHeroCfg(heroCfg)
  local attrData = {}
  local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
  local EquipTypeCfgIns = ConfigManager:GetConfigInsByName("EquipType")
  local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
  local CharacterDamageTypeIns = ConfigManager:GetConfigInsByName("CharacterDamageType")
  local campCfg = CampCfgIns:GetValue_ByCampID(heroCfg.m_Camp)
  if not campCfg:GetError() then
    attrData[#attrData + 1] = {
      path = campCfg.m_CampIcon,
      formId = UIDefines.ID_FORM_HEROCAMPDETAIL
    }
  end
  local equiptypeData = EquipTypeCfgIns:GetValue_ByEquiptypeID(heroCfg.m_Equiptype)
  if not equiptypeData:GetError() then
    attrData[#attrData + 1] = {
      path = equiptypeData.m_EquiptypeIcon,
      formId = UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL
    }
  end
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
  if not careerCfg:GetError() then
    attrData[#attrData + 1] = {
      path = careerCfg.m_CareerIcon,
      formId = UIDefines.ID_FORM_HEROCAREERDETAIL
    }
  end
  local damageCfg = CharacterDamageTypeIns:GetValue_ByDamageType(heroCfg.m_MainAttribute)
  if not damageCfg:GetError() then
    attrData[#attrData + 1] = {
      path = damageCfg.m_DamageTypeIcon,
      formId = UIDefines.ID_FORM_HERODAMAGETYPEDETAIL
    }
  end
  return attrData
end

function HeroTrialActivity:GetLevelTime(levelID)
  local startTime = 0
  local endTime = 0
  if self.allTableCfg[levelID] then
    if not string.isnullorempty(self.allTableCfg[levelID].m_OpenTime) then
      startTime = TimeUtil:TimeStringToTimeSec2(self.allTableCfg[levelID].m_OpenTime)
    end
    if not string.isnullorempty(self.allTableCfg[levelID].m_CloseTime) then
      endTime = TimeUtil:TimeStringToTimeSec2(self.allTableCfg[levelID].m_CloseTime)
    end
  end
  if self.mTrialLevelData and self.mTrialLevelData[levelID] and (self.mTrialLevelData[levelID].iOpenTime ~= 0 or self.mTrialLevelData[levelID].iCloseTime ~= 0) then
    startTime = self.mTrialLevelData[levelID].iOpenTime
    endTime = self.mTrialLevelData[levelID].iCloseTime
  end
  return startTime, endTime
end

function HeroTrialActivity:CheckLevelIsOpen(levelID)
  if self.mTrialLevelData and self.mTrialLevelData[levelID] then
    local startTime, endTime = self:GetLevelTime(levelID)
    if TimeUtil:IsInTime(startTime, endTime) then
      return true
    end
  end
  return false
end

function HeroTrialActivity:CheckLevelIsFinishByLevelId(levelID)
  local status = self:GeStatusByLevelId(levelID)
  if status and 0 < status then
    return true
  end
  return false
end

function HeroTrialActivity:CheckLevelIsFinishByHeroId(heroId)
  if self.levelData then
    for _, v in pairs(self.levelData) do
      if heroId == v.HeroCfg.m_HeroID then
        return v.IsFinish
      end
    end
  end
end

function HeroTrialActivity:CheckLevelIsExist(heroId)
  if self.levelData then
    for _, v in pairs(self.levelData) do
      if heroId == v.HeroCfg.m_HeroID then
        return true
      end
    end
  end
  return false
end

function HeroTrialActivity:CheckLevelIsShowRed(levelID)
  local isClick = LocalDataManager:GetIntSimple("Activity_HeroTrialItem_Red_Point" .. levelID, 0)
  if isClick == 1 then
    return false
  end
  return true
end

return HeroTrialActivity
