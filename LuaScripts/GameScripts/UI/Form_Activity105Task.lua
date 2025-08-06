local Form_Activity105Task = class("Form_Activity105Task", require("UI/UIFrames/Form_Activity105TaskUI"))

function Form_Activity105Task:SetInitParam(param)
end

function Form_Activity105Task:AfterInit()
  self.super.AfterInit(self)
  self.m_TaskListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "HeroActivity/UI105TaskItem")
end

function Form_Activity105Task:OnActive()
  self.super.OnActive(self)
end

function Form_Activity105Task:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity105Task:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity105Task:ShowItemListAnim()
  local ItemList = self.m_TaskListInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #ItemList
  for i, Item in ipairs(ItemList) do
    local tempObj = Item:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    self["ItemInitTimer" .. i] = TimeService:SetTimer(0.051 * (i - 1), 1, function()
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, "luoleilai_achievement_task_in")
    end)
  end
end

local fullscreen = true
ActiveLuaUI("Form_Activity105Task", Form_Activity105Task)
return Form_Activity105Task
