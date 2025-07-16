local ActExploreInteractiveChange = class("ActExploreInteractiveChange")

function ActExploreInteractiveChange:ctor(id, type, position, center, radius, isTrigger)
  self.ID = id
  self.Type = type
  self.Position = position
  self.Center = center or CS.UnityEngine.Vector3.zero
  self.Radius = radius
  self.IsTrigger = isTrigger
end

function ActExploreInteractiveChange:OnCreate(world, entityObj)
  if entityObj.playerInteractive then
    if self.Type == 0 then
      if self.IsTrigger then
        entityObj.playerInteractive:AddTrigger(self.ID, self.Position, self.Center, self.Radius)
      else
        entityObj.playerInteractive:AddInteractive(self.ID, self.Position, self.Center, self.Radius)
      end
    elseif self.Type == 1 then
      entityObj.playerInteractive:SetInteractiveEnable(self.ID, true)
    elseif self.Type == 2 then
      entityObj.playerInteractive:SetInteractiveEnable(self.ID, false)
    elseif self.Type == 3 then
      entityObj.playerInteractive:RemoveInteractive(self.ID)
    end
  end
end

return ActExploreInteractiveChange
