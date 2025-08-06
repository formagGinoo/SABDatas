local Form_CastleMain = class("Form_CastleMain", require("UI/UIFrames/Form_CastleMainUI"))
local CastlePlaceIns = ConfigManager:GetConfigInsByName("CastlePlace")
local HallPlaceID = 0
local BackToHomeTimeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("CastleBackToHome"))

function Form_CastleMain:SetInitParam(param)
end

function Form_CastleMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnHomeClk), 1124)
  self.m_widgetTaskEnter = self:createTaskBar(self.m_common_task_enter)
  self.m_castleListContent = self.m_castle_node_list.transform:Find("pnl_mask/Scroll View/Viewport/Content")
  self.storyHelper = self.m_Content:GetComponent("PrefabHelper")
  self.storyHelper:RegisterCallback(handler(self, self.OnInitStoryItem))
  self.m_grayImgMaterial = self.m_icon_arrow_Image.material
  self.m_castlePlaceButtons = {}
  self.m_backLobbyLockerID = nil
  self.m_popPanelLockerID = nil
  self:InitButtonDataList()
  self:CheckRegisterRedDot()
  self:PlayVoiceOnFirstEnter()
  self:AddEventListeners()
end

function Form_CastleMain:OnActive()
  self.super.OnActive(self)
  self.m_pnl_event:SetActive(false)
  self.m_ShowStoryType = CastleStoryManager.ShowStoryType.Plot
  self:FreshData()
  self:FreshUI()
  self:InitStatus()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(59)
end

function Form_CastleMain:OnOpen()
  if self.m_enterTimer then
    TimeService:KillTimer(self.m_enterTimer)
    self.m_enterTimer = nil
  end
  self.m_enterTimer = TimeService:SetTimer(self.m_uiVariables.EnterDelayTime, 1, function()
    if not self.m_ownerModule then
      return
    end
    self.m_ownerModule:ChangeToTopShow()
    self.m_enterTimer = nil
  end)
end

function Form_CastleMain:OnUncoverd()
  if not self.m_ownerModule then
    return
  end
  self.m_ownerModule:ChangeToTopShow()
  if CastleStoryManager:GetCurClkPlace() then
    self.m_ownerModule:ChangeToDetailShow(CastleStoryManager:GetCurClkPlace())
    CastleStoryManager:SetCurClkPlace()
    self:broadcastEvent("eGameEvent_CastlePopStoryWindow")
  end
end

function Form_CastleMain:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_showroom_redpoint, RedDotDefine.ModuleType.CastleStatueRewardEntry)
  self:RegisterOrUpdateRedDotItem(self.m_hangUp_redpoint, RedDotDefine.ModuleType.HangUpEntry)
  self:RegisterOrUpdateRedDotItem(self.m_star_redpoint, RedDotDefine.ModuleType.StarPlatform)
  self:RegisterOrUpdateRedDotItem(self.m_circulation_redpoint, RedDotDefine.ModuleType.HeroCirculationEntry)
  self:RegisterOrUpdateRedDotItem(self.m_showroom_redpoint2, RedDotDefine.ModuleType.CastleStatueRewardEntry)
  self:RegisterOrUpdateRedDotItem(self.m_hangUp_redpoint2, RedDotDefine.ModuleType.HangUpEntry)
  self:RegisterOrUpdateRedDotItem(self.m_star_redpoint2, RedDotDefine.ModuleType.StarPlatform)
  self:RegisterOrUpdateRedDotItem(self.m_circulation_redpoint2, RedDotDefine.ModuleType.HeroCirculationEntry)
  self:RegisterOrUpdateRedDotItem(self.m_wild_redpoint2, RedDotDefine.ModuleType.DispatchEntry)
  self:RegisterOrUpdateRedDotItem(self.m_wild_redpoint, RedDotDefine.ModuleType.DispatchEntry)
  self:RegisterOrUpdateRedDotItem(self.m_stronghold_redpoint, RedDotDefine.ModuleType.CastleEventEntry)
  self:RegisterOrUpdateRedDotItem(self.m_stronghold_redpoint2, RedDotDefine.ModuleType.CastleEventEntry)
  self:RegisterOrUpdateRedDotItem(self.m_meeting_redpoint, RedDotDefine.ModuleType.CastleCouncilEntry)
  self:RegisterOrUpdateRedDotItem(self.m_meeting_redpoint2, RedDotDefine.ModuleType.CastleCouncilEntry)
  self:RegisterOrUpdateRedDotItem(self.m_vault_redpoint, RedDotDefine.ModuleType.CastlePlaceItem, {placeID = 6})
  self:RegisterOrUpdateRedDotItem(self.m_hall_redpoint, RedDotDefine.ModuleType.CastlePlaceItem, {placeID = 7})
  self:RegisterOrUpdateRedDotItem(self.m_vault_redpoint2, RedDotDefine.ModuleType.CastlePlaceItem, {placeID = 6})
  self:RegisterOrUpdateRedDotItem(self.m_hall_redpoint2, RedDotDefine.ModuleType.CastlePlaceItem, {placeID = 7})
end

function Form_CastleMain:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function Form_CastleMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_delayPlayFloatTimer then
    TimeService:KillTimer(self.m_delayPlayFloatTimer)
    self.m_delayPlayFloatTimer = nil
  end
  if self.m_castleOutTimer then
    TimeService:KillTimer(self.m_castleOutTimer)
    self.m_castleOutTimer = nil
  end
  if self.m_backLobbyLockerID and UILockIns:IsValidLocker(self.m_backLobbyLockerID) then
    UILockIns:Unlock(self.m_backLobbyLockerID)
  end
  self.m_backLobbyLockerID = nil
  if self.m_popPanelLockerID and UILockIns:IsValidLocker(self.m_popPanelLockerID) then
    UILockIns:Unlock(self.m_popPanelLockerID)
  end
  self.m_popPanelLockerID = nil
end

function Form_CastleMain:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_csui.m_param = nil
  end
end

function Form_CastleMain:ClearCacheData()
end

function Form_CastleMain:InitButtonDataList()
  local allPlaceCfg = CastlePlaceIns:GetAll()
  local placeNameDic = {}
  for i, tempPlaceCfg in pairs(allPlaceCfg) do
    placeNameDic[tempPlaceCfg.m_Button] = tempPlaceCfg
    local tempPlaceButtonData = {
      castlePlaceCfg = tempPlaceCfg,
      enterNode = nil,
      listEnterNode = nil
    }
    local index = tempPlaceCfg.m_PlaceID
    self.m_castlePlaceButtons[index] = tempPlaceButtonData
  end
  local buttonRootTrans = self.m_castle_node.transform
  local childCount = buttonRootTrans.childCount
  for i = 1, childCount do
    local itemTrans = buttonRootTrans:GetChild(i - 1)
    local buttonName = itemTrans.name
    local tempPlaceCfg = placeNameDic[buttonName]
    if tempPlaceCfg then
      local enterNode = self:InitPlaceButtonItem(itemTrans, tempPlaceCfg)
      local placeID = tempPlaceCfg.m_PlaceID
      local tempPlaceButtonData = self.m_castlePlaceButtons[placeID]
      if tempPlaceButtonData then
        tempPlaceButtonData.enterNode = enterNode
      end
    else
      UILuaHelper.SetActive(itemTrans, false)
    end
  end
  local listNodeContentTrans = self.m_castleListContent
  childCount = listNodeContentTrans.childCount
  for i = 1, childCount do
    local itemTrans = listNodeContentTrans:GetChild(i - 1)
    local buttonName = itemTrans.name
    local tempPlaceCfg = placeNameDic[buttonName]
    if tempPlaceCfg then
      local listEnterNode = self:InitPlaceButtonItem(itemTrans, tempPlaceCfg)
      local placeID = tempPlaceCfg.m_PlaceID
      local tempPlaceButtonData = self.m_castlePlaceButtons[placeID]
      if tempPlaceButtonData then
        tempPlaceButtonData.listEnterNode = listEnterNode
      end
    else
      UILuaHelper.SetActive(itemTrans, false)
    end
  end
end

function Form_CastleMain:GetPrefabParamByStr(params)
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

function Form_CastleMain:AddEventListeners()
  self:addEventListener("eGameEvent_CastleStoryFresh", handler(self, self.FreshStoryState))
  self:addEventListener("eGameEvent_CastleDispatchStatueLevelUpRedPoint", handler(self, self.RefreshRedPoint))
  self:addEventListener("eGameEvent_Inherit_UnLock", handler(self, self.OnInheritUnLockResponse))
  self:addEventListener("eGameEvent_Castle_OpenForm", handler(self, self.OnCastleOpenForm))
  self:addEventListener("eGameEvent_Castle_CloseForm", handler(self, self.OnCastleCloseForm))
end

function Form_CastleMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CastleMain:OnCastleOpenForm(param)
  if not self.m_ownerModule then
    return
  end
  if not param then
    return
  end
  local subPlaceID = param.placeID
  local tempPlaceButtonData = self.m_castlePlaceButtons[subPlaceID]
  if not tempPlaceButtonData then
    return
  end
  local castlePlaceCfg = tempPlaceButtonData.castlePlaceCfg
  local floatWindow = castlePlaceCfg.m_FloatWindow
  if floatWindow == 1 then
    UILuaHelper.SetCanvasGroupAlpha(self.m_rootTrans, 1)
    self:ShowPopPanelEnterCastleAnim()
    self:CheckChangeSceneView(castlePlaceCfg)
  else
  end
end

function Form_CastleMain:OnCastleCloseForm(param)
  if not self.m_ownerModule then
    return
  end
  if not param then
    return
  end
  local subPlaceID = param.placeID
  local tempPlaceButtonData = self.m_castlePlaceButtons[subPlaceID]
  if not tempPlaceButtonData then
    return
  end
  local castlePlaceCfg = tempPlaceButtonData.castlePlaceCfg
  local floatWindow = castlePlaceCfg.m_FloatWindow
  if floatWindow == 1 then
    self:OnFloatWindowCloseBack()
  else
  end
end

function Form_CastleMain:FreshUI()
  self:FreLockStatus()
  self:RefreshRedPoint()
  self:FreshStoryState()
end

function Form_CastleMain:RefreshRedPoint()
  if not self.m_ownerModule then
    return
  end
  local redPoint = CastleDispatchManager:CheckDispatchRedPoint()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.DispatchEntry,
    count = redPoint
  })
end

function Form_CastleMain:InitStatus()
  if self.m_castleListContent then
    UILuaHelper.SetLocalPosition(self.m_castleListContent, 0, 0, 0)
  end
end

function Form_CastleMain:InitPlaceButtonItem(itemNodeTrans, castlePlaceCfg)
  local placeID = castlePlaceCfg.m_PlaceID
  local tempButton = itemNodeTrans:GetComponent(T_Button)
  if tempButton then
    UILuaHelper.BindButtonClickManual(tempButton, function()
      self:OnPlaceEnterItemClk(placeID)
    end)
  end
  local nodeHero = itemNodeTrans:Find("btn_hero")
  local heroIcon, btnIcon
  if nodeHero then
    heroIcon = itemNodeTrans:Find("btn_hero/img_bg/c_head_mask/icon_hero"):GetComponent(T_Image)
    btnIcon = itemNodeTrans:Find("btn_hero"):GetComponent(T_Button)
    if btnIcon then
      UILuaHelper.BindButtonClickManual(btnIcon, function()
        if self.leftTimes < 1 then
          StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(48001))
          return
        end
        local cfg = CastleStoryManager:GetPlaceCurStory(placeID).cfg
        self:OnStoryItemClk(cfg)
      end)
    end
  end
  local textName = itemNodeTrans:Find("txt_name"):GetComponent(T_TextMeshProUGUI)
  local enterIcon = itemNodeTrans:Find("icon")
  local lockNode = itemNodeTrans:Find("lock")
  local bgText = itemNodeTrans:Find("bg_txt")
  textName.text = castlePlaceCfg.m_mName
  UILuaHelper.SetActive(itemNodeTrans, true)
  return {
    rootNode = itemNodeTrans,
    tempButton = tempButton,
    nodeHero = nodeHero,
    heroIcon = heroIcon,
    textName = textName,
    bgText = bgText,
    enterIcon = enterIcon,
    lockNode = lockNode
  }
end

function Form_CastleMain:FreLockStatus()
  if not self.m_castlePlaceButtons then
    return
  end
  if not next(self.m_castlePlaceButtons) then
    return
  end
  for i, v in ipairs(self.m_castlePlaceButtons) do
    local tempPlaceCfg = v.castlePlaceCfg
    local openFlag = CastleManager:IsCastlePlaceUnlock(tempPlaceCfg.m_PlaceID)
    UILuaHelper.SetActive(v.enterNode.bgText, openFlag)
    UILuaHelper.SetActive(v.enterNode.lockNode, not openFlag)
    UILuaHelper.SetActive(v.enterNode.enterIcon, openFlag)
    if v.listEnterNode then
      UILuaHelper.SetActive(v.listEnterNode.bgText, openFlag)
      UILuaHelper.SetActive(v.listEnterNode.lockNode, not openFlag)
      UILuaHelper.SetActive(v.listEnterNode.enterIcon, openFlag)
    end
  end
end

function Form_CastleMain:FreshStoryState()
  if not self.m_ownerModule then
    return
  end
  if not UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.NightConversation) then
    self.m_btn_strength:SetActive(false)
    self.m_btn_event:SetActive(false)
    return
  end
  if not self.m_castlePlaceButtons then
    return
  end
  if not next(self.m_castlePlaceButtons) then
    return
  end
  self.m_btn_strength:SetActive(true)
  self.m_btn_event:SetActive(true)
  for i, v in ipairs(self.m_castlePlaceButtons) do
    local placeID = v.castlePlaceCfg.m_PlaceID
    if v.enterNode then
      local storydata = CastleStoryManager:GetPlaceCurStory(placeID)
      if storydata and CastleStoryManager:IsStoryCanShow(storydata) then
        UILuaHelper.SetActive(v.enterNode.nodeHero, true)
        local heroID = storydata.cfg.m_ShowCharacter
        ResourceUtil:CreateHeroIcon(v.enterNode.heroIcon, heroID)
      else
        UILuaHelper.SetActive(v.enterNode.nodeHero, false)
      end
    end
  end
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

function Form_CastleMain:OnInitStoryItem(go, index)
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

function Form_CastleMain:OnStoryItemClk(storyCfg)
  local placeID = storyCfg.m_PlaceID
  local tempPlaceButtonData = self.m_castlePlaceButtons[placeID]
  local castlePlaceCfg = tempPlaceButtonData.castlePlaceCfg
  StackFlow:Push(UIDefines.ID_FORM_CASTLEEVENTPOP, {
    cfg = storyCfg,
    callback = function()
      if castlePlaceCfg.m_Type == 2 then
        self:OnPlaceEnterItemClk(9, placeID)
        CastleStoryManager:SetCurClkPlace(9)
        return
      end
      self:CheckChangeSceneView(castlePlaceCfg)
    end,
    is_FullScreen = castlePlaceCfg.m_Type == 1
  })
  self:OnBtnblockClicked()
end

function Form_CastleMain:OnStoryPlaybackItemClk(storyCfg)
  local placeID = storyCfg.m_PlaceID
  local tempPlaceButtonData = self.m_castlePlaceButtons[placeID]
  local castlePlaceCfg = tempPlaceButtonData.castlePlaceCfg
  StackFlow:Push(UIDefines.ID_FORM_CASTLEEVENTPOP, {
    cfg = storyCfg,
    is_FullScreen = castlePlaceCfg.m_Type == 1,
    showStoryType = self.m_ShowStoryType
  })
  self:OnBtnblockClicked()
end

function Form_CastleMain:CheckEnterForm(castlePlaceCfg, subPlaceID)
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
  paramTab.subPlaceID = subPlaceID
  StackFlow:Push(systemID, paramTab)
end

function Form_CastleMain:CheckChangeSceneView(castlePlaceCfg)
  if not castlePlaceCfg then
    return
  end
  if not self.m_ownerModule then
    return
  end
  local placeID = castlePlaceCfg.m_PlaceID
  if placeID == nil or placeID == 0 then
    return
  end
  self.m_ownerModule:ChangeToDetailShow(placeID)
end

function Form_CastleMain:ShowPopPanelEnterCastleAnim()
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, self.m_uiVariables.CastleOutAnimStr)
end

function Form_CastleMain:OnBackClk()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_CastleMain:OnHomeClk()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_CastleMain:OnPlaceEnterItemClk(placeID, subPlaceID)
  self.m_pnl_event:SetActive(false)
  if not placeID then
    return
  end
  local tempPlaceButtonData = self.m_castlePlaceButtons[placeID]
  if not tempPlaceButtonData then
    return
  end
  local castlePlaceCfg = tempPlaceButtonData.castlePlaceCfg
  local unlockType = castlePlaceCfg.m_UnlockType
  if unlockType == CastleManager.UnlockType.KeyUnlock then
    self:CheckEnterForm(castlePlaceCfg, subPlaceID)
    self:CheckChangeSceneView(castlePlaceCfg)
  else
    local isUnlock, unlockTips = CastleManager:IsCastlePlaceUnlock(placeID)
    if isUnlock ~= true then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, unlockTips)
      return
    end
    local systemStr = castlePlaceCfg.m_Prefab
    local systemParam = "ID_" .. string.upper(systemStr)
    local systemID = UIDefines[systemParam]
    if not systemID then
      return
    end
    if systemID == UIDefines.ID_FORM_CASTLEMEETINGRROOM then
      if not self.m_ownerModule then
        return
      end
      self:CloseForm()
      self.m_ownerModule:ChangeToDetailShow(placeID)
      TimeService:SetTimer(1, 1, function()
        CouncilHallManager:LoadCouncilHallScene(function()
          if not self.m_ownerModule then
            self:OnHomeClk()
            return
          end
          StackFlow:Push(UIDefines.ID_FORM_CASTLEMAIN)
          self.m_ownerModule:ChangeToTopShow()
          if CastleStoryManager:GetCurClkPlace() then
            self.m_ownerModule:ChangeToDetailShow(CastleStoryManager:GetCurClkPlace())
            CastleStoryManager:SetCurClkPlace()
            self:broadcastEvent("eGameEvent_CastlePopStoryWindow")
          end
        end)
      end)
      return
    elseif systemID == UIDefines.ID_FORM_INHERIT then
      if InheritManager.m_inherit_level == 0 then
        InheritManager:ReqUnLockSystemInheritData()
        return
      end
    elseif systemID == UIDefines.ID_FORM_HANGUP then
      QuickOpenFuncUtil:OpenFunc(3)
      return
    end
    self:CheckEnterForm(castlePlaceCfg, subPlaceID)
    local floatWindow = castlePlaceCfg.m_FloatWindow
    if floatWindow ~= 1 then
      self:CheckChangeSceneView(castlePlaceCfg)
    end
  end
end

function Form_CastleMain:OnBtnlobbyClicked()
  if utils.isNull(self.m_rootTrans) then
    return
  end
  if self.m_ownerModule then
    self.m_ownerModule:ChangeToDetailShow(HallPlaceID)
  end
  self.m_backLobbyLockerID = UILockIns:Lock(BackToHomeTimeNum)
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, self.m_uiVariables.CastleOutAnimStr)
  TimeService:SetTimer(BackToHomeTimeNum, 1, function()
    self:OnBackClk()
    self.m_backLobbyLockerID = nil
  end)
end

function Form_CastleMain:OnFloatWindowCloseBack()
  if utils.isNull(self.m_rootTrans) then
    return
  end
  if self.m_ownerModule then
    self.m_ownerModule:ChangeToTopShow()
  end
  local floatWinTime = UILuaHelper.GetAnimationLengthByName(self.m_rootTrans, self.m_uiVariables.CastleFloatWinTime)
  local delayPlayTime = tonumber(ConfigManager:GetGlobalSettingsByKey("DelayCastleOutPopPanelTime"))
  self.m_popPanelLockerID = UILockIns:Lock(floatWinTime + delayPlayTime)
  if self.m_delayPlayFloatTimer then
    TimeService:KillTimer(self.m_delayPlayFloatTimer)
    self.m_delayPlayFloatTimer = nil
  end
  self.m_delayPlayFloatTimer = TimeService:SetTimer(delayPlayTime, 1, function()
    self.m_delayPlayFloatTimer = nil
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, self.m_uiVariables.CastleInAnimStr)
  end)
  if self.m_castleOutTimer then
    TimeService:KillTimer(self.m_castleOutTimer)
    self.m_castleOutTimer = nil
  end
  self.m_castleOutTimer = TimeService:SetTimer(floatWinTime + delayPlayTime, 1, function()
    self.m_castleOutTimer = nil
    self.m_popPanelLockerID = nil
  end)
end

function Form_CastleMain:OnBtnblockClicked()
  self.m_pnl_event:SetActive(false)
  self.m_icon_arrow.transform.localScale = Vector3(1, -1, 1)
end

function Form_CastleMain:OnBtneventClicked()
  if self.m_pnl_event.activeSelf then
    self.m_pnl_event:SetActive(false)
    self.m_icon_arrow.transform.localScale = Vector3(1, -1, 1)
  else
    self.m_pnl_event:SetActive(true)
    self.m_icon_arrow.transform.localScale = Vector3(1, 1, 1)
  end
end

function Form_CastleMain:OnBtnstrengthClicked()
  utils.popUpDirectionsUI({
    tipsID = 1181,
    func1 = function()
    end
  })
end

function Form_CastleMain:OnInheritUnLockResponse()
  if not self.m_ownerModule then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_INHERIT)
end

function Form_CastleMain:OnBtndialogueClicked()
  self.m_ShowStoryType = CastleStoryManager.ShowStoryType.Plot
  self:FreshStoryState()
end

function Form_CastleMain:OnBtnreviewClicked()
  self.m_ShowStoryType = CastleStoryManager.ShowStoryType.Playback
  self:FreshStoryState()
end

function Form_CastleMain:IsFullScreen()
  return true
end

function Form_CastleMain:PlayVoiceOnFirstEnter()
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("HomeVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
end

local fullscreen = true
ActiveLuaUI("Form_CastleMain", Form_CastleMain)
return Form_CastleMain
