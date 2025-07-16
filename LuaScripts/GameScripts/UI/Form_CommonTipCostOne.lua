local Form_CommonTipCostOne = class("Form_CommonTipCostOne", require("UI/UIFrames/Form_CommonTipCostOneUI"))
local DefaultCommonTextID = 100028
local string_CS_Format = string.CS_Format

function Form_CommonTipCostOne:SetInitParam(param)
end

function Form_CommonTipCostOne:AfterInit()
  self.super.AfterInit(self)
  self.m_beforeItem = nil
  self:CreateItemWidget()
  self:createResourceBar(self.m_top_resource)
end

function Form_CommonTipCostOne:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_CommonTipCostOne:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_CommonTipCostOne:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CommonTipCostOne:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_beforeItemID = tParam.beforeItemID
    self.m_beforeItemNum = tParam.beforeItemNum
    self.m_commonTextID = tParam.commonTextID
    self.m_ConfirmCommonTipsID = tParam.confirmCommonTipsID
    self.m_formatFun = tParam.formatFun
    self.m_sureBackFun = tParam.funSure
    self.m_csui.m_param = nil
  end
end

function Form_CommonTipCostOne:CreateItemWidget()
  self.m_beforeItem = self:createCommonItem(self.m_item_consume)
  self.m_beforeItem:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnBeforeItemClk(itemID, itemNum, itemCom)
  end)
end

function Form_CommonTipCostOne:FreshUI()
  self:FreshItemUI()
  self:FreshWord()
end

function Form_CommonTipCostOne:FreshItemUI()
  if self.m_beforeItemID and self.m_beforeItemNum then
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = self.m_beforeItemID,
      iNum = self.m_beforeItemNum
    })
    self.m_beforeItem:SetItemInfo(processItemData)
  end
end

function Form_CommonTipCostOne:FreshWord()
  local commonTextStr = ConfigManager:GetCommonTextById(DefaultCommonTextID)
  if self.m_commonTextID then
    commonTextStr = ConfigManager:GetCommonTextById(self.m_commonTextID)
  elseif self.m_ConfirmCommonTipsID then
    commonTextStr = ConfigManager:GetConfirmCommonTipsById(self.m_ConfirmCommonTipsID)
  end
  if self.m_formatFun then
    commonTextStr = self.m_formatFun(commonTextStr)
  else
    commonTextStr = self:DefaultFormat(commonTextStr)
  end
  self.m_word_Text.text = commonTextStr
end

function Form_CommonTipCostOne:DefaultFormat(commonTextStr)
  if not commonTextStr then
    return
  end
  local beforeItemName = ItemManager:GetItemName(self.m_beforeItemID)
  return string_CS_Format(commonTextStr, beforeItemName, self.m_beforeItemNum)
end

function Form_CommonTipCostOne:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CommonTipCostOne:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_CommonTipCostOne:OnBeforeItemClk(itemID, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_CommonTipCostOne:OnAfterItemClk(itemID, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_CommonTipCostOne:OnBtnYesClicked()
  if self.m_sureBackFun then
    self.m_sureBackFun()
  end
  self:CloseForm()
end

function Form_CommonTipCostOne:OnBtnNoClicked()
  self:CloseForm()
end

function Form_CommonTipCostOne:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CommonTipCostOne", Form_CommonTipCostOne)
return Form_CommonTipCostOne
