local UISubPanelBase = require("UI/Common/UISubPanelBase")
local AttractFactionSubPanel = class("AttractFactionSubPanel", UISubPanelBase)
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")

function AttractFactionSubPanel:OnInit()
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
end

function AttractFactionSubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.curShowHeroData
  self.m_stContentData = self.m_panelData.stContentData
  self.m_vFaction = self.m_stContentData.vFaction
  self.m_txt_name_Text.text = self.m_curShowHeroData.characterCfg.m_mName
  self.m_lastSelectTab = nil
  self:InitTab()
  self:SelectTab(1)
  self:CheckRedDot()
end

function AttractFactionSubPanel:InitTab()
  for k, v in ipairs(self.m_tabList) do
    v.root:SetActive(false)
  end
  local tabInfo
  for k, v in ipairs(self.m_vFaction) do
    tabInfo = self.m_tabList[k]
    if tabInfo then
      tabInfo.root:SetActive(true)
      tabInfo.selectItemText.text = string.format("%02d", k)
      tabInfo.unselectItemText.text = string.format("%02d", k)
      self:SetTabSelect(k, false)
    end
  end
end

function AttractFactionSubPanel:SetTabSelect(iTab, bSelected)
  local tabInfo = self.m_tabList[iTab]
  if bSelected then
    tabInfo.selectItem:SetActive(true)
    tabInfo.unselectItem:SetActive(false)
    tabInfo.redItem:SetActive(false)
  else
    tabInfo.selectItem:SetActive(false)
    tabInfo.unselectItem:SetActive(true)
    local stStoryData = self.m_vFaction[iTab]
    local iStoryId = stStoryData.m_StoryId
    local iHeroId = self.m_curShowHeroData.serverData.iHeroId
    local islocked = false
    if self.m_curShowHeroData.serverData.iAttractRank < stStoryData.m_UnlockAttractRank or LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, stStoryData.m_UnlockMainline) == false then
      islocked = true
    end
    tabInfo.redItem:SetActive(islocked and (AttractManager:CheckStoryNew(iHeroId, iStoryId) or AttractManager:CanReceiveGift(iHeroId, iStoryId)))
  end
end

function AttractFactionSubPanel:OnBtntab1Clicked()
  self:SelectTab(1)
end

function AttractFactionSubPanel:OnBtntab2Clicked()
  self:SelectTab(2)
end

function AttractFactionSubPanel:OnBtntab3Clicked()
  self:SelectTab(3)
end

function AttractFactionSubPanel:OnBtntab4Clicked()
  self:SelectTab(4)
end

function AttractFactionSubPanel:OnBtntab5Clicked()
  self:SelectTab(5)
end

function AttractFactionSubPanel:SelectTab(iTab)
  if self.m_lastSelectTab == iTab then
    return
  end
  if self.m_lastSelectTab then
    self:SetTabSelect(self.m_lastSelectTab, false)
  end
  self:SetTabSelect(iTab, true)
  self.m_lastSelectTab = iTab
  self:FreshStory(self.m_vFaction[iTab])
end

function AttractFactionSubPanel:FreshStory(stStoryData)
  self.m_txt_title_Text.text = stStoryData.m_mSectionTitle
  local islocked = false
  if self.m_curShowHeroData.serverData.iAttractRank < stStoryData.m_UnlockAttractRank or LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, stStoryData.m_UnlockMainline) == false then
    islocked = true
  end
  UILuaHelper.ResetAnimationByName(self.m_pnl_lock, "m_pnl_lock_in")
  local isNew = AttractManager:CheckStoryNew(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId)
  if islocked or not islocked and isNew then
    for k, v in ipairs(self.m_conditionList) do
      v.root:SetActive(false)
    end
    self.m_pnl_lock:SetActive(true)
    self.m_mask_scrollview:SetActive(false)
    local iConditionCount = 0
    if stStoryData.m_UnlockAttractRank > 0 then
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
    if stStoryData.m_UnlockMainline > 0 then
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
      self.m_outTimer = TimeService:SetTimer(outLen, 1, function()
        self.m_pnl_lock:SetActive(false)
        self.m_mask_scrollview:SetActive(true)
        self.m_txt_biography_desc_Text.text = stStoryData.m_mText
        self.m_outTimer = nil
      end)
    end
  else
    self.m_pnl_lock:SetActive(false)
    self.m_mask_scrollview:SetActive(true)
    self.m_txt_biography_desc_Text.text = stStoryData.m_mText
  end
  self:FreshGift(islocked, stStoryData)
end

function AttractFactionSubPanel:FreshGift(islocked, stStoryData)
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

function AttractFactionSubPanel:CheckRedDot()
end

function AttractFactionSubPanel:OnBtngiftitemClicked()
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

function AttractFactionSubPanel:OnInactivePanel()
  UILuaHelper.StopAnimation(self.m_pnl_lock)
  if self.m_outTimer then
    TimeService:KillTimer(self.m_outTimer)
    self.m_outTimer = nil
  end
end

function AttractFactionSubPanel:OnActivePanel()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "ui_attract_panel_camp_in")
end

return AttractFactionSubPanel
