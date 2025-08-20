local AnnouncementPushFaceSubPanelBase = require("UI/SubPanel/AnnouncementPushFaceSubPanelBase")
local AnnouncementPushFaceGachaSubPanel = class("AnnouncementPushFaceGachaSubPanel", AnnouncementPushFaceSubPanelBase)
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function AnnouncementPushFaceGachaSubPanel:OnFreshData()
  AnnouncementPushFaceGachaSubPanel.super.OnFreshData(self)
end

function AnnouncementPushFaceGachaSubPanel:UpdateLeftPanel()
  AnnouncementPushFaceGachaSubPanel.super.UpdateLeftPanel(self)
  self.m_txt_subtitleLeft_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sActivityInfo)
  local heroId = self.m_pushFaceData.iCharacterId
  if heroId then
    local heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroId)
    if not heroCfg:GetError() then
      UILuaHelper.SetAtlasSprite(self.m_img_hero_ssrLeft_Image, QualityPathCfg[heroCfg.m_Quality].ssrImgPath)
      self.m_txt_heronameLeft_Text.text = heroCfg.m_mName
      local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
      if not careerCfg:GetError() then
        UILuaHelper.SetAtlasSprite(self.m_img_career_Image, careerCfg.m_CareerIcon)
      end
    end
  end
end

function AnnouncementPushFaceGachaSubPanel:UpdateRightPanel()
  AnnouncementPushFaceGachaSubPanel.super.UpdateRightPanel(self)
  self.m_txt_subtitleRight_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sActivityInfo)
  local heroId = self.m_pushFaceData.iCharacterId
  if heroId then
    local heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroId)
    if not heroCfg:GetError() then
      UILuaHelper.SetAtlasSprite(self.m_img_hero_ssrRight_Image, QualityPathCfg[heroCfg.m_Quality].ssrImgPath)
      self.m_txt_heronameRight_Text.text = heroCfg.m_mName
      local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCfg.m_Career)
      if not careerCfg:GetError() then
        UILuaHelper.SetAtlasSprite(self.m_img_career_Image, careerCfg.m_CareerIcon)
      end
    end
  end
end

return AnnouncementPushFaceGachaSubPanel
