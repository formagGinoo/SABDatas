local UIItemBase = require("UI/Common/UIItemBase")
local UIGuildBossItem = class("UIGuildBossItem", UIItemBase)

function UIGuildBossItem:OnInit()
end

function UIGuildBossItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function UIGuildBossItem:SetItemInfo(itemData)
  local cfg = itemData.bossCfg
  local levelCfg = itemData.levelCfg
  local serverData = itemData.serverData
  local maxHp = itemData.maxHp
  ResourceUtil:CreateGuildBossIconByName(self.m_img_bosshead_Image, cfg.m_Avatar)
  self.m_txt_bosslevel_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100074), levelCfg.m_BossLevel)
  if serverData then
    if serverData.bKill then
      self.m_bg_pass:SetActive(true)
      self.m_img_slider_Image.fillAmount = 0
    else
      self.m_img_slider_Image.fillAmount = serverData.iBossHp / maxHp
      self.m_bg_pass:SetActive(false)
    end
  else
    self.m_img_slider_Image.fillAmount = 1
    self.m_bg_pass:SetActive(false)
  end
  self.m_img_border_nml:SetActive(itemData.is_selected ~= true)
  self.m_bg_item_sel:SetActive(itemData.is_selected or false)
  self.m_img_border_sel:SetActive(itemData.is_selected or false)
end

function UIGuildBossItem:OnChooseItem(flag)
  self.m_itemData.is_selected = flag
  self.m_bg_item_sel:SetActive(flag)
  self.m_img_border_sel:SetActive(flag)
  self.m_img_border_nml:SetActive(not flag)
end

return UIGuildBossItem
