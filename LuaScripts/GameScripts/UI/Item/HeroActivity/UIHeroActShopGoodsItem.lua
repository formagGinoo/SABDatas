local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroActShopGoodsItem = class("UIHeroActShopGoodsItem", UIItemBase)

function UIHeroActShopGoodsItem:OnInit()
  self.m_itemIcon = self:createShopGoodsItem(self.m_itemTemplateCache:GameObject("c_common_shopitem"))
  self.m_sold_time = self.m_itemTemplateCache:GameObject("c_sold_time")
  self.m_buy_obj = self.m_itemTemplateCache:GameObject("c_btn_shopitem_buy")
end

function UIHeroActShopGoodsItem:OnFreshData()
  local data = self.m_itemData
  self.m_itemIcon:SetItemInfo(data)
  local goodsId = data.iGoodsId
  local groupId = data.iGroupId
  local iShopId = data.iShopId
  local goodCfg = ShopManager:GetShopGoodsConfig(groupId, goodsId)
  local m_showTime = TimeUtil:TimeStringToTimeSec2(goodCfg.m_ShowTime) or 0
  local shopCfg = ShopManager:GetShopConfig(iShopId)
  local is_corved, corveCfg = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shopGoods, {
    id = shopCfg.m_ActId,
    iGroupID = groupId,
    iGoodsId = goodsId
  })
  if is_corved then
    m_showTime = corveCfg.iShowTime
  end
  local cur_time = TimeUtil:GetServerTimeS()
  local is_inTime = m_showTime <= cur_time
  self.m_itemIcon.m_shop_root_obj:SetActive(true)
  if is_inTime then
    self.m_sold_time:SetActive(false)
    self.m_buy_obj:SetActive(true)
  else
    local left_time = m_showTime - cur_time + 5
    self.m_txt_soldtime_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(20097), TimeUtil:SecondsToFormatCNStr(math.floor(left_time)))
    if self.timer then
      TimeService:KillTimer(self.timer)
    end
    self.timer = TimeService:SetTimer(1, -1, function()
      left_time = left_time - 1
      if left_time <= 0 then
        TimeService:KillTimer(self.timer)
        self.m_sold_time:SetActive(false)
        self.m_buy_obj:SetActive(true)
      end
      self.m_txt_soldtime_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(20097), TimeUtil:SecondsToFormatCNStr(math.floor(left_time)))
    end)
    self.m_sold_time:SetActive(true)
    self.m_buy_obj:SetActive(false)
  end
  self:RegisterOrUpdateRedDotItem(self.m_itemTemplateCache:GameObject("c_common_shopitem_redpoint"), RedDotDefine.ModuleType.HeroActShopGoodsNew, {
    iActID = shopCfg.m_ActId,
    iGroupID = groupId,
    iGoodsId = goodsId,
    iBought = data.iBought
  })
end

function UIHeroActShopGoodsItem:OnUpdate(dt)
  self.m_itemIcon:OnUpdate(dt)
end

function UIHeroActShopGoodsItem:dispose()
  UIHeroActShopGoodsItem.super.dispose(self)
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

return UIHeroActShopGoodsItem
