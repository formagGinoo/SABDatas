local Form_ActivityEventCalendarPop = class("Form_ActivityEventCalendarPop", require("UI/UIFrames/Form_ActivityEventCalendarPopUI"))

function Form_ActivityEventCalendarPop:SetInitParam(param)
end

function Form_ActivityEventCalendarPop:AfterInit()
  self.super.AfterInit(self)
  self.m_PreviewInfinity = self:CreateInfinityGrid(self.m_pnl_preview_InfinityGrid, "ActivityPreview/ActivityNextPreviewItem")
end

function Form_ActivityEventCalendarPop:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:FreshUI()
end

function Form_ActivityEventCalendarPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityEventCalendarPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityEventCalendarPop:InitData()
  local tParam = self.m_csui.m_param
  if tParam then
    local activity = tParam.activity
    if not activity then
      self:CloseForm()
      return
    end
    local mUpcoming = activity:GetUpcomingPreviewList()
    local t = {}
    for _, value in pairs(mUpcoming) do
      table.insert(t, value)
    end
    table.sort(t, function(a, b)
      return a.iId < b.iId
    end)
    self.vUpcoming = t
    tParam = nil
  end
end

function Form_ActivityEventCalendarPop:FreshUI()
  self.m_PreviewInfinity:ShowItemList(self.vUpcoming)
end

function Form_ActivityEventCalendarPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityEventCalendarPop", Form_ActivityEventCalendarPop)
return Form_ActivityEventCalendarPop
