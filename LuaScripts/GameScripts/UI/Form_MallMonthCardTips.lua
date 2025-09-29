local Form_MallMonthCardTips = class("Form_MallMonthCardTips", require("UI/UIFrames/Form_MallMonthCardTipsUI"))
local MonthlyCardIns = ConfigManager:GetConfigInsByName("StoreBaseGoodsMonthly")
local priavteTips = ConfigManager:GetCommonTextById(220027)
local cardEndTips = ConfigManager:GetCommonTextById(220028)

function Form_MallMonthCardTips:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local clickNode = self.m_rootTrans:Find("content_node/m_pnl_reward/ui_common_click")
  self.m_btn_Close.transform:SetParent(clickNode)
  self.m_itemPanel = {
    [GlobalConfig.MonthlyType.Small] = {
      item = self.m_reward_three1,
      commonItem = self.m_common_item_three1,
      timeObj = self.m_pnl_time_three1,
      timeText = self.m_txt_time_three1_Text
    },
    [GlobalConfig.MonthlyType.Middle] = {
      item = self.m_reward_three2,
      commonItem = self.m_common_item_three2,
      timeObj = self.m_pnl_time_three2,
      timeText = self.m_txt_time_three2_Text
    },
    [GlobalConfig.MonthlyType.Big] = {
      item = self.m_reward_three3,
      commonItem = self.m_common_item_three3,
      timeObj = self.m_pnl_time_three3,
      timeText = self.m_txt_time_three3_Text
    }
  }
  self.m_privilegePanel = {
    [GlobalConfig.MonthlyType.Small] = {
      item = self.m_pnl_bp1,
      timeTxt = self.m_txt_bpend1_Text
    },
    [GlobalConfig.MonthlyType.Middle] = {
      item = self.m_pnl_bp2,
      timeTxt = self.m_txt_bpend2_Text
    },
    [GlobalConfig.MonthlyType.Big] = {
      item = self.m_pnl_bp3,
      timeTxt = self.m_txt_bpend3_Text
    }
  }
end

function Form_MallMonthCardTips:OnActive()
  if self.m_csui.m_param then
    self.m_isPushUnlock = self.m_csui.m_param.isPrivilege
    self.m_fc = self.m_csui.m_param.fc
  end
  self.super.OnActive(self)
  self.m_lastTipTime = 0
  self.m_tipsCardType = nil
  self.m_lastTipsTime = 0
  self:RefreshStage()
  GlobalManagerIns:TriggerWwiseBGMState(71)
end

function Form_MallMonthCardTips:OnInactive()
  self.super.OnInactive(self)
  if self.m_isPushUnlock then
    self.m_isPushUnlock = false
    local param = {}
    StackPopup:Push(UIDefines.ID_FORM_MALLMONTHCARDUNLOCKTIPS, param)
  else
    self:broadcastEvent("eGameEvent_MonthlyCardRefresh")
    MonthlyCardManager:GetAddCardId()
  end
  PushFaceManager:CheckShowNextPopPanel()
  if self.m_tipsCardType then
    local isOn = self.m_btn_tips_Toggle.isOn and 1 or 0
    LocalDataManager:SetIntSimple("MonthlyCardTips" .. self.m_tipsCardType, isOn)
  end
  self.m_tipsCardType = nil
end

function Form_MallMonthCardTips:RefreshStage()
  self.m_pnl_reward:SetActive(true)
  self.m_pnl_endtime:SetActive(false)
  for key, value in pairs(self.m_itemPanel) do
    local isShow = MonthlyCardManager:DailyRewardExhibition(key)
    value.item:SetActive(isShow)
    if isShow then
      value.timeText.text = MonthlyCardManager:GetCardRemainingDayTextByType(key) or ""
      local cfgReward = MonthlyCardManager:GetRewardCfg(key, true)
      local itemObj = value.commonItem
      local common_item = self:createCommonItem(itemObj)
      common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        utils.openItemDetailPop({iID = itemID, iNum = itemNum})
      end)
      local id = cfgReward[1]
      local num = cfgReward[2]
      local processItemData = ResourceUtil:GetProcessRewardData({iID = id, iNum = num})
      common_item:SetItemInfo(processItemData)
      local cfg = MonthlyCardManager:GetMonthlyCardByType(key)
      local endTime = MonthlyCardManager:GetCardEndTime(key)
      local serverTime = TimeUtil:GetServerTimeS()
      local tipBuyTime = endTime - cfg.m_RemindTime
      local isOpenNoTips = LocalDataManager:GetIntSimple("MonthlyCardTips" .. key, 0) == 1
      local shouldRemind = serverTime > tipBuyTime and not isOpenNoTips
      if shouldRemind and (self.m_lastTipsTime == 0 or tipBuyTime < self.m_lastTipsTime) then
        self.m_lastTipsTime = tipBuyTime
        self.m_tipsCardType = key
      end
    end
  end
end

function Form_MallMonthCardTips:RefreshPrivilegePanel()
  self.m_pnl_endtime:SetActive(true)
  self.m_btn_tips_Toggle.isOn = false
  local curCardInfo = MonthlyCardManager:GetHaveMonthlyCardInfo()
  for key, value in pairs(self.m_privilegePanel) do
    value.item:SetActive(false)
  end
  local serverTime = TimeUtil:GetServerTimeS()
  local showItemNum = 0
  for key, value in pairs(curCardInfo) do
    local monthlyCardCfg = MonthlyCardIns:GetValue_ByGoodsID(value.iCardId)
    if serverTime > value.iExpireTime - monthlyCardCfg.m_RemindTime then
      showItemNum = showItemNum + 1
      local monthlyCardType = monthlyCardCfg.m_type
      self.m_privilegePanel[monthlyCardType].item:SetActive(true)
      self.m_privilegePanel[monthlyCardType].timeTxt.text = MonthlyCardManager:GetCardRemainingDayTextByType(monthlyCardType) or ""
    end
  end
  local tipsTxt = table.getn(curCardInfo) >= GlobalConfig.MonthlyCardPrivilege and priavteTips or cardEndTips
  self.m_txt_endtime_Text.text = tipsTxt
  UILuaHelper.SetActive(self.m_lineGroup1, showItemNum == 2)
  UILuaHelper.SetActive(self.m_lineGroup2, showItemNum == 3)
end

function Form_MallMonthCardTips:OnBtnCloseClicked()
  if self.m_tipsCardType then
    self.m_pnl_reward:SetActive(false)
    self.m_pnl_endtime:SetActive(true)
    self:RefreshPrivilegePanel()
  else
    self:CloseForm()
  end
end

function Form_MallMonthCardTips:OnBtnCloseTipsClicked()
end

function Form_MallMonthCardTips:OnBtncancelClicked()
  self:CloseForm()
end

function Form_MallMonthCardTips:OnBtnconfirmClicked()
  QuickOpenFuncUtil:OpenFunc(40004)
  self:CloseForm()
end

function Form_MallMonthCardTips:IsFullScreen()
  return true
end

function Form_MallMonthCardTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MallMonthCardTips", Form_MallMonthCardTips)
return Form_MallMonthCardTips
