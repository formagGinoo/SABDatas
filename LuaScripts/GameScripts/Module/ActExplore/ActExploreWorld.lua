require("Module/ActExplore/ActExploreTask")
local ActExploreWorld = class("ActExploreWorld")
local eventHandlers
local entityObjectClass = require("Module/ActExplore/ActExploreObject")
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function ActExploreWorld:ctor(onLoadFinish)
  self.onLoadFinish = onLoadFinish
  self.pickableObjects = {}
  self.objectIDIndex = 0
  self.objects = {}
  self.delayDestroy = {}
  self:RegisterEventHandler()
end

function ActExploreWorld:GenObjectID()
  self.objectIDIndex = self.objectIDIndex + 1
  return self.objectIDIndex
end

function ActExploreWorld:RegisterEventHandler()
  if eventHandlers == nil then
    eventHandlers = {}
    self:AddEventHandler("AttachEventHandler")
    self:AddEventHandler("BlackScreenEventHandler")
    self:AddEventHandler("CounterChangeEventHandler")
    self:AddEventHandler("CreateInteractiveEventHandler")
    self:AddEventHandler("DestroyEventHandler")
    self:AddEventHandler("InteroperabilityHandler")
    self:AddEventHandler("MoveStateEventHandler")
    self:AddEventHandler("PlayAnimatorStateEventHandler")
    self:AddEventHandler("PlayEffectEventHandler")
    self:AddEventHandler("PlayPlotEventHandler")
    self:AddEventHandler("PlaySoundEventHandler")
    self:AddEventHandler("PopMessageEventHandler")
    self:AddEventHandler("SetIconEventHandler")
    self:AddEventHandler("SetMoveObstacleHandler")
    self:AddEventHandler("StateChangeEventHandler")
    self:AddEventHandler("TakeRewardEventHandler")
    self:AddEventHandler("TransformEventHandler")
    self:AddEventHandler("TeleportPlayerEventHandler")
  end
end

function ActExploreWorld:AddEventHandler(path)
  local handler = require("Module/ActExplore/EventHandler/" .. path)
  eventHandlers[handler.EvnetTypeID.value__] = handler
end

function ActExploreWorld:Init()
  self.exploreManager = CS.VisualActExploreManager.Instance
  self.sceneConfig = self.exploreManager.Config
  self.exploreManager.SceneSDF.AgentRadius = 0
  self.exploreManager.System:SetEventHandler(handler(self, self.OnEvent))
  self.exploreManager:SetGameObjectLoadedHandler(handler(self, self.OnGameObjectLoadFinish))
  self.timerID = TimeService:SetTimer(0, -1, handler(self, self.OnUpdate))
  self:InitCreate()
  self.exploreManager.System:Update(0)
  for k, v in pairs(self.objects) do
    if v.enable then
      self:DoEntityLoad(v)
    end
  end
end

function ActExploreWorld:DoEntityLoad(entity)
  if entity.resData == nil then
    return false
  end
  local resData = entity.resData
  entity.resData = nil
  if resData.Prefab ~= nil then
    self.exploreManager:LoadGameObject(entity.objectID, resData.Prefab)
    return true
  elseif resData.PerformanceID ~= nil then
    self.exploreManager:LoadByPerformance(entity.objectID, resData.PerformanceID)
    return true
  end
end

function ActExploreWorld:FindObjectByEntityID(entityID)
  for _, v in pairs(self.objects) do
    if v.entityID == entityID then
      return v
    end
  end
  return nil
end

function ActExploreWorld:FindObjectByUID(UID)
  for _, v in pairs(self.objects) do
    if v.UID == UID then
      return v
    end
  end
  return nil
end

function ActExploreWorld:FindObject(objectID)
  return self.objects[objectID]
end

function ActExploreWorld:OnUpdate()
  local dt = CS.UnityEngine.Time.deltaTime
  for _, v in pairs(self.objects) do
    v:Update(self, dt)
  end
  local count = #self.delayDestroy
  for i = count, 1, -1 do
    local item = self.delayDestroy[i]
    item.time = item.time - dt
    if item.time <= 0 then
      table.remove(self.delayDestroy, i)
      local entity = self.objects[item.objectID]
      if entity ~= nil then
        if entity.UID then
          self.exploreManager.SceneSDF:RemoveObstacle(entity.UID, false)
        end
        self.objects[item.objectID] = nil
        if self.player == entity then
          self.player = nil
        end
        if self.player ~= nil then
          self.player:AddTask(self, ActExploreTask.InteractiveChange.new(entity.objectID, 3))
        end
        self.form:SetIcon(entity.gameObject, nil)
        self.form:OnInteractiveDestroy(entity.objectID)
        entity:Desteroy()
        if entity.PerformanceID ~= nil then
          local using = false
          for _, v in pairs(self.objects) do
            if v.PerformanceID == entity.PerformanceID then
              using = true
              break
            end
          end
          if not using then
            self.exploreManager:UnloadPerformance(entity.PerformanceID)
          end
        end
      end
    end
  end
end

function ActExploreWorld:OnEvent(event)
  local typeId = event.EventType
  local handler = eventHandlers[typeId]
  if handler == nil then
    log.error("活动探索事件缺少处理函数 ： " .. event:GetType().Name)
  end
  local entityObj
  if event.EntityID ~= 0 then
    entityObj = self:FindObjectByEntityID(event.EntityID)
  end
  handler.OnEvent(self, entityObj, event)
end

function ActExploreWorld:OnGameObjectLoadFinish(key, obj)
  if self.loadingCount > 0 and self.loadedCount ~= nil then
    self.loadedCount = self.loadedCount + 1
    if self.loadingCount <= self.loadedCount then
      self.exploreManager:ApplySceneSetting()
      self.loadedCount = nil
      self:UpdatePickUpAmount()
      TimeService:SetTimer(0.5, 1, handler(self, self.OnLoadFinished))
    end
  end
  local entity = self.objects[key]
  if entity ~= nil then
    entity:OnLoadFinish(self, obj)
    if entity.element ~= nil and entity.element.m_InteractivityType == 3 then
      self.form:SetInteractiveText(entity.gameObject, entity.objectID, entity.element)
    end
    return true
  end
  return false
end

function ActExploreWorld:OnLoadFinished()
  self.onLoadFinish()
  self.onLoadFinish = nil
  StackTop:DestroyUI(UIDefines.ID_FORM_GAMESCENELOADING)
end

function ActExploreWorld:InitCreate()
  local system = self.exploreManager.System
  self.loadingCount = 0
  self.loadedCount = 0
  local playerCfg = self.sceneConfig.Player
  local playerEntityID = system:CreateEntity(CS.LogicActExplore.ActExploreEntityType.Player)
  local pos = playerCfg.Transform.Position
  local rot = playerCfg.Transform.Rotation
  local playerData = self.synchronizer:GetData(0)
  if playerData ~= nil then
    pos = playerData.position
    rot = playerData.rotation
  else
    self.synchronizer:OnObjectCreate(0, 0)
    self.synchronizer:SetObjectTransform(0, pos, rot)
  end
  system:SetEntityTransform(playerEntityID, pos, rot, true)
  local player = entityObjectClass.new()
  player:Init(self:GenObjectID(), playerEntityID, 0)
  self.objects[player.objectID] = player
  self.player = player
  self.loadingCount = 1
  self.exploreManager:LoadByPerformance(player.objectID, playerCfg.PerformanceID)
  player.PerformanceID = playerCfg.PerformanceID
  player:AddTask(self, ActExploreTask.Player.new(playerCfg))
  local cameraAimPoint = CS.UnityEngine.GameObject.Find("AimPoint")
  if cameraAimPoint then
    cameraAimPoint.transform:SetPositionAndRotation(pos, rot)
    player:AddTask(self, ActExploreTask.CameraFollow.new())
    self.aimFollow = cameraAimPoint:GetComponent("Follow")
  end
  local cameraGroup = CS.UnityEngine.GameObject.Find("CameraGroup")
  self.cameraGroup = {}
  local cameras = cameraGroup:GetComponentsInChildren(typeof(CS.Cinemachine.CinemachineVirtualCameraBase), true)
  for i = 0, cameras.Length - 1 do
    local camera = cameras[i]
    self.cameraGroup[camera.Name] = camera
  end
  self:SwitchCamera(nil)
  local walkTargetEffectID = system:CreateEntity(CS.LogicActExplore.ActExploreEntityType.Effect)
  self.walkTargetEffect = entityObjectClass.new()
  self.walkTargetEffect:Init(self:GenObjectID(), walkTargetEffectID, 0)
  self.objects[self.walkTargetEffect.objectID] = self.walkTargetEffect
  self.loadingCount = self.loadingCount + 1
  self.exploreManager:LoadGameObject(self.walkTargetEffect.objectID, ActExploreRes.WalkTarget)
  self.walkTargetEffect:AddTask(self, ActExploreTask.Active.new(false))
  local targetEffectID = system:CreateEntity(CS.LogicActExplore.ActExploreEntityType.Effect)
  self.targetEffect = entityObjectClass.new()
  self.targetEffect:Init(self:GenObjectID(), targetEffectID, 0)
  self.objects[self.targetEffect.objectID] = self.targetEffect
  self.loadingCount = self.loadingCount + 1
  self.exploreManager:LoadGameObject(self.targetEffect.objectID, ActExploreRes.SelectEffect)
  self.targetEffect:AddTask(self, ActExploreTask.Active.new(false))
  local interactives = self.sceneConfig.Interactives
  local interactiveCount = interactives.Count
  for i = 0, interactiveCount - 1 do
    local cfg = interactives[i]
    local element = CS.CData_ActExploreInteractive.GetInstance():GetValue_ByID(cfg.ID)
    local serverData = self.synchronizer:GetData(cfg.UID)
    if not element:GetError() and self:CheckInteractiveIsUnlock(element) then
      if element.m_Pickable == 1 then
        self.pickableObjects[cfg.UID] = false
      end
      if serverData == nil or 0 <= serverData.state then
        local interactEntityID = system:CreateEntity(CS.LogicActExplore.ActExploreEntityType.Interact)
        system:SetEntityTransform(interactEntityID, cfg.Transform.Position, cfg.Transform.Rotation, true)
        local interact = entityObjectClass.new()
        interact:Init(self:GenObjectID(), interactEntityID, cfg.UID)
        interact.element = element
        interact.sceneCfg = cfg
        interact.Interoperability = true
        if serverData == nil then
          self.synchronizer:OnObjectCreate(cfg.UID, cfg.ID)
          if element.m_Pickable == 1 then
            self.newPickableAdd = true
          end
        end
        if element.m_Pickable == 1 then
          self.pickableObjects[cfg.UID] = true
        end
        self.objects[interact.objectID] = interact
        interact.enable = true
        if element.m_Prefab ~= "" then
          interact.resData = {
            Prefab = element.m_Prefab
          }
        elseif element.m_PresentationID ~= 0 then
          interact.resData = {
            PerformanceID = element.m_PresentationID
          }
          interact.PerformanceID = element.m_PresentationID
        else
          self.exploreManager:CreateEmptyGameObject(interact.objectID)
        end
        if element.m_Script ~= "" then
          system:LoadStateScript(interactEntityID, element.m_Script)
        end
        local destroyTime = TimeUtil:TimeStringToTimeSec2(element.m_DestroyTime) or 0
        if 0 < destroyTime then
          interact:AddTask(self, ActExploreTask.DelayDestroy.new(destroyTime))
        end
        if cfg.HasObstacle then
          self.exploreManager.SceneSDF:AddByInteractiveConfig(cfg)
        end
        if 0 < cfg.InteractiveRadius and 0 < element.m_InteractivityType and element.m_InteractivityType < 3 then
          player:AddTask(self, ActExploreTask.InteractiveChange.new(interact.objectID, 0, cfg.Transform.Position, CS.VisualActExploreUtil.Rotate(cfg.Transform, cfg.Center), cfg.InteractiveRadius, element.m_InteractivityType == 1))
        end
        if serverData ~= nil then
          for k, v in pairs(serverData.counters) do
            system:SetCounter(interactEntityID, k, v, false)
          end
        end
      end
    end
  end
  self:CreateDynamicInteractiveByServer()
end

function ActExploreWorld:CreateDynamicInteractiveByServer()
  local objectDatas = self.synchronizer.objectData
  if objectDatas == nil or next(objectDatas) == nil then
    return
  end
  local system = self.exploreManager.System
  for k, v in pairs(objectDatas) do
    if k < 0 then
      local element = CS.CData_ActExploreInteractive.GetInstance():GetValue_ByID(v.cfgID)
      if not element:GetError() then
        if element.m_Pickable == 1 then
          self.pickableObjects[k] = false
        end
        if 0 <= v.state then
          local interactEntityID = system:CreateEntity(CS.LogicActExplore.ActExploreEntityType.Interact)
          local interact = entityObjectClass.new()
          interact:Init(self:GenObjectID(), interactEntityID, k)
          interact.element = element
          self.objects[interact.objectID] = interact
          system:SetEntityTransform(interactEntityID, v.position, v.rotation, true)
          if element.m_Prefab ~= "" then
            self.exploreManager:LoadGameObject(interact.objectID, element.m_Prefab)
          elseif element.m_PresentationID ~= 0 then
            self.exploreManager:LoadByPerformance(interact.objectID, element.m_PresentationID)
          else
            self.exploreManager:CreateEmptyGameObject(interact.objectID)
          end
          if element.m_Pickable == 1 then
            self.pickableObjects[k] = true
          end
          self.player:AddTask(self, ActExploreTask.InteractiveChange.new(interact.objectID, 0, v.position, v.rotation, element.m_InteractivityRange, element.m_InteractivityType == 1))
          local destroyTime = TimeUtil:TimeStringToTimeSec2(element.m_DestroyTime) or 0
          if 0 < destroyTime then
            interact:AddTask(self, ActExploreTask.DelayDestroy.new(destroyTime))
          end
          for name, value in pairs(v.counters) do
            system:SetCounter(interactEntityID, name, value, false)
          end
        end
      end
    end
  end
end

function ActExploreWorld:CreateDynamicInteractive(ownerEntity, id, flyDuration)
  local element = CS.CData_ActExploreInteractive.GetInstance():GetValue_ByID(id)
  if element:GetError() then
    return
  end
  local system = self.exploreManager.System
  local interactEntityID = system:CreateEntity(CS.LogicActExplore.ActExploreEntityType.Interact)
  local uid = -ownerEntity.UID
  local interact = entityObjectClass.new()
  interact:Init(self:GenObjectID(), interactEntityID, uid)
  interact.element = element
  self.objects[interact.objectID] = interact
  self.synchronizer:OnObjectCreate(uid, id)
  if element.m_Prefab ~= "" then
    self.exploreManager:LoadGameObject(interact.objectID, element.m_Prefab)
  elseif element.m_PresentationID ~= 0 then
    self.exploreManager:LoadByPerformance(interact.objectID, element.m_PresentationID)
  else
    self.exploreManager:CreateEmptyGameObject(interact.objectID)
  end
  if element.m_Pickable == 1 then
    self.pickableObjects[uid] = true
    self:UpdatePickUpAmount()
  end
  if element.m_Script ~= "" then
    system:LoadStateScript(interactEntityID, element.m_Script)
  end
  local curve = ownerEntity.sceneCfg.Path
  if curve ~= nil and curve:IsValid() then
    interact:AddTask(self, ActExploreTask.CurveFlyTask.new(curve, flyDuration))
    local pos = curve:EvaluatePosition(1)
    self.synchronizer:SetObjectTransform(uid, pos, CS.UnityEngine.Quaternion.identity)
  else
    interact:AddTask(self, ActExploreTask.Transform.new(ownerEntity.sceneCfg.Transform.Position, CS.UnityEngine.Quaternion.identity))
    self.player:AddTask(self, ActExploreTask.InteractiveChange.new(interact.objectID, 0, ownerEntity.sceneCfg.Transform.Position, nil, element.m_InteractivityRange, element.m_InteractivityType == 1))
    self.synchronizer:SetObjectTransform(uid, ownerEntity.sceneCfg.Transform.Position, ownerEntity.sceneCfg.Transform.Rotation)
    self.synchronizer:SyncToServer()
  end
  local destroyTime = TimeUtil:TimeStringToTimeSec2(element.m_DestroyTime) or 0
  if 0 < destroyTime then
    interact:AddTask(self, ActExploreTask.DelayDestroy.new(destroyTime))
  end
end

function ActExploreWorld:CreateEffectObject(entityID, effectName)
  local effect = entityObjectClass.new()
  effect.IsEffect = true
  effect:Init(self:GenObjectID(), entityID, 0)
  self.objects[effect.objectID] = effect
  self.exploreManager:LoadGameObject(effect.objectID, effectName)
  return effect
end

function ActExploreWorld:OnInteractiveChange(preId, id)
  local preEntity = self:FindObject(preId)
  if preEntity then
  end
  local entity = self:FindObject(id)
  if entity then
    self.form:ShowInteractive(self.player.gameObject, id, entity.element.m_ButtonType)
    self.targetEffect:AddTask(self, ActExploreTask.Active.new(true))
    if entity.gameObject then
      local pos = entity.gameObject.transform.position
      if entity.element then
        pos.y = pos.y + entity.element.m_PointPosition
      end
      self.targetEffect:AddTask(self, ActExploreTask.Transform.new(pos, CS.UnityEngine.Quaternion.identity))
    end
    self:SwitchCamera(entity.element.m_TriggerCamera)
    self.triggerCameraId = id
  else
    self.form:ShowInteractive(nil, -1, 0)
    self.targetEffect:AddTask(self, ActExploreTask.Active.new(false))
    self:SwitchCamera(nil)
    self.triggerCameraId = nil
  end
end

function ActExploreWorld:SwitchCamera(name, tmp)
  if name == nil or name == "" then
    name = "Main"
  end
  if not tmp then
    if self.currentCamera == name then
      return
    end
    self.currentCamera = name
  end
  for k, v in pairs(self.cameraGroup) do
    if k == name then
      v.m_Priority = 100
    else
      v.m_Priority = 0
    end
  end
end

function ActExploreWorld:OnTriggerStateChange(id, isEnter)
  local entity = self:FindObject(id)
  if entity and isEnter then
    self:OnInteractive(id, CS.LogicActExplore.ActExploreInteractType.Button)
  end
end

function ActExploreWorld:OnInteractive(id, type)
  local entity = self:FindObject(id)
  if entity == nil then
    return
  end
  if entity.element == nil then
    return
  end
  if entity.element.m_Script ~= "" then
    self.exploreManager.System:InteractEvent(entity.entityID, type)
    return
  end
  if entity.element.m_JumpID ~= 0 then
    QuickOpenFuncUtil:OpenFunc(entity.element.m_JumpID)
  end
  if 0 < entity.element.m_Item.Length then
    self.player:AddTask(self, ActExploreTask.InteractiveChange.new(entity.objectID, 3))
    entity:AddTask(self, ActExploreTask.RewardFly.new())
  end
end

function ActExploreWorld:TakeReward(element)
  self.synchronizer:TakeReward(element)
end

function ActExploreWorld:OnMoveInput(vec)
  if self.player ~= nil and self.player.playerController ~= nil then
    vec:Normalize()
    self.player.playerController:MoveDirection(vec)
    if vec.x ~= 0 and vec.y ~= 0 then
      self.player:AddTask(self, ActExploreTask.CameraAimPointReset.new())
      self:SwitchCamera(self.currentCamera)
    else
      self.synchronizer:SetObjectTransform(0, self.player.gameObject.transform.position, self.player.gameObject.transform.rotation)
    end
  end
end

function ActExploreWorld:OnMoveTo(vec)
  if self.player ~= nil and self.player.playerController ~= nil then
    if self.moveStateHandler == nil then
      self.moveStateHandler = handler(self, self.OnPointMoveStateChange)
    end
    local target = self.player.playerController:MoveTo(vec, self.moveStateHandler)
    self.walkTargetEffect:AddTask(self, ActExploreTask.Transform.new(target, CS.UnityEngine.Quaternion.identity))
  end
end

function ActExploreWorld:OnPointMoveStateChange(state)
  if state == 0 then
    self.player:AddTask(self, ActExploreTask.CameraAimPointReset.new())
    self:SwitchCamera(self.currentCamera)
  elseif state == 1 then
    self.synchronizer:SetObjectTransform(0, self.player.gameObject.transform.position, self.player.gameObject.transform.rotation)
  end
  self.walkTargetEffect:AddTask(self, ActExploreTask.Active.new(state == 0))
end

function ActExploreWorld:OnDragScreen(offsetX, offsetZ)
  if self.aimFollow == nil then
    return
  end
  if offsetX == nil or offsetZ == nil then
    return
  end
  self.aimFollow.Target = nil
  local pos = self.aimFollow.transform.position
  pos.x = offsetX + pos.x
  pos.z = offsetZ + pos.z
  pos = self.sceneConfig:ClampCameraAimPoint(pos)
  self.aimFollow.transform.position = pos
  if self.triggerCameraId ~= nil then
    local isInTrigger = self.player.playerInteractive:IsInRange(self.triggerCameraId, pos)
    local entity = self:FindObject(self.triggerCameraId)
    if isInTrigger then
      self:SwitchCamera(entity.element.m_TriggerCamera, true)
    else
      self:SwitchCamera(nil, true)
    end
  end
end

function ActExploreWorld:DestroyObject(entity, delayTime)
  self.synchronizer:OnObjectDestroy(entity.UID)
  table.insert(self.delayDestroy, {
    time = delayTime or 0,
    objectID = entity.objectID
  })
  self.synchronizer:SyncToServer()
  if entity.UID and self.pickableObjects[entity.UID] then
    self.pickableObjects[entity.UID] = false
    self:UpdatePickUpAmount()
  end
end

function ActExploreWorld:UpdatePickUpAmount()
  local amount = 0
  local count = 0
  for k, v in pairs(self.pickableObjects) do
    amount = amount + 1
    if not v then
      count = count + 1
    end
  end
  self.form:SetPickupAmount(amount, count)
  return amount, count
end

function ActExploreWorld:CheckInteractiveIsUnlock(element)
  local openTime = TimeUtil:TimeStringToTimeSec2(element.m_OpenTime) or 0
  local currentTime = TimeUtil:GetServerTimeS()
  if 0 < openTime and openTime > currentTime then
    return false
  end
  local destroyTime = TimeUtil:TimeStringToTimeSec2(element.m_DestroyTime) or 0
  if 0 < destroyTime and currentTime > destroyTime then
    return false
  end
  return true
end

function ActExploreWorld:Destroy()
  TimeService:KillTimer(self.timerID)
  for k, v in pairs(self.objects) do
    v:Desteroy()
  end
end

return ActExploreWorld
