local Form_GachaMain = class("Form_GachaMain", require("UI/UIFrames/Form_GachaMainUI"))
local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
local c_item_root_in = "c_item_root_in"
local PlayerPrefs = CS.UnityEngine.PlayerPrefs
local VideoResNameList = {
  "Gacha_Video_02_1_time",
  "Gacha_Summon_10_times",
  "Gacha_Video_02_10_times",
  "Gacha_Summon_1_time",
  "Gacha_Video_End",
  "Gacha_Summon_1_time_man",
  "Gacha_Video_End_man",
  "Gacha_SSR_show"
}
local FirstVideoResNameList = {
  "Gacha_Video_01",
  "Gacha_Enter_1stTime",
  "Gacha_1stTime_Summon",
  "Censor_Black"
}
local AudiobnkId = {
  52,
  53,
  54,
  46,
  47,
  48,
  152
}
local VideoPlot = {
  "Gacha_Video_01",
  "Gacha_Enter_1stTime"
}

function Form_GachaMain:SetInitParam(param)
end

function Form_GachaMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_content_node:SetActive(true)
  local resourceBarRoot = self.m_rootTrans:Find("m_content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("m_content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil)
  self.m_subPanelData = {}
  self.m_curChooseTab = 1
  self:AddEventListeners()
  self.m_preLoadFlag = true
end

function Form_GachaMain:OnActive()
  self.super.OnActive(self)
  self.m_content_node:SetActive(true)
  self.m_firstEnter = true
  self.m_changeTabLockUI = false
  self.m_subPanelData = {}
  self.m_gachaData = nil
  self:GeneratedGachaList()
  if self.m_csui.m_param and self.m_csui.m_param.windowId then
    self:SetChooseTab(self.m_csui.m_param.windowId)
    self.m_csui.m_param.windowId = nil
  end
  self:refreshTabLoopScroll()
  self:ChangeTab(self.m_curChooseTab)
  self.m_firstEnter = false
  GachaManager:ResetChooseWindowId()
  if self.m_csui.m_param.isPlayAudio then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(52)
  end
end

function Form_GachaMain:OnInactive()
  self.super.OnInactive(self)
  self.m_selTabObj = nil
  self.m_gachaData = nil
  if self.m_csui.m_param.isPlayAudio then
    self.m_csui.m_param.isPlayAudio = false
  end
  if self.m_subPanelData then
    for i, panelData in pairs(self.m_subPanelData) do
      if panelData.subPanelLua and panelData.subPanelLua.dispose then
        panelData.subPanelLua:dispose()
        panelData.subPanelLua = nil
      end
    end
    self.m_subPanelData = {}
  end
  for key, v in pairs(self.timerList or {}) do
    TimeService:KillTimer(v)
  end
  self.timerList = nil
  self.m_changeTabLockUI = false
end

function Form_GachaMain:PreLoadUI()
  StackFlow:TryLoadUI(UIDefines.ID_FORM_GACHASHOW, nil, nil)
end

function Form_GachaMain:SetChooseTab(windowId)
  local index = 1
  if windowId then
    for i, v in ipairs(self.m_subPanelData) do
      if v.config and v.config.m_windowID == windowId then
        index = i
        break
      end
    end
  end
  self.m_curChooseTab = index
end

function Form_GachaMain:RefreshResourceBar()
  local panelData = self.m_subPanelData[self.m_curChooseTab]
  if panelData then
    local mainCurrency = utils.changeCSArrayToLuaTable(panelData.config.m_MainCurrency)
    self.m_widgetResourceBar:FreshChangeItems(mainCurrency)
  end
end

function Form_GachaMain:OnUpdate(dt)
  if self.m_subPanelData then
    for i, v in ipairs(self.m_subPanelData) do
      if v.subPanelLua and v.subPanelLua.OnUpdate then
        v.subPanelLua:OnUpdate(dt)
      end
    end
  end
end

function Form_GachaMain:AddEventListeners()
  self:addEventListener("eGameEvent_DoGacha", handler(self, self.OnEventGachaResult))
  self:addEventListener("eGameEvent_GetGachaWishHeroList", handler(self, self.OnGetWishHeroList))
  self:addEventListener("eGameEvent_SaveGachaWishHeroList", handler(self, self.OnSaveWishHeroList))
  self:addEventListener("eGameEvent_GachaFirstVideoFinish", handler(self, self.OnFirstGachaVideoPlayFinish))
  self:addEventListener("eGameEvent_VideoStart", handler(self, self.OnVideoPlayStart))
  self:addEventListener("eGameEvent_Gacha_DailyResetGetData", handler(self, self.OnDailyReset))
  self:addEventListener("eGameEvent_Gacha_StepGachaGetReward", handler(self, self.OnFreshTab))
end

function Form_GachaMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GachaMain:OnDailyReset()
  if self.m_subPanelData then
    for i, v in ipairs(self.m_subPanelData) do
      if v.subPanelLua and v.subPanelLua.OnDailyReset then
        v.subPanelLua:OnDailyReset()
      end
    end
  end
end

function Form_GachaMain:OnFreshTab(iGachaID)
  self.m_subPanelData[self.m_curChooseTab].redDot = GachaManager:CheckGachaPoolHaveRedDotById(iGachaID)
  self:refreshTabLoopScroll()
end

function Form_GachaMain:OnFirstGachaVideoPlayFinish()
  self.m_content_node:SetActive(false)
  self.m_content_node:SetActive(true)
end

function Form_GachaMain:OnEventGachaResult(gachaData)
  GachaManager:SetGachaGuideCheckFlag(true)
  GachaManager:SetSkippedHeroShow(false)
  UILuaHelper.SetPlayVideoIsSkipped(false)
  self.m_gachaData = gachaData
  local str = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Gacha) or ""
  if str ~= GachaManager.FirstGachaStr then
    local function callFun()
      ClientDataManager:SetClientValue(ClientDataManager.ClientKeyType.Gacha, GachaManager.FirstGachaStr)
      
      self:OnVideoPlayFinish2(gachaData)
      CS.WwiseMusicPlayer.Instance:TryStop("Gacha_Video_01")
      CS.WwiseMusicPlayer.Instance:TryStop("Vo_Gacha_Video_01")
      self:broadcastEvent("eGameEvent_VideoFinish", "Gacha_Video_01")
    end
    
    CS.UI.UILuaHelper.PlayFromAddRes("Gacha_Video_01", "Gacha_Video_01", true, callFun, CS.UnityEngine.ScaleMode.ScaleToFit, false)
    GlobalManagerIns:TriggerWwiseBGMState(90)
    UILuaHelper.StartPlaySFX("Vo_Gacha_Video_01")
  else
    self:OnVideoPlayFinish2(gachaData)
  end
end

function Form_GachaMain:OnVideoPlayFinish2(gachaData)
  if GachaManager:IsSkippedInteract() then
    local heroDataList = GachaManager:GetHeroDataAndPreLoadVideo(gachaData.vGachaItem)
    local param = {heroDataList = heroDataList, param = gachaData}
    if not CS.UI.UILuaHelper.CheckFormUIIsShow(UIDefines.ID_FORM_GACHASHOW) then
      StackFlow:Push(UIDefines.ID_FORM_GACHASHOW, param)
    end
  elseif not CS.UI.UILuaHelper.CheckFormUIIsShow(UIDefines.ID_FORM_GACHATOUCHNEW) then
    StackFlow:Push(UIDefines.ID_FORM_GACHATOUCHNEW, gachaData)
  end
  self:broadcastEvent("eGameEvent_DoGachaEnd")
end

function Form_GachaMain:OnVideoPlayStart(videoName)
  if videoName == "Gacha_Video_01" then
    if GachaManager:IsSkippedInteract() then
      local heroDataList = GachaManager:GetHeroDataAndPreLoadVideo(self.m_gachaData.vGachaItem)
      local param = {
        heroDataList = heroDataList,
        param = self.m_gachaData
      }
      if not CS.UI.UILuaHelper.CheckFormUIIsShow(UIDefines.ID_FORM_GACHASHOW) then
        StackFlow:Push(UIDefines.ID_FORM_GACHASHOW, param)
      end
    elseif not CS.UI.UILuaHelper.CheckFormUIIsShow(UIDefines.ID_FORM_GACHATOUCHNEW) then
      StackFlow:Push(UIDefines.ID_FORM_GACHATOUCHNEW, self.m_gachaData)
    end
  end
end

function Form_GachaMain:GeneratedGachaList()
  local gachaAllCfg = GachaIns:GetAll()
  self.m_subPanelData = {}
  for i, itemCfg in pairs(gachaAllCfg) do
    local flag = UnlockSystemUtil:CheckGachaIsOpenById(itemCfg.m_GachaID)
    if flag and itemCfg then
      local redDot = PlayerPrefs.GetInt("Gacha_" .. tostring(itemCfg.m_GachaID), 0) ~= 1
      redDot = redDot or GachaManager:CheckGachaPoolHaveRedDotById(itemCfg.m_GachaID)
      self.m_subPanelData[#self.m_subPanelData + 1] = {
        redDot = redDot,
        panelRoot = self.m_gachainfo_root,
        config = itemCfg,
        subPanelName = itemCfg.m_GachaCover,
        backFun = function()
        end
      }
    end
  end
  table.sort(self.m_subPanelData, function(a, b)
    return a.config.m_BannerOrder > b.config.m_BannerOrder
  end)
  if not self.m_subPanelData[self.m_curChooseTab] then
    self.m_curChooseTab = 1
  end
end

function Form_GachaMain:refreshTabLoopScroll()
  local data = self.m_subPanelData
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_scrollView
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "c_btn_go" then
          if self.m_changeTabLockUI == true then
            return
          end
          CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
          if self.m_curChooseTab == index then
            return
          end
          self:RefreshGachaRedDat(index, cell_data)
          self:ChangeTab(index, cell_data)
          self:refreshTabLoopScroll()
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    self.m_loop_scroll_view:moveToCellIndex(self.m_curChooseTab)
  else
    self.m_loop_scroll_view:reloadData(data, true)
  end
end

function Form_GachaMain:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local c_item_root = luaBehaviour:FindGameObject("c_item_root")
  local config = cell_data.config
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_go", true)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_select", self.m_curChooseTab == index)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_UIFX_Team_btn", self.m_curChooseTab == index)
  UIUtil.setLocalScale(c_item_root, self.m_curChooseTab == index and 1 or 0.87, self.m_curChooseTab == index and 1 or 0.87)
  LuaBehaviourUtil.setImg(luaBehaviour, "c_img_herobg", config.m_BannerPic)
  LuaBehaviourUtil.setImg(luaBehaviour, "c_img_herobg_mask", config.m_BannerPic)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_herobg_mask", self.m_curChooseTab ~= index)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_desc1", config.m_mName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_desc2", config.m_mName2)
  if self.m_firstEnter then
    UILuaHelper.PlayAnimationByName(cell_object, c_item_root_in)
  end
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_redpoint", cell_data.redDot)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_timebg", false)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_time", false)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_count", false)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_RemainTime_icon", false)
  if config.m_TagType then
    if config.m_TagType == 1 then
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_bg2", false)
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_bg2", true)
      UILuaHelper.SetColorByMultiIndex(luaBehaviour:FindGameObject("c_img_bg2"), (config.m_TagType + 2) % 3)
    end
  end
  if config.m_EndTime ~= "" then
    self.timerList = self.timerList or {}
    if self.timerList[config.m_GachaID] then
      TimeService:KillTimer(self.timerList[config.m_GachaID])
      self.timerList[config.m_GachaID] = nil
    end
    local endTime = TimeUtil:TimeStringToTimeSec2(config.m_EndTime)
    local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.gacha, {
      id = config.m_ActId,
      gacha_id = config.m_GachaID
    })
    if is_corved then
      endTime = t2
    end
    local left_time = endTime - TimeUtil:GetServerTimeS()
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_time", TimeUtil:SecondsToFormatCNStr(math.floor(left_time)))
    self.timerList[config.m_GachaID] = TimeService:SetTimer(1, -1, function()
      left_time = left_time - 1
      if left_time <= 0 then
        TimeService:KillTimer(self.timerList[config.m_GachaID])
        self.timerList[config.m_GachaID] = nil
        if cell_data.subPanelLua and cell_data.subPanelLua.dispose then
          cell_data.subPanelLua:dispose()
          cell_data.subPanelLua = nil
        end
        self.m_curChooseTab = 1
        self:GeneratedGachaList()
        self:refreshTabLoopScroll()
        self:ChangeTab(self.m_curChooseTab)
        GachaManager:ResetChooseWindowId()
      end
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_time", TimeUtil:SecondsToFormatCNStr(math.floor(left_time)))
    end)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_time", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_timebg", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_RemainTime_icon", true)
  end
  if config.m_WishTimesRes ~= 0 then
    local gachaCount = GachaManager:GetGachaCountById(config.m_GachaID)
    if config.m_WishTimesRes - gachaCount > 0 then
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_count", string.gsubNumberReplace(ConfigManager:GetCommonTextById(20205), config.m_WishTimesRes - gachaCount))
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_timebg", true)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_count", true)
    end
  end
end

function Form_GachaMain:ChangeTab(index, cell_data)
  if index then
    self:ChangeGachaTabPanel(index)
    self.m_curChooseTab = index
    local curSubPanelData = self.m_subPanelData[index]
    if curSubPanelData then
      self:RefreshGachaRedDat(index, curSubPanelData)
      if curSubPanelData.subPanelLua == nil then
        self.m_changeTabLockUI = true
        local initData = curSubPanelData.config
        
        local function loadCallBack(subPanelLua)
          if subPanelLua then
            curSubPanelData.subPanelLua = subPanelLua
          end
          if subPanelLua.OnActivePanel then
            subPanelLua:OnActivePanel()
          end
          if self.m_preLoadFlag and self.PreLoadUI then
            self.m_preLoadFlag = nil
            self:PreLoadUI()
          end
          self.m_changeTabLockUI = false
        end
        
        SubPanelManager:LoadSubPanel(curSubPanelData.subPanelName, curSubPanelData.panelRoot, self, initData, {gachaConfig = initData}, loadCallBack)
      else
        self:RefreshCurTabSubPanelInfo()
      end
      self:SetGachaBg()
      self:RefreshResourceBar()
      self:RefreshWishBtnState()
    end
    if self.m_firstEnter == false then
      self:broadcastEvent("eGameEvent_WndActive", self:GetFramePrefabName())
    end
  end
end

function Form_GachaMain:RefreshCurTabSubPanelInfo()
  if not self.m_curChooseTab then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local subPanelLua = curSubPanelData.subPanelLua
    if subPanelLua then
      subPanelLua:SetActive(true)
      subPanelLua:OnFreshData()
      if subPanelLua.OnActivePanel then
        subPanelLua:OnActivePanel()
      end
    end
  end
end

function Form_GachaMain:ChangeGachaTabPanel(index)
  local lastChooseTab = self.m_curChooseTab
  if lastChooseTab then
    local lastSubPanelData = self.m_subPanelData[lastChooseTab]
    if lastSubPanelData and lastSubPanelData.subPanelLua then
      lastSubPanelData.subPanelLua:SetActive(false)
      if lastSubPanelData.subPanelLua.RemoveAllEventListeners then
        lastSubPanelData.subPanelLua:RemoveAllEventListeners()
      end
      if lastSubPanelData.subPanelLua.OnHidePanel then
        lastSubPanelData.subPanelLua:OnHidePanel()
      end
    end
  end
end

function Form_GachaMain:RefreshWishBtnState()
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab] or {}
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaWishList)
  local config = curSubPanelData.config
  if isOpen and config and config.m_WishListID and config.m_WishListID ~= 0 then
    self.m_wish_pnl:SetActive(true)
    local flag, gachaNum = GachaManager:CheckGachaWishListUnlock(config.m_WishListID)
    self.m_btn_wish_lock:SetActive(not flag)
    self.m_btn_wish_normal:SetActive(flag)
    if flag then
      local iWishRed = LocalDataManager:GetIntSimple("GachaWish" .. config.m_GachaID, 0)
      UILuaHelper.SetActive(self.m_wish_redpoint, iWishRed == 0)
    end
    if not flag and gachaNum then
      self.m_txt_wish_time_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100092), gachaNum)
    end
    self.m_btn_wish_activate:SetActive(GachaManager:CheckWishHeroIsActivate(config.m_GachaID))
  else
    self.m_wish_pnl:SetActive(false)
  end
end

function Form_GachaMain:OnGetWishHeroList()
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local config = curSubPanelData.config
    LocalDataManager:SetIntSimple("GachaWish" .. config.m_GachaID, 1)
    UILuaHelper.SetActive(self.m_wish_redpoint, false)
    StackPopup:Push(UIDefines.ID_FORM_GACHAWISHPOP, {
      wishListID = config.m_WishListID,
      gachaID = config.m_GachaID
    })
  end
end

function Form_GachaMain:OnBtnwishnormalClicked()
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local config = curSubPanelData.config
    GachaManager:ReqGachaGetWishList(config.m_GachaID)
  end
end

function Form_GachaMain:OnBtnwishlockClicked()
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab] or {}
  local isOpen, tipsId = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaWishList)
  local config = curSubPanelData.config
  if isOpen and config and config.m_WishListID and config.m_WishListID ~= 0 then
    local flag, gachaNum = GachaManager:CheckGachaWishListUnlock(config.m_WishListID)
    local str = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100092), gachaNum)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, str)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tipsId)
  end
end

function Form_GachaMain:OnSaveWishHeroList()
  self:RefreshWishBtnState()
end

function Form_GachaMain:RefreshGachaRedDat(index, cell_data)
  if cell_data then
    local config = cell_data.config
    local isOpen = PlayerPrefs.GetInt("Gacha_" .. tostring(config.m_GachaID), 0)
    if isOpen ~= 1 then
      PlayerPrefs.SetInt("Gacha_" .. tostring(config.m_GachaID), 1)
      PlayerPrefs.Save()
      self.m_subPanelData[index].redDot = false
    end
  end
end

function Form_GachaMain:SetGachaBg()
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local config = curSubPanelData.config
    ResourceUtil:CreateIconByPath(self.m_img_bg_Image, config.m_BG)
    for i = 0, self.m_other_effect.transform.childCount - 1 do
      local child = self.m_other_effect.transform:GetChild(i)
      child.gameObject:SetActive(false)
      if child.gameObject.name == curSubPanelData.subPanelName then
        UILuaHelper.SetActive(child, true)
      end
    end
  end
end

function Form_GachaMain:OnBtnmoreClicked()
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local config = curSubPanelData.config
    StackPopup:Push(UIDefines.ID_FORM_GACHAMOREPOP, {
      gacha_id = config.m_GachaID
    })
  end
end

function Form_GachaMain:OnBtnshopClicked()
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  if curSubPanelData then
    local config = curSubPanelData.config
    QuickOpenFuncUtil:OpenFunc(config.m_Jump)
  end
end

function Form_GachaMain:IsFullScreen()
  return true
end

function Form_GachaMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GACHAMAIN)
end

function Form_GachaMain:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_GachaMain:OnDestroy()
  self.super.OnDestroy(self)
  self.m_preLoadFlag = nil
  if self.m_subPanelData then
    for i, panelData in pairs(self.m_subPanelData) do
      if panelData.subPanelLua and panelData.subPanelLua.dispose then
        panelData.subPanelLua:dispose()
        panelData.subPanelLua = nil
      end
    end
  end
  self:RemoveAllEventListeners()
end

function Form_GachaMain:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local gachaAllCfg = GachaIns:GetAll()
  for i, itemCfg in pairs(gachaAllCfg) do
    local flag = UnlockSystemUtil:CheckGachaIsOpenById(itemCfg.m_GachaID)
    if flag and itemCfg then
      local sSubPanelName = itemCfg.m_GachaCover
      local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
      if vPackageSub ~= nil then
        for m = 1, #vPackageSub do
          vPackage[#vPackage + 1] = vPackageSub[m]
        end
      end
      if vResourceExtraSub ~= nil then
        for n = 1, #vResourceExtraSub do
          vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[n]
        end
      end
      if itemCfg.m_Spine and itemCfg.m_Spine ~= "" then
        vResourceExtra[#vResourceExtra + 1] = {
          sName = itemCfg.m_Spine,
          eType = DownloadManager.ResourceType.UI
        }
      end
    end
  end
  local str = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Gacha) or ""
  if str ~= GachaManager.FirstGachaStr then
    for i, v in ipairs(FirstVideoResNameList) do
      vResourceExtra[#vResourceExtra + 1] = {
        sName = v .. ".mp4",
        eType = DownloadManager.ResourceType.Video
      }
    end
  end
  for i, v in ipairs(VideoResNameList) do
    vResourceExtra[#vResourceExtra + 1] = {
      sName = v .. ".mp4",
      eType = DownloadManager.ResourceType.Video
    }
  end
  for i, v in ipairs(AudiobnkId) do
    local temptable = utils.changeCSArrayToLuaTable(UILuaHelper.GetAudioResById(v))
    if temptable then
      for _, value in pairs(temptable) do
        vResourceExtra[#vResourceExtra + 1] = {
          sName = value,
          eType = DownloadManager.ResourceType.Audio
        }
      end
    end
  end
  for i, v in ipairs(VideoPlot) do
    vResourceExtra[#vResourceExtra + 1] = {
      sName = v .. ".srt",
      eType = DownloadManager.ResourceType.Subtitle
    }
  end
  return vPackage, vResourceExtra
end

function Form_GachaMain:GetGuideConditionIsOpen(conditionType, conditionParam)
  local flag = false
  if self.m_subPanelData and not GachaManager:GetGachaGuideCheckFlag() then
    local curSubPanelData = self.m_subPanelData[self.m_curChooseTab] or {}
    if curSubPanelData.config and conditionParam == tostring(curSubPanelData.config.m_WishListID) then
      local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaWishList)
      local config = curSubPanelData.config
      if isOpen and config and config.m_WishListID and config.m_WishListID ~= 0 then
        flag = GachaManager:CheckGachaWishListUnlock(config.m_WishListID)
      end
    end
  end
  return flag
end

local fullscreen = true
ActiveLuaUI("Form_GachaMain", Form_GachaMain)
return Form_GachaMain
