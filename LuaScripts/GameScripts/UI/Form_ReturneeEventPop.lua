local Form_ReturneeEventPop = class("Form_ReturneeEventPop", require("UI/UIFrames/Form_ReturneeEventPopUI"))

function Form_ReturneeEventPop:SetInitParam(param)
end

function Form_ReturneeEventPop:AfterInit()
  self.super.AfterInit(self)
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  returnTaskAct:SetReminded()
end

function Form_ReturneeEventPop:OnActive()
  self.ActivityReturnUI = self.m_csui.m_param
  self.super.OnActive(self)
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  local unlockLow = returnTaskAct:IsGoodUnlock(1)
  if not unlockLow then
    self.m_reward_1:SetActive(true)
    local lowPackCfg = returnTaskAct:GetGoodCfg(1)
    local txt = self.m_reward_1.transform:Find("txt_reward_title_1"):GetComponent("TMPPro")
    local name = returnTaskAct:getLangText(lowPackCfg.iGiftName)
    txt.text = string.CS_Format(ConfigManager:GetCommonTextById(220030), name)
    local lowRewards = returnTaskAct:GetLowRewardItems()
    self:InitRewardItems(self.m_reward_list_1.transform, lowRewards)
  else
    self.m_reward_1:SetActive(false)
  end
  local unlockHeigh = returnTaskAct:IsGoodUnlock(2)
  if not unlockHeigh then
    self.m_reward_2:SetActive(true)
    local highPackCfg = returnTaskAct:GetGoodCfg(2)
    local txt = self.m_reward_2.transform:Find("txt_reward_title_2"):GetComponent("TMPPro")
    local name = returnTaskAct:getLangText(highPackCfg.iGiftName)
    if not unlockLow then
      txt.text = string.CS_Format(ConfigManager:GetCommonTextById(220031), name)
    else
      txt.text = string.CS_Format(ConfigManager:GetCommonTextById(220032), name)
    end
    local highRewards = returnTaskAct:GetHeighRewardItems()
    self:InitRewardItems(self.m_reward_list_2.transform, highRewards)
    if unlockLow then
      local txtPrice = self.m_btn_yes.transform:Find("txt"):GetComponent("TMPPro")
      txtPrice.text = IAPManager:GetProductPrice(highPackCfg.sProductId, true)
    end
  else
    self.m_reward_2:SetActive(false)
  end
  if self.m_reward_3 then
    self.m_reward_3:SetActive(false)
  end
end

function Form_ReturneeEventPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_ReturneeEventPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ReturneeEventPop:InitRewardItems(root, rewards)
  while root.childCount < #rewards do
    CS.UnityEngine.Object.Instantiate(self.m_common_item, root)
  end
  local childCount = root.childCount
  for i = 1, childCount do
    local child = root:GetChild(i - 1).gameObject
    if i <= #rewards then
      child:SetActive(true)
      local reward = rewards[i]
      local processData = ResourceUtil:GetProcessRewardData(reward)
      local itemWidgetIcon = self:createCommonItem(child)
      itemWidgetIcon:SetItemInfo(processData)
      itemWidgetIcon:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        utils.openItemDetailPop({iID = itemID, iNum = itemNum})
      end)
    else
      child:SetActive(false)
    end
  end
end

function Form_ReturneeEventPop:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_RETURNEEEVENTPOP)
end

function Form_ReturneeEventPop:OnBtnCloseClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_RETURNEEEVENTPOP)
end

function Form_ReturneeEventPop:OnBtnnoClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_RETURNEEEVENTPOP)
end

function Form_ReturneeEventPop:OnBtnyesClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_RETURNEEEVENTPOP)
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct == nil then
    return
  end
  local unlockLow = returnTaskAct:IsGoodUnlock(1)
  if not unlockLow then
    if self.ActivityReturnUI ~= nil then
      self.ActivityReturnUI:SwitchRightPanelState(2)
    end
    return
  end
  local unlockHeigh = returnTaskAct:IsGoodUnlock(2)
  if not unlockHeigh then
    returnTaskAct:BuyGiftPackage(2)
  end
end

ActiveLuaUI("Form_ReturneeEventPop", Form_ReturneeEventPop)
return Form_ReturneeEventPop
