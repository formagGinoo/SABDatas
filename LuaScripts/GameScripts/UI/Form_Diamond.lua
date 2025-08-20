local Form_Diamond = class("Form_Diamond", require("UI/UIFrames/Form_DiamondUI"))

function Form_Diamond:SetInitParam(param)
end

local RechargeCurrencyID = MTTDProto.SpecialItem_Diamond
local FreeCurrencyID = MTTDProto.SpecialItem_FreeDiamond

function Form_Diamond:AfterInit()
  self.super.AfterInit(self)
end

function Form_Diamond:OnActive()
  self.super.OnActive(self)
  self.iVirtualDiamondsID = self.m_csui.m_param.iID
  local iRechargeCount = ItemManager:GetItemNum(RechargeCurrencyID)
  local showPayDiamond = BigNumFormatPayItem(iRechargeCount) or ""
  self.m_txt_ownpay_Text.text = showPayDiamond
  local iFreeCount = ItemManager:GetItemNum(FreeCurrencyID)
  local showFreeDiamond = BigNumFormatPayItem(iFreeCount) or ""
  self.m_txt_ownfree_Text.text = showFreeDiamond
  local totalNum = iRechargeCount + iFreeCount
  local totalNumText = BigNumFormatPayItem(totalNum) or ""
  self.m_txt_all_Text.text = totalNumText
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_Diamond:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_Diamond:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Diamond:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_Diamond:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_Diamond:OnBtnpaytipsClicked()
  utils.openItemDetailPop({
    iID = RechargeCurrencyID,
    iNum = ItemManager:GetItemNum(RechargeCurrencyID)
  })
end

function Form_Diamond:OnBtnfreetipsClicked()
  utils.openItemDetailPop({
    iID = FreeCurrencyID,
    iNum = ItemManager:GetItemNum(FreeCurrencyID)
  })
end

function Form_Diamond:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Diamond", Form_Diamond)
return Form_Diamond
