local MinigameHelper = class("MinigameHelper")

function MinigameHelper:ctor()
  self.vAllLegacyStageCfg = {}
end

function MinigameHelper:GetSubActMiniGameAllLegacyStageCfg(iSubActID)
  if self.vAllLegacyStageCfg[iSubActID] then
    return self.vAllLegacyStageCfg[iSubActID]
  end
  local MiniGameLegacyStageIns = ConfigManager:GetConfigInsByName("MiniGameLegacyStage")
  local list = MiniGameLegacyStageIns:GetValue_BySubActID(iSubActID)
  local vAllLegacyStageCfg = {}
  for k, v in pairs(list) do
    if v.m_LevelID and v.m_LevelID > 0 then
      table.insert(vAllLegacyStageCfg, v)
    end
  end
  table.sort(vAllLegacyStageCfg, function(a, b)
    return a.m_LevelID < b.m_LevelID
  end)
  self.vAllLegacyStageCfg[iSubActID] = vAllLegacyStageCfg
  return vAllLegacyStageCfg
end

function MinigameHelper:GetLegacyStageCfgBySubActIdAndLevelId(iSubActId, iLevelId)
  local MiniGameLegacyStageIns = ConfigManager:GetConfigInsByName("MiniGameLegacyStage")
  local cfg = MiniGameLegacyStageIns:GetValue_BySubActIDAndLevelID(iSubActId, iLevelId)
  if cfg:GetError() then
    log.error("MinigameHelper GetLegacyStageCfgBySubActIdAndLevelId error! iSubActId:" .. tostring(iSubActId) .. " iLevelId: " .. tostring(iLevelId))
    return nil
  end
  return cfg
end

function MinigameHelper:GetCurLevelCfg(iActId, iSubActId)
  local vAllLegacyStageCfg = self:GetSubActMiniGameAllLegacyStageCfg(iSubActId)
  local act_data = HeroActivityManager:GetHeroActData(iActId)
  if not act_data then
    return nil
  end
  local stMiniGame = act_data.server_data.stMiniGame
  local iCurLevelId = 0
  for i, cfg in ipairs(vAllLegacyStageCfg) do
    local bIsUnlock = true
    local iUnlockLevel = cfg.m_UnlockLevel
    local iPreLevel = cfg.m_OderLevel
    if iUnlockLevel and 0 < iUnlockLevel then
      bIsUnlock = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(iUnlockLevel)
    end
    if iPreLevel and 0 < iPreLevel then
      bIsUnlock = stMiniGame.mGameStat[iPreLevel] == 1 and LegacyLevelManager:IsLevelHavePass(iPreLevel)
    end
    if bIsUnlock then
      iCurLevelId = cfg.m_LevelID
    end
  end
  return iCurLevelId
end

function MinigameHelper:SetCurLevelInfo(iActId, iSubActId, iLevelId)
  self.iActId = iActId
  self.iSubActId = iSubActId
  self.iLevelId = iLevelId
end

function MinigameHelper:GetCurLevelInfo()
  return self.iActId, self.iSubActId, self.iLevelId
end

function MinigameHelper:ClearCurLevelInfo()
  self.iActId = nil
  self.iSubActId = nil
  self.iLevelId = nil
end

function MinigameHelper:IsMiniGamePuzzleRewardCanGet(iActId, iSubActId)
  local vAllLegacyStageCfg = self:GetSubActMiniGameAllLegacyStageCfg(iSubActId)
  local act_data = HeroActivityManager:GetHeroActData(iActId)
  if not act_data then
    return false
  end
  local iFinishCoun = 0
  local stMiniGame = act_data.server_data.stMiniGame
  local iMaxLevelNum = 5
  for i = 1, iMaxLevelNum do
    local cfg = vAllLegacyStageCfg[i]
    if cfg then
      local bIsPass = stMiniGame.mGameStat[cfg.m_LevelID] == 1
      if bIsPass then
        iFinishCoun = iFinishCoun + 1
      end
    end
  end
  return iMaxLevelNum <= iFinishCoun and not HeroActivityManager:IsSubActAwarded(iActId, iSubActId)
end

function MinigameHelper:IsMiniGameNewOpen(iActId, iSubActId)
  local activitySubInfoCfg = HeroActivityManager:GetSubInfoByID(iSubActId)
  log.info("MinigameHelper:IsMiniGameNewOpen activitySubInfoCfg.m_MiniGameMainDoc:" .. activitySubInfoCfg.m_MiniGameMainDoc)
  if activitySubInfoCfg.m_MiniGameMainDoc == "" then
    log.error("MinigameHelper:IsMiniGameNewOpen error! iActId:" .. tostring(iActId) .. " iSubActId: " .. tostring(iSubActId))
    return false
  end
  local levelTb = ConfigManager:GetConfigInsByName(activitySubInfoCfg.m_MiniGameMainDoc)
  if not levelTb then
    log.error("MinigameHelper:IsMiniGameNewOpen error! iActId:" .. tostring(iActId) .. " iSubActId: " .. tostring(iSubActId))
    return false
  end
  local levelConfigsAll = levelTb:GetValue_BySubActID(iSubActId)
  local difficultys = {}
  for k, v in pairs(levelConfigsAll) do
    if difficultys[v.m_DifficultyID] then
      table.insert(difficultys[v.m_DifficultyID], v)
    else
      difficultys[v.m_DifficultyID] = {v}
    end
  end
  for k, v in pairs(difficultys) do
    local open_time = 0
    if v[1].m_OpenTime and v[1].m_OpenTime ~= "" then
      open_time = TimeUtil:TimeStringToTimeSec2(v[1].m_OpenTime) or 0
    end
    local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = iActId,
      m_MemoryID = v[1].m_LevelID
    })
    if is_corved then
      open_time = t1
    end
    local cur_time = TimeUtil:GetServerTimeS()
    local unlock = open_time <= cur_time
    if unlock and LocalDataManager:GetIntSimple("Activity_MiniGame_Red_Point" .. iActId .. "_" .. iSubActId .. "_" .. k, 0) == 0 then
      log.info("MinigameHelper:IsMiniGameNewOpen unlock")
      return true
    end
  end
  return lastConfirmDifficulty == 0
end

function MinigameHelper:IsMiniGamePuzzleHaveRedDot(iActId, iSubActId)
  log.info("MinigameHelper:IsMiniGameHaveRedDot iActId:" .. tostring(iActId) .. " iSubActId: " .. tostring(iSubActId))
  local miniGameIsOpen = HeroActivityManager:IsSubActIsOpenByID(iActId, iSubActId)
  if not miniGameIsOpen then
    log.info("MinigameHelper:IsMiniGameHaveRedDot miniGameIsOpen false! iActId:" .. tostring(iActId) .. " iSubActId: " .. tostring(iSubActId))
    return 0
  end
  local taskId = HeroActivityManager:GetSubFuncID(iActId, HeroActivityManager.SubActTypeEnum.GameTask)
  local param = {actId = iActId, whackMoleTaskId = taskId}
  local taskRed = HeroActivityManager:CheckHaveFinishWhackMoleTask(param)
  if taskRed ~= 0 then
    return 1
  end
  if self:IsMiniGameNewOpen(iActId, iSubActId) then
    log.info("MinigameHelper:IsMiniGameHaveRedDot IsMiniGameNewOpen true! iActId:" .. tostring(iActId) .. " iSubActId: " .. tostring(iSubActId))
    return 1
  end
  return 0
end

return MinigameHelper
