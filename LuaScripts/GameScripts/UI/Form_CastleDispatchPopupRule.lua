local Form_CastleDispatchPopupRule = class("Form_CastleDispatchPopupRule", require("UI/UIFrames/Form_CastleDispatchPopupRuleUI"))

function Form_CastleDispatchPopupRule:SetInitParam(param)
end

function Form_CastleDispatchPopupRule:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_listInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_dispatch_list_InfinityGrid, "Dispatch/UIDispatchRateItem", initGridData)
end

function Form_CastleDispatchPopupRule:OnActive()
  self.super.OnActive(self)
  local dispatchList = CastleDispatchManager:GetDispatchEventByLevel()
  self.m_listInfinityGrid:ShowItemList(dispatchList)
  self:AddEventListeners()
end

function Form_CastleDispatchPopupRule:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_CastleDispatchPopupRule:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_CastleDispatchPopupRule:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CastleDispatchPopupRule:OnItemClk()
end

function Form_CastleDispatchPopupRule:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_CastleDispatchPopupRule:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_CastleDispatchPopupRule:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleDispatchPopupRule:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleDispatchPopupRule", Form_CastleDispatchPopupRule)
return Form_CastleDispatchPopupRule
