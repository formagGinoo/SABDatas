local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivitySignTenDaySubPanel = class("ActivitySignTenDaySubPanel", UISubPanelBase)
local SignMaxNum = 10
local __SpineNameStr = "silvan_base_a1_01"

function ActivitySignTenDaySubPanel:OnInit()
  self.m_rewardInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_reward_InfinityGrid, "ActivityReward/Act10DaySignItem")
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_CommonText = ConfigManager:GetCommonTextById(220018)
end

function ActivitySignTenDaySubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_Sign_UpdateSign", handler(self, self.OnEventUpdateSign))
  self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
end

function ActivitySignTenDaySubPanel:RemoveEventListeners()
  self:clearEventListener()
end

function ActivitySignTenDaySubPanel:OnFreshData()
  local activityId = self.m_panelData.activity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  if self.m_stActivity == nil then
    return
  end
  self:RemoveEventListeners()
  self:AddEventListeners()
  self:FreshShowSpine()
  self:RefreshUI()
  self:AutoRequestSign()
end

function ActivitySignTenDaySubPanel:OnInactive()
  self:RemoveEventListeners()
  self:KillRemainTimer()
  self:FreshShowSpine()
end

function ActivitySignTenDaySubPanel:RefreshUI()
  self:RefreshReward()
  self:RefreshRemainTime()
end

function ActivitySignTenDaySubPanel:RefreshReward()
  local iSignNum = self.m_stActivity:GetSignNum()
  local bSignToday = self.m_stActivity:IsSignToday()
  local vSignInfoList = self.m_stActivity:GetSignInfoList()
  local itemDataList = {}
  for i = 1, SignMaxNum do
    local itemData = {}
    local stSignInfo = vSignInfoList[i]
    local customData
    if i <= iSignNum then
      itemData.state = ActivityManager.SignTaken
      customData = {is_have_get = true}
    elseif i == iSignNum + 1 and not bSignToday then
      itemData.state = ActivityManager.SignCanTaken
    elseif i == iSignNum + 1 and bSignToday then
      itemData.state = ActivityManager.SignCanTaken
    else
      itemData.state = ActivityManager.SignCannotTaken
    end
    local itemInfo = ResourceUtil:GetProcessRewardData({
      iID = stSignInfo.stRewardInfo[1].iID,
      iNum = stSignInfo.stRewardInfo[1].iNum
    }, customData)
    itemData.day = i
    itemData.rewardInfo = itemInfo
    itemData.iSignNum = iSignNum
    itemData.maxRewardDay = SignMaxNum
    table.insert(itemDataList, itemData)
  end
  self.m_rewardInfinityGrid:ShowItemList(itemDataList)
end

function ActivitySignTenDaySubPanel:AutoRequestSign()
  if self.m_stActivity then
    local iSignNum = self.m_stActivity:GetSignNum()
    local bSignToday = self.m_stActivity:IsSignToday()
    local vSignInfoList = self.m_stActivity:GetSignInfoList()
    if not bSignToday and iSignNum < #vSignInfoList then
      local stSignInfo = vSignInfoList[iSignNum + 1]
      self.m_stActivity:RequestSign(stSignInfo.iIndex)
    end
  end
end

function ActivitySignTenDaySubPanel:OnEventUpdateSign(stParam)
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  PushFaceManager:RemoveShowPopPanelList(UIDefines.ID_FORM_ACTIVITYSIGN10DAY, self.m_stActivity:getSubPanelName())
  if self.m_rootObj.activeInHierarchy then
    utils.popUpRewardUI(stParam.vReward)
    self:RefreshReward()
    if self.m_parentLua then
      self.m_parentLua:RefreshTableButtonList()
    end
  end
end

function ActivitySignTenDaySubPanel:OnEventActivityReload()
  if self.m_rootObj.activeInHierarchy then
    self:RefreshUI()
    self:AutoRequestSign()
  end
end

function ActivitySignTenDaySubPanel:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  self:KillRemainTimer()
  self.endTime = self.m_stActivity:getActivityEndTime()
  if self.endTime == 0 then
    self.m_PanelRemainTime:SetActive(false)
    return
  end
  self.m_PanelRemainTime:SetActive(true)
  local remainTime = 0 < self.endTime - TimeUtil:GetServerTimeS() and self.endTime - TimeUtil:GetServerTimeS() or 0
  if not remainTime or remainTime <= 0 then
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYSIGN10DAY)
    return
  end
  self.m_txtRemainTime_Text.text = string.gsubnumberreplace(self.m_CommonText, TimeUtil:SecondsToFormatCNStr3(remainTime))
  self.m_remainTimer = TimeService:SetTimer(1, -1, function()
    remainTime = self.endTime - TimeUtil:GetServerTimeS() > 0 and self.endTime - TimeUtil:GetServerTimeS() or 0
    local text = TimeUtil:SecondsToFormatCNStr3(remainTime)
    self.m_txtRemainTime_Text.text = string.gsubnumberreplace(self.m_CommonText, text)
    if remainTime <= 0 then
      self:KillRemainTimer()
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYSIGN10DAY)
    end
  end)
end

function ActivitySignTenDaySubPanel:KillRemainTimer()
  if self.m_remainTimer then
    TimeService:KillTimer(self.m_remainTimer)
    self.m_remainTimer = nil
  end
end

function ActivitySignTenDaySubPanel:GetShowSpine()
  return __SpineNameStr
end

function ActivitySignTenDaySubPanel:FreshShowSpine()
  self:CheckRecycleSpine()
  local spineStr = self:GetShowSpine()
  if not spineStr then
    return
  end
  self:LoadHeroSpine(spineStr, SpinePlaceCfg.SignIn10DaySystem, self.m_root_hero)
end

function ActivitySignTenDaySubPanel:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
  if not heroSpineAssetName then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine(true)
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
      UILuaHelper.SetSpineTimeScale(spineLoadObj.spineObj, 1)
    end)
  end
end

function ActivitySignTenDaySubPanel:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

return ActivitySignTenDaySubPanel
