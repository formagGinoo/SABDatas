local BaseManager = require("Manager/Base/BaseManager")
local StoryManager = class("StoryManager", BaseManager)

function StoryManager:OnCreate()
  self:addEventListener("eGameEvent_DialogueShow", handler(self, self.OnEventDialogueShow))
  self:addEventListener("eGameEvent_DialogueOptionShow", handler(self, self.OnEventDialogueOptionsShow))
  self:addEventListener("eGameEvent_DialogueChangeSkip", handler(self, self.OnEventDialogueChangeSkip))
  self:addEventListener("eGameEvent_DialogueCloseReview", handler(self, self.OnEventDialogueCloseReview))
  self:addEventListener("eGameEvent_DialogueCloseAutoAndManual", handler(self, self.OnEventDialogueCloseAutoAndManual))
  self:addEventListener("eGameEvent_DialogueDisableSpeedUp", handler(self, self.OnEventDialogueDisableSpeedUp))
  self:addEventListener("eGameEvent_DialogueCaptionsShow", handler(self, self.OnEventDialogueCaptionsShow))
  self:addEventListener("eGameEvent_DialogueCaptionsShowEnd", handler(self, self.OnEventDialogueCaptionsShowEnd))
  self:addEventListener("eGameEvent_TimelineStop", handler(self, self.OnTimelineStop))
end

function StoryManager:OnUpdate(dt)
end

function StoryManager:OnEventDialogueShow(message)
  StackSpecial:Push(UIDefines.ID_FORM_DIALOGUE)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUE)
  if form ~= nil then
    form:SetData(message)
  end
end

function StoryManager:OnEventDialogueOptionsShow(message)
  StackSpecial:Push(UIDefines.ID_FORM_DIALOGUE)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUE)
  if form ~= nil then
    form:SetOptions(message)
  end
end

function StoryManager:OnEventDialogueChangeSkip(bCanSkip)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUE)
  if form ~= nil then
    form:SetSkip(bCanSkip)
  end
end

function StoryManager:OnEventDialogueCloseReview(bCanReview)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUE)
  if form ~= nil then
    form:SetReview(bCanReview)
  end
end

function StoryManager:OnEventDialogueDisableSpeedUp(disable)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUE)
  if form ~= nil then
    form:SetDisableSpeedUp(disable)
  end
end

function StoryManager:OnEventDialogueCloseAutoAndManual(bCanAutoAndManual)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUE)
  if form ~= nil then
    form:SetAutoAndManual(bCanAutoAndManual)
  end
end

function StoryManager:OnTimelineStop()
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUE)
  if form ~= nil then
    form:OnTimelineEnd()
  end
end

function StoryManager:getAutoStatus()
  if self.m_bAuto == nil then
    self.m_bAuto = CS.UI.UILuaHelper.GetPlayerPreference("DialogueAuto") == 1 and true or false
  end
  return self.m_bAuto
end

function StoryManager:setAutoStatus(bAuto)
  self.m_bAuto = bAuto
  CS.UI.UILuaHelper.SetPlayerPreference("DialogueAuto", bAuto and 1 or 0)
end

function StoryManager:OnEventDialogueCaptionsShow(chapterTitle, chapterName, chapterContent, chapterNum, voice)
  StackSpecial:Push(UIDefines.ID_FORM_DIALOGUECAPTIONS)
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_DIALOGUECAPTIONS)
  if form ~= nil then
    form:SetData(chapterTitle, chapterName, chapterContent, chapterNum, voice)
  end
end

function StoryManager:OnEventDialogueCaptionsShowEnd()
  StackSpecial:RemoveUIFromStack(UIDefines.ID_FORM_DIALOGUECAPTIONS)
end

return StoryManager
