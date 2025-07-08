local GameSceneBase = require("Scene/GameSceneBase")
local GameScene_CouncilHall = class("GameScene_CouncilHall", GameSceneBase)

function GameScene_CouncilHall:OnEnterScene(iSceneIDPrev)
  self.super.OnEnterScene(self, iSceneIDPrev)
  local sceneID = self.m_iSceneID
  local vRootGO = CS.UnityEngine.SceneManagement.SceneManager:GetActiveScene():GetRootGameObjects()
  for i = 0, vRootGO.Length - 1 do
    local go = vRootGO[i]
    if go.name == "Overlay_Canera" then
      self.m_camera = go:GetComponent(T_Camera)
      self.m_cameraObj = go
    end
    local ChairList = {}
    if go.name == "Root" then
      local char_root = go.transform:Find("Castle_CouncilHall_1/Base/Char")
      for j = 0, char_root.childCount - 1 do
        ChairList[#ChairList + 1] = char_root:GetChild(j)
      end
      self.ChairList = ChairList
      self.mascotObjList = {}
      self.mascotObjList[1] = go.transform:Find("Castle_CouncilHall_1/Base/G_MascotBat_Skin")
      self.mascotObjList[2] = go.transform:Find("Castle_CouncilHall_1/Base/G_MascotGarlic_Base_skin")
    end
  end
  CouncilHallManager:SetCouncilHallChairListAndCamera(self.ChairList, self.m_camera, self.mascotObjList)
  if self.m_camera then
    UILuaHelper.InsertCameraToUIRootStack(self.m_camera, 0)
    utils.AdaptCamera(self.m_camera)
  end
end

function GameScene_CouncilHall:OnLeaveScene(iSceneIDNext)
  self.super.OnLeaveScene(self, iSceneIDNext)
  if self.m_camera then
    UILuaHelper.RemoveCameraFromUIRootStack(self.m_camera)
  end
  CouncilHallManager:UnloadAssets()
end

function GameScene_CouncilHall:GetEnterSceneUIDefineIDDefault()
  return UIDefines.ID_FORM_CASTLEMEETINGRROOM
end

function GameScene_CouncilHall:GetDownloadResourceExtra()
end

return GameScene_CouncilHall
