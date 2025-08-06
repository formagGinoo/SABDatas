local Form_CastleStrongHoldMap = class("Form_CastleStrongHoldMap", require("UI/UIFrames/Form_CastleStrongHoldMapUI"))
local ShopPos
local TweenTime = 0.5

function Form_CastleStrongHoldMap:SetInitParam(param)
end

function Form_CastleStrongHoldMap:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnHomeClk))
  self.storyHelper = self.m_Content:GetComponent("PrefabHelper")
  self.storyHelper:RegisterCallback(handler(self, self.OnInitStoryItem))
  self.m_grayImgMaterial = self.m_icon_arrow_Image.material
  self:InitUI()
  ShopPos = self.m_ShowPos.transform.localPosition
end

function Form_CastleStrongHoldMap:OnActive()
  self.super.OnActive(self)
  self.m_pnl_event:SetActive(false)
  self.m_common_top_back:SetActive(true)
  self.m_ShowStoryType = CastleStoryManager.ShowStoryType.Plot
  self:ResetMapAllPlaceShow()
  self:FreshUI()
  self:addEventListener("eGameEvent_Castle_UnlockPlace", handler(self, self.FreshNodes))
  self:addEventListener("eGameEvent_CastleStoryFresh", handler(self, self.FreshUI))
  CS.GlobalManager.Instance:TriggerWwiseBGMState(218)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(219)
end

function Form_CastleStrongHoldMap:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(220)
end

function Form_CastleStrongHoldMap:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleStrongHoldMap:InitUI()
  self.UICompnents = {}
  local CastlePlaceIns = ConfigManager:GetConfigInsByName("CastlePlace")
  local allPlaceCfg = CastlePlaceIns:GetAll()
  local placeNameDic = {}
  for i, tempPlaceCfg in pairs(allPlaceCfg) do
    if tempPlaceCfg.m_Type == 2 then
      placeNameDic[tempPlaceCfg.m_Button] = tempPlaceCfg
      local tempPlaceButtonData = {castlePlaceCfg = tempPlaceCfg}
      local placeID = tempPlaceCfg.m_PlaceID
      self.UICompnents[placeID] = tempPlaceButtonData
    end
  end
  local root = self.m_pnl_btn_stronghold.transform
  local childCount = root.childCount
  for i = 1, childCount do
    local child = root:GetChild(i - 1)
    local buttonName = child.name
    local tempPlaceCfg = placeNameDic[buttonName]
    if tempPlaceCfg then
      local placeID = tempPlaceCfg.m_PlaceID
      local tempButton = child:GetComponent(T_Button)
      if tempButton then
        UILuaHelper.BindButtonClickManual(tempButton, function()
          self:OnPlaceEnterItemClk(placeID)
        end)
      end
      local btn = child:Find("btn_hero"):GetComponent(T_Button)
      if btn then
        UILuaHelper.BindButtonClickManual(btn, function()
          if self.leftTimes < 1 then
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(48001))
            return
          end
          local cfg = CastleStoryManager:GetPlaceCurStory(placeID).cfg
          self:OnStoryItemClk(cfg)
        end)
      end
      local name_normal = child:Find("pnl_normal/txt_name"):GetComponent("TMPPro")
      local name_lock = child:Find("pnl_lock/txt_name02"):GetComponent("TMPPro")
      name_normal.text = tempPlaceCfg.m_mName
      name_lock.text = tempPlaceCfg.m_mName
      local redDot = child:Find("stronghold_redpoint").gameObject
      self:RegisterOrUpdateRedDotItem(redDot, RedDotDefine.ModuleType.CastlePlaceItem, {placeID = placeID})
      self.UICompnents[placeID].mComponent = {
        go = child.gameObject,
        node_normal = child:Find("pnl_normal"),
        node_lock = child:Find("pnl_lock"),
        node_hero = child:Find("btn_hero"),
        icon_hero = child:Find("btn_hero/img_bg/c_head_mask/icon_hero"):GetComponent("Image")
      }
    end
  end
end

function Form_CastleStrongHoldMap:FreshUI()
  self:FreshData()
  self:FreshRightTop()
  self:FreshNodes()
end

function Form_CastleStrongHoldMap:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    local m_placeID = tonumber(tParam.placeID)
    local m_placeCfg = CastleManager:GetCastlePlaceCfgByID(m_placeID)
    local subPlaceID = tParam.subPlaceID
    if subPlaceID then
      self:ShowPlaceSolo(subPlaceID)
    end
    self.m_csui.m_param = nil
    self.m_widgetBtnBack:SetExplainID(m_placeCfg.m_Tips)
  end
end

function Form_CastleStrongHoldMap:FreshRightTop()
  local maxTimes = CastleStoryManager:GetMaxStoryEnergyCount()
  local leftTimes = maxTimes - CastleStoryManager:GetiStoryTimes()
  self.leftTimes = leftTimes
  self.m_txt_num_strength_Text.text = leftTimes .. "/" .. maxTimes
  local storyList = {}
  if self.m_ShowStoryType == CastleStoryManager.ShowStoryType.Plot then
    storyList = CastleStoryManager:GetAllPlaceCurStoryList()
  else
    storyList = CastleStoryManager:GetAllFinishedStoryInfo()
  end
  UILuaHelper.SetActive(self.m_img_bg_light, self.m_ShowStoryType == CastleStoryManager.ShowStoryType.Plot)
  UILuaHelper.SetActive(self.m_icon_light, self.m_ShowStoryType == CastleStoryManager.ShowStoryType.Plot)
  UILuaHelper.SetActive(self.m_icon_dark, self.m_ShowStoryType == CastleStoryManager.ShowStoryType.Playback)
  UILuaHelper.SetActive(self.m_img_bg_light02, self.m_ShowStoryType == CastleStoryManager.ShowStoryType.Playback)
  UILuaHelper.SetActive(self.m_icon_dark02, self.m_ShowStoryType == CastleStoryManager.ShowStoryType.Plot)
  UILuaHelper.SetActive(self.m_icon_light02, self.m_ShowStoryType == CastleStoryManager.ShowStoryType.Playback)
  if not utils.isNull(self.m_common_empty) then
    UILuaHelper.SetActive(self.m_common_empty, #storyList == 0)
  end
  local count = #storyList
  self.m_txt_num_event_Text.text = count
  self.storyList = storyList
  self.storyHelper:CheckAndCreateObjs(count)
  if count == 0 then
    self.m_icon_arrow_Image.material = self.m_grayImgMaterial
    self.m_icon_message_Image.material = self.m_grayImgMaterial
  else
    self.m_icon_arrow_Image.material = nil
    self.m_icon_message_Image.material = nil
  end
end

function Form_CastleStrongHoldMap:FreshNodes()
  if not self.UICompnents then
    return
  end
  if not next(self.UICompnents) then
    return
  end
  for i, v in pairs(self.UICompnents) do
    local tempPlaceCfg = v.castlePlaceCfg
    local openFlag = CastleManager:IsCastlePlaceUnlock(tempPlaceCfg.m_PlaceID)
    local mComponent = v.mComponent
    UILuaHelper.SetActive(mComponent.node_normal, openFlag)
    UILuaHelper.SetActive(mComponent.node_lock, not openFlag)
    local storydata = CastleStoryManager:GetPlaceCurStory(tempPlaceCfg.m_PlaceID)
    if storydata and CastleStoryManager:IsStoryCanShow(storydata) then
      UILuaHelper.SetActive(mComponent.node_hero, true)
      local heroID = storydata.cfg.m_ShowCharacter
      ResourceUtil:CreateHeroIcon(mComponent.icon_hero, heroID)
    else
      UILuaHelper.SetActive(mComponent.node_hero, false)
    end
  end
end

function Form_CastleStrongHoldMap:OnInitStoryItem(go, index)
  local idx = index + 1
  UILuaHelper.SetCanvasGroupAlpha(go, 0)
  TimeService:SetTimer(0.06 * index, 1, function()
    UILuaHelper.SetCanvasGroupAlpha(go, 1)
    UILuaHelper.PlayAnimationByName(go, "m_pnl_event_tab_in")
  end)
  local transform = go.transform
  local cfg = self.storyList[idx]
  local heroID = cfg.m_ShowCharacter
  local img = transform:Find("m_btn_tab_root/img_head_mask/m_img_hero"):GetComponent("Image")
  ResourceUtil:CreateHeroIcon(img, heroID)
  local m_txt_castle_tabtxt_Text = transform:Find("m_btn_tab_root/m_txt_castle_tabtxt"):GetComponent("TMPPro")
  m_txt_castle_tabtxt_Text.text = cfg.m_mTitle
  local btn = go:GetComponent("Button")
  btn.onClick:RemoveAllListeners()
  btn.onClick:AddListener(function()
    if self.m_ShowStoryType == CastleStoryManager.ShowStoryType.Plot then
      if self.leftTimes < 1 then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(48001))
        return
      end
      self:OnStoryItemClk(cfg)
    else
      self:OnStoryPlaybackItemClk(cfg)
    end
  end)
end

function Form_CastleStrongHoldMap:OnPlaceEnterItemClk(placeID)
  self.m_pnl_event:SetActive(false)
  if not placeID then
    return
  end
  local tempPlaceButtonData = self.UICompnents[placeID]
  if not tempPlaceButtonData then
    return
  end
  local castlePlaceCfg = tempPlaceButtonData.castlePlaceCfg
  local unlockType = castlePlaceCfg.m_UnlockType
  if unlockType == CastleManager.UnlockType.KeyUnlock then
    self:CheckEnterForm(castlePlaceCfg)
  else
    local isUnlock, unlockTips = CastleManager:IsCastlePlaceUnlock(placeID)
    if isUnlock ~= true then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, unlockTips)
      return
    end
    self:CheckEnterForm(castlePlaceCfg)
  end
end

function Form_CastleStrongHoldMap:CheckEnterForm(castlePlaceCfg)
  if not castlePlaceCfg then
    return
  end
  local systemStr = castlePlaceCfg.m_Prefab
  local systemParam = "ID_" .. string.upper(systemStr)
  local systemID = UIDefines[systemParam]
  if not systemID then
    return
  end
  local paramTab = self:GetPrefabParamByStr(castlePlaceCfg.m_PrefabParam) or {}
  paramTab.NotFullScreen = true
  
  function paramTab.callback()
    self.m_common_top_back:SetActive(true)
    self:ResetMapAllPlaceShow(castlePlaceCfg.m_PlaceID)
    GlobalManagerIns:TriggerWwiseBGMState(31)
  end
  
  self.m_common_top_back:SetActive(false)
  self:ShowPlaceSolo(castlePlaceCfg.m_PlaceID)
  StackFlow:Push(systemID, paramTab)
  GlobalManagerIns:TriggerWwiseBGMState(17)
end

function Form_CastleStrongHoldMap:GetPrefabParamByStr(params)
  if not params then
    return
  end
  local paramTab = {}
  local paramLen = params.Length
  if paramLen <= 0 then
    return paramTab
  end
  for i = 0, paramLen - 1 do
    local tempParam = params[i]
    local keyStr = tempParam[0]
    local paramStr = tempParam[1]
    paramTab[keyStr] = paramStr
  end
  return paramTab
end

function Form_CastleStrongHoldMap:ShowPlaceSolo(m_PlaceID)
  local go
  for k, v in pairs(self.UICompnents) do
    if k == m_PlaceID then
      v.mComponent.go:SetActive(true)
      go = v.mComponent.go
    else
      v.mComponent.go:SetActive(false)
    end
  end
  local offset = ShopPos - go.transform.localPosition
  self.toSequence = Tweening.DOTween.Sequence()
  self.m_img_bg.transform:DOLocalMove(offset, TweenTime)
  self.m_pnl_btn_stronghold.transform:DOLocalMove(offset, TweenTime)
end

function Form_CastleStrongHoldMap:ResetMapAllPlaceShow(m_PlaceID)
  for k, v in pairs(self.UICompnents) do
    v.mComponent.go:SetActive(true)
  end
  self.BackSequence = Tweening.DOTween.Sequence()
  self.m_img_bg.transform:DOLocalMove(Vector3.zero, TweenTime)
  self.m_pnl_btn_stronghold.transform:DOLocalMove(Vector3.zero, TweenTime)
end

function Form_CastleStrongHoldMap:OnStoryItemClk(storyCfg)
  local placeID = storyCfg.m_PlaceID
  local tempPlaceButtonData = self.UICompnents[placeID]
  StackPopup:Push(UIDefines.ID_FORM_CASTLEEVENTPOP, {
    cfg = storyCfg,
    callback = function()
      if not tempPlaceButtonData then
        CastleStoryManager:SetCurClkPlace(placeID)
        self:CloseForm()
      else
        self:ShowPlaceSolo(placeID)
      end
    end,
    is_FullScreen = not tempPlaceButtonData
  })
  self:OnBtnblockClicked()
end

function Form_CastleStrongHoldMap:OnStoryPlaybackItemClk(storyCfg)
  StackFlow:Push(UIDefines.ID_FORM_CASTLEEVENTPOP, {
    cfg = storyCfg,
    is_FullScreen = 1,
    showStoryType = self.m_ShowStoryType
  })
  self:OnBtnblockClicked()
end

function Form_CastleStrongHoldMap:OnBackClk()
  self:CloseForm()
end

function Form_CastleStrongHoldMap:OnHomeClk()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_CastleStrongHoldMap:OnBtnblockClicked()
  self.m_pnl_event:SetActive(false)
  self.m_icon_arrow.transform.localScale = Vector3(1, -1, 1)
end

function Form_CastleStrongHoldMap:OnBtneventClicked()
  if not self.storyList or #self.storyList == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(48002))
    return
  end
  if self.m_pnl_event.activeSelf then
    self.m_pnl_event:SetActive(false)
    self.m_icon_arrow.transform.localScale = Vector3(1, -1, 1)
  else
    self.m_pnl_event:SetActive(true)
    self.m_icon_arrow.transform.localScale = Vector3(1, 1, 1)
  end
end

function Form_CastleStrongHoldMap:OnBtndialogueClicked()
  self.m_ShowStoryType = CastleStoryManager.ShowStoryType.Plot
  self:FreshRightTop()
end

function Form_CastleStrongHoldMap:OnBtnreviewClicked()
  self.m_ShowStoryType = CastleStoryManager.ShowStoryType.Playback
  self:FreshRightTop()
end

function Form_CastleStrongHoldMap:OnBtnstrengthClicked()
  self.m_pnl_event:SetActive(false)
  utils.popUpDirectionsUI({
    tipsID = 1181,
    func1 = function()
    end
  })
end

function Form_CastleStrongHoldMap:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleStrongHoldMap", Form_CastleStrongHoldMap)
return Form_CastleStrongHoldMap
