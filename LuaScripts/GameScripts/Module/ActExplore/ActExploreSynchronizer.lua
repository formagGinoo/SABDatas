local ActExploreSynchronizer = class("ActExploreSynchronizer")

function ActExploreSynchronizer:GetState(uid)
  return 0
end

function ActExploreSynchronizer:GetObjectTransform(uid)
  return CS.UnityEngine.Vector3.zero, CS.UnityEngine.Quaternion.identity
end

function ActExploreSynchronizer:GetObjectCounter(uid)
  return nil
end

function ActExploreSynchronizer:GetData(uid)
  return nil
end

function ActExploreSynchronizer:OnCounterChange(uid, key, value)
end

function ActExploreSynchronizer:OnObjectCreate(uid, cfgID)
end

function ActExploreSynchronizer:SetObjectTransform(uid, position, rotation)
end

function ActExploreSynchronizer:TakeReward(cfgID)
end

function ActExploreSynchronizer:OnObjectDestroy(uid)
end

function ActExploreSynchronizer:SyncToServer()
end

return ActExploreSynchronizer
