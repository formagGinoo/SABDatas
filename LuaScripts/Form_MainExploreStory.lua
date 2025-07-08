local Form_MainExploreStory = class("Form_MainExploreStory", require("UI/UIFrames/Form_MainExploreStoryUI"))

function Form_MainExploreStory:SetInitParam(param)
end

function Form_MainExploreStory:AfterInit()
  self.super.AfterInit(self)
  local root_trans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = root_trans.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_btn_symbol:SetActive(false)
  self.allConfig = nil
  self.m_scrollRect = self.m_item_list:GetComponent("ScrollRect")
  self.mItemListInfinityGrid = self:CreateInfinityGrid(self.m_item_list_InfinityGrid, "MainExplore/MainExploreStoryItem")
end

function Form_MainExploreStory:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(77)
  self:FreshUI()
  self.m_scrollRect.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
  self:addEventListener("eGameEvent_LostStory_GetReward", handler(self, self.FreshUI))
end

function Form_MainExploreStory:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_MainExploreStory:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MainExploreStory:FreshUI()
  if not self.allConfig then
    local _, all_config = MainExploreManager:GetMainLostStoryConfig()
    self.allConfig = table.copy(all_config)
  end
  local serverStoryData = MainExploreManager:GetServerStoryData()
  table.sort(self.allConfig, function(a, b)
    local aconfig = a[1]
    local a_unlock_count = MainExploreManager:GetUnlockStorySubCount(aconfig.m_StoryID)
    local is_got = false
    if serverStoryData and serverStoryData[aconfig.m_StoryID] then
      is_got = serverStoryData[aconfig.m_StoryID].iRewardTime > 0
    end
    local a_flag = not is_got and a_unlock_count == #a and 1 or 0
    local bconfig = b[1]
    local b_unlock_count = MainExploreManager:GetUnlockStorySubCount(bconfig.m_StoryID)
    is_got = false
    if serverStoryData and serverStoryData[bconfig.m_StoryID] then
      is_got = serverStoryData[bconfig.m_StoryID].iRewardTime > 0
    end
    local b_flag = not is_got and b_unlock_count == #b and 1 or 0
    if b_flag ~= a_flag then
      return a_flag > b_flag
    end
    return aconfig.m_StoryID < bconfig.m_StoryID
  end)
  self.mItemListInfinityGrid:ShowItemList(self.allConfig)
  local chapterID = self.m_csui.m_param.chapterID
  local config = MainExploreManager:GetMainExploreRewardCfgByChapterID(chapterID)
  local MainChapterIns = ConfigManager:GetConfigInsByName("MainChapter")
  local chapterCfg = MainChapterIns:GetValue_ByChapterID(chapterID)
  if chapterCfg:GetError() then
    log.error("Form_MainExploreStory:OnActive() GetValue_ByChapterID is error, WRONG ID : " .. chapterID)
    return
  end
  self.m_txt_chaper_num_Text.text = chapterCfg.m_ChapterTitle
  local data = MainExploreManager:GetServerChapterRewardData()
  local is_got = false
  for _, v in ipairs(data or {}) do
    if chapterID == v then
      is_got = true
      break
    end
  end
  local iClueCount, iMaxCount = MainExploreManager:GetCurChapterExploreInfo(chapterID)
  local showRedPoint = 0
  if iClueCount and iMaxCount then
    self.m_txt_progress_num_Text.text = iClueCount .. "/" .. iMaxCount
    showRedPoint = not is_got and iMaxCount <= iClueCount and 1 or 0
    self.m_slider_Image.fillAmount = iClueCount / iMaxCount
    self.m_txt_progress_num_Text.alpha = iClueCount < iMaxCount and 1 or 0.5
  else
    self.m_txt_progress_num_Text.text = ""
    self.m_slider_Image.fillAmount = 0
  end
  local reward = utils.changeCSArrayToLuaTable(config.m_MainChapterReward)
  local common_item = self:createCommonItem(self.m_item)
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = reward[1][1],
    iNum = reward[1][2]
  })
  processItemData.showRedPoint = showRedPoint
  self.m_claimed:SetActive(0 < showRedPoint)
  common_item:SetItemInfo(processItemData)
  common_item:SetItemHaveGetActive(is_got)
  common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    if not is_got and iClueCount >= iMaxCount then
      MainExploreManager:RqsCastleTakeChapterReward(chapterID, function()
        processItemData = ResourceUtil:GetProcessRewardData({
          iID = reward[1][1],
          iNum = reward[1][2]
        })
        common_item:SetItemInfo(processItemData)
        self.m_claimed:SetActive(false)
        is_got = true
        common_item:SetItemHaveGetActive(true)
      end)
      return
    end
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
end

function Form_MainExploreStory:OnBackClk()
  self:CloseForm()
end

function Form_MainExploreStory:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MainExploreStory", Form_MainExploreStory)
return Form_MainExploreStory
