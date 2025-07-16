local UIItemBase = require("UI/Common/UIItemBase")
local UIActBuffHeroItem = class("UIActBuffHeroItem", UIItemBase)

function UIActBuffHeroItem:OnInit()
  self.m_HeroIcon = self:createHeroIcon(self.m_itemRootObj)
  self.m_HeroIcon:SetHeroIconClickCB(function()
    self:OnHeroItemClick()
  end)
  self.m_c_txt_lv_num_Text = self.m_itemTemplateCache:TMPPro("c_txt_lv_num")
  self.m_canvasgroup = self.m_itemRootObj:GetComponent("CanvasGroup")
end

function UIActBuffHeroItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_HeroIcon:SetHeroData(self.m_itemData.serverData, false)
  self.m_HeroIcon:FreshBreak(0)
  self.m_txt_bonus_Text.text = self.m_itemData.bonus_config.m_Rate .. "%"
  local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
  local heroCfg = CharacterInfoIns:GetValue_ByHeroID(self.m_itemData.bonus_config.m_Character)
  if heroCfg:GetError() then
    log.error("HeroIcon heroCfgID Cannot Find Check Config: " .. self.m_itemData.bonus_config.m_Character)
    return
  end
  self.m_c_txt_lv_num_Text.text = heroCfg.m_mShortname
  self.m_NotOwned:SetActive(not self.m_itemData.is_owned)
  self.m_bg_bonus:SetActive(true)
  self.m_canvasgroup.alpha = self.m_itemData.is_owned and 1 or 0.5
end

function UIActBuffHeroItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
end

return UIActBuffHeroItem
