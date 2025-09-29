local AVGContext = class("AVGContext")
AVGStageType = {
  InitLoading = 0,
  Playing = 1,
  Finished = 2
}

function AVGContext:Init(name, form)
  self.reviewList = {}
  self.playingSounds = {}
  self.postProfiles = {}
  self.assetIndex = {}
  self.Stage = AVGStageType.InitLoading
  self.spriteLoader = CS.AVGSpriteLoader.Create()
  self.form = form
  self.data = CS.AVGLoader.LoadAVGData(name)
  local roleClass = require("Module/AVG/AVGRole")
  self.roles = {}
  local length = self.data.Roles.Length
  for i = 1, length do
    local roleData = self.data.Roles[i - 1]
    local role = roleClass.new(roleData, self)
    self.roles[i - 1] = role
  end
  local pendantClass = require("Module/AVG/AVGPendant")
  self.pendants = {}
  local length = self.data.Pendants.Length
  for i = 1, length do
    local pendantData = self.data.Pendants[i - 1]
    local pendant = pendantClass.new(pendantData, self)
    self.pendants[i - 1] = pendant
  end
  self:SetNextGroup(0)
  self:AddUIToLoadQueue("ui_avg_postprofile")
end

function AVGContext:CreateGroup(index)
  if index >= self.data.Groups.Length then
    return nil
  end
  local groupData = self.data.Groups[index]
  local group = {
    PassTime = 0,
    IsLoaded = false,
    NextGroup = groupData.Next,
    Playables = {}
  }
  local length = groupData.PlayList.Length
  for i = 1, length do
    local idx = groupData.PlayList[i - 1]
    local playableData = self.data.PlayableDatas[idx]
    local playable = self:CreatePlayable(playableData)
    if playable then
      playable.DataIndex = idx
      table.insert(group.Playables, playable)
    end
  end
  return group
end

function AVGContext:AddReviewData(playableIndex, data)
  local index = 0
  for i, v in ipairs(self.reviewList) do
    if v.PlayableIndex == playableIndex then
      index = i
      break
    end
  end
  if 0 < index then
    while index <= #self.reviewList do
      table.remove(self.reviewList, index)
    end
  end
  data.PlayableIndex = playableIndex
  table.insert(self.reviewList, data)
end

function AVGContext:GetReviewList()
  return self.reviewList
end

function AVGContext:GetBranch(index)
  if index < 0 or index >= self.data.BranchItems.Length then
    return nil
  end
  return self.data.BranchItems[index]
end

function AVGContext:CreatePlayable(playableData)
  local typeName = playableData.Type:ToString()
  local path = "Module/AVG/Playable/AVGPlayable" .. typeName
  local playableClass = require(path)
  if not playableClass then
    log.error("Playable class 不存在: " .. typeName)
    return nil
  end
  local playable = playableClass.new(playableData, self)
  playable.TypeName = typeName
  return playable
end

function AVGContext:PreloadGroup(group)
  if group.IsLoaded then
    return
  end
  for _, playable in ipairs(group.Playables) do
    playable:DoLoad()
  end
  group.IsLoaded = true
end

function AVGContext:GetCurve(index)
  local curve = self.data.Curves[index]
  return curve:ToAnimationCurve()
end

function AVGContext:AddSpriteToLoadQueue(name)
  local index = self.assetIndex[name]
  if index == nil then
    index = self.spriteLoader:LoadSprite(name)
    self.assetIndex[name] = index
  elseif not self.spriteLoader:IsLoaded(index) then
    self.spriteLoader:LoadUIPrefab(name)
  end
end

function AVGContext:AddUIToLoadQueue(name)
  if name == nil or name == "" then
    return
  end
  local index = self.assetIndex[name]
  if index == nil then
    index = self.spriteLoader:LoadUIPrefab(name)
    self.assetIndex[name] = index
  elseif not self.spriteLoader:IsLoaded(index) then
    self.spriteLoader:LoadUIPrefab(name)
  end
end

function AVGContext:GetSprite(name)
  local index = self.assetIndex[name]
  if index == nil then
    return nil
  end
  return self.spriteLoader:GetSprite(index)
end

function AVGContext:GetUIPrefab(name)
  local index = self.assetIndex[name]
  if index == nil then
    return nil
  end
  return self.spriteLoader:GetPrefab(index)
end

function AVGContext:UnloadRes(resName)
  local index = self.assetIndex[resName]
  if index ~= nil then
    self.spriteLoader:Unload(index)
  end
end

function AVGContext:SwitchBG(resName)
  if self.preBGRes then
    self:UnloadRes(self.preBGRes)
  end
  self.preBGRes = resName
  local sprite = self:GetSprite(resName)
  self.form:SetBG(sprite)
end

function AVGContext:SwitchPostProfile(name)
  for k, v in pairs(self.postProfiles) do
    v:SetActive(k == name)
  end
end

function AVGContext:PlaySound(name)
  CS.UI.UILuaHelper.StartPlaySFX(name, nil, handler(self, self.OnSoundStart), handler(self, self.OnSoundFinish))
end

function AVGContext:OnSoundStart(id)
  if self.Stage == AVGStageType.Finished then
    CS.UI.UILuaHelper.StopPlaySFX(id)
    return
  end
  if 0 < id then
    table.insert(self.playingSounds, id)
  end
end

function AVGContext:OnSoundFinish(id)
  for i, v in ipairs(self.playingSounds) do
    if v == id then
      table.remove(self.playingSounds, i)
      break
    end
  end
end

function AVGContext:IsAssetLoadFinished(name)
  local index = self.assetIndex[name]
  if index == nil then
    return false
  end
  return self.spriteLoader:IsLoaded(index)
end

function AVGContext:GetAllRoles()
  return self.roles
end

function AVGContext:GetRole(index)
  return self.roles[index]
end

function AVGContext:GetPendant(index)
  return self.pendants[index]
end

function AVGContext:DestroyPendant(index)
  local pendant = self.pendants[index]
  if pendant ~= nil then
    pendant:Destroy()
    self.pendants[index] = nil
  end
end

function AVGContext:OnClickContinue()
  local wait = false
  if self.currentGroup ~= nil then
    local group = self.currentGroup
    for i, v in ipairs(group.Playables) do
      if v.State == ACGAVGPlayableState.Playing and not wait then
        wait = v:OnClickContinue()
      end
    end
  end
  if not wait then
    self:OnSkipGroup()
  end
end

function AVGContext:OnSkipGroup(nextGroupIndex)
  if self.currentGroup ~= nil then
    local group = self.currentGroup
    local finishedCount = 0
    for i, v in ipairs(group.Playables) do
      if v.State == ACGAVGPlayableState.Finished then
        finishedCount = finishedCount + 1
      end
    end
    if finishedCount == #group.Playables then
      for i, v in ipairs(group.Playables) do
        v:OnDestroy()
      end
    else
      return
    end
    nextGroupIndex = nextGroupIndex or group.NextGroup
  end
  self:SetNextGroup(nextGroupIndex)
end

function AVGContext:SetNextGroup(groupIndex)
  self.currentGroup = self:CreateGroup(groupIndex)
  if self.currentGroup ~= nil then
    self:PreloadGroup(self.currentGroup)
  else
    self.Stage = AVGStageType.Finished
  end
end

function AVGContext:Update(dt)
  if self.spriteLoader.IsLoading then
    return
  end
  if self.Stage == AVGStageType.InitLoading then
    self.Stage = AVGStageType.Playing
    for _, v in pairs(self.roles) do
      v:OnInitResLoadFinished()
    end
    local postProfile = self:GetUIPrefab("ui_avg_postprofile")
    if postProfile ~= nil then
      local postProfile = GameObject.Instantiate(postProfile, self.form.m_curtain.transform.parent).transform
      local root = postProfile:Find("root")
      local childCount = root.childCount
      for i = 1, childCount do
        local child = root:GetChild(i - 1)
        child.gameObject:SetActive(false)
        self.postProfiles[child.name] = child.gameObject
      end
      root.gameObject:SetActive(true)
    end
  end
  if self.currentGroup ~= nil then
    local group = self.currentGroup
    group.PassTime = group.PassTime + dt
    local finishedCount = 0
    local waitableCount = 0
    for i, v in ipairs(group.Playables) do
      if v.State == ACGAVGPlayableState.None and group.PassTime >= v:Delay() then
        v.State = ACGAVGPlayableState.Playing
        v:OnStart()
      end
      if v.State == ACGAVGPlayableState.Playing then
        v:OnUpdate(dt)
      end
      if v.State == ACGAVGPlayableState.Finished then
        finishedCount = finishedCount + 1
      end
      if v:Waitable() then
        waitableCount = waitableCount + 1
      end
    end
    if finishedCount == #group.Playables and (self.form:IsAuto() or waitableCount == 0) then
      for i, v in ipairs(group.Playables) do
        v:OnDestroy()
      end
      self:SetNextGroup(group.NextGroup)
    end
  end
  for _, v in pairs(self.roles) do
    v:Update(dt)
  end
  if self.currentGroup == nil then
    self.Stage = AVGStageType.Finished
  end
end

function AVGContext:Finish()
  self.Stage = AVGStageType.Finished
end

function AVGContext:Destroy()
  for k, v in pairs(self.roles) do
    v:Destroy()
  end
  for k, v in pairs(self.pendants) do
    v:Destroy()
  end
  for _, id in ipairs(self.playingSounds) do
    CS.UI.UILuaHelper.StopPlaySFX(id)
  end
  if self.currentGroup then
    for i, playable in ipairs(self.currentGroup.Playables) do
      playable:OnDestroy()
    end
    self.currentGroup = nil
  end
  self.spriteLoader:Destroy()
  self.Stage = AVGStageType.Finished
end

return AVGContext
