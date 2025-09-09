local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableDialogue = class("AVGPlayableDialogue", AVGPlayable)

function AVGPlayableDialogue:Waitable()
  return true
end

function AVGPlayableDialogue:OnStart()
  local element = CS.CData_AVGDialogue.GetInstance():GetValue_ByID(self.playableData.Dialogue)
  if element:GetError() then
    log.error("AVGPlayableDialogue:OnStart() - DialogueID not found: " .. self.playableData.Dialogue)
    self.State = ACGAVGPlayableState.Finished
    return
  end
  self.duration = element.m_Duration
  local name = CS.MultiLanguageManager.Instance:GetPlotText(element.m_Role)
  self.textTypeWriter = self.context.form:SetDialogueContent(element.m_Style, name)
  self.textTypeWriter:ShowText(element.m_mContent, element.m_Speed, handler(self, self.OnTextTypeWriterFinish))
  local reviewData = {
    Type = 0,
    RoleName = name,
    DialogueContent = element.m_mContent,
    Voice = element.m_Audio
  }
  self.context:AddReviewData(self.DataIndex, reviewData)
  local loopTimes = element.m_MouthAnimation
  if element.m_Audio ~= "" then
    CS.UI.UILuaHelper.StartPlaySFX(element.m_Audio, nil, handler(self, self.OnPlaySFXStart), handler(self, self.OnPlaySFXFinish))
    loopTimes = -1
  end
  if 0 <= self.playableData.DialogueRole then
    local role = self.context:GetRole(self.playableData.DialogueRole)
    if role then
      role:SetSpeekTimes(loopTimes)
    end
  end
end

function AVGPlayableDialogue:OnTextTypeWriterFinish()
  if self.State == ACGAVGPlayableState.Finished then
    return
  end
  self.textTypeWriter = nil
  self.context.form:ShowArrow()
end

function AVGPlayableDialogue:OnClickContinue()
  local wait = false
  if self.textTypeWriter ~= nil then
    self.textTypeWriter:FinishShowText()
    self.textTypeWriter = nil
    wait = true
  end
  self.hasClickSkip = true
  if self.passedTime < self.duration then
    self.passedTime = self.duration
    wait = true
  end
  self.State = ACGAVGPlayableState.Finished
  return wait
end

function AVGPlayableDialogue:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if self.playingId == nil then
    if self.duration < self.passedTime then
      self:StopSpeek()
      self.State = ACGAVGPlayableState.Finished
    end
  elseif self.passedTime > 20 then
    self:StopSpeek()
    self.State = ACGAVGPlayableState.Finished
  end
end

function AVGPlayableDialogue:OnDestroy()
  if self.textTypeWriter ~= nil then
    self.textTypeWriter:FinishShowText()
    self.textTypeWriter = nil
  end
  self:StopSpeek()
  if self.playingId ~= nil then
    CS.UI.UILuaHelper.StopPlaySFX(self.playingId)
  end
  self.context.form:SwitchDialogueMode(0)
end

function AVGPlayableDialogue:OnPlaySFXStart(playingId)
  if 0 < playingId then
    self.playingId = playingId
  end
end

function AVGPlayableDialogue:OnPlaySFXFinish(playingId)
  if self.playingId == playingId then
    self.playingId = nil
    self.State = ACGAVGPlayableState.Finished
    self:StopSpeek()
  end
end

function AVGPlayableDialogue:StopSpeek()
  if self.playableData.DialogueRole >= 0 then
    local role = self.context:GetRole(self.playableData.DialogueRole)
    if role then
      role:StopSpeek()
    end
  end
end

return AVGPlayableDialogue
