local LoungeCharacterBase = class("LoungeCharacterBase")
local LoungeFavorability = require("UI/SubPanel/Lounge/LoungeFavorability")

function LoungeCharacterBase:init(characterId, character, ui)
  self._characterId = characterId
  self._character = character
  self._animator = character:GetComponent("Animator")
  self._ui = ui
  self.eventMap = {
    Clicked = handler(self, self._onCharacterClicked),
    PointerDown = handler(self, self._onCharacterPointerDown),
    PointerUp = handler(self, self._onCharacterPointerUp),
    SaveState = handler(self, self._saveState),
    ShowBiteButton = handler(self, self._showBiteButton),
    HideBiteButton = handler(self, self._hideBiteButton),
    BiteStart = handler(self, self._biteStart),
    BiteEnd = handler(self, self._biteEnd),
    Bite = handler(self, self._bite),
    EnterIdle = handler(self, self._enterIdle),
    ExitIdle = handler(self, self._exitIdle)
  }
  self.actionMap = {
    Subtitle = handler(self, self._showSubtitle),
    Target = handler(self, self._showTarget),
    AddFavorability = handler(self, self._addFavorability),
    SetGuidePoints = handler(self, self._setGuidePoints),
    PlaySound = handler(self, self._playSound)
  }
  
  function self._character.EventCallback(character, eventName, param1, param2)
    local handlerFunc = self.eventMap[eventName]
    if handlerFunc then
      handlerFunc(eventName, param1, param2)
    end
  end
  
  function self._character.ActionExecutor(character, actionName, param1, param2)
    local executorFunc = self.actionMap[actionName]
    if executorFunc then
      executorFunc(actionName, param1, param2)
    end
  end
  
  self._favorability = LoungeFavorability.new(100)
end

function LoungeCharacterBase:saveState(state)
  if state == nil then
    state = self._animator:GetInteger("state")
  end
  LoungeManager:saveHeroState(self._characterId, tostring(state))
end

function LoungeCharacterBase:restoreState()
  local stateStr = LoungeManager:loadHeroState(self._characterId)
  local state = tonumber(stateStr) or 0
  self._favorability:loadState(self._characterId)
  if self._ui.setFavorabilityUI then
    self._ui:setFavorabilityUI(self._favorability:getPercent(), false)
  end
  self._character:ResetAnimations()
  if self._animator then
    self._animator:SetInteger("state", state or 0)
    self._animator:Update(1.0)
  end
end

function LoungeCharacterBase:reset()
  self:saveState(0)
  self._favorability:clear()
  self._favorability:saveState(self._characterId)
  self:restoreState()
  if self._ui.setFavorabilityUI then
    self._ui:setFavorabilityUI(self._favorability:getPercent(), false)
  end
  if self._ui.resetGuidePointTimer then
    self._ui:resetGuidePointTimer()
  end
end

function LoungeCharacterBase:bitePressed()
  if self._ui.resetGuidePointTimer then
    self._ui:resetGuidePointTimer()
  end
  if self._animator then
    self._animator:SetBool("biteOn", true)
    self._animator:SetTrigger("bite")
  end
end

function LoungeCharacterBase:biteReleased()
  if self._animator then
    self._animator:SetBool("biteOn", false)
  end
end

function LoungeCharacterBase:_onCharacterClicked(eventName, param1, param2)
  self._animator:SetTrigger("touch_" .. param1)
  if self._ui.resetGuidePointTimer then
    self._ui:resetGuidePointTimer()
  end
end

function LoungeCharacterBase:_onCharacterPointerUp(eventName, param1, param2)
  if self._ui.resetGuidePointTimer then
    self._ui:resetGuidePointTimer()
  end
end

function LoungeCharacterBase:onCharacterPointerUp(eventName, param1, param2)
  if self._ui.resetGuidePointTimer then
    self._ui:resetGuidePointTimer()
  end
end

function LoungeCharacterBase:_showSubtitle(actionName, param1, param2)
  if self._ui.showSubtitle then
    self._ui:showSubtitle(param1, param2)
  end
end

function LoungeCharacterBase:_showBiteButton(actionName, param1, param2)
  if self._ui.showBiteButton then
    self._ui:showBiteButton(true)
  end
end

function LoungeCharacterBase:_hideBiteButton(actionName, param1, param2)
  if self._ui.showBiteButton then
    self._ui:showBiteButton(false)
  end
end

function LoungeCharacterBase:_biteStart(actionName, param1, param2)
  if self._ui.biteStart then
    self._ui:biteStart()
  end
end

function LoungeCharacterBase:_biteEnd(actionName, param1, param2)
  if self._ui.biteEnd then
    self._ui:biteEnd()
  end
end

function LoungeCharacterBase:_bite(actionName, param1, param2)
  if self._ui.bite then
    self._ui:bite()
  end
end

function LoungeCharacterBase:_showTarget(actionName, param1, param2)
  if self._ui.showTarget then
    local targetId = tonumber(param1) or 0
    local popup = param2 == "true" or param2 == "1"
    self._ui:showTarget(targetId, popup)
  end
end

function LoungeCharacterBase:_addFavorability(actionName, param1, param2)
  local cfg = string.split(param1, ";")
  if #cfg ~= 3 then
    print("Invalid favorability config: " .. param1)
    return
  end
  local score = tonumber(cfg[1]) or 0
  local times = tonumber(cfg[2]) or 0
  local max = tonumber(cfg[3]) or 0
  local scoreToAdd = self._favorability:addFavorability(param2, score, times, max)
  if scoreToAdd ~= 0 then
    local percent = self._favorability:getPercent()
    self._favorability:saveState(self._characterId)
    self._ui:setFavorabilityUI(percent, true)
  end
end

function LoungeCharacterBase:_setGuidePoints(actionName, param1, param2)
  local guidePoints
  if param1 ~= nil and param1 ~= "" then
    guidePoints = string.split(param1, ";")
  end
  if self._ui.setGuidePoints then
    self._ui:setGuidePoints(guidePoints)
  end
end

function LoungeCharacterBase:_saveState(actionName, param1, param2)
  local state = tonumber(param1)
  self:saveState(state)
end

function LoungeCharacterBase:_playSound(actionName, param1, param2)
  local soundName = param1
  if soundName ~= nil and soundName ~= "" then
    UILuaHelper.StartPlaySFX(soundName, nil, nil, nil)
  end
end

function LoungeCharacterBase:_enterIdle()
  self._character:EnableIKControllers(true)
end

function LoungeCharacterBase:_exitIdle()
  self._character:EnableIKControllers(false)
end

function LoungeCharacterBase:dispose()
  if self._character ~= nil then
    self._character.EventCallback = nil
    self._character.ActionExecutor = nil
    self._character = nil
  end
  self._ui = nil
  self._animator = nil
end

return LoungeCharacterBase
