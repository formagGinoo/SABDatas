local Form_SpineInteract = class("Form_SpineInteract", require("UI/UIFrames/Form_SpineInteractUI"))

function Form_SpineInteract:SetInitParam(param)
end

function Form_SpineInteract:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1113)
  self._characterState = {
    state = 0,
    perfumeOn = false,
    weather = 0,
    elementState = {}
  }
  for k, v in pairs(self.parts) do
    self._characterState.elementState[k] = false
  end
  self._character = self.m_root_hero:GetComponentInChildren(typeof(CS.Plugins.Common.LoungeCharacter))
  self._character:Initialize()
  self._character:RegisterAnimationState("perfume_spurt_head")
  self._character:RegisterAnimationState("perfume_spurt_body")
  self._character:RegisterAnimationState("perfume_spurt_breast_l")
  self._character:RegisterAnimationState("perfume_spurt_breast_r")
  self._character:RegisterAnimationState("perfume_spurt_leg_l")
  self._character:RegisterAnimationState("perfume_spurt_leg_r")
  self._character:RegisterAnimationState("bite_climax")
  if self._character then
    self._renderer = self._character:GetComponent("Renderer")
    self._character:EventCallbacks("+", function(character, eventName, parameter)
      self:characterEventCallback(character, eventName, parameter)
    end)
  end
end

function Form_SpineInteract:OnActive()
  self.super.OnActive(self)
  local rootTrans = self.m_csui.m_uiGameObject.transform
  local canvas = rootTrans:GetComponent("Canvas")
  local orderInLayer = canvas.sortingOrder + 1
  self._renderer.sortingOrder = orderInLayer
  self:SetupRaycaster(canvas)
end

function Form_SpineInteract:OnInactive()
  self.super.OnInactive(self)
  self:RemoveRaycaster()
end

function Form_SpineInteract:SetupRaycaster(canvas)
  if canvas.worldCamera then
    self._raycaster = canvas.worldCamera.gameObject:AddComponent(typeof(CS.UnityEngine.EventSystems.Physics2DRaycaster))
  end
end

function Form_SpineInteract:RemoveRaycaster()
  if self._raycaster then
    CS.UnityEngine.Object.Destroy(self._raycaster)
    self._raycaster = nil
  end
end

function Form_SpineInteract:OnBackClk()
  self:CloseForm()
end

function Form_SpineInteract:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_SpineInteract:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_SpineInteract:characterEventCallback(character, eventName, parameter)
  print(eventName .. ":" .. parameter)
  local func
  if eventName == "Clicked" then
    func = self:getProcessClickFunction(parameter)
  elseif eventName == "PointerDown" then
    func = self:getProcessPointerDownFunction(parameter)
  elseif eventName == "PointerUp" then
    func = self:getProcessPointerUpFunction(parameter)
  elseif eventName == "AnimationStart" then
    func = self.processAnimationStateEnter
  elseif eventName == "AnimationEnd" then
    func = self.processAnimationStateExit
  end
  if func ~= nil then
    func(self, parameter)
  end
end

function Form_SpineInteract:isAllPartSet(elementType)
  for k, v in pairs(self.parts) do
    if v == elementType and not self._characterState.elementState[k] then
      return false
    end
  end
  return true
end

function Form_SpineInteract:enterCharacterState(state)
  self._characterState.state = state
  self._characterState.perfumeOn = false
  self._character.Animator:SetBool("perfume", false)
  self._character.Animator:SetInteger("state", state)
end

function Form_SpineInteract:processPartClicked(parameter)
  self._character.Animator:SetTrigger("touch_" .. parameter)
  if self._characterState.state == 0 then
    if not self._characterState.perfumeOn or self.parts[parameter] == self.elementTypes.PART then
    end
  elseif self._characterState.state == 1 then
  elseif self._characterState.state == 2 then
  end
end

function Form_SpineInteract:processPerfumeClicked(parameter)
  if self._characterState.state == 0 then
    self._characterState.perfumeOn = not self._characterState.perfumeOn
    self._character.Animator:SetBool("perfume", self._characterState.perfumeOn)
  end
end

function Form_SpineInteract:processGoldClicked(parameter)
  self._character.Animator:SetTrigger("touch_" .. parameter)
  if self._characterState.state == 1 then
    self._characterState.elementState[parameter] = true
    self._character.Animator:SetBool(parameter, true)
  end
end

function Form_SpineInteract:processPartPointerDown()
  if self._characterState.state == 1 and self:isAllPartSet(self.elementTypes.GOLD) then
    self._character.Animator:SetBool("bite", true)
  end
end

function Form_SpineInteract:processPartPointerUp()
  if self._characterState.state == 1 then
    self._character.Animator:SetBool("bite", false)
  end
end

function Form_SpineInteract:processAnimationStateEnter(parameter)
  if string.sub(parameter, 1, 14) == "perfume_spurt_" then
    local part = string.sub(parameter, 15)
    print("animstateenter" .. part)
  end
end

function Form_SpineInteract:processAnimationStateExit(parameter)
  if self._characterState.state == 0 then
    if string.sub(parameter, 1, 14) == "perfume_spurt_" then
      local part = string.sub(parameter, 15)
      print("animstateexit" .. part)
      if not self._characterState.elementState[part] then
        self._characterState.elementState[part] = true
        self._character.Animator:SetBool("sweet_" .. part, true)
      end
      if self:isAllPartSet(self.elementTypes.PART) then
        self:enterCharacterState(1)
      end
    end
  elseif self._characterState.state == 1 and parameter == "bite_climax" then
    self:enterCharacterState(2)
  end
end

function Form_SpineInteract:processUnknown(parameter)
  print("Unknown part" .. parameter)
end

function Form_SpineInteract:IsFullScreen()
  return true
end

Form_SpineInteract.elementTypes = {
  PART = 0,
  GOLD = 1,
  PERFUME = 2
}
Form_SpineInteract.processClickFunctions = {
  [Form_SpineInteract.elementTypes.PART] = Form_SpineInteract.processPartClicked,
  [Form_SpineInteract.elementTypes.GOLD] = Form_SpineInteract.processGoldClicked,
  [Form_SpineInteract.elementTypes.PERFUME] = Form_SpineInteract.processPerfumeClicked
}
Form_SpineInteract.processPointerDownFunctions = {
  [Form_SpineInteract.elementTypes.PART] = Form_SpineInteract.processPartPointerDown
}
Form_SpineInteract.processPointerUpFunctions = {
  [Form_SpineInteract.elementTypes.PART] = Form_SpineInteract.processPartPointerUp
}
Form_SpineInteract.parts = {
  head = Form_SpineInteract.elementTypes.PART,
  body = Form_SpineInteract.elementTypes.PART,
  breast_l = Form_SpineInteract.elementTypes.PART,
  breast_r = Form_SpineInteract.elementTypes.PART,
  leg_l = Form_SpineInteract.elementTypes.PART,
  leg_r = Form_SpineInteract.elementTypes.PART,
  perfume = Form_SpineInteract.elementTypes.PERFUME,
  gold1 = Form_SpineInteract.elementTypes.GOLD,
  gold2 = Form_SpineInteract.elementTypes.GOLD,
  gold3 = Form_SpineInteract.elementTypes.GOLD,
  gold4 = Form_SpineInteract.elementTypes.GOLD,
  gold5 = Form_SpineInteract.elementTypes.GOLD,
  gold6 = Form_SpineInteract.elementTypes.GOLD
}

function Form_SpineInteract:getProcessClickFunction(name)
  local elementType = self.parts[name]
  if elementType ~= nil then
    return self.processClickFunctions[elementType]
  end
  return self.processUnknown
end

function Form_SpineInteract:getProcessPointerDownFunction(name)
  local elementType = self.parts[name]
  if elementType ~= nil then
    return self.processPointerDownFunctions[elementType]
  end
  return self.processUnknown
end

function Form_SpineInteract:getProcessPointerUpFunction(name)
  local elementType = self.parts[name]
  if elementType ~= nil then
    return self.processPointerUpFunctions[elementType]
  end
  return self.processUnknown
end

local fullscreen = true
ActiveLuaUI("Form_SpineInteract", Form_SpineInteract)
return Form_SpineInteract
