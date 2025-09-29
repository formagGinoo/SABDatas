local AnnouncementPushFaceSubPanelBase = require("UI/SubPanel/AnnouncementPushFaceSubPanelBase")
local AnnouncementPushFaceFashionSubPanel = class("AnnouncementPushFaceFashionSubPanel", AnnouncementPushFaceSubPanelBase)

function AnnouncementPushFaceFashionSubPanel:OnFreshData()
  AnnouncementPushFaceFashionSubPanel.super.OnFreshData(self)
end

function AnnouncementPushFaceFashionSubPanel:UpdateLeftPanel()
  AnnouncementPushFaceFashionSubPanel.super.UpdateLeftPanel(self)
  self.m_txt_titleLeft_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sTitle)
  self.m_txt_subtitleLeft_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sActivityInfo)
end

function AnnouncementPushFaceFashionSubPanel:UpdateRightPanel()
  AnnouncementPushFaceFashionSubPanel.super.UpdateRightPanel(self)
  self.m_txt_titleRight_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sTitle)
  self.m_txt_subtitleRight_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sActivityInfo)
end

return AnnouncementPushFaceFashionSubPanel
