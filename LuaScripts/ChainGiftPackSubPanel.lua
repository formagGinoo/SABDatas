local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ChainGiftPackSubPanel = class("ChainGiftPackSubPanel", UISubPanelBase)
local newGachaWindowId = 25002

function ChainGiftPackSubPanel:OnInit()
end

function ChainGiftPackSubPanel:OnFreshData()
  self.m_storeData = self.m_panelData.storeData
  self.payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  self:RefreshData()
  self:RefreshUI()
end

function ChainGiftPackSubPanel:RefreshData()
  self.m_curShowGoodInfo = nil
  self.m_allGoodList = self.m_storeData.stGoodsConfig
  table.sort(self.m_allGoodList, function(a, b)
    return a.SortOrder < b.SortOrder
  end)
  for k, v in pairs(self.m_allGoodList.mGoods) do
    local buyTimes = self.payStoreActivity:GetBuyCount(self.m_storeData.iStoreId, v.iGoodsId)
    local limitBuyTimes = v.iLimitNum
    if buyTimes < limitBuyTimes then
      self.isOver = false
      self.m_curShowGoodInfo = v
      break
    end
    self.isOver = true
    self.m_curShowGoodInfo = v
  end
end

function ChainGiftPackSubPanel:RefreshUI()
  if self.m_curShowGoodInfo then
    self.m_txt_giftnum_Text.text = self.payStoreActivity:getLangText(self.m_curShowGoodInfo.sGoodsName)
    local buyTimes = self.payStoreActivity:GetBuyCount(self.m_storeData.iStoreId, self.m_curShowGoodInfo.iGoodsId)
    self.m_txt_price_Text.text = IAPManager:GetProductPrice(self.m_curShowGoodInfo.sProductId, true)
    local times = tonumber(self.m_curShowGoodInfo.iLimitNum) - tonumber(buyTimes)
    self.m_txt_titlegift_Text.text = times .. "/" .. self.m_curShowGoodInfo.iLimitNum
    if self.m_curShowGoodInfo.sGoodsPic ~= "" then
      UILuaHelper.SetAtlasSprite(self.m_icon_box_Image, self.m_curShowGoodInfo.sGoodsPic)
    end
    self.m_txt_num_Text.text = "x" .. self.m_curShowGoodInfo.vReward[1].iNum
    UILuaHelper.SetActive(self.m_bg_magnification, false)
    if not self.isOver and self.m_curShowGoodInfo.iDiscount ~= 0 then
      UILuaHelper.SetActive(self.m_bg_magnification, true)
      local showText = tonumber(self.m_curShowGoodInfo.iDiscount) .. "%"
      self.m_txt_magnification_Text.text = tostring(showText)
    end
    UILuaHelper.SetActive(self.m_img_soldoutmask, self.isOver)
  end
  self.m_txt_countnum_Text.text = ConfigManager:GetCommonTextById(20109)
end

function ChainGiftPackSubPanel:OnBtnbuyClicked()
  local config = self.m_curShowGoodInfo
  if not self.payStoreActivity or not config then
    return
  end
  local buyTimes = self.payStoreActivity:GetBuyCount(self.m_storeData.iStoreId, config.iGoodsId)
  if buyTimes >= config.iLimitNum and config.iLimitNum > 0 then
    return
  end
  local ProductInfo = {
    StoreID = self.m_storeData.iStoreId,
    GoodsID = config.iGoodsId,
    productId = config.sProductId,
    productSubId = config.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActPayStore,
    productName = self.payStoreActivity:getLangText(config.sGoodsName),
    productDesc = self.payStoreActivity:getLangText(config.sGoodsDesc),
    iActivityId = self.payStoreActivity:getID(),
    GiftPackType = 1
  }
  IAPManager:BuyProductByStoreType(ProductInfo, nil, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
  end)
end

function ChainGiftPackSubPanel:OnIconboxClicked()
  local itemID = self.m_curShowGoodInfo.vReward[1].iID
  utils.openItemDetailPop({iID = itemID})
end

function ChainGiftPackSubPanel:OnBtnpblssrClicked()
  QuickOpenFuncUtil:OpenFunc(newGachaWindowId)
end

return ChainGiftPackSubPanel
