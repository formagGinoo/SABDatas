local Form_HeroPreview = class("Form_HeroPreview", require("UI/UIFrames/Form_HeroPreviewUI"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local MinScale = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineMin") or 0)
local MaxScale = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineMax") or 0)
local MoveRate = 1
local DefaultScale = tonumber(ConfigManager:GetGlobalSettingsByKey("PreviewHeroSpineDefault") or 0)
local ClickInAnim = "heropreview_touch_in"
local ClickOutAnim = "heropreview_touch_out"

function Form_HeroPreview:SetInitParam(param)
end

function Form_HeroPreview:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/m_common_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, nil)
  self.m_curScale = DefaultScale
  self.m_ScreenW = ScreenSafeArea.width
  self.m_ScreenH = ScreenSafeArea.height
  self.m_SpineW = nil
  self.m_SpineH = nil
  self.m_heroCfg = nil
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
  self.m_dragExtension.isCanRecInput = true
  Input.multiTouchEnabled = true
  self:FreshData()
  self:FreshUI()
  self:FreshShowBackSliderUI()
end

function Form_HeroPreview:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_dragExtension.isCanRecInput = false
  Input.multiTouchEnabled = false
end

function Form_HeroPreview:OnDestroy()
  self.super.OnDestroy(self)
  self.m_scale_change_Slider.onValueChanged:RemoveAllListeners()
end

function Form_HeroPreview:AddEventListeners()
end

function Form_HeroPreview:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroPreview:ClearData()
end

function Form_HeroPreview:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    local heroID = tParam.heroID
    self.m_backFun = tParam.backFun
    self.m_heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroID)
    if self.m_heroCfg:GetError() then
      log.error("HeroPreview heroCfgID Cannot Find Check Config: " .. heroID)
      return
    end
    self.m_csui.m_param = nil
  end
end

function Form_HeroPreview:FreshUI()
  if not self.m_heroCfg then
    return
  end
  if self.m_heroCfg:GetError() == true then
    return
  end
  self:FreshShowHeroInfo()
end

function Form_HeroPreview:FreshShowHeroInfo()
  local heroCfg = self.m_heroCfg
  if heroCfg.m_HeroID == 0 then
    return
  end
  self:ShowHeroSpine(heroCfg.m_Spine)
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
  UILuaHelper.SetSpineTimeScale(spineRootObj, 0)
  self.m_spineW, self.m_spineH = UILuaHelper.GetUISize(spineRootObj)
  local pivotX, pivotY = UILuaHelper.GetRectTransPivot(spineRootObj)
  local offsetX = (pivotX - 0.5) * self.m_spineW
  local offsetY = (pivotY - 0.5) * self.m_spineH
  UILuaHelper.SetSizeWithCurrentAnchors(self.m_root_hero, self.m_spineW, self.m_spineH)
  UILuaHelper.SetAnchoredPosition(spineRootObj, offsetX, offsetY, 0)
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
    self.m_MinX = 0
    self.m_MaxX = 0
  else
    self.m_MinX = (self.m_ScreenW - scaleW) / 2
    self.m_MaxX = (scaleW - self.m_ScreenW) / 2
  end
  local scaleH = self.m_spineH * self.m_curScale
  if scaleH <= self.m_ScreenH then
    self.m_MinY = 0
    self.m_MaxY = 0
  else
    self.m_MinY = (self.m_ScreenH - scaleH) / 2
    self.m_MaxY = (scaleH - self.m_ScreenH) / 2
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
  UILuaHelper.SetActive(self.m_common_back, self.m_isShowBackSliderUI)
  UILuaHelper.SetActive(self.m_pnl_preview, self.m_isShowBackSliderUI)
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

function Form_HeroPreview:OnMouseDownEvent(touchData)
end

function Form_HeroPreview:OnMouseMoveEvent(touchData)
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
  if touchData.isOnUI then
    return
  end
  if touchData.isClick then
    self.m_isShowBackSliderUI = not self.m_isShowBackSliderUI
    self:FreshShowBackSliderUI()
    self:CheckShowClickAnim()
  end
  if touchData.isMove and self.m_isShowBackSliderUI == false then
    self.m_isShowBackSliderUI = true
    self:FreshShowBackSliderUI()
    self:CheckShowClickAnim()
  end
end

function Form_HeroPreview:OnScrollWheelEvent(deltaScale)
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
  local scale = pinchData.sqr / pinchData.originSqr
  local showScale = self.m_curScale
  showScale = self.m_curScale * scale
  showScale = self:GetLimitScale(showScale)
  self:FreshHeroRootScale(showScale)
end

function Form_HeroPreview:OnPinchEndEvent(pinchData)
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
  local scale = MinScale + (MaxScale - MinScale) * value
  if scale == self.m_curScale then
    return
  end
  self:FreshHeroRootScale(scale, true)
end

function Form_HeroPreview:IsFullScreen()
  return true
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
