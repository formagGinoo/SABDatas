local UIItemBase = require("UI/Common/UIItemBase")
local UIGuildListItem = class("UIGuildListItem", UIItemBase)

function UIGuildListItem:OnInit()
  self.m_imgLogo = self.m_itemRootObj.transform:Find("c_img_logo"):GetComponent(T_Image)
  self.m_txtLvText = self.m_itemRootObj.transform:Find("bg_lv/c_txt_lv"):GetComponent(T_TextMeshProUGUI)
  self.m_txtGuildNameText = self.m_itemRootObj.transform:Find("c_txt_guild_name"):GetComponent(T_TextMeshProUGUI)
  self.m_txtMbText = self.m_itemRootObj.transform:Find("c_txt_mb"):GetComponent(T_TextMeshProUGUI)
  self.m_iconRankObj = self.m_itemRootObj.transform:Find("c_icon_rank").gameObject
  self.m_tagApplyObj = self.m_itemRootObj.transform:Find("c_tag_apply").gameObject
  self.m_txtUidText = self.m_itemRootObj.transform:Find("c_txt_guild_uid"):GetComponent(T_TextMeshProUGUI)
  self.m_iconRankImg = self.m_iconRankObj:GetComponent(T_Image)
  self.m_txt_rank_Text = self.m_itemRootObj.transform:Find("c_icon_rank/c_txt_rank"):GetComponent(T_TextMeshProUGUI)
  self.m_formatStr = ConfigManager:GetCommonTextById(20048)
  self.m_formatStr2 = ConfigManager:GetCommonTextById(20033)
end

function UIGuildListItem:OnFreshData()
  self:SetItemInfo(self.m_itemData)
end

function UIGuildListItem:SetItemInfo(itemData)
  local guildLvCfg = GuildManager:GetGuildLevelConfigByLv(itemData.iLevel) or {}
  self.m_txtLvText.text = string.format(self.m_formatStr2, tostring(itemData.iLevel))
  self.m_txtGuildNameText.text = itemData.sName
  self.m_txtMbText.text = string.format(self.m_formatStr, itemData.iCurrMemberCount, guildLvCfg.m_Member)
  ResourceUtil:CreateGuildIconById(self.m_imgLogo, itemData.iBadgeId)
  self.m_tagApplyObj:SetActive(GuildManager:IsInApplyList(itemData.iAllianceId))
  self.m_iconRankObj:SetActive(false)
  self.m_txtUidText.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100053), itemData.iAllianceId)
  local isRankActive = GuildManager:IsGuildRankDataActive(itemData)
  self.m_iconRankObj:SetActive(isRankActive)
  if isRankActive then
    local grade = GuildManager:GetGuildBossGradeByRank(itemData.iLastBattleRank, itemData.iLastBattleRankCount)
    ResourceUtil:CreateGuildGradeIconById(self.m_iconRankImg, grade)
    local gradeCfg = GuildManager:GetGuildBattleGradeCfgByID(grade)
    self.m_txt_rank_Text.text = gradeCfg.m_mGradeName
  end
end

return UIGuildListItem
