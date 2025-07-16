local Form_Activity101Lamia_ShardPersonalityComplete = class("Form_Activity101Lamia_ShardPersonalityComplete", require("UI/UIFrames/Form_Activity101Lamia_ShardPersonalityCompleteUI"))

function Form_Activity101Lamia_ShardPersonalityComplete:SetInitParam(param)
end

function Form_Activity101Lamia_ShardPersonalityComplete:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_goRoot = goRoot
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
end

function Form_Activity101Lamia_ShardPersonalityComplete:OnActive()
  self.super.OnActive(self)
  self.call_back = self.m_csui.m_param.call_back
  self.m_UILockID = UILockIns:Lock(3)
  TimeService:SetTimer(1.5, 1, function()
    UILuaHelper.PlayAnimationByName(self.m_goRoot, "Lamia_ShardPersonalityComplete_loop")
  end)
end

function Form_Activity101Lamia_ShardPersonalityComplete:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity101Lamia_ShardPersonalityComplete:OnBtnCloseClicked()
  self:OnBackClk()
end

function Form_Activity101Lamia_ShardPersonalityComplete:OnBackClk()
  self:CloseForm()
  if self.call_back then
    self.call_back()
    self.call_back = nil
  end
end

function Form_Activity101Lamia_ShardPersonalityComplete:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_ShardPersonalityComplete", Form_Activity101Lamia_ShardPersonalityComplete)
return Form_Activity101Lamia_ShardPersonalityComplete
