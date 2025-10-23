local Form_Activity112Shop = class("Form_Activity112Shop", require("UI/UIFrames/Form_Activity112ShopUI"))

function Form_Activity112Shop:SetInitParam(param)
end

function Form_Activity112Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_GoodsListInfinityGrid = self:CreateInfinityGrid(self.m_scrollView_shop_InfinityGrid, "HeroActivity/UIHeroActShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
end

function Form_Activity112Shop:OnActive()
  self.super.OnActive(self)
end

function Form_Activity112Shop:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity112Shop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity112Shop:CheckShowEnterAnim()
end

local fullscreen = true
ActiveLuaUI("Form_Activity112Shop", Form_Activity112Shop)
return Form_Activity112Shop
