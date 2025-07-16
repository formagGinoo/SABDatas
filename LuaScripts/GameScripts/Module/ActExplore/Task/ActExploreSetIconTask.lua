local ActExploreSetIconTask = class("ActExploreSetIconTask")

function ActExploreSetIconTask:ctor(iconName)
  self.iconName = iconName
end

function ActExploreSetIconTask:OnCreate(world, entityObj)
  local height = 0
  if entityObj.element ~= nil then
    height = entityObj.element.m_IconHeight
  end
  if world.form then
    world.form:SetIcon(entityObj.gameObject, self.iconName, height)
  end
end

return ActExploreSetIconTask
