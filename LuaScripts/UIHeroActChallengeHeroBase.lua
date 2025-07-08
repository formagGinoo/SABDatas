local UIHeroActChallengeHeroBase = class("UIHeroActChallengeHeroBase", require("UI/Common/UIBase"))
local ActLamiaPowerChaIns = ConfigManager:GetConfigInsByName("ActLamiaPowerCha")

function UIHeroActChallengeHeroBase:AfterInit()
  UIHeroActChallengeHeroBase.super.AfterInit(self)
  self.m_activityID = nil
  self.m_actLamiaPowerChaCfgDic = nil
  self.m_showLamiaPowerList = nil
  self.m_luaHeroList = require("UI/Common/UIInfinityGrid").new(self.m_heroList_InfinityGrid, "LamiaLevel/UILamiaChallengePowerHeroItem")
end

function UIHeroActChallengeHeroBase:OnActive()
  UIHeroActChallengeHeroBase.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function UIHeroActChallengeHeroBase:OnInactive()
  UIHeroActChallengeHeroBase.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function UIHeroActChallengeHeroBase:FreshUI()
  if not self.m_activityID then
    return
  end
  self.m_luaHeroList:ShowItemList(self.m_showLamiaPowerList)
  self.m_luaHeroList:LocateTo()
end

function UIHeroActChallengeHeroBase:AddEventListeners()
end

function UIHeroActChallengeHeroBase:RemoveAllEventListeners()
  self:clearEventListener()
end

function UIHeroActChallengeHeroBase:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_activityID = tParam.activityID
    self:FreshPowerChaCfgData()
    self.m_csui.m_param = nil
  end
end

function UIHeroActChallengeHeroBase:FreshPowerChaCfgData()
  if not self.m_activityID then
    return
  end
  self.m_actLamiaPowerChaCfgDic = {}
  local actLamiaPowerChaCfgDic = ActLamiaPowerChaIns:GetValue_ByActivityID(self.m_activityID)
  for i, tempCfg in pairs(actLamiaPowerChaCfgDic) do
    local tempTab = {
      config = tempCfg,
      isHave = false,
      sort = tempCfg.m_Sort,
      characterID = tempCfg.m_Character,
      characterCfg = HeroManager:GetHeroConfigByID(tempCfg.m_Character)
    }
    self.m_actLamiaPowerChaCfgDic[tempTab.characterID] = tempTab
  end
  local allHaveHeroList = HeroManager:GetHeroList()
  for i, tempHeroData in ipairs(allHaveHeroList) do
    local heroID = tempHeroData.characterCfg.m_HeroID
    if self.m_actLamiaPowerChaCfgDic[heroID] then
      self.m_actLamiaPowerChaCfgDic[heroID].isHave = true
    end
  end
  self.m_showLamiaPowerList = {}
  for i, v in pairs(self.m_actLamiaPowerChaCfgDic) do
    self.m_showLamiaPowerList[v.config.m_Sort] = v
  end
end

function UIHeroActChallengeHeroBase:ClearCacheData()
end

function UIHeroActChallengeHeroBase:OnBtnCloseClicked()
  self:CloseForm()
end

function UIHeroActChallengeHeroBase:OnBtnReturnClicked()
  self:CloseForm()
end

function UIHeroActChallengeHeroBase:OnDestroy()
  UIHeroActChallengeHeroBase.super.OnDestroy(self)
end

function UIHeroActChallengeHeroBase:IsOpenGuassianBlur()
  return true
end

return UIHeroActChallengeHeroBase
