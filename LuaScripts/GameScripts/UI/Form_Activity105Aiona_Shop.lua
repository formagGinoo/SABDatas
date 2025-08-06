local Form_Activity105Aiona_Shop = class("Form_Activity105Aiona_Shop", require("UI/UIFrames/Form_Activity105Aiona_ShopUI"))

function Form_Activity105Aiona_Shop:SetInitParam(param)
end

function Form_Activity105Aiona_Shop:AfterInit()
  self.super.AfterInit(self)
  self.m_GoodsListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_shop_InfinityGrid, "HeroActivity/UIHeroActShopGoodsItem")
  self.m_GoodsListInfinityGrid:RegisterButtonCallback("c_btn_shopitem_buy", handler(self, self.OnShopBuyBtnClk))
  self:SetCellPerLine()
end

function Form_Activity105Aiona_Shop:OnActive()
  self.super.OnActive(self)
end

function Form_Activity105Aiona_Shop:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity105Aiona_Shop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity105Aiona_Shop:OnShopBuyBtnClk(index, go)
  self.super.OnShopBuyBtnClk(self, index, go)
  local goods = self.m_shopGoods[index + 1]
  local bCanBuy = ShopManager:CheckHaveAnyStock(self.m_ShopID, goods.iGroupId, goods.iGoodsId)
  if not bCanBuy then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10104)
  else
    local param = {
      shopId = self.m_ShopID,
      goodsInfo = goods,
      bSkipVoice = true
    }
    StackPopup:Push(UIDefines.ID_FORM_SHOPCONFIRMPOP, param)
  end
end

local fullscreen = true
ActiveLuaUI("Form_Activity105Aiona_Shop", Form_Activity105Aiona_Shop)
return Form_Activity105Aiona_Shop
