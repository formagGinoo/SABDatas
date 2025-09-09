local Form_Activity101Lamia_Shop = class("Form_Activity101Lamia_Shop", require("UI/UIFrames/Form_Activity101Lamia_ShopUI"))

function Form_Activity101Lamia_Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_GoodsListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_shop_InfinityGrid, "HeroActivity/UIHeroActShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
  self:SetCellPerLine()
  self.ani_str = "Lamiri_Shop_itlein"
end

function Form_Activity101Lamia_Shop:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(102)
end

ActiveLuaUI("Form_Activity101Lamia_Shop", Form_Activity101Lamia_Shop)
return Form_Activity101Lamia_Shop
