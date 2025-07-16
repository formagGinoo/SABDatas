local Form_GameSceneLoading = class("Form_GameSceneLoading", require("UI/UIFrames/Form_GameSceneLoadingUI"))

function Form_GameSceneLoading:SetInitParam(param)
end

function Form_GameSceneLoading:AfterInit()
  self.super.AfterInit(self)
end

function Form_GameSceneLoading:OnActive()
  self.super.OnActive(self)
  local iSceneID = self.m_csui.m_param.iSceneID
  local stGameSceneConfig = ConfigManager:GetConfigInsByName("GameScene"):GetValue_ByID(iSceneID)
  UILuaHelper.SetUITexture(self.m_img_bg_Image, stGameSceneConfig.m_LoadingImg)
  self:setTimer(0.01, 1, function()
    local fActiveCB = self.m_csui.m_param.fActiveCB
    if fActiveCB then
      fActiveCB()
    end
  end)
end

function Form_GameSceneLoading:GetDownloadResourceExtra(tParam)
  local vResourceExtra = {}
  local iSceneID = tParam.iSceneID
  local stGameSceneConfig = ConfigManager:GetConfigInsByName("GameScene"):GetValue_ByID(iSceneID)
  vResourceExtra[#vResourceExtra + 1] = {
    sName = stGameSceneConfig.m_LoadingImg,
    eType = DownloadManager.ResourceType.UITexture
  }
  return nil, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_GameSceneLoading", Form_GameSceneLoading)
return Form_GameSceneLoading
