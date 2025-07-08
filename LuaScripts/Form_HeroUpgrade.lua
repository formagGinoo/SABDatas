local Form_HeroUpgrade = class("Form_HeroUpgrade", require("UI/UIFrames/Form_HeroUpgradeUI"))
local SubPanelManager = _ENV.SubPanelManager
local actions = {"idle", "touch"}

function Form_HeroUpgrade:SetInitParam(param)
end

function Form_HeroUpgrade:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1108)
  self.m_lvUpPanelData = {
    panelRoot = self.m_base_panel_root,
    subPanelName = "HeroLvUpgradeSubPanel",
    subPanelLua = nil,
    backFun = nil
  }
  self.m_root_hero_BtnEx = self.m_root_hero:GetComponent("ButtonExtensions")
  if self.m_root_hero_BtnEx then
    self.m_root_hero_BtnEx.BeginDrag = handler(self, self.OnImgBeginDrag)
    self.m_root_hero_BtnEx.Drag = handler(self, self.OnImgDrag)
    self.m_root_hero_BtnEx.EndDrag = handler(self, self.OnImgEndBDrag)
  end
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  self.m_startDragPos = nil
  self.m_startDragUIPosX = nil
  self.m_curChooseHeroIndex = nil
  self.m_curShowHeroData = nil
  self.m_allHeroList = nil
  self.m_dragTween = nil
  self.m_dragTimer = nil
  self.m_dragEndTimer = nil
  self.m_isJustOne = false
  self.m_closeUpgradeBackFun = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_HeroUpgrade:OnActive()
  self.super.OnActive(self)
  self.m_playVoice = true
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_HeroUpgrade:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
end

function Form_HeroUpgrade:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
  if self.m_lvUpPanelData.subPanelLua then
    self.m_lvUpPanelData.subPanelLua:dispose()
    self.m_lvUpPanelData.subPanelLua = nil
  end
  if self.m_dragTimer then
    TimeService:KillTimer(self.m_dragTimer)
    self.m_dragTimer = nil
  end
  if self.m_dragEndTimer then
    TimeService:KillTimer(self.m_dragEndTimer)
    self.m_dragEndTimer = nil
  end
  if self.m_closeUpgradeBackFun then
    self.m_closeUpgradeBackFun = nil
  end
end

function Form_HeroUpgrade:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SetHeroData", handler(self, self.OnSetHeroData))
end

function Form_HeroUpgrade:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroUpgrade:OnSetHeroData(param)
  if not param then
    return
  end
  local heroServerData = param.heroServerData
  if heroServerData.iHeroId == self.m_curShowHeroData.serverData.iHeroId then
    self:FreshShowHeroPower()
    if self.m_playVoice then
      local voice = HeroManager:GetHeroLevelUpVoice(heroServerData.iHeroId)
      if voice and voice ~= "" then
        CS.UI.UILuaHelper.StartPlaySFX(voice)
      end
      self.m_playVoice = false
    end
  end
end

function Form_HeroUpgrade:FreshShowHeroPower()
  self.m_txt_power_value_Text.text = BigNumFormat(self.m_curShowHeroData.serverData.iPower)
end

function Form_HeroUpgrade:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_allHeroList = tParam.heroDataList
    local heroID = tParam.heroID
    local chooseIndex = self:GetAllHeroIndex(heroID)
    self.m_curChooseHeroIndex = chooseIndex
    self.m_curShowHeroData = self.m_allHeroList[self.m_curChooseHeroIndex]
    self.m_isJustOne = #self.m_allHeroList <= 1
    self.m_csui.m_param = nil
    self.m_closeUpgradeBackFun = tParam.closeBackFun
  end
end

function Form_HeroUpgrade:GetAllHeroIndex(heroID)
  if not heroID then
    return
  end
  for i, v in ipairs(self.m_allHeroList) do
    if v.serverData.iHeroId == heroID then
      return i
    end
  end
end

function Form_HeroUpgrade:FreshUI()
  if not self.m_curShowHeroData then
    return
  end
  self:FreshShowHeroInfo(true)
  self:FreshCurTabSubPanelInfo(false)
  self:CheckShowEnterAnim()
  self.m_changehero:SetActive(#self.m_allHeroList > 1)
end

function Form_HeroUpgrade:FreshShowHeroInfo(isEnterFresh)
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  if heroCfg.m_HeroID == 0 then
    return
  end
  self.m_playVoice = true
  self.m_txt_power_value_Text.text = BigNumFormat(self.m_curShowHeroData.serverData.iPower)
  self:ShowHeroSpine(heroCfg.m_Spine, isEnterFresh)
end

function Form_HeroUpgrade:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HeroUpgrade:ShowHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.HeroDetail
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack()
  end)
end

function Form_HeroUpgrade:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  local spinePlaceObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spinePlaceObj, true)
  local spineRootObj = self.m_curHeroSpineObj.spineObj
  self.m_spineDitherExtension = spineRootObj:GetComponent("SpineDitherExtension")
  self.m_spineDitherExtension:SetSpineMaskAndGray(false)
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
  self:SpinePlayRandomAnim()
end

function Form_HeroUpgrade:SpinePlayRandomAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  local heroSpine = self.m_curHeroSpineObj.spineObj
  if not heroSpine or UILuaHelper.IsNull(heroSpine) then
    return
  end
  local action = actions[math.random(1, 2)]
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, "idle", false, false, function()
    if UILuaHelper.IsNull(heroSpine) then
      return
    end
    UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, action, false, false, function()
      self:SpinePlayRandomAnim()
    end)
  end)
end

function Form_HeroUpgrade:FreshCurTabSubPanelInfo(isJustFreshData)
  if not self.m_curShowHeroData then
    return
  end
  if self.m_lvUpPanelData.subPanelLua then
    self.m_lvUpPanelData.subPanelLua:SetActive(true)
    self.m_lvUpPanelData.subPanelLua:FreshData({
      heroData = self.m_curShowHeroData,
      allHeroList = self.m_allHeroList,
      chooseIndex = self.m_curChooseHeroIndex,
      isJustFreshData = isJustFreshData
    })
    if self.m_lvUpPanelData.subPanelLua.OnActivePanel then
      self.m_lvUpPanelData.subPanelLua:OnActivePanel()
    end
  else
    SubPanelManager:LoadSubPanel(self.m_lvUpPanelData.subPanelName, self.m_lvUpPanelData.panelRoot, self, {}, {
      heroData = self.m_curShowHeroData,
      allHeroList = self.m_allHeroList,
      chooseIndex = self.m_curChooseHeroIndex,
      initData = {}
    }, function(subPanelLua)
      if subPanelLua then
        self.m_lvUpPanelData.subPanelLua = subPanelLua
        if self.m_lvUpPanelData.subPanelLua.isNeedShowEnterAnim and subPanelLua.ShowEnterInAnim then
          subPanelLua:ShowEnterInAnim()
          self.m_lvUpPanelData.subPanelLua.isNeedShowEnterAnim = false
        end
        if self.m_lvUpPanelData.subPanelLua.isNeedShowTabAnim and subPanelLua.ShowTabInAnim then
          subPanelLua:ShowTabInAnim()
          self.m_lvUpPanelData.subPanelLua.isNeedShowTabAnim = false
        end
        if subPanelLua.OnActivePanel then
          subPanelLua:OnActivePanel()
        end
      end
    end)
  end
end

function Form_HeroUpgrade:CheckShowEnterAnim()
  local subPanelLua = self.m_lvUpPanelData.subPanelLua
  if subPanelLua then
    if subPanelLua.ShowEnterInAnim then
      subPanelLua:ShowEnterInAnim()
    end
  else
    self.m_lvUpPanelData.isNeedShowEnterAnim = true
  end
end

function Form_HeroUpgrade:ShowFormEnterAnim()
end

function Form_HeroUpgrade:OnBackClk()
  self:CheckRecycleSpine(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  if self.m_closeUpgradeBackFun then
    local heroID = self.m_curShowHeroData.serverData.iHeroId
    self.m_closeUpgradeBackFun(heroID)
  end
  self:CloseForm()
end

function Form_HeroUpgrade:OnBackHome()
  self:CheckRecycleSpine(true)
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_HeroUpgrade:OnImgBeginDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
  self.m_startDragUIPosX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, startPos.x, startPos.y, self.m_groupCam)
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
  end
end

function Form_HeroUpgrade:OnImgEndBDrag(pointerEventData)
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
    self:CheckShowLastHero()
  else
    self:CheckShowNextHero()
  end
  self.m_startDragPos = nil
  self.m_startDragUIPosX = nil
end

function Form_HeroUpgrade:OnImgDrag(pointerEventData)
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
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension.DitherNum = lerpRate
  end
end

function Form_HeroUpgrade:TryChangeCurHero(toHeroIndex)
  local curShowHeroData = self.m_allHeroList[toHeroIndex]
  if curShowHeroData == nil then
    return
  end
  
  local function OnDownloadComplete(ret)
    log.info(string.format("Download HeroDetail ChangeCurHero %s,%s Complete: %s", tostring(levelType), tostring(levelID), tostring(ret)))
    self.m_curChooseHeroIndex = toHeroIndex
    self.m_curShowHeroData = self.m_allHeroList[self.m_curChooseHeroIndex]
    self:FreshShowHeroInfo()
    self:FreshCurTabSubPanelInfo(true)
    self:ShowFormEnterAnim()
  end
  
  local vPackage = {}
  vPackage[#vPackage + 1] = {
    sName = tostring(curShowHeroData.characterCfg.m_HeroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  DownloadManager:DownloadResourceWithUI(vPackage, nil, "UI_Form_HeroUpgrade_ChangeHero_" .. tostring(curShowHeroData.characterCfg.m_HeroID), nil, nil, OnDownloadComplete)
end

function Form_HeroUpgrade:CheckShowLastHero()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(false, function()
    local toHeroIndex = self.m_curChooseHeroIndex - 1
    if toHeroIndex <= 0 then
      toHeroIndex = #self.m_allHeroList
    end
    self:TryChangeCurHero(toHeroIndex)
  end)
end

function Form_HeroUpgrade:CheckShowNextHero()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(true, function()
    local toHeroIndex = self.m_curChooseHeroIndex + 1
    if toHeroIndex > #self.m_allHeroList then
      toHeroIndex = 1
    end
    self:TryChangeCurHero(toHeroIndex)
  end)
end

function Form_HeroUpgrade:CheckKillDragDoTween(isJustKillTween)
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

function Form_HeroUpgrade:CheckShowDragTween(isLeft, midBackFun)
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

function Form_HeroUpgrade:CheckShowDragBackTween()
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

function Form_HeroUpgrade:OnBtnnextClicked()
  self:CheckShowNextHero()
end

function Form_HeroUpgrade:OnBtnpreviousClicked()
  self:CheckShowLastHero()
end

function Form_HeroUpgrade:IsFullScreen()
  return true
end

function Form_HeroUpgrade:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra("HeroLvUpgradeSubPanel")
  if vPackageSub ~= nil then
    for i = 1, #vPackageSub do
      vPackage[#vPackage + 1] = vPackageSub[i]
    end
  end
  if vResourceExtraSub ~= nil then
    for i = 1, #vResourceExtraSub do
      vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
    end
  end
  self.m_allHeroList = tParam.heroDataList
  local iHeroID = tParam.heroID
  local iCurChooseHeroIndex = self:GetAllHeroIndex(iHeroID)
  local iHeroIDReal = self.m_allHeroList[iCurChooseHeroIndex].characterCfg.m_HeroID
  vPackage[#vPackage + 1] = {
    sName = tostring(iHeroIDReal),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_HeroUpgrade", Form_HeroUpgrade)
return Form_HeroUpgrade
