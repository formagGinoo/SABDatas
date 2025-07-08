local Form_LegacyActivityFail = class("Form_LegacyActivityFail", require("UI/UIFrames/Form_LegacyActivityFailUI"))

function Form_LegacyActivityFail:SetInitParam(param)
end

function Form_LegacyActivityFail:AfterInit()
  self.super.AfterInit(self)
end

function Form_LegacyActivityFail:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(10)
end

function Form_LegacyActivityFail:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_LegacyActivityFail:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LegacyActivityFail:AddEventListeners()
end

function Form_LegacyActivityFail:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LegacyActivityFail:ClearData()
end

function Form_LegacyActivityFail:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_levelSubType = tParam.levelSubType
  self.m_finishErrorCode = tParam.finishErrorCode
end

function Form_LegacyActivityFail:FreshUI()
end

function Form_LegacyActivityFail:OnBtnBgCloseClicked()
  CS.Form_MessageExplore.SendMessage_ExploreReset()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_LegacyActivityFail:OnBtnabandonClicked()
  CS.Form_MessageExplore.SendMessage_ExploreReset()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_LegacyActivityFail:OnBtnrestartClicked()
  CS.Form_MessageExplore.SendMessage_ExploreReset()
  BattleFlowManager:ReStartBattle(true)
end

function Form_LegacyActivityFail:OnBtnrollbackClicked()
  self:CloseForm()
  CS.VisualExploreManager.RollBack()
  CS.BattleGameManager.Instance:SwitchMode(true)
  CS.VisualExploreManager.SetActive(true)
  CS.VisualSceneManager.Instance:SwitchMode(true)
end

local fullscreen = true
ActiveLuaUI("Form_LegacyActivityFail", Form_LegacyActivityFail)
return Form_LegacyActivityFail
