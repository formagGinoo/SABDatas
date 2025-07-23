local Form_WhackMoleTask = class("Form_WhackMoleTask", require("UI/UIFrames/Form_WhackMoleTaskUI"))
local Form_In = "whackmole_task_in"
local Form_Out = "whackmole_task_out"

function Form_WhackMoleTask:SetInitParam(param)
end

function Form_WhackMoleTask:AfterInit()
  self.super.AfterInit(self)
  self.m_taskList_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_task_list_InfinityGrid, "WhackMole/UIWhackMoleTaskItem")
end

function Form_WhackMoleTask:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, Form_In)
  self:AddEventListeners()
  self.main_id = tParam.main_id
  self.sub_id = tParam.sub_id
  self:OnRefreshLevelList()
end

function Form_WhackMoleTask:AddEventListeners()
  self:addEventListener("eGameEvent_ActTask_GetReward", function()
    self:OnRefreshLevelList()
  end)
end

function Form_WhackMoleTask:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_WhackMoleTask:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_WhackMoleTask:OnRefreshLevelList()
  if self.m_taskList_InfinityGrid then
    local taskDataList = HeroActivityManager:GetWhackMoleTaskData(self.main_id, self.sub_id)
    self.m_taskList_InfinityGrid:ShowItemList(taskDataList)
    self.m_taskList_InfinityGrid:LocateTo(0)
  end
end

function Form_WhackMoleTask:OnBtnCloseClicked()
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, Form_Out)
  self:CloseForm()
end

function Form_WhackMoleTask:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleTask", Form_WhackMoleTask)
return Form_WhackMoleTask
