local M = {}
M.LOCK_CONDITION_TYPE = {
  LOCK = 0,
  UNLOCK = 1,
  LEVEL = 2,
  CHAPTER = 3,
  GUIDE = 4,
  GUILD_LEVEL = 6,
  STAGE = 7
}
M.GACHA_LOCK_CONDITION_TYPE = {
  CHAPTER = 1,
  LEVEL = 2,
  GUIDE = 3
}

function M:GetSystemUnlockConfig(id)
  if not id then
    log.error("UnlockSystemUtil GetSystemUnlockConfig id = nil")
    return
  end
  local configInstance = ConfigManager:GetConfigInsByName("SystemUnlock")
  return configInstance:GetValue_BySystemID(id)
end

function M:GetLockClientMessage(id)
  local configInstance = ConfigManager:GetConfigInsByName("ClientMessage")
  local cfg = configInstance:GetValue_ByID(id)
  if cfg:GetError() then
    log.error("UnlockSystemUtil GetLockClientMessage  error id  " .. tostring(id))
    return
  end
  return cfg.m_mContent
end

function M:IsSystemOpen(id, cfg)
  local forceLockSystemAct = ActivityManager:GetActivityByType(MTTD.ActivityType_SystemSwitch)
  if forceLockSystemAct then
    local is_force, open_flag, tips_id = forceLockSystemAct:IsSystemUnlockBySystemID(id)
    if is_force then
      return open_flag, tips_id
    end
  end
  cfg = cfg or self:GetSystemUnlockConfig(id)
  local open_flag, tips_id, unlockType = false, -1, 0
  if cfg then
    local conditionTypeArray = utils.changeCSArrayToLuaTable(cfg.m_UnlockConditionType)
    local conditionDataArray = utils.changeCSArrayToLuaTable(cfg.m_UnlockConditionData)
    for index, conditionDataArray2 in ipairs(conditionDataArray or {}) do
      for index2, v in ipairs(conditionDataArray2) do
        open_flag = self:SystemOpenCondition(conditionTypeArray[index], index, index2, id, cfg)
        if open_flag == false then
          if index <= cfg.m_ClientMessage.Length then
            tips_id = cfg.m_ClientMessage[index - 1]
          else
            tips_id = "???"
          end
          return open_flag, tips_id
        elseif cfg.m_ClientMessage and index <= cfg.m_ClientMessage.Length then
          tips_id = cfg.m_ClientMessage[index - 1]
        end
      end
    end
    unlockType = cfg.m_UnlockType
  end
  return open_flag, tips_id, unlockType
end

function M:SystemOpenCondition(conditionType, index, index2, id, cfg)
  cfg = cfg or self:GetSystemUnlockConfig(id)
  local open_flag = false
  if conditionType then
    local conditionData = cfg.m_UnlockConditionData
    if type(cfg.m_UnlockConditionData) ~= "string" then
      local unlockConditionData = utils.changeCSArrayToLuaTable(cfg.m_UnlockConditionData)
      if unlockConditionData[index] and unlockConditionData[index][index2] then
        conditionData = unlockConditionData[index][index2] or 999
      else
        conditionData = unlockConditionData[index] or 999
      end
    end
    if conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.LOCK then
      open_flag = false
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.UNLOCK then
      open_flag = true
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.LEVEL then
      open_flag = conditionData <= RoleManager:GetLevel()
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.CHAPTER then
      open_flag = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, conditionData)
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.GUIDE then
      open_flag = GuideManager:CheckSubStepGuideCmp(conditionData)
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.STAGE then
      open_flag = ConditionManager:IsConditionUnlock(ConditionType.MainChapter, conditionData)
    elseif conditionType == UnlockSystemUtil.LOCK_CONDITION_TYPE.GUILD_LEVEL then
      local _, iAllianceLevel = RoleManager:GetRoleAllianceInfo()
      if iAllianceLevel then
        open_flag = conditionData <= iAllianceLevel
      else
        open_flag = false
      end
    else
      log.warn("open_conditionType not found : " .. tostring(conditionType))
    end
  else
    log.warn("open_condition cfg id not found : " .. tostring(id))
  end
  return open_flag
end

function M:CheckGachaIsOpenById(gachaId)
  local cfg = GachaManager:GetGachaConfig(gachaId)
  local open_flag = false
  if cfg.m_IsOpen == 0 then
    return open_flag
  end
  local conditionTypeArray = utils.changeCSArrayToLuaTable(cfg.m_UnlockConditionType)
  for index, conditionType in ipairs(conditionTypeArray or {}) do
    local conditionData = cfg.m_UnlockConditionData[index - 1] or 999
    if conditionType == UnlockSystemUtil.GACHA_LOCK_CONDITION_TYPE.LEVEL then
      open_flag = conditionData <= RoleManager:GetLevel()
    elseif conditionType == UnlockSystemUtil.GACHA_LOCK_CONDITION_TYPE.CHAPTER then
      open_flag = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, conditionData)
    elseif conditionType == UnlockSystemUtil.GACHA_LOCK_CONDITION_TYPE.GUIDE then
      open_flag = GuideManager:CheckSubStepGuideCmp(conditionData)
    else
      log.warn("open_conditionType not found : " .. tostring(conditionType))
    end
    if open_flag == false then
      return open_flag
    end
  end
  local startTime = TimeUtil:TimeStringToTimeSec2(cfg.m_StartTime) or 0
  local endTime = TimeUtil:TimeStringToTimeSec2(cfg.m_EndTime) or 0
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.gacha, {
    id = cfg.m_ActId,
    gacha_id = gachaId
  })
  if is_corved then
    startTime = t1
    endTime = t2
  end
  open_flag = TimeUtil:IsInTime(startTime, endTime)
  if not open_flag then
    return open_flag
  end
  local gachaCount = GachaManager:GetGachaCountById(gachaId)
  open_flag = cfg.m_WishTimesRes == 0 or gachaCount < cfg.m_WishTimesRes
  return open_flag
end

function M:CheckShopIsOpenById(shopId)
  local cfg = ShopManager:GetShopConfig(shopId)
  local open_flag = false
  if cfg.m_IsOn == 0 then
    return open_flag
  end
  if cfg.m_SystemUnlockID == 0 then
    open_flag = true
  else
    open_flag = self:IsSystemOpen(cfg.m_SystemUnlockID)
    if not open_flag then
      return open_flag
    end
  end
  if cfg.m_EndTime ~= "" and cfg.m_StartTime ~= "" then
    local startTime = TimeUtil:TimeStringToTimeSec2(cfg.m_StartTime) or 0
    local endTime = TimeUtil:TimeStringToTimeSec2(cfg.m_EndTime) or 0
    open_flag = TimeUtil:IsInTime(startTime, endTime)
  elseif cfg.m_StartTime ~= "" and cfg.m_EndTime == "" then
    local startTime = TimeUtil:TimeStringToTimeSec2(cfg.m_StartTime) or 0
    open_flag = TimeUtil:IsInTime(startTime, 0)
  end
  if cfg.m_Type == ShopManager.ShopType.ShopType_Activity then
    local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
      id = cfg.m_ActId,
      shop_id = shopId
    })
    if is_corved then
      open_flag = TimeUtil:IsInTime(t1, t2)
    end
  end
  return open_flag
end

return M
