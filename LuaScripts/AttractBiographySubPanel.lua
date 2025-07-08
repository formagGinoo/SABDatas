local UISubPanelBase = require("UI/Common/UISubPanelBase")
local AttractBiographySubPanel = class("AttractBiographySubPanel", UISubPanelBase)
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local AttractStoryIns = ConfigManager:GetConfigInsByName("AttractStory")
local HeroTagCfg = {Attract = 1}
local ShowTabHeroPos = {
  [HeroTagCfg.Attract] = {
    isMaskAndGray = true,
    position = {
      -300,
      0,
      0
    },
    scale = {
      1,
      1,
      1
    },
    posTime = 0.01,
    scaleTime = 0.1,
    posTween = nil,
    scaleTween = nil
  }
}

function AttractBiographySubPanel:OnInit()
  self.m_tabList = {}
  self.m_tabList[#self.m_tabList + 1] = {
    root = self.m_btn_tab1,
    selectItem = self.m_img_red_line1,
    selectItemText = self.m_txt_day1_Text,
    unselectItem = self.m_txt_day_unselect1,
    unselectItemText = self.m_txt_day_unselect1_Text,
    redItem = self.m_img_red1
  }
  self.m_tabList[#self.m_tabList + 1] = {
    root = self.m_btn_tab2,
    selectItem = self.m_img_red_line2,
    selectItemText = self.m_txt_day2_Text,
    unselectItem = self.m_txt_day_unselect2,
    unselectItemText = self.m_txt_day_unselect2_Text,
    redItem = self.m_img_red2
  }
  self.m_tabList[#self.m_tabList + 1] = {
    root = self.m_btn_tab3,
    selectItem = self.m_img_red_line3,
    selectItemText = self.m_txt_day3_Text,
    unselectItem = self.m_txt_day_unselect3,
    unselectItemText = self.m_txt_day_unselect3_Text,
    redItem = self.m_img_red3
  }
  self.m_tabList[#self.m_tabList + 1] = {
    root = self.m_btn_tab4,
    selectItem = self.m_img_red_line4,
    selectItemText = self.m_txt_day4_Text,
    unselectItem = self.m_txt_day_unselect4,
    unselectItemText = self.m_txt_day_unselect4_Text,
    redItem = self.m_img_red4
  }
  self.m_tabList[#self.m_tabList + 1] = {
    root = self.m_btn_tab5,
    selectItem = self.m_img_red_line5,
    selectItemText = self.m_txt_day5_Text,
    unselectItem = self.m_txt_day_unselect5,
    unselectItemText = self.m_txt_day_unselect5_Text,
    redItem = self.m_img_red5
  }
  self.m_conditionList = {}
  self.m_conditionList[#self.m_conditionList + 1] = {
    root = self.m_item_condition1,
    unlock = self.m_unlock1,
    lock = self.m_lock1,
    desc_unlock = self.m_txt_desc_unlock1_Text,
    desc_lock = self.m_txt_desc_lock1_Text
  }
  self.m_conditionList[#self.m_conditionList + 1] = {
    root = self.m_item_condition2,
    unlock = self.m_unlock2,
    lock = self.m_lock2,
    desc_unlock = self.m_txt_desc_unlock2_Text,
    desc_lock = self.m_txt_desc_lock2_Text
  }
  self.m_conditionList[#self.m_conditionList + 1] = {
    root = self.m_item_condition3,
    unlock = self.m_unlock3,
    lock = self.m_lock3,
    desc_unlock = self.m_txt_desc_unlock3_Text,
    desc_lock = self.m_txt_desc_lock3_Text
  }
end

function AttractBiographySubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.curShowHeroData
  self.m_stContentData = self.m_panelData.stContentData
  self.m_vBiography = self.m_stContentData.vBiography
  self.m_txt_name_Text.text = self.m_curShowHeroData.characterCfg.m_mFullName
  local performanceID = self.m_curShowHeroData.characterCfg.m_PerformanceID[0]
  local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(self.m_img_head1_Image, szIcon)
  self.m_lastSelectTab = nil
  self:InitTab()
  self:SelectTab(1)
  self:CheckRedDot()
end

function AttractBiographySubPanel:InitTab()
  for k, v in ipairs(self.m_tabList) do
    v.root:SetActive(false)
  end
  local tabInfo
  for k, v in ipairs(self.m_vBiography) do
    tabInfo = self.m_tabList[k]
    if tabInfo then
      tabInfo.root:SetActive(true)
      tabInfo.selectItemText.text = string.format("%02d", k)
      tabInfo.unselectItemText.text = string.format("%02d", k)
      self:SetTabSelect(k, false)
    end
  end
end

function AttractBiographySubPanel:CheckStoryLock(stStoryData)
  return self.m_curShowHeroData.serverData.iAttractRank < stStoryData.m_UnlockAttractRank or LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, stStoryData.m_UnlockMainline) == false or not AttractManager:HasSawStory(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_PreStoryId)
end

function AttractBiographySubPanel:SetTabSelect(iTab, bSelected)
  local tabInfo = self.m_tabList[iTab]
  if bSelected then
    tabInfo.selectItem:SetActive(true)
    tabInfo.unselectItem:SetActive(false)
    tabInfo.redItem:SetActive(false)
  else
    tabInfo.selectItem:SetActive(false)
    tabInfo.unselectItem:SetActive(true)
    local stStoryData = self.m_vBiography[iTab]
    local iStoryId = stStoryData.m_StoryId
    local iHeroId = self.m_curShowHeroData.serverData.iHeroId
    local islocked = self:CheckStoryLock(stStoryData)
    tabInfo.redItem:SetActive(islocked == false and (AttractManager:CheckStoryNew(iHeroId, iStoryId) or AttractManager:CanReceiveGift(iHeroId, iStoryId)))
  end
end

function AttractBiographySubPanel:CheckTabRed()
  for k, v in ipairs(self.m_vBiography) do
    if k ~= self.m_lastSelectTab then
      tabInfo = self.m_tabList[k]
      if tabInfo then
        self:SetTabSelect(k, false)
      end
    end
  end
end

function AttractBiographySubPanel:OnBtntab1Clicked()
  self:SelectTab(1)
end

function AttractBiographySubPanel:OnBtntab2Clicked()
  self:SelectTab(2)
end

function AttractBiographySubPanel:OnBtntab3Clicked()
  self:SelectTab(3)
end

function AttractBiographySubPanel:OnBtntab4Clicked()
  self:SelectTab(4)
end

function AttractBiographySubPanel:OnBtntab5Clicked()
  self:SelectTab(5)
end

function AttractBiographySubPanel:SelectTab(iTab)
  if self.m_lastSelectTab == iTab then
    return
  end
  GlobalManagerIns:TriggerWwiseBGMState(66)
  if self.m_lastSelectTab then
    self:SetTabSelect(self.m_lastSelectTab, false)
  end
  self:SetTabSelect(iTab, true)
  self.m_lastSelectTab = iTab
  self:FreshStory(self.m_vBiography[iTab])
end

function AttractBiographySubPanel:FreshStory(stStoryData)
  self.m_txt_title_Text.text = stStoryData.m_mSectionTitle
  local islocked = self:CheckStoryLock(stStoryData)
  UILuaHelper.ResetAnimationByName(self.m_pnl_lock, "m_pnl_lock_in")
  local isNew = AttractManager:CheckStoryNew(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId)
  if islocked or not islocked and isNew then
    for k, v in ipairs(self.m_conditionList) do
      v.root:SetActive(false)
    end
    self.m_pnl_lock:SetActive(true)
    self.m_mask_scrollview:SetActive(false)
    local iConditionCount = 0
    if stStoryData.m_PreStoryId ~= 0 then
      iConditionCount = iConditionCount + 1
      local conditionInfo = self.m_conditionList[iConditionCount]
      conditionInfo.root:SetActive(true)
      local strTips = CommonTextIns:GetValue_ById(100104).m_mMessage
      local stPreTimeline = AttractStoryIns:GetValue_ByHeroIDAndStoryId(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_PreStoryId)
      strTips = string.gsub(strTips, "{0}", stPreTimeline.m_mSectionTitle)
      if not AttractManager:HasSawStory(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_PreStoryId) then
        conditionInfo.desc_lock.text = strTips
        conditionInfo.unlock:SetActive(false)
        conditionInfo.lock:SetActive(true)
      else
        conditionInfo.desc_unlock.text = strTips
        conditionInfo.unlock:SetActive(true)
        conditionInfo.lock:SetActive(false)
      end
    end
    if 0 < stStoryData.m_UnlockAttractRank then
      iConditionCount = iConditionCount + 1
      local conditionInfo = self.m_conditionList[iConditionCount]
      conditionInfo.root:SetActive(true)
      local strTips = CommonTextIns:GetValue_ById(100063).m_mMessage
      strTips = string.gsub(strTips, "{0}", stStoryData.m_UnlockAttractRank)
      if self.m_curShowHeroData.serverData.iAttractRank < stStoryData.m_UnlockAttractRank then
        conditionInfo.desc_lock.text = strTips
        conditionInfo.unlock:SetActive(false)
        conditionInfo.lock:SetActive(true)
      else
        conditionInfo.desc_unlock.text = strTips
        conditionInfo.unlock:SetActive(true)
        conditionInfo.lock:SetActive(false)
      end
    end
    if 0 < stStoryData.m_UnlockMainline then
      iConditionCount = iConditionCount + 1
      local conditionInfo = self.m_conditionList[iConditionCount]
      conditionInfo.root:SetActive(true)
      local cfg = LevelManager:GetMainLevelCfgById(stStoryData.m_UnlockMainline)
      local strTips = CommonTextIns:GetValue_ById(100064).m_mMessage
      strTips = string.gsub(strTips, "{0}", cfg.m_LevelName)
      if LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, stStoryData.m_UnlockMainline) == false then
        conditionInfo.desc_lock.text = strTips
        conditionInfo.unlock:SetActive(false)
        conditionInfo.lock:SetActive(true)
      else
        conditionInfo.desc_unlock.text = strTips
        conditionInfo.unlock:SetActive(true)
        conditionInfo.lock:SetActive(false)
      end
    end
    if not islocked and isNew then
      AttractManager:SaveStoryNew(self.m_curShowHeroData.serverData.iHeroId, {
        stStoryData.m_StoryId
      })
      local outLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_lock, "m_pnl_lock_in")
      UILuaHelper.PlayAnimationByName(self.m_pnl_lock, "m_pnl_lock_in")
      GlobalManagerIns:TriggerWwiseBGMState(67)
      self.m_outTimer = TimeService:SetTimer(outLen, 1, function()
        self.m_pnl_lock:SetActive(false)
        self.m_txt_biography_desc_Text.text = stStoryData.m_mText
        self.m_mask_scrollview:SetActive(true)
        self.m_mask_scrollview.transform:Find("scrollview"):GetComponent("ScrollRect").verticalNormalizedPosition = 1.0
        UILuaHelper.ForceRebuildLayoutImmediate(self.m_mask_scrollview)
        self.m_outTimer = nil
        if not AttractManager:HasSawStory(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId) then
          AttractManager:ReqSeeStory(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId)
        end
      end)
    end
  else
    self.m_pnl_lock:SetActive(false)
    self.m_txt_biography_desc_Text.text = stStoryData.m_mText
    self.m_mask_scrollview:SetActive(true)
    self.m_mask_scrollview.transform:Find("scrollview"):GetComponent("ScrollRect").verticalNormalizedPosition = 1.0
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_mask_scrollview)
    if not AttractManager:HasSawStory(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId) then
      AttractManager:ReqSeeStory(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId)
    end
  end
  self:FreshGift(islocked, stStoryData)
end

function AttractBiographySubPanel:FreshGift(islocked, stStoryData)
  self.m_islocked = islocked
  self.m_stStoryData = stStoryData
  if not AttractManager:storyHasReward(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId) then
    self.m_btn_gift_item:SetActive(false)
    return
  end
  self.m_btn_gift_item:SetActive(true)
  if islocked then
    self.m_task_cannot_receive:SetActive(true)
    self.m_task_can_receive:SetActive(false)
    self.m_task_have_receive:SetActive(false)
  elseif AttractManager:CanReceiveGift(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId) then
    self.m_task_cannot_receive:SetActive(false)
    self.m_task_can_receive:SetActive(true)
    self.m_task_have_receive:SetActive(false)
  else
    self.m_task_cannot_receive:SetActive(false)
    self.m_task_can_receive:SetActive(false)
    self.m_task_have_receive:SetActive(true)
  end
end

function AttractBiographySubPanel:CheckRedDot()
end

function AttractBiographySubPanel:OnBtngiftitemClicked()
  if self.m_islocked or not AttractManager:CanReceiveGift(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId) then
    StackFlow:Push(UIDefines.ID_FORM_COMMONTIPPREVIEW, {
      vReward = self.m_stStoryData.m_Rewards
    })
    return
  else
    AttractManager:ReqTakeStoryReward(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId, function()
      self:FreshGift(self.m_islocked, self.m_stStoryData)
    end)
  end
end

function AttractBiographySubPanel:OnInactivePanel()
  UILuaHelper.StopAnimation(self.m_pnl_lock)
  if self.m_outTimer then
    TimeService:KillTimer(self.m_outTimer)
    self.m_outTimer = nil
  end
  self:clearEventListener()
end

function AttractBiographySubPanel:OnActivePanel()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "ui_attract_panel_camp_in")
  self:addEventListener("eGameEvent_Hero_AttractRedCheck", handler(self, self.OnAttractRedCheck))
end

function AttractBiographySubPanel:OnAttractRedCheck()
  self:CheckTabRed()
end

return AttractBiographySubPanel
