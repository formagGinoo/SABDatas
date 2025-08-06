local GameSceneBase = require("Scene/GameSceneBase")
local GameScene_LevelMap = class("GameScene_LevelMap", GameSceneBase)

function GameScene_LevelMap:OnEnterScene(iSceneIDPrev)
  self.super.OnEnterScene(self, iSceneIDPrev)
  self.m_cameraLevelMap = nil
  local vRootGO = CS.UnityEngine.SceneManagement.SceneManager:GetActiveScene():GetRootGameObjects()
  if vRootGO.Length > 0 then
    local tempGoRoot = vRootGO[0]
    self.m_cameraLevelMap = tempGoRoot.transform:Find("Camera/MainStoryCamera"):GetComponent(T_Camera)
    self.m_chapterRootTrans = tempGoRoot.transform:Find("LevelRoot").transform
    self.m_poolRootTrans = tempGoRoot.transform:Find("GameObjectPoolRoot").transform
  end
  if self.m_cameraLevelMap then
    UILuaHelper.InsertCameraToUIRootStack(self.m_cameraLevelMap, 0)
  end
end

function GameScene_LevelMap:OnLeaveScene(iSceneIDNext)
  self.super.OnLeaveScene(self, iSceneIDNext)
  if self.m_cameraLevelMap then
    UILuaHelper.RemoveCameraFromUIRootStack(self.m_cameraLevelMap)
  end
  if CS.GameQualityManager.DestroyLevelMapAsset then
    if self.m_chapterRootTrans then
      local childNum = self.m_chapterRootTrans.childCount
      for i = 1, childNum do
        local chapterNode = self.m_chapterRootTrans:GetChild(i - 1)
        if chapterNode then
          local chapterNodeStr = chapterNode.name
          local allChildRefComArray = chapterNode:GetComponentsInChildren(typeof(CS.mufplugin.Common.Extension.SpriteRefHolder), true)
          if allChildRefComArray and allChildRefComArray.Length then
            local refComNum = allChildRefComArray.Length
            for i = 1, refComNum do
              local tempRefCom = allChildRefComArray[i - 1]
              if tempRefCom and tempRefCom.SpriteName then
                CS.MUF.Resource.ResourceManager.UnloadAsset(tempRefCom.SpriteName, CS.MUF.Resource.ResourceType.Atlas)
              end
            end
          end
          GameObject.Destroy(chapterNode.gameObject)
          CS.MUF.Resource.ResourceManager.UnloadAsset(chapterNodeStr, CS.MUF.Resource.ResourceType.UI)
        end
      end
    end
    self.m_chapterRootTrans = nil
    if self.m_poolRootTrans then
      local allChildRefComArray = self.m_poolRootTrans:GetComponentsInChildren(typeof(CS.mufplugin.Common.Extension.SpriteRefHolder), true)
      if allChildRefComArray and allChildRefComArray.Length then
        local refComNum = allChildRefComArray.Length
        for i = 1, refComNum do
          local tempRefCom = allChildRefComArray[i - 1]
          if tempRefCom and tempRefCom.SpriteName then
            CS.MUF.Resource.ResourceManager.UnloadAsset(tempRefCom.SpriteName, CS.MUF.Resource.ResourceType.Atlas)
          end
        end
      end
    end
    self.m_poolRootTrans = nil
  end
end

function GameScene_LevelMap:GetEnterSceneUIDefineIDDefault()
  return UIDefines.ID_FORM_LEVELMAIN
end

function GameScene_LevelMap:GetDownloadResourceExtra()
  local vResourceExtra = {}
  local levelMainHelper = LevelManager:GetLevelMainHelper()
  local stNextLevelCfg = levelMainHelper:GetNextShowLevelCfg(LevelManager.MainLevelSubType.MainStory)
  if stNextLevelCfg then
    local iChapterIDMax = stNextLevelCfg.m_ChapterID
    local mTexture2DResName = {}
    for iChapterID = 1, iChapterIDMax + 1 do
      local stLevelMapConfig = ConfigManager:GetConfigInsByName("LevelMapConfig"):GetValue_ByChapter(iChapterID)
      if not stLevelMapConfig:GetError() then
        for i = 0, stLevelMapConfig.m_Texture2DRes.Length - 1 do
          local sName = stLevelMapConfig.m_Texture2DRes[i]
          if mTexture2DResName[sName] == nil then
            mTexture2DResName[sName] = true
            vResourceExtra[#vResourceExtra + 1] = {
              sName = sName,
              eType = DownloadManager.ResourceType.Texture2DRes
            }
          end
        end
      end
    end
  end
  if #vResourceExtra == 0 then
    local textTureFormatStr = "MainLevelSubTexture_%d_%d"
    local valueStr = ConfigManager:GetEditorExportSettingByKey("WorldMapGridCount")
    local valueStrArray = string.split(valueStr, ";")
    local xMaxNum = tonumber(valueStrArray[1])
    local yMaxNum = tonumber(valueStrArray[2])
    for i = 0, xMaxNum - 1 do
      local xValue = i
      for j = 0, yMaxNum - 1 do
        local yValue = j
        local sName = string.format(textTureFormatStr, xValue, yValue)
        vResourceExtra[#vResourceExtra + 1] = {
          sName = sName,
          eType = DownloadManager.ResourceType.Texture2DRes
        }
      end
    end
  end
  if levelMainHelper then
    local ChapterNodePreStr = "Chapter-"
    local allChapterDic = levelMainHelper:GetAllChapterDic()
    for chapterID, _ in pairs(allChapterDic) do
      if chapterID ~= 0 then
        local chapterNodeStr = ChapterNodePreStr .. chapterID
        vResourceExtra[#vResourceExtra + 1] = {
          sName = chapterNodeStr,
          eType = DownloadManager.ResourceType.UI
        }
      end
    end
  end
  return nil, vResourceExtra
end

return GameScene_LevelMap
