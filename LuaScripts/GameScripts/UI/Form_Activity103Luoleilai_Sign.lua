local Form_Activity103Luoleilai_Sign = class("Form_Activity103Luoleilai_Sign", require("UI/UIFrames/Form_Activity103Luoleilai_SignUI"))

function Form_Activity103Luoleilai_Sign:SetInitParam(param)
end

function Form_Activity103Luoleilai_Sign:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnSignItemClick)
  }
  self.m_luaSignItemInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "HeroActivity/UIAct103SignItem", initGridData)
end

function Form_Activity103Luoleilai_Sign:OnActive()
  self.super.OnActive(self)
end

function Form_Activity103Luoleilai_Sign:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity103Luoleilai_Sign:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity103Luoleilai_Sign:OnSignItemClick(index, go)
  local server_data = self.sign_data[index].server_data
  local can_get = server_data.iAwardedMaxDays < server_data.iLoginDays and index <= server_data.iLoginDays
  if can_get then
    HeroActivityManager:RequestRecReward(self.act_id)
    return
  end
end

function Form_Activity103Luoleilai_Sign:ShowItemListAnim()
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

function Form_Activity103Luoleilai_Sign:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity103Luoleilai_Sign", Form_Activity103Luoleilai_Sign)
return Form_Activity103Luoleilai_Sign
