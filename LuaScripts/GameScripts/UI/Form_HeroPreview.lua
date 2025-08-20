local Form_HeroPreview = class("Form_HeroPreview", require("UI/UIFrames/Form_HeroPreviewUI"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local MinScale = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineMin") or 0)
local MaxScale = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineMax") or 0)
local MoveRate = 1
local DefaultScale = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineDefault") or 0)
local PreviewHeroSpineMinLX = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineMinLX") or 0)
local PreviewHeroSpineMinRX = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineMinRX") or 0)
local PreviewHeroSpineMinUY = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineMinUY") or 0)
local PreviewHeroSpineMinDY = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineMinDY") or 0)
local ClickInAnim = "heropreview_touch_in"
local ClickOutAnim = "heropreview_touch_out"

function Form_HeroPreview:SetInitParam(param)
end

function Form_HeroPreview:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_curScale = DefaultScale
  self.m_ScreenW = ScreenSafeArea.width
  self.m_ScreenH = ScreenSafeArea.height
  self.m_SpineW = nil
  self.m_SpineH = nil
  self.m_fashionCfg = nil
  self.m_spineDitherExtension = nil
  self.m_MinX = nil
  self.m_MaxX = nil
  self.m_MinY = nil
  self.m_MaxY = nil
  self.m_isShowBackSliderUI = true
  self.m_dragExtension = self.m_drag_node:GetComponent("DragExtension")
  
  function self.m_dragExtension.MouseDownEvent(touchData)
    self:OnMouseDownEvent(touchData)
  end
  
  function self.m_dragExtension.MouseMoveEvent(touchData)
    self:OnMouseMoveEvent(touchData)
  end
  
  function self.m_dragExtension.MouseUpEvent(touchData)
    self:OnMouseUpEvent(touchData)
  end
  
  function self.m_dragExtension.ScrollWheelEvent(scale)
    self:OnScrollWheelEvent(scale)
  end
  
  function self.m_dragExtension.PinchInEvent(pinchData)
    self:OnPinchInEvent(pinchData)
  end
  
  function self.m_dragExtension.PinchEvent(pinchData)
    self:OnPinchEvent(pinchData)
  end
  
  function self.m_dragExtension.PinchEndEvent(pinchData)
    self:OnPinchEndEvent(pinchData)
  end
  
  self.m_scale_change_Slider.onValueChanged:AddListener(function(value)
    self:OnScaleValueChange(value)
  end)
  self.m_backFun = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_HeroPreview:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_landscapeMode = true
  self.m_dragExtension.isCanRecInput = true
  Input.multiTouchEnabled = true
  self.m_moveLock = false
  self.m_rotationLock = false
  self.m_zoomLock = false
  self.m_curScale = DefaultScale
  self:FreshData()
  self:FreshUI()
  self:FreshShowBackSliderUI()
  self:ResetRootHeroNode()
end

function Form_HeroPreview:ResetRootHeroNode()
  UILuaHelper.SetLocalRotationParam(self.m_root_hero, 0, 0, 0)
  UILuaHelper.SetLocalPosition(self.m_root_hero, 0, 0, 0)
end

function Form_HeroPreview:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_dragExtension.isCanRecInput = false
  Input.multiTouchEnabled = false
  self.m_landscapeMode = true
  self:CheckRecycleSpine(true)
end

function Form_HeroPreview:OnDestroy()
  self.super.OnDestroy(self)
  self.m_scale_change_Slider.onValueChanged:RemoveAllListeners()
  self:CheckRecycleSpine(true)
end

function Form_HeroPreview:AddEventListeners()
end

function Form_HeroPreview:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroPreview:ClearData()
end

function Form_HeroPreview:SetUILockState(fashionId)
  local cfg = HeroManager:GetCharacterViewModeCfgById(fashionId)
  if cfg and cfg.m_MoveLock then
    self.m_moveLock = cfg.m_MoveLock == 1
    self.m_rotationLock = cfg.m_RotationLock == 1
    self.m_zoomLock = cfg.m_ZoomLock == 1
  end
end

function Form_HeroPreview:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    local fashionId = tParam.fashionId
    local fashion = HeroManager:GetHeroFashion()
    if not fashion or not fashionId then
      log.error("HeroPreview error !!!")
      return
    end
    local fashionInfoCfg = fashion:GetFashionInfoByID(fashionId)
    self.m_backFun = tParam.backFun
    if not fashionInfoCfg then
      log.error("HeroPreview GetFashionInfoByID Cannot Find Check Config: " .. tostring(fashionId))
      return
    end
    self.m_fashionCfg = fashionInfoCfg
    self:SetUILockState(fashionId)
    self.m_csui.m_param = nil
  end
end

function Form_HeroPreview:FreshUI()
  if not self.m_fashionCfg then
    return
  end
  self:FreshShowHeroInfo()
end

function Form_HeroPreview:FreshShowHeroInfo()
  self:ShowHeroSpine(self.m_fashionCfg.m_Spine)
end

function Form_HeroPreview:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HeroPreview:ShowHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.HeroPreview
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack()
  end)
end

function Form_HeroPreview:OnLoadSpineBack()
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
  if spineRootObj:GetComponent("SpineSkeletonPosControl") then
    spineRootObj:GetComponent("SpineSkeletonPosControl"):OnResetInit()
  end
  self.m_spineW, self.m_spineH = UILuaHelper.GetUISize(spineRootObj)
  UILuaHelper.SetSizeWithCurrentAnchors(self.m_root_hero, self.m_spineW, self.m_spineH)
  UILuaHelper.SetAnchoredPosition(spineRootObj, 0, 0, 0)
  self:FreshHeroRootPos(0, 0)
  local scale = self:GetLimitScale(DefaultScale)
  self:FreshHeroRootScale(scale)
end

function Form_HeroPreview:GetLimitScale(scale)
  if not scale then
    return
  end
  if scale < MinScale then
    scale = MinScale
  end
  if scale > MaxScale then
    scale = MaxScale
  end
  return scale
end

function Form_HeroPreview:FreshHeroRootScale(scale, isNotFreshBar)
  self.m_curScale = scale
  UILuaHelper.SetLocalScale(self.m_root_hero, self.m_curScale, self.m_curScale, 1)
  self:FreshBorderParam()
  local curX, curY, _ = UILuaHelper.GetLocalPosition(self.m_root_hero)
  local x, y = self:GetLimitMovePos(curX, curY)
  UILuaHelper.SetLocalPosition(self.m_root_hero, x, y)
  if isNotFreshBar ~= true then
    local percent = (self.m_curScale - MinScale) / (MaxScale - MinScale)
    self.m_scale_change_Slider.value = percent
  end
end

function Form_HeroPreview:FreshHeroRootPos(x, y)
  UILuaHelper.SetLocalPosition(x, y, 0)
end

function Form_HeroPreview:FreshBorderParam()
  local scaleW = self.m_spineW * self.m_curScale
  if scaleW <= self.m_ScreenW then
    self.m_MinX = PreviewHeroSpineMinLX
    self.m_MaxX = PreviewHeroSpineMinRX
  else
    self.m_MinX = math.min((self.m_ScreenW - scaleW) / 2, PreviewHeroSpineMinLX)
    self.m_MaxX = math.max((scaleW - self.m_ScreenW) / 2, PreviewHeroSpineMinRX)
  end
  local scaleH = self.m_spineH * self.m_curScale
  if scaleH <= self.m_ScreenH then
    self.m_MinY = PreviewHeroSpineMinDY
    self.m_MaxY = PreviewHeroSpineMinUY
  else
    self.m_MinY = math.min((self.m_ScreenH - scaleH) / 2, PreviewHeroSpineMinDY)
    self.m_MaxY = math.max((scaleH - self.m_ScreenH) / 2, PreviewHeroSpineMinUY)
  end
end

function Form_HeroPreview:GetLimitMovePos(x, y)
  if x < self.m_MinX then
    x = self.m_MinX
  end
  if x > self.m_MaxX then
    x = self.m_MaxX
  end
  if y < self.m_MinY then
    y = self.m_MinY
  end
  if y > self.m_MaxY then
    y = self.m_MaxY
  end
  return x, y
end

function Form_HeroPreview:FreshShowBackSliderUI()
  UILuaHelper.SetActive(self.m_pnl_preview, self.m_isShowBackSliderUI and not self.m_zoomLock)
  UILuaHelper.SetActive(self.m_top_right_hor, self.m_landscapeMode and self.m_isShowBackSliderUI and not self.m_rotationLock)
  UILuaHelper.SetActive(self.m_bg_hor, self.m_landscapeMode)
  UILuaHelper.SetActive(self.m_bg_ver, not self.m_landscapeMode)
  UILuaHelper.SetActive(self.m_back_hor, self.m_landscapeMode and self.m_isShowBackSliderUI)
  UILuaHelper.SetActive(self.m_back_ver, not self.m_landscapeMode and self.m_isShowBackSliderUI)
  UILuaHelper.SetActive(self.m_top_right_ver, not self.m_landscapeMode and self.m_isShowBackSliderUI and not self.m_rotationLock)
  if self.m_isShowBackSliderUI and not self.m_zoomLock then
    if self.m_landscapeMode then
      UILuaHelper.SetParent(self.m_pnl_preview, self.m_slider_root_hor, true)
      UILuaHelper.SetLocalRotationParam(self.m_root_hero, 0, 0, 0)
      UILuaHelper.PlayAnimationByName(self.m_slider_root_hor, "heropreview_hor_in")
    else
      UILuaHelper.SetParent(self.m_pnl_preview, self.m_slider_root_ver, true)
      UILuaHelper.SetLocalRotationParam(self.m_root_hero, 0, 0, 90)
      UILuaHelper.PlayAnimationByName(self.m_slider_root_ver, "heropreview_hor_in")
    end
  elseif self.m_zoomLock then
    if self.m_landscapeMode then
      UILuaHelper.SetLocalRotationParam(self.m_root_hero, 0, 0, 0)
      UILuaHelper.SetLocalPosition(self.m_root_hero, 0, 0, 0)
    else
      UILuaHelper.SetLocalRotationParam(self.m_root_hero, 0, 0, 90)
      UILuaHelper.SetLocalPosition(self.m_root_hero, 0, 0, 0)
    end
  end
end

function Form_HeroPreview:CheckShowClickAnim()
  if self.m_isShowBackSliderUI then
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, ClickOutAnim)
  else
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, ClickInAnim)
  end
end

function Form_HeroPreview:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
  if self.m_backFun then
    self.m_backFun()
    self.m_backFun = nil
  end
end

function Form_HeroPreview:OnBtnhorClicked()
  self:OnBackClk()
end

function Form_HeroPreview:OnBtnverClicked()
  self:OnBackClk()
end

function Form_HeroPreview:OnBtnturnhorClicked()
  if self.m_rotationLock then
    return
  end
  self.m_landscapeMode = false
  self.m_ClickTurnScreen = true
  self:FreshShowBackSliderUI()
end

function Form_HeroPreview:OnBtnturnverClicked()
  if self.m_rotationLock then
    return
  end
  self.m_landscapeMode = true
  self.m_ClickTurnScreen = true
  self:FreshShowBackSliderUI()
end

function Form_HeroPreview:OnMouseDownEvent(touchData)
end

function Form_HeroPreview:OnMouseMoveEvent(touchData)
  if self.m_moveLock then
    return
  end
  if touchData.isOnUI then
    return
  end
  local posX, posY, _ = UILuaHelper.GetLocalPosition(self.m_root_hero)
  local deltaPos = touchData.deltaPos
  local deltaX = deltaPos.x * MoveRate
  local deltaY = deltaPos.y * MoveRate
  local changeX = posX + deltaX
  local changeY = posY + deltaY
  local endX, endY = self:GetLimitMovePos(changeX, changeY)
  UILuaHelper.SetLocalPosition(self.m_root_hero, endX, endY, 0)
end

function Form_HeroPreview:OnMouseUpEvent(touchData)
  if self.m_moveLock then
    return
  end
  if touchData.isOnUI then
    return
  end
  if touchData.isClick then
    if self.m_ClickTurnScreen then
      self.m_ClickTurnScreen = false
    else
      self.m_isShowBackSliderUI = not self.m_isShowBackSliderUI
      self:FreshShowBackSliderUI()
    end
    self:CheckShowClickAnim()
  end
  if touchData.isMove and self.m_isShowBackSliderUI == false then
    self.m_isShowBackSliderUI = true
    self:FreshShowBackSliderUI()
    self:CheckShowClickAnim()
  end
end

function Form_HeroPreview:OnScrollWheelEvent(deltaScale)
  if self.m_zoomLock then
    return
  end
  local tempScale = self.m_curScale + deltaScale
  local scale = self:GetLimitScale(tempScale)
  if scale == self.m_curScale then
    return
  end
  self:FreshHeroRootScale(scale)
end

function Form_HeroPreview:OnPinchInEvent(pinchData)
end

function Form_HeroPreview:OnPinchEvent(pinchData)
  if self.m_zoomLock then
    return
  end
  local scale = pinchData.sqr / pinchData.originSqr
  local showScale = self.m_curScale
  showScale = self.m_curScale * scale
  showScale = self:GetLimitScale(showScale)
  self:FreshHeroRootScale(showScale)
end

function Form_HeroPreview:OnPinchEndEvent(pinchData)
  if self.m_zoomLock then
    return
  end
  if self.m_isShowBackSliderUI == false then
    self.m_isShowBackSliderUI = true
    self:FreshShowBackSliderUI()
    self:CheckShowClickAnim()
  end
  local scale = pinchData.sqr / pinchData.originSqr
  local showScale = self.m_curScale
  showScale = self.m_curScale * scale
  showScale = self:GetLimitScale(showScale)
  self:FreshHeroRootScale(showScale)
end

function Form_HeroPreview:OnScaleValueChange(value)
  if self.m_zoomLock then
    return
  end
  local scale = MinScale + (MaxScale - MinScale) * value
  if scale == self.m_curScale then
    return
  end
  self:FreshHeroRootScale(scale, true)
end

function Form_HeroPreview:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local iHeroID = tParam.heroID
  vPackage[#vPackage + 1] = {
    sName = tostring(iHeroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_HeroPreview", Form_HeroPreview)
return Form_HeroPreview
