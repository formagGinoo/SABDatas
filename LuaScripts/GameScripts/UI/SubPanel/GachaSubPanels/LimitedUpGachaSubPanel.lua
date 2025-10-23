local GachaSubPanel = require("UI/SubPanel/GachaSubPanels/GachaSubPanelAct101")
local LimitedUpGachaSubPanel = class("LimitedUpGachaSubPanel", GachaSubPanel)
local desTxt = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(20393).m_mMessage

function LimitedUpGachaSubPanel:RefreshUI()
  LimitedUpGachaSubPanel.super.RefreshUI(self)
  self:RefreshUpTotalDraws()
end

function LimitedUpGachaSubPanel:RefreshUpTotalDraws()
  local specialGoodGroup = utils.changeCSArrayToLuaTable(self.m_gachaConfig.m_SpecialGoodsGroupID)
  if utils.isNull(self.m_btn_activity) and table.getn(specialGoodGroup) <= 2 and self.m_gachaConfig.m_ActId == 0 then
    return
  end
  local shopGoodsCfg = ShopManager:GetShopGoodsConfig(specialGoodGroup[2], specialGoodGroup[3])
  local goodsCfg = utils.changeCSArrayToLuaTable(shopGoodsCfg.m_Currency)
  local num = ItemManager:GetItemNum(goodsCfg[1])
  self.m_limit = not ShopManager:CheckHaveAnyStock(specialGoodGroup[1], specialGoodGroup[2], specialGoodGroup[3])
  UILuaHelper.SetActive(self.m_activity_mask, self.m_limit)
  local isShow = LocalDataManager:GetIntSimple("UpActivityReward" .. self.m_gachaConfig.m_GachaID, 0) == 0
  UILuaHelper.SetActive(self.m_activity_redpoint, num >= goodsCfg[2] and not self.m_limit and isShow)
  UILuaHelper.SetActive(self.m_txt_activity, not self.m_limit)
  UILuaHelper.SetActive(self.m_txt_activity2, self.m_limit)
  if self.m_limit then
    self.m_txt_activity2_Text.text = string.CS_Format(desTxt, num)
  else
    self.m_txt_activity_Text.text = tostring(num) .. "/" .. tostring(goodsCfg[2])
  end
end

function LimitedUpGachaSubPanel:OnBtnactivityClicked()
  local param = {
    gachaCfg = self.m_gachaConfig
  }
  if self.m_limit then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40058)
  else
    StackFlow:Push(UIDefines.ID_FORM_GACHAEXCHANGEPOP, param)
  end
end

function LimitedUpGachaSubPanel:OnActivePanel()
  LimitedUpGachaSubPanel.super.OnActivePanel(self)
  self:RemoveAllEventListeners()
  self:AddEventListeners()
end

function LimitedUpGachaSubPanel:OnHidePanel()
  LimitedUpGachaSubPanel.super.OnHidePanel(self)
  self:RemoveAllEventListeners()
end

function LimitedUpGachaSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_ShopSoldOut", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_ShopBuy", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Gacha_FreshGachaTab", handler(self, self.RefreshUI))
end

function LimitedUpGachaSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

return LimitedUpGachaSubPanel
