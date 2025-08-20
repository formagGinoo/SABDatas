local AnnouncementPushFaceSubPanelBase = require("UI/SubPanel/AnnouncementPushFaceSubPanelBase")
local AnnouncementPushFaceHuntingSubPanel = class("AnnouncementPushFaceHuntingSubPanel", AnnouncementPushFaceSubPanelBase)

function AnnouncementPushFaceHuntingSubPanel:OnFreshData()
  AnnouncementPushFaceHuntingSubPanel.super.OnFreshData(self)
end

function AnnouncementPushFaceHuntingSubPanel:UpdateLeftPanel()
  AnnouncementPushFaceHuntingSubPanel.super.UpdateLeftPanel(self)
  self.m_txt_titleLeft_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sTitle)
  self.m_txt_subtitleLeft_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sSubTitle)
end

function AnnouncementPushFaceHuntingSubPanel:UpdateRightPanel()
  AnnouncementPushFaceHuntingSubPanel.super.UpdateRightPanel(self)
  self.m_txt_titleRight_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sTitle)
  self.m_txt_subtitleRight_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sSubTitle)
end

return AnnouncementPushFaceHuntingSubPanel
