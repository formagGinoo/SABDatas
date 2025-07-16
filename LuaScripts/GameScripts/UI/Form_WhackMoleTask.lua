local Form_WhackMoleTask = class("Form_WhackMoleTask", require("UI/UIFrames/Form_WhackMoleTaskUI"))

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
  self:AddEventListeners()
  self.main_id = tParam.main_id
  self.sub_id = tParam.sub_id
  self:OnRefreshLevelData()
  self:OnRefreshLevelList()
end

function Form_WhackMoleTask:AddEventListeners()
  self:addEventListener("eGameEvent_ActTask_GetReward", handler(self, self.RefreshUI))
end

function Form_WhackMoleTask:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_WhackMoleTask:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_WhackMoleTask:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_WhackMoleTask:OnRefreshLevelData()
end

function Form_WhackMoleTask:OnRefreshLevelList()
  local taskDataList = HeroActivityManager:GetWhackMoleTaskData(self.main_id, self.sub_id)
  self.m_taskList_InfinityGrid:ShowItemList(taskDataList)
end

function Form_WhackMoleTask:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_WhackMoleTask:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleTask", Form_WhackMoleTask)
return Form_WhackMoleTask
