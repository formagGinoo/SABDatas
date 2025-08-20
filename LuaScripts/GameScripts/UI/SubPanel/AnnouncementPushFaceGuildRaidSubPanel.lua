local AnnouncementPushFaceSubPanelBase = require("UI/SubPanel/AnnouncementPushFaceSubPanelBase")
local AnnouncementPushFaceGuildRaidSubPanel = class("AnnouncementPushFaceGuildRaidSubPanel", AnnouncementPushFaceSubPanelBase)
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function AnnouncementPushFaceGuildRaidSubPanel:OnFreshData()
  AnnouncementPushFaceGuildRaidSubPanel.super.OnFreshData(self)
end

function AnnouncementPushFaceGuildRaidSubPanel:UpdateLeftPanel()
  AnnouncementPushFaceGuildRaidSubPanel.super.UpdateLeftPanel(self)
  self.m_txt_titleLeft_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sTitle)
  self.m_txt_subtitleLeft_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sSubTitle)
  local heroId = self.m_pushFaceData.iCharacterId
  if heroId then
    local heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroId)
    if not heroCfg:GetError() then
      UILuaHelper.SetAtlasSprite(self.m_img_hero_ssrLeft_Image, QualityPathCfg[heroCfg.m_Quality].ssrImgPath)
      self.m_txt_heronameLeft_Text.text = heroCfg.m_mName
      local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
      if not careerCfg:GetError() then
        UILuaHelper.SetAtlasSprite(self.m_img_careerLeft_Image, careerCfg.m_CareerIcon)
      end
    end
  end
end

function AnnouncementPushFaceGuildRaidSubPanel:UpdateRightPanel()
  AnnouncementPushFaceGuildRaidSubPanel.super.UpdateRightPanel(self)
  self.m_txt_titleRight_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sTitle)
  self.m_txt_subtitleRight_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sSubTitle)
  local heroId = self.m_pushFaceData.iCharacterId
  if heroId then
    local heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroId)
    if not heroCfg:GetError() then
      UILuaHelper.SetAtlasSprite(self.m_img_hero_ssrRight_Image, QualityPathCfg[heroCfg.m_Quality].ssrImgPath)
      self.m_txt_heronameRight_Text.text = heroCfg.m_mName
      local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
      if not careerCfg:GetError() then
        UILuaHelper.SetAtlasSprite(self.m_img_careerRight_Image, careerCfg.m_CareerIcon)
      end
    end
  end
end

return AnnouncementPushFaceGuildRaidSubPanel
