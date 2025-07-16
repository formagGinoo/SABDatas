local meta = class("BaseObject")

function meta:initComponent()
end

function meta:getOrAddComponent(componentName, ...)
  local component = self:getComponent(componentName)
  component = component or self:addComponent(componentName, ...)
  return component
end

function meta:addComponent(componentName, ...)
  local mComponent = rawget(self, "mComponent")
  if not mComponent then
    mComponent = {}
    setmetatable(mComponent, {
      __index = self.mComponent
    })
    rawset(self, "mComponent", mComponent)
  end
  if not mComponent[componentName] then
    mComponent[componentName] = {}
  end
  self.m_iComponentId = checknumber(self.m_iComponentId) + 1
  local id = self.m_iComponentId
  local component = require("Component/" .. componentName).new(self)
  component:setId(id)
  table.insert(mComponent[componentName], {id = id, component = component})
  if component.OnLoad then
    component:OnLoad(...)
  end
  return component
end

function meta:getComponent(componentName)
  local mComponent = rawget(self, "mComponent")
  if mComponent then
    local vComponentList = mComponent[componentName]
    if vComponentList and 1 <= #vComponentList then
      return vComponentList[1].component
    end
  end
end

function meta:removeComponent(component)
  local mComponent = rawget(self, "mComponent")
  if mComponent then
    local vComponentList = mComponent[component:getName()]
    if vComponentList then
      for index, info in ipairs(vComponentList) do
        if info.id == component:getId() then
          if component.OnDestroy then
            component:OnDestroy()
          end
          table.remove(vComponentList, index)
          return
        end
      end
    end
  end
end

function meta:removeAllComponent()
  local mComponent = rawget(self, "mComponent")
  if mComponent then
    for _, vComponentList in pairs(mComponent) do
      for _, info in ipairs(vComponentList) do
        local component = info.component
        if component.OnDestroy then
          component:OnDestroy()
        end
      end
    end
    rawset(self, "mComponent", nil)
  end
end

function meta:doEvent(eventName, ...)
  local mComponent = rawget(self, "mComponent")
  if mComponent then
    for componentName, vComponentList in pairs(mComponent) do
      for _, info in ipairs(vComponentList) do
        local component = info.component
        if component[eventName] then
          component[eventName](component, ...)
        end
      end
    end
  end
  if self[eventName] then
    self[eventName](self, ...)
  end
end

return meta
