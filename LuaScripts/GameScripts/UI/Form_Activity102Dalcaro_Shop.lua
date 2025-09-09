local Form_Activity102Dalcaro_Shop = class("Form_Activity102Dalcaro_Shop", require("UI/UIFrames/Form_Activity102Dalcaro_ShopUI"))

function Form_Activity102Dalcaro_Shop:SetInitParam(param)
end

function Form_Activity102Dalcaro_Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_GoodsListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_shop_InfinityGrid, "HeroActivity/UIHeroActShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
  self:SetCellPerLine()
  self.ani_str = "common_shopitem_in"
end

function Form_Activity102Dalcaro_Shop:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(119)
end

local fullscreen = true
ActiveLuaUI("Form_Activity102Dalcaro_Shop", Form_Activity102Dalcaro_Shop)
return Form_Activity102Dalcaro_Shop
