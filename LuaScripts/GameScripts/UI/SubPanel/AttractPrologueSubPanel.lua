local UISubPanelBase = require("UI/Common/UISubPanelBase")
local AttractPrologueSubPanel = class("AttractPrologueSubPanel", UISubPanelBase)
local characterCampSubCfg = ConfigManager:GetConfigInsByName("CharacterCampSub")

function AttractPrologueSubPanel:OnInit()
end

function AttractPrologueSubPanel:OnFreshData()
  self.m_curShowHeroData = self.m_panelData.curShowHeroData
  self.m_stContentData = self.m_panelData.stContentData
  self.m_txt_name_Text.text = self.m_curShowHeroData.characterCfg.m_mFullName
  if self.m_stContentData.vBiography and self.m_stContentData.vBiography[1] then
    self.m_txt_biography_desc_Text.text = self.m_stContentData.vBiography[1].m_mText
  end
  local subCampInfo = characterCampSubCfg:GetValue_ByCampSubID(self.m_curShowHeroData.characterCfg.m_CampSubID)
  if subCampInfo and not subCampInfo:GetError() then
    self.m_txt_camp_Text.text = string.gsub(ConfigManager:GetCommonTextById(100208), "{0}", subCampInfo.m_mCampSubName)
    UILuaHelper.SetAtlasSprite(self.m_img_camp_icon_Image, subCampInfo.m_CampSubIcon)
    self.m_txt_camp_desc_Text.text = subCampInfo.m_mCampSubDesc
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_scrollview_camp)
  end
  local performanceID = self.m_curShowHeroData.characterCfg.m_PerformanceID[0]
  local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(self.m_img_head1_Image, szIcon)
  self:FreshRedDot()
end

function AttractPrologueSubPanel:FreshRedDot()
  self:FreshBiographyRedDot()
end

function AttractPrologueSubPanel:FreshBiographyRedDot()
  self.m_icon_new1:SetActive(false)
  self.m_img_red1:SetActive(false)
  local vBiography = self.m_stContentData.vBiography
  local vStoryIds = {}
  for k, v in ipairs(vBiography) do
    vStoryIds[#vStoryIds + 1] = v.m_StoryId
  end
  local redDot = false
  for k, v in ipairs(vStoryIds) do
    if AttractManager:CheckStoryNew(self.m_curShowHeroData.serverData.iHeroId, v) then
      redDot = true
      break
    end
  end
  if redDot then
    self.m_icon_new1:SetActive(true)
    return
  end
  for k, v in ipairs(vStoryIds) do
    if AttractManager:CanReceiveGift(self.m_curShowHeroData.serverData.iHeroId, v) then
      redDot = true
      break
    end
  end
  if redDot then
    self.m_img_red1:SetActive(true)
    return
  end
end

function AttractPrologueSubPanel:OnBtnbiographytouchClicked()
  self:broadcastEvent("eGameEvent_AttractBook_Change_Tab", AttractManager.BookType.Biography)
end

function AttractPrologueSubPanel:OnBtnvoicetouchClicked()
  self:broadcastEvent("eGameEvent_AttractBook_Change_Tab", AttractManager.BookType.Dialogue)
end

function AttractPrologueSubPanel:OnActivePanel()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, "ui_attract_panel_prologue_in")
end

return AttractPrologueSubPanel
