local CharacterStateMachine = class("CharacterStates")

function CharacterStateMachine:ctor()
  self.data = {}
  self.states = {}
end

function CharacterStateMachine:init(character, eventCallback)
  self.character = character
  self.animator = character.Animator
  self.eventCallback = eventCallback
  if self.stateClasses then
    for _, stateClass in ipairs(self.stateClasses) do
      local stateInstance = stateClass.new()
      self:registerState(stateInstance)
    end
  end
  if self.interestedAnimationStates then
    for _, v in ipairs(self.interestedAnimationStates) do
      self.character:RegisterAnimationState(v)
    end
  end
end

function CharacterStateMachine:dispose()
  if self.currentState and self.currentState.exit then
    self.currentState:exit()
  end
  self.currentState = nil
  self.states = {}
  self.character = nil
end

function CharacterStateMachine:registerState(state)
  local stateName = state:getName()
  self.states[stateName] = state
  state.stateMachine = self
  self.currentState = nil
end

function CharacterStateMachine:unregisterState(stateName)
  self.states[stateName] = nil
end

function CharacterStateMachine:update()
  if self.currentState and self.currentState.update then
    self.currentState:update()
  end
end

function CharacterStateMachine:changeState(stateName)
  local newState = self.states[stateName]
  if newState then
    if self.currentState and self.currentState.exit then
      self.currentState:exit()
    end
    self.currentState = newState
    if self.currentState.enter then
      self.currentState:enter()
    end
  else
    print("State " .. stateName .. " does not exist.")
  end
end

function CharacterStateMachine:restoreState(data)
end

function CharacterStateMachine:handleEvent(eventName, parameter)
  if self.currentState and self.currentState.handleEvent then
    self.currentState:handleEvent(eventName, parameter)
  end
end

function CharacterStateMachine:sendEvent(eventName, paramter)
  if self.eventCallback then
    self.eventCallback(eventName, paramter)
  end
end

return CharacterStateMachine
