local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local LegacyLevelManager = class("LegacyLevelManager", BaseLevelManager)
local table_sort = table.sort
local tostring = _ENV.tostring
local ipairs = _ENV.ipairs
local next = _ENV.next
local pairs = _ENV.pairs
LegacyLevelManager.ChapterTypeEnum = {Normal = 1, ExChapter = 2}

function LegacyLevelManager:OnCreate()
  self.m_curLevelType = nil
  self.m_curLevelID = nil
  self.m_chapterRewardDic = {}
  self.m_legacyStageLevelDic = {}
  self.m_haveRecordLevelIDList = {}
  self.m_levelCfgCache = {}
  self.m_chapterCfgCache = {}
  self.m_normalChapterList = {}
  self.m_exChapterList = {}
  self.m_chapterDic = {}
  self.m_LegacyStageChapterIns = nil
  self.m_LegacyStageLevelIns = nil
  self.m_legacyGuideList = nil
  self.m_levelIDWatchRecordList = nil
  self:AddEventListener()
end

function LegacyLevelManager:OnInitNetwork()
  RPCS():Listen_Push_LegacyStage(handler(self, self.OnPushLegacyStage), "LegacyLevelManager")
end

function LegacyLevelManager:OnAfterFreshData()
  self:InitGlobalCfg()
  self:InitLevelCfgData()
  self:ReqLegacyStageGetInit()
end

function LegacyLevelManager:OnDailyReset()
end

function LegacyLevelManager:OnUpdate(dt)
end

function LegacyLevelManager:AddEventListener()
end

function LegacyLevelManager:OnPushLegacyStage(stPushLegacyStageInfo, msg)
  if not stPushLegacyStageInfo then
    return
  end
  local haveRecordLevelIDList = stPushLegacyStageInfo.vGameLevelId or {}
  self.m_haveRecordLevelIDList = haveRecordLevelIDList
  self:broadcastEvent("eGameEvent_LegacyLevel_LegacyStagePush")
end

function LegacyLevelManager:ReqLegacyStageGetInit()
  local msg = MTTDProto.Cmd_LegacyStage_GetInit_CS()
  RPCS():LegacyStage_GetInit(msg, handler(self, self.OnLegacyStageGetInit))
end

function LegacyLevelManager:OnLegacyStageGetInit(stLegacyStageInitInfo, msg)
  if not stLegacyStageInitInfo then
    return
  end
  self.m_chapterRewardDic = stLegacyStageInitInfo.mChapter
  self.m_legacyStageLevelDic = stLegacyStageInitInfo.mLevel
  self.m_haveRecordLevelIDList = stLegacyStageInitInfo.vGameLevelId
end

function LegacyLevelManager:ReqLegacyStageGameReset(levelID)
  if not levelID then
    return
  end
  local msg = MTTDProto.Cmd_LegacyStage_GameReset_CS()
  msg.iLevelId = levelID
  RPCS():LegacyStage_GameReset(msg, handler(self, self.OnLegacyStageGameResetSC))
end

function LegacyLevelManager:OnLegacyStageGameResetSC(stLegacyStageResetInfo, msg)
  if not stLegacyStageResetInfo then
    return
  end
  local levelID = stLegacyStageResetInfo.iLevelId
  self:ClearLegacyLevelRecord(levelID)
  self:broadcastEvent("eGameEvent_LegacyLevel_StageReset", {levelID = levelID})
end

function LegacyLevelManager:ReqLegacyStageTakeChapterReward(chapterID)
  if not chapterID then
    return
  end
  local msg = MTTDProto.Cmd_LegacyStage_TakeChapterReward_CS()
  msg.iChapterId = chapterID
  RPCS():LegacyStage_TakeChapterReward(msg, handler(self, self.OnLegacyStageTakeChapterRewardSC))
end

function LegacyLevelManager:OnLegacyStageTakeChapterRewardSC(stLegacyStageTakeChapterRewardInfo, msg)
  if not stLegacyStageTakeChapterRewardInfo then
    return
  end
  if stLegacyStageTakeChapterRewardInfo.vReward and next(stLegacyStageTakeChapterRewardInfo.vReward) then
    utils.popUpRewardUI(stLegacyStageTakeChapterRewardInfo.vReward)
  end
  local chapterID = stLegacyStageTakeChapterRewardInfo.iChapterId
  self:SetChapterRewardHaveCord(chapterID)
  self:broadcastEvent("eGameEvent_LegacyLevel_GetChapterReward", {chapterID = chapterID})
end

function LegacyLevelManager:InitGlobalCfg()
  LegacyLevelManager.LevelType = {
    LegacyLevel = MTTDProto.FightType_LegacyStage
  }
  LegacyLevelManager.LegacyLevelType = {LegacyLevel = 1, ActivityLevel = 2}
end

function LegacyLevelManager:InitLevelCfgData()
  self.m_LegacyStageChapterIns = ConfigManager:GetConfigInsByName("LegacyStageChapterInfo")
  self.m_LegacyStageLevelIns = ConfigManager:GetConfigInsByName("LegacyStageLevelInfo")
  local allLevelDic = self.m_LegacyStageLevelIns:GetAll()
  for _, levelCfg in pairs(allLevelDic) do
    local chapterID = levelCfg.m_ChapterID
    local chapterData = self.m_chapterDic[chapterID]
    if chapterData == nil then
      local chapterInfoCfg = self.m_LegacyStageChapterIns:GetValue_ByChapterID(chapterID)
      if chapterInfoCfg:GetError() ~= true then
        chapterData = {
          chapterCfg = chapterInfoCfg,
          levelList = {},
          exChapterData = nil
        }
        if chapterInfoCfg.m_ChapterType == LegacyLevelManager.ChapterTypeEnum.Normal then
          self.m_normalChapterList[#self.m_normalChapterList + 1] = chapterData
        else
          self.m_exChapterList[#self.m_exChapterList + 1] = chapterData
        end
        self.m_chapterDic[chapterID] = chapterData
      end
    end
    if chapterData then
      chapterData.levelList[#chapterData.levelList + 1] = levelCfg
    end
  end
  for _, tempChapterData in ipairs(self.m_exChapterList) do
    local preChapterID = tempChapterData.chapterCfg.m_PreChapterID
    local normalChapterData = self.m_chapterDic[preChapterID]
    if normalChapterData then
      normalChapterData.exChapterData = tempChapterData
    end
  end
  self:FreshChapterListToSort()
end

function LegacyLevelManager:FreshChapterListToSort()
  self.m_normalChapterList = self:ChangeChapterToSort(self.m_normalChapterList, 0)
  for _, chapterData in ipairs(self.m_normalChapterList) do
    local levelList = chapterData.levelList
    chapterData.levelList = self:ChangeLevelListToSort(levelList, 0)
  end
  for _, chapterData in ipairs(self.m_exChapterList) do
    local levelList = chapterData.levelList
    chapterData.levelList = self:ChangeLevelListToSort(levelList, 0)
  end
end

function LegacyLevelManager:ChangeChapterToSort(chapterDataList, startCheckID)
  if not chapterDataList or not next(chapterDataList) then
    return
  end
  local startChapterLen = #chapterDataList
  startCheckID = startCheckID or 0
  local tempChapterDic = {}
  local startChapterID
  for _, chapterData in ipairs(chapterDataList) do
    if chapterData then
      if chapterData.chapterCfg.m_PreChapterID == startCheckID then
        startChapterID = chapterData.chapterCfg.m_ChapterID
      end
      tempChapterDic[chapterData.chapterCfg.m_ChapterID] = {chapterData = chapterData, nextID = nil}
    end
  end
  for _, chapterData in ipairs(chapterDataList) do
    if chapterData and chapterData.chapterCfg.m_PreChapterID ~= startCheckID then
      local preChapterID = chapterData.chapterCfg.m_PreChapterID
      if tempChapterDic[preChapterID] then
        tempChapterDic[preChapterID].nextID = chapterData.chapterCfg.m_ChapterID
      end
    end
  end
  local sortChapterList = {}
  local tempChapterID = startChapterID
  local tempStartChapterData = tempChapterDic[tempChapterID]
  if not tempStartChapterData then
    log.error("LegacyLevelManager ChapterList cannot to a list startChapterID: " .. tostring(tempChapterID) .. " startCheckID: " .. startCheckID)
    return
  end
  sortChapterList[#sortChapterList + 1] = tempChapterDic[tempChapterID].chapterData
  while tempChapterDic[tempChapterID].nextID ~= nil do
    tempChapterID = tempChapterDic[tempChapterID].nextID
    if tempChapterDic[tempChapterID] then
      sortChapterList[#sortChapterList + 1] = tempChapterDic[tempChapterID].chapterData
    end
  end
  local endChapterLen = #sortChapterList
  if startChapterLen ~= endChapterLen then
    log.error("LegacyLevelManager ChapterList after sort have reduce Chapter startChapterLen: " .. tostring(startChapterLen) .. " endChapterLen: " .. tostring(endChapterLen) .. " firstChapterID: " .. sortChapterList[1].chapterCfg.m_ChapterID)
  end
  return sortChapterList
end

function LegacyLevelManager:ChangeLevelListToSort(levelList, startCheckID)
  if not levelList or not next(levelList) then
    return {}
  end
  local startLen = #levelList
  startCheckID = startCheckID or 0
  local tempLevelDic = {}
  local startLevelID
  for _, levelCfg in ipairs(levelList) do
    if levelCfg then
      if levelCfg.m_PreLevelID == startCheckID then
        startLevelID = levelCfg.m_LevelID
      end
      tempLevelDic[levelCfg.m_LevelID] = {levelCfg = levelCfg, nextID = nil}
    end
  end
  for _, levelCfg in ipairs(levelList) do
    if levelCfg and levelCfg.m_PreLevelID ~= startCheckID then
      local unlockLevelID = levelCfg.m_PreLevelID
      if tempLevelDic[unlockLevelID] then
        tempLevelDic[unlockLevelID].nextID = levelCfg.m_LevelID
      end
    end
  end
  local sortLevelList = {}
  local tempLevelID = startLevelID
  local tempStartLevelData = tempLevelDic[tempLevelID]
  if not tempStartLevelData then
    log.error("LegacyLevelManager ChangeLevelListToSort cannot to a list startLevelID: " .. tostring(tempLevelID) .. " startCheckID: " .. tostring(startCheckID))
    return
  end
  sortLevelList[#sortLevelList + 1] = tempLevelDic[tempLevelID].levelCfg
  while tempLevelDic[tempLevelID].nextID ~= nil do
    tempLevelID = tempLevelDic[tempLevelID].nextID
    if tempLevelDic[tempLevelID] then
      sortLevelList[#sortLevelList + 1] = tempLevelDic[tempLevelID].levelCfg
    end
  end
  local endLevelLen = #sortLevelList
  if startLen ~= endLevelLen then
    log.error("LegacyLevelManager ChangeLevelListToSort after sort have reduce level startLen: " .. tostring(startLen) .. " endLevelLen: " .. tostring(endLevelLen) .. " firstLevelID: " .. sortLevelList[1].m_LevelID)
  end
  return sortLevelList
end

function LegacyLevelManager:CreateLegacyGuideList()
  if self.m_legacyGuideList then
    return
  end
  if next(self.m_chapterDic) == nil then
    self:InitLevelCfgData()
  end
  local legacyIns = ConfigManager:GetConfigInsByName("Legacy")
  self.m_legacyGuideList = {}
  local allLegacyDic = legacyIns:GetAll()
  for _, tempLegacyCfg in pairs(allLegacyDic) do
    local legacyChapterID = tempLegacyCfg.m_LegacyChapterID
    local chapterCfg = self:GetChapterConfigByID(legacyChapterID)
    if chapterCfg then
      local sortNum = tempLegacyCfg.m_Order
      local tempLegacyGuideData = {
        legacyCfg = tempLegacyCfg,
        legacyChapterCfg = chapterCfg,
        sortOrder = sortNum
      }
      self.m_legacyGuideList[#self.m_legacyGuideList + 1] = tempLegacyGuideData
    end
  end
  table_sort(self.m_legacyGuideList, function(a, b)
    return a.sortOrder < b.sortOrder
  end)
end

function LegacyLevelManager:ClearLegacyLevelRecord(levelID)
  if not levelID then
    return
  end
  if not self.m_haveRecordLevelIDList then
    return
  end
  for i, tempLevelID in ipairs(self.m_haveRecordLevelIDList) do
    if levelID == tempLevelID then
      table.remove(self.m_haveRecordLevelIDList, i)
    end
  end
end

function LegacyLevelManager:SetChapterRewardHaveCord(chapterID)
  if not chapterID then
    return
  end
  if not self.m_chapterRewardDic then
    return
  end
  local tempChapterData = self.m_chapterRewardDic[chapterID]
  if not tempChapterData then
    tempChapterData = {iChapterId = chapterID}
    self.m_chapterRewardDic[chapterID] = tempChapterData
  end
  tempChapterData.bRewardTaken = true
end

function LegacyLevelManager:BattleSucFreshDataStatus(levelType, levelID, legacyLevelData)
  if not levelType then
    return
  end
  if levelType ~= LegacyLevelManager.LevelType.LegacyLevel then
    return
  end
  if not levelID then
    return
  end
  local levelStageInfo = self.m_legacyStageLevelDic[levelID] or {}
  levelStageInfo.iLevelId = levelID
  levelStageInfo.iPassTimes = legacyLevelData.iPassTimes or 0
  self.m_legacyStageLevelDic[levelID] = levelStageInfo
  self:ClearLegacyLevelRecord(levelID)
  self:CheckFreshLevelIDWatchRecordToServer(levelID)
end

function LegacyLevelManager:IsLevelIDHaveWatchRecord(levelID)
  if not levelID then
    return
  end
  local levelIDRecordList = self:GetFreshLevelIDWatchRecordList()
  if not levelIDRecordList then
    return
  end
  for _, tempLevelID in ipairs(levelIDRecordList) do
    if tempLevelID == levelID then
      return true
    end
  end
end

function LegacyLevelManager:GetFreshLevelIDWatchRecordList()
  if not self.m_levelIDWatchRecordList then
    local tempRecordList = {}
    local clientRecordStr = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.LegacyLevel)
    if clientRecordStr ~= nil or clientRecordStr ~= "" then
      local recordLevelIDStrList = string.split(clientRecordStr, "_")
      for _, levelStr in ipairs(recordLevelIDStrList) do
        local levelNum = tonumber(levelStr)
        if self:IsLevelUnlock(levelNum) == true and self:IsLevelHavePass(levelNum) ~= true then
          tempRecordList[#tempRecordList + 1] = levelNum
        end
      end
    end
    self.m_levelIDWatchRecordList = tempRecordList
  end
  return self.m_levelIDWatchRecordList
end

function LegacyLevelManager:GetLevelRecordWatchClientStr()
  local levelIDWatchRecordList = self:GetFreshLevelIDWatchRecordList()
  if not levelIDWatchRecordList then
    return
  end
  local tempTab = {}
  for i, v in ipairs(levelIDWatchRecordList) do
    if i == 1 then
      tempTab[#tempTab + 1] = tostring(v)
    else
      tempTab[#tempTab + 1] = "_"
      tempTab[#tempTab + 1] = tostring(v)
    end
  end
  if #tempTab == 0 then
    return ""
  else
    return table.concat(tempTab)
  end
end

function LegacyLevelManager:SetLevelRecordWatchToServer()
  ClientDataManager:SetClientValue(ClientDataManager.ClientKeyType.LegacyLevel, self:GetLevelRecordWatchClientStr())
  self:broadcastEvent("eGameEvent_LegacyLevel_LevelWatchRecordFresh")
end

function LegacyLevelManager:SetNewLevelIDWatchRecord(levelID)
  if not levelID then
    return
  end
  if self:IsLevelIDHaveWatchRecord(levelID) ~= true then
    self.m_levelIDWatchRecordList[#self.m_levelIDWatchRecordList + 1] = levelID
    self:SetLevelRecordWatchToServer()
  end
end

function LegacyLevelManager:CheckFreshLevelIDWatchRecordToServer(havePassLevelID)
  if not havePassLevelID then
    return
  end
  local levelIDRecordList = self:GetFreshLevelIDWatchRecordList()
  if not levelIDRecordList then
    return
  end
  local isInRecord = false
  for i, recordLevelID in ipairs(levelIDRecordList) do
    if recordLevelID == havePassLevelID then
      isInRecord = true
      table.remove(levelIDRecordList, i)
    end
  end
  if isInRecord then
    self:SetLevelRecordWatchToServer()
  end
end

function LegacyLevelManager:GetLevelConfigByID(levelID)
  if not self.m_LegacyStageLevelIns then
    return
  end
  if not levelID then
    return
  end
  local levelCfg
  levelCfg = self.m_levelCfgCache[levelID]
  if not levelCfg then
    local tempCfg = self.m_LegacyStageLevelIns:GetValue_ByLevelID(levelID)
    if tempCfg:GetError() ~= true then
      levelCfg = tempCfg
      self.m_levelCfgCache[levelID] = levelCfg
    end
  end
  return levelCfg
end

function LegacyLevelManager:GetChapterConfigByID(chapterID)
  if not self.m_LegacyStageChapterIns then
    return
  end
  if not chapterID then
    return
  end
  local chapterCfg
  chapterCfg = self.m_chapterCfgCache[chapterID]
  if not chapterCfg then
    local tempCfg = self.m_LegacyStageChapterIns:GetValue_ByChapterID(chapterID)
    if tempCfg:GetError() ~= true then
      chapterCfg = tempCfg
      self.m_chapterCfgCache[chapterID] = chapterCfg
    end
  end
  return chapterCfg
end

function LegacyLevelManager:IsLevelHavePass(levelID)
  if not levelID then
    return
  end
  if levelID == 0 then
    return true
  end
  local levelStageInfo = self.m_legacyStageLevelDic[levelID] or {}
  local passTimes = levelStageInfo.iPassTimes or 0
  return 0 < passTimes
end

function LegacyLevelManager:IsChapterLevelAllHavePass(chapterID)
  if not chapterID then
    return
  end
  local chapterData = self.m_chapterDic[chapterID]
  if not chapterData then
    return
  end
  local levelList = chapterData.levelList
  if not levelList then
    return
  end
  if #levelList == 0 then
    return true
  end
  local lastLevelCfg = levelList[#levelList]
  if not lastLevelCfg then
    return
  end
  return self:IsLevelHavePass(lastLevelCfg.m_LevelID)
end

function LegacyLevelManager:IsChapterUnlock(chapterID)
  if not chapterID then
    return
  end
  if chapterID == 0 then
    return
  end
  local chapterCfg = self:GetChapterConfigByID(chapterID)
  if not chapterCfg then
    return
  end
  local unlockMainLevelID = chapterCfg.m_UnlockMainLevel
  if not unlockMainLevelID then
    return
  end
  if unlockMainLevelID ~= 0 and LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, unlockMainLevelID) ~= true then
    return false
  end
  local preChapterID = chapterCfg.m_PreChapterID
  if preChapterID == 0 then
    return true
  end
  return self:IsChapterLevelAllHavePass(preChapterID)
end

function LegacyLevelManager:IsLevelUnlock(levelID)
  if not levelID then
    return
  end
  local levelCfg = self:GetLevelConfigByID(levelID)
  if not levelCfg then
    return
  end
  local chapterID = levelCfg.m_ChapterID
  if not chapterID then
    return
  end
  local isChapterUnlock = self:IsChapterUnlock(chapterID)
  if isChapterUnlock ~= true then
    return
  end
  local preLevelID = levelCfg.m_PreLevelID
  if not preLevelID then
    return
  end
  return self:IsLevelHavePass(preLevelID)
end

function LegacyLevelManager:GetNormalChapterList()
  return self.m_normalChapterList or {}
end

function LegacyLevelManager:GetChapterProgressNum(chapterID)
  if not chapterID then
    return
  end
  local chapterData = self.m_chapterDic[chapterID]
  if not chapterData then
    return
  end
  local levelList = chapterData.levelList
  local totalLevelLen = #levelList
  if totalLevelLen <= 0 then
    return
  end
  local havePassLevelNum = 0
  for _, levelCfg in ipairs(levelList) do
    local isHavePass = self:IsLevelHavePass(levelCfg.m_LevelID)
    if isHavePass == true then
      havePassLevelNum = havePassLevelNum + 1
    else
      break
    end
  end
  return havePassLevelNum / totalLevelLen, havePassLevelNum, totalLevelLen
end

function LegacyLevelManager:IsLevelHaveRecord(levelID)
  if not levelID then
    return
  end
  for i, tempLevelID in ipairs(self.m_haveRecordLevelIDList) do
    if levelID == tempLevelID then
      return true
    end
  end
  return false
end

function LegacyLevelManager:IsChapterRewardHaveGet(chapterID)
  if not chapterID then
    return
  end
  local chapterRewardData = self.m_chapterRewardDic[chapterID]
  if not chapterRewardData then
    return
  end
  return chapterRewardData.bRewardTaken
end

function LegacyLevelManager:GetLegacyGuideDataList()
  if not self.m_legacyGuideList then
    self:CreateLegacyGuideList()
  end
  return self.m_legacyGuideList
end

function LegacyLevelManager:IsLevelEntryHaveRedDot(levelType)
  local redDotPoint = 0
  if not levelType then
    return redDotPoint
  end
  if levelType ~= LegacyLevelManager.LevelType.LegacyLevel then
    return redDotPoint
  end
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.LegacyLevel)
  if isOpen ~= true then
    return redDotPoint
  end
  redDotPoint = redDotPoint + (self:IsAllChapterHaveRedDot() or 0)
  if 0 < redDotPoint then
    return redDotPoint
  end
  redDotPoint = redDotPoint + (LegacyManager:IsAllLegacyEnterHaveRedDot() or 0)
  return redDotPoint
end

function LegacyLevelManager:IsAllChapterHaveRedDot()
  if not self.m_chapterDic then
    return 0
  end
  local redDotPoint = 0
  for _, chapterData in pairs(self.m_chapterDic) do
    local chapterID = chapterData.chapterCfg.m_ChapterID
    local tempChapterRedDotPoint = self:IsChapterEntryHaveRedDot(chapterID) or 0
    if 0 < tempChapterRedDotPoint then
      redDotPoint = redDotPoint + tempChapterRedDotPoint
      return redDotPoint
    end
  end
  return redDotPoint
end

function LegacyLevelManager:IsChapterEntryHaveRedDot(chapterID)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.LegacyLevel)
  if isOpen ~= true then
    return 0
  end
  local redDotPoint = 0
  if not chapterID then
    return redDotPoint
  end
  local chapterData = self.m_chapterDic[chapterID]
  if not chapterData then
    return redDotPoint
  end
  redDotPoint = redDotPoint + (self:IsChapterHaveRewardRedDot(chapterID) or 0)
  if 0 < redDotPoint then
    return redDotPoint
  end
  redDotPoint = redDotPoint + (self:IsChapterHaveNewLevelRedDot(chapterID) or 0)
  if 0 < redDotPoint then
    return redDotPoint
  end
  redDotPoint = redDotPoint + (self:IsChapterHaveDailyRedDot(chapterID) or 0)
  if 0 < redDotPoint then
    return redDotPoint
  end
  return redDotPoint
end

function LegacyLevelManager:IsChapterHaveDailyRedDot(chapterID)
  local redDotPoint = 0
  if not chapterID then
    return redDotPoint
  end
  local chapterData = self.m_chapterDic[chapterID]
  if not chapterData then
    return redDotPoint
  end
  local _, combat = HeroManager:GetTopFiveHeroByCombat()
  local time = TimeUtil:GetServerTimeS()
  if self:IsChapterUnlock(chapterID) == true and self:IsChapterLevelAllHavePass(chapterID) ~= true then
    local levelList = chapterData.levelList
    for _, levelCfg in ipairs(levelList) do
      local levelID = levelCfg.m_LevelID
      if self:IsLevelHavePass(levelID) ~= true and self:IsLevelUnlock(levelID) == true then
        local power = 0
        local tab = utils.changeCSArrayToLuaTable(levelCfg.m_Power)
        for i, v in ipairs(tab) do
          if v > power then
            power = v
          end
        end
        local nextTime = LocalDataManager:GetIntSimple("Red_Point_DailyLegacyLevel_" .. chapterID, 0)
        if combat > power and time > nextTime then
          redDotPoint = redDotPoint + 1
        end
      end
    end
  end
  return redDotPoint
end

function LegacyLevelManager:IsChapterHaveNewLevelRedDot(chapterID)
  local redDotPoint = 0
  if not chapterID then
    return redDotPoint
  end
  local chapterData = self.m_chapterDic[chapterID]
  if not chapterData then
    return redDotPoint
  end
  if self:IsChapterUnlock(chapterID) == true and self:IsChapterLevelAllHavePass(chapterID) ~= true then
    local levelList = chapterData.levelList
    for _, levelCfg in ipairs(levelList) do
      local levelID = levelCfg.m_LevelID
      if self:IsLevelHavePass(levelID) ~= true and self:IsLevelUnlock(levelID) == true then
        local isHaveWatchRecord = self:IsLevelIDHaveWatchRecord(levelID)
        if isHaveWatchRecord ~= true then
          redDotPoint = redDotPoint + 1
          return redDotPoint
        end
      end
    end
  end
  return redDotPoint
end

function LegacyLevelManager:IsChapterHaveRewardRedDot(chapterID)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.LegacyLevel)
  if isOpen ~= true then
    return 0
  end
  if not chapterID then
    return 0
  end
  local chapterData = self.m_chapterDic[chapterID]
  if not chapterData then
    return 0
  end
  local isAllHavePass = self:IsChapterLevelAllHavePass(chapterID)
  if isAllHavePass ~= true then
    return 0
  end
  local isRewardHaveGet = self:IsChapterRewardHaveGet(chapterID)
  if isRewardHaveGet == true then
    return 0
  end
  return 1
end

function LegacyLevelManager:CheckSetChapterWatchStatus(chapterID)
  if not chapterID then
    return
  end
  local chapterData = self.m_chapterDic[chapterID]
  if not chapterData then
    return
  end
  if self:IsChapterUnlock(chapterID) == true and self:IsChapterLevelAllHavePass(chapterID) ~= true then
    local levelList = chapterData.levelList
    for _, levelCfg in ipairs(levelList) do
      local levelID = levelCfg.m_LevelID
      if self:IsLevelHavePass(levelID) ~= true and self:IsLevelUnlock(levelID) == true then
        local isHaveWatchRecord = self:IsLevelIDHaveWatchRecord(levelID)
        if isHaveWatchRecord ~= true then
          self:SetNewLevelIDWatchRecord(levelID)
        end
      end
    end
  end
end

function LegacyLevelManager:GetNormalCurChapterIndex()
  if not self.m_normalChapterList then
    return
  end
  for i, tempChapterData in ipairs(self.m_normalChapterList) do
    local tempChapterID = tempChapterData.chapterCfg.m_ChapterID
    local isAllHavePass = self:IsChapterLevelAllHavePass(tempChapterID)
    if isAllHavePass ~= true then
      local isChapterUnlock = self:IsChapterUnlock(tempChapterID)
      if isChapterUnlock == true then
        return i
      else
        local index = i - 1
        if index <= 0 then
          index = 1
        end
        return index
      end
    end
  end
  return #self.m_normalChapterList
end

function LegacyLevelManager:GetLegacyBackParamTab()
  if not self.m_curLevelType or not self.m_curLevelID then
    return
  end
  local levelCfg = self:GetLevelConfigByID(self.m_curLevelID)
  if not levelCfg then
    return
  end
  local chapterID = levelCfg.m_ChapterID
  local chapterCfg = self:GetChapterConfigByID(chapterID)
  if not chapterCfg then
    return
  end
  local paramTab = {
    chapterID = chapterID,
    isChooseEx = chapterCfg.m_ChapterType == LegacyLevelManager.ChapterTypeEnum.ExChapter
  }
  return paramTab
end

function LegacyLevelManager:StartEnterBattle(levelType, levelID)
  if not levelType then
    return
  end
  self.m_curLevelType = levelType
  self.m_curLevelID = levelID
  self:BeforeEnterBattle(levelType, levelID)
  local mapID = self:GetLevelMapID()
  self:EnterPVEBattle(mapID)
end

function LegacyLevelManager:BeforeEnterBattle(levelType, levelID)
  LegacyLevelManager.super.BeforeEnterBattle(self)
  local inputLevelData = {
    levelType = levelType or 0,
    levelSubType = 1,
    levelID = levelID,
    heroList = HeroManager:GetHeroServerList(),
    enemyIndex = 0,
    enemyDetail = nil
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function LegacyLevelManager:GetLevelMapID(levelType, levelId)
  if levelType and levelId then
    local cfgIns = CS.CData_LegacyStageLevelInfo.GetInstance()
    if cfgIns then
      local cfg = cfgIns:GetValue_ByLevelID(levelId)
      if cfg and not cfg:GetError() then
        return cfg.m_BattleID
      end
    end
  end
  if not self.m_curLevelType or not self.m_curLevelID then
    return
  end
  local levelCfg = self:GetLevelConfigByID(self.m_curLevelID)
  if not levelCfg then
    return
  end
  return levelCfg.m_BattleID
end

function LegacyLevelManager:GetDownloadResourceExtra()
  local extraRes = {
    {
      sName = "Form_LegacyBattleMain",
      eType = DownloadManager.ResourceType.UI
    },
    {
      sName = "Form_LegacyBattleDefeat",
      eType = DownloadManager.ResourceType.UI
    },
    {
      sName = "Form_LegacyBattleExploration",
      eType = DownloadManager.ResourceType.UI
    },
    {
      sName = "Form_LegacyBattlePopoverSkill",
      eType = DownloadManager.ResourceType.UI
    },
    {
      sName = "Form_LegacyBattleRound",
      eType = DownloadManager.ResourceType.UI
    },
    {
      sName = "Form_LegacyBattleWin",
      eType = DownloadManager.ResourceType.UI
    }
  }
  return nil, extraRes
end

function LegacyLevelManager:OnBattleEnd(isSuc, legacyStageGamePassSC, finishErrorCode)
  log.info("LegacyLevelManager OnBattleEnd isSuc: ", tostring(isSuc))
  if finishErrorCode ~= nil and finishErrorCode ~= 0 then
    local msg = {rspcode = finishErrorCode}
    NetworkManager:OnRpcCallbackFail(msg, function()
      BattleFlowManager:ExitBattle()
    end)
  else
    local result = isSuc
    local levelType = self.m_curLevelType
    local levelID = self.m_curLevelID
    if result then
      self:BattleSucFreshDataStatus(self.m_curLevelType, self.m_curLevelID, legacyStageGamePassSC.stLevel)
      local rewardData
      if legacyStageGamePassSC then
        rewardData = legacyStageGamePassSC.vReward
      end
      StackFlow:Push(UIDefines.ID_FORM_LEGACYACTIVITYWIN, {
        levelType = levelType,
        levelID = levelID,
        rewardData = rewardData,
        finishErrorCode = finishErrorCode,
        showHeroID = randomShowHeroID
      })
    else
      StackFlow:Push(UIDefines.ID_FORM_LEGACYACTIVITYFAIL, {
        levelType = levelType,
        levelID = levelID,
        finishErrorCode = finishErrorCode
      })
    end
  end
end

function LegacyLevelManager:EnterNextBattle(levelType, ...)
end

function LegacyLevelManager:OnBackLobby(fCB)
  local formStr = "Form_PvpMain"
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
    if isSuc then
      log.info("OnBackLobby MainCity LoadBack")
      if self.m_curLevelType == LegacyLevelManager.LevelType.LegacyLevel then
        if self.m_curLevelID then
          local cfg = self:GetLevelConfigByID(self.m_curLevelID)
          if cfg and cfg.m_LevelType == LegacyLevelManager.LegacyLevelType.ActivityLevel then
            local iActId, iSubActId = HeroActivityManager:GetMinigameHelper():GetCurLevelInfo()
            local isOpen = HeroActivityManager:IsSubActIsOpenByID(iActId, iSubActId)
            if isOpen then
              StackFlow:Push(UIDefines.ID_FORM_ACTIVITY105MINIGAME_MAIN, {main_id = iActId, sub_id = iSubActId})
              formStr = "Form_Activity105Minigame_Main"
            end
            HeroActivityManager:GetMinigameHelper():ClearCurLevelInfo()
          else
            local isOpen, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.LegacyLevel)
            if isOpen then
              StackFlow:Push(UIDefines.ID_FORM_LEGACYACTIVITYMAIN, self:GetLegacyBackParamTab())
              formStr = "Form_LegacyActivityMain"
            else
              StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
              formStr = "Form_HallActivityMain"
            end
          end
        else
          StackFlow:Push(UIDefines.ID_FORM_HALL)
          formStr = "Form_Hall"
        end
      else
        StackFlow:Push(UIDefines.ID_FORM_HALL)
        formStr = "Form_Hall"
      end
      if fCB then
        fCB(formStr)
      end
      self:ClearCurBattleInfo()
    end
  end, true)
end

function LegacyLevelManager:ClearCurBattleInfo()
  self.m_curLevelType = nil
  self.m_curLevelID = nil
end

function LegacyLevelManager:FromBattleToHall()
  self:ClearCurBattleInfo()
  self:ExitBattle()
end

return LegacyLevelManager
