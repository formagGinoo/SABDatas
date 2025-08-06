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

return MinigameHelper
