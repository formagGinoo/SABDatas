local Form_MallMonthCardTips = class("Form_MallMonthCardTips", require("UI/UIFrames/Form_MallMonthCardTipsUI"))

function Form_MallMonthCardTips:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local clickNode = self.m_rootTrans:Find("content_node/ui_common_click")
  self.m_btn_Close.transform:SetParent(clickNode)
  self.disableContinueTime = 0
end

function Form_MallMonthCardTips:OnActive()
  self.fromHallPop = self.m_csui.m_param
  self.super.OnActive(self)
  self.stage = 0
  self:RefreshStage()
  GlobalManagerIns:TriggerWwiseBGMState(71)
end

function Form_MallMonthCardTips:OnInactive()
  self.super.OnInactive(self)
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_MallMonthCardTips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_MallMonthCardTips:RefreshStage()
  if MonthlyCardManager:DailyRewardExhibition(true) then
    self.m_small = true
  end
  if MonthlyCardManager:DailyRewardExhibition(false) then
    self.m_Big = true
  end
  self.m_bg_item:SetActive(false)
  self.m_bg_item_double:SetActive(false)
  self.m_bg_shadow_small:SetActive(false)
  self.m_bg_shadow_big:SetActive(false)
  if self.m_small and self.m_Big then
    self.m_bg_shadow_big:SetActive(true)
    self.m_bg_item_double:SetActive(true)
    self.m_bg_item:SetActive(false)
    self.m_txt_time_double01_Text.text = MonthlyCardManager:GetSmallCardRemainingDayText() or ""
    self.m_txt_time_double02_Text.text = MonthlyCardManager:GetBigCardRemainingDayText() or ""
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, "")
    self:RefreshReward()
  elseif self.m_small or self.m_Big then
    self.m_bg_shadow_big:SetActive(self.m_Big)
    self.m_bg_shadow_small:SetActive(self.m_small)
    self.m_bg_item_double:SetActive(false)
    self.m_bg_item:SetActive(true)
    if self.m_small then
      self.m_txt_time_Text.text = MonthlyCardManager:GetSmallCardRemainingDayText() or ""
    else
      self.m_txt_time_Text.text = MonthlyCardManager:GetBigCardRemainingDayText() or ""
    end
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, "")
    self:RefreshReward()
  else
    StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_MALLMONTHCARDTIPS)
    MonthlyCardManager:EnableExhibitionRewardInHall(true)
    PushFaceManager:CheckShowNextPopPanel()
  end
end

function Form_MallMonthCardTips:RefreshReward(isSmallReward)
  if self.m_small and self.m_Big then
    self.m_bg_item:SetActive(false)
    self.m_bg_item_double:SetActive(true)
    self.m_reward_small:SetActive(true)
    local cfg = MonthlyCardManager:GetRewardCfg(true, true)
    local itemObj = self.m_reward_small.transform:Find("c_common_item_double01").gameObject
    local common_item = self:createCommonItem(itemObj)
    common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    local id = cfg[1]
    local num = cfg[2]
    local processItemData = ResourceUtil:GetProcessRewardData({iID = id, iNum = num})
    common_item:SetItemInfo(processItemData)
    self.m_reward_big:SetActive(true)
    local cfgBig = MonthlyCardManager:GetRewardCfg(false, true)
    local itemObjBig = self.m_reward_big.transform:Find("c_common_item_double02").gameObject
    local common_itemBig = self:createCommonItem(itemObjBig)
    common_itemBig:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    local idBig = cfgBig[1]
    local numBig = cfgBig[2]
    local processItemDataBig = ResourceUtil:GetProcessRewardData({iID = idBig, iNum = numBig})
    common_itemBig:SetItemInfo(processItemDataBig)
    self.m_small = false
    self.m_Big = false
  end
  if self.m_small then
    self.m_bg_item:SetActive(true)
    self.m_bg_item_double:SetActive(false)
    local cfg = MonthlyCardManager:GetRewardCfg(true, true)
    local itemObj = self.m_bg_item.transform:Find("c_common_item").gameObject
    local common_item = self:createCommonItem(itemObj)
    common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    local id = cfg[1]
    local num = cfg[2]
    local processItemData = ResourceUtil:GetProcessRewardData({iID = id, iNum = num})
    common_item:SetItemInfo(processItemData)
    self.m_small = false
  end
  if self.m_Big then
    self.m_bg_item:SetActive(true)
    self.m_bg_item_double:SetActive(false)
    local cfg = MonthlyCardManager:GetRewardCfg(false, true)
    local itemObj = self.m_bg_item.transform:Find("c_common_item").gameObject
    local common_item = self:createCommonItem(itemObj)
    common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    local id = cfg[1]
    local num = cfg[2]
    local processItemData = ResourceUtil:GetProcessRewardData({iID = id, iNum = num})
    common_item:SetItemInfo(processItemData)
    self.m_Big = false
  end
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
