local GameSceneBase = require("Scene/GameSceneBase")
local GameScene_Favorability = class("GameScene_Favorability", GameSceneBase)

function GameScene_Favorability:OnEnterScene(iSceneIDPrev)
  self.super.OnEnterScene(self, iSceneIDPrev)
  local sceneID = self.m_iSceneID
  local cameraInit, cameraFocus, manager, chairModel, OtherModel, mSeatPosTransform
  local vRootGO = CS.UnityEngine.SceneManagement.SceneManager:GetActiveScene():GetRootGameObjects()
  for i = 0, vRootGO.Length - 1 do
    local go = vRootGO[i]
    if go.name == "Root" then
      self.m_camera = go.transform:Find("Castle_StudyRoom/Base/camera/MainCamera"):GetComponent(T_Camera)
      self.m_cameraObj = self.m_camera.gameObject
      cameraInit = go.transform:Find("Castle_StudyRoom/Base/camera/NodeInit").gameObject
      cameraFocus = go.transform:Find("Castle_StudyRoom/Base/camera/NodeFocus").gameObject
      mSeatPosTransform = go.transform:Find("Castle_StudyRoom/Base/Char/Seatpos_1").transform
      manager = go.transform:Find("Castle_StudyRoom"):GetComponent(typeof(CS.NewAttractRoomManager))
      chairModel = go.transform:Find("Castle_StudyRoom/Base/StudyRoom_Scence/Char_Scence/ChairNode").gameObject
      OtherModel = go.transform:Find("Castle_StudyRoom/Base/StudyRoom_Scence/Char_Scence/OtherModelNode").gameObject
    end
  end
  AttractManager:SetFavorabilitySeatPosAndCamera(mSeatPosTransform, self.m_camera, cameraInit, cameraFocus, manager)
  AttractManager:SetFavorabilityModel(chairModel, OtherModel)
  if self.m_camera then
    UILuaHelper.InsertCameraToUIRootStack(self.m_camera, 0)
    utils.AdaptCamera(self.m_camera)
  end
end

function GameScene_Favorability:OnLeaveScene(iSceneIDNext)
  self.super.OnLeaveScene(self, iSceneIDNext)
  if self.m_camera then
    UILuaHelper.RemoveCameraFromUIRootStack(self.m_camera)
  end
  AttractManager:UnloadAssets()
end

function GameScene_Favorability:GetEnterSceneUIDefineIDDefault()
  return UIDefines.ID_FORM_ATTRACTMAIN2
end

function GameScene_Favorability:GetDownloadResourceExtra()
end

return GameScene_Favorability
