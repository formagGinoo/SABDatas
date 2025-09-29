local AVGRole = class("AVGRole")

function AVGRole:ctor(data, context)
  self.speekLoopTimes = 0
  self.roleData = CS.AVGLoader.LoadRoleData(data.ResName)
  self.context = context
  local template = self.context.form.m_role
  self.root = GameObject.Instantiate(template, self.context.form.m_roles.transform).transform
  self.fadeGroup = self.root:GetComponent("CanvasGroup")
  self.bodyImage = self.root:Find("body"):GetComponent(T_Image)
  self.animation = self.root:Find("body"):GetComponent(T_Animation)
  self.bodyImage.type = CS.UnityEngine.UI.Image.Type.Simple
  self.headImage = self.bodyImage.transform:Find("head"):GetComponent(T_Image)
  self.eyeImage = self.headImage.transform:Find("eye"):GetComponent(T_Image)
  self.mouthImage = self.headImage.transform:Find("mouth"):GetComponent(T_Image)
  self.scale = 1
  self.startScale = self.root.localScale
  local T_Hole = typeof(CS.ImageHoleEffect)
  self.bodyHole = self.bodyImage.gameObject:AddComponent(T_Hole)
  self.headHole = self.headImage.gameObject:AddComponent(T_Hole)
  self.bodyHole.Hole = self.headImage
  self.headHole.Hole = self.eyeImage
  self.currentColor = CS.UnityEngine.Color.white
  self.preColor = CS.UnityEngine.Color.white
  self.material = GameObject.Instantiate(self.bodyImage.material)
  self.bodyImage.material = self.material
  self.headImage.material = self.material
  self.eyeImage.material = self.material
  self.mouthImage.material = self.material
  self.bodyImage.enabled = false
  self.headImage.enabled = false
  self.eyeImage.enabled = false
  self.mouthImage.enabled = false
  self.bodySize = self.roleData.RoleImgSize
  self.root.sizeDelta = self.bodySize
  self.bodyImage.transform.sizeDelta = self.bodySize
  self.headScale = CS.UnityEngine.Vector3(1, 1, 1)
  self.faceName = ""
  self.faceData = nil
  self.eyeIndex = 0
  self.eyeTime = 0
  self.mouthIndex = 0
  self.mouthTime = 0
  self.context:AddSpriteToLoadQueue(self.roleData.RoleRes)
  local pos = self:GetPositionByName(data.InitPos)
  self:SetPosition(pos)
  if data.InitPos ~= "OutLeft" and data.InitPos ~= "OutRight" then
    self:SetVisable(true)
  else
    self:SetVisable(false)
  end
end

function AVGRole:GetPositionByName(name)
  if name == "OutLeft" then
    local parent = self.root.parent
    local rect = parent.rect
    local x = -rect.width / 2 - self.bodySize.x * 1.1
    return CS.UnityEngine.Vector2(x, 0)
  elseif name == "OutRight" then
    local parent = self.root.parent
    local rect = parent.rect
    local x = rect.width / 2 + self.bodySize.x * 1.1
    return CS.UnityEngine.Vector2(x, 0)
  end
  return self.context.form:GetRolePos(name)
end

function AVGRole:LoadFaceRes(face)
  local faceData = self.roleData:FindFaceData(face)
  if faceData then
    self.context:AddSpriteToLoadQueue(faceData.HeadRes)
    self:LoadFaceAnimationRes(faceData.Eye)
    self:LoadFaceAnimationRes(faceData.Mouth)
  end
end

function AVGRole:LoadFaceAnimationRes(animationData)
  local length = animationData.Sprites.Length
  for i = 1, length do
    local sprite = animationData.Sprites[i - 1]
    self.context:AddSpriteToLoadQueue(sprite)
  end
end

function AVGRole:SetVisable(visable)
  self.root.gameObject:SetActive(visable)
  if visable then
    self.bodyImage.sprite = self.context:GetSprite(self.roleData.RoleRes)
  end
end

function AVGRole:OnInitResLoadFinished()
  self.bodyImage.sprite = self.context:GetSprite(self.roleData.RoleRes)
  self.bodyImage.enabled = self.bodyImage.sprite ~= nil
end

function AVGRole:PlayAnimation(name)
  if self.animation then
    CS.UI.UILuaHelper.PlayAnimationByName(self.animation, name, 1, 0)
    return CS.UI.UILuaHelper.GetAnimationPlayingTime(self.animation, name)
  end
  return 0
end

function AVGRole:SetColor(color)
  self.preColor = self.currentColor
  self.currentColor = color
end

function AVGRole:LerpColor(p)
  local color = CS.UnityEngine.Color.Lerp(self.preColor, self.currentColor, p)
  self.material:SetColor("_Color", color)
end

function AVGRole:PlayFace(face)
  if self.faceName == face then
    return
  end
  self.faceName = face
  self.faceData = self.roleData:FindFaceData(face)
  if not self.faceData then
    self.headImage.enabled = false
    self.eyeImage.enabled = false
    self.mouthImage.enabled = false
    self.bodyHole:SetDirty()
    self.headHole:SetDirty()
    return
  end
  local headSize = self.faceData.HeadImgSize
  local noneHead = string.isnullorempty(self.faceData.HeadRes)
  local overrideSize = self.faceData.OverrideSize
  if not noneHead and overrideSize.x > 1 then
    self.headScale.x = overrideSize.x / headSize.x
    self.headScale.y = overrideSize.y / headSize.y
  else
    self.headScale.x = 1
    self.headScale.y = 1
  end
  self.headImage.transform.sizeDelta = headSize
  self.headImage.transform.anchoredPosition = CS.UnityEngine.Vector2(self.faceData.Offset.x, -self.faceData.Offset.y)
  self.headImage.transform.localScale = self.headScale
  local headSprite = self.context:GetSprite(self.faceData.HeadRes)
  self.headImage.sprite = headSprite
  self.headImage.enabled = headSprite ~= nil
  self.eyeImage.transform.anchoredPosition = CS.UnityEngine.Vector2(self.faceData.Eye.Offset.x, -self.faceData.Eye.Offset.y)
  self.eyeImage.transform.sizeDelta = self.faceData.Eye.Size
  self.eyeImage.enabled = false
  self.eyeImage.sprite = nil
  self.eyeIndex = -1
  self.eyeTime = self.faceData.Eye.Interval
  self.mouthImage.transform.anchoredPosition = CS.UnityEngine.Vector2(self.faceData.Mouth.Offset.x, -self.faceData.Mouth.Offset.y)
  self.mouthImage.transform.sizeDelta = self.faceData.Mouth.Size
  self.mouthImage.enabled = false
  self.mouthImage.sprite = nil
  self.mouthIndex = -1
  self.mouthTime = 0
  self.speekLoopTimes = 0
  if noneHead then
    self.bodyHole.Hole = self.eyeImage
    self.headHole.Hole = nil
  else
    self.bodyHole.Hole = self.headImage
    self.headHole.Hole = self.eyeImage
  end
  self.bodyHole:SetDirty()
  self.headHole:SetDirty()
end

function AVGRole:SetFade(value)
  self.fadeGroup.alpha = value
end

function AVGRole:SetPosition(v)
  self.root.anchoredPosition = v
end

function AVGRole:GetPosition()
  return self.root.anchoredPosition
end

function AVGRole:GetScale()
  return self.scale
end

function AVGRole:SetScale(v)
  self.scale = v
  self.root.localScale = self.startScale * v
end

function AVGRole:SetSpeekTimes(loopTimes)
  self.mouthIndex = -1
  self.mouthTime = 0
  self.loopTimes = 0
  self.mouthImage.sprite = nil
  self.mouthImage.enabled = false
  self.speekLoopTimes = loopTimes
end

function AVGRole:SetSpeekMinTimes(loopTimes)
  if loopTimes < self.loopTimes then
    self.speekLoopTimes = 1
  else
    self.speekLoopTimes = math.max(loopTimes - self.loopTimes, 1)
  end
end

function AVGRole:StopSpeek()
  if self.speekLoopTimes ~= 0 then
    self.speekLoopTimes = 1
  end
end

function AVGRole:Update(dt)
  if self.faceData ~= nil then
    self.eyeTime = self.eyeTime - dt
    if self.eyeTime <= 0 then
      self.eyeIndex = self.eyeIndex + 1
      self.eyeTime = self.faceData.Eye.Interval
      if self.eyeIndex >= self.faceData.Eye.Sprites.Length then
        self.eyeIndex = -1
        self.eyeTime = self.roleData.EyePauseDuration
      end
      if 0 <= self.eyeIndex then
        local sprite = self.faceData.Eye.Sprites[self.eyeIndex]
        self.eyeImage.sprite = self.context:GetSprite(sprite)
      else
        self.eyeImage.sprite = nil
      end
      self.eyeImage.enabled = self.eyeImage.sprite ~= nil
      self.headHole:SetDirty()
    end
    if self.speekLoopTimes ~= 0 then
      self.mouthTime = self.mouthTime + dt
      if self.mouthTime >= self.faceData.Mouth.Interval then
        self.mouthTime = 0
        self.mouthIndex = self.mouthIndex + 1
        if self.mouthIndex >= self.faceData.Mouth.Sprites.Length then
          self.mouthIndex = -1
          self.speekLoopTimes = self.speekLoopTimes - 1
          self.mouthTime = self.loopTimes + 1
        end
        if self.speekLoopTimes == 0 then
          self.mouthIndex = -1
          self.mouthTime = 0
          self.mouthImage.enabled = false
        else
          if 0 <= self.mouthIndex then
            local sprite = self.faceData.Mouth.Sprites[self.mouthIndex]
            self.mouthImage.sprite = self.context:GetSprite(sprite)
          else
            self.mouthImage.sprite = nil
          end
          self.mouthImage.enabled = self.mouthImage.sprite ~= nil
        end
      end
    end
  end
end

function AVGRole:Destroy()
  if self.root then
    GameObject.Destroy(self.root.gameObject)
    self.root = nil
  end
end

return AVGRole
