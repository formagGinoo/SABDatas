local UIItemBase = require("UI/Common/UIItemBase")
local MinigameFlipItem = class("MinigameFlipItem", UIItemBase)
local levelTb = ConfigManager:GetConfigInsByName("MiniGameFlopLevelInfo")
local clueInfoTb = ConfigManager:GetConfigInsByName("MiniGameFlopClueInfo")

function MinigameFlipItem:OnInit()
  if self.m_itemInitData then
    self.OnItemClkCallback = self.m_itemInitData.OnItemClk
  end
  self.unlock = false
end

function MinigameFlipItem:OnFreshData()
  local activityId = self.m_itemData.activityId
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  self.levelCfg = levelTb:GetValue_ByLevelID(self.m_itemData.iLevelId)
  self.levelCfgBefore = levelTb:GetValue_ByLevelID(self.levelCfg.m_OrderLevel)
  self.m_txt_title_num_Text.text = self.levelCfg.m_mLevelName
  local clueCfg = clueInfoTb:GetValue_ByClueID(self.levelCfg.m_Clue)
  UILuaHelper.SetAtlasSprite(self.m_card_icon_Image, clueCfg.m_Pic)
  local cur_time = TimeUtil:GetServerTimeS()
  self.unlockc1 = cur_time >= self.m_itemData.iOpenTime and cur_time <= self.m_itemData.iCloseTime
  self.unlockc2 = false
  if self.levelCfg.m_OrderLevel == 0 then
    self.unlockc2 = true
  elseif self.m_stActivity.m_lvStatusData[self.levelCfg.m_OrderLevel] ~= nil then
    self.unlockc2 = true
  end
  self.unlock = self.unlockc1 and self.unlockc2
  UILuaHelper.SetActive(self.m_card_redpoint, false)
  if self.unlock and LocalDataManager:GetIntSimple("Activity_FlopCard_lvRedpoint" .. self.m_itemData.iLevelId, 0) == 0 then
    UILuaHelper.SetActive(self.m_card_redpoint, true)
    GlobalManagerIns:TriggerWwiseBGMState(383)
  end
  UILuaHelper.SetActive(self.m_mask, not self.unlock)
  self.m_step_count_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100904), self.levelCfg.m_Steps)
  local state = self.m_stActivity.m_lvStatusData[self.m_itemData.iLevelId]
  if state and state.iScore ~= 0 then
    self.m_itemData.is_select_vReward = true
  else
    self.m_itemData.is_select_vReward = false
  end
  if state and state.iClueTime ~= 0 then
    self.m_itemData.is_select_iClueTime = true
  else
    self.m_itemData.is_select_iClueTime = false
  end
  UILuaHelper.SetActive(self.m_got_node, self.m_itemData.is_select_iClueTime)
end

function MinigameFlipItem:ShowFinished(isShow)
  self.m_itemData.is_select = isShow
  UILuaHelper.SetActive(self.m_got_node, isShow)
end

function MinigameFlipItem:OnCardiconClicked()
  if self.unlock then
    StackPopup:Push(UIDefines.ID_FORM_ACTIVITY110_ITEMPOP, {
      LevelId = self.m_itemData.iLevelId
    })
  end
end

function MinigameFlipItem:OnMaskClicked()
  if not self.unlock then
    local tstr = TimeUtil:TimerToString3(self.m_itemData.iOpenTime)
    local str = string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(40055), self.levelCfgBefore.m_mLevelName, tstr)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, str)
  end
end

function MinigameFlipItem:OnBtnchallengeClicked()
  if not self.m_stActivity:isInActivityTime() then
    return
  end
  if self.unlock then
    self:broadcastEvent("eGameEvent_Level_MinigameLvIndex", self.m_itemIndex)
    UILuaHelper.SetActive(self.m_card_redpoint, false)
    LocalDataManager:SetIntSimple("Activity_FlopCard_lvRedpoint" .. self.m_itemData.iLevelId, 1)
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110_WARMUP_MAIN, {
      LevelId = self.m_itemData.iLevelId,
      activityId = self.m_itemData.activityId,
      is_select_iClueTime = self.m_itemData.is_select_iClueTime
    })
  end
end

function MinigameFlipItem:OnBtnintroduceClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110_DETAIL, {
    LevelId = self.m_itemData.iLevelId,
    is_select_vReward = self.m_itemData.is_select_vReward,
    is_select_iClueTime = self.m_itemData.is_select_iClueTime
  })
end

function MinigameFlipItem:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

return MinigameFlipItem
