local UIItemBase = require("UI/Common/UIItemBase")
local UIStoreMsdkPcItem = class("UIStoreMsdkPcItem", UIItemBase)

function UIStoreMsdkPcItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
end

function UIStoreMsdkPcItem:OnFreshData()
  local transform = self.m_itemRootObj.transform
  local channelData = self.m_itemData.channelInfo
  local skuInfo = self.m_itemData.skuInfo
  local priceInfo = self.m_itemData.priceInfo
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_pay", skuInfo.currency .. " " .. CS.System.String.Format("{0:#,0.##}", channelData.price_local_sell * 0.01))
  if priceInfo and channelData.price_local_sell < priceInfo.price_local_sell_max then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_paycount", true)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_paycount", priceInfo.price_local_sell_show_max)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_paycount", false)
  end
  local imageLoader = transform:GetComponent("UICachedImageLoader")
  if imageLoader then
    imageLoader.imageUrl = channelData.icon
    imageLoader:LoadUrl()
  end
end

function UIStoreMsdkPcItem:dispose()
  UIStoreMsdkPcItem.super.dispose(self)
end

function UIStoreMsdkPcItem:OnBtnpayClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemData.channelInfo)
  end
end

return UIStoreMsdkPcItem
