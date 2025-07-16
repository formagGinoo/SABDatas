local Form_ActExploreExit = class("Form_ActExploreExit", require("UI/UIFrames/Form_ActExploreExitUI"))

function Form_ActExploreExit:SetInitParam(param)
end

function Form_ActExploreExit:AfterInit()
  self.super.AfterInit(self)
  self:addEventListener("eGameEvent_ActExploreUIVisuable", handler(self, self.OnUIActiveEvent))
end

function Form_ActExploreExit:OnActive()
  self.super.OnActive(self)
end

function Form_ActExploreExit:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActExploreExit:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActExploreExit:OnUIActiveEvent(active)
  self.m_btn_pause:SetActive(active)
end

function Form_ActExploreExit:OnBtnpauseClicked()
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_ActExploreExit:IsFullScreen()
  return true
end

ActiveLuaUI("Form_ActExploreExit", Form_ActExploreExit)
return Form_ActExploreExit
