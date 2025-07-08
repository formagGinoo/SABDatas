local Form_MainExploreRemenber = class("Form_MainExploreRemenber", require("UI/UIFrames/Form_MainExploreRemenberUI"))
local RotationEnum = {
  [0] = Vector3.zero,
  [1] = Vector3(0, 0, -20),
  [2] = Vector3(0, 0, -37),
  [3] = Vector3(0, 0, -54),
  [4] = Vector3(0, 0, -74),
  [5] = Vector3(0, 0, -98)
}
local SpineAniEnum = {
  Idle1 = "idle1",
  Idle2 = "idle2",
  Open1 = "open1",
  Open2 = "open2"
}
local ColorEnum = {
  yellow = Color(0.47843137254901963, 0.43529411764705883, 0.34901960784313724),
  gray = Color(0.3411764705882353, 0.3411764705882353, 0.33725490196078434)
}

function Form_MainExploreRemenber:SetInitParam(param)
end

function Form_MainExploreRemenber:AfterInit()
  self.super.AfterInit(self)
  self.m_TabItemCache = {}
  self.m_tap_check_PrefabHelper = self.m_tap_check:GetComponent("PrefabHelper")
  self.m_tap_check_PrefabHelper:RegisterCallback(handler(self, self.OnInitTabItem))
  self.m_scrollRect = self.m_scrollView:GetComponent("ScrollRect")
end

function Form_MainExploreRemenber:OnActive()
  self.super.OnActive(self)
  self:addEventListener("eGameEvent_LostStory_GetReward", handler(self, self.FreshUI))
  self.configs = self.m_csui.m_param.configs
  self.allMainConfigs = MainExploreManager:GetMainExploreConfig()
  self.cur_idx = 0
  GlobalManagerIns:TriggerWwiseBGMState(78)
  self:FreshUI()
  self.m_tap_check_PrefabHelper:CheckAndCreateObjs(#self.configs + 1)
  self.m_title_pageone_Text.text = self.configs[1].m_mStoryTitle
  self.m_img_arrow.transform.localRotation = RotationEnum[0]
  CS.GlobalManager.Instance:TriggerWwiseBGMState(211)
end

function Form_MainExploreRemenber:FreshUI()
  local config = self.configs[self.cur_idx]
  local m_StoryID = self.configs[1].m_StoryID
  self.got_count = MainExploreManager:GetUnlockStorySubCount(m_StoryID)
  local data = MainExploreManager:GetServerStoryData()
  self.is_got = false
  if data and data[m_StoryID] then
    self.is_got = data[m_StoryID].iRewardTime > 0
  end
  if config then
    self.m_pnl_page:SetActive(false)
    self:FreshTextInfo(config)
    self.m_scrollRect.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
    UILuaHelper.SpinePlayAnim(self.m_mainexplore_book, 0, SpineAniEnum.Idle2, true)
    UILuaHelper.PlayAnimationByName(self.m_pnl_detials, "MainExploreRemenber_page_in")
    UILuaHelper.PlayAnimationByName(self.m_pnl_none, "MainExploreRemenber_page_in")
  else
    local reward = utils.changeCSArrayToLuaTable(self.configs[1].m_Reward)[1]
    UILuaHelper.SetAtlasSprite(self.m_icon_ld_Image, ItemManager:GetItemIconPathByID(reward[1]))
    self.m_txt_rewardnum_Text.text = reward[2]
    self.m_pnl_page:SetActive(true)
    self.m_pnl_detials:SetActive(false)
    self.m_pnl_none:SetActive(false)
    self.m_pnl_received:SetActive(self.is_got)
    UILuaHelper.SpinePlayAnim(self.m_mainexplore_book, 0, SpineAniEnum.Idle1, true)
    UILuaHelper.PlayAnimationByName(self.m_pnl_page, "MainExploreRemenber_page_in")
    self.m_claimed:SetActive(not self.is_got and self.got_count >= #self.configs)
  end
  self.m_txt_tips_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100087), self.got_count, #self.configs)
end

function Form_MainExploreRemenber:FreshTextInfo(config)
  self.m_txt_subtitle_Text.text = config.m_mSubsectionTitle
  self.m_txt_words_Text.text = config.m_mText
  local unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, tonumber(self.allMainConfigs[config.m_MainChapterClue[0]][config.m_MainChapterClue[1]].m_UnlockLevel))
  if unlock then
    local server_data = MainExploreManager:GetServerStoryData()
    local data = server_data[config.m_StoryID]
    local is_got = false
    if data then
      for i, v in pairs(data.vSectionId) do
        if v == config.m_SubsectionID then
          is_got = true
        end
      end
    end
    if is_got then
      self.m_pnl_detials:SetActive(true)
      self.m_pnl_none:SetActive(false)
      local story_config = MainExploreManager:GetMainLostStoryByStoryID(config.m_StoryID)[1]
      local icon = utils.changeCSArrayToLuaTable(story_config.m_icon)
      UILuaHelper.SetAtlasSprite(self.m_icon_ld_Image, ItemManager:GetItemIconPathByID(icon[1]))
      self.m_txt_subtitle:SetActive(true)
      self.m_txt_words:SetActive(true)
    else
      self.m_pnl_detials:SetActive(false)
      self.m_pnl_none:SetActive(true)
      local tip = ConfigManager:GetCommonTextById(100213)
      self.m_txt_words_none_Text.text = string.gsubNumberReplace(tip, tonumber(config.m_MainChapterClue[0]) - 1)
    end
  else
    self.m_pnl_detials:SetActive(false)
    self.m_pnl_none:SetActive(true)
    local story2level = MainExploreManager:GetStoryToLevelList()
    local levelid = story2level[config.m_StoryID][config.m_SubsectionID]
    local cfgIns = ConfigManager:GetConfigInsByName("MainLevel")
    local cfg = cfgIns:GetValue_ByLevelID(levelid)
    local tip = ConfigManager:GetCommonTextById(100206)
    self.m_txt_words_none_Text.text = string.gsubNumberReplace(tip, cfg.m_LevelName)
  end
end

function Form_MainExploreRemenber:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_MainExploreRemenber:OnInitTabItem(go, index)
  local item = self.m_TabItemCache[index]
  if not item then
    local transform = go.transform
    item = {
      button = transform:Find("c_item_tab"):GetComponent("Button"),
      m_img_num = transform:Find("c_item_tab/m_img_num"):GetComponent("Image"),
      m_img_tab_select = transform:Find("c_item_tab/m_img_tab_sel").gameObject
    }
    self.m_TabItemCache[index] = item
  end
  item.m_img_num.color = ColorEnum.yellow
  item.button.onClick:RemoveAllListeners()
  item.button.onClick:AddListener(function()
    if index == self.cur_idx then
      return
    end
    CS.GlobalManager.Instance:TriggerWwiseBGMState(212)
    self:PlayAniAndFeshUI(self.cur_idx, index)
    self.cur_idx = index
    self.m_img_arrow.transform:DORotate(RotationEnum[self.cur_idx], 0.5)
    self.m_tap_check_PrefabHelper:Refresh()
  end)
  item.m_img_tab_select:SetActive(index == self.cur_idx)
end

function Form_MainExploreRemenber:PlayAniAndFeshUI(cur_idx, target_idx)
  local aniStr, is_reverse
  if cur_idx == 0 then
    aniStr = SpineAniEnum.Open1
    is_reverse = false
    UILuaHelper.PlayAnimationByName(self.m_pnl_page, "MainExploreRemenber_page_out")
  elseif target_idx == 0 then
    aniStr = SpineAniEnum.Open1
    is_reverse = true
    UILuaHelper.PlayAnimationByName(self.m_pnl_detials, "MainExploreRemenber_page_out")
    UILuaHelper.PlayAnimationByName(self.m_pnl_none, "MainExploreRemenber_page_out")
  elseif cur_idx < target_idx then
    aniStr = SpineAniEnum.Open2
    is_reverse = false
    UILuaHelper.PlayAnimationByName(self.m_pnl_detials, "MainExploreRemenber_page_out")
    UILuaHelper.PlayAnimationByName(self.m_pnl_none, "MainExploreRemenber_page_out")
  else
    aniStr = SpineAniEnum.Open2
    is_reverse = true
    UILuaHelper.PlayAnimationByName(self.m_pnl_detials, "MainExploreRemenber_page_out")
    UILuaHelper.PlayAnimationByName(self.m_pnl_none, "MainExploreRemenber_page_out")
  end
  UILuaHelper.SpinePlayAnimWithBack(self.m_mainexplore_book, 0, aniStr, false, is_reverse, function()
    self:FreshUI()
  end)
end

function Form_MainExploreRemenber:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MainExploreRemenber:OnBtnclickClicked()
  self:CloseForm()
end

function Form_MainExploreRemenber:OnBtnleftdownClicked()
  if self.is_got or not self.is_got and self.got_count < #self.configs then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    local reward = utils.changeCSArrayToLuaTable(self.configs[1].m_Reward)[1]
    utils.openItemDetailPop({
      iID = reward[1],
      iNum = reward[2]
    })
  else
    MainExploreManager:RqsGetStoryReawrd(self.configs[1].m_StoryID)
  end
end

function Form_MainExploreRemenber:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MainExploreRemenber", Form_MainExploreRemenber)
return Form_MainExploreRemenber
