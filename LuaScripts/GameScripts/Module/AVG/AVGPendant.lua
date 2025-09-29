local AVGPendant = class("AVGPendant")

function AVGPendant:ctor(data, context)
  self.data = data
  self.context = context
  context:AddUIToLoadQueue(data.ResName)
end

function AVGPendant:Show()
  if not self.obj then
    local prefab = self.context:GetUIPrefab(self.data.ResName)
    if prefab then
      local root = self.context.form.m_pendant.transform
      if self.data.Layer == 1 then
        root = self.context.form.m_roles.transform
      end
      self.obj = CS.UnityEngine.GameObject.Instantiate(prefab, root)
    end
  end
  if self.obj then
    self.obj:SetActive(true)
  end
end

function AVGPendant:PlayAnimation(name)
  if self.obj then
    CS.UI.UILuaHelper.PlayAnimationByName(self.obj, name, 1, 0)
  end
end

function AVGPendant:Hide()
  if self.obj then
    self.obj:SetActive(false)
  end
end

function AVGPendant:Destroy()
  if self.obj then
    CS.UnityEngine.GameObject.Destroy(self.obj)
    self.obj = nil
  end
end

return AVGPendant
