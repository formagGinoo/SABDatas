local UISubPanelBase = require("UI/Common/UISubPanelBase")
local AttractTimeLineSubPanel = class("AttractTimeLineSubPanel", UISubPanelBase)
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local AttractStoryIns = ConfigManager:GetConfigInsByName("AttractStory")

function AttractTimeLineSubPanel:OnInit()
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

function AttractTimeLineSubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.curShowHeroData
  self.m_stContentData = self.m_panelData.stContentData
  self.m_stTimeline = self.m_stContentData.stTimeline
  self:FreshTimeline(self.m_stTimeline)
end

function AttractTimeLineSubPanel:AddEventListeners()
end

function AttractTimeLineSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function AttractTimeLineSubPanel:CheckStoryLock(stStoryData)
  return self.m_curShowHeroData.serverData.iAttractRank < stStoryData.m_UnlockAttractRank or LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, stStoryData.m_UnlockMainline) == false or not AttractManager:HasSawStory(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_PreStoryId)
end

function AttractTimeLineSubPanel:FreshTimeline(stStoryData)
  self.m_txt_name_Text.text = stStoryData.m_mSectionTitle
  self.m_txt_camp_desc_Text.text = stStoryData.m_mText
  self.m_img_timeline:SetActive(false)
  UILuaHelper.SetAtlasSprite(self.m_img_timeline_Image, stStoryData.m_TimelinePic, function()
    self.m_img_timeline:SetActive(true)
  end)
  for k, v in ipairs(self.m_conditionList) do
    v.root:SetActive(false)
  end
  local islocked = self:CheckStoryLock(stStoryData)
  self:FreshGift(islocked, stStoryData)
  UILuaHelper.ResetAnimationByName(self.m_img_lock1, "m_img_lock1_in")
  self.m_txt_camp_desc.transform.parent.parent:GetComponent("ScrollRect").verticalNormalizedPosition = 1.0
  local isNew = AttractManager:CheckStoryNew(self.m_curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId)
  if islocked or not islocked and isNew then
    self.m_img_lock1:SetActive(true)
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
      local outLen = UILuaHelper.GetAnimationLengthByName(self.m_img_lock1, "m_img_lock1_in")
      UILuaHelper.PlayAnimationByName(self.m_img_lock1, "m_img_lock1_in")
      self.m_outTimer = TimeService:SetTimer(outLen, 1, function()
        for k, v in ipairs(self.m_conditionList) do
          v.root:SetActive(false)
        end
        self.m_img_lock1:SetActive(true)
        self.m_outTimer = nil
      end)
    end
  else
    self.m_img_lock1:SetActive(false)
  end
end

function AttractTimeLineSubPanel:FreshGift(islocked, stStoryData)
  self.m_islocked = islocked
  self.m_stStoryData = stStoryData
  if AttractManager:CheckStoryNew(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId) then
    self.m_icon_new:SetActive(true)
  else
    self.m_icon_new:SetActive(false)
  end
  if islocked then
    if not AttractManager:storyHasReward(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId) then
      self.m_btn_reward_lock:SetActive(false)
      self.m_btn_reward_get:SetActive(false)
      self.m_btn_reward_got:SetActive(false)
    else
      self.m_btn_reward_lock:SetActive(true)
      self.m_btn_reward_get:SetActive(false)
      self.m_btn_reward_got:SetActive(false)
    end
    self.m_btn_light:SetActive(false)
    self.m_btn_gray:SetActive(true)
  else
    if not AttractManager:HasSawStory(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId) then
      self.m_btn_reward_lock:SetActive(true)
      self.m_btn_reward_get:SetActive(false)
      self.m_btn_reward_got:SetActive(false)
    elseif not AttractManager:storyHasReward(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId) then
      self.m_btn_reward_lock:SetActive(false)
      self.m_btn_reward_get:SetActive(false)
      self.m_btn_reward_got:SetActive(false)
    elseif AttractManager:CanReceiveGift(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId) then
      self.m_btn_reward_lock:SetActive(false)
      self.m_btn_reward_get:SetActive(true)
      self.m_btn_reward_got:SetActive(false)
    else
      self.m_btn_reward_lock:SetActive(false)
      self.m_btn_reward_get:SetActive(false)
      self.m_btn_reward_got:SetActive(true)
    end
    self.m_btn_light:SetActive(true)
    self.m_btn_gray:SetActive(false)
  end
end

function AttractTimeLineSubPanel:OnBtnrewardlockClicked()
  StackFlow:Push(UIDefines.ID_FORM_COMMONTIPPREVIEW, {
    vReward = self.m_stStoryData.m_Rewards,
    sContent = ConfigManager:GetCommonTextById(100207)
  })
end

function AttractTimeLineSubPanel:OnBtnrewardgetClicked()
  AttractManager:ReqTakeStoryReward(self.m_curShowHeroData.serverData.iHeroId, self.m_stStoryData.m_StoryId, function()
    self:FreshGift(self.m_islocked, self.m_stStoryData)
  end)
end

function AttractTimeLineSubPanel:OnBtnrewardgotClicked()
  StackFlow:Push(UIDefines.ID_FORM_COMMONTIPPREVIEW, {
    vReward = self.m_stStoryData.m_Rewards,
    sContent = ConfigManager:GetCommonTextById(100207)
  })
end

function AttractTimeLineSubPanel:OnBtnlightClicked()
  self:broadcastEvent("eGameEvent_AttractBook_Show_Timeline")
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTTIMELINETRANSFORM, {
    stStoryData = self.m_stStoryData,
    curShowHeroData = self.m_curShowHeroData
  })
end

function AttractTimeLineSubPanel:OnBtngrayClicked()
end

function AttractTimeLineSubPanel:OnInactivePanel()
  UILuaHelper.StopAnimation(self.m_img_lock1)
  if self.m_outTimer then
    TimeService:KillTimer(self.m_outTimer)
    self.m_outTimer = nil
  end
end

function AttractTimeLineSubPanel:OnActivePanel()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "ui_attract_panel_prologue_in")
end

return AttractTimeLineSubPanel
