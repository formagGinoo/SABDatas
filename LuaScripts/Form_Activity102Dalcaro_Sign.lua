local Form_Activity102Dalcaro_Sign = class("Form_Activity102Dalcaro_Sign", require("UI/UIFrames/Form_Activity102Dalcaro_SignUI"))

function Form_Activity102Dalcaro_Sign:SetInitParam(param)
end

function Form_Activity102Dalcaro_Sign:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity102Dalcaro_Sign:OnActive()
  self.super.OnActive(self)
  self:ShowItemListAnim()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(117)
end

function Form_Activity102Dalcaro_Sign:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity102Dalcaro_Sign:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity102Dalcaro_Sign:ShowItemListAnim()
  local ItemList = self.m_luaSignItemInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #ItemList
  for i, Item in ipairs(ItemList) do
    local tempObj = Item:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    self["ItemInitTimer" .. i] = TimeService:SetTimer(0.1 * (i - 1), 1, function()
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, "Dalcaro_Sign_m_pnl_list_item_in")
    end)
  end
end

function Form_Activity102Dalcaro_Sign:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity102Dalcaro_Sign", Form_Activity102Dalcaro_Sign)
return Form_Activity102Dalcaro_Sign
