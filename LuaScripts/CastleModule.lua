local BaseModule = require("Module/BaseModule")
local CastleModule = class("CastleModule", BaseModule)

function CastleModule:ctor(...)
  CastleModule.super.ctor(self, ...)
  self.m_castleManager = nil
end

function CastleModule:onReset()
end

function CastleModule:onSetVisible(isVisible)
end

function CastleModule:onDestroyUI(uid, uiStack)
end

function CastleModule:onPushUI(uid, uiStack)
end

function CastleModule:onAfterInitUI(uid, uiStack)
end

function CastleModule:onActiveUI(uid, uiStack)
end

function CastleModule:onInActiveUI(uid, uiStack)
end

function CastleModule:onDestroyUI(uid, uiStack)
end

function CastleModule:EnterModule()
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.Castle, function(isSuc)
    if isSuc then
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HALL)
      StackFlow:Push(UIDefines.ID_FORM_CASTLEMAIN)
    end
  end)
end

function CastleModule:SetCastleManager(castleManager)
  if not castleManager then
    return
  end
  self.m_castleManager = castleManager
end

function CastleModule:ClearCastleManager()
  self.m_castleManager = nil
end

function CastleModule:ChangeToDetailShow(sceneEnterIndex)
  if not sceneEnterIndex == nil then
    return
  end
  if sceneEnterIndex < 0 then
    return
  end
  if not self.m_castleManager then
    return
  end
  self.m_castleManager:ChangeToDetailShow(sceneEnterIndex)
end

function CastleModule:ChangeToTopShow()
  if not self.m_castleManager then
    return
  end
  self.m_castleManager:ChangeToTopShow()
end

function CastleModule:InitCameraStatusShow()
  if not self.m_castleManager then
    return
  end
  self.m_castleManager:InitCameraStatusShow()
end

return CastleModule
