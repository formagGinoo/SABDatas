local Form_CastleMainLock = class("Form_CastleMainLock", require("UI/UIFrames/Form_CastleMainLockUI"))
local DefaultSliderNum = 0.6
local UnlockSmokeAnimStr = "CastleMainLock_smoke_out"
local SliderAnimStr = "CastleMainLock_slide"
local UnlockFreshAnimStr = "CastleMainLock_unlock"

function Form_CastleMainLock:SetInitParam(param)
end

function Form_CastleMainLock:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnHomeClk))
  self.m_slider_Extension = self.m_slider_node:GetComponent("ButtonExtensions")
  self.m_slider_Extension.BeginDrag = handler(self, self.OnSliderBegin)
  self.m_slider_Extension.EndDrag = handler(self, self.OnSliderEnd)
  self.m_placeID = nil
  self.m_placeCfg = nil
end

function Form_CastleMainLock:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  self:PlayOpenAudio()
end

function Form_CastleMainLock:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
  if self.callback then
    self.callback()
    self.callback = nil
  end
end

function Form_CastleMainLock:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleMainLock:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_placeID = tonumber(tParam.placeID)
    self.m_placeCfg = CastleManager:GetCastlePlaceCfgByID(self.m_placeID)
    self.IsFullScreen = not tParam.NotFullScreen
    self.callback = tParam.callback
    self.m_csui.m_param = nil
  end
end

function Form_CastleMainLock:ClearCacheData()
  self.m_placeID = nil
  self.m_placeCfg = nil
end

function Form_CastleMainLock:AddEventListeners()
  self:addEventListener("eGameEvent_Castle_UnlockPlace", handler(self, self.OnPlaceUnlock))
end

function Form_CastleMainLock:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CastleMainLock:OnPlaceUnlock(param)
  if param.placeID == self.m_placeID then
    if self.m_unlockTimer then
      TimeService:KillTimer(self.m_unlockTimer)
      self.m_unlockTimer = nil
    end
    local animLen = UILuaHelper.GetAnimationLengthByName(self.m_Form_CastleMainLock_smoke, UnlockSmokeAnimStr)
    if 0 < animLen then
      self:FreshUI()
      UILuaHelper.SetActive(self.m_Form_CastleMainLock_smoke, true)
      UILuaHelper.PlayAnimationByName(self.m_Form_CastleMainLock_smoke, UnlockSmokeAnimStr)
      UILuaHelper.PlayAnimationByName(self.m_rootTrans, UnlockFreshAnimStr)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(129)
      self.m_unlockTimer = TimeService:SetTimer(animLen, 1, function()
        self.m_unlockTimer = nil
        UILuaHelper.ResetAnimationByName(self.m_Form_CastleMainLock_smoke, UnlockSmokeAnimStr)
        UILuaHelper.SetActive(self.m_Form_CastleMainLock_smoke, false)
      end)
    end
  end
end

function Form_CastleMainLock:FreshUI()
  if not self.m_placeID then
    return
  end
  self:FreshUnlockStatus()
end

function Form_CastleMainLock:PlaceBaseInfo()
  if not self.m_placeCfg then
    return
  end
  self.m_txt_name_Text.text = self.m_placeCfg.m_mName
  self.m_txt_des_Text.text = self.m_placeCfg.m_mPlaceText
  local unlockItem = self.m_placeCfg.m_UnlockData
  local itemCfg = ItemManager:GetItemConfigById(unlockItem)
  self.m_txt_des2_Text.text = itemCfg.m_mItemDesc
  self.m_widgetBtnBack:SetExplainID(self.m_placeCfg.m_Tips)
  self.m_btn_symbol:SetActive(self.m_placeCfg.m_Tips > 0)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_txt_des)
  UILuaHelper.SetLocalPosition(self.m_txt_des, 0, 0, 0)
  UILuaHelper.SetAtlasSprite(self.m_icon_key_light_Image, self.m_placeCfg.m_KeyPic)
  UILuaHelper.SetAtlasSprite(self.m_icon_key_gray_Image, self.m_placeCfg.m_KeyPic)
end

function Form_CastleMainLock:PlayOpenAudio()
  if not self.m_placeCfg then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(self.m_placeCfg.m_MainLockAudio)
end

function Form_CastleMainLock:FreshUnlockStatus()
  local isUnlock, _ = CastleManager:IsCastlePlaceUnlock(self.m_placeID)
  local unlockItem = self.m_placeCfg.m_UnlockData
  local itemNum = ItemManager:GetItemNum(unlockItem)
  local isCanUnlock = false
  if 0 < itemNum then
    isCanUnlock = true
  end
  UILuaHelper.SetActive(self.m_icon_key_light, isUnlock or isCanUnlock)
  UILuaHelper.SetActive(self.m_icon_key_gray, not isUnlock and not isCanUnlock)
  UILuaHelper.SetActive(self.m_node_conditions, not isUnlock and not isCanUnlock)
  UILuaHelper.SetActive(self.m_slider_node, not isUnlock and isCanUnlock)
  UILuaHelper.SetActive(self.m_img_accepted, isUnlock)
  UILuaHelper.SetActive(self.m_txt_des2, isUnlock)
  UILuaHelper.SetActive(self.m_Form_CastleMainLock_smoke, not isUnlock)
  UILuaHelper.SetActive(self.m_Form_CastleMainLock_Unlock, false)
  UILuaHelper.SetActive(self.m_From_CastleMainLock_slide, not isUnlock and isCanUnlock)
  UILuaHelper.SetActive(self.m_From_CastleMainLock_slide_2, not isUnlock and isCanUnlock)
  if not isUnlock and isCanUnlock then
    UILuaHelper.PlayAnimationByName(self.m_slider_node, SliderAnimStr)
  end
  if not isUnlock and not isCanUnlock then
    self.m_txt_conditions_Text.text = self.m_placeCfg.m_mUnlockText
  end
  UILuaHelper.SetActive(self.m_open_name, isUnlock)
  UILuaHelper.SetActive(self.m_close_name, not isUnlock)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_close_name)
  self:PlaceBaseInfo()
  self.m_slider_node_Slider.value = DefaultSliderNum
end

function Form_CastleMainLock:OnBtnBlockClicked()
  self:CloseForm()
end

function Form_CastleMainLock:OnBackClk()
  self:CloseForm()
end

function Form_CastleMainLock:OnHomeClk()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_CastleMainLock:OnSliderBegin()
  self.m_isInSlider = true
  UILuaHelper.StopAnimation(self.m_slider_node)
  local sliderNode = self.m_slider_node
  TimeService:SetTimer(0.01, 1, function()
    UILuaHelper.ResetAnimationByName(sliderNode, SliderAnimStr, 1)
  end)
end

function Form_CastleMainLock:OnSliderEnd()
  if self.m_isInSlider then
    self.m_isInSlider = false
    local currentPercent = self.m_slider_node_Slider.value
    if 1 <= currentPercent then
      CastleManager:ReqCastleUnlockKeyPlace(self.m_placeID)
    else
      UILuaHelper.PlayAnimationByName(self.m_slider_node, SliderAnimStr)
    end
  end
end

function Form_CastleMainLock:IsFullScreen()
  return self.IsFullScreen
end

local fullscreen = true
ActiveLuaUI("Form_CastleMainLock", Form_CastleMainLock)
return Form_CastleMainLock
