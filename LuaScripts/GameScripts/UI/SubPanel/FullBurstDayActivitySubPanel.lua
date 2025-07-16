local UISubPanelBase = require("UI/Common/UISubPanelBase")
local FullBurstDayActivitySubPanel = class("FullBurstDayActivitySubPanel", UISubPanelBase)
local iMaxCount = 3

function FullBurstDayActivitySubPanel:OnInit()
  self:AddEventListeners()
end

function FullBurstDayActivitySubPanel:OnInActive()
end

function FullBurstDayActivitySubPanel:OnDestroy()
  FullBurstDayActivitySubPanel.super.OnDestroy(self)
end

function FullBurstDayActivitySubPanel:OnFreshData()
  self:RefreshUI()
end

function FullBurstDayActivitySubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_FullBurstDayUpdate", handler(self, self.OnFullBurstDayUpdate))
end

function FullBurstDayActivitySubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function FullBurstDayActivitySubPanel:OnFullBurstDayUpdate(stParam)
  self.m_parentLua:RefreshTableButtonList()
  if stParam == nil then
    return
  end
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
end

function FullBurstDayActivitySubPanel:killRemainTimer()
end

function FullBurstDayActivitySubPanel:RefreshUI()
  self.m_stActivity = self.m_panelData.activity
  if self.m_stActivity == nil then
    return
  end
end

return FullBurstDayActivitySubPanel
