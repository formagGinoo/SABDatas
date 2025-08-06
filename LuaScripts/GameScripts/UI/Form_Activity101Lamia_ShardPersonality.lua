local Form_Activity101Lamia_ShardPersonality = class("Form_Activity101Lamia_ShardPersonality", require("UI/UIFrames/Form_Activity101Lamia_ShardPersonalityUI"))
local reward_length = 575.47
local reward_pos = Vector2.New(0, -70)
local MainCardAtlas = {
  [0] = "Atlas_Activity101Lamia/activity101lamia_xs_zcard1_0",
  "Atlas_Activity101Lamia/activity101lamia_xs_zcard1_1",
  "Atlas_Activity101Lamia/activity101lamia_xs_zcard1_2",
  "Atlas_Activity101Lamia/activity101lamia_xs_zcard1_3",
  "Atlas_Activity101Lamia/activity101lamia_xs_zcard1_4",
  "Atlas_Activity101Lamia/activity101lamia_xs_zcard1_5",
  "Atlas_Activity101Lamia/activity101lamia_xs_zcard1_6",
  "Atlas_Activity101Lamia/activity101lamia_xs_zcard1_7"
}
local Lamia_ShardPersonality_center_out = "Lamia_ShardPersonality_center_out"
local Lamia_ShardPersonality_card_out = "Lamia_card_get"

function Form_Activity101Lamia_ShardPersonality:SetInitParam(param)
end

function Form_Activity101Lamia_ShardPersonality:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1119)
  local m_btn_table_Button = goRoot.transform:Find("content_node/btn_table"):GetComponent("Button")
  m_btn_table_Button.onClick:RemoveAllListeners()
  m_btn_table_Button.onClick:AddListener(function()
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDTABLE, self.format_configs)
  end)
  self.m_redpoint_item:SetActive(false)
  self.m_grayImgMaterial = self.m_icon1_Image.material
  self.m_img_card72:SetActive(false)
  self.m_block:SetActive(false)
end

function Form_Activity101Lamia_ShardPersonality:OnActive()
  self.super.OnActive(self)
  self.act_id = self.m_csui.m_param.main_id
  self.sub_id = self.m_csui.m_param.sub_id
  self:addEventListener("eGameEvent_ActMemory_GetAllReward", handler(self, self.FreshUI))
  self:addEventListener("eGameEvent_ActMinigame_Finish", handler(self, self.FreshUI))
  self:InitUI()
  self:RegisterRedDot()
  self:FreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(99)
  self.openTime = TimeUtil:GetServerTimeS()
  self.report_name = self.act_id .. "/Form_Activity101Lamia_ShardPersonality"
  HeroActivityManager:ReportActOpen(self.report_name, {
    openTime = self.openTime
  })
end

function Form_Activity101Lamia_ShardPersonality:OnInactive()
  self.super.OnInactive(self)
  if self.reward_item_cache then
    for index, v in pairs(self.reward_item_cache) do
      v.obj:SetActive(false)
    end
  end
  self:ResetCommonItem()
  self:clearEventListener()
  self.m_reward_pop_node:SetActive(false)
  HeroActivityManager:ReportActClose(self.report_name, {
    openTime = self.openTime
  })
end

function Form_Activity101Lamia_ShardPersonality:GetRewardItemCom(item_trans)
  if not item_trans then
    return
  end
  return {
    obj = item_trans.gameObject,
    node_got = item_trans:Find("m_chapter_task_have_receive").gameObject,
    node_can_rec = item_trans:Find("m_chapter_task_can_receive").gameObject,
    node_cannot_rec = item_trans:Find("m_chapter_task_cannot_receive").gameObject,
    txt_num = item_trans:Find("m_txt_chapter_task_num"):GetComponent(T_TextMeshProUGUI),
    node_reward_pop_root = item_trans:Find("m_reward_pop_root"),
    btn = item_trans:GetComponent(T_Button)
  }
end

function Form_Activity101Lamia_ShardPersonality:InitUI()
  local format_configs = {}
  local configs = HeroActivityManager:GetActMemoryInfoCfgByID(self.sub_id)
  for _, config in pairs(configs) do
    local m_MemoryID = config.m_MemoryID
    if m_MemoryID and 0 < m_MemoryID then
      format_configs[m_MemoryID] = config
    end
  end
  self.format_configs = format_configs
  local rewards_data = {}
  for _, config in ipairs(format_configs) do
    local rewards = utils.changeCSArrayToLuaTable(config.m_Rewards)
    if rewards and 0 < #rewards then
      table.insert(rewards_data, config)
    end
  end
  self.rewards_data = rewards_data
  for i, v in ipairs(self.format_configs) do
    if i < 7 then
      UILuaHelper.SetAtlasSprite(self["m_img_card" .. i .. "_Image"], v.m_Pic)
    end
    self["m_txt_limit_time" .. i .. "_Text"].text = v.m_OpenTime
    local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = self.act_id,
      m_MemoryID = v.m_MemoryID
    })
    if is_corved then
      self["m_txt_limit_time" .. i .. "_Text"].text = TimeUtil:TimerToString3(t1)
    end
    UILuaHelper.SetAtlasSprite(self["m_icon" .. i .. "_Image"], ItemManager:GetItemIconPathByID(v.m_Item))
    local count = ItemManager:GetItemNum(v.m_Item, true) or 0
    count = 0 < count and 1 or 0
    self["m_txt_icon" .. i .. "_Text"].text = count .. "/" .. 1
    if count == 0 then
      self["m_icon" .. i .. "_Image"].material = self.m_grayImgMaterial
    else
      self["m_icon" .. i .. "_Image"].material = nil
    end
  end
  UILuaHelper.SetActive(self.m_btn_Chapter_Task_Close, false)
  UILuaHelper.SetActive(self.m_chapter_task_base_item, false)
  self.m_baseRewardItem = self.m_reward_pop_node.transform:Find("c_common_item").gameObject
  UILuaHelper.SetActive(self.m_baseRewardItem, false)
  self.reward_item_cache = self.reward_item_cache or {}
  local parentTrans = self.m_chapter_reward_list
  for i, config in ipairs(self.rewards_data) do
    local item = self.reward_item_cache[i]
    if not item then
      local item_trans = GameObject.Instantiate(self.m_chapter_task_base_item, parentTrans.transform).transform
      item = self:GetRewardItemCom(item_trans)
      self.reward_item_cache[i] = item
      UILuaHelper.BindButtonClickManual(self, item.btn, function()
        self:OnRewardItemClicked(i)
      end)
    end
    reward_pos.x = reward_length * (config.m_MemoryID / #self.format_configs)
    item.obj.transform.anchoredPosition = reward_pos
    item.obj:SetActive(true)
    item.txt_num.text = config.m_MemoryID
  end
end

function Form_Activity101Lamia_ShardPersonality:CheckAndPlayAni()
  GlobalManagerIns:TriggerWwiseBGMState(101)
  UILuaHelper.PlayAnimationByName(self.m_img_card72, Lamia_ShardPersonality_center_out)
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_img_card72, Lamia_ShardPersonality_center_out)
  TimeService:SetTimer(aniLen + 0.1, 1, function()
    self.m_img_card72:SetActive(false)
    self.m_block:SetActive(false)
  end)
end

function Form_Activity101Lamia_ShardPersonality:FreshUI()
  self.server_data = HeroActivityManager:GetHeroActData(self.act_id).server_data.stMiniGame
  self:FreshCards()
  self:FreshReward()
end

function Form_Activity101Lamia_ShardPersonality:FreshCards()
  local server_data = self.server_data
  local card_idx = 0
  for i, v in ipairs(self.format_configs) do
    local is_done = server_data.mGameStat[i] == 1
    if is_done then
      card_idx = card_idx + 1
    end
    local num = ItemManager:GetItemNum(v.m_Item, true)
    local is_got = num and 0 < num
    local open_time = TimeUtil:TimeStringToTimeSec2(v.m_OpenTime) or 0
    local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = self.act_id,
      m_MemoryID = v.m_MemoryID
    })
    if is_corved then
      open_time = t1
    end
    local cur_time = TimeUtil:GetServerTimeS()
    local is_in_time = open_time <= cur_time
    local is_pre_done = false
    local pre_config = HeroActivityManager:GetCurMemorysPre(self.sub_id, i)
    if not pre_config then
      is_pre_done = true
    else
      is_pre_done = server_data.mGameStat[pre_config.m_MemoryID] == 1
    end
    if v.m_UIType == 1 then
      self.m_img_card7:SetActive(true)
      if is_done then
        self.m_img_limit7:SetActive(false)
        self.m_img_get7:SetActive(false)
        self.m_img_get_none7:SetActive(false)
        self.m_pnl_icon7:SetActive(false)
      else
        self.m_img_limit7:SetActive(false)
        self.m_img_get7:SetActive(false)
        self.m_img_get_none7:SetActive(false)
        if not is_in_time then
          self.m_img_limit7:SetActive(true)
        elseif not is_got then
        elseif not is_pre_done then
        else
          self.m_img_get7:SetActive(true)
        end
        self.m_pnl_icon7:SetActive(true)
      end
    elseif is_done then
      self["m_img_card" .. i]:SetActive(true)
      self["m_img_limit" .. i]:SetActive(false)
      self["m_img_lock" .. i]:SetActive(false)
      self["m_img_get" .. i]:SetActive(false)
      self["m_img_get_none" .. i]:SetActive(false)
      self["m_pnl_icon" .. i]:SetActive(false)
    else
      self["m_img_card" .. i]:SetActive(false)
      self["m_img_limit" .. i]:SetActive(false)
      self["m_img_lock" .. i]:SetActive(false)
      self["m_img_get" .. i]:SetActive(false)
      self["m_img_get_none" .. i]:SetActive(false)
      if not is_in_time then
        self["m_img_limit" .. i]:SetActive(true)
      elseif not is_got then
        self["m_img_get_none" .. i]:SetActive(true)
      elseif not is_pre_done then
        self["m_img_lock" .. i]:SetActive(true)
      else
        self["m_img_get" .. i]:SetActive(true)
      end
      self["m_pnl_icon" .. i]:SetActive(true)
    end
    self:RegisterOrUpdateRedDotItem(self["m_redpoint" .. i], RedDotDefine.ModuleType.HeroActMemoryCardCanRead, {
      v,
      server_data,
      self.act_id
    })
  end
  self.m_txt_memorynum_Text.text = card_idx .. "/" .. #self.format_configs - 1
  if 6 < card_idx then
    self.m_pnl_memory:SetActive(false)
    self.m_txt_finish:SetActive(true)
    self.m_txt_finish_Text.text = ConfigManager:GetCommonTextById(100209)
  else
    self.m_pnl_memory:SetActive(true)
    self.m_txt_finish:SetActive(false)
  end
  if self.preUnlockMemoryID then
    UILuaHelper.SetAtlasSprite(self.m_img_card7_Image, MainCardAtlas[card_idx] or MainCardAtlas[0])
    UILuaHelper.SetAtlasSprite(self.m_img_card72_Image, MainCardAtlas[card_idx - 1] or MainCardAtlas[0])
  else
    UILuaHelper.SetAtlasSprite(self.m_img_card7_Image, MainCardAtlas[card_idx])
  end
  if self.preUnlockMemoryID == 7 then
    self:CheckAndPlayAni()
    self.preUnlockMemoryID = nil
    return
  end
  if self.preUnlockMemoryID and card_idx and card_idx == self.preUnlockMemoryID then
    self.m_block:SetActive(true)
    self["m_img_get" .. card_idx]:SetActive(true)
    self.m_img_card72:SetActive(true)
    UILuaHelper.PlayAnimationByName(self["m_img_get" .. card_idx], Lamia_ShardPersonality_card_out)
    GlobalManagerIns:TriggerWwiseBGMState(100)
    local aniLen = UILuaHelper.GetAnimationLengthByName(self["m_img_get" .. card_idx], Lamia_ShardPersonality_card_out)
    TimeService:SetTimer(aniLen - 1, 1, function()
      self["m_img_card" .. card_idx]:SetActive(true)
      TimeService:SetTimer(1, 1, function()
        self["m_img_get" .. card_idx]:SetActive(false)
      end)
      self:CheckAndPlayAni()
    end)
  end
  self.preUnlockMemoryID = nil
end

function Form_Activity101Lamia_ShardPersonality:FreshReward()
  local max_index = #self.format_configs
  local server_data = self.server_data
  local cur_readcard_num = 0
  for _, v in pairs(server_data.mGameStat) do
    if v == 1 then
      cur_readcard_num = cur_readcard_num + 1
    end
  end
  for i, config in ipairs(self.rewards_data) do
    local item = self.reward_item_cache[i]
    item.obj:SetActive(true)
    item.node_got:SetActive(false)
    item.node_can_rec:SetActive(false)
    item.node_cannot_rec:SetActive(false)
    if cur_readcard_num < config.m_MemoryID then
      item.node_cannot_rec:SetActive(true)
    elseif server_data.iMaxAwardedGame >= config.m_MemoryID then
      item.node_got:SetActive(true)
    else
      item.node_can_rec:SetActive(true)
    end
  end
  self.m_txt_reward_progress_num_Text.text = cur_readcard_num .. "/" .. max_index
  self.m_reward_bar_Slider.value = cur_readcard_num / max_index
end

function Form_Activity101Lamia_ShardPersonality:ResetCommonItem()
  if self.common_item_cache then
    for _, v in pairs(self.common_item_cache) do
      v:SetActive(false)
    end
  end
end

function Form_Activity101Lamia_ShardPersonality:RegisterRedDot()
end

function Form_Activity101Lamia_ShardPersonality:OnIconClicked(m_MemoryID)
  local config = self.format_configs[m_MemoryID]
  local num = ItemManager:GetItemNum(config.m_Item, true)
  local is_got = num and 0 < num
  if is_got then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITEM, {
      item_id = config.m_Item
    })
  else
    local str = ConfigManager:GetClientMessageTextById(40035)
    str = string.gsubNumberReplace(str, config.m_mLevelRef)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, str)
  end
end

function Form_Activity101Lamia_ShardPersonality:OnCardClicked(m_MemoryID)
  local config = self.format_configs[m_MemoryID]
  local server_data = self.server_data
  local is_done = server_data.mGameStat[m_MemoryID] == 1
  local num = ItemManager:GetItemNum(config.m_Item, true)
  local is_got = num and 0 < num
  local open_time = TimeUtil:TimeStringToTimeSec2(config.m_OpenTime) or 0
  local cur_time = TimeUtil:GetServerTimeS()
  local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
    id = self.act_id,
    m_MemoryID = m_MemoryID
  })
  if is_corved then
    open_time = t1
  end
  local is_in_time = cur_time >= open_time
  local is_pre_done = false
  local pre_config = HeroActivityManager:GetCurMemorysPre(self.sub_id, m_MemoryID)
  if not pre_config then
    is_pre_done = true
  else
    is_pre_done = server_data.mGameStat[pre_config.m_MemoryID] == 1
  end
  if is_done then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDMEMORY, {config = config, is_done = true})
    return
  elseif is_got and is_in_time and is_pre_done then
    self.preUnlockMemoryID = m_MemoryID
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDSELECT, {
      act_id = self.act_id,
      config = config
    })
    return
  end
  if m_MemoryID < 7 then
    local str = ConfigManager:GetClientMessageTextById(40045)
    local timeStr = is_corved and TimeUtil:TimerToString3(t1) or config.m_OpenTime
    str = string.gsubNumberReplace(str, timeStr, ItemManager:GetItemName(config.m_Item))
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, str)
  else
    local str = ConfigManager:GetClientMessageTextById(40046)
    local timeStr = is_corved and TimeUtil:TimerToString3(t1) or config.m_OpenTime
    str = string.gsubNumberReplace(str, timeStr)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, str)
  end
end

function Form_Activity101Lamia_ShardPersonality:OnRewardItemClicked(rewards_data_idx)
  local server_data = self.server_data
  local config = self.rewards_data[rewards_data_idx]
  local cur_readcard_num = 0
  for _, v in pairs(server_data.mGameStat) do
    if v == 1 then
      cur_readcard_num = cur_readcard_num + 1
    end
  end
  self.m_reward_pop_node:SetActive(false)
  if server_data.iMaxAwardedGame < config.m_MemoryID and cur_readcard_num >= config.m_MemoryID then
    HeroActivityManager:ReqLamiaGameGetAllAwardCS(self.act_id, self.sub_id)
  else
    local item = self.reward_item_cache[rewards_data_idx]
    local parentTrans = self.m_reward_pop_node
    self.common_item_cache = self.common_item_cache or {}
    self:ResetCommonItem()
    local rewards = utils.changeCSArrayToLuaTable(config.m_Rewards)
    for i, v in ipairs(rewards) do
      local common_item = self.common_item_cache[i]
      if not common_item then
        local item_obj = GameObject.Instantiate(self.m_baseRewardItem, parentTrans.transform).gameObject
        common_item = self:createCommonItem(item_obj)
        common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
          self:OnRewardCommonItemClk(itemID, itemNum, itemCom)
        end)
        self.common_item_cache[i] = common_item
      end
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(v[1]),
        iNum = tonumber(v[2])
      })
      common_item:SetItemInfo(processItemData)
      common_item:SetActive(true)
    end
    self.m_reward_pop_node:SetActive(false)
    TimeService:SetTimer(0.1, 1, function()
      UILuaHelper.SetParent(self.m_reward_pop_node, item.node_reward_pop_root, true)
      self.m_reward_pop_node:SetActive(true)
    end)
    UILuaHelper.SetActive(self.m_btn_Chapter_Task_Close, true)
  end
end

function Form_Activity101Lamia_ShardPersonality:OnBtnChapterTaskCloseClicked()
  self.m_reward_pop_node:SetActive(false)
  self.m_btn_Chapter_Task_Close:SetActive(false)
end

function Form_Activity101Lamia_ShardPersonality:OnRewardCommonItemClk(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_Activity101Lamia_ShardPersonality:OnIcon1Clicked()
  self:OnIconClicked(1)
end

function Form_Activity101Lamia_ShardPersonality:OnIcon2Clicked()
  self:OnIconClicked(2)
end

function Form_Activity101Lamia_ShardPersonality:OnIcon3Clicked()
  self:OnIconClicked(3)
end

function Form_Activity101Lamia_ShardPersonality:OnIcon4Clicked()
  self:OnIconClicked(4)
end

function Form_Activity101Lamia_ShardPersonality:OnIcon5Clicked()
  self:OnIconClicked(5)
end

function Form_Activity101Lamia_ShardPersonality:OnIcon6Clicked()
  self:OnIconClicked(6)
end

function Form_Activity101Lamia_ShardPersonality:OnIcon7Clicked()
  self:OnIconClicked(7)
end

function Form_Activity101Lamia_ShardPersonality:OnPnlcardcenterClicked()
  self:OnCardClicked(7)
end

function Form_Activity101Lamia_ShardPersonality:OnPnlcard1Clicked()
  self:OnCardClicked(1)
end

function Form_Activity101Lamia_ShardPersonality:OnPnlcard2Clicked()
  self:OnCardClicked(2)
end

function Form_Activity101Lamia_ShardPersonality:OnPnlcard3Clicked()
  self:OnCardClicked(3)
end

function Form_Activity101Lamia_ShardPersonality:OnPnlcard4Clicked()
  self:OnCardClicked(4)
end

function Form_Activity101Lamia_ShardPersonality:OnPnlcard5Clicked()
  self:OnCardClicked(5)
end

function Form_Activity101Lamia_ShardPersonality:OnPnlcard6Clicked()
  self:OnCardClicked(6)
end

function Form_Activity101Lamia_ShardPersonality:OnBackClk()
  self:CloseForm()
end

function Form_Activity101Lamia_ShardPersonality:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_Activity101Lamia_ShardPersonality:OnDestroy()
  self.super.OnDestroy(self)
  self.reward_item_cache = nil
  self.common_item_cache = nil
end

function Form_Activity101Lamia_ShardPersonality:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_ShardPersonality", Form_Activity101Lamia_ShardPersonality)
return Form_Activity101Lamia_ShardPersonality
