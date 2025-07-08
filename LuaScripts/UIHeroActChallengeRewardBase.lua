local UIHeroActChallengeRewardBase = class("UIHeroActChallengeRewardBase", require("UI/Common/UIBase"))

function UIHeroActChallengeRewardBase:AfterInit()
  UIHeroActChallengeRewardBase.super.AfterInit(self)
  self.m_activityID = nil
  self.m_subActivityID = nil
  self.m_showLevelList = nil
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.m_luaLevelList = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "LamiaLevel/UILamiaChallengeRewardItem")
end

function UIHeroActChallengeRewardBase:OnActive()
  UIHeroActChallengeRewardBase.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function UIHeroActChallengeRewardBase:OnInactive()
  UIHeroActChallengeRewardBase.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function UIHeroActChallengeRewardBase:OnDestroy()
  UIHeroActChallengeRewardBase.super.OnDestroy(self)
end

function UIHeroActChallengeRewardBase:FreshUI()
  if not self.m_activityID then
    return
  end
  if not self.m_subActivityID then
    return
  end
  self.m_luaLevelList:ShowItemList(self.m_showLevelList)
  self.m_luaLevelList:LocateTo()
end

function UIHeroActChallengeRewardBase:AddEventListeners()
end

function UIHeroActChallengeRewardBase:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_activityID = tParam.activityID
    self.m_subActivityID = tParam.activitySubID
    self:FreshLevelDataList()
    self.m_csui.m_param = nil
  end
end

function UIHeroActChallengeRewardBase:FreshLevelDataList()
  if not self.m_activityID then
    return
  end
  if not self.m_subActivityID then
    return
  end
  local levelData = self.m_levelHelper:GetLevelDataByActAndSubID(self.m_activityID, self.m_subActivityID)
  if not levelData then
    return
  end
  self.m_showLevelList = levelData.levelCfgList
end

function UIHeroActChallengeRewardBase:ClearCacheData()
end

function UIHeroActChallengeRewardBase:RemoveAllEventListeners()
  self:clearEventListener()
end

function UIHeroActChallengeRewardBase:OnBtnCloseClicked()
  self:CloseForm()
end

function UIHeroActChallengeRewardBase:OnBtnReturnClicked()
  self:CloseForm()
end

function UIHeroActChallengeRewardBase:IsOpenGuassianBlur()
  return true
end

return UIHeroActChallengeRewardBase
