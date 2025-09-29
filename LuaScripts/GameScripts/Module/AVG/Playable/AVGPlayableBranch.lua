local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableBranch = class("AVGPlayableBranch", AVGPlayable)
local BranchStageType = {
  None = 0,
  Dialogue = 1,
  Choice = 2,
  WatiClick = 3
}

function AVGPlayableBranch:Waitable()
  return true
end

function AVGPlayableBranch:OnStart()
  self.stage = BranchStageType.Dialogue
  self:ShowDialogue()
end

function AVGPlayableBranch:ShowDialogue()
  local element = CS.CData_AVGDialogue.GetInstance():GetValue_ByID(self.playableData.Dialogue)
  if element:GetError() then
    self.stage = BranchStageType.Choice
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
  self.mouthLoopTimes = loopTimes
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

function AVGPlayableBranch:ShowOption()
  local optionList = {}
  self.optionGroup = {}
  local length = self.playableData.Branchs.Length
  local optionIndex = 1
  self.optionReviewData = {
    Type = 1,
    Options = {}
  }
  for i = 1, length do
    local branchIndex = self.playableData.Branchs[i - 1]
    local branch = self.context:GetBranch(branchIndex)
    if branch then
      self.optionGroup[optionIndex] = branch.Group
      local element = CS.CData_AVGDialogue.GetInstance():GetValue_ByID(branch.Content)
      local content = branch.Content
      if not element:GetError() then
        content = element.m_mContent
      end
      table.insert(optionList, content)
      table.insert(self.optionReviewData.Options, content)
      optionIndex = optionIndex + 1
    end
  end
  self.context.form:SetOptions(optionList, true, self, self.OnClickOption)
  self.stage = BranchStageType.WatiClick
end

function AVGPlayableBranch:OnClickOption(index)
  self.State = ACGAVGPlayableState.Finished
  local nextGroup = self.optionGroup[index]
  self.context:OnSkipGroup(nextGroup)
  if self.optionReviewData ~= nil then
    self.optionReviewData.SelectedIndex = index
    self.context:AddReviewData(self.DataIndex, self.optionReviewData)
  end
end

function AVGPlayableBranch:OnTextTypeWriterFinish()
  if self.State == ACGAVGPlayableState.Finished then
    return
  end
  if self.textTypeWriter then
    self.context.form:ShowArrow()
  end
  self.textTypeWriter = nil
end

function AVGPlayableBranch:OnClickContinue()
  if self.stage == BranchStageType.Dialogue then
    if self.textTypeWriter ~= nil then
      self.textTypeWriter:FinishShowText()
      self.textTypeWriter = nil
    end
    self:StopSpeek()
    if self.passedTime < self.duration then
      self.passedTime = self.duration
    end
    self.stage = BranchStageType.Choice
  end
  return true
end

function AVGPlayableBranch:OnUpdate(dt)
  if self.stage == BranchStageType.Dialogue then
    self:OnDialogueUpdate(dt)
  end
  if self.stage == BranchStageType.Choice then
    self:ShowOption()
  end
end

function AVGPlayableBranch:OnDialogueUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if (self.playingId == nil or self.passedTime > 20) and self.duration < self.passedTime and self.textTypeWriter == nil then
    self:StopSpeek()
    self.stage = BranchStageType.Choice
  end
end

function AVGPlayableBranch:OnDestroy()
  self:StopSpeek()
  if self.playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.playingId)
  end
  self.context.form:SwitchDialogueMode(0)
  if self.textTypeWriter ~= nil then
    self.textTypeWriter:FinishShowText()
    self.textTypeWriter = nil
  end
end

function AVGPlayableBranch:OnPlaySFXStart(playingId)
  if 0 < playingId then
    self.playingId = playingId
  end
end

function AVGPlayableBranch:OnPlaySFXFinish(playingId)
  if self.playingId == playingId then
    self.playingId = nil
    if self.playableData.DialogueRole >= 0 then
      local role = self.context:GetRole(self.playableData.DialogueRole)
      if role then
        role:SetSpeekMinTimes(self.mouthLoopTimes)
      end
    end
  end
end

function AVGPlayableBranch:StopSpeek()
  if self.playableData.DialogueRole >= 0 then
    local role = self.context:GetRole(self.playableData.DialogueRole)
    if role then
      role:StopSpeek()
    end
  end
end

return AVGPlayableBranch
