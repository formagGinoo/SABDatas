local GameSceneBase = class("GameSceneBase")

function GameSceneBase:ctor(iSceneID)
  self.m_iSceneID = iSceneID
  self.m_stGameSceneConfig = ConfigManager:GetConfigInsByName("GameScene"):GetValue_ByID(iSceneID)
  if self.m_stGameSceneConfig == nil or self.m_stGameSceneConfig:GetError() then
    log.error("Get Scene Config Error, SceneID: " .. iSceneID)
  end
  self.m_iEnterSceneUIDefineID = self:GetEnterSceneUIDefineIDDefault()
  self.m_stEnterSceneUIActiveParam = nil
end

function GameSceneBase:GetSceneID()
  return self.m_iSceneID
end

function GameSceneBase:GetSceneName()
  return self.m_stGameSceneConfig.m_SceneName
end

function GameSceneBase:OnEnterScene(iSceneIDPrev)
  log.info("OnEnterScene: ", tostring(iSceneIDPrev), "->", self.m_iSceneID)
end

function GameSceneBase:OnLeaveScene(iSceneIDNext)
  log.info("OnLeaveScene: ", self.m_iSceneID, "->", tostring(iSceneIDNext))
end

function GameSceneBase:GetEnterSceneUIDefineIDDefault()
  return nil
end

function GameSceneBase:GetEnterSceneUIDefineID()
  return self.m_iEnterSceneUIDefineID
end

function GameSceneBase:SetEnterSceneUIDefineID(iUIDefineID)
  self.m_iEnterSceneUIDefineID = iUIDefineID
end

function GameSceneBase:GetEnterSceneUIActiveParam()
  return self.m_stEnterSceneUIActiveParam
end

function GameSceneBase:SetEnterSceneUIActiveParam(stParam)
  self.m_stEnterSceneUIActiveParam = stParam
end

function GameSceneBase:GetDownloadResourceExtra()
  return nil, nil
end

return GameSceneBase
