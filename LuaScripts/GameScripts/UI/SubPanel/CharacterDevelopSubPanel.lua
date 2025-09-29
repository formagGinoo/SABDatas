local UISubPanelBase = require("UI/Common/UISubPanelBase")
local CharacterDevelopSubPanel = class("CharacterDevelopSubPanel", UISubPanelBase)
local tabButton = {
  "break",
  "eqp",
  "fp"
}

function CharacterDevelopSubPanel:OnInit()
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_scrollviewLoopScrollView = self:CreateLoopScrollView(self.m_scrollview:GetComponent(T_LoopScrollView), "PayStore/CharacterDevelopItem", {})
  self.m_scrollviewLoopScrollView:SetCellSizeForIndexDelegate(function(index)
    if not self.m_stActivityGroup[index + 1] then
      return Vector2.New(200, 0)
    end
    if self.m_stActivityGroup[index + 1].isTitle then
      return Vector2.New(200, 60)
    end
    if self.m_stActivityGroup[index + 1].isEnd then
      return Vector2.New(200, 0)
    end
    return Vector2.New(200, 228)
  end)
  self.m_scroll_viewport = self.m_scrollview:GetComponent(T_ScrollRect).viewport.transform
  self.m_lastScrollIndex = nil
end

function CharacterDevelopSubPanel:InitUI()
end

function CharacterDevelopSubPanel:OnActivePanel()
  self:RemoveEventListeners()
  self:AddEventListeners()
  UILuaHelper.PlayAnimationByName(self.m_rootObj.transform, "Activity_panel_LVL_in")
end

function CharacterDevelopSubPanel:GetRecentIndex()
  if not self.m_stActivityGroup or not self.activityData then
    return nil
  end
  for index, item in ipairs(self.m_stActivityGroup) do
    if item.isTitle and item.data then
      local groupId = item.data.iGroupId
      if self.activityData:GetTrainRedByGroupId(groupId) then
        log.info("ahuan" .. index)
        return index, self:GetGroupNameById(groupId)
      end
    end
  end
  for index, item in ipairs(self.m_stActivityGroup) do
    if item.isTask and item.data then
      local trainId = item.data.iId
      local taskAchieved = self.activityData:IsTaskCanGetReward(trainId)
      local taskStatus = self.activityData:GetTrainStatusByTrainId(trainId)
      local soldOut = false
      if taskStatus and taskStatus.iBought >= item.data.iLimitNum then
        soldOut = true
      end
      if taskAchieved and not soldOut then
        for titleIndex, titleItem in ipairs(self.m_stActivityGroup) do
          if titleItem.isTitle and titleItem.data and titleItem.data.iGroupId == item.data.iTaskGroup then
            log.info("ahuan" .. titleIndex)
            return titleIndex, self:GetGroupNameById(titleItem.data.iGroupId)
          end
        end
      end
    end
  end
  return nil
end

function CharacterDevelopSubPanel:GetGroupNameById(groupId)
  log.info("ahuan" .. groupId)
  if tabButton and groupId and 1 <= groupId and groupId <= #tabButton then
    return tabButton[groupId]
  end
  return "break"
end

function CharacterDevelopSubPanel:MoveToRecentIndex()
  local recentIndex, recentGroupName = self:GetRecentIndex()
  if recentIndex then
    if recentGroupName then
      self:OnSwitchTab(recentGroupName, true)
    end
    self.m_scrollviewLoopScrollView:ScrollTo(recentIndex, 0)
    self.m_lastScrollIndex = recentIndex
  else
    self:OnSwitchTab("break", true)
    self.m_scrollviewLoopScrollView:ScrollTo(1, 0)
    self.m_lastScrollIndex = 1
  end
end

function CharacterDevelopSubPanel:ShowItemListAnim()
  UILuaHelper.PlayAnimationByName(self.m_scroll_viewport, "Activity_panel_LVL_switch_in")
end

function CharacterDevelopSubPanel:OnFreshData()
  local m_panelData = self.m_panelData.storeData
  self.activityData = self:GetActivityByTypeAndStoreId(MTTD.ActivityType_Train, m_panelData.iStoreId)
  if not self.activityData then
    log.error("activityData not found")
    return
  end
  self.m_stActivityCommonData = self.activityData.mTrianCommonData
  self.m_stActivityClientData = self.activityData.mTrianClientData
  self.activityData:SetStoreData(self.m_panelData.storeData)
  self.m_txt_timeleft_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(220020), TimeUtil:SecondsToFormatCNStr4(self.activityData:getActivityEndTime() - self.activityData:getActivityBeginTime()))
  self:RefreshClientData()
  self:OnSwitchTab("break", true)
  self:UpdateLeftPanel()
  self:MoveToRecentIndex()
end

function CharacterDevelopSubPanel:OnInactivePanel()
  self.m_lastScrollIndex = nil
  self:CheckRecycleSpine()
  self:RemoveEventListeners()
end

function CharacterDevelopSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_TrainUpdate", handler(self, self.OnEventTrainUpdate))
  self:addEventListener("eGameEvent_PayStore_RedDot_ChangeCount", handler(self, self.OnEventPayStoreRedDotChangeCount))
end

function CharacterDevelopSubPanel:RemoveEventListeners()
  self:removeEventListener("eGameEvent_Activity_TrainUpdate", handler(self, self.OnEventTrainUpdate))
  self:removeEventListener("eGameEvent_PayStore_RedDot_ChangeCount", handler(self, self.OnEventPayStoreRedDotChangeCount))
end

function CharacterDevelopSubPanel:OnDestroy()
  CharacterDevelopSubPanel.super.OnDestroy(self)
end

function CharacterDevelopSubPanel:OnUpdate(dt)
end

function CharacterDevelopSubPanel:OnEventPayStoreRedDotChangeCount()
  if not self.activityData then
    return
  end
  for _, v in ipairs(tabButton) do
    self["m_btn_" .. v].transform:Find("m_img_redpoint").gameObject:SetActive(self.activityData:GetTrainRedByGroupId(_))
  end
end

function CharacterDevelopSubPanel:RefreshClientData()
  log.info("self.m_stActivityClientData" .. table.serialize(self.m_stActivityClientData))
  if not string.IsNullOrEmpty(self.m_stActivityClientData.sGiftBackground) then
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_img_bg_Image, self.m_stActivityClientData.sGiftBackground, nil, nil, true)
  end
end

function CharacterDevelopSubPanel:OnEventTrainUpdate(iActivityId)
  if not self.activityData then
    return
  end
  if iActivityId == self.activityData:getID() then
    self:UpdateLeftPanel()
    self:UpdateRightPanel()
  end
end

function CharacterDevelopSubPanel:RefreshLoopScroll(force)
  local data = self.m_stActivityGroup
  if self.m_scrollviewLoopScrollView then
    self.m_scrollviewLoopScrollView:ShowItemList(data, force)
  end
end

function CharacterDevelopSubPanel:UpdateLeftPanel()
  local heroId = self.m_stActivityCommonData.iHeroId
  if heroId then
    local heroCfg = HeroManager:GetHeroConfigByID(heroId)
    if heroCfg then
      ResourceUtil:CreateCareerImg(self.m_img_career_Image, heroCfg.m_Career)
      self:LoadHeroSpine(heroCfg.m_Spine)
      self.m_txt_hero_name_Text.text = heroCfg.m_mName
    end
  end
end

function CharacterDevelopSubPanel:UpdateRightPanel(force)
  self:RefreshLoopScroll(force)
end

function CharacterDevelopSubPanel:LoadHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, SpinePlaceCfg.GrowUpGift, self.m_root_role, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spinePlaceObj, true)
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
      UILuaHelper.SetSpineTimeScale(spineLoadObj.spineObj, 1)
    end)
  end
end

function CharacterDevelopSubPanel:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
    self.m_SpineStrCfg = nil
  end
end

function CharacterDevelopSubPanel:OnBtnbreakClicked()
  self:OnSwitchTab("break")
end

function CharacterDevelopSubPanel:OnBtneqpClicked()
  self:OnSwitchTab("eqp")
end

function CharacterDevelopSubPanel:OnBtnfpClicked()
  self:OnSwitchTab("fp")
end

function CharacterDevelopSubPanel:OnBtntimeClicked()
  utils.popUpDirectionsUI({
    tipsID = 1264,
    func1 = function()
    end
  })
end

function CharacterDevelopSubPanel:OnBtncareerdetailClicked()
  local heroCfg = HeroManager:GetHeroConfigByID(self.m_stActivityCommonData.iHeroId)
  StackPopup:Push(UIDefines.ID_FORM_HEROCAREERDETAIL, {heroCfg = heroCfg})
end

function CharacterDevelopSubPanel:OnBtnsrchClicked()
  StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
    heroID = self.m_stActivityCommonData.iHeroId
  })
end

function CharacterDevelopSubPanel:OnSwitchTab(name, force)
  local curIndex = 1
  local moveIndex = 1
  for _, v in ipairs(tabButton) do
    self["m_icon_" .. v .. "grey"]:SetActive(v ~= name)
    self["m_icon_" .. v .. "light"]:SetActive(v == name)
    self["m_btn_" .. v].transform:Find("m_img_redpoint").gameObject:SetActive(self.activityData:GetTrainRedByGroupId(_))
    curIndex = v == name and _ or curIndex
  end
  self.m_stActivityGroup = self:GenerateTaskData()
  self:UpdateRightPanel(force)
  for _, v in pairs(self.m_stActivityGroup) do
    if v.isTitle and v.data.iGroupId == curIndex then
      moveIndex = _
      break
    end
  end
  if not force then
    self.m_scrollviewLoopScrollView:ScrollTo(moveIndex, 0)
  end
  self:ShowItemListAnim()
end

function CharacterDevelopSubPanel:GenerateTaskData()
  if not self.activityData then
    return {}
  end
  local data = {}
  local taskGroup = self.activityData:GetTaskGroup()
  local first = true
  for _, v in pairs(taskGroup) do
    if not first then
      table.insert(data, {
        isEnd = true,
        activityData = self.activityData
      })
    end
    first = false
    self.activityData:GetTrainStatusByTrainId(v.iGroupId)
    table.insert(data, {
      isTitle = true,
      data = self.activityData:GetGroupConfigByGroupId(v.iGroupId),
      activityData = self.activityData
    })
    local tasklist = self.activityData:GetTrainsByGroupId(v.iGroupId)
    local taskIndex = 0
    for _, v in pairs(tasklist) do
      taskIndex = taskIndex + 1
      table.insert(data, {
        isTask = true,
        data = v,
        iTaskIndex = taskIndex,
        activityData = self.activityData
      })
    end
  end
  return data
end

function CharacterDevelopSubPanel:GetActivityByTypeAndStoreId(iActivityType, storeId)
  local activityList = ActivityManager:GetActivityListByType(iActivityType)
  for _, activity in ipairs(activityList) do
    if activity.mTrianCommonData.iStoreId == storeId then
      return activity
    end
  end
  return nil
end

return CharacterDevelopSubPanel
