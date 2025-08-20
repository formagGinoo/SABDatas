local Form_Activity106Task = class("Form_Activity106Task", require("UI/UIFrames/Form_Activity106TaskUI"))

function Form_Activity106Task:SetInitParam(param)
end

function Form_Activity106Task:AfterInit()
  self.super.AfterInit(self)
  self.m_TaskListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "HeroActivity/UI106TaskItem")
end

function Form_Activity106Task:OnActive()
  self.super.OnActive(self)
end

function Form_Activity106Task:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity106Task:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity106Task:ShowItemListAnim()
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
ActiveLuaUI("Form_Activity106Task", Form_Activity106Task)
return Form_Activity106Task
