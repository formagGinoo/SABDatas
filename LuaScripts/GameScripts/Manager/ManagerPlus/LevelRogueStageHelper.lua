local LevelRogueStageHelper = class("LevelRogueStageHelper")

function LevelRogueStageHelper:ctor()
  self.m_allPassChapterStagesIds = {}
  self.m_stRogue = {}
  self.m_iCurStage = 0
  self.m_iDailyReward = 0
  self.m_iTakenReward = 0
  self.m_mStage = {}
  self.m_LevelRewardCfgList = {}
  self.m_LevelRewardListDic = {}
  self.m_LevelRewardGroupCfgList = {}
  self.m_RogueStageChapterCfgTab = {}
  self.m_cacheRogueItemIconPosCfgTab = {}
  local param = ConfigManager:GetGlobalSettingsByKey("RogueStageLevelMonsterShowOrder") or {}
  self.m_rogueStageLevelMonsterShowOrderParam = string.split(param, ";")
  self:InitRogueItemCfg()
  self.m_activeTechTreeTable = {}
  self.m_cacheRogueTechTreeCfgTab = {}
  self.m_allTechTreeList = nil
  self:InitRogueStageRewardCfg()
end

function LevelRogueStageHelper:UpdateFinishChallengePushData(stData)
  self.m_mStage[stData.iStageId] = stData.stStage
  self.m_stRogue.iCurStage = stData.iCurStage
  self.m_stRogue.iCurStartTime = stData.iCurStartTime
  self.m_iCurStage = stData.iCurStage
  self.m_iDailyReward = stData.iDailyReward
  self.m_stRogue.iDailyReward = stData.iDailyReward
  local newHandbook = stData.vNewHandbook
  for _, v in pairs(newHandbook) do
    self.m_stRogue.mHandbook[v] = TimeUtil:GetServerTimeS()
  end
end

function LevelRogueStageHelper:UpdateTakenReward(stData)
  self.m_iTakenReward = stData.iTakenReward
end

function LevelRogueStageHelper:UpdateRogueStageData(stData)
  if not stData then
    return
  end
  self.m_stRogue = stData.stRogue
  self.m_mStage = self.m_stRogue.mStage
  self.m_iCurStage = self.m_stRogue.iCurStage
  self.m_iDailyReward = self.m_stRogue.iDailyReward
  self.m_iTakenReward = self.m_stRogue.iTakenReward
  if table.getn(self.m_mStage) > 0 then
    self.m_stageMonsterTab = {}
    for stageId, v in pairs(self.m_mStage) do
      self.m_stageMonsterTab[stageId] = self:GenerateStageDailyMonster(v.mDailyMonster)
    end
  end
  self.m_activeTechTreeTable = self.m_stRogue.mTech or {}
end

function LevelRogueStageHelper:GetDailyRewardLevel()
  return self.m_iDailyReward
end

function LevelRogueStageHelper:GetTakenRewardLevel()
  return self.m_iTakenReward
end

function LevelRogueStageHelper:GenerateStageDailyMonster(dailyMonster)
  local monsterList = {}
  local monsters = table.deepcopy(dailyMonster)
  if table.getn(self.m_rogueStageLevelMonsterShowOrderParam) > 0 then
    for i, v in ipairs(self.m_rogueStageLevelMonsterShowOrderParam) do
      if monsters[tonumber(v)] then
        table.insertto(monsterList, monsters[tonumber(v)])
        monsters[tonumber(v)] = nil
      end
    end
  end
  if table.getn(monsters) > 0 then
    for i, v in pairs(monsters) do
      table.insertto(monsterList, v)
    end
  end
  return monsterList
end

function LevelRogueStageHelper:GetStageInfoById(stageId)
  if table.getn(self.m_mStage) > 0 then
    return self.m_mStage[stageId]
  end
end

function LevelRogueStageHelper:GetStageMapIdById(stageId)
  if table.getn(self.m_mStage) > 0 and self.m_mStage[stageId] then
    return self.m_mStage[stageId].iDailyLevel
  end
end

function LevelRogueStageHelper:GetStagePassTimesById(stageId)
  if table.getn(self.m_mStage) > 0 and self.m_mStage[stageId] then
    return self.m_mStage[stageId].iPassTimes
  end
end

function LevelRogueStageHelper:GetCurChapterId()
  if self.m_iCurStage ~= 0 then
    local cfg = self:GetStageConfigById(self.m_iCurStage)
    return cfg.m_ChapterId
  end
  local chapterId = 0
  local cfgTab = self:GetRogueStageChapterCfg()
  if 0 < table.getn(cfgTab) then
    for i, v in pairs(cfgTab) do
      for m, n in pairs(v) do
        local passTime = self:GetStagePassTimesById(n.m_StageId)
        if passTime and passTime == 0 then
          local unlock = self:IsLevelUnLock(n.m_StageId)
          if not unlock then
            return chapterId
          end
          return n.m_ChapterId
        end
        chapterId = n.m_ChapterId
      end
    end
  end
  return chapterId
end

function LevelRogueStageHelper:GetCurStageId()
  if self.m_iCurStage ~= 0 then
    return self.m_iCurStage
  end
  local stageId = 0
  local cfgTab = self:GetRogueStageChapterCfg()
  if 0 < table.getn(cfgTab) then
    for i, v in ipairs(cfgTab) do
      for m, n in ipairs(v) do
        local passTime = self:GetStagePassTimesById(n.m_StageId)
        if passTime and passTime == 0 then
          local unlock = self:IsLevelUnLock(n.m_StageId)
          if not unlock then
            return stageId
          end
          return n.m_StageId
        end
        stageId = n.m_StageId
      end
    end
  end
  return stageId
end

function LevelRogueStageHelper:GetFightingStageID()
  return self.m_iCurStage
end

function LevelRogueStageHelper:GetStageMonsterById(stageId)
  if table.getn(self.m_stageMonsterTab) > 0 then
    return self.m_stageMonsterTab[stageId]
  end
end

function LevelRogueStageHelper:GetStageRewardsByLevel(level)
  local cfg = self:GetRogueStageRewardConfigById(level)
  if cfg then
    return utils.changeCSArrayToLuaTable(cfg.m_Rewards)
  end
end

function LevelRogueStageHelper:SetStageData(stageDataTab)
  if stageDataTab and stageDataTab then
    for i, v in pairs(stageDataTab) do
      local dataTab = v.mStageFirstFinishTime
      if dataTab then
        for id, time in pairs(dataTab) do
          self.m_allPassChapterStagesIds[id] = time
        end
      end
    end
  end
end

function LevelRogueStageHelper:IsLevelHavePass(stageId)
  local passTime = 0
  if stageId then
    if stageId == 0 then
      return true, passTime
    end
    for i, v in pairs(self.m_mStage) do
      if v.iStageId == stageId then
        return v.iPassTimes ~= 0, v.iPassTimes
      end
    end
  end
  return false, passTime
end

function LevelRogueStageHelper:IsHaveNewStage()
  for i, v in pairs(self.m_mStage) do
    if v.iStageId then
      local unlock = self:IsLevelUnLock(v.iStageId)
      local redPoint = RogueStageManager:CheckNewStageRedPoint(v.iStageId)
      if unlock and v.iPassTimes == 0 and 0 < redPoint then
        return 1
      end
    end
  end
  return 0
end

function LevelRogueStageHelper:IsNewStage(iStageId)
  for i, v in pairs(self.m_mStage) do
    if v.iStageId == iStageId then
      local unlock = self:IsLevelUnLock(v.iStageId)
      if unlock and v.iPassTimes == 0 then
        return 1
      end
    end
  end
  return 0
end

function LevelRogueStageHelper:IsLevelUnLock(stageId)
  local levelCfg = self:GetStageConfigById(stageId)
  local unlockLevelID = levelCfg.m_UnlockStage
  local isPass = self:IsLevelHavePass(unlockLevelID)
  local pass = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, levelCfg.m_UnlockMainLevel)
  local name = LevelManager:GetLevelName(LevelManager.LevelType.MainLevel, levelCfg.m_UnlockMainLevel)
  return isPass and pass, pass, name
end

function LevelRogueStageHelper:GetStageRecommendTips(monsterIdList)
  local RogueStageLevelTipsIns = ConfigManager:GetConfigInsByName("RogueStageLevelTips")
  local cfgAll = RogueStageLevelTipsIns:GetAll()
  for i, v in pairs(cfgAll) do
    if table.indexof(monsterIdList, v.m_ID) then
      return v.m_mChallengeTips
    end
  end
  return ""
end

function LevelRogueStageHelper:GetStageConfigById(stageId)
  local RogueStageChapterIns = ConfigManager:GetConfigInsByName("RogueStageChapter")
  local stageCfg = RogueStageChapterIns:GetValue_ByStageId(stageId)
  if stageCfg:GetError() then
    log.error("LevelRogueStageHelper GetStageConfigById  id  " .. tostring(stageId))
    return
  end
  return stageCfg
end

function LevelRogueStageHelper:GetRogueStageRewardGroupConfigById(groupID, gear)
  local RogueStageRewardGroupIns = ConfigManager:GetConfigInsByName("RogueStageRewardGroup")
  local rewardCfg = RogueStageRewardGroupIns:GetValue_ByGroupIDAndGear(groupID, gear)
  if rewardCfg and rewardCfg:GetError() then
    log.error("LevelRogueStageHelper GetRogueStageRewardGroupConfigById  id  " .. tostring(groupID) .. tostring(gear))
    return
  end
  return rewardCfg
end

function LevelRogueStageHelper:GetRogueStageRewardConfigById(keyLevel)
  local RogueStageRewardIns = ConfigManager:GetConfigInsByName("RogueStageReward")
  local rewardCfg = RogueStageRewardIns:GetValue_ByKeyLevel(keyLevel)
  if rewardCfg and rewardCfg:GetError() then
    log.error("LevelRogueStageHelper GetRogueStageRewardConfigById  keyLevel  " .. tostring(keyLevel))
    return
  end
  return rewardCfg
end

function LevelRogueStageHelper:GetRogueStageRewardMaxGearByRewardId(groupID)
  local RogueStageRewardGroupIns = ConfigManager:GetConfigInsByName("RogueStageRewardGroup")
  local cfgTab = RogueStageRewardGroupIns:GetValue_ByGroupID(groupID)
  if cfgTab then
    local min = 999999
    local max = 0
    for i, v in pairs(cfgTab) do
      if min > v.m_KeyLevel then
        min = v.m_KeyLevel
      end
      if max < v.m_KeyLevel then
        max = v.m_KeyLevel
      end
    end
    return cfgTab.Count, min, max
  end
end

function LevelRogueStageHelper:GetRogueStageRewardGroupCfgListByLv(keyLevel)
  if not keyLevel then
    return
  end
  local tempCfg
  if self.m_LevelRewardCfgList[keyLevel] then
    tempCfg = self.m_LevelRewardCfgList[keyLevel]
  else
    local RogueStageRewardIns = ConfigManager:GetConfigInsByName("RogueStageReward")
    local cfg = RogueStageRewardIns:GetValue_ByKeyLevel(keyLevel)
    self.m_LevelRewardCfgList[keyLevel] = cfg
    tempCfg = cfg
  end
  return tempCfg
end

function LevelRogueStageHelper:InitRogueStageRewardCfg()
  local RogueStageRewardIns = ConfigManager:GetConfigInsByName("RogueStageReward")
  local cfgAll = RogueStageRewardIns:GetAll()
  for _, v in pairs(cfgAll) do
    if v.m_KeyLevel > 0 then
      self.m_LevelRewardCfgList[v.m_KeyLevel] = v
    end
  end
  local RogueStageRewardGroupIns = ConfigManager:GetConfigInsByName("RogueStageRewardGroup")
  local cfgGroupAll = RogueStageRewardGroupIns:GetAll()
  for _, v in pairs(cfgGroupAll) do
    for _, n in pairs(v) do
      if n.m_KeyLevel > 0 then
        self.m_LevelRewardGroupCfgList[n.m_KeyLevel] = n
      end
    end
  end
  local RogueStageChapterIns = ConfigManager:GetConfigInsByName("RogueStageChapter")
  local chapterCfgAll = RogueStageChapterIns:GetAll()
  for _, v in pairs(chapterCfgAll) do
    if not self.m_RogueStageChapterCfgTab[v.m_ChapterId] then
      self.m_RogueStageChapterCfgTab[v.m_ChapterId] = {}
    end
    self.m_RogueStageChapterCfgTab[v.m_ChapterId][v.m_Order] = v
  end
  local RogueTechTreeInfoIns = ConfigManager:GetConfigInsByName("RogueTechTreeInfo")
  local allConfigs = RogueTechTreeInfoIns:GetAll()
  if allConfigs then
    for i, v in pairs(allConfigs) do
      self.m_cacheRogueTechTreeCfgTab[v.m_TechID] = v
    end
  end
  local RogueItemIconPosIns = ConfigManager:GetConfigInsByName("RogueItemIconPos")
  local allPosConfigs = RogueItemIconPosIns:GetAll()
  if allPosConfigs then
    for i, v in pairs(allPosConfigs) do
      self.m_cacheRogueItemIconPosCfgTab[v.m_ItemID] = v
    end
  end
end

function LevelRogueStageHelper:GetRogueStageRewardCfgList()
  return self.m_LevelRewardCfgList
end

function LevelRogueStageHelper:GetCurRogueStageRewards()
  local rewardList = {}
  if self.m_iDailyReward > self.m_iTakenReward then
    local startStep = self.m_iTakenReward
    local rewardTab = {}
    for n = startStep + 1, self.m_iDailyReward do
      local cfg = self.m_LevelRewardCfgList[n]
      if cfg then
        for i = 0, cfg.m_Rewards.Length - 1 do
          local item = cfg.m_Rewards[i]
          if item and item[0] and rewardTab[item[0]] then
            rewardTab[item[0]] = rewardTab[item[0]] + item[1]
          else
            rewardTab[item[0]] = item[1]
          end
        end
      end
    end
    for i, v in pairs(rewardTab) do
      rewardList[#rewardList + 1] = {i, v}
    end
  end
  return rewardList
end

function LevelRogueStageHelper:IsHaveRewards()
  return self.m_iDailyReward > self.m_iTakenReward
end

function LevelRogueStageHelper:GetRogueStageGearByIdAndKillCount(stageId, killCount)
  if not stageId or not killCount then
    return
  end
  local levelCfg = self:GetStageConfigById(stageId)
  local groupId = levelCfg.m_Reward
  local rewardCfgList = self:GetRogueStageRewardGroupCfgListByID(groupId)
  local condition = 0
  local gear = 0
  for i, v in pairs(rewardCfgList) do
    if killCount >= v.m_Condition and condition < v.m_Condition then
      condition = v.m_Condition
      gear = v.m_Gear
    end
  end
  return gear
end

function LevelRogueStageHelper:GetRogueStageRewardGroupCfgListByID(groupID)
  if not groupID then
    return
  end
  local tempList
  if self.m_LevelRewardListDic[groupID] then
    tempList = self.m_LevelRewardListDic[groupID]
  else
    tempList = {}
    local RogueStageRewardGroupIns = ConfigManager:GetConfigInsByName("RogueStageRewardGroup")
    local dungeonLevelPhaseDic = RogueStageRewardGroupIns:GetValue_ByGroupID(groupID)
    for _, v in pairs(dungeonLevelPhaseDic) do
      tempList[v.m_Gear] = v
    end
    self.m_LevelRewardListDic[groupID] = tempList
  end
  return tempList
end

function LevelRogueStageHelper:GetStageRewardMaxGear(stageId)
  local levelCfg = self:GetStageConfigById(stageId)
  local groupId = levelCfg.m_Reward
  local rewardCfgList = self:GetRogueStageRewardGroupCfgListByID(groupId)
  return table.getn(rewardCfgList)
end

function LevelRogueStageHelper:GetStageIdAndGearByKeyLevel(keyLevel)
  for i, v in pairs(self.m_LevelRewardGroupCfgList) do
    if v.m_KeyLevel == keyLevel then
      local cfg = self:GetStageCfgByRewardId(v.m_GroupID)
      if cfg then
        return cfg.m_StageId, v.m_Gear
      end
    end
  end
end

function LevelRogueStageHelper:GetStageCfgByRewardId(rewardId)
  local cfgTab = self:GetRogueStageChapterCfg()
  if table.getn(cfgTab) > 0 then
    for i, v in pairs(cfgTab) do
      for m, n in pairs(v) do
        if n.m_Reward == rewardId then
          return n
        end
      end
    end
  end
end

function LevelRogueStageHelper:GetStageGearShowDataByStageId(stageId)
  local gear = 0
  if 0 < self.m_iDailyReward then
    local curStageId, curGear = self:GetStageIdAndGearByKeyLevel(self.m_iDailyReward)
    if not curStageId then
      return gear
    end
    if curStageId == stageId then
      return curGear
    end
    local idTab = {}
    for i, v in pairs(self.m_LevelRewardGroupCfgList) do
      if v.m_KeyLevel < self.m_iDailyReward then
        if not idTab[v.m_GroupID] then
          idTab[v.m_GroupID] = v.m_Gear
        elseif idTab[v.m_GroupID] < v.m_Gear then
          idTab[v.m_GroupID] = v.m_Gear
        end
      end
    end
    local levelCfg = self:GetStageConfigById(stageId)
    if levelCfg then
      local groupId = levelCfg.m_Reward
      if idTab[groupId] then
        return idTab[groupId]
      end
    end
  end
  return gear
end

function LevelRogueStageHelper:GetRogueStageChapterCfg()
  return self.m_RogueStageChapterCfgTab
end

function LevelRogueStageHelper:GetRogueStageGearRangeById(stageId)
  local levelCfg = self:GetStageConfigById(stageId)
  local groupId = levelCfg.m_Reward
  local rewardCfgList = self:GetRogueStageRewardGroupCfgListByID(groupId)
  local gearMin = 99999
  local gearMax = 0
  for i, v in pairs(rewardCfgList) do
    if gearMin > v.m_KeyLevel then
      gearMin = v.m_KeyLevel
    end
    if gearMax < v.m_KeyLevel then
      gearMax = v.m_KeyLevel
    end
  end
  return gearMin, gearMax
end

function LevelRogueStageHelper:FreshTechUnlockTime(techID, unlockTime)
  if not techID then
    return
  end
  if not self.m_activeTechTreeTable then
    return
  end
  self.m_activeTechTreeTable[techID] = unlockTime
end

function LevelRogueStageHelper:IsTechNodeActive(techTD)
  if not techTD then
    return
  end
  if not self.m_activeTechTreeTable[techTD] then
    return
  end
  return self.m_activeTechTreeTable[techTD] ~= 0
end

function LevelRogueStageHelper:IsTechNodePreConditionMatch(techID)
  if not techID then
    return
  end
  local techTreeInfoCfg = self:GetTechCfgByID(techID)
  if not techTreeInfoCfg then
    return
  end
  local limitLevelID = techTreeInfoCfg.m_LimitLevel
  if LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, limitLevelID) ~= true then
    local levelName = LevelManager:GetLevelName(LevelManager.LevelType.MainLevel, limitLevelID)
    local showStr = ConfigManager:GetCommonTextById(100707)
    showStr = string.CS_Format(showStr, levelName)
    return false, showStr
  end
  local preNodeArray = techTreeInfoCfg.m_FrontTechID
  if preNodeArray.Length > 0 then
    local lengthNum = preNodeArray.Length
    for i = 1, lengthNum do
      local preTechID = preNodeArray[i - 1]
      if preTechID ~= 0 and self:IsTechNodeActive(preTechID) ~= true then
        local showStr = ConfigManager:GetCommonTextById(100706)
        return false, showStr
      end
    end
  end
  return true
end

function LevelRogueStageHelper:IsTechNodeCanActive(techID)
  if not techID then
    return
  end
  local techTreeInfoCfg = self:GetTechCfgByID(techID)
  if not techTreeInfoCfg then
    return
  end
  local isMatch, unMathStr = self:IsTechNodePreConditionMatch(techID)
  if not isMatch then
    return isMatch, unMathStr
  end
  local costItemList = utils.changeCSArrayToLuaTable(techTreeInfoCfg.m_Cost)
  if costItemList and next(costItemList) then
    for i, tempData in ipairs(costItemList) do
      if tempData and next(tempData) then
        local itemID = tempData[1]
        local itemNum = tempData[2]
        local curHaveNum = ItemManager:GetItemNum(itemID) or 0
        if itemNum > curHaveNum then
          return false, ConfigManager:GetClientMessageTextById(53001)
        end
      end
    end
  end
  return true
end

function LevelRogueStageHelper:GetTechCfgByID(techID)
  if not techID then
    return
  end
  local rogueTechTreeInfoCfg = self.m_cacheRogueTechTreeCfgTab[techID]
  if rogueTechTreeInfoCfg == nil then
    local RogueTechTreeInfoIns = ConfigManager:GetConfigInsByName("RogueTechTreeInfo")
    if RogueTechTreeInfoIns then
      local csCfg = RogueTechTreeInfoIns:GetValue_ByTechID(techID)
      if csCfg and csCfg:GetError() ~= true then
        rogueTechTreeInfoCfg = csCfg
        self.m_cacheRogueTechTreeCfgTab[techID] = rogueTechTreeInfoCfg
      end
    end
  end
  return rogueTechTreeInfoCfg
end

function LevelRogueStageHelper:GetAllTechTreeList()
  local allTechTreeList = self.m_allTechTreeList
  if self.m_allTechTreeList == nil then
    self.m_allTechTreeList = {}
    local RogueTechTreeInfoIns = ConfigManager:GetConfigInsByName("RogueTechTreeInfo")
    local allConfigs = RogueTechTreeInfoIns:GetAll()
    for i, v in pairs(allConfigs) do
      local uiCoordinate = v.m_UICoordinate
      if uiCoordinate and uiCoordinate.Length > 0 then
        local groupNum = uiCoordinate[0]
        local posIndex = uiCoordinate[1]
        if self.m_allTechTreeList[groupNum] == nil then
          self.m_allTechTreeList[groupNum] = {}
        end
        self.m_allTechTreeList[groupNum][posIndex] = v
      end
    end
    allTechTreeList = self.m_allTechTreeList
  end
  return allTechTreeList
end

function LevelRogueStageHelper:GetAllAndActiveTechTreeNodeNum()
  local allTechTreeList = self:GetAllTechTreeList()
  if not allTechTreeList then
    return
  end
  local allNum = 0
  local actNum = 0
  for i, layerList in ipairs(allTechTreeList) do
    if layerList and next(layerList) then
      for _, tempTreeCfg in ipairs(layerList) do
        local techTreeID = tempTreeCfg.m_TechID
        allNum = allNum + 1
        if self:IsTechNodeActive(techTreeID) == true then
          actNum = actNum + 1
        end
      end
    end
  end
  return allNum, actNum
end

function LevelRogueStageHelper:IsTechTreeOverMax(layerNum)
  if not layerNum then
    return
  end
  local allTechTreeList = self:GetAllTechTreeList()
  if not allTechTreeList then
    return
  end
  local maxTreeLayer = #allTechTreeList
  if layerNum > maxTreeLayer then
    return true
  end
  return false
end

function LevelRogueStageHelper:IsTechTreeLayerActive(layerNum)
  if not layerNum then
    return
  end
  local allTechTreeList = self:GetAllTechTreeList()
  if not allTechTreeList then
    return
  end
  local maxTreeLayer = #allTechTreeList
  if layerNum > maxTreeLayer then
    return
  end
  local layerTreeCfgList = allTechTreeList[layerNum]
  if not layerTreeCfgList or not next(layerTreeCfgList) then
    return
  end
  for i, treeCfg in ipairs(layerTreeCfgList) do
    if self:IsTechNodeActive(treeCfg.m_TechID) == true then
      return true
    end
  end
  return false
end

function LevelRogueStageHelper:GetFirstUnlockTreeLayerNum()
  local allTechTreeList = self:GetAllTechTreeList()
  if not allTechTreeList then
    return
  end
  local activeLayerNum = 1
  for layerNum, layerList in ipairs(allTechTreeList) do
    if layerList and next(layerList) then
      for index, tempTreeCfg in ipairs(layerList) do
        local techTreeID = tempTreeCfg.m_TechID
        local mainTree = tempTreeCfg.m_MainTree
        if mainTree and mainTree ~= 0 then
          if not self:IsTechNodeActive(techTreeID) then
            return activeLayerNum
          end
          activeLayerNum = layerNum
        end
      end
    end
  end
  return activeLayerNum
end

function LevelRogueStageHelper:GetAllActiveTechIDList()
  if not self.m_activeTechTreeTable then
    return {}
  end
  local techIDList = {}
  for techID, _ in pairs(self.m_activeTechTreeTable) do
    techIDList[#techIDList + 1] = techID
  end
  return techIDList
end

function LevelRogueStageHelper:GetTechEffectByType(effectType)
  if not self.m_activeTechTreeTable then
    return
  end
  local effectTab
  local techId = 0
  for techID, v in pairs(self.m_activeTechTreeTable) do
    local cfg = self:GetTechCfgByID(techID)
    if cfg and cfg.m_EffectType == effectType and techID > techId then
      techId = techID
      effectTab = cfg.m_EffectValue
    end
  end
  if effectTab then
    return utils.changeCSArrayToLuaTable(effectTab)
  end
end

function LevelRogueStageHelper:GetTechHeroModifyEffect()
  if not self.m_activeTechTreeTable then
    return
  end
  local effect = 0
  for techID, v in pairs(self.m_activeTechTreeTable) do
    local cfg = self:GetTechCfgByID(techID)
    if cfg and cfg.m_EffectType == MTTDProto.RogueTechEffect_HeroModify then
      local valueTab = utils.changeCSArrayToLuaTable(cfg.m_EffectValue)
      if valueTab and valueTab[1] and valueTab[1][1] then
        effect = effect + valueTab[1][1]
      end
    end
  end
  return effect
end

function LevelRogueStageHelper:GetHeroModifyEffectByStageId(stageId)
  local levelCfg = self:GetStageConfigById(stageId)
  local heroModify = 0
  if levelCfg then
    local balancedLevel = levelCfg.m_BalancedLevel or 0
    heroModify = self:GetTechHeroModifyEffect() + balancedLevel
  end
  return heroModify
end

function LevelRogueStageHelper:IsRogueTechCanUnlock()
  for techID, cfg in pairs(self.m_cacheRogueTechTreeCfgTab) do
    if not self:IsTechNodeActive(techID) then
      local isCanActive = self:IsTechNodeCanActive(techID)
      if isCanActive then
        return 1
      end
    end
  end
  return 0
end

local MaxCombinationNum = 4

function LevelRogueStageHelper:InitRogueItemCfg()
  local RogueStageItemInfoIns = ConfigManager:GetConfigInsByName("RogueStageItemInfo")
  local allRogueStageItem = RogueStageItemInfoIns:GetAll()
  self.m_rogueStageItemCache = {}
  self.m_rogueStageItemGroup = {}
  for i, v in pairs(allRogueStageItem) do
    if v:GetError() ~= true then
      self.m_rogueStageItemCache[v.m_ItemID] = v
      local groupID = v.m_ItemGroupID
      if self.m_rogueStageItemGroup[groupID] == nil then
        self.m_rogueStageItemGroup[groupID] = {}
      end
      self.m_rogueStageItemGroup[groupID][v.m_ItemLevel] = v
    end
  end
  self.m_rogueStageItemCombinationCache = {}
  self.m_rogueStageCombinationMapCache = {}
  self.m_rogueStageCombinationMaterialCache = {}
  local RogueStageItemCombination = ConfigManager:GetConfigInsByName("RogueStageItemCombination")
  local allRogueStageItemCombination = RogueStageItemCombination:GetAll()
  for i, v in pairs(allRogueStageItemCombination) do
    if v:GetError() ~= true then
      self.m_rogueStageItemCombinationCache[v.m_RougeItemID] = v
      self.m_rogueStageCombinationMapCache[v.m_MaterialID_1] = v
      for i = 2, MaxCombinationNum do
        local tempMaterialID = v["m_MaterialID_" .. i]
        if tempMaterialID and tempMaterialID ~= 0 then
          if self.m_rogueStageCombinationMaterialCache[tempMaterialID] == nil then
            self.m_rogueStageCombinationMaterialCache[tempMaterialID] = {}
          end
          local tempMaterialIDCacheTab = self.m_rogueStageCombinationMaterialCache[tempMaterialID]
          tempMaterialIDCacheTab[v.m_MaterialID_1] = true
        end
      end
    end
  end
end

function LevelRogueStageHelper:GetRogueItemCfgByID(itemID)
  if not itemID then
    return
  end
  return self.m_rogueStageItemCache[itemID]
end

function LevelRogueStageHelper:GetRogueItemGroupListByGroupID(itemGroupID)
  if not itemGroupID then
    return
  end
  return self.m_rogueStageItemGroup[itemGroupID]
end

function LevelRogueStageHelper:GetRogueItemCfgByGroupIDAndLv(itemGroupID, lv)
  if not itemGroupID then
    return
  end
  if not lv then
    return
  end
  local tempGroupList = self.m_rogueStageItemGroup[itemGroupID]
  if not tempGroupList then
    return
  end
  return tempGroupList[lv]
end

function LevelRogueStageHelper:GetRogueCombinationCfgByID(rogueItemID)
  if not rogueItemID then
    return
  end
  if not self.m_rogueStageItemCombinationCache then
    return
  end
  return self.m_rogueStageItemCombinationCache[rogueItemID]
end

function LevelRogueStageHelper:GetRogueCombinationCfgByMapID(rogueMapID)
  if not rogueMapID then
    return
  end
  if not self.m_rogueStageCombinationMapCache then
    return
  end
  return self.m_rogueStageCombinationMapCache[rogueMapID]
end

function LevelRogueStageHelper:GetRogueCombinationMaterialIDListByMapID(rogueMapID)
  if not rogueMapID then
    return
  end
  local rogueStageCombinationCfg = self:GetRogueCombinationCfgByMapID(rogueMapID)
  if not rogueStageCombinationCfg then
    return
  end
  local materialIDList = {}
  for i = 2, MaxCombinationNum do
    local tempMaterialID = rogueStageCombinationCfg["m_MaterialID_" .. i]
    if tempMaterialID and tempMaterialID ~= 0 then
      materialIDList[#materialIDList + 1] = tempMaterialID
    end
  end
  return materialIDList
end

function LevelRogueStageHelper:GetRogueCombinationMapIDTabByMaterialID(rogueMaterialID)
  if not rogueMaterialID then
    return
  end
  if not self.m_rogueStageCombinationMaterialCache then
    return
  end
  return self.m_rogueStageCombinationMaterialCache[rogueMaterialID]
end

function LevelRogueStageHelper:GetRogueCombinationMapIDListByMaterialID(rogueMaterialID)
  if not rogueMaterialID then
    return
  end
  local mapCacheTab = self:GetRogueCombinationMapIDTabByMaterialID(rogueMaterialID)
  if not mapCacheTab then
    return
  end
  local mapIDList = {}
  for id, v in pairs(mapCacheTab) do
    if v == true then
      mapIDList[#mapIDList + 1] = id
    end
  end
  return mapIDList
end

function LevelRogueStageHelper:IsRogueMapMaterialByItemCfg(rogueItemCfg)
  if not rogueItemCfg then
    return
  end
  local itemType = rogueItemCfg.m_ItemType
  local itemSubType = rogueItemCfg.m_ItemSubType
  if itemType == RogueStageManager.RogueStageItemType.Material and (itemSubType == RogueStageManager.RogueStageItemSubType.CommonMap or itemSubType == RogueStageManager.RogueStageItemSubType.ExclusiveMap) then
    return true
  end
  return false
end

function LevelRogueStageHelper:IsRogueMaterialByItemCfg(rogueItemCfg)
  if not rogueItemCfg then
    return
  end
  local itemType = rogueItemCfg.m_ItemType
  local itemSubType = rogueItemCfg.m_ItemSubType
  if itemType == RogueStageManager.RogueStageItemType.Material and itemSubType == RogueStageManager.RogueStageItemSubType.CommonMaterial then
    return true
  end
  return false
end

function LevelRogueStageHelper:GetRougeItemSubTypeInfoCfgBySubType(sybType)
  local RougeItemSubTypeInfoIns = ConfigManager:GetConfigInsByName("RougeItemSubTypeInfo")
  local cfg = RougeItemSubTypeInfoIns:GetValue_ByItemSubType(sybType)
  if cfg:GetError() then
    log.error("can not find GetRougeItemSubTypeInfoCfgBySubType Cfg sybType ==" .. tostring(sybType))
    return
  end
  return cfg
end

function LevelRogueStageHelper:GetRogueItemIconPosById(itemID)
  if self.m_cacheRogueItemIconPosCfgTab and self.m_cacheRogueItemIconPosCfgTab[itemID] then
    return self.m_cacheRogueItemIconPosCfgTab[itemID]
  end
  local RogueItemIconPosIns = ConfigManager:GetConfigInsByName("RogueItemIconPos")
  local cfg = RogueItemIconPosIns:GetValue_ByItemID(itemID)
  if cfg:GetError() then
    log.error("can not find GetRogueItemIconPosById Cfg itemID ==" .. tostring(itemID))
    return
  end
  return cfg
end

function LevelRogueStageHelper:GetRogueStageItemCombination(itemId, includeHeroIdList, isHaveItemIds)
  local RogueStageItemCombinationIns = ConfigManager:GetConfigInsByName("RogueStageItemCombination")
  local cfgAll = RogueStageItemCombinationIns:GetAll()
  local combinationList = {}
  local itemCfg = self:GetRogueItemCfgByID(itemId)
  if itemCfg and itemCfg.m_ItemType == RogueStageManager.RogueStageItemType.Product then
    local combinationCfg = self:GetRogueCombinationCfgByID(itemId)
    if combinationCfg then
      local sort = RogueStageManager.RegionTypeSort.Normal
      if itemCfg.m_TechID ~= 0 and not self:IsTechNodeActive(itemCfg.m_TechID) then
        sort = RogueStageManager.RegionTypeSort.Exclusive
      end
      local haveList, synthesisFlag = self:CheckRogueItemCanSynthesis(isHaveItemIds, itemId)
      local showTitle = sort == RogueStageManager.RegionTypeSort.Exclusive
      combinationList[1] = {
        materialId0 = itemId,
        materialId1 = combinationCfg.m_MaterialID_1,
        materialId2 = combinationCfg.m_MaterialID_2,
        materialId3 = combinationCfg.m_MaterialID_3,
        materialId4 = combinationCfg.m_MaterialID_4,
        cfg = combinationCfg,
        sort = sort,
        id = itemId,
        showTitle = showTitle,
        haveItemList = haveList,
        synthesisFlag = synthesisFlag,
        checkIsHave = isHaveItemIds ~= nil
      }
      return combinationList
    end
  end
  for rougeItemId, v in pairs(cfgAll) do
    for m = 1, MaxCombinationNum do
      if v["m_MaterialID_" .. m] == itemId then
        local sort = RogueStageManager.RegionTypeSort.Normal
        local cfg = self:GetRogueItemCfgByID(rougeItemId)
        if cfg.m_ItemSubType == RogueStageManager.RogueStageItemSubType.CharacterEquip and 0 < table.getn(includeHeroIdList) and not table.indexof(includeHeroIdList, cfg.m_Character) then
          sort = RogueStageManager.RegionTypeSort.Exclusive
        end
        if cfg.m_TechID ~= 0 and not self:IsTechNodeActive(cfg.m_TechID) then
          sort = RogueStageManager.RegionTypeSort.Exclusive
        end
        local haveList, synthesisFlag = self:CheckRogueItemCanSynthesis(isHaveItemIds, rougeItemId)
        combinationList[#combinationList + 1] = {
          materialId0 = rougeItemId,
          materialId1 = v.m_MaterialID_1,
          materialId2 = v.m_MaterialID_2,
          materialId3 = v.m_MaterialID_3,
          materialId4 = v.m_MaterialID_4,
          sort = sort,
          id = rougeItemId,
          haveItemList = haveList,
          synthesisFlag = synthesisFlag,
          checkIsHave = isHaveItemIds ~= nil
        }
      end
    end
  end
  local combinationMap = {}
  for i = #combinationList, 1, -1 do
    if combinationMap[combinationList[i].materialId0] then
      combinationList[i] = nil
    else
      combinationMap[combinationList[i].materialId0] = 1
    end
  end
  local tempList = {}
  for i, v in pairs(combinationList) do
    tempList[#tempList + 1] = v
  end
  
  local function sortFun(data1, data2)
    if data1.sort == data2.sort then
      return data1.id < data2.id
    else
      return data1.sort < data2.sort
    end
  end
  
  table.sort(tempList, sortFun)
  local showTitle = false
  for i, v in ipairs(tempList) do
    if not showTitle and v.sort == RogueStageManager.RegionTypeSort.Exclusive then
      showTitle = true
      v.showTitle = true
    end
  end
  return tempList
end

function LevelRogueStageHelper:SetRogueBagData(bagDataList)
  self.m_rogueBagDataList = bagDataList
end

function LevelRogueStageHelper:GetRogueBagData()
  return self.m_rogueBagDataList
end

function LevelRogueStageHelper:CheckRogueItemCanSynthesis(isHaveItemIds, rogueItemID)
  local list = {}
  local synthesisFlag = false
  if table.getn(isHaveItemIds) == 0 or not rogueItemID then
    return list, synthesisFlag
  end
  local itemIds = table.deepcopy(isHaveItemIds)
  local cfg = self:GetRogueCombinationCfgByID(rogueItemID)
  local count = 0
  if cfg then
    for i = 1, MaxCombinationNum do
      local tempMaterialID = cfg["m_MaterialID_" .. i]
      if tempMaterialID and tempMaterialID ~= 0 then
        local index = table.indexof(itemIds, tempMaterialID)
        if index then
          table.remove(itemIds, index)
          list[#list + 1] = tempMaterialID
        end
        count = count + 1
      end
    end
    local index = table.indexof(itemIds, rogueItemID)
    if index then
      list[#list + 1] = rogueItemID
    end
  end
  return list, table.getn(list) == count
end

function LevelRogueStageHelper:GetRogueServerData()
  return self.m_stRogue or MTTDProto.Cmd_Rogue_GetData_SC().stRogue
end

function LevelRogueStageHelper:GetRogueHandBookCfgs()
  if self.m_RogueHandBookCfgs then
    return self.m_RogueHandBookCfgs
  end
  local ins = ConfigManager:GetConfigInsByName("RogueStageItemInfo")
  local all_config_dic = ins:GetAll()
  local configs = {}
  configs[RogueStageManager.HandBookType.Exclusive] = {}
  configs[RogueStageManager.HandBookType.Normal] = {}
  configs[RogueStageManager.HandBookType.Material] = {}
  for k, v in pairs(all_config_dic) do
    if v.m_HandbookType and v.m_HandbookType ~= 0 then
      table.insert(configs[v.m_HandbookType], {cfg = v})
    end
  end
  for i, v in pairs(configs) do
    table.sort(v, function(a, b)
      return a.cfg.m_HandbookOrder < b.cfg.m_HandbookOrder
    end)
  end
  self.m_RogueHandBookCfgs = configs
  return configs
end

function LevelRogueStageHelper:IsRogueHandBookItemHaveNew(params)
  local id = params.id
  local bIsActive = params.bIsActive
  if not bIsActive then
    return 0
  end
  local localValue = LocalDataManager:GetIntSimple("RogueHandBookItem_ID_" .. id, 0)
  if localValue == 0 then
    return 1
  end
  return 0
end

function LevelRogueStageHelper:IsRogueHandBookTabHaveNew(iHandBookType)
  local HandBookCfgs = self:GetRogueHandBookCfgs()
  if not HandBookCfgs then
    return 0
  end
  local cfgs = HandBookCfgs[iHandBookType]
  if not cfgs then
    return 0
  end
  local stRogue = self:GetRogueServerData()
  if not stRogue then
    return 0
  end
  local mHandbook = stRogue.mHandbook
  if not mHandbook then
    return 0
  end
  for i, v in ipairs(cfgs) do
    local params = {
      id = v.cfg.m_ItemID,
      bIsActive = mHandbook[v.cfg.m_ItemID] ~= nil and 0 < mHandbook[v.cfg.m_ItemID]
    }
    if self:IsRogueHandBookItemHaveNew(params) == 1 then
      return 1
    end
  end
  return 0
end

function LevelRogueStageHelper:CheckRogueHandBookEntryReddot()
  local HandBookCfgs = self:GetRogueHandBookCfgs()
  if not HandBookCfgs then
    return 0
  end
  local stRogue = self:GetRogueServerData()
  if not stRogue then
    return 0
  end
  local mHandbook = stRogue.mHandbook
  if not mHandbook then
    return 0
  end
  for _, cfgs in ipairs(HandBookCfgs) do
    for _, v in ipairs(cfgs) do
      local params = {
        id = v.cfg.m_ItemID,
        bIsActive = mHandbook[v.cfg.m_ItemID] ~= nil and 0 < mHandbook[v.cfg.m_ItemID]
      }
      if self:IsRogueHandBookItemHaveNew(params) == 1 then
        return 1
      end
    end
  end
  return 0
end

function LevelRogueStageHelper:CheckRogueEntryHaveRedPoint()
  local count = 0
  count = RogueStageManager:CheckDailyRedPoint()
  if 0 < count then
    return count
  end
  count = self:CheckRogueHandBookEntryReddot()
  if 0 < count then
    return count
  end
  count = TaskManager:CheckRogueAchievementEntryReddot()
  if 0 < count then
    return count
  end
  count = self:IsRogueTechCanUnlock()
  if 0 < count then
    return count
  end
  count = self:IsHaveRewards() == true and 1 or 0
  if 0 < count then
    return count
  end
  count = self:IsHaveNewStage()
  return count
end

return LevelRogueStageHelper
