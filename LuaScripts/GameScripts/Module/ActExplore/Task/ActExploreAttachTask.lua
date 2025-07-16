local ActExploreAttachTask = class("ActExploreAttachTask")

function ActExploreAttachTask:ctor(targetID, node, offset, rotation)
  self.targetID = targetID
  self.nodeName = node
  self.offset = offset
  self.rotation = rotation
end

function ActExploreAttachTask:OnCreate(world, entityObj)
  local transform = entityObj.gameObject.transform
  if self.targetID == 0 then
    transform:SetParent(world.exploreManager.transform, false)
    local cfg = world.exploreManager:FindPoint(self.nodeName)
    if cfg then
      local rot = CS.UnityEngine.Quaternion.Euler(cfg.Transform.Rotation)
      local pos = cfg.Position + rot * self.offset
      rot = rot * self.rotation
      transform:SetPositionAndRotation(pos, rot)
    else
      transform:SetPositionAndRotation(self.offset, self.rotation)
    end
  else
    local target = world:FindObject(self.targetID)
    if target and target.gameObject then
      local node = CS.CommonExtensions.FindIteratively(target.gameObject.transform, self.nodeName)
      node = node or target.gameObject.transform
      transform:SetParent(node, false)
      transform:SetLocalPositionAndRotation(self.offset, self.rotation)
    else
      world:DestroyObject(entityObj)
    end
  end
end

return ActExploreAttachTask
