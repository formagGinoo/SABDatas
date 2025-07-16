local UIItemBase = require("UI/Common/UIItemBase")
local RechargeItem = class("RechargeItem", UIItemBase)

function RechargeItem:OnInit()
end

function RechargeItem:OnFreshData()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity == nil then
    return
  end
  local config = self.m_itemData
  if config.sGoodsPic ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_img_bgpic_Image, config.sGoodsPic)
  end
  local defaultCount = 0
  if 0 < #config.vReward then
    defaultCount = config.vReward[1].iNum
  end
  local externCount = defaultCount
  local isFirstBuy = payStoreActivity:GetBuyCount(config.iStoreId, config.iGoodsId) == 0
  if not isFirstBuy then
    externCount = 0
    if 0 < #config.vRewardExt then
      externCount = config.vRewardExt[1].iNum
    end
  end
  self.m_img_tag:SetActive(isFirstBuy)
  self.m_txt_coinnum_Text.text = IAPManager:GetProductPrice(config.sProductId, true)
  self.m_txt_bonusnum_Text.text = "+" .. tostring(externCount)
  self.m_txt_titlenum_Text.text = tostring(payStoreActivity:getLangText(config.sGoodsName))
end

function RechargeItem:OnBtnbuyClicked()
  StackPopup:Push(UIDefines.ID_FORM_RECHARGE, self.m_itemData)
end

return RechargeItem
