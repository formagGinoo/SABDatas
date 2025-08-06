local BaseManagerHelper = require("Manager/Base/BaseManagerHelper")
local HeroFashion = class("HeroFashion", BaseManagerHelper)
local FashionInfoIns = ConfigManager:GetConfigInsByName("FashionInfo")

function HeroFashion:ctor()
  HeroFashion.super.ctor(self)
  self.m_fashionStatus = {}
  self.m_heroFashionInfoListDic = {}
  self.m_heroFashionCache = {}
  self:InitFashionInfoCache()
end

function HeroFashion:InitFashionInfoCache()
  if not FashionInfoIns then
    return
  end
  local allValues = FashionInfoIns:GetAll()
  for i, v in pairs(allValues) do
    local characterID = v.m_CharacterId
    local fashionID = v.m_FashionID
    self.m_heroFashionCache[fashionID] = v
    if self.m_heroFashionInfoListDic[characterID] == nil then
      self.m_heroFashionInfoListDic[characterID] = {}
    end
    local fashionInfoList = self.m_heroFashionInfoListDic[characterID]
    fashionInfoList[#fashionInfoList + 1] = v
  end
end

function HeroFashion:InitFashionStatus(fashionStatus)
  if not fashionStatus then
    return
  end
  self.m_fashionStatus = fashionStatus
end

function HeroFashion:AddNewFashion(fashionID)
  if not fashionID then
    return
  end
  self.m_fashionStatus[fashionID] = TimeUtil:GetServerTimeS()
end

function HeroFashion:IsFashionHave(fashionID)
  if not fashionID then
    return
  end
  if not self.m_fashionStatus then
    return
  end
  local fashionInfoCfg = self:GetFashionInfoByID(fashionID)
  if fashionInfoCfg and fashionInfoCfg.m_Type == 0 then
    return true
  end
  if self.m_fashionStatus[fashionID] ~= nil and self.m_fashionStatus[fashionID] ~= 0 then
    return true
  end
  return false
end

function HeroFashion:IsFashionEquip(fashionID, heroData)
  if not fashionID then
    return
  end
  if not heroData then
    return
  end
  local curUseFashion = heroData.serverData.iFashion
  if curUseFashion == 0 then
    local fashionInfoCfg = self:GetFashionInfoByID(fashionID)
    if fashionInfoCfg and fashionInfoCfg.m_Type == 0 then
      return true
    else
      return false
    end
  else
    return curUseFashion == fashionID
  end
end

function HeroFashion:GetFashionInfoByID(fashionID)
  if not fashionID then
    return
  end
  if not self.m_heroFashionCache then
    return
  end
  return self.m_heroFashionCache[fashionID]
end

function HeroFashion:GetFashionInfoListByHeroID(heroID)
  if not heroID then
    return
  end
  if not self.m_heroFashionInfoListDic then
    return
  end
  local fashionInfoList = self.m_heroFashionInfoListDic[heroID]
  if not fashionInfoList then
    return
  end
  return fashionInfoList
end

function HeroFashion:GetSpineStrByFashionID(fashionID)
  if not fashionID then
    return
  end
  local fashionInfoCfg = self:GetFashionInfoByID(fashionID)
  if not fashionInfoCfg then
    return
  end
  return fashionInfoCfg.m_Spine
end

function HeroFashion:IsFashionHaveNewFlag(fashionID)
  if not fashionID then
    return false
  end
  local fashionInfo = self:GetFashionInfoByID(fashionID)
  if not fashionInfo then
    return false
  end
  local isHave = self:IsFashionHave(fashionID)
  if isHave ~= true then
    return false
  end
  if fashionInfo.m_Type == 0 then
    return false
  end
  return LocalDataManager:GetIntSimple("HeroFashionNew" .. fashionID, 0) == 0
end

function HeroFashion:SetFashionHaveNewFlag(fashionID, flagNum)
  if not fashionID then
    return
  end
  if not flagNum then
    return
  end
  LocalDataManager:SetIntSimple("HeroFashionNew" .. fashionID, flagNum)
  self:broadcastEvent("eGameEvent_Hero_SetHeroFashionNewFlag", {fashionID = fashionID})
end

function HeroFashion:IsHeroFashionHaveRedDot(heroID)
  if not heroID then
    return 0
  end
  local fashionInfoList = self:GetFashionInfoListByHeroID(heroID)
  if not fashionInfoList then
    return 0
  end
  for i, v in ipairs(fashionInfoList) do
    if self:IsFashionHaveNewFlag(v.m_FashionID) == true then
      return 1
    end
  end
  return 0
end

function HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroID, fashionID)
  if not heroID then
    return
  end
  if fashionID == nil then
    return
  end
  if fashionID == 0 then
    local fashionInfoList = self:GetFashionInfoListByHeroID(heroID)
    if fashionInfoList and next(fashionInfoList) then
      for i, v in ipairs(fashionInfoList) do
        if v.m_Type == 0 then
          return v
        end
      end
    end
  else
    return self:GetFashionInfoByID(fashionID)
  end
end

function HeroFashion:GetHeroSpineByHeroFashionID(heroID, fashionID)
  if not heroID then
    return
  end
  local fashionInfo = self:GetFashionInfoByHeroIDAndFashionID(heroID, fashionID)
  if not fashionInfo then
    return
  end
  return fashionInfo.m_Spine
end

function HeroFashion:GetFashionHideTypeValue(fashionID, configHideTypeValue)
  if not fashionID then
    return configHideTypeValue
  end
  local activityCom = ActivityManager:GetActivityByType(MTTD.ActivityType_UpTimeManager)
  if not activityCom then
    return configHideTypeValue
  end
  local isMatch, serverValue = activityCom:GetFashionStatusByID(fashionID)
  if isMatch == true then
    configHideTypeValue = serverValue
  end
  return configHideTypeValue
end

function HeroFashion:GetAllHaveFashionInfoList()
  if not self.m_fashionStatus then
    return
  end
  local fashionInfoList = {}
  for fashionID, v in pairs(self.m_fashionStatus) do
    if v ~= nil and 0 < v then
      local tempFashionInfo = self:GetFashionInfoByID(fashionID)
      if tempFashionInfo then
        fashionInfoList[#fashionInfoList + 1] = tempFashionInfo
      end
    end
  end
  return fashionInfoList
end

return HeroFashion
