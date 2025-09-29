local Form_Activity110Shop = class("Form_Activity110Shop", require("UI/UIFrames/Form_Activity110ShopUI"))

function Form_Activity110Shop:SetInitParam(param)
end

function Form_Activity110Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_GoodsListInfinityGrid = self:CreateInfinityGrid(self.m_scrollView_shop_InfinityGrid, "HeroActivity/UIHeroActShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
end

function Form_Activity110Shop:OnActive()
  self.super.OnActive(self)
end

function Form_Activity110Shop:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity110Shop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity110Shop:CheckShowEnterAnim()
end

local fullscreen = true
ActiveLuaUI("Form_Activity110Shop", Form_Activity110Shop)
return Form_Activity110Shop
