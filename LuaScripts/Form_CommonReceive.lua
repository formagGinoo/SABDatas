local Form_CommonReceive = class("Form_CommonReceive", require("UI/UIFrames/Form_CommonReceiveUI"))
local DelayCloseUI = 5

function Form_CommonReceive:SetInitParam(param)
end

function Form_CommonReceive:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
end

function Form_CommonReceive:OnActive()
  self.super.OnActive(self)
  UILuaHelper.DestroyChildren(self.m_tips_parent_node)
  if self.m_lastTipsSequence then
    self.m_lastTipsSequence:Kill()
  end
  self.m_lastTipsSequence = nil
  local tParam = self.m_csui.m_param
  utils.createPromptTips(tParam)
  self:DelayCloseCommonTipsRootUI(tParam)
end

function Form_CommonReceive:DelayCloseCommonTipsRootUI(paramData)
  local delay_close = paramData.delayClose or 0
  local delay_open = paramData.delayOpen or 0
  if self.m_lastTipsSequence then
    self.m_lastTipsSequence:Kill()
  end
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(delay_open + delay_close + DelayCloseUI)
  sequence:OnComplete(function()
    self.m_lastTipsSequence = nil
    StackTop:RemoveUIFromStack(UIDefines.ID_FORM_COMMONRECEIVE)
  end)
  sequence:SetAutoKill(true)
  self.m_lastTipsSequence = sequence
end

function Form_CommonReceive:OnInactive()
  self.super.OnInactive(self)
end

function Form_CommonReceive:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_CommonReceive", Form_CommonReceive)
return Form_CommonReceive
