local GameSceneBase = require("Scene/GameSceneBase")
local GameScene_Castle = class("GameScene_Castle", GameSceneBase)

function GameScene_Castle:OnEnterScene(iSceneIDPrev)
  self.super.OnEnterScene(self, iSceneIDPrev)
  self.m_camera = nil
  self.m_castleManager = nil
  local vRootGO = CS.UnityEngine.SceneManagement.SceneManager:GetActiveScene():GetRootGameObjects()
  for i = 0, vRootGO.Length - 1 do
    local go = vRootGO[i]
    if go.name == "Castle" then
      local tempTrans = go.transform
      self.m_camera = tempTrans:Find("Base/camera/MainCamera"):GetComponent(T_Camera)
      self.m_castleManager = tempTrans:Find("Base"):GetComponent("CastleManager")
      break
    end
  end
  if self.m_camera then
    UILuaHelper.InsertCameraToUIRootStack(self.m_camera)
    UILuaHelper.AddCameraObjectOcclusionToCastleCamera(self.m_camera)
  end
  if self.m_castleManager then
    ModuleManager:GetModuleByName("CastleModule"):SetCastleManager(self.m_castleManager)
    if iSceneIDPrev == GameSceneManager.SceneID.CouncilHall_1 then
      local placeID = tonumber(ConfigManager:GetGlobalSettingsByKey("CastleCouncilHallPlaceId"))
      self.m_castleManager:SetCameraState2CouncilHall(placeID)
    end
  end
end

function GameScene_Castle:OnLeaveScene(iSceneIDNext)
  self.super.OnLeaveScene(self, iSceneIDNext)
  if self.m_camera then
    UILuaHelper.RemoveCameraFromUIRootStack(self.m_camera)
    self.m_camera = nil
  end
  if self.m_castleManager then
    self.m_castleManager:InitMaterialParam()
    ModuleManager:GetModuleByName("CastleModule"):ClearCastleManager()
    self.m_castleManager = nil
  end
end

function GameScene_Castle:GetEnterSceneUIDefineIDDefault()
  return UIDefines.ID_FORM_CASTLEMAIN
end

return GameScene_Castle
