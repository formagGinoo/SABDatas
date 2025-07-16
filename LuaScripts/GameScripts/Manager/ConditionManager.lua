local BaseManager = require("Manager/Base/BaseManager")
local ConditionManager = class("ConditionManager", BaseManager)
ConditionType = {
  StoryLevel = 1,
  RoleLevel = 2,
  GuideStep = 3,
  MainChapter = 5
}

function ConditionManager:OnCreate()
end

function ConditionManager:OnInitNetwork()
end

function ConditionManager:OnUpdate(dt)
end

function ConditionManager:IsMulConditionUnlock(conditionTypeList, conditionParamList)
  if not conditionTypeList or not conditionParamList then
    return
  end
  if #conditionTypeList ~= #conditionParamList then
    return
  end
  for i, v in ipairs(conditionTypeList) do
    local conditionParam = conditionParamList[i]
    if conditionParamList == nil then
      log.error("ConditionManager IsMulConditionUnlock conditionTypeList 和 conditionParamList 不匹配")
      return
    end
    local isUnlock, unlockStr = self:IsConditionUnlock(v, conditionParam)
    if isUnlock == false then
      return isUnlock, v, unlockStr
    end
  end
  return true
end

function ConditionManager:IsConditionUnlock(conditionType, conditionParamStr)
  if not conditionType or not conditionParamStr then
    return false
  end
  conditionType = tonumber(conditionType)
  local conditionParamList = string.split(conditionParamStr, ",")
  if conditionType == ConditionType.StoryLevel then
    local conditionLevelID = tonumber(conditionParamList[1])
    local isHavePass = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, conditionLevelID)
    if isHavePass == true then
      return true
    end
    local cfg = LevelManager:GetMainLevelCfgById(conditionLevelID) or {}
    local str = UnlockSystemUtil:GetLockClientMessage(30015)
    return isHavePass, string.format(str, cfg.m_LevelName or "")
  elseif conditionType == ConditionType.RoleLevel then
    local conditionLvNum = tonumber(conditionParamList[1])
    local curRoleLv = RoleManager:GetLevel()
    local isGetLv = conditionLvNum <= curRoleLv
    if isGetLv == true then
      return true
    end
    local str = UnlockSystemUtil:GetLockClientMessage(30016)
    return isGetLv, string.format(str, conditionLvNum)
  elseif conditionType == ConditionType.GuideStep then
    local subGuideID = tonumber(conditionParamList[1])
    local isGuideFinish = GuideManager:CheckSubStepGuideCmp(subGuideID)
    if isGuideFinish == true then
      return true
    end
    local str = UnlockSystemUtil:GetLockClientMessage(30017)
    return false, string.format(str, subGuideID)
  elseif conditionType == ConditionType.MainChapter then
    local chapterID = tonumber(conditionParamList[1])
    local mainHelper = LevelManager:GetLevelMainHelper()
    if not mainHelper then
      return false
    end
    local isAllStoryPass, chapterTitle = mainHelper:IsChapterAllStoryLevelHavePass(chapterID)
    if isAllStoryPass == true then
      return true
    end
    local str = UnlockSystemUtil:GetLockClientMessage(30024)
    return false, string.CS_Format(str, chapterTitle)
  end
  return false
end

function ConditionManager:IsMulConditionUnlockNew(conditionTypeList, conditionParamList)
  if not conditionTypeList or not conditionParamList then
    return true
  end
  if #conditionTypeList ~= #conditionParamList then
    return false, nil, "error_params"
  end
  for index, conditionParamList2 in ipairs(conditionParamList or {}) do
    for index2, v in ipairs(conditionParamList2) do
      local isUnlock, unlockStr = self:IsConditionUnlockNew(conditionTypeList[index], v)
      if isUnlock == false then
        return isUnlock, conditionTypeList[index], unlockStr
      end
    end
  end
  return true
end

local UnlockCMD = {}
UnlockCMD[UnlockSystemUtil.LOCK_CONDITION_TYPE.LOCK] = function()
  return false
end
UnlockCMD[UnlockSystemUtil.LOCK_CONDITION_TYPE.UNLOCK] = function()
  return true
end
UnlockCMD[UnlockSystemUtil.LOCK_CONDITION_TYPE.LEVEL] = function(conditionParam)
  local str = UnlockSystemUtil:GetLockClientMessage(30016)
  return RoleManager:GetLevel() >= tonumber(conditionParam), string.format(str, tonumber(conditionParam))
end
UnlockCMD[UnlockSystemUtil.LOCK_CONDITION_TYPE.CHAPTER] = function(conditionParam)
  local open_flag = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, conditionParam)
  if open_flag then
    return true
  end
  local str = UnlockSystemUtil:GetLockClientMessage(30015)
  local cfg = LevelManager:GetMainLevelCfgById(conditionParam)
  return open_flag, string.format(str, cfg.m_LevelName)
end
UnlockCMD[UnlockSystemUtil.LOCK_CONDITION_TYPE.GUIDE] = function(conditionParam)
  local open_flag = GuideManager:CheckSubStepGuideCmp(conditionParam)
  if open_flag then
    return true
  end
  local str = UnlockSystemUtil:GetLockClientMessage(30017)
  return open_flag, string.format(str, conditionParam)
end
UnlockCMD[UnlockSystemUtil.LOCK_CONDITION_TYPE.GUILD_LEVEL] = function(conditionParam)
  local _, iAllianceLevel = RoleManager:GetRoleAllianceInfo()
  local open_flag
  if iAllianceLevel then
    open_flag = conditionParam < iAllianceLevel
  else
    open_flag = false
  end
  return open_flag
end
UnlockCMD[UnlockSystemUtil.LOCK_CONDITION_TYPE.STAGE] = function(conditionParam)
  local open_flag = ConditionManager:IsConditionUnlock(ConditionType.MainChapter, conditionParam)
  return open_flag
end

function ConditionManager:IsConditionUnlockNew(conditionType, conditionParam)
  if not conditionType or not conditionParam then
    return false
  end
  local f = UnlockCMD[tonumber(conditionType)]
  if f then
    return f(conditionParam)
  end
  return false
end

return ConditionManager
