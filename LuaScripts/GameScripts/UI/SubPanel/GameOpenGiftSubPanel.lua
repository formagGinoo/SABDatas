local UISubPanelBase = require("UI/Common/UISubPanelBase")
local GameOpenGiftSubPanel = class("GameOpenGiftSubPanel", UISubPanelBase)
local RewardID = 1050

function GameOpenGiftSubPanel:OnInit()
end

function GameOpenGiftSubPanel:OnFreshData()
  self.m_storeData = self.m_panelData.storeData
  self:RefreshData()
end

function GameOpenGiftSubPanel:RefreshData()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  local goodsList = self.m_storeData.stGoodsConfig.mGoods
  local goodsData = {}
  for k, v in pairs(goodsList) do
    table.insert(goodsData, v)
  end
  table.sort(goodsData, function(a, b)
    return a.iGoodsId < b.iGoodsId
  end)
  self.goodsData = goodsData
  for i = 1, #goodsData do
    if not goodsData[i].iStoreId then
      goodsData[i].iStoreId = self.m_storeData.iStoreId
    end
    local buyTimes = payStoreActivity:GetBuyCount(self.m_storeData.iStoreId, goodsData[i].iGoodsId)
    local bIsSoldOut = buyTimes >= goodsData[i].iLimitNum and goodsData[i].iLimitNum > 0
    self["m_pnl_soldoutmask" .. i]:SetActive(bIsSoldOut)
    self["m_item" .. i]:SetActive(not bIsSoldOut)
    local numText = ""
    if goodsData[i].iLimitNum > 0 then
      local v = goodsData[i].iLimitNum - buyTimes
      if v < 0 then
        v = 0
      end
      numText = string.format(ConfigManager:GetCommonTextById(20047), v, goodsData[i].iLimitNum)
    end
    self["m_txt_limit" .. i .. "_Text"].text = numText
    self["m_txt_titlegift" .. i .. "_Text"].text = payStoreActivity:getLangText(goodsData[i].sGoodsName)
    self["m_txt_price" .. i .. "_Text"].text = IAPManager:GetProductPrice(goodsData[i].sProductId, true)
    local discount = goodsData[i].iDiscount
    if 0 < discount then
      UILuaHelper.SetActive(self["m_bg_discount" .. i], true)
      local showText = tonumber(discount) .. "%"
      self["m_txt_discount" .. i .. "_Text"].text = tostring(showText)
    else
      UILuaHelper.SetActive(self["m_bg_discount" .. i], false)
    end
    for _, v in ipairs(goodsData[i].vReward) do
      if RewardID == v.iID then
        self["m_txt_num" .. i .. "_Text"].text = "x" .. v.iNum
      end
    end
  end
end

function GameOpenGiftSubPanel:OnActivePanel()
end

function GameOpenGiftSubPanel:OnInactivePanel()
end

function GameOpenGiftSubPanel:RefreshList()
end

function GameOpenGiftSubPanel:OnBtntouch1Clicked()
  self:PushBuyWindow(1)
end

function GameOpenGiftSubPanel:OnBtntouch2Clicked()
  self:PushBuyWindow(2)
end

function GameOpenGiftSubPanel:OnBtntouch3Clicked()
  self:PushBuyWindow(3)
end

function GameOpenGiftSubPanel:OnBtntouch4Clicked()
  self:PushBuyWindow(4)
end

function GameOpenGiftSubPanel:PushBuyWindow(idx)
  local config = self.goodsData[idx]
  if not config then
    return
  end
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not payStoreActivity then
    return
  end
  local buyTimes = payStoreActivity:GetBuyCount(config.iStoreId, config.iGoodsId)
  if buyTimes >= config.iLimitNum and config.iLimitNum > 0 then
    return
  end
  local param = {
    Name = payStoreActivity:getLangText(config.sGoodsName),
    Desc = payStoreActivity:getLangText(config.sGoodsDesc),
    Icon = config.sGoodsPic,
    PriceText = IAPManager:GetProductPrice(config.sProductId, true),
    Reward = config.vReward,
    ProductInfo = {
      productId = config.sProductId,
      productSubId = config.iProductSubId,
      StoreID = config.iStoreId,
      GoodsID = config.iGoodsId,
      iStoreType = MTTDProto.IAPStoreType_ActPayStore,
      GiftPackType = 1,
      rewardList = config.vReward
    }
  }
  if config.sProductId == "" then
    param.PriceText = ConfigManager:GetCommonTextById(20041)
  end
  StackPopup:Push(UIDefines.ID_FORM_FIXEDGIFTWINDOW, param)
end

return GameOpenGiftSubPanel
