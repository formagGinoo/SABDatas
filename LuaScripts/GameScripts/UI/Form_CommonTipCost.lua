local Form_CommonTipCost = class("Form_CommonTipCost", require("UI/UIFrames/Form_CommonTipCostUI"))
local DefaultCommonTextID = 100018
local string_CS_Format = string.CS_Format

function Form_CommonTipCost:SetInitParam(param)
end

function Form_CommonTipCost:AfterInit()
  self.super.AfterInit(self)
  self.m_beforeItem = nil
  self.m_afterItem = nil
  self:CreateItemWidget()
  self.top_Bar = self:createResourceBar(self.m_top_resource)
end

function Form_CommonTipCost:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  self:RefreshResourceBar()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_CommonTipCost:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_CommonTipCost:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CommonTipCost:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_beforeItemID = tParam.beforeItemID
    self.m_beforeItemNum = tParam.beforeItemNum
    self.m_afterItemID = tParam.afterItemID
    self.m_afterItemNum = tParam.afterItemNum
    self.m_commonTextID = tParam.commonTextID
    self.m_formatFun = tParam.formatFun
    self.m_sureBackFun = tParam.funSure
    self.m_csui.m_param = nil
  end
end

function Form_CommonTipCost:RefreshResourceBar()
  local mainCurrency = {
    self.m_afterItemID,
    MTTDProto.SpecialItem_Coin,
    MTTDProto.SpecialItem_ShowDiamond
  }
  self.top_Bar:FreshChangeItems(mainCurrency)
end

function Form_CommonTipCost:CreateItemWidget()
  self.m_beforeItem = self:createCommonItem(self.m_item_before)
  self.m_beforeItem:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnBeforeItemClk(itemID, itemNum, itemCom)
  end)
  self.m_afterItem = self:createCommonItem(self.m_item_after)
  self.m_afterItem:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnAfterItemClk(itemID, itemNum, itemCom)
  end)
end

function Form_CommonTipCost:FreshUI()
  self:FreshItemUI()
  self:FreshWord()
end

function Form_CommonTipCost:FreshItemUI()
  if self.m_beforeItemID and self.m_beforeItemNum then
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = self.m_beforeItemID,
      iNum = self.m_beforeItemNum
    })
    self.m_beforeItem:SetItemInfo(processItemData)
  end
  if self.m_afterItemID and self.m_afterItemNum then
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = self.m_afterItemID,
      iNum = self.m_afterItemNum
    })
    self.m_afterItem:SetItemInfo(processItemData)
  end
end

function Form_CommonTipCost:FreshWord()
  local showTextID = DefaultCommonTextID
  if self.m_commonTextID then
    showTextID = self.m_commonTextID
  end
  local commonTextStr = ConfigManager:GetCommonTextById(showTextID)
  if self.m_formatFun then
    commonTextStr = self.m_formatFun(commonTextStr)
  else
    commonTextStr = self:DefaultFormat(commonTextStr)
  end
  self.m_word_Text.text = commonTextStr
end

function Form_CommonTipCost:DefaultFormat(commonTextStr)
  if not commonTextStr then
    return
  end
  local beforeItemName = ItemManager:GetItemName(self.m_beforeItemID)
  return string_CS_Format(commonTextStr, beforeItemName, self.m_beforeItemNum)
end

function Form_CommonTipCost:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CommonTipCost:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_CommonTipCost:OnBeforeItemClk(itemID, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_CommonTipCost:OnAfterItemClk(itemID, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_CommonTipCost:OnBtnYesClicked()
  if self.m_sureBackFun then
    self.m_sureBackFun()
  end
  self:CloseForm()
end

function Form_CommonTipCost:IsOpenGuassianBlur()
  return true
end

function Form_CommonTipCost:OnBtnNoClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_CommonTipCost", Form_CommonTipCost)
return Form_CommonTipCost
