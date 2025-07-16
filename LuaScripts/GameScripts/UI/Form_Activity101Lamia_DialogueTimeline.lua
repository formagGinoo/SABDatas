local Form_Activity101Lamia_DialogueTimeline = class("Form_Activity101Lamia_DialogueTimeline", require("UI/UIFrames/Form_Activity101Lamia_DialogueTimelineUI"))
local WaitTime = 0.2

function Form_Activity101Lamia_DialogueTimeline:SetInitParam(param)
end

function Form_Activity101Lamia_DialogueTimeline:AfterInit()
  self.super.AfterInit(self)
  self.m_levelID = nil
  self.m_backFun = nil
  if self.m_waitTimer then
    TimeService:KillTimer(self.m_waitTimer)
    self.m_waitTimer = nil
  end
end

function Form_Activity101Lamia_DialogueTimeline:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(98)
end

function Form_Activity101Lamia_DialogueTimeline:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity101Lamia_DialogueTimeline:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity101Lamia_DialogueTimeline:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelID = tParam.levelID
  self.m_backFun = tParam.backFun
  self.m_csui.m_param = nil
end

function Form_Activity101Lamia_DialogueTimeline:FreshUI()
  if not self.m_levelID then
    return
  end
  local levelCfg = LevelHeroLamiaActivityManager:GetLevelCfgByID(self.m_levelID)
  if not levelCfg then
    return
  end
  self.m_txt_title_Text.text = levelCfg.m_LevelRef
  self.m_txt_title_desc_Text.text = levelCfg.m_mLevelName
  if self.m_waitTimer then
    TimeService:KillTimer(self.m_waitTimer)
    self.m_waitTimer = nil
  end
  self.m_waitTimer = TimeService:SetTimer(WaitTime, 1, function()
    self.m_waitTimer = nil
    if self.m_backFun then
      self.m_backFun()
    end
    self:CloseForm()
  end)
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_DialogueTimeline", Form_Activity101Lamia_DialogueTimeline)
return Form_Activity101Lamia_DialogueTimeline
