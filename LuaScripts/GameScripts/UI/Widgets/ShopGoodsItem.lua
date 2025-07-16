local ShopGoodsItem = class("ShopGoodsItem")
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function ShopGoodsItem:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_shop_root_obj = self.m_goRoot.transform:Find("pnl_item").gameObject
  self.m_common_item_obj = self.m_goRoot.transform:Find("pnl_item/c_common_item").gameObject
  self.m_redpoint_obj = self.m_goRoot.transform:Find("c_common_shopitem_redpoint").gameObject
  self.m_tag_obj = self.m_goRoot.transform:Find("pnl_item/c_img_shopitem_tag").gameObject
  self.m_salenum_obj = self.m_goRoot.transform:Find("pnl_item/c_shopitem_salenum").gameObject
  self.m_buy_obj = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy").gameObject
  self.m_price_sale_obj = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy/c_txt_price_sale").gameObject
  self.m_shop_time_obj = self.m_goRoot.transform:Find("pnl_item/c_shop_time").gameObject
  self.m_sold_out_obj = self.m_goRoot.transform:Find("c_shopitem_soldout").gameObject
  self.m_txt_shop_time = self.m_goRoot.transform:Find("pnl_item/c_shop_time/c_txt_shop_time"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_shopitem_name = self.m_goRoot.transform:Find("pnl_item/c_txt_shopitem_name"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_shopitem_remain = self.m_goRoot.transform:Find("pnl_item/c_txt_shopitem_remain"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_salenum = self.m_goRoot.transform:Find("pnl_item/c_shopitem_salenum/c_txt_shopitem_salenum"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_price_original = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy/c_txt_price_original"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_price_sale = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy/c_txt_price_sale"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_price_beforesale = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy/c_txt_price_sale/c_txt_price_beforesale"):GetComponent(T_TextMeshProUGUI)
  self.m_sold_img = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy/c_btn_icon"):GetComponent(T_Image)
  self.m_sold_obj = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy/c_btn_icon").gameObject
  self.m_txt_price_original_obj = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy/c_txt_price_original").gameObject
  self.m_txt_price_sale_obj = self.m_goRoot.transform:Find("pnl_item/c_btn_shopitem_buy/c_txt_price_sale").gameObject
end

function ShopGoodsItem:SetItemInfo(itemData)
  local goodsId = itemData.iGoodsId
  local groupId = itemData.iGroupId
  local iBought = itemData.iBought
  local iShopId = itemData.iShopId
  self.itemData = itemData
  self.m_salenum_obj:SetActive(false)
  local goodCfg = ShopManager:GetShopGoodsConfig(groupId, goodsId)
  if goodCfg and not goodCfg:GetError() then
    local goodItem = utils.changeCSArrayToLuaTable(goodCfg.m_ItemID) or {}
    if self.m_itemIcon == nil then
      self.m_itemIcon = require("UI/Widgets/CommonItem").new(self.m_common_item_obj)
    end
    local processData = ResourceUtil:GetProcessRewardData({
      iID = goodItem[1],
      iNum = goodItem[2]
    })
    self.m_itemIcon:SetItemInfo(processData)
    self.m_itemIcon:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnItemClick(itemID, itemNum, itemCom)
    end)
    local limitFlag = ShopManager:CheckIsReachedPurchaseLimit(iShopId, groupId, goodsId)
    local soldOut = iBought >= goodCfg.m_ItemQuantity or limitFlag
    self.m_sold_out_obj:SetActive(soldOut)
    self.m_shop_root_obj:SetActive(not soldOut)
    self.m_txt_shopitem_name.text = processData.name
    self.m_txt_shopitem_remain.text = string.format(ConfigManager:GetCommonTextById(20047), goodCfg.m_ItemQuantity - iBought, goodCfg.m_ItemQuantity)
    self.m_tag_obj:SetActive(goodCfg.m_Recommend > 0 and not soldOut)
    local currency = utils.changeCSArrayToLuaTable(goodCfg.m_Currency) or {}
    local originalPrice = currency[2]
    local finalPrice = currency[3]
    if originalPrice == finalPrice then
      self.m_salenum_obj:SetActive(false)
      self.m_txt_price_original.text = BigNumFormat(originalPrice)
      self.m_txt_price_original_obj:SetActive(true)
      self.m_txt_price_original_obj:SetActive(true)
      self.m_txt_price_sale_obj:SetActive(false)
    else
      self.m_salenum_obj:SetActive(true)
      self.m_txt_price_original_obj:SetActive(false)
      self.m_txt_salenum.text = string.format(ConfigManager:GetCommonTextById(20040), math.floor((originalPrice - finalPrice) / originalPrice * 100))
      self.m_txt_price_beforesale.text = BigNumFormat(originalPrice)
      self.m_txt_price_sale.text = BigNumFormat(finalPrice)
      self.m_txt_price_original_obj:SetActive(false)
      self.m_txt_price_sale_obj:SetActive(true)
    end
    ResourceUtil:CreatIconById(self.m_sold_img, currency[1])
    self.m_sold_obj:SetActive(true)
    self.m_buy_obj:SetActive(not soldOut)
    if finalPrice == 0 then
      self.m_redpoint_obj:SetActive(not soldOut)
      if originalPrice == finalPrice then
        self.m_txt_price_original.text = ConfigManager:GetCommonTextById(20041)
      else
        self.m_txt_price_sale.text = ConfigManager:GetCommonTextById(20041)
      end
    else
      self.m_redpoint_obj:SetActive(false)
    end
    self:RefreshTime(goodCfg)
    local num = ItemManager:GetItemNum(currency[1], true)
    if finalPrice > num then
      UILuaHelper.SetColor(self.m_txt_price_original, table.unpack(GlobalConfig.COMMON_COLOR.Red))
      UILuaHelper.SetColor(self.m_txt_price_sale, table.unpack(GlobalConfig.COMMON_COLOR.Red))
    else
      UILuaHelper.SetColor(self.m_txt_price_original, 255, 255, 255, 1)
      UILuaHelper.SetColor(self.m_txt_price_sale, 255, 255, 255, 1)
    end
  else
    log.error("can not find shop goods by groupId == " .. tostring(groupId) .. " goodsId == " .. tostring(goodsId))
  end
end

function ShopGoodsItem:RefreshTime(goodCfg)
  self.m_iTimeDurationOneSecond = 1
  if self.m_txt_shop_time and goodCfg.m_EndTime ~= "" then
    local endTime = TimeUtil:TimeStringToTimeSec2(goodCfg.m_EndTime)
    local shopCfg = ShopManager:GetShopConfig(self.itemData.iShopId)
    local is_corved, corveCfg = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shopGoods, {
      id = shopCfg.m_ActId,
      iGroupID = goodCfg.m_GoodsGroupID,
      iGoodsId = goodCfg.m_GoodsID
    })
    if is_corved then
      endTime = corveCfg.iEndTime
    end
    self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
    self.m_txt_shop_time.text = TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick))
    self.m_shop_time_obj:SetActive(true)
  else
    self.m_shop_time_obj:SetActive(false)
  end
end

function ShopGoodsItem:OnUpdate(dt)
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick - dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    self.m_txt_shop_time.text = TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick))
  end
  if self.m_iTimeTick <= 0 then
    self.m_iTimeTick = nil
    self.m_txt_shop_time.text = ""
  end
end

function ShopGoodsItem:OnItemClick(itemID, itemNum)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  local shopCfg = ShopManager:GetShopConfig(self.itemData.iShopId)
  if shopCfg.m_ActId > 0 then
    LocalDataManager:SetIntSimple(shopCfg.m_ActId .. "_ActShopGoodsRedDot_" .. self.itemData.iGroupId .. "_" .. self.itemData.iGoodsId, 1, true)
    EventCenter.Broadcast(EventDefine.eGameEvent_Level_Lamia_ShopGoodsClicked)
  end
end

return ShopGoodsItem
