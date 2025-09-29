local UIItemBase = require("UI/Common/UIItemBase")
local UILevelUpOverItem = class("UILevelUpOverItem", UIItemBase)
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")

function UILevelUpOverItem:OnInit()
  self.m_pnl_r = self.m_itemRootObj.transform:Find("m_pnl_r").gameObject
  self.m_pnl_sr = self.m_itemRootObj.transform:Find("m_pnl_sr").gameObject
  self.m_pnl_ssr = self.m_itemRootObj.transform:Find("m_pnl_ssr").gameObject
  self.m_txt_level_limit = self.m_itemRootObj.transform:Find("m_txt_level_limit").gameObject
  self.m_txt_level_limit_Text = self.m_itemRootObj.transform:Find("m_txt_level_limit"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_level_before = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level").gameObject
  self.m_txt_level_before_Text = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_level_after = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level_up").gameObject
  self.m_txt_level_after_Text = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level_up"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_level_max = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level_up/m_txt_level_max").gameObject
  self.m_img_head = self.m_itemRootObj.transform:Find("pnl_head_mask/m_img_head").gameObject
  self.m_img_head_Image = self.m_itemRootObj.transform:Find("pnl_head_mask/m_img_head"):GetComponent(T_Image)
end

function UILevelUpOverItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function UILevelUpOverItem:SetItemInfo(itemData)
  local serverData = itemData.heroData.serverData
  local characterCfg = HeroManager:GetHeroConfigByID(serverData.iHeroId)
  local limitBreakTemplateID = characterCfg.m_Quality
  self.m_txt_level_after_Text.text = ConfigManager:GetCommonTextById(20386) .. serverData.iLevel
  ResourceUtil:CreateHeroIcon(self.m_img_head_Image, serverData.iHeroId)
  self.m_pnl_r:SetActive(limitBreakTemplateID == GlobalConfig.QUALITY_COMMON_ENUM.R)
  self.m_pnl_sr:SetActive(limitBreakTemplateID == GlobalConfig.QUALITY_COMMON_ENUM.SR)
  self.m_pnl_ssr:SetActive(limitBreakTemplateID == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
  self.m_txt_level_max:SetActive(false)
  self.m_txt_level_before:SetActive(false)
  self.m_img_arrow:SetActive(false)
  self.m_txt_level_after:SetActive(true)
  self.m_txt_level_limit:SetActive(false)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_itemRootObj)
end

return UILevelUpOverItem
