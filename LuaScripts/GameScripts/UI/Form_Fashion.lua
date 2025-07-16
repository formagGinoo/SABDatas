local Form_Fashion = class("Form_Fashion", require("UI/UIFrames/Form_FashionUI"))
local FashionTagCfg = {Fashion = 1, Voice = 2}
local DefaultShowTab = FashionTagCfg.Fashion
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local actions = {"idle", "touch"}
local L2DOpenAnimStr = "L2D_open"
local L2DCloseAnimStr = "L2D_close"

function Form_Fashion:SetInitParam(param)
end

function Form_Fashion:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1038)
  self.m_panelData = {
    [FashionTagCfg.Fashion] = {
      panelRoot = self.m_pnl_skin,
      subPanelName = "HeroFashionSubPanel",
      subPanelLua = nil,
      backFun = function(index)
        self:OnSubPanelFashionChange(index)
      end
    },
    [FashionTagCfg.Voice] = {
      panelRoot = self.m_pnl_voice,
      subPanelName = "HeroFashionVoiceSubPanel",
      subPanelLua = nil
    }
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
  self.m_dragTween = nil
  self.m_dragTimer = nil
  self.m_dragEndTimer = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_HeroFashion = HeroManager:GetHeroFashion()
  self.m_heroData = nil
  self.m_heroCfg = nil
  self.m_heroID = nil
  self.m_heroFashionInfoList = nil
  self.m_curChooseIndex = nil
  self.m_curShowFashion = nil
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  self.m_curShowTab = nil
end

function Form_Fashion:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_Fashion:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:CheckRecycleSpine(true)
  self:RemoveAllEventListeners()
end

function Form_Fashion:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_Fashion:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_heroID = tParam.heroID
    self.m_heroData = HeroManager:GetHeroDataByID(self.m_heroID)
    self.m_heroCfg = HeroManager:GetHeroConfigByID(self.m_heroID)
    local fashionID = tParam.fashionID
    self:FreshFashionList()
    self.m_curChooseIndex = self:GetEnterChooseIndex(fashionID)
    if self.m_curChooseIndex == nil then
      self.m_curChooseIndex = 1
    end
    self.m_curShowFashion = self.m_heroFashionInfoList[self.m_curChooseIndex]
    self.m_csui.m_param = nil
  end
end

function Form_Fashion:ClearCacheData()
end

function Form_Fashion:FreshFashionList()
  if not self.m_heroID then
    return
  end
  local tempFashionInfoList = self.m_HeroFashion:GetFashionInfoListByHeroID(self.m_heroID)
  if not tempFashionInfoList then
    return
  end
  self.m_heroFashionInfoList = {}
  for i, v in ipairs(tempFashionInfoList) do
    local tempHideType = self.m_HeroFashion:GetFashionHideTypeValue(v.m_FashionID, v.m_HideType) or 0
    if tempHideType ~= 1 then
      self.m_heroFashionInfoList[#self.m_heroFashionInfoList + 1] = v
    end
  end
end

function Form_Fashion:GetEnterChooseIndex(paramFashionID)
  local fashionID = 0
  if paramFashionID == nil then
    if self.m_heroData then
      fashionID = self.m_heroData.serverData.iFashion
    end
  else
    fashionID = paramFashionID
  end
  local fashionIndex = self:GetIndexByFashionID(fashionID)
  return fashionIndex
end

function Form_Fashion:GetIndexByFashionID(fashionID)
  if fashionID == nil then
    return
  end
  if not self.m_heroFashionInfoList then
    return
  end
  if fashionID == 0 then
    for i, v in ipairs(self.m_heroFashionInfoList) do
      if v.m_Type == 0 then
        return i
      end
    end
  else
    for i, v in ipairs(self.m_heroFashionInfoList) do
      if v.m_FashionID == fashionID then
        return i
      end
    end
  end
end

function Form_Fashion:AddEventListeners()
end

function Form_Fashion:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Fashion:FreshUI()
  self:FreshShowFashionInfo()
  self:ChangeSubPanelShow(DefaultShowTab)
  self:FreshStaticOrDynamic()
  self:FreshVoiceOrFashionBtnShow()
end

function Form_Fashion:FreshStaticOrDynamic()
  local isStatic = LocalDataManager:GetIntSimple("FashionStaticToggle", 0) == 1
  if isStatic then
    UILuaHelper.ResetAnimationByName(self.m_btn_l2d, L2DCloseAnimStr, -1)
  else
    UILuaHelper.ResetAnimationByName(self.m_btn_l2d, L2DOpenAnimStr, -1)
  end
end

function Form_Fashion:FreshVoiceOrFashionBtnShow(isPlayAnim)
  local isShowVoice = self.m_curShowFashion.m_IsShowVoice == 1
  isShowVoice = isShowVoice and self.m_curShowTab == FashionTagCfg.Fashion
  isShowVoice = isShowVoice and self.m_heroData ~= nil
  UILuaHelper.SetActive(self.m_btn_voice, isShowVoice)
  local isShowFashion = self.m_curShowTab == FashionTagCfg.Voice
  UILuaHelper.SetActive(self.m_btn_fashion, isShowFashion)
  if isPlayAnim then
    if isShowVoice then
      UILuaHelper.PlayAnimationByName(self.m_btn_voice, "fashion_btn_in")
    end
    if isShowFashion then
      UILuaHelper.PlayAnimationByName(self.m_btn_fashion, "fashion_btn_in")
    end
  end
end

function Form_Fashion:ChangeSubPanelShow(toShowTab)
  local lastShowTab = self.m_curShowTab
  if lastShowTab then
    local lastSubPanelData = self.m_panelData[lastShowTab]
    if lastSubPanelData.subPanelLua then
      UILuaHelper.SetActive(lastSubPanelData.panelRoot, false)
      if lastSubPanelData.subPanelLua.OnHidePanel then
        lastSubPanelData.subPanelLua:OnHidePanel()
      end
    end
  end
  if toShowTab then
    self.m_curShowTab = toShowTab
    local curSubPanelData = self.m_panelData[toShowTab]
    if curSubPanelData then
      UILuaHelper.SetActive(curSubPanelData.panelRoot, true)
      if curSubPanelData.subPanelLua == nil then
        local initData = {
          backFun = curSubPanelData.backFun,
          uiCamera = self.m_groupCam
        }
        local subPanelLua = self:CreateSubPanel(curSubPanelData.subPanelName, curSubPanelData.panelRoot, self, initData, {
          heroCfg = self.m_heroCfg,
          allFashionList = self.m_heroFashionInfoList,
          chooseIndex = self.m_curChooseIndex,
          heroData = self.m_heroData
        })
        curSubPanelData.subPanelLua = subPanelLua
        if subPanelLua.OnActivePanel then
          subPanelLua:OnActivePanel()
        end
      else
        self:FreshCurTabSubPanelInfo()
      end
    end
  end
end

function Form_Fashion:FreshCurTabSubPanelInfo(isChangeSelect)
  if not self.m_curShowTab then
    return
  end
  if not self.m_curShowFashion then
    return
  end
  local curSubPanelData = self.m_panelData[self.m_curShowTab]
  local subPanelLua = curSubPanelData.subPanelLua
  if subPanelLua then
    if isChangeSelect then
      if subPanelLua.ChangeChooseIndex then
        subPanelLua:ChangeChooseIndex(self.m_curChooseIndex)
      end
    else
      subPanelLua:FreshData({
        heroCfg = self.m_heroCfg,
        allFashionList = self.m_heroFashionInfoList,
        chooseIndex = self.m_curChooseIndex,
        heroData = self.m_heroData
      })
      if subPanelLua.OnActivePanel then
        subPanelLua:OnActivePanel()
      end
    end
  end
end

function Form_Fashion:FreshLeftDownInfoShow()
  if not self.m_heroCfg then
    return
  end
  if not self.m_curShowFashion then
    return
  end
  self.m_txt_petname_Text.text = self.m_curShowFashion.m_mFashionName
  self.m_txt_rolename_Text.text = self.m_heroCfg.m_mName
  self.m_txt_roledesc_Text.text = self.m_curShowFashion.m_mFashionDes
  local campCfg = CampCfgIns:GetValue_ByCampID(self.m_heroCfg.m_Camp)
  if campCfg:GetError() ~= true then
    UILuaHelper.SetAtlasSprite(self.m_img_camp_Image, campCfg.m_WishListIcon)
  end
end

function Form_Fashion:FreshShowFashionInfo()
  if not self.m_curShowFashion then
    return
  end
  self:FreshLeftDownInfoShow()
  local spineStr = self.m_curShowFashion.m_Spine
  self:ShowHeroSpine(spineStr)
end

function Form_Fashion:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_Fashion:ShowHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.HeroFashionItem
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack()
  end)
end

function Form_Fashion:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  local spinePlaceObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spinePlaceObj, true)
  local spineRootObj = self.m_curHeroSpineObj.spineObj
  self.m_spineDitherExtension = spineRootObj:GetComponent("SpineDitherExtension")
  self.m_spineDitherExtension:SetSpineMaskAndGray(false)
  UILuaHelper.SetSpineTimeScale(spineRootObj, 1)
  UILuaHelper.SpinePlayAnimWithBack(spineRootObj, 0, "idle", false, false)
  UILuaHelper.SpineResetInit(spineRootObj)
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
  self:FreshSpineStaticOrDynamicShow()
end

function Form_Fashion:FreshSpineStaticOrDynamicShow()
  if not self.m_curHeroSpineObj then
    return
  end
  local spineRootObj = self.m_curHeroSpineObj.spineObj
  local isStatic = LocalDataManager:GetIntSimple("FashionStaticToggle", 0) == 1
  if isStatic then
    UILuaHelper.SetSpineTimeScale(spineRootObj, 1)
    UILuaHelper.SpinePlayAnimWithBack(spineRootObj, 0, "idle", false, false)
    UILuaHelper.SpineResetInit(spineRootObj)
    UILuaHelper.SetSpineTimeScale(spineRootObj, 0)
  else
    UILuaHelper.SetSpineTimeScale(spineRootObj, 1)
    self:SpinePlayRandomAnim()
  end
end

function Form_Fashion:SpinePlayRandomAnim()
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

function Form_Fashion:OnBackClk()
  self:CheckRecycleSpine(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_Fashion:OnImgBeginDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if self.m_curShowTab == FashionTagCfg.Voice then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
  self.m_startDragUIPosX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, startPos.x, startPos.y, self.m_groupCam)
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
  end
end

function Form_Fashion:OnImgEndBDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if self.m_curShowTab == FashionTagCfg.Voice then
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
    self:CheckShowLast()
  else
    self:CheckShowNext()
  end
  self.m_startDragPos = nil
  self.m_startDragUIPosX = nil
end

function Form_Fashion:OnImgDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if self.m_curShowTab == FashionTagCfg.Voice then
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

function Form_Fashion:TryChangeCurFashion(toIndex)
  self.m_curChooseIndex = toIndex
  self.m_curShowFashion = self.m_heroFashionInfoList[self.m_curChooseIndex]
  self:FreshShowFashionInfo()
  self:FreshCurTabSubPanelInfo(true)
  self:FreshVoiceOrFashionBtnShow()
end

function Form_Fashion:CheckShowLast()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(false, function()
    local toIndex = self.m_curChooseIndex - 1
    if toIndex <= 0 then
      toIndex = #self.m_heroFashionInfoList
    end
    self:TryChangeCurFashion(toIndex)
  end)
end

function Form_Fashion:CheckShowNext()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(true, function()
    local toIndex = self.m_curChooseIndex + 1
    if toIndex > #self.m_heroFashionInfoList then
      toIndex = 1
    end
    self:TryChangeCurFashion(toIndex)
  end)
end

function Form_Fashion:CheckKillDragDoTween(isJustKillTween)
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

function Form_Fashion:CheckShowDragTween(isLeft, midBackFun)
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

function Form_Fashion:CheckShowDragBackTween()
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

function Form_Fashion:OnSubPanelFashionChange(index)
  if not index then
    return
  end
  if index == self.m_curChooseIndex then
    return
  end
  self.m_curChooseIndex = index
  self.m_curShowFashion = self.m_heroFashionInfoList[self.m_curChooseIndex]
  self:FreshShowFashionInfo()
  self:FreshVoiceOrFashionBtnShow()
end

function Form_Fashion:ChangeStaticToggle(isStatic)
  local isCurStatic = LocalDataManager:GetIntSimple("FashionStaticToggle", 0) == 1
  if isCurStatic == isStatic then
    return
  end
  LocalDataManager:SetIntSimple("FashionStaticToggle", isStatic and 1 or 0)
  if isStatic then
    UILuaHelper.PlayAnimationByName(self.m_btn_l2d, L2DCloseAnimStr)
  else
    UILuaHelper.PlayAnimationByName(self.m_btn_l2d, L2DOpenAnimStr)
  end
  self:FreshSpineStaticOrDynamicShow()
end

function Form_Fashion:OnBtnl2dClicked()
  if not self.m_curShowFashion then
    return
  end
  local isCurStatic = LocalDataManager:GetIntSimple("FashionStaticToggle", 0) == 1
  self:ChangeStaticToggle(not isCurStatic)
end

function Form_Fashion:OnBtnvoiceClicked()
  if not self.m_curShowFashion then
    return
  end
  if self.m_curShowTab == FashionTagCfg.Voice then
    return
  end
  self:ChangeSubPanelShow(FashionTagCfg.Voice)
  self:FreshVoiceOrFashionBtnShow(true)
end

function Form_Fashion:OnBtnfashionClicked()
  if not self.m_curShowFashion then
    return
  end
  if self.m_curShowTab == FashionTagCfg.Fashion then
    return
  end
  self:ChangeSubPanelShow(FashionTagCfg.Fashion)
  self:FreshVoiceOrFashionBtnShow(true)
end

function Form_Fashion:OnBtninfoClicked()
  if not self.m_curShowFashion then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HEROPREVIEW, {
    fashionId = self.m_curShowFashion.m_FashionID
  })
end

function Form_Fashion:GetDownloadResourceExtra(tParam)
  local heroID = tParam.heroID
  local vPackage = {}
  local vResourceExtra = {}
  if heroID ~= nil then
    vPackage[#vPackage + 1] = {
      sName = tostring(heroID),
      eType = DownloadManager.ResourcePackageType.Character
    }
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Fashion", Form_Fashion)
return Form_Fashion
