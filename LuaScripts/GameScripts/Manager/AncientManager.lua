local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local AncientManager = class("AncientManager", BaseLevelManager)

function AncientManager:OnCreate()
  self.m_questList = {}
  self.m_stAncient = {}
end

function AncientManager:OnInitNetwork()
  RPCS():Listen_Push_Ancient_Quest(handler(self, self.OnPushAncientQuest), "AncientManager")
end

function AncientManager:OnAfterInitConfig()
  self:InitGlobalCfg()
end

function AncientManager:OnInitMustRequestInFetchMore()
end

function AncientManager:InitGlobalCfg()
end

function AncientManager:OnDailyReset()
  self:ReqAncientGetDataCS()
end

function AncientManager:OnPushAncientQuest(stData, msg)
  if not stData then
    return
  end
  local len = table.getn(stData.vQuest)
  if 0 < len then
    for i = len, 1, -1 do
      local quest = stData.vQuest[i]
      if quest then
        for index, v in pairs(self.m_questList) do
          if v.iId == quest.iId then
            self.m_questList[index] = quest
          end
        end
      end
    end
    self.m_stAncient.vQuest = self.m_questList
  end
  self:broadcastEvent("eGameEvent_Ancient_TaskUpdate")
end

function AncientManager:ReqAncientGetDataCS()
  local reqMsg = MTTDProto.Cmd_Ancient_GetData_CS()
  RPCS():Ancient_GetData(reqMsg, handler(self, self.OnReqAncientGetDataSC))
end

function AncientManager:OnReqAncientGetDataSC(stData)
  self.m_stAncient = stData.stAncient
  self.m_questList = self.m_stAncient.vQuest
end

function AncientManager:ReqAncientChangeHeroCS(iHeroId)
  local reqMsg = MTTDProto.Cmd_Ancient_ChangeHero_CS()
  reqMsg.iHeroId = iHeroId
  RPCS():Ancient_ChangeHero(reqMsg, handler(self, self.OnReqAncientChangeHeroSC))
end

function AncientManager:OnReqAncientChangeHeroSC(stData)
  if self.m_stAncient and stData then
    self.m_stAncient.iCurHero = stData.iHeroId
    if self.m_stAncient.mSummonHero then
      self.m_stAncient.mSummonHero[stData.iHeroId] = stData.stHero
    end
  end
  self:broadcastEvent("eGameEvent_Ancient_ChangeHero")
end

function AncientManager:ReqAncientTakeQuestAwardCS(vQuestId)
  local reqMsg = MTTDProto.Cmd_Ancient_TakeQuestAward_CS()
  reqMsg.vQuestId = vQuestId
  RPCS():Ancient_TakeQuestAward(reqMsg, handler(self, self.OnReqAncientTakeQuestAwardSC))
end

function AncientManager:OnReqAncientTakeQuestAwardSC(stData)
  local len = table.getn(stData.vQuestId)
  if 0 < len then
    for i = len, 1, -1 do
      if stData.vQuestId[i] then
        for index, v in pairs(self.m_questList) do
          if v.iId == stData.vQuestId[i] then
            self.m_questList[index].iState = MTTDProto.QuestState_Over
          end
        end
      end
    end
    self.m_stAncient.vQuest = self.m_questList
  end
  if stData.vItem and next(stData.vItem) then
    utils.popUpRewardUI(stData.vItem)
  end
  self:broadcastEvent("eGameEvent_Ancient_TakeQuestAward")
end

function AncientManager:ReqAncientRefreshQuestCS()
  local reqMsg = MTTDProto.Cmd_Ancient_RefreshQuest_CS()
  RPCS():Ancient_RefreshQuest(reqMsg, handler(self, self.OnReqAncientRefreshQuestSC))
end

function AncientManager:OnReqAncientRefreshQuestSC(stData)
  self.m_stAncient.vQuest = stData.vQuest
  self.m_stAncient.iRefreshTimes = self.m_stAncient.iRefreshTimes + 1
  self.m_questList = stData.vQuest
  self:broadcastEvent("eGameEvent_Ancient_RefreshQuest")
end

function AncientManager:ReqAncientAddEnergyCS(iAddEnergy)
  local reqMsg = MTTDProto.Cmd_Ancient_AddEnergy_CS()
  reqMsg.iAddEnergy = iAddEnergy
  RPCS():Ancient_AddEnergy(reqMsg, handler(self, self.OnReqAncientAddEnergySC))
end

function AncientManager:OnReqAncientAddEnergySC(stData)
  local heroId = self.m_stAncient.iCurHero
  if table.getn(self.m_stAncient.mSummonHero) > 0 and self.m_stAncient.mSummonHero[heroId] then
    self.m_stAncient.mSummonHero[heroId].iCurEnergy = stData.iCurEnergy
  end
  self:broadcastEvent("eGameEvent_Ancient_AddEnergy")
end

function AncientManager:ReqAncientSummonHeroCS()
  local reqMsg = MTTDProto.Cmd_Ancient_SummonHero_CS()
  RPCS():Ancient_SummonHero(reqMsg, handler(self, self.OnReqAncientSummonHeroSC))
end

function AncientManager:OnReqAncientSummonHeroSC(stData)
  if self.m_stAncient and self.m_stAncient.mSummonHero and stData then
    self.m_stAncient.mSummonHero[stData.iHeroId] = stData.stHero
    self.m_stAncient.iCurHero = stData.iCurHero
  end
  if stData.vItem and next(stData.vItem) then
    utils.popUpRewardUI(stData.vItem, function()
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13027)
      self:broadcastEvent("eGameEvent_Ancient_SummonHero")
    end)
  end
end

function AncientManager:GetCurHeroID()
  if self.m_stAncient and self.m_stAncient.iCurHero then
    return self.m_stAncient.iCurHero
  end
end

function AncientManager:GetAncientData()
  return self.m_stAncient
end

function AncientManager:GetAncientSummonHero()
  if self.m_stAncient and self.m_stAncient.mSummonHero and self.m_stAncient.iCurHero then
    return self.m_stAncient.mSummonHero[self.m_stAncient.iCurHero]
  end
end

function AncientManager:GetAncientSummonHeroById(heroId)
  if self.m_stAncient and self.m_stAncient.mSummonHero and heroId then
    return self.m_stAncient.mSummonHero[heroId]
  end
end

function AncientManager:GetTaskRefreshTimes()
  return self.m_stAncient.iRefreshTimes
end

function AncientManager:GetTaskList()
  return self.m_questList
end

function AncientManager:GetAncientCharacterCfgById(heroId)
  local characterIns = ConfigManager:GetConfigInsByName("AncientCharacter")
  local characterInfo = characterIns:GetValue_ByHeroID(heroId)
  if characterInfo:GetError() then
    log.error("AncientManager GetAncientCharacterCfgById  id  " .. tostring(heroId))
    return
  end
  return characterInfo
end

function AncientManager:GetAncientTaskCfgById(taskId)
  local taskIns = ConfigManager:GetConfigInsByName("AncientTask")
  local taskInfo = taskIns:GetValue_ByUID(taskId)
  if taskInfo:GetError() then
    log.error("AncientManager GetAncientTaskCfgById  id  " .. tostring(taskId))
    return
  end
  return taskInfo
end

function AncientManager:GetAllAncientCharacterIdsAndCfgList()
  local characterIns = ConfigManager:GetConfigInsByName("AncientCharacter")
  local characterAll = characterIns:GetAll()
  local idList = {}
  local cfgList = {}
  for i, v in pairs(characterAll) do
    if v.m_Display == 1 then
      idList[#idList + 1] = v.m_HeroID
      cfgList[#cfgList + 1] = v
    end
  end
  return idList, cfgList
end

function AncientManager:GetTaskNameById(taskId, taskCfg)
  local name = ""
  taskCfg = taskCfg or self:GetAncientTaskCfgById(taskId)
  local param = utils.changeCSArrayToLuaTable(taskCfg.m_DescParam)
  name = string.CS_Format(taskCfg.m_mTaskName, param)
  return name
end

function AncientManager:GetCanReceiveTaskIds()
  local taskIds = {}
  if self.m_stAncient and table.getn(self.m_stAncient.vQuest) > 0 then
    for i, v in pairs(self.m_stAncient.vQuest) do
      if v.iState == MTTDProto.QuestState_Finish then
        taskIds[#taskIds + 1] = v.iId
      end
    end
  end
  return taskIds
end

function AncientManager:CheckHeroIsUnlockById(heroId)
  local unlock = true
  if not heroId then
    return
  end
  local cfg = self:GetAncientCharacterCfgById(heroId)
  if not cfg then
    log.error("GetAncientCharacterCfgById error heroId " .. tostring(heroId))
    return
  end
  local unlockList = utils.changeCSArrayToLuaTable(cfg.m_Unlock)
  for m = 1, table.getn(unlockList) do
    if unlockList[m] and unlockList[m][1] then
      local conditionId = unlockList[m][1]
      local summonHero = self:GetAncientSummonHeroById(conditionId)
      if summonHero then
        if summonHero.iSummonTimes < unlockList[m][2] then
          return false
        end
      else
        return false
      end
    end
  end
  return unlock
end

function AncientManager:CheckAncientEnterRedDot()
  local id = RoleManager:GetRoleAllianceInfo()
  if not id or id == 0 or id == "0" then
    return 0
  end
  local taskIds = self:GetCanReceiveTaskIds()
  local gachaFlag = self:CheckAncientCanGachaHero()
  local flag = 0 < table.getn(taskIds) or gachaFlag
  return flag and 1 or 0
end

function AncientManager:CheckAncientCanGachaHero()
  local summonHero = self:GetAncientSummonHero()
  if summonHero and summonHero.iHeroId ~= 0 then
    local summonHeroCfg = self:GetAncientCharacterCfgById(summonHero.iHeroId)
    if summonHeroCfg then
      local summonEnergyMax = summonHero.iSummonTimes == 0 and summonHeroCfg.m_SummonHero or summonHeroCfg.m_SummonChip
      if summonEnergyMax <= summonHero.iCurEnergy then
        return true
      end
    end
  end
end

return AncientManager
