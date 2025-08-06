local UISubPanelBase = require("UI/Common/UISubPanelBase")
local EmpousaActivitySubPanel = class("EmpousaActivitySubPanel", UISubPanelBase)
local iMaxCount = 3

function EmpousaActivitySubPanel:OnInit()
  self.mComponents = {}
  for i = 1, iMaxCount do
    local trans = self["m_btn_item_task" .. i].transform
    if not utils.isNull(trans) then
      self.mComponents[i] = {
        desc_Text = self["m_txt_task" .. i .. "_Text"],
        obj_got = self["m_pnl_locktask" .. i],
        obj_canGet = trans:Find("c_common_item" .. i .. "/c_img_redpoint").gameObject,
        obj_fxCanGet = self["m_vx_act" .. i],
        rewardItem = trans:Find("c_common_item" .. i).gameObject
      }
    end
  end
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.LoadedHeroList = {}
end

function EmpousaActivitySubPanel:OnInActive()
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(self.iHeroId)
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
end

function EmpousaActivitySubPanel:OnDestroy()
  self:CheckRecycleSpine(self.iHeroId)
  EmpousaActivitySubPanel.super.OnDestroy(self)
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
end

function EmpousaActivitySubPanel:OnFreshData()
  self:RemoveAllEventListeners()
  self:AddEventListeners()
  self:RefreshUI()
end

function EmpousaActivitySubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_LevelAwardUpdate", handler(self, self.OnLevelAwardUpdate))
end

function EmpousaActivitySubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function EmpousaActivitySubPanel:OnLevelAwardUpdate(stParam)
  self.m_parentLua:RefreshTableButtonList()
  if stParam == nil then
    return
  end
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  if stParam.iId ~= nil then
    for k, v in ipairs(self.mComponents) do
      local questInfo = self.m_stActivity:GetQuestList()[k]
      if questInfo.iId == stParam.iId then
        self:RefreshRewardItem(v, questInfo, k)
        break
      end
    end
  end
end

function EmpousaActivitySubPanel:RefreshUI()
  self.m_stActivity = self.m_panelData.activity
  if self.m_stActivity == nil then
    return
  end
  self.m_txt_title_Text.text = self.m_stActivity:getLangText(tostring(self.m_stActivity.m_stActivityData.sTitle))
  self.m_txt_condition_Text.text = self.m_stActivity:getLangText(tostring(self.m_stActivity.m_stActivityData.sDetailDesc))
  local clientCfg = self.m_stActivity:GetClientCfg()
  local iHeroId = clientCfg.iHeroId
  self.iHeroId = iHeroId
  if not self.LoadedHeroList[iHeroId] then
    local heroCfg = HeroManager:GetHeroConfigByID(iHeroId)
    self:LoadHeroSpine(iHeroId, heroCfg.m_Spine, self.m_root_role, function()
    end)
  end
  local questList = self.m_stActivity:GetQuestList()
  for i, v in ipairs(questList) do
    local item = self.mComponents[i]
    if item then
      self:RefreshRewardItem(item, v)
    end
  end
end

function EmpousaActivitySubPanel:RefreshRewardItem(item, questInfo)
  item.desc_Text.text = questInfo.sName
  local commonItem = self:createCommonItem(item.rewardItem)
  local processData = ResourceUtil:GetProcessRewardData(questInfo.vReward[1])
  commonItem:SetItemInfo(processData)
  commonItem:SetItemIconClickCB(function(iID, iNum)
    local questState = self.m_stActivity:GetQuestState(questInfo.iId)
    if questState.iState == TaskManager.TaskState.Finish then
      self:RequestGetReward(questInfo)
    else
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      utils.openItemDetailPop({iID = iID, iNum = iNum})
    end
  end)
  local questState = self.m_stActivity:GetQuestState(questInfo.iId)
  if questState then
    if questState.iState == TaskManager.TaskState.Finish then
      item.obj_canGet:SetActive(true)
      item.obj_fxCanGet:SetActive(true)
      item.obj_got:SetActive(false)
    elseif questState.iState == TaskManager.TaskState.Doing then
      item.obj_canGet:SetActive(false)
      item.obj_fxCanGet:SetActive(false)
      item.obj_got:SetActive(false)
    elseif questState.iState == TaskManager.TaskState.Completed then
      item.obj_canGet:SetActive(false)
      item.obj_fxCanGet:SetActive(false)
      item.obj_got:SetActive(true)
    end
  else
    item.obj_canGet:SetActive(false)
    item.obj_fxCanGet:SetActive(false)
    item.obj_got:SetActive(false)
  end
end

function EmpousaActivitySubPanel:CheckRecycleAllSpine()
  if not self.LoadedHeroList then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  local heroSpineObjKey = next(self.LoadedHeroList)
  if heroSpineObjKey then
    local heroSpineObj = self.LoadedHeroList[heroSpineObjKey]
    if heroSpineObj then
      UILuaHelper.SpineResetMatParam(heroSpineObj.spineObj)
    end
  end
  for i, tempHeroSpineObj in pairs(self.LoadedHeroList) do
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(tempHeroSpineObj)
  end
  self.LoadedHeroList = {}
end

function EmpousaActivitySubPanel:CheckRecycleSpine(heroID)
  if self.m_HeroSpineDynamicLoader and self.LoadedHeroList[heroID] ~= nil then
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.LoadedHeroList[heroID])
    self.LoadedHeroList[heroID] = nil
  end
end

function EmpousaActivitySubPanel:LoadHeroSpine(heroID, heroSpineAssetName, uiParent, loadSucBack)
  if not heroID then
    return
  end
  if not heroSpineAssetName then
    return
  end
  local showTypeStr = "herodetail"
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine(heroID)
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine(heroID)
      self.LoadedHeroList[heroID] = spineLoadObj
      local spineObj = spineLoadObj.spineObj
      UILuaHelper.SetActive(spineObj, true)
      UILuaHelper.SpineResetInit(spineObj)
      local heroSpineTrans = spineLoadObj.spineTrans
      if heroSpineTrans:GetComponent("SpineSkeletonPosControl") then
        heroSpineTrans:GetComponent("SpineSkeletonPosControl"):OnResetInit()
      end
      if loadSucBack then
        loadSucBack()
      end
    end)
  end
end

function EmpousaActivitySubPanel:OnBtnsearchClicked()
  local clientCfg = self.m_stActivity:GetClientCfg()
  local iHeroId = clientCfg.iHeroId
  StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {heroID = iHeroId})
end

function EmpousaActivitySubPanel:RequestGetReward(questInfo)
  self.m_stActivity:RequestGetReward(questInfo.iId, function(sc, stParam)
    local item
    if stParam.iId ~= nil then
      for k, v in ipairs(self.mComponents) do
        local info = self.m_stActivity:GetQuestList()[k]
        if info.iId == stParam.iId then
          item = v
          break
        end
      end
    end
    if item and item.obj_got then
      self:OnLevelAwardUpdate(stParam)
      UILuaHelper.PlayAnimationByName(item.obj_got, "activity_clive_list_done")
      local aniLen = UILuaHelper.GetAnimationLengthByName(item.obj_got, "activity_clive_list_done")
      self.m_UILockID = UILockIns:Lock(aniLen)
      TimeService:SetTimer(aniLen, 1, function()
        local vReward = sc.vReward
        utils.popUpRewardUI(vReward)
      end)
    end
  end)
end

function EmpousaActivitySubPanel:OnClickTask(idx)
  local questList = self.m_stActivity:GetQuestList()
  local questInfo = questList[idx]
  if not questInfo then
    return
  end
  local questState = self.m_stActivity:GetQuestState(questInfo.iId)
  if questState.iState == TaskManager.TaskState.Finish then
    self:RequestGetReward(questInfo)
  elseif questState.iState == TaskManager.TaskState.Doing then
    QuickOpenFuncUtil:OpenFunc(questInfo.iJump)
  end
end

function EmpousaActivitySubPanel:OnBtnitetask1Clicked()
  self:OnClickTask(1)
end

function EmpousaActivitySubPanel:OnBtnitetask2Clicked()
  self:OnClickTask(2)
end

function EmpousaActivitySubPanel:OnBtnitetask3Clicked()
  self:OnClickTask(3)
end

function EmpousaActivitySubPanel:OnBtngoClicked()
  QuickOpenFuncUtil:OpenFunc(1)
end

return EmpousaActivitySubPanel
