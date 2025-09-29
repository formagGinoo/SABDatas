local Form_110Achievement = class("Form_110Achievement", require("UI/UIFrames/Form_110AchievementUI"))

function Form_110Achievement:SetInitParam(param)
end

function Form_110Achievement:AfterInit()
  self.super.AfterInit(self)
  self.m_TaskListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "HeroActivity/UI110TaskItem")
  self.m_scrollView:SetActive(false)
end

function Form_110Achievement:OnActive()
  self.m_scrollView:SetActive(false)
  self.super.OnActive(self)
end

function Form_110Achievement:OnInactive()
  self.super.OnInactive(self)
end

function Form_110Achievement:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_110Achievement:CheckShowEnterAnim()
  TimeService:SetTimer(0.1, 1, function()
    self:ShowItemListAnim()
  end)
end

function Form_110Achievement:ShowItemListAnim()
  if utils.isNull(self.m_scrollView) then
    return
  end
  self.m_scrollView:SetActive(true)
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
ActiveLuaUI("Form_110Achievement", Form_110Achievement)
return Form_110Achievement
