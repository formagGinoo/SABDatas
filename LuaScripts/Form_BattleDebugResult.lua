local Form_BattleDebugResult = class("Form_BattleDebugResult", require("UI/UIFrames/Form_BattleDebugResultUI"))

function Form_BattleDebugResult:SetInitParam(param)
end

function Form_BattleDebugResult:AfterInit()
  self.super.AfterInit(self)
end

function Form_BattleDebugResult:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_victory:SetActive(tParam)
  self.m_defeat:SetActive(not tParam)
end

function Form_BattleDebugResult:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattleDebugResult:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattleDebugResult:OnBtnBgCloseClicked()
  self:CloseForm()
  CS.BattleGameManager.Instance:ExitBattle()
end

local fullscreen = true
ActiveLuaUI("Form_BattleDebugResult", Form_BattleDebugResult)
return Form_BattleDebugResult
