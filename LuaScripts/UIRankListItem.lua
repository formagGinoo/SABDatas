local UIItemBase = require("UI/Common/UIItemBase")
local UIRankListItem = class("UIRankListItem", UIItemBase)

function UIRankListItem:OnInit()
  local c_circle_head = self.m_itemTemplateCache:GameObject("c_circle_head")
  self.playerHeadCom = self:createPlayerHead(c_circle_head)
end

function UIRankListItem:OnFreshData()
  local rankInfo = self.m_itemData
  rankInfo.stRoleId = {
    iUid = rankInfo.iRoleUid,
    iZoneId = rankInfo.iZoneId
  }
  self.playerHeadCom:SetPlayerHeadInfo(rankInfo)
  local iRank = rankInfo.iRank
  self.m_icon_rank1:SetActive(iRank == 1)
  self.m_icon_rank2:SetActive(iRank == 2)
  self.m_icon_rank3:SetActive(iRank == 3)
  self.m_icon_rank4:SetActive(4 <= iRank)
  self.m_z_txt_rank_st1:SetActive(iRank == 1)
  self.m_z_txt_rank_rd2:SetActive(iRank == 2)
  self.m_z_txt_rank_nd3:SetActive(iRank == 3)
  self.m_txt_rank_Text.text = iRank
  if iRank == 1 then
    self.m_txt_rank_Text.color = RankManager.ColorEnum.first
    self.m_img_bg_title_Image.color = RankManager.ColorEnum.first
  elseif iRank == 2 then
    self.m_txt_rank_Text.color = RankManager.ColorEnum.second
    self.m_img_bg_title_Image.color = RankManager.ColorEnum.second
  elseif iRank == 3 then
    self.m_txt_rank_Text.color = RankManager.ColorEnum.third
    self.m_img_bg_title_Image.color = RankManager.ColorEnum.third
  else
    self.m_txt_rank_Text.color = RankManager.ColorEnum.normal
  end
  self.m_img_bg_title:SetActive(iRank <= 3)
  self.m_img_bg_rank_Image.color = iRank <= 3 and RankManager.ColorEnum.firstbg or RankManager.ColorEnum.normalbg
  self.m_txt_name_Text.text = rankInfo.sName
  self.m_txt_guild_name_Text.text = rankInfo.sAllianceName ~= "" and rankInfo.sAllianceName or ConfigManager:GetCommonTextById(20111) or ""
  local valueType = GlobalRankManager.RankType2RankValueType[rankInfo.RankID]
  if valueType == GlobalRankManager.RankValueType.MainLevel then
    local level_id = rankInfo.iRankValue
    local MainLevelIns = ConfigManager:GetConfigInsByName("MainLevel")
    local levelCfg = MainLevelIns:GetValue_ByLevelID(level_id)
    if levelCfg:GetError() then
      log.error("获取困难关配置失败，无效的config_id：" .. tostring(level_id))
      return
    end
    self.m_txt_achievement_Text.text = levelCfg.m_LevelName
  elseif valueType == GlobalRankManager.RankValueType.FactionDevelopment then
    self.m_txt_achievement_Text.text = rankInfo.iRankValue
  elseif valueType == GlobalRankManager.RankValueType.Tower then
    self.m_txt_achievement_Text.text = LevelManager:GetLevelName(LevelManager.LevelType.Tower, rankInfo.iRankValue)
  end
  if valueType == GlobalRankManager.RankValueType.MainLevel or valueType == GlobalRankManager.RankValueType.Tower then
    self.m_icon_achievement:SetActive(true)
    self.m_icon_point:SetActive(false)
  else
    self.m_icon_achievement:SetActive(false)
    self.m_icon_point:SetActive(true)
  end
  self.m_img_sellist:SetActive(rankInfo.isSelect)
end

function UIRankListItem:RefreshItemFx(delay)
  UILuaHelper.SetCanvasGroupAlpha(self.m_itemRootObj, 0)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(delay)
  sequence:OnComplete(function()
    UILuaHelper.SetCanvasGroupAlpha(self.m_itemRootObj, 1)
    UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "RankListCharts_cellin")
  end)
  sequence:SetAutoKill(true)
end

function UIRankListItem:OnBtnimgrankitemClicked()
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
end

return UIRankListItem
