local UIItemBase = require("UI/Common/UIItemBase")
local RechargeItem = class("RechargeItem", UIItemBase)

function RechargeItem:OnInit()
end

function RechargeItem:OnUpdate(dt)
  if self.enableUpdateCheck then
    local delalyActiveTime = self.m_itemData.delalyActiveTime
    if delalyActiveTime and delalyActiveTime <= 0 then
      UILuaHelper.PlayAnimationByName(self:GetItemRootObj(), nil)
      self.enableUpdateCheck = false
    else
    end
  end
end

function RechargeItem:OnFreshData()
  local payStoreActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if payStoreActivity == nil then
    return
  end
  local config = self.m_itemData
  local delalyActiveTime = config.delalyActiveTime
  if delalyActiveTime and 0 < delalyActiveTime then
    self.enableUpdateCheck = true
    UILuaHelper.SetCanvasGroupAlpha(self.m_itemRootObj, 0)
  else
    self.enableUpdateCheck = false
    UILuaHelper.SetCanvasGroupAlpha(self.m_itemRootObj, 1)
    UILuaHelper.ResetAnimationByName(self:GetItemRootObj(), nil, -1)
    UILuaHelper.PlayAnimationByName(self:GetItemRootObj(), nil)
  end
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
  self.m_txt_coinnum_Text.text = IAPManager:GetProductPrice(config.sProductId, true)
  self.m_txt_bonusnumfirst_Text.text = "+" .. tostring(externCount)
  self.m_txt_bonusnumdouble_Text.text = "+" .. tostring(externCount)
  self.m_txt_titlenum_Text.text = tostring(payStoreActivity:getLangText(config.sGoodsName))
  self.m_pnl_tagfirst:SetActive(isFirstBuy)
  self.m_pnl_tagdouble:SetActive(not isFirstBuy)
end

function RechargeItem:OnBtnbuyClicked()
  StackPopup:Push(UIDefines.ID_FORM_RECHARGE, self.m_itemData)
end

return RechargeItem
