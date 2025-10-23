local LoungeCharacterState = class("LoungeCharacterState")

function LoungeCharacterState:ctor()
end

function LoungeCharacterState:setAnimatorTrigger(triggerName)
  if self.stateMachine.animator then
    self.stateMachine.animator:SetTrigger(triggerName)
  end
end

function LoungeCharacterState:setAnimatorTriggers(triggerNames)
  if self.stateMachine.animator then
    for _, v in ipairs(triggerNames) do
      self.stateMachine.animator:SetTrigger(v)
    end
  end
end

function LoungeCharacterState:resetAnimatorTrigger(triggerName)
  if self.stateMachine.animator then
    self.stateMachine.animator:ResetTrigger(triggerName)
  end
end

function LoungeCharacterState:resetAnimatorTriggers(triggerNames)
  if self.stateMachine.animator then
    for _, v in ipairs(triggerNames) do
      self.stateMachine.animator:ResetTrigger(v)
    end
  end
end

function LoungeCharacterState:setAnimatorBool(boolName, value)
  if self.stateMachine.animator then
    self.stateMachine.animator:SetBool(boolName, value)
  end
end

function LoungeCharacterState:setAnimatorBools(boolNames, value)
  if self.stateMachine.animator then
    for _, v in ipairs(boolNames) do
      self.stateMachine.animator:SetBool(v, value)
    end
  end
end

function LoungeCharacterState:setAnimatorInteger(intName, value)
  if self.stateMachine.animator then
    self.stateMachine.animator:SetInteger(intName, value)
  end
end

function LoungeCharacterState:setAnimatorIntegers(intName, value)
  if self.stateMachine.animator then
    for _, v in ipairs(intName) do
      self.stateMachine.animator:SetInteger(v, value)
    end
  end
end

function LoungeCharacterState:setAnimatorFloat(floatName, value)
  if self.stateMachine.animator then
    self.stateMachine.animator:SetFloat(floatName, value)
  end
end

function LoungeCharacterState:setAnimatorFloats(floatNames, value)
  if self.stateMachine.animator then
    for _, v in ipairs(floatNames) do
      self.stateMachine.animator:SetFloat(v, value)
    end
  end
end

function LoungeCharacterState:sendEvent(name, parameter)
  self.stateMachine:sendEvent(name, parameter)
end

function LoungeCharacterState:getData()
  return self.stateMachine.data
end

return LoungeCharacterState
