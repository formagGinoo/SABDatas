local Form_Shop = class("Form_Shop", require("UI/UIFrames/Form_ShopUI"))
local ShopIns = ConfigManager:GetConfigInsByName("Shop")
local DefaultShowSpineName = "merchant"
local ITEM_WIDTH = 330
local curBuyItem

function Form_Shop:SetInitParam(param)
end

function Form_Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1110)
  self.m_GoodsListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_shop_InfinityGrid, "Shop/UIShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
  self.m_timeDes = ConfigManager:GetCommonTextById(20042)
  self.m_curChooseTab = 1
  self.m_shopGoods = {}
  self.m_shopList = {}
  self.m_chooseShopCfg = {}
  self:SetCellPerLine()
end

function Form_Shop:SetCellPerLine()
  local count = math.floor(self.m_scrollView_shop.transform.rect.width / ITEM_WIDTH)
  self.m_GoodsListInfinityGrid:SetCellPerLine(math.max(count, 3))
end

function Form_Shop:OnActive()
  curBuyItem = nil
  self.super.OnActive(self)
  self:LoadShowSpine()
  self:AddEventListeners()
  self.m_firstOpenFlag = true
  if self.m_csui.m_param and self.m_csui.m_param.sel_shop then
    self.m_selShop = self.m_csui.m_param.sel_shop
    self.m_shopList = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Normal)
    self:ChangeChooseTabToSelShop()
  end
  self:RefreshUI()
  if self.m_GoodsListInfinityGrid then
    self.m_GoodsListInfinityGrid:LocateTo(0)
  end
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("ShopEnterVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
  self.m_changeTabVoice = true
  self.m_buyVoice = true
end

function Form_Shop:OnActiveSame()
  self:refreshTabLoopScroll()
  self:RefreshShopItemInfo()
end

function Form_Shop:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
  self:RemoveAllEventListeners()
  self.m_firstOpenFlag = true
  self.m_curChooseTab = 1
end

function Form_Shop:RefreshUI()
  self.m_shopList = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Normal)
  self:refreshTabLoopScroll()
  self:RefreshShopItemInfo()
  self:RefreshTime()
  self:RefreshResourceBar()
end

function Form_Shop:ChangeChooseTabToSelShop()
  if self.m_selShop then
    for i, shopCfg in ipairs(self.m_shopList) do
      if shopCfg.m_WindowID == self.m_selShop then
        self.m_curChooseTab = i
        return
      end
    end
  end
end

function Form_Shop:RefreshResourceBar()
  local shopCfg = self.m_shopList[self.m_curChooseTab]
  if shopCfg then
    local mainCurrency = utils.changeCSArrayToLuaTable(shopCfg.m_MainCurrency)
    self.m_widgetResourceBar:FreshChangeItems(mainCurrency)
  end
  self.m_shop_name_Text.text = self.m_chooseShopCfg.m_mName
end

function Form_Shop:AddEventListeners()
  self:addEventListener("eGameEvent_RefreshShopData", handler(self, self.OnEventShopRefresh))
  self:addEventListener("eGameEvent_ShopBuy", handler(self, self.OnEventShopItemRefresh))
  self:addEventListener("eGameEvent_RefreshShopItem", handler(self, self.OnEventShopItemRefresh))
  self:addEventListener("eGameEvent_ShopSoldOut", handler(self, self.RefreshShopItemSoldOutAnim))
  self:addEventListener("eGameEvent_Item_SetItem", handler(self, self.RefreshSetItem))
end

function Form_Shop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Shop:OnEventShopRefresh(shopId)
  self:PlayBuyVoice()
  if self.m_chooseShopCfg then
    local shopList = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Normal)
    if self.m_chooseShopCfg.m_ShopID == shopId then
      self:RefreshUI()
    elseif not shopList[self.m_curChooseTab] or shopList[self.m_curChooseTab].m_ShopID ~= self.m_chooseShopCfg.m_ShopID then
      self.m_curChooseTab = 1
      self:RefreshUI()
    end
  end
end

function Form_Shop:PlayBuyVoice()
  if self.m_buyVoice then
    self.m_buyVoice = false
    local closeVoice = ConfigManager:GetGlobalSettingsByKey("ShopBuyVoice")
    CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
      self.m_playingId = playingId
    end, function()
      self.m_playingId = nil
    end)
  end
end

function Form_Shop:OnEventShopItemRefresh()
  self:PlayBuyVoice()
  self:refreshTabLoopScroll()
  self:RefreshShopItemInfo()
end

function Form_Shop:GetDailyRefreshTime()
  self.m_iNextRefreshTime = TimeUtil:GetServerNextCommonResetTime()
end

function Form_Shop:OnUpdate(dt)
  if self.m_GoodsListInfinityGrid then
    self.m_GoodsListInfinityGrid:update(dt)
  end
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick - dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond - dt
  if self.m_iTimeDurationOneSecond <= 0 then
    self.m_iTimeDurationOneSecond = 1
    local str = string.format(self.m_timeDes, TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick)))
    self.m_txt_cutdown_time_Text.text = str
  end
  if self.m_iTimeTick <= 0 then
    self.m_iTimeTick = nil
    self.m_txt_cutdown_time_Text.text = ""
  end
end

function Form_Shop:RefreshTime()
  self.m_iTimeDurationOneSecond = 1
  if self.m_chooseShopCfg.m_RefreshType == ShopManager.REFRESH_TYPE.NoRefresh then
    self.m_shop_time:SetActive(false)
  else
    local endTime = TimeUtil:GetServerTimeS()
    if self.m_chooseShopCfg.m_RefreshType == ShopManager.REFRESH_TYPE.DailyRefresh then
      endTime = TimeUtil:GetServerNextCommonResetTime()
    elseif self.m_chooseShopCfg.m_RefreshType == ShopManager.REFRESH_TYPE.WeeklyRefresh then
      endTime = TimeUtil:GetNextWeekResetTime()
    elseif self.m_chooseShopCfg.m_RefreshType == ShopManager.REFRESH_TYPE.MonthlyRefresh then
      endTime = TimeUtil:GetNextMonthResetTime()
    elseif self.m_chooseShopCfg.m_RefreshType == ShopManager.REFRESH_TYPE.AppointedTime then
      endTime = TimeUtil:TimeStringToTimeSec2(self.m_chooseShopCfg.m_RefreshParam)
    end
    self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
    local str = string.format(self.m_timeDes, TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick)))
    self.m_txt_cutdown_time_Text.text = str
    self.m_shop_time:SetActive(true)
  end
  self.m_btn_time:SetActive(self.m_chooseShopCfg.m_RefreshNum ~= 0)
end

function Form_Shop:RefreshShopItemInfo()
  if self.m_shopList[self.m_curChooseTab] then
    local goods = ShopManager:GetShopGoodsByShopId(self.m_shopList[self.m_curChooseTab].m_ShopID) or {}
    self.m_GoodsListInfinityGrid:ShowItemList(goods)
    self.m_shopGoods = goods
    self.m_chooseShopCfg = self.m_shopList[self.m_curChooseTab]
  end
  self.m_pnl_blocktips1:SetActive(false)
end

function Form_Shop:RefreshShopItemSoldOutAnim()
  if curBuyItem ~= nil then
    self:PlayBuyVoice()
    self:NoRefreshShopDiscountAnim(function()
      local animationObj = curBuyItem.transform:Find("c_shopitem_soldout").gameObject
      local pnlItem = curBuyItem.transform:Find("pnl_item").gameObject
      self:RefreshShopItemInfo()
      curBuyItem = nil
      pnlItem:SetActive(true)
      UILuaHelper.PlayAnimationByName(animationObj, "shopitem_soldout_in")
      GlobalManagerIns:TriggerWwiseBGMState(81)
    end)
  end
  self:refreshTabLoopScroll()
end

function Form_Shop:RefreshSetItem()
  self:NoRefreshShopDiscountAnim(function()
    self:RefreshShopItemInfo()
  end)
end

function Form_Shop:NoRefreshShopDiscountAnim(midFun)
  local content = self.m_scrollView_shop.transform:Find("Viewport/Content").gameObject
  if content ~= nil then
    for i = 0, content.transform.childCount - 1 do
      local child = content.transform:GetChild(i).gameObject
      child.transform:Find("pnl_item/c_shopitem_salenum"):GetComponent("Animation").playAutomatically = false
    end
    midFun()
    for i = 0, content.transform.childCount - 1 do
      local child = content.transform:GetChild(i).gameObject
      child.transform:Find("pnl_item/c_shopitem_salenum"):GetComponent("Animation").playAutomatically = true
    end
  end
end

function Form_Shop:refreshTabLoopScroll()
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_scrollView
    local params = {
      show_data = self.m_shopList,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "c_btn_go" then
          CS.GlobalManager.Instance:TriggerWwiseBGMState(62)
          self:ChangeTab(index, cell_data)
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(self.m_shopList, true)
  end
  if self.m_firstOpenFlag then
    self.m_loop_scroll_view:moveToCellIndex(self.m_curChooseTab)
  end
  self.m_firstOpenFlag = false
end

function Form_Shop:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_go", true)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_select_btn", self.m_curChooseTab == index)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_normal_btn", self.m_curChooseTab ~= index)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_normal_shopdesc", cell_data.m_mName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_select_shopdesc", cell_data.m_mName)
  LuaBehaviourUtil.setImg(luaBehaviour, "c_img_normal_btn_icon", cell_data.m_IconPath)
  LuaBehaviourUtil.setImg(luaBehaviour, "c_img_select_btn_icon", cell_data.m_IconPathClick)
  local redFlag = ShopManager:CheckShopRedPointByShopId(cell_data.m_ShopID)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_redpoint", redFlag)
  if self.m_chooseTabFlag then
    local c_item_root = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_item_root")
    UILuaHelper.PlayAnimationByName(c_item_root, "base_select")
  end
end

function Form_Shop:ChangeTab(index, cell_data)
  self.m_curChooseTab = index
  self.m_chooseTabFlag = true
  self:RefreshUI()
  self.m_chooseTabFlag = false
  if self.m_GoodsListInfinityGrid then
    self.m_GoodsListInfinityGrid:LocateTo(0)
  end
  if self.m_changeTabVoice then
    local closeVoice = ConfigManager:GetGlobalSettingsByKey("ShopSwitchVoice")
    if not self.m_playingId then
      self.m_changeTabVoice = false
      CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
        self.m_playingId = playingId
      end, function()
        self.m_playingId = nil
      end)
    end
  end
end

function Form_Shop:OnShopBuyBtnClk(index, go)
  if self.m_shopList[self.m_curChooseTab] and self.m_shopGoods then
    local goods = self.m_shopGoods[index + 1]
    curBuyItem = go
    local limit = ShopManager:CheckIsReachedPurchaseLimit(self.m_shopList[self.m_curChooseTab].m_ShopID, goods.iGroupId, goods.iGoodsId)
    if limit then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40013)
    else
      local param = {
        shopId = self.m_shopList[self.m_curChooseTab].m_ShopID,
        goodsInfo = goods
      }
      StackPopup:Push(UIDefines.ID_FORM_SHOPCONFIRMPOP, param)
    end
  end
end

function Form_Shop:OnBtntimeClicked()
  local shopMaxRefreshTimes = 0
  local freeRefreshTimes = 0
  if self.m_chooseShopCfg then
    shopMaxRefreshTimes, freeRefreshTimes = ShopManager:GetShopCanRefreshMaxTimesByShopId(self.m_chooseShopCfg.m_ShopID)
  end
  if self.m_chooseShopCfg and 0 < shopMaxRefreshTimes then
    local refreshNum = ShopManager:GetShopRefreshTimesByShopId(self.m_chooseShopCfg.m_ShopID)
    local curTotalRefreshTimes = refreshNum + ShopManager:GetShopCurFreeRefreshTimesByShopId(self.m_chooseShopCfg.m_ShopID)
    if shopMaxRefreshTimes > curTotalRefreshTimes then
      local refreshCostTab = utils.changeCSArrayToLuaTable(self.m_chooseShopCfg.m_RefreshCost)
      local refreshCost = refreshCostTab[refreshNum + 1] == nil and refreshCostTab[#refreshCostTab] or refreshCostTab[refreshNum + 1]
      local itemCfg = ItemManager:GetItemConfigById(refreshCost[1])
      local curRefreshShopTimes = ShopManager:GetShopCurFreeRefreshTimesByShopId(self.m_chooseShopCfg.m_ShopID)
      local currefreshCost = freeRefreshTimes > curRefreshShopTimes and 0 or refreshCost[2]
      utils.ShowCommonTipCost({
        beforeItemID = refreshCost[1],
        beforeItemNum = currefreshCost,
        formatFun = function(sContent)
          return string.format(sContent, tostring(itemCfg.m_mItemName), currefreshCost)
        end,
        confirmCommonTipsID = 1400,
        funSure = function()
          ShopManager:ReqShopRefresh(self.m_chooseShopCfg.m_ShopID)
        end
      })
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10105)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10106)
  end
end

function Form_Shop:IsFullScreen()
  return true
end

function Form_Shop:OnBackHome()
  local isInBattle = BattleFlowManager:IsInBattle()
  if isInBattle == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("ShopCloseVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
end

function Form_Shop:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("ShopCloseVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_SHOP)
end

function Form_Shop:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_Shop:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(DefaultShowSpineName, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_Shop:LoadShowSpine()
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  self.m_HeroSpineDynamicLoader:GetObjectByName(DefaultShowSpineName, function(nameStr, object)
    self:CheckRecycleSpine()
    UILuaHelper.SetParent(object, self.m_root_hero, true)
    UILuaHelper.SetActive(object, true)
    UILuaHelper.SpineResetMatParam(object)
    self.m_curHeroSpineObj = object
  end)
end

function Form_Shop:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = DefaultShowSpineName,
    eType = DownloadManager.ResourceType.UI
  }
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Shop", Form_Shop)
return Form_Shop
