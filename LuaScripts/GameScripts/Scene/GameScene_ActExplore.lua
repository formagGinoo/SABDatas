local GameSceneBase = require("Scene/GameSceneBase")
local GameScene_ActExplore = class("GameScene_ActExplore", GameSceneBase)
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local worldClass = require("Module/ActExplore/ActExploreWorld")
local ActExploreSynchronizer = require("Module/ActExplore/ActExploreSynchronizer")
ActExploreRes = {
  WalkTarget = "FX_Common_Explore_WalkTarget_Blue",
  SelectEffect = CS.VisualExploreGrid.CharactSelectEffect,
  LineMaterial = "FX_Common_line_bx_001",
  PickAudioEvent = "Play_ui_activity103_pick"
}

function GameScene_ActExplore:GetPreload(sceneName)
  local preload = CS.VisualActExplore.VisualActExplorePreload.Create(sceneName)
  preload:AddResource("ActExplore", CS.MUF.Resource.ResourceType.Scene)
  preload:AddResource("Form_ActExploreMain", CS.MUF.Resource.ResourceType.UI)
  preload:AddResource("Form_ActExploreExit", CS.MUF.Resource.ResourceType.UI)
  preload:AddResource(ActExploreRes.WalkTarget, CS.MUF.Resource.ResourceType.FX)
  preload:AddResource(ActExploreRes.SelectEffect, CS.MUF.Resource.ResourceType.FX)
  preload:AddResource(ActExploreRes.LineMaterial, CS.MUF.Resource.ResourceType.Material)
  preload:Collector()
  return preload
end

function GameScene_ActExplore:OnEnterScene(iSceneIDPrev)
  self.super.OnEnterScene(self, iSceneIDPrev)
  UILuaHelper.InsertCameraToUIRootStack(nil, 0)
  local preload = self:GetPreload(self.sceneName)
  self.ActExploreManager = CS.VisualActExploreManager.Create(preload)
  self.ActExploreManager:Preload(handler(self, self.OnPreloadFinish))
end

function GameScene_ActExplore:OnLeaveScene(iSceneIDNext)
  self.super.OnLeaveScene(self, iSceneIDNext)
  if self.synchronizer ~= nil then
    self.synchronizer:SyncToServer()
  end
  StackBottom:DestroyUI(UIDefines.ID_FORM_DIALOGUE_POPO)
  StackBottom:DestroyUI(UIDefines.ID_FORM_ACTEXPLOREMAIN)
  StackFlow:DestroyUI(UIDefines.ID_FORM_WHACKMOLEBATTLEMAIN)
  StackFlow:DestroyUI(UIDefines.ID_FORM_WHACKMOLEMAIN)
  UILuaHelper.RemoveCameraFromUIRootStack(CS.UnityEngine.Camera.main)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTEXPLOREEXIT)
  self.exploreWorld:Destroy()
  self.exploreWorld = nil
  self.sceneName = nil
  self.synchronizer = nil
  self.activityID = nil
  self.onEnterScene = nil
end

function GameScene_ActExplore:OpenScene(sceneName, activityID, onEnterScene, bIsHideLoading)
  self.sceneName = sceneName
  self.activityID = activityID
  self.onEnterScene = onEnterScene
  if activityID == nil then
    self.synchronizer = ActExploreSynchronizer.new()
    self:DoLoad(bIsHideLoading)
  else
    self.lockId = UILockIns:Lock(10)
    HeroActivityManager:GetSynchronizer(activityID, function(synchronizer)
      self.synchronizer = synchronizer
      self:DoLoad(bIsHideLoading)
    end)
  end
end

function GameScene_ActExplore:DoLoad(bIsHideLoading)
  StackFlow:Push(UIDefines.ID_FORM_ACTEXPLOREEXIT)
  StackBottom:Push(UIDefines.ID_FORM_ACTEXPLOREMAIN)
  
  local function loadScene()
    GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.ActExplore, function(isSuc)
      self:Unlock()
      if isSuc then
        local brain = CS.Cinemachine.CinemachineCore.Instance:GetActiveBrain(0)
        UILuaHelper.InsertCameraToUIRootStack(brain.OutputCamera)
      end
    end, true)
  end
  
  if not bIsHideLoading then
    StackTop:Push(UIDefines.ID_FORM_GAMESCENELOADING, {
      iSceneID = GameSceneManager.SceneID.ActExplore,
      fActiveCB = loadScene
    })
  else
    loadScene()
  end
end

function GameScene_ActExplore:OnPreloadFinish()
  local form = StackBottom:GetUIInstanceLua(UIDefines.ID_FORM_ACTEXPLOREMAIN)
  self.exploreWorld = worldClass.new(handler(self, self.OnLoadFinish))
  self.exploreWorld.synchronizer = self.synchronizer
  self.exploreWorld.form = form
  self.exploreWorld:Init()
  if form ~= nil then
    form:SetWorld(self.exploreWorld)
  end
end

function GameScene_ActExplore:OnLoadFinish()
  if self.onEnterScene ~= nil then
    self.onEnterScene()
    self.onEnterScene = nil
  else
    EventCenter.Broadcast(EventDefine.eGameEvent_ActExploreUIReady)
  end
end

function GameScene_ActExplore:Unlock()
  if self.lockId ~= nil then
    UILockIns:Unlock(self.lockId)
    self.lockId = nil
  end
end

return GameScene_ActExplore
