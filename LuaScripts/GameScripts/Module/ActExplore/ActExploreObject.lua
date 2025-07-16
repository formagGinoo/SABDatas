local ActExploreObject = class("ActExploreObject")

function ActExploreObject:Init(objectID, entityID, UID)
  self.objectID = objectID
  self.entityID = entityID
  self.UID = UID
  self.taskList = {}
end

function ActExploreObject:OnLoadFinish(world, obj)
  self.gameObject = obj
  self.animator = obj:GetComponentInChildren(T_Animator)
  local name = obj.name .. self.objectID .. "|" .. (self.entityID or 0)
  if self.element ~= nil then
    name = name .. "_" .. self.element.m_ID
  end
  obj.name = name
  local taskCount = #self.taskList
  for i = taskCount, 1, -1 do
    local task = self.taskList[i]
    if task.OnCreate then
      task:OnCreate(world, self)
    end
    if not task.Update then
      table.remove(self.taskList, i)
    end
  end
end

function ActExploreObject:AddTask(world, task)
  if self.gameObject and task.OnCreate then
    task:OnCreate(world, self)
  end
  if not self.gameObject or task.Update then
    table.insert(self.taskList, 1, task)
  end
end

function ActExploreObject:Update(world, dt)
  if not self.gameObject then
    return
  end
  local taskCount = #self.taskList
  for i = taskCount, 1, -1 do
    local task = self.taskList[i]
    if not task:Update(world, self, dt) then
      table.remove(self.taskList, i)
    end
  end
end

function ActExploreObject:Desteroy()
  if self.gameObject then
    local exploreManager = CS.VisualActExploreManager.Instance
    exploreManager:ReleaseGameObject(self.objectID)
    self.gameObject = nil
  end
  self.element = nil
  self.animator = nil
  if self.navMeshAgent ~= nil then
    GameObject.Destroy(self.navMeshAgent)
    self.navMeshAgent = nil
  end
  if self.playerController ~= nil then
    GameObject.Destroy(self.playerController)
    self.playerController = nil
  end
  if self.navMeshObstacle ~= nil then
    GameObject.Destroy(self.navMeshObstacle)
    self.navMeshObstacle = nil
  end
  if self.playerInteractive ~= nil then
    GameObject.Destroy(self.playerInteractive)
    self.playerInteractive = nil
  end
end

return ActExploreObject
