local Form_ActivityMinigame108Task = class("Form_ActivityMinigame108Task", require("UI/UIFrames/Form_ActivityMinigame108TaskUI"))

function Form_ActivityMinigame108Task:SetInitParam(param)
end

function Form_ActivityMinigame108Task:AfterInit()
  self.super.AfterInit(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    self:CloseForm()
    return
  end
  self.main_id = tParam.main_id
  self.sub_id = tParam.sub_id
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClick)
  }
  self.m_luaTaskListInfinityGrid = self:CreateInfinityGrid(self.m_task_list_InfinityGrid, "ActivityMinigame108/Minigame108TaskItem", initGridData)
end

function Form_ActivityMinigame108Task:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:OnRefreshTaskList()
end

function Form_ActivityMinigame108Task:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_ActivityMinigame108Task:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_ActivityMinigame108Task:AddEventListeners()
  self:addEventListener("eGameEvent_ActTask_GetReward", function()
    self:OnRefreshTaskList()
  end)
end

function Form_ActivityMinigame108Task:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityMinigame108Task:OnRefreshTaskList()
  if self.m_luaTaskListInfinityGrid then
    local taskDataList = HeroActivityManager:GetWhackMoleTaskData(self.main_id, self.sub_id)
    self.m_luaTaskListInfinityGrid:ShowItemList(taskDataList)
    self.m_luaTaskListInfinityGrid:LocateTo(0)
  end
end

function Form_ActivityMinigame108Task:OnHeroItemClick()
end

function Form_ActivityMinigame108Task:OnBtnCloseClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_ActivityMinigame108Task", Form_ActivityMinigame108Task)
return Form_ActivityMinigame108Task
