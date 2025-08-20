local AnnouncementPushFaceSubPanelBase = require("UI/SubPanel/AnnouncementPushFaceSubPanelBase")
local AnnouncementPushFacePersonalRaidSubPanel = class("AnnouncementPushFacePersonalRaidSubPanel", AnnouncementPushFaceSubPanelBase)

function AnnouncementPushFacePersonalRaidSubPanel:OnFreshData()
  AnnouncementPushFacePersonalRaidSubPanel.super.OnFreshData(self)
end

function AnnouncementPushFacePersonalRaidSubPanel:UpdateLeftPanel()
  AnnouncementPushFacePersonalRaidSubPanel.super.UpdateLeftPanel(self)
  self.m_txt_titleLeft_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sTitle)
end

function AnnouncementPushFacePersonalRaidSubPanel:UpdateRightPanel()
  AnnouncementPushFacePersonalRaidSubPanel.super.UpdateRightPanel(self)
  self.m_txt_titleRight_Text.text = self.m_curAct:getLangText(self.m_pushFaceData.sTitle)
end

return AnnouncementPushFacePersonalRaidSubPanel
