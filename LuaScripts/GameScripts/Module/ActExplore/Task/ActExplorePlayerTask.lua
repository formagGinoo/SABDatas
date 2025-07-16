local ActExplorePlayerTask = class("ActExplorePlayerTask")

function ActExplorePlayerTask:ctor(cfg)
  self.playerConfig = cfg
end

function ActExplorePlayerTask:OnCreate(world, entityObj)
  entityObj.playerInteractive = entityObj.gameObject:AddComponent(typeof(CS.ActExploreInteractiveCheck))
  entityObj.playerInteractive.OnInteractiveChange = handler(world, world.OnInteractiveChange)
  entityObj.playerInteractive.OnTriggerStateChange = handler(world, world.OnTriggerStateChange)
  local playerController = entityObj.gameObject:AddComponent(typeof(CS.ActExploreMoveController))
  entityObj.playerController = playerController
  playerController.SpeedCurve = self.playerConfig.SpeedCurve
  playerController.MoveSpeed = self.playerConfig.MaxSpeed
  playerController.PathFinder = world.exploreManager.PathFinder
  playerController.SceneSDF = world.exploreManager.SceneSDF
  playerController.Radius = 0
  playerController.MoveAnimator = entityObj.animator
  playerController.AnimParamName = "IsRun"
  playerController.UseParam = true
  playerController.StartWaitTime = 0.125
  playerController.LineMaterial = CS.VisualResourcePool.GetMaterial(ActExploreRes.LineMaterial)
end

return ActExplorePlayerTask
