local UISubPanelBase = require("UI/Common/UISubPanelBase")
local CliveActivitySubPanel = class("CliveActivitySubPanel", UISubPanelBase)
local iMaxCount = 6

function CliveActivitySubPanel:OnInit()
  self:AddEventListeners()
  self.mComponents = {}
  for i = 1, iMaxCount do
    local trans = self["m_btn_task" .. i].transform
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
  self.MultiColorChange1 = self.m_z_txt_tab1:GetComponent("MultiColorChange")
  self.MultiColorChange2 = self.m_z_txt_tab2:GetComponent("MultiColorChange")
  self.aniHeroRoot = self.m_old_hero.transform.parent.gameObject
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.LoadedHeroList = {}
end

function CliveActivitySubPanel:OnInActive()
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
  self.m_UILockID = nil
end

function CliveActivitySubPanel:OnDestroy()
  CliveActivitySubPanel.super.OnDestroy(self)
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
  self.m_UILockID = nil
end

function CliveActivitySubPanel:OnFreshData()
  self.iCurTabIdx = 1
  self.m_stActivity = self.m_panelData.activity
  local clientCfg = self.m_stActivity:GetClientCfg()
  table.sort(clientCfg.vHeroConfig, function(a, b)
    if a.iOrder and b.iOrder then
      return a.iOrder < b.iOrder
    end
  end)
  local strDesc = self.m_stActivity:getLangText(tostring(self.m_stActivity.m_stActivityData.sDetailDesc))
  self.descList = string.split(strDesc, "/")
  local questList = self.m_stActivity:GetQuestList()
  local taskIdList1 = {}
  local taskIdList2 = {}
  local vUseQuestIdList1 = clientCfg.vHeroConfig[1].vUseQuestId
  local idList1 = string.split(vUseQuestIdList1, ";")
  local vUseQuestIdList2 = clientCfg.vHeroConfig[2].vUseQuestId
  local idList2 = string.split(vUseQuestIdList2, ";")
  local taskList = {}
  for i, v in ipairs(questList) do
    for _, idStr in ipairs(idList1) do
      if tonumber(idStr) == v.iId then
        table.insert(taskList, v)
        taskIdList1[#taskIdList1 + 1] = v
      end
    end
    for _, idStr in ipairs(idList2) do
      if tonumber(idStr) == v.iId then
        table.insert(taskList, v)
        taskIdList2[#taskIdList2 + 1] = v
      end
    end
  end
  self.taskList = taskList
  self.taskIdList1 = taskIdList1
  self.taskIdList2 = taskIdList2
  if self.iCurTabIdx == 1 then
    self.m_young_hero.transform:SetAsLastSibling()
    self.m_old_hero.transform:SetAsFirstSibling()
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.aniHeroRoot, "activity_clive_hero_in")
    TimeService:SetTimer(aniLen, 1, function()
      UILuaHelper.PlayAnimationByName(self.aniHeroRoot, "activity_clive_hero_young_loop")
    end)
  else
    self.m_old_hero.transform:SetAsLastSibling()
    self.m_young_hero.transform:SetAsFirstSibling()
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.aniHeroRoot, "activity_clive_hero_in")
    TimeService:SetTimer(aniLen, 1, function()
      UILuaHelper.PlayAnimationByName(self.aniHeroRoot, "activity_clive_hero_old_loop")
    end)
  end
  self:RefreshUI()
  self:RefreshTopTab()
end

function CliveActivitySubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_LevelAwardUpdate", handler(self, self.OnLevelAwardUpdate))
end

function CliveActivitySubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function CliveActivitySubPanel:RefreshTopTab()
  local questList = self.taskList
  self.m_img_redpoint1:SetActive(false)
  self.m_img_redpoint2:SetActive(false)
  for i, v in ipairs(questList) do
    local questState = self.m_stActivity:GetQuestState(v.iId)
    if questState and questState.iState == TaskManager.TaskState.Finish then
      for _, info in ipairs(self.taskIdList1) do
        if v.iId == info.iId then
          self.m_img_redpoint1:SetActive(true)
        end
      end
      for _, info in ipairs(self.taskIdList2) do
        if v.iId == info.iId then
          self.m_img_redpoint2:SetActive(true)
        end
      end
    end
  end
end

function CliveActivitySubPanel:OnLevelAwardUpdate(stParam)
  self.m_parentLua:RefreshTableButtonList()
  self:RefreshTopTab()
  if stParam == nil then
    return
  end
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  if stParam.iId ~= nil then
    for k, v in ipairs(self.mComponents) do
      local questInfo = self.taskList[k]
      if questInfo.iId == stParam.iId then
        self:RefreshRewardItem(v, questInfo, k)
        break
      end
    end
  end
end

function CliveActivitySubPanel:killRemainTimer()
end

function CliveActivitySubPanel:RefreshUI()
  if self.m_stActivity == nil then
    return
  end
  self.m_txt_title_Text.text = self.m_stActivity:getLangText(tostring(self.m_stActivity.m_stActivityData.sTitle))
  self.m_txt_condition_Text.text = self.descList[self.iCurTabIdx]
  local clientCfg = self.m_stActivity:GetClientCfg()
  local iHeroId = clientCfg.vHeroConfig[self.iCurTabIdx].iHeroId
  local characterIns = ConfigManager:GetConfigInsByName("CharacterInfo")
  local cfg = characterIns:GetValue_ByHeroID(iHeroId)
  if cfg:GetError() then
    log.error("can not find hero id in CharacterInfo config  id==" .. tostring(iHeroId))
    return
  end
  ResourceUtil:CreateHeroSSRQualityImg(self.m_img_rarity_Image, cfg.m_Quality)
  self.m_txt_hero_name_Text.text = cfg.m_mName
  if self.iCurTabIdx == 1 then
    self.m_pnl_listtask1:SetActive(true)
    self.m_pnl_listtask2:SetActive(false)
    self.m_img_sel_tab1:SetActive(true)
    self.m_img_sel_tab2:SetActive(false)
    self.MultiColorChange1:SetColorByIndex(1)
    self.MultiColorChange2:SetColorByIndex(0)
    if UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.RogueStage) then
      self.m_btn_go:SetActive(true)
      self.m_txt_lock_tips:SetActive(false)
    else
      self.m_btn_go:SetActive(false)
      self.m_txt_lock_tips:SetActive(true)
      local clientCfg = self.m_stActivity:GetClientCfg()
      self.m_txt_lock_tips_Text.text = self.m_stActivity:getLangText(clientCfg.vHeroConfig[1].sUnlockDesc)
    end
  else
    self.m_pnl_listtask1:SetActive(false)
    self.m_pnl_listtask2:SetActive(true)
    self.m_img_sel_tab1:SetActive(false)
    self.m_img_sel_tab2:SetActive(true)
    self.MultiColorChange1:SetColorByIndex(0)
    self.MultiColorChange2:SetColorByIndex(1)
    if UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Arena) then
      self.m_btn_go:SetActive(true)
      self.m_txt_lock_tips:SetActive(false)
    else
      self.m_btn_go:SetActive(false)
      self.m_txt_lock_tips:SetActive(true)
      local clientCfg = self.m_stActivity:GetClientCfg()
      self.m_txt_lock_tips_Text.text = self.m_stActivity:getLangText(clientCfg.vHeroConfig[2].sUnlockDesc)
    end
  end
  for i, v in ipairs(self.taskList) do
    local item = self.mComponents[i]
    if item then
      self:RefreshRewardItem(item, v)
    end
  end
end

function CliveActivitySubPanel:RefreshRewardItem(item, questInfo)
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

function CliveActivitySubPanel:OnBtnsearchClicked()
  local clientCfg = self.m_stActivity:GetClientCfg()
  local iHeroId = clientCfg.vHeroConfig[self.iCurTabIdx].iHeroId
  StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {heroID = iHeroId})
end

function CliveActivitySubPanel:OnTab1Clicked()
  self:OnClickTab(1)
end

function CliveActivitySubPanel:OnTab2Clicked()
  self:OnClickTab(2)
end

function CliveActivitySubPanel:OnClickTab(idx)
  if self.iCurTabIdx == idx then
    return
  end
  self.iCurTabIdx = idx
  self:RefreshUI()
  self:DoChangeAni()
end

function CliveActivitySubPanel:DoChangeAni()
  if self.iCurTabIdx == 1 then
    UILuaHelper.PlayAnimationByName(self.aniHeroRoot, "activity_clive_hero_young_cut")
    TimeService:SetTimer(0.1, 1, function()
      self.m_young_hero.transform:SetAsLastSibling()
      self.m_old_hero.transform:SetAsFirstSibling()
    end)
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.aniHeroRoot, "activity_clive_hero_young_cut")
    self.m_UILockID = UILockIns:Lock(aniLen)
    TimeService:SetTimer(aniLen, 1, function()
      UILuaHelper.PlayAnimationByName(self.aniHeroRoot, "activity_clive_hero_young_loop")
    end)
  else
    UILuaHelper.PlayAnimationByName(self.aniHeroRoot, "activity_clive_hero_old_cut")
    TimeService:SetTimer(0.1, 1, function()
      self.m_old_hero.transform:SetAsLastSibling()
      self.m_young_hero.transform:SetAsFirstSibling()
    end)
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.aniHeroRoot, "activity_clive_hero_old_cut")
    self.m_UILockID = UILockIns:Lock(aniLen)
    TimeService:SetTimer(aniLen, 1, function()
      UILuaHelper.PlayAnimationByName(self.aniHeroRoot, "activity_clive_hero_old_loop")
    end)
  end
end

function CliveActivitySubPanel:RequestGetReward(questInfo)
  self.m_stActivity:RequestGetReward(questInfo.iId, function(sc, stParam)
    local item
    if stParam.iId ~= nil then
      for k, v in ipairs(self.mComponents) do
        local info = self.taskList[k]
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

function CliveActivitySubPanel:OnClickTask(idx)
  local questInfo = self.taskList[idx]
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

function CliveActivitySubPanel:OnBtntask1Clicked()
  self:OnClickTask(1)
end

function CliveActivitySubPanel:OnBtntask2Clicked()
  self:OnClickTask(2)
end

function CliveActivitySubPanel:OnBtntask3Clicked()
  self:OnClickTask(3)
end

function CliveActivitySubPanel:OnBtntask4Clicked()
  self:OnClickTask(4)
end

function CliveActivitySubPanel:OnBtntask5Clicked()
  self:OnClickTask(5)
end

function CliveActivitySubPanel:OnBtntask6Clicked()
  self:OnClickTask(6)
end

function CliveActivitySubPanel:OnBtngoClicked()
  local clientCfg = self.m_stActivity:GetClientCfg()
  local iJumpType = clientCfg.vHeroConfig[self.iCurTabIdx].iJumpType
  local sJumpParam = clientCfg.vHeroConfig[self.iCurTabIdx].sJumpParam
  ActivityManager:DealJump(iJumpType, sJumpParam)
end

return CliveActivitySubPanel
