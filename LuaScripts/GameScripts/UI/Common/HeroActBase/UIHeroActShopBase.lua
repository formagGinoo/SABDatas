local UIHeroActShopBase = class("UIHeroActShopBase", require("UI/Common/UIBase"))
local curBuyItem
local ITEM_WIDTH = 330
local DurationTime = 0.08

function UIHeroActShopBase:AfterInit()
  UIHeroActShopBase.super.AfterInit(self)
  self.m_isInit = true
  local root_trans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = root_trans.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_btn_symbol:SetActive(false)
  local resourceBarRoot = root_trans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_timeDes = ConfigManager:GetCommonTextById(20098)
end

function UIHeroActShopBase:SetCellPerLine()
  local count = math.floor(self.m_pnl_shop.transform.rect.width / ITEM_WIDTH)
  count = count < 3 and 3 or count
  self.m_GoodsListInfinityGrid:SetCellPerLine(count)
  self.m_LineItemCount = count
end

function UIHeroActShopBase:OnActive()
  UIHeroActShopBase.super.OnActive(self)
  self.sel_shop = self.m_csui.m_param.sel_shop
  local shop_list = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Activity)
  for i, v in ipairs(shop_list) do
    if v.m_WindowID == self.sel_shop then
      self.config = v
    end
  end
  self.m_ShopID = self.config.m_ShopID
  self:AddEventListeners()
  self:RefreshUI()
  if self.m_GoodsListInfinityGrid then
    self.m_GoodsListInfinityGrid:LocateTo(0)
  end
  self:CheckShowEnterAnim()
end

function UIHeroActShopBase:OnInactive()
  UIHeroActShopBase.super.OnInactive(self)
  self:clearEventListener()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
  self.m_GoodsListInfinityGrid:dispose()
end

function UIHeroActShopBase:CheckShowEnterAnim()
  local showItemList = self.m_GoodsListInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj().transform:Find("c_common_shopitem").gameObject
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  TimeService:SetTimer(0.15, 1, function()
    self:ShowItemListAnim()
  end)
end

function UIHeroActShopBase:ShowItemListAnim()
  local showItemList = self.m_GoodsListInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj().transform:Find("c_common_shopitem").gameObject
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    self["ItemInitTimer" .. i] = TimeService:SetTimer((i - 1) * DurationTime, 1, function()
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, self.ani_str)
    end)
  end
end

function UIHeroActShopBase:AddEventListeners()
  self:addEventListener("eGameEvent_RefreshShopData", handler(self, self.OnEventShopRefresh))
  self:addEventListener("eGameEvent_ShopBuy", handler(self, self.OnEventShopItemRefresh))
  self:addEventListener("eGameEvent_RefreshShopItem", handler(self, self.OnEventShopItemRefresh))
  self:addEventListener("eGameEvent_ShopSoldOut", handler(self, self.RefreshShopItemSoldOutAnim))
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.RefreshSetItem))
end

function UIHeroActShopBase:RefreshUI()
  local mainCurrency = utils.changeCSArrayToLuaTable(self.config.m_MainCurrency)
  self.m_widgetResourceBar:FreshChangeItems(mainCurrency)
  self:RefreshShopItemInfo()
  self:FreshTimer()
end

function UIHeroActShopBase:FreshTimer()
  self.m_shop_time:SetActive(false)
  local endTime = TimeUtil:TimeStringToTimeSec2(self.config.m_EndTime) or 0
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
    id = self.config.m_ActId,
    shop_id = self.m_ShopID
  })
  if is_corved then
    endTime = t2
  end
  if not endTime or endTime == 0 then
    self:CloseForm()
    return
  end
  local left_time = endTime - TimeUtil:GetServerTimeS()
  self.m_txt_cutdown_time_Text.text = string.gsubNumberReplace(self.m_timeDes, TimeUtil:SecondsToFormatCNStr(math.floor(left_time)))
  if self.timer then
    TimeService:KillTimer(self.timer)
  end
  self.timer = TimeService:SetTimer(1, -1, function()
    left_time = left_time - 1
    if left_time <= 0 then
      TimeService:KillTimer(self.timer)
      self.m_shop_time:SetActive(false)
      StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    end
    self.m_txt_cutdown_time_Text.text = string.gsubNumberReplace(self.m_timeDes, TimeUtil:SecondsToFormatCNStr(math.floor(left_time)))
  end)
  self.m_shop_time:SetActive(true)
end

function UIHeroActShopBase:OnEventShopRefresh(shopId)
  if self.config then
    self:RefreshUI()
  end
end

function UIHeroActShopBase:OnEventShopItemRefresh()
  local mainCurrency = utils.changeCSArrayToLuaTable(self.config.m_MainCurrency)
  self.m_widgetResourceBar:FreshChangeItems(mainCurrency)
  self:RefreshShopItemInfo()
end

function UIHeroActShopBase:RefreshShopItemSoldOutAnim()
  if curBuyItem ~= nil then
    self:NoRefreshShopDiscountAnim(function()
      local animationObj = curBuyItem.transform:Find("c_common_shopitem/c_shopitem_soldout").gameObject
      local pnlItem = curBuyItem.transform:Find("c_common_shopitem/pnl_item").gameObject
      self:RefreshShopItemInfo()
      curBuyItem = nil
      pnlItem:SetActive(true)
      UILuaHelper.PlayAnimationByName(animationObj, "shopitem_soldout_in")
    end)
  end
end

function UIHeroActShopBase:NoRefreshShopDiscountAnim(midFun)
  local content = self.m_scrollView_shop.transform:Find("Viewport/Content").gameObject
  if content ~= nil then
    for i = 0, content.transform.childCount - 1 do
      local child = content.transform:GetChild(i).gameObject
      child.transform:Find("c_common_shopitem/pnl_item/c_shopitem_salenum"):GetComponent("Animation").playAutomatically = false
    end
    midFun()
    for i = 0, content.transform.childCount - 1 do
      local child = content.transform:GetChild(i).gameObject
      child.transform:Find("c_common_shopitem/pnl_item/c_shopitem_salenum"):GetComponent("Animation").playAutomatically = true
    end
  end
end

function UIHeroActShopBase:RefreshShopItemInfo()
  local goods = ShopManager:GetShopGoodsByShopId(self.m_ShopID) or {}
  self.m_GoodsListInfinityGrid:ShowItemList(goods)
  self.m_shopGoods = goods
end

function UIHeroActShopBase:OnBackClk()
  self:CloseForm()
end

function UIHeroActShopBase:OnShopBuyBtnClk(index, go)
  curBuyItem = go
  local goods = self.m_shopGoods[index + 1]
  LocalDataManager:SetIntSimple(self.config.m_ActId .. "_ActShopGoodsRedDot_" .. goods.iGroupId .. "_" .. goods.iGoodsId, 1, true)
  self:broadcastEvent("eGameEvent_Level_Lamia_ShopGoodsClicked")
end

function UIHeroActShopBase:OnDestroy()
  UIHeroActShopBase.super.OnDestroy(self)
end

function UIHeroActShopBase:IsFullScreen()
  return true
end

return UIHeroActShopBase
