local BaseManager = require("Manager/Base/BaseManager")
local GameSceneManager = class("GameSceneManager", BaseManager)
GameSceneManager.SceneID = {
  MainCity = 1,
  LevelMap = 2,
  Castle = 4,
  CouncilHall_1 = 5,
  Favorability = 6,
  ActExplore = 7
}

function GameSceneManager:OnCreate()
  self.m_mGameScene = {}
  self.m_cGameSceneCur = nil
end

function GameSceneManager:OnInitNetwork()
end

function GameSceneManager:GetGameScene(iSceneID)
  if self.m_mGameScene[iSceneID] == nil then
    local cGameScene
    if iSceneID == GameSceneManager.SceneID.LevelMap then
      cGameScene = require("Scene/GameScene_LevelMap")
    elseif iSceneID == GameSceneManager.SceneID.Castle then
      cGameScene = require("Scene/GameScene_Castle")
    elseif iSceneID == GameSceneManager.SceneID.MainCity then
      cGameScene = require("Scene/GameScene_MainCity")
    elseif iSceneID == GameSceneManager.SceneID.CouncilHall_1 then
      cGameScene = require("Scene/GameScene_CouncilHall")
    elseif iSceneID == GameSceneManager.SceneID.Favorability then
      cGameScene = require("Scene/GameScene_Favorability")
    elseif iSceneID == GameSceneManager.SceneID.ActExplore then
      cGameScene = require("Scene/GameScene_ActExplore")
    else
      cGameScene = require("Scene/GameSceneBase")
    end
    self.m_mGameScene[iSceneID] = cGameScene.new(iSceneID)
  end
  return self.m_mGameScene[iSceneID]
end

function GameSceneManager:ChangeGameSceneReal(iSceneID, fCompleteCB, bHideLoading)
  local function OnChangeGameSceneComplete(isSuc)
    if fCompleteCB then
      fCompleteCB(isSuc)
    end
    if not bHideLoading then
      StackTop:RemoveUIFromStack(UIDefines.ID_FORM_GAMESCENELOADING)
    end
  end
  
  local cGameScene = self:GetGameScene(iSceneID)
  local sSceneName = cGameScene:GetSceneName()
  local iSceneIDPre
  if self.m_cGameSceneCur then
    iSceneIDPre = self.m_cGameSceneCur:GetSceneID()
    self.m_cGameSceneCur:OnLeaveScene(iSceneID)
  end
  SceneManagerIns:LoadSceneAsync(sSceneName, function(isSuc)
    self.m_cGameSceneCur = cGameScene
    self.m_cGameSceneCur:OnEnterScene(iSceneIDPre)
    local iEnterSceneUIDefineID = cGameScene:GetEnterSceneUIDefineID()
    if iEnterSceneUIDefineID then
      StackFlow:TryLoadUI(iEnterSceneUIDefineID, function()
        OnChangeGameSceneComplete(isSuc)
      end)
    else
      OnChangeGameSceneComplete(isSuc)
    end
  end)
end

function GameSceneManager:ChangeGameScene(iSceneID, fCompleteCB, bHideLoading, cancelCallback)
  local function OnLoadingActive()
    self:ChangeGameSceneReal(iSceneID, fCompleteCB, bHideLoading)
  end
  
  local cGameScene = self:GetGameScene(iSceneID)
  local sSceneName = cGameScene:GetSceneName()
  local vPackage = {}
  local vResourceAB = {
    {
      sName = sSceneName,
      eType = DownloadManager.ResourceType.Scene
    }
  }
  if not bHideLoading then
    vPackage[#vPackage + 1] = {
      sName = "Form_GameSceneLoading",
      eType = DownloadManager.ResourcePackageType.UI
    }
    local stGameSceneConfig = ConfigManager:GetConfigInsByName("GameScene"):GetValue_ByID(iSceneID)
    vResourceAB[#vResourceAB + 1] = {
      sName = stGameSceneConfig.m_LoadingImg,
      eType = DownloadManager.ResourceType.UITexture
    }
  end
  local iEnterSceneUIDefineID = cGameScene:GetEnterSceneUIDefineID()
  if iEnterSceneUIDefineID then
    vPackage[#vPackage + 1] = {
      sName = UINames[iEnterSceneUIDefineID],
      eType = DownloadManager.ResourcePackageType.UI
    }
    local uiEnterScene = require("UI/" .. UINames[iEnterSceneUIDefineID])
    local vPackageExtra, vResourceABExtra = uiEnterScene:GetDownloadResourceExtra(cGameScene:GetEnterSceneUIActiveParam())
    if vPackageExtra then
      for i = 1, #vPackageExtra do
        vPackage[#vPackage + 1] = vPackageExtra[i]
      end
    end
    if vResourceABExtra then
      for i = 1, #vResourceABExtra do
        vResourceAB[#vResourceAB + 1] = vResourceABExtra[i]
      end
    end
  end
  local vScenePackExtra, vSceneResABExtra = cGameScene:GetDownloadResourceExtra()
  if vScenePackExtra and next(vScenePackExtra) then
    for i, v in ipairs(vScenePackExtra) do
      vPackage[#vPackage + 1] = v
    end
  end
  if vSceneResABExtra and next(vSceneResABExtra) then
    for i, v in ipairs(vSceneResABExtra) do
      vResourceAB[#vResourceAB + 1] = v
    end
  end
  
  local function OnDownloadComplete(ret)
    log.info(string.format("Download Scene %s Complete: %s", sSceneName, tostring(ret)))
    if not bHideLoading then
      StackTop:Push(UIDefines.ID_FORM_GAMESCENELOADING, {iSceneID = iSceneID, fActiveCB = OnLoadingActive})
    else
      OnLoadingActive()
    end
  end
  
  DownloadManager:DownloadResourceWithUI(vPackage, vResourceAB, "Scene_" .. sSceneName, nil, nil, OnDownloadComplete, nil, nil, nil, nil, function()
    if cancelCallback then
      cancelCallback()
    end
  end)
end

function GameSceneManager:GetCurScene()
  return self.m_cGameSceneCur
end

function GameSceneManager:CheckChangeSceneToMainCity(backFun, bHideLoading)
  local curSceneCom = self:GetCurScene()
  if curSceneCom and curSceneCom:GetSceneID() ~= GameSceneManager.SceneID.MainCity then
    self:ChangeGameScene(GameSceneManager.SceneID.MainCity, backFun, bHideLoading)
  end
end

return GameSceneManager
