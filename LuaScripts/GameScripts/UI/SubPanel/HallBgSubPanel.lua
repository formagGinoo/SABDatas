local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HallBgSubPanel = class("HallBgSubPanel", UISubPanelBase)
local MainBgType = RoleManager.MainBgType
local DefaultPosIndex = 1
local DefaultBgSpineTab = {
  [1] = {
    conditionHeroID = "ShilaConditionHeroID",
    conditionMainLevelID = nil,
    bgPathStr = "role_blackgril"
  },
  [2] = {
    conditionHeroID = "EmpusaeConditionHeroID",
    conditionMainLevelID = "EmpusaeConditionLevelID",
    bgPathStr = "role_Empusae"
  }
}

function HallBgSubPanel:OnInit()
  self.m_showPosDataList = {}
  self.m_curShowIndex = nil
  self.m_curServerUseIndex = nil
  self.m_root_hero_BtnEx = self.m_root_hero:GetComponent("ButtonExtensions")
  if self.m_root_hero_BtnEx then
    self.m_root_hero_BtnEx.BeginDrag = handler(self, self.OnImgBeginDrag)
    self.m_root_hero_BtnEx.Drag = handler(self, self.OnImgDrag)
    self.m_root_hero_BtnEx.EndDrag = handler(self, self.OnImgEndBDrag)
  end
  self.m_rootTrans = self.m_rootObj.transform
  self.m_groupCam = self.m_parentLua:OwnerStack().Group:GetCamera()
  self.m_startDragPos = nil
  self.m_startDragUIPosX = nil
  self.m_dragTween = nil
  self.m_dragTimer = nil
  self.m_dragEndTimer = nil
  self.m_bg_root_trans = self.m_bg_root.transform
  self.m_curBgPrefabStr = nil
  self.m_curBgNodeObj = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_HeroFashion = HeroManager:GetHeroFashion()
  self.m_lastPlayVoiceTime = 0
  self.m_spineClick = self.m_root_hero:GetComponent("SpineClick")
  if self.m_spineClick then
    function self.m_spineClick.Touched(name, localpos)
      log.info("spineClick:" .. tostring(name))
      
      if self.m_isDrag or self.m_curShowHeroData == nil then
        self.m_isDrag = false
        return
      end
      local curServerTime = TimeUtil:GetServerTimeS()
      if curServerTime - self.m_lastPlayVoiceTime < self.m_uiVariables.LimitVoiceSecNum then
        return
      end
      self.m_lastPlayVoiceTime = TimeUtil:GetServerTimeS()
      local vVoiceText = AttractManager:GetTouchVoice(self.m_curShowHeroData, self.m_curShowHeroData.characterCfg.m_HeroID, name)
      if vVoiceText then
        self:StopCurPlayingVoice()
        self.m_vVoiceText = vVoiceText
        self:PlayVoice(self.m_vVoiceText[self.m_playSubIndex])
      else
        return
      end
    end
  end
end

function HallBgSubPanel:PlayVoice(voiceInfo)
  CS.UI.UILuaHelper.StartPlaySFX(voiceInfo.voice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playSubIndex = self.m_playSubIndex + 1
    local nextVoice = self.m_vVoiceText[self.m_playSubIndex]
    if nextVoice ~= nil then
      self:PlayVoice(nextVoice)
    else
      self.m_playingId = nil
    end
  end)
end

function HallBgSubPanel:StopCurPlayingVoice()
  self.m_playSubIndex = 1
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function HallBgSubPanel:AddEventListeners()
end

function HallBgSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HallBgSubPanel:OnActive()
  self:AddEventListeners()
  if self.m_spineClick == nil then
    self.m_spineClick = self.m_root_hero:GetComponent("SpineClick")
  end
  self:FreshCreateShowBgList()
  self:FreshShowCurrentPos()
end

function HallBgSubPanel:OnInActive()
  self:CheckRecycleSpine(true)
  self:CheckRecycleBgNode()
  self:ClearData()
  self:CheckReqSetMainBgIndexToServer()
  if self.m_spineClick then
    self.m_spineClick:DestroyFollowerList()
    self.m_spineClick = nil
  end
  self:RemoveAllEventListeners()
end

function HallBgSubPanel:OnDestroy()
  self:CheckRecycleSpine(true)
  self:CheckRecycleBgNode()
  self:RemoveAllEventListeners()
  self:ClearData()
  HallBgSubPanel.super.OnDestroy(self)
end

function HallBgSubPanel:ClearData()
  self.m_spineDitherExtension = nil
end

function HallBgSubPanel:FreshCreateShowBgList()
  self.m_showPosDataList = {}
  local heroPosData = RoleManager:GetMainBackGroundDataList()
  for i = 1, RoleManager.MaxHallBgPosNum do
    local tempPosData = heroPosData[i]
    if tempPosData and tempPosData.iType ~= MainBgType.Empty then
      local posData = {
        serverData = tempPosData,
        characterCfg = nil,
        mainBgCfg = nil
      }
      if tempPosData.iType == MainBgType.Role then
        local tempRoleCfg = HeroManager:GetHeroConfigByID(tempPosData.iId)
        if tempRoleCfg then
          posData.characterCfg = tempRoleCfg
        end
      elseif tempPosData.iType == MainBgType.Fashion then
        local tempFashionInfo = self.m_HeroFashion:GetFashionInfoByID(tempPosData.iId)
        if tempFashionInfo then
          posData.fashionInfo = tempFashionInfo
        end
      else
        local tempMainBgCfg = RoleManager:GetMainBackgroundCfg(tempPosData.iId)
        if tempMainBgCfg then
          posData.mainBgCfg = tempMainBgCfg
        end
      end
      self.m_showPosDataList[#self.m_showPosDataList + 1] = posData
    end
  end
  self.m_curShowIndex = self:GetServerDefaultChooseIndex() or DefaultPosIndex
  self.m_curServerUseIndex = self.m_curShowIndex
end

function HallBgSubPanel:GetServerDefaultChooseIndex()
  local serverIndex = RoleManager:GetMainBackGroundIndex()
  local heroPosData = RoleManager:GetMainBackGroundDataList()
  local tempServerData = heroPosData[serverIndex]
  if not tempServerData then
    return
  end
  for i, v in ipairs(self.m_showPosDataList) do
    if v.serverData.iId == tempServerData.iId then
      return i
    end
  end
end

function HallBgSubPanel:GetServerPosIndexByData(mainBgData)
  if not mainBgData then
    return
  end
  local heroPosData = RoleManager:GetMainBackGroundDataList()
  for i = 1, RoleManager.MaxHallBgPosNum do
    local tempPosData = heroPosData[i]
    if tempPosData and tempPosData.iType ~= MainBgType.Empty and tempPosData.iType == mainBgData.iType and tempPosData.iId == mainBgData.iId then
      return i
    end
  end
end

function HallBgSubPanel:CheckReqSetMainBgIndexToServer()
  if self.m_curServerUseIndex ~= self.m_curShowIndex then
    local showPoseData = self.m_showPosDataList[self.m_curShowIndex]
    local toChooseIndex = self:GetServerPosIndexByData(showPoseData.serverData)
    if toChooseIndex and 0 < toChooseIndex then
      RoleManager:ReqRoleSetMainBackgroundIndex(toChooseIndex)
    end
  end
end

function HallBgSubPanel:GetCurUseMainBackgroundID()
  if not self.m_curMainBackgroundCfg then
    return
  end
  return self.m_curMainBackgroundCfg.m_BDID
end

function HallBgSubPanel:FreshShowCurrentPos()
  if not self.m_curShowIndex then
    return
  end
  local curShowPosData = self.m_showPosDataList[self.m_curShowIndex]
  if not curShowPosData then
    return
  end
  local curChoseData = curShowPosData.serverData
  if curChoseData.iType == MainBgType.Empty then
    return
  end
  local isShowRole = curChoseData.iType == MainBgType.Role
  local isShowBg = curChoseData.iType == MainBgType.Activity
  local isShowFashion = curChoseData.iType == MainBgType.Fashion
  self:StopCurPlayingVoice()
  UILuaHelper.SetActive(self.m_heroDefaultBg, isShowRole or isShowFashion)
  if isShowRole or isShowFashion then
    self:HideBgRootChild()
    local showSpineStr
    if isShowRole then
      local heroID = curShowPosData.characterCfg.m_HeroID
      self.m_curShowHeroData = HeroManager:GetHeroDataByID(heroID)
      local fashionInfo = self.m_HeroFashion:GetFashionInfoByHeroIDAndFashionID(heroID, 0)
      if fashionInfo then
        showSpineStr = fashionInfo.m_Spine
      end
    else
      showSpineStr = curShowPosData.fashionInfo.m_Spine
    end
    if showSpineStr ~= nil and showSpineStr ~= "" then
      self:ShowHeroSpine(showSpineStr)
    end
  elseif isShowBg then
    self:HideCurSpine()
    self:ShowMainBg()
  end
end

function HallBgSubPanel:CheckShowBlackMaskAnim(lastIndex, toShowIndex)
  if not toShowIndex then
    return
  end
  if not lastIndex then
    return
  end
  if lastIndex == toShowIndex then
    return
  end
  local lastShowPosData = self.m_showPosDataList[lastIndex]
  local isLastPosShowBg = false
  if lastShowPosData and lastShowPosData.serverData.iType == MainBgType.Activity then
    isLastPosShowBg = true
  end
  local toShowPosData = self.m_showPosDataList[toShowIndex]
  local isToPosShowBg = false
  if toShowPosData and toShowPosData.serverData.iType == MainBgType.Activity then
    isToPosShowBg = true
  end
  if isLastPosShowBg or isToPosShowBg then
    UILuaHelper.SetActive(self.m_bg_mask, false)
    UILuaHelper.SetActive(self.m_bg_mask, true)
  end
end

function HallBgSubPanel:ShowMainBg()
  if not self.m_curShowIndex then
    return
  end
  local curShowPosData = self.m_showPosDataList[self.m_curShowIndex]
  if not curShowPosData then
    return
  end
  local curChoseData = curShowPosData.serverData
  if curChoseData.iType ~= MainBgType.Activity then
    return
  end
  self.m_curMainBackgroundCfg = curShowPosData.mainBgCfg
  local tempPrefabStr = self.m_curMainBackgroundCfg.m_Prefabs
  if tempPrefabStr and tempPrefabStr ~= "" then
    utils.TryLoadUIPrefabInParent(self.m_bg_root_trans, tempPrefabStr, function(nameStr, gameObject)
      self.m_curBgPrefabStr = nameStr
      self.m_curBgNodeObj = gameObject
      self:FreshBgChild()
      self:CheckShowDefaultSpineWithHave()
    end)
  end
end

function HallBgSubPanel:FreshBgChild()
  if not self.m_curMainBackgroundCfg then
    return
  end
  UILuaHelper.SetActiveChildren(self.m_bg_root_trans, false)
  local tempPrefabStr = self.m_curMainBackgroundCfg.m_Prefabs
  if tempPrefabStr and tempPrefabStr ~= "" then
    local subNode = self.m_bg_root_trans:Find(tempPrefabStr)
    if subNode then
      UILuaHelper.SetActive(subNode, true)
    end
  end
end

function HallBgSubPanel:CheckRecycleBgNode()
  if self.m_curBgPrefabStr and self.m_curBgNodeObj then
    utils.RecycleInParentUIPrefab(self.m_curBgPrefabStr, self.m_curBgNodeObj)
  end
  self.m_curBgPrefabStr = nil
  self.m_curBgNodeObj = nil
end

function HallBgSubPanel:HideBgRootChild()
  UILuaHelper.SetActiveChildren(self.m_bg_root, false)
  self.m_curMainBackgroundCfg = nil
end

function HallBgSubPanel:CheckShowDefaultSpineWithHave()
  if not self.m_curMainBackgroundCfg then
    return
  end
  if self.m_curMainBackgroundCfg.m_DefaultType ~= 1 then
    return
  end
  local tempPrefabStr = self.m_curMainBackgroundCfg.m_Prefabs
  if tempPrefabStr == nil or tempPrefabStr == "" then
    return
  end
  for i, v in ipairs(DefaultBgSpineTab) do
    local isConditionMatch = true
    if v.conditionHeroID and self.m_uiVariables[v.conditionHeroID] and HeroManager:GetHeroDataByID(self.m_uiVariables[v.conditionHeroID]) == nil then
      isConditionMatch = false
    end
    if v.conditionMainLevelID and self.m_uiVariables[v.conditionMainLevelID] and LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, self.m_uiVariables[v.conditionMainLevelID]) ~= true then
      isConditionMatch = false
    end
    local nodePath = tempPrefabStr .. "/" .. v.bgPathStr
    local tempNode = self.m_bg_root_trans:Find(nodePath)
    if tempNode then
      UILuaHelper.SetActive(tempNode, isConditionMatch)
    end
  end
end

function HallBgSubPanel:HideCurSpine()
  self:CheckRecycleSpine()
  self.m_spineDitherExtension = nil
  self.m_curShowHeroData = nil
end

function HallBgSubPanel:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function HallBgSubPanel:ShowHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.MainShow
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack()
  end)
end

function HallBgSubPanel:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  local spinePlaceObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spinePlaceObj, true)
  local spineRootObj = self.m_curHeroSpineObj.spineObj
  self.m_spineDitherExtension = spineRootObj.transform:GetComponent("SpineDitherExtension")
  UILuaHelper.SpineResetMatParam(spineRootObj)
  UILuaHelper.SetSpineTimeScale(spineRootObj, 1)
  if self.m_dragEndTimer then
    local leftTime = TimeService:GetTimerLeftTime(self.m_dragEndTimer)
    if leftTime and 0 < leftTime then
      self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
      self.m_spineDitherExtension:SetToDither(1.0, 0.0, leftTime)
      if self.m_dragEndTimer then
        TimeService:KillTimer(self.m_dragEndTimer)
        self.m_dragEndTimer = nil
      end
      self.m_dragEndTimer = TimeService:SetTimer(leftTime, 1, function()
        self:CheckKillDragDoTween()
        self.m_dragEndTimer = nil
      end)
    else
      self.m_spineDitherExtension:StopToDither(true)
      self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
    end
  else
    self.m_spineDitherExtension:StopToDither(true)
    self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
  end
  self:SpinePlayIdleAnim()
  if self.m_spineClick and self.m_curHeroSpineObj and not utils.isNull(self.m_curHeroSpineObj.spineObj) then
    local typeStr = SpinePlaceCfg.MainShow
    local spineStr = self.m_curHeroSpineObj.spineStr
    self.m_spineClick:BindingSpine("hero_place_" .. spineStr .. "," .. typeStr .. "," .. spineStr)
  end
end

function HallBgSubPanel:SpinePlayIdleAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpine = self.m_curHeroSpineObj.spineObj
  if not heroSpine then
    return
  end
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, "idle", true, false)
end

function HallBgSubPanel:OnImgBeginDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
  self.m_startDragUIPosX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, startPos.x, startPos.y, self.m_groupCam)
  if self.m_spineDitherExtension and not UILuaHelper.IsNull(self.m_spineDitherExtension) then
    self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
  end
end

function HallBgSubPanel:OnImgEndBDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_startDragPos.x
  local absDeltaNum = math.abs(deltaNum)
  if absDeltaNum < self.m_uiVariables.DragLimitNum then
    self:CheckShowDragBackTween()
    return
  end
  if 0 < deltaNum then
    self:CheckShowLastPos()
  else
    self:CheckShowNextPos()
  end
  self.m_startDragPos = nil
  self.m_startDragUIPosX = nil
end

function HallBgSubPanel:OnImgDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragUIPosX then
    return
  end
  local dragPos = pointerEventData.position
  local basePos = self.m_uiVariables.BasePosition
  local startDragUIPosX = self.m_startDragUIPosX
  local localX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, dragPos.x, dragPos.y, self.m_groupCam)
  local deltaX = localX - startDragUIPosX
  local deltaAbsNum = math.abs(deltaX)
  if deltaAbsNum > self.m_uiVariables.MaxDragDeltaNum then
    return
  end
  local lerpRate = deltaAbsNum / self.m_uiVariables.MaxDragDeltaNum
  local paiRateNum = lerpRate * 3.1415 / 2
  local sinRateNum = math.sin(paiRateNum)
  local inputDeltaNum = sinRateNum * self.m_uiVariables.MaxDragDeltaNum
  if deltaX < 0 then
    inputDeltaNum = -inputDeltaNum
  end
  UILuaHelper.SetLocalPosition(self.m_root_hero, basePos.x + inputDeltaNum, basePos.y, 0)
  if self.m_spineDitherExtension and not UILuaHelper.IsNull(self.m_spineDitherExtension) then
    self.m_spineDitherExtension.DitherNum = lerpRate
  end
end

function HallBgSubPanel:CheckShowLastPos()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(false, function()
    local lastIndex = self.m_curShowIndex
    local toShowIndex = self.m_curShowIndex - 1
    if toShowIndex <= 0 then
      toShowIndex = #self.m_showPosDataList
    end
    self.m_curShowIndex = toShowIndex
    self:FreshShowCurrentPos()
    self:CheckShowBlackMaskAnim(lastIndex, toShowIndex)
  end)
end

function HallBgSubPanel:CheckShowNextPos()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(true, function()
    local lastIndex = self.m_curShowIndex
    local toShowIndex = self.m_curShowIndex + 1
    if toShowIndex > #self.m_showPosDataList then
      toShowIndex = 1
    end
    self.m_curShowIndex = toShowIndex
    self:FreshShowCurrentPos()
    self:CheckShowBlackMaskAnim(lastIndex, toShowIndex)
  end)
end

function HallBgSubPanel:CheckKillDragDoTween(isJustKillTween)
  if self.m_dragTween and self.m_dragTween:IsPlaying() then
    self.m_dragTween:Kill()
  end
  self.m_dragTween = nil
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
  self.m_UILockID = nil
  if not isJustKillTween then
    local basePos = self.m_uiVariables.BasePosition
    UILuaHelper.SetLocalPosition(self.m_root_hero, basePos.x, basePos.y, basePos.z)
    if self.m_spineDitherExtension then
      self.m_spineDitherExtension.DitherNum = 0
      self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
    end
  end
end

function HallBgSubPanel:CheckShowDragTween(isLeft, midBackFun)
  local dragPosX = isLeft and self.m_uiVariables.DragLeftPosNum or self.m_uiVariables.DragRightPosNum
  local basePos = self.m_uiVariables.BasePosition
  local changePos = {
    x = dragPosX,
    y = basePos.y,
    z = 0
  }
  local toTween = self.m_root_hero.transform:DOLocalMove(changePos, self.m_uiVariables.DragTweenTime)
  local backPos = basePos
  local backTween = self.m_root_hero.transform:DOLocalMove(backPos, self.m_uiVariables.DragTweenBackTime)
  self.m_dragTween = CS.DG.Tweening.DOTween.Sequence()
  self.m_dragTween:Append(toTween)
  self.m_dragTween:Append(backTween)
  self.m_dragTween:PlayForward()
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
    self.m_spineDitherExtension:SetToDither(self.m_spineDitherExtension.DitherNum, 1, self.m_uiVariables.DragTweenTime)
  end
  self.m_dragTween:PlayForward()
  if self.m_dragTimer then
    TimeService:KillTimer(self.m_dragTimer)
    self.m_dragTimer = nil
  end
  self.m_UILockID = UILockIns:Lock(self.m_uiVariables.DragTweenTime + self.m_uiVariables.DragTweenBackTime)
  self.m_dragTimer = TimeService:SetTimer(self.m_uiVariables.DragTweenTime, 1, function()
    self.m_dragTimer = nil
    if midBackFun then
      midBackFun()
    end
  end)
  if self.m_dragEndTimer then
    TimeService:KillTimer(self.m_dragEndTimer)
    self.m_dragEndTimer = nil
  end
  self.m_dragEndTimer = TimeService:SetTimer(self.m_uiVariables.DragTweenTime + self.m_uiVariables.DragTweenBackTime, 1, function()
    self:CheckKillDragDoTween()
    self.m_dragEndTimer = nil
  end)
end

function HallBgSubPanel:CheckShowDragBackTween()
  if self.m_dragTimer then
    TimeService:KillTimer(self.m_dragTimer)
    self.m_dragTimer = nil
  end
  self.m_UILockID = UILockIns:Lock(self.m_uiVariables.DragTweenTime)
  local basePos = self.m_uiVariables.BasePosition
  local backPos = basePos
  self.m_dragTween = self.m_root_hero.transform:DOLocalMove(backPos, self.m_uiVariables.DragTweenBackTime)
  self.m_dragTween:PlayForward()
  self.m_dragTimer = TimeService:SetTimer(self.m_uiVariables.DragTweenTime, 1, function()
    self.m_dragTimer = nil
    self:CheckKillDragDoTween()
  end)
end

function HallBgSubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return HallBgSubPanel
