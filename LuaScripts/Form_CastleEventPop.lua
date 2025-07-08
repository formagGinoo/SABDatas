local Form_CastleEventPop = class("Form_CastleEventPop", require("UI/UIFrames/Form_CastleEventPopUI"))

function Form_CastleEventPop:SetInitParam(param)
end

function Form_CastleEventPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_CastleEventPop:OnActive()
  self.super.OnActive(self)
  local cfg = self.m_csui.m_param.cfg
  local maxTimes = CastleStoryManager:GetMaxStoryEnergyCount()
  local leftTimes = maxTimes - CastleStoryManager:GetiStoryTimes()
  self.m_txt_num_strength_Text.text = leftTimes .. "/" .. maxTimes
  self.m_txt_title_Text.text = cfg.m_mTitle
  local heroID = cfg.m_ShowCharacter
  ResourceUtil:CreatHeroBust(self.m_img_head_Image, heroID)
  self.m_txt_content_Text.text = string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(48003), cfg.m_mTitle)
  self:addEventListener("eGameEvent_CastlePopStoryWindow", handler(self, self.OpenPop2))
  CS.GlobalManager.Instance:TriggerWwiseBGMState(215)
end

function Form_CastleEventPop:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_CastleEventPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleEventPop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CastleEventPop:OnBtnstrengthClicked()
end

function Form_CastleEventPop:OnBtncancelClicked()
  self:CloseForm()
end

function Form_CastleEventPop:OnBtnconsumeClicked()
  if self.m_csui.m_param.callback then
    self.m_csui.m_param.callback()
    self.m_csui.m_param.callback = nil
  end
  if CastleStoryManager:GetCurClkPlace() and CastleStoryManager:GetCurClkPlace() ~= 9 then
    return
  end
  self:OpenPop2()
end

function Form_CastleEventPop:OpenPop2()
  self:CloseForm()
  StackFlow:Push(UIDefines.ID_FORM_CASTLEEVENTPOP02, {
    cfg = self.m_csui.m_param.cfg,
    is_FullScreen = self.m_csui.m_param.is_FullScreen
  })
end

function Form_CastleEventPop:IsOpenGuassianBlur()
end

function Form_CastleEventPop:IsFullScreen()
end

local fullscreen = true
ActiveLuaUI("Form_CastleEventPop", Form_CastleEventPop)
return Form_CastleEventPop
