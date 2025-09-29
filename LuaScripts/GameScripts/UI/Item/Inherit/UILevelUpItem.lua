local UIItemBase = require("UI/Common/UIItemBase")
local UILevelUpItem = class("UILevelUpItem", UIItemBase)
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")

function UILevelUpItem:OnInit()
  local button = self.m_itemRootObj:GetComponent("Button")
  button.onClick:RemoveAllListeners()
  button.onClick:AddListener(handler(self, self.OnBtnClick))
  self.m_pnl_r = self.m_itemRootObj.transform:Find("m_pnl_r").gameObject
  self.m_pnl_sr = self.m_itemRootObj.transform:Find("m_pnl_sr").gameObject
  self.m_pnl_ssr = self.m_itemRootObj.transform:Find("m_pnl_ssr").gameObject
  self.m_txt_level_limit = self.m_itemRootObj.transform:Find("m_txt_level_limit").gameObject
  self.m_txt_level_limit_Text = self.m_itemRootObj.transform:Find("m_txt_level_limit"):GetComponent(T_TextMeshProUGUI)
  self.lv_hor_node = self.m_itemRootObj.transform:Find("lv_hor_node")
  self.m_txt_level_before = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level").gameObject
  self.m_txt_level_before_Text = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_level_after = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level_up").gameObject
  self.m_txt_level_after_Text = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level_up"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_level_max = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level_up/m_txt_level_max").gameObject
  self.m_img_head = self.m_itemRootObj.transform:Find("pnl_head_mask/m_img_head").gameObject
  self.m_img_head_Image = self.m_itemRootObj.transform:Find("pnl_head_mask/m_img_head"):GetComponent(T_Image)
  self.m_txt_max_gray = self.m_itemRootObj.transform:Find("lv_hor_node/m_txt_level/m_txt_max_gray").gameObject
end

function UILevelUpItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function UILevelUpItem:SetItemInfo(itemData)
  local serverData = itemData.heroData.serverData
  local characterCfg = HeroManager:GetHeroConfigByID(serverData.iHeroId)
  local limitBreakTemplateID = characterCfg.m_Quality
  local iBreak = serverData.iBreak
  local allCharacterLimitBreaks = CharacterLimitBreakIns:GetValue_ByLimitBreakTemplate(limitBreakTemplateID)
  local canLevelUpByBreak = false
  for _, breakCfg in pairs(allCharacterLimitBreaks) do
    if breakCfg.m_LimitBreakLevel == iBreak then
      self.m_maxLevel = breakCfg.m_MaxLevel
    end
    if iBreak < breakCfg.m_LimitBreakLevel and breakCfg.m_MaxLevel > self.m_maxLevel then
      canLevelUpByBreak = true
    end
  end
  local beforeLv = serverData.iLevel
  local afterLv = 0
  self.m_txt_level_before_Text.text = ConfigManager:GetCommonTextById(20386) .. beforeLv
  if self.m_maxLevel ~= beforeLv then
    if beforeLv <= itemData.iLevel then
      afterLv = itemData.iLevel
    else
      afterLv = beforeLv
    end
  else
    afterLv = math.max(beforeLv, itemData.iLevel)
  end
  ResourceUtil:CreateHeroIcon(self.m_img_head_Image, serverData.iHeroId)
  self.m_pnl_r:SetActive(limitBreakTemplateID == GlobalConfig.QUALITY_COMMON_ENUM.R)
  self.m_pnl_sr:SetActive(limitBreakTemplateID == GlobalConfig.QUALITY_COMMON_ENUM.SR)
  self.m_pnl_ssr:SetActive(limitBreakTemplateID == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
  self.m_txt_level_max:SetActive(self.m_maxLevel == afterLv and beforeLv ~= afterLv)
  self.m_txt_max_gray:SetActive(self.m_maxLevel == afterLv and beforeLv == afterLv)
  if self.m_bom_btn_black then
    self.m_bom_btn_black:SetActive(beforeLv == afterLv)
  end
  self.m_txt_level_before:SetActive(true)
  self.m_img_arrow:SetActive(afterLv ~= beforeLv)
  self.m_txt_level_after:SetActive(afterLv ~= beforeLv)
  self.m_txt_level_after_Text.text = afterLv
  if canLevelUpByBreak and self.m_maxLevel == afterLv then
    self.m_txt_level_limit:SetActive(true)
    local maxPossibleLevel = 0
    for _, breakCfg in pairs(allCharacterLimitBreaks) do
      if maxPossibleLevel < breakCfg.m_MaxLevel then
        maxPossibleLevel = breakCfg.m_MaxLevel
      end
    end
    local isMaxLevel = maxPossibleLevel <= self.m_maxLevel
    if isMaxLevel then
      self.m_txt_level_limit_Text.text = ConfigManager:GetCommonTextById(20385)
    else
      self.m_txt_level_limit_Text.text = ConfigManager:GetCommonTextById(20384)
    end
  else
    self.m_txt_level_limit:SetActive(self.m_maxLevel == afterLv)
    self.m_txt_level_limit_Text.text = ConfigManager:GetCommonTextById(20385)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.lv_hor_node)
end

function UILevelUpItem:OnBtnClick()
  StackFlow:Push(UIDefines.ID_FORM_HEROUPGRADE, {
    heroDataList = {
      self.m_itemData.heroData
    },
    heroID = self.m_itemData.heroData.serverData.iHeroId
  })
end

return UILevelUpItem
