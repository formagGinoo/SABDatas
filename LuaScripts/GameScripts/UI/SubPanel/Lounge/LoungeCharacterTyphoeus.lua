local LoungeCharacterStateMachine = require("UI/SubPanel/Lounge/LoungeCharacterStateMachine")
local LoungeCharacterState = require("UI/SubPanel/Lounge/LoungeCharacterState")
local LoungeCharacterTyphoeus = class("LoungeCharacterTyphoeus", LoungeCharacterStateMachine)
LoungeCharacterTyphoeus.ElementTypes = {
  NONE = 0,
  PART = 1,
  GOLD = 2,
  PERFUME = 3
}
LoungeCharacterTyphoeus.elements = {
  head = LoungeCharacterTyphoeus.ElementTypes.PART,
  body = LoungeCharacterTyphoeus.ElementTypes.PART,
  breast_l = LoungeCharacterTyphoeus.ElementTypes.PART,
  breast_r = LoungeCharacterTyphoeus.ElementTypes.PART,
  leg_l = LoungeCharacterTyphoeus.ElementTypes.PART,
  leg_r = LoungeCharacterTyphoeus.ElementTypes.PART,
  perfume = LoungeCharacterTyphoeus.ElementTypes.PERFUME,
  gold_01 = LoungeCharacterTyphoeus.ElementTypes.GOLD,
  gold_02 = LoungeCharacterTyphoeus.ElementTypes.GOLD,
  gold_03 = LoungeCharacterTyphoeus.ElementTypes.GOLD,
  gold_04 = LoungeCharacterTyphoeus.ElementTypes.GOLD,
  gold_05 = LoungeCharacterTyphoeus.ElementTypes.GOLD,
  gold_06 = LoungeCharacterTyphoeus.ElementTypes.GOLD
}
LoungeCharacterTyphoeus.ikControllers = {
  head = "head_control",
  body = "body_control",
  breast_l = "breast_l_control",
  breast_r = "breast_r_control",
  foot_r = "foot_r_control",
  leg_l = "leg_l_control",
  leg_r = "leg_r_control"
}
LoungeCharacterTyphoeus.interestedAnimationStates = {
  "perfume_spurt_head",
  "perfume_spurt_body",
  "perfume_spurt_breast_l",
  "perfume_spurt_breast_r",
  "perfume_spurt_leg_l",
  "perfume_spurt_leg_r",
  "bite_climax",
  "idle_01",
  "touch_body_01",
  "touch_breast_l_01",
  "touch_breast_r_01",
  "touch_head_01",
  "touch_leg_l_01",
  "touch_leg_r_01",
  "touch_refuse",
  "perfume_idle_01",
  "touch_sweat_body",
  "touch_sweat_breast_l",
  "touch_sweat_breast_r",
  "touch_sweat_head",
  "touch_sweat_leg_l",
  "touch_sweat_leg_r"
}
LoungeCharacterTyphoeus.weathers = {
  idle_01 = "weather_normal_idle",
  touch_body_01 = "weather_angry_idle",
  touch_breast_l_01 = "weather_normal_idle",
  touch_breast_r_01 = "weather_angry_idle",
  touch_head_01 = "weather_normal_idle",
  touch_leg_l_01 = "weather_normal_idle",
  touch_leg_r_01 = "weather_normal_idle",
  touch_refuse = "weather_angry_idle",
  perfume_idle_01 = "weather_normal_idle",
  perfume_spurt_body = "weather_angry_idle",
  perfume_spurt_breast_l = "weather_happy_idle",
  perfume_spurt_breast_r = "weather_happy_idle",
  perfume_spurt_head = "weather_angry_idle",
  perfume_spurt_leg_l = "weather_normal_idle",
  perfume_spurt_leg_r = "weather_normal_idle",
  touch_sweat_body = "weather_angry_idle",
  touch_sweat_breast_l = "weather_happy_idle",
  touch_sweat_breast_r = "weather_happy_idle",
  touch_sweat_head = "weather_angry_idle",
  touch_sweat_leg_l = "weather_normal_idle",
  touch_sweat_leg_r = "weather_normal_idle"
}
LoungeCharacterTyphoeus.weatherAnimationId = {
  weather_normal_idle = 0,
  weather_happy_idle = 1,
  weather_angry_idle = 2
}

function LoungeCharacterTyphoeus:getElementType(elementName)
  local type = self.elements[elementName]
  if type == nil then
    return self.ElementTypes.NONE
  end
  return type
end

function LoungeCharacterTyphoeus:getElementsByType(elementType)
  local elements = {}
  for elementName, type in pairs(self.elements) do
    if type == elementType then
      table.insert(elements, elementName)
    end
  end
  return elements
end

function LoungeCharacterTyphoeus:getWeatherIdByAnimation(animName)
  local weather = self.weathers[animName]
  if weather ~= nil then
    return self.weatherAnimationId[weather]
  end
  return nil
end

function LoungeCharacterTyphoeus:getAllElements()
  local elements = {}
  for elementName, _ in pairs(self.elements) do
    table.insert(elements, elementName)
  end
  return elements
end

local DefaultState = class("DefaultState", LoungeCharacterState)

function DefaultState:enter()
  local data = self:getData()
  data.state = 1
  self:setAnimatorInteger("state", 0)
  local parts = self.stateMachine:getElementsByType(LoungeCharacterTyphoeus.ElementTypes.PART)
  for _, v in ipairs(parts) do
    self:setAnimatorBool("sweet_" .. v, data[v] or false)
  end
  local golds = self.stateMachine:getElementsByType(LoungeCharacterTyphoeus.ElementTypes.GOLD)
  self:setAnimatorBools(golds, false)
  self.perfumeOn = false
  self:setAnimatorBool("perfumeOn", false)
  self:sendEvent("HideBiteButton")
end

function DefaultState:exit()
end

function DefaultState:handleEvent(name, parameter)
  if name == "Clicked" then
    local elementType = self.stateMachine:getElementType(parameter)
    if elementType == LoungeCharacterTyphoeus.ElementTypes.PART then
      if self.perfumeOn then
        self:setAnimatorTrigger("perfume_spurt_" .. parameter)
      else
        self:setAnimatorTrigger("touch_" .. parameter)
      end
    elseif elementType == LoungeCharacterTyphoeus.ElementTypes.GOLD then
      self:setAnimatorTrigger("touch_refuse")
    elseif elementType == LoungeCharacterTyphoeus.ElementTypes.PERFUME then
      self.perfumeOn = not self.perfumeOn
      self:setAnimatorBool("perfumeOn", self.perfumeOn)
    end
  elseif name == "AnimationStart" then
    self:updateWeather(parameter)
  elseif name == "AnimationEnd" and string.startsWith(parameter, "perfume_spurt_") then
    local elementName = string.sub(parameter, string.len("perfume_spurt_") + 1)
    local data = self:getData()
    data[elementName] = true
    self:setAnimatorBool("sweet_" .. elementName, self.perfumeOn)
    if self:isAllPartSweet() then
      self.stateMachine:changeState("CollectGoldState")
    end
  end
end

function DefaultState:updateWeather(animName)
  local weatherId = self.stateMachine:getWeatherIdByAnimation(animName)
  if weatherId ~= nil then
    self:setAnimatorInteger("weather", weatherId)
  end
end

function DefaultState:isAllPartSweet()
  local data = self:getData()
  for elementName, elementType in pairs(self.stateMachine.elements) do
    if elementType == LoungeCharacterTyphoeus.ElementTypes.PART and not data[elementName] then
      return false
    end
  end
  return true
end

local CollectGoldState = class("CollectGoldState", LoungeCharacterState)

function CollectGoldState:enter()
  local data = self:getData()
  data.state = 2
  self:setAnimatorInteger("state", 1)
  local parts = self.stateMachine:getElementsByType(LoungeCharacterTyphoeus.ElementTypes.PART)
  for _, v in ipairs(parts) do
    self:setAnimatorBool("sweet_" .. v, true)
  end
  local golds = self.stateMachine:getElementsByType(LoungeCharacterTyphoeus.ElementTypes.GOLD)
  for _, v in ipairs(golds) do
    self:setAnimatorBool(v, data[v] or false)
  end
  self:setAnimatorBool("perfumeOn", false)
  self:setAnimatorInteger("weather", 0)
  self:sendEvent("HideBiteButton")
end

function CollectGoldState:exit()
end

function CollectGoldState:handleEvent(name, parameter)
  if name == "Clicked" then
    local elementType = self.stateMachine:getElementType(parameter)
    if elementType == LoungeCharacterTyphoeus.ElementTypes.PART then
      self:setAnimatorTrigger("touch_" .. parameter)
    elseif elementType == LoungeCharacterTyphoeus.ElementTypes.GOLD then
      local data = self:getData()
      self:setAnimatorBool(parameter, true)
      data[parameter] = true
      if self:isAllGoldCollected() then
        self.stateMachine:changeState("BiteState")
      end
    end
  end
end

function CollectGoldState:isAllGoldCollected()
  local data = self:getData()
  for elementName, elementType in pairs(self.stateMachine.elements) do
    if elementType == LoungeCharacterTyphoeus.ElementTypes.GOLD and not data[elementName] then
      return false
    end
  end
  return true
end

local BiteState = class("BiteState", LoungeCharacterState)

function BiteState:enter()
  local data = self:getData()
  data.state = 3
  self:setAnimatorInteger("state", 2)
  local parts = self.stateMachine:getElementsByType(LoungeCharacterTyphoeus.ElementTypes.PART)
  for _, v in ipairs(parts) do
    self:setAnimatorBools("sweet_" .. v, true)
  end
  local golds = self.stateMachine:getElementsByType(LoungeCharacterTyphoeus.ElementTypes.GOLD)
  self:setAnimatorBools(golds, true)
  self:setAnimatorBool("perfumeOn", false)
  self:setAnimatorInteger("weather", 0)
  self:sendEvent("ShowBiteButton")
end

function BiteState:exit()
end

function BiteState:handleEvent(name, parameter)
  if name == "Clicked" then
    local elementType = self.stateMachine:getElementType(parameter)
    if elementType == LoungeCharacterTyphoeus.ElementTypes.PART then
      self:setAnimatorTrigger("touch_" .. parameter)
    end
  elseif name == "PointerDown" then
    if parameter == "Bite" then
      self:setAnimatorTrigger("bite")
      self:setAnimatorBool("biteOn", true)
    end
  elseif name == "PointerUp" then
    if parameter == "Bite" then
      self:setAnimatorBool("biteOn", false)
    end
  elseif name == "AnimationEnd" and parameter == "bite_climax" then
    self.stateMachine:changeState("ClimaxState")
  end
end

local ClimaxState = class("ClimaxState", LoungeCharacterState)

function ClimaxState:enter()
  local data = self:getData()
  data.state = 4
  self:setAnimatorInteger("state", 3)
  local parts = self.stateMachine:getElementsByType(LoungeCharacterTyphoeus.ElementTypes.PART)
  for _, v in ipairs(parts) do
    self:setAnimatorBools("sweet_" .. v, true)
  end
  local golds = self.stateMachine:getElementsByType(LoungeCharacterTyphoeus.ElementTypes.GOLD)
  self:setAnimatorBools(golds, true)
  self:setAnimatorBool("perfumeOn", false)
  self:setAnimatorInteger("weather", 0)
  self:sendEvent("HideBiteButton")
end

function ClimaxState:exit()
end

function ClimaxState:handleEvent(name, parameter)
  if name == "Clicked" then
    local elementType = self.stateMachine:getElementType(parameter)
    if elementType == LoungeCharacterTyphoeus.ElementTypes.PART then
      self:setAnimatorTrigger("touch_" .. parameter)
    end
  end
end

LoungeCharacterTyphoeus.stateClasses = {
  DefaultState,
  CollectGoldState,
  BiteState,
  ClimaxState
}

function LoungeCharacterTyphoeus:restoreState(data)
  self.data = data
  local stateIndex = data.state or 1
  local stateName = self.stateClasses[stateIndex].getName()
  self:changeState(stateName)
end

return LoungeCharacterTyphoeus
