local UISubPanelBase = require("UI/Common/UISubPanelBase")
local FirstRechargeActivitySubPanel = class("FirstRechargeActivitySubPanel", UISubPanelBase)
local iMaxCount = 4
local DefaultShowSpineName = "Hippocratic_Base"

function FirstRechargeActivitySubPanel:OnInit()
  self:AddEventListeners()
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function FirstRechargeActivitySubPanel:OnInActive()
  self:CheckRecycleSpine(true)
end

function FirstRechargeActivitySubPanel:OnFreshData()
  self.m_stActivity = self.m_panelData.activity
  local clientCfg = self.m_stActivity:GetClientCfg()
  local iRedQuestId = clientCfg.iRedQuestId
  local questList = self.m_stActivity:GetQuestList()
  local questInfo, redQuestInfo
  for k, v in ipairs(questList) do
    if v.iId ~= iRedQuestId then
      questInfo = v
    else
      redQuestInfo = v
    end
  end
  if questInfo then
    self.questInfo = questInfo
    local questState = self.m_stActivity:GetQuestState(questInfo.iId)
    self.questState = questState
    local prefabHelper = self.m_pnl_reward:GetComponent("PrefabHelper")
    utils.ShowPrefabHelper(prefabHelper, handler(self, self.OnInitItem), questInfo.vReward)
    self.m_btn_reward:SetActive(questState.iState == TaskManager.TaskState.Finish)
    self.m_btn_charge:SetActive(questState.iState == TaskManager.TaskState.Doing)
  end
  if redQuestInfo then
    self.redQuestInfo = redQuestInfo
    local questState = self.m_stActivity:GetQuestState(redQuestInfo.iId)
    self.redQuestState = questState
    local reward = redQuestInfo.vReward[1]
    UILuaHelper.SetAtlasSprite(self.m_chanrge_icon_Image, ItemManager:GetItemIconPathByID(reward.iID))
    self.m_txt_charage_Text.text = reward.iNum
    self.m_pnl_gotreward:SetActive(questState.iState == TaskManager.TaskState.Completed)
    self.m_redpoint:SetActive(questState.iState == TaskManager.TaskState.Finish)
    self.m_UIFX_award_loop:SetActive(questState.iState == TaskManager.TaskState.Finish)
  end
  self:LoadShowSpine()
end

function FirstRechargeActivitySubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_LevelAwardUpdate", handler(self, self.OnLevelAwardUpdate))
end

function FirstRechargeActivitySubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function FirstRechargeActivitySubPanel:OnLevelAwardUpdate(tParam)
  self.m_parentLua:RefreshTableButtonList()
end

function FirstRechargeActivitySubPanel:OnInitItem(go, index, data)
  local transform = go.transform
  local item = transform:Find("c_item_reward01").gameObject
  local commonItem = self:createCommonItem(item)
  local processData = ResourceUtil:GetProcessRewardData(data)
  commonItem:SetItemInfo(processData)
  commonItem:SetItemIconClickCB(function(iID, iNum)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = iID, iNum = iNum})
  end)
  local fx = transform:Find("img_light_collect").gameObject
  fx:SetActive(self.questState.iState == TaskManager.TaskState.Finish)
  self.m_UIFX_firstrecharge_loop:SetActive(self.questState.iState == TaskManager.TaskState.Finish)
  commonItem:SetItemHaveGetActive(self.questState.iState == TaskManager.TaskState.Completed)
end

function FirstRechargeActivitySubPanel:OnBtnchargeClicked()
  if not self.questInfo then
    return
  end
  QuickOpenFuncUtil:OpenFunc(self.questInfo.iJump)
end

function FirstRechargeActivitySubPanel:OnBtnredrewardClicked()
  if not self.redQuestInfo or not self.redQuestState then
    return
  end
  if self.redQuestState.iState ~= TaskManager.TaskState.Finish then
    return
  end
  self:RequestGetReward(self.redQuestInfo.iId)
end

function FirstRechargeActivitySubPanel:OnBtnrewardClicked()
  if not self.questInfo or not self.questState then
    return
  end
  if self.questState.iState ~= TaskManager.TaskState.Finish then
    return
  end
  self:RequestGetReward(self.questInfo.iId)
end

function FirstRechargeActivitySubPanel:RequestGetReward(iId)
  self.m_stActivity:RequestGetReward(iId, function(sc, stParam)
    local vReward = sc.vReward
    if vReward then
      utils.popUpRewardUI(vReward)
    end
    self:OnFreshData()
  end)
end

function FirstRechargeActivitySubPanel:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(DefaultShowSpineName, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function FirstRechargeActivitySubPanel:LoadShowSpine()
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  self.m_HeroSpineDynamicLoader:GetObjectByName(DefaultShowSpineName, function(nameStr, object)
    self:CheckRecycleSpine()
    UILuaHelper.SetParent(object, self.m_root_hero, true)
    UILuaHelper.SetActive(object, true)
    UILuaHelper.SpineResetMatParam(object)
    self.m_curHeroSpineObj = object
  end)
end

return FirstRechargeActivitySubPanel
