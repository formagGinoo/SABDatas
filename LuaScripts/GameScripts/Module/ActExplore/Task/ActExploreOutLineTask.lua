local ActExploreOutLineTask = class("ActExploreOutLineTask")

function ActExploreOutLineTask:ctor(active)
  self.active = active
end

function ActExploreOutLineTask:OnCreate(world, entityObj)
  local mpo = CS.MaterialPropertyOverride.Get(entityObj.gameObject)
  if mpo then
    if self.active then
      mpo:SetFloat("_OutlineWidth", 1)
    else
      mpo:SetFloat("_OutlineWidth", 0)
    end
  end
end

return ActExploreOutLineTask
