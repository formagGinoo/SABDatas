local Form_BattleSetting = class("Form_BattleSetting", require("UI/UIFrames/Form_BattleSettingUI"))
local SettingTab = {
  Quality = 1,
  System = 2,
  Language = 3,
  Battle = 4,
  Push = 5,
  Download = 6,
  Account = 7
}

function Form_BattleSetting:SetInitParam(param)
end

function Form_BattleSetting:AfterInit()
  self.super.AfterInit(self)
  self.m_subPanel = {
    [SettingTab.Battle] = {
      tabMain = self.m_tab4,
      tabBtn = self.m_fighting_select,
      panel = self.m_pnl_battle,
      tabUnselect = self.m_btn_fighting.transform:Find("txt_fighting").gameObject
    },
    [SettingTab.System] = {
      tabMain = self.m_tab2,
      tabBtn = self.m_system_select,
      panel = self.m_pnl_system,
      tabUnselect = self.m_btn_system.transform:Find("txt_system").gameObject
    },
    [SettingTab.Quality] = {
      tabMain = self.m_tab1,
      tabBtn = self.m_pic_select,
      panel = self.m_pnl_pic,
      tabUnselect = self.m_btn_pic.transform:Find("txt_pic").gameObject
    },
    [SettingTab.Language] = {
      tabMain = self.m_tab3,
      tabBtn = self.m_lang_select,
      panel = self.m_pnl_lang,
      tabUnselect = self.m_btn_lang.transform:Find("txt_lang").gameObject
    },
    [SettingTab.Push] = {
      tabMain = self.m_tab5,
      tabBtn = self.m_tips_select,
      panel = self.m_pnl_tips,
      tabUnselect = self.m_btn_tips.transform:Find("txt_tips").gameObject
    },
    [SettingTab.Download] = {
      tabMain = self.m_tab6,
      tabBtn = self.m_download_select,
      panel = self.m_pnl_download,
      tabUnselect = self.m_btn_download.transform:Find("txt_download").gameObject
    },
    [SettingTab.Account] = {
      tabMain = self.m_tab7,
      tabBtn = self.m_account_select,
      panel = self.m_pnl_account,
      tabUnselect = self.m_account.transform:Find("txt_account").gameObject
    }
  }
  self.m_subFunc = {
    [SettingTab.Battle] = {
      InitFunc = handler(self, self.InitBattlePanel),
      RefreshFunc = handler(self, self.RefreshBattlePanel)
    },
    [SettingTab.System] = {
      InitFunc = handler(self, self.InitSystemPanel),
      RefreshFunc = handler(self, self.RefreshSystemPanel)
    },
    [SettingTab.Quality] = {
      InitFunc = handler(self, self.InitQualityPanel),
      RefreshFunc = handler(self, self.RefreshQualityPanel)
    },
    [SettingTab.Language] = {
      InitFunc = handler(self, self.InitLanguagePanel),
      RefreshFunc = handler(self, self.RefreshLanguagePanel)
    },
    [SettingTab.Push] = {
      InitFunc = handler(self, self.InitPushPanel),
      RefreshFunc = handler(self, self.RefreshPushPanel)
    },
    [SettingTab.Download] = {
      InitFunc = handler(self, self.InitDownloadPanel),
      RefreshFunc = handler(self, self.RefreshDownloadPanel)
    },
    [SettingTab.Account] = {
      InitFunc = handler(self, self.InitAccountPanel),
      RefreshFunc = handler(self, self.RefreshAccountPanel)
    }
  }
  self.m_initMap = {}
  self:CheckRegisterRedDot()
  if ActivityManager:IsInCensorOpen() then
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowSkillCutInKey, 1)
    self.m_skill_group:SetActive(false)
  else
    self.m_skill_group:SetActive(true)
  end
  if ChannelManager:IsEUChannel() and not ChannelManager:IsWindows() then
    self.m_txt_moreinfo:SetActive(true)
    self.m_txt_moreinfo:GetComponent("ButtonExtensions").Clicked = handler(self, self.OnBtnMoreClicked)
  else
    self.m_txt_moreinfo:SetActive(false)
  end
end

function Form_BattleSetting:AddEventListeners()
  self:addEventListener("eGameEvent_PauseGame", handler(self, self.OnPauseGame))
end

function Form_BattleSetting:OnPauseGame(bPaused)
  if bPaused then
  elseif self.m_pushInfinityGrid and self.m_vPushList then
    self.m_pushInfinityGrid:ShowItemList(self.m_vPushList)
  end
end

function Form_BattleSetting:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattleSetting:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:InitView()
end

function Form_BattleSetting:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:Save()
end

function Form_BattleSetting:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_qualityInfinityGrid then
    self.m_qualityInfinityGrid:DisPoseItems()
    self.m_qualityInfinityGrid = nil
  end
end

function Form_BattleSetting:OnHyperClickedFlog()
  if not self.logLevel then
    local activityModule = ActivityManager:GetActivityByType(MTTD.ActivityType_ModuleControl)
    if activityModule then
      self.logLevel = activityModule:GetFlogControlData().iLogLevel or 0
    end
  end
  utils.CheckAndPushCommonTips({
    tipsID = 1193,
    func1 = function()
      ReportManager:ReportFlog(self.logLevel)
    end
  })
end

function Form_BattleSetting:InitView()
  local tParam = self.m_csui.m_param
  if tParam ~= nil and tParam.hideTypeList then
    local hideTypeList = tParam.hideTypeList
    for k, v in ipairs(hideTypeList) do
      if self.m_subPanel[v] then
        self.m_subPanel[v].tabMain:SetActive(false)
      end
    end
  else
    for k, v in pairs(self.m_subPanel) do
      v.tabMain:SetActive(true)
    end
  end
  self.m_btn_pilotcode:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.InitiationCode))
  if tParam ~= nil and tParam.iSelect then
    self:SwitchTab(tParam.iSelect, true)
  else
    self:SwitchTab(SettingTab.Account, true)
  end
end

function Form_BattleSetting:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_SettingAccount_redPoint, RedDotDefine.ModuleType.SettingAccount)
  self:RegisterOrUpdateRedDotItem(self.m_SettingCustomerService_redPoint, RedDotDefine.ModuleType.SettingCustomerService)
end

function Form_BattleSetting:InitSubPanel(settingTab)
  if self.m_initMap[settingTab] then
    return
  end
  self.m_subFunc[settingTab].InitFunc()
  self.m_initMap[settingTab] = true
end

function Form_BattleSetting:RefreshSubPanel(settingTab)
  if self.m_subFunc[settingTab].RefreshFunc then
    self.m_subFunc[settingTab].RefreshFunc()
  end
end

function Form_BattleSetting:InitBattlePanel()
  local showSkillTips = UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowSkillTipsKey, 0)
  self.m_initShowSkillTips = showSkillTips
  if showSkillTips == 1 then
    self.m_btn_line_yes_ActiveToggle.isOn = true
    BattleGlobalManager:SetAllVisualCharacterLineVisible(true)
  else
    self.m_btn_line_no_ActiveToggle.isOn = true
    BattleGlobalManager:SetAllVisualCharacterLineVisible(false)
  end
  local defaultShowSkillCutIn = CS.DataCooker.GetAndCreateLogicGlobalSettingsCookedData("DefaultShowSkillCutIn"):GetValueInt()
  local showSkillCutIn = UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowSkillCutInKey, defaultShowSkillCutIn)
  if showSkillCutIn == 0 then
    self.m_btn_show_yes_ActiveToggle.isOn = true
  elseif showSkillCutIn == 1 then
    self.m_btn_show_no_ActiveToggle.isOn = true
  elseif showSkillCutIn == 2 then
    self.m_btn_show_once_ActiveToggle.isOn = true
  end
  local showBattleBlood = UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowBattleBloodKey, 0)
  if showBattleBlood == 0 then
    self.m_btn_blood_yes_ActiveToggle.isOn = true
  elseif showBattleBlood == 1 then
    self.m_btn_blood_no_ActiveToggle.isOn = true
  elseif showBattleBlood == 2 then
    self.m_btn_blood_smart_ActiveToggle.isOn = true
  end
  local showMaxSkillOffset = UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowMaxSkillOffsetKey, 0)
  if showMaxSkillOffset == 1 then
    self.m_btn_indicator_yes_ActiveToggle.isOn = true
  elseif showMaxSkillOffset == 0 then
    self.m_btn_indicator_no_ActiveToggle.isOn = true
  end
  local showCameraShake = UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowCameraShakeKey, 0)
  if showCameraShake == 0 then
    self.m_btn_lens_yes_ActiveToggle.isOn = true
  elseif showCameraShake == 1 then
    self.m_btn_lens_no_ActiveToggle.isOn = true
  end
end

function Form_BattleSetting:RefreshBattlePanel()
end

function Form_BattleSetting:InitSystemPanel()
  self:InitItemView(self.m_all, 0)
  self:InitItemView(self.m_sfx, 1)
  self:InitItemView(self.m_music, 2)
  self:InitItemView(self.m_voice, 3)
end

function Form_BattleSetting:RefreshSystemPanel()
end

function Form_BattleSetting:InitQualityPanel()
  local settingGraphicsInfoIns = ConfigManager:GetConfigInsByName("SettingGraphicsInfo")
  local settingGraphicsChoiceIns = ConfigManager:GetConfigInsByName("SettingGraphicsChoice")
  local initQualityGridData = {
    itemClkBackFun = handler(self, self.OnQualityItemClk)
  }
  self.m_qualityInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_pic_InfinityGrid, "Setting/UISettingQualityItem", initQualityGridData)
  local qualitySettingList = {}
  local settingGraphicsInfoAll = settingGraphicsInfoIns:GetAll()
  local settingGraphicsChoiceAll = settingGraphicsChoiceIns:GetAll()
  local maxValue = 1
  local ChooiceHideList = {}
  local GraphicHideList = {}
  if IsWindowsPlatform() then
    local hideKeys = {}
    for _, key in ipairs(hideKeys) do
      ChooiceHideList[key] = 1
    end
  end
  if not (not IsAndroidPlatform() or CS.DeviceUtil.IsEmulatorX86()) or IsIPhonePlatform() then
    local hideKeys = {201}
    for _, key in ipairs(hideKeys) do
      ChooiceHideList[key] = 1
    end
  end
  if IsAndroidPlatform() or IsIPhonePlatform() then
    local hideGrapId = {3, 4}
    for _, key in ipairs(hideGrapId) do
      GraphicHideList[key] = 1
    end
  end
  for k, v in pairs(settingGraphicsInfoAll) do
    local iGraphicID = v.m_GraphicID
    if iGraphicID == 1 then
      maxValue = CS.GameQualityManager.Instance.DetectedQualityLevel
    elseif iGraphicID == 2 then
      maxValue = CS.GameQualityManager.Instance:GetMaxFPS()
    end
    if v.m_Hide == 0 and GraphicHideList[iGraphicID] == nil then
      local settingDetail = {}
      local disableList = {}
      for k2, v2 in pairs(settingGraphicsChoiceAll) do
        if v2.m_GraphicID ~= iGraphicID or v2.m_Hide ~= 0 or ChooiceHideList[v2.m_ChoiceID] ~= nil then
        elseif maxValue < v2.m_GameValue then
          disableList[#disableList + 1] = v2
        else
          settingDetail[#settingDetail + 1] = v2
        end
      end
      table.sort(settingDetail, function(a, b)
        return a.m_ChoiceID < b.m_ChoiceID
      end)
      table.sort(disableList, function(a, b)
        return a.m_ChoiceID < b.m_ChoiceID
      end)
      table.insertto(settingDetail, disableList)
      qualitySettingList[#qualitySettingList + 1] = {
        qualityInfo = v,
        qualityChoice = settingDetail,
        parentTransform = self.m_pnl_pic.transform,
        scrollView = self.m_scrollView_pic
      }
    end
  end
  table.sort(qualitySettingList, function(a, b)
    return a.qualityInfo.m_Order < b.qualityInfo.m_Order
  end)
  self.m_qualitySettingList = qualitySettingList
end

function Form_BattleSetting:RefreshQualityPanel()
  self.m_scrollView_pic:GetComponent("ScrollRect").normalizedPosition = CS.UnityEngine.Vector2(0, 1)
  self.m_qualityInfinityGrid:ShowItemList(self.m_qualitySettingList)
end

function Form_BattleSetting:InitLanguagePanel()
  local multiLangCfgAll = CData_MultiLanguage:GetAll()
  local vLanguageList = {}
  local vVoiceList = {}
  for i, v in pairs(multiLangCfgAll) do
    if v.m_IsEnable == 1 then
      vLanguageList[#vLanguageList + 1] = v
    end
    if v.m_IsEnableVoice == 1 then
      vVoiceList[#vVoiceList + 1] = v
    end
  end
  table.sort(vLanguageList, function(a, b)
    return a.m_ID < b.m_ID
  end)
  self.m_vLanguageList = vLanguageList
  table.sort(vVoiceList, function(a, b)
    return a.m_ID < b.m_ID
  end)
  self.m_vVoiceList = vVoiceList
  self.m_selectLanguageIndex = 1
  local languageConfig = {}
  for i, v in ipairs(vLanguageList) do
    languageConfig[#languageConfig + 1] = {
      iIndex = i,
      sTitle = v.m_LanguageName
    }
    if v.m_ID == CS.MultiLanguageManager.g_iLanguageID then
      self.m_selectLanguageIndex = i
    end
  end
  local widgetBtnFilter = self:createFilterButton(self.m_ui_sys_fitler_lang1)
  self.m_widgetBtnFilter = widgetBtnFilter
  widgetBtnFilter:RefreshTabConfig(languageConfig, self.m_selectLanguageIndex, nil, function(filterIndex, isFilterDown)
    if filterIndex == self.m_selectLanguageIndex then
      return
    end
    self:OnSelectLanguageID(vLanguageList[filterIndex].m_ID, filterIndex)
  end, function(item, tabConfig)
    local itemText = item.transform:Find("common_filter_tab_name"):GetComponent(T_TextMeshProUGUI)
    item.transform:Find("common_filter_tab_name").gameObject:SetActive(true)
    local selectBg = item.transform:Find("img_select_bg").gameObject
    item.transform:Find("txt_dis").gameObject:SetActive(false)
    item.transform:Find("txt_recommend").gameObject:SetActive(false)
    item.transform:Find("txt_contain").gameObject:SetActive(false)
    if self.m_selectLanguageIndex == tabConfig.iIndex then
      itemText.color = CS.UnityEngine.Color(0.2196078431372549, 0.2196078431372549, 0.2196078431372549)
      selectBg:SetActive(true)
    else
      itemText.color = CS.UnityEngine.Color(0.8588235294117647, 0.8235294117647058, 0.7411764705882353)
      selectBg:SetActive(false)
    end
    itemText.text = tabConfig.sTitle
  end, function(tabConfig)
    return tabConfig.sTitle
  end, nil, self.m_pnl_lang.transform)
  self.m_selectVoiceIndex = 1
  local voiceConfig = {}
  local settingLanguageIns = ConfigManager:GetConfigInsByName("SettingLanguage")
  for i, v in ipairs(vVoiceList) do
    local languageCfg = settingLanguageIns:GetValue_ByLanID(v.m_LanID)
    voiceConfig[#voiceConfig + 1] = {
      iIndex = i,
      sTitle = languageCfg.m_mVoiceName
    }
    if v.m_ID == CS.MultiLanguageManager.g_iLanguageVoiceID then
      self.m_selectVoiceIndex = i
    end
  end
  local widgetBtnFilter2 = self:createFilterButton(self.m_ui_sys_fitler_lang2)
  self.m_widgetBtnFilter2 = widgetBtnFilter2
  widgetBtnFilter2:RefreshTabConfig(voiceConfig, self.m_selectVoiceIndex, nil, function(filterIndex, isFilterDown, tabConfig)
    self:OnSelectVoiceID(vVoiceList[filterIndex].m_ID, filterIndex, tabConfig)
  end, function(item, tabConfig)
    local stLanguageElment = CData_MultiLanguage:GetValue_ByID(vVoiceList[tabConfig.iIndex].m_ID)
    local sLabelName = "multilanvo_" .. stLanguageElment.m_SoundType
    local needDownloadSize = DownloadManager:GetTotalBytesByLabel(sLabelName) - DownloadManager:GetDownloadedBytesByLabel(sLabelName)
    tabConfig.needDownloadSize = needDownloadSize
    local itemText = item.transform:Find("common_filter_tab_name"):GetComponent(T_TextMeshProUGUI)
    local selectBg = item.transform:Find("img_select_bg").gameObject
    item.transform:Find("txt_dis").gameObject:SetActive(false)
    item.transform:Find("txt_recommend").gameObject:SetActive(false)
    if self.m_selectVoiceIndex == tabConfig.iIndex then
      itemText.color = CS.UnityEngine.Color(0.2196078431372549, 0.2196078431372549, 0.2196078431372549)
      selectBg:SetActive(true)
      item.transform:Find("common_filter_tab_name").gameObject:SetActive(true)
      item.transform:Find("txt_contain").gameObject:SetActive(false)
      itemText.text = tabConfig.sTitle
    else
      if 0 < needDownloadSize then
        item.transform:Find("txt_contain").gameObject:SetActive(true)
        item.transform:Find("common_filter_tab_name").gameObject:SetActive(false)
        local sizeMB = needDownloadSize / 1024 / 1024
        if 1000 < sizeMB then
          sizeMB = sizeMB / 1024
          item.transform:Find("txt_contain"):Find("txt_contain2"):GetComponent(T_TextMeshProUGUI).text = string.format(" %.02f%s", sizeMB, DownloadManager:GetGBStr())
        else
          item.transform:Find("txt_contain"):Find("txt_contain2"):GetComponent(T_TextMeshProUGUI).text = string.format(" %.02f%s", sizeMB, DownloadManager:GetMBStr())
        end
        item.transform:Find("txt_contain"):Find("txt_contain1"):GetComponent(T_TextMeshProUGUI).text = tabConfig.sTitle
        UILuaHelper.ForceRebuildLayoutImmediate(item.transform:Find("txt_contain").gameObject)
      else
        item.transform:Find("txt_contain").gameObject:SetActive(false)
        item.transform:Find("common_filter_tab_name").gameObject:SetActive(true)
        itemText.text = tabConfig.sTitle
        itemText.color = CS.UnityEngine.Color(0.8588235294117647, 0.8235294117647058, 0.7411764705882353)
      end
      selectBg:SetActive(false)
    end
  end, function(tabConfig)
    return tabConfig.sTitle
  end, nil, self.m_pnl_lang.transform)
end

function Form_BattleSetting:RefreshLanguagePanel()
end

function Form_BattleSetting:InitPushPanel()
  local settingPushIns = ConfigManager:GetConfigInsByName("SettingPush")
  local settingPushCfgAll = settingPushIns:GetAll()
  local vPushList = {}
  for i, v in pairs(settingPushCfgAll) do
    if v.m_Default ~= -1 then
      vPushList[#vPushList + 1] = {
        pushCfg = v,
        callFunc = handler(self, self.OnPushItemToggle)
      }
    end
  end
  table.sort(vPushList, function(a, b)
    return a.pushCfg.m_PushID < b.pushCfg.m_PushID
  end)
  self.m_vPushList = vPushList
  self.m_mPushOption = PushNotificationManager:GetPushOption()
  self.m_pushInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_tips_InfinityGrid, "Setting/UISettingPushItem")
  self.m_pushInfinityGrid:ShowItemList(vPushList)
end

function Form_BattleSetting:RefreshPushPanel()
  if self.m_pushInfinityGrid and self.m_vPushList then
    self.m_pushInfinityGrid:ShowItemList(self.m_vPushList)
  end
end

function Form_BattleSetting:OnPushItemToggle(pushCfg, isOn, activeToggle)
  local function _setPush()
    self.m_isPushDirty = true
    
    self.m_mPushOption[pushCfg.m_PushID] = isOn and 1 or 0
    self.m_isChanged = true
  end
  
  if pushCfg.m_PushType == 1 and isOn then
    if not PushNotificationManager:CheckPermission() then
      activeToggle.isOn = false
      log.error("Permissions is not enabled")
      utils.CheckAndPushCommonTips({
        tipsID = 1184,
        func1 = function()
          PushNotificationManager:RequestPermission()
          log.error("Jump to Phone Setting")
          StackTop:RemoveUIFromStack(UIDefines.ID_FORM_COMMONTIPS)
        end,
        func2 = function()
          StackTop:RemoveUIFromStack(UIDefines.ID_FORM_COMMONTIPS)
        end
      })
    else
      _setPush()
    end
  else
    _setPush()
  end
end

function Form_BattleSetting:SavePush()
  if self.m_isPushDirty then
    PushNotificationManager:SyncPushOptionToServer(self.m_mPushOption)
    self.m_isPushDirty = false
  end
end

function Form_BattleSetting:InitDownloadPanel()
  local bDownloadMobile = DownloadManager:CanDownloadInMobile()
  self.m_btn_autodl_ActiveToggle.isOn = bDownloadMobile
end

function Form_BattleSetting:RefreshDownloadPanel()
  self.m_scrollView_download:GetComponent("ScrollRect").normalizedPosition = CS.UnityEngine.Vector2(0, 1)
end

function Form_BattleSetting:InitAccountPanel()
end

function Form_BattleSetting:RefreshAccountPanel()
  if ChannelManager:IsChinaChannel() then
    self.m_btn_playercenter:SetActive(false)
  elseif ChannelManager:IsDMMChannel() then
    self.m_btn_playercenter:SetActive(false)
  else
    self.m_btn_playercenter:SetActive(true)
  end
  self.m_btn_customerlist:SetActive(true)
  self.m_btn_secret:SetActive(true)
  if ChannelManager:IsChinaChannel() then
    self.m_txt_ICP:SetActive(true)
    local mIcpTxt = string.replace(ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(210028).m_mMessage, "\"\"", "\"")
    self.m_txt_ICP_Text.text = mIcpTxt
  else
    self.m_txt_ICP:SetActive(false)
  end
  self.m_btn_3list:SetActive(ChannelManager:IsChinaChannel())
  self.m_btn_systemlist:SetActive(ChannelManager:IsChinaChannel())
  self.m_btn_personlist:SetActive(false)
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.RedemptionCode)
  self.m_btn_redemptioncode:SetActive(openFlag)
  local activityModule = ActivityManager:GetActivityByType(MTTD.ActivityType_ModuleControl)
  local isOpenFlogReport = 1
  if activityModule then
    isOpenFlogReport = activityModule:GetFlogControlData().iReportButtonControl or 1
  end
  UILuaHelper.SetActive(self.m_txt_FlogReport, isOpenFlogReport == 0)
  self.m_txt_FlogReport_Text.text = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(220002).m_mMessage
  local btnFlog = self.m_txt_FlogReport.gameObject:GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(btnFlog, function()
    self:OnHyperClickedFlog()
  end)
end

function Form_BattleSetting:OnBtnlogoutClicked()
  if ChannelManager:IsChinaChannel() then
    CS.AIHelp.AIHelpSupport.ResetUserInfo()
  else
    CS.AiHelpManager.Instance:AiHelpResetUserInfo()
  end
  ApplicationManager:RestartGame()
end

function Form_BattleSetting:OnBtndelClicked()
  StackTop:Push(UIDefines.ID_FORM_PLAYERACCOUNTDELPOP)
end

function Form_BattleSetting:OnBtnautodlClicked()
  DownloadManager:SwitchDownloadInMobile()
  self.m_isChanged = true
end

function Form_BattleSetting:InitItemView(rootGo, iType)
  local c_btn_mute = rootGo.transform:Find("c_btn_mute"):GetComponent("Button")
  local c_btn_voice = rootGo.transform:Find("c_btn_voice"):GetComponent("Button")
  local slider = rootGo.transform:Find("c_Slider"):GetComponent("Slider")
  local sliderValue = 0
  local muteValue = false
  if iType == 0 then
    sliderValue = CS.WwiseMusicPlayer.Instance.MasterVolume
    muteValue = CS.WwiseMusicPlayer.Instance.MuteMasterVolume
  elseif iType == 1 then
    sliderValue = CS.WwiseMusicPlayer.Instance.MusicVolume
    muteValue = CS.WwiseMusicPlayer.Instance.MuteMusicVolume
  elseif iType == 2 then
    sliderValue = CS.WwiseMusicPlayer.Instance.SFXVolume
    muteValue = CS.WwiseMusicPlayer.Instance.MuteSFXVolume
  elseif iType == 3 then
    sliderValue = CS.WwiseMusicPlayer.Instance.VoiceVolume
    muteValue = CS.WwiseMusicPlayer.Instance.MuteVoiceVolume
  end
  if sliderValue == 0 then
    muteValue = true
  elseif muteValue then
    sliderValue = 0
  end
  slider.value = sliderValue
  local sliderText = rootGo.transform:Find("c_txt_slider"):GetComponent("TextMeshProUGUI")
  sliderText.text = tostring(math.floor(sliderValue * 100))
  slider.onValueChanged:AddListener(function()
    self:UpdateSliderView(slider, sliderText, c_btn_mute, c_btn_voice, slider.value, iType)
  end)
  c_btn_mute.onClick:AddListener(function()
    self:UpdateMuteView(slider, sliderText, c_btn_mute, c_btn_voice, iType, false)
  end)
  c_btn_voice.onClick:AddListener(function()
    self:UpdateMuteView(slider, sliderText, c_btn_mute, c_btn_voice, iType, true)
  end)
  c_btn_mute.gameObject:SetActive(muteValue)
  c_btn_voice.gameObject:SetActive(not muteValue)
end

function Form_BattleSetting:UpdateSliderView(slider, sliderText, c_btn_mute, c_btn_voice, sliderValue, iType)
  if iType == 0 then
    CS.WwiseMusicPlayer.Instance.MasterVolume = sliderValue
  elseif iType == 1 then
    CS.WwiseMusicPlayer.Instance.MusicVolume = sliderValue
  elseif iType == 2 then
    CS.WwiseMusicPlayer.Instance.SFXVolume = sliderValue
  elseif iType == 3 then
    CS.WwiseMusicPlayer.Instance.VoiceVolume = sliderValue
  end
  local isMute = sliderValue == 0
  self:UpdateMuteView(slider, sliderText, c_btn_mute, c_btn_voice, iType, isMute)
  self.m_isChanged = true
end

function Form_BattleSetting:UpdateMuteView(slider, sliderText, c_btn_mute, c_btn_voice, iType, isMute)
  if iType == 0 then
    CS.WwiseMusicPlayer.Instance.MuteMasterVolume = isMute
  elseif iType == 1 then
    CS.WwiseMusicPlayer.Instance.MuteMusicVolume = isMute
  elseif iType == 2 then
    CS.WwiseMusicPlayer.Instance.MuteSFXVolume = isMute
  elseif iType == 3 then
    CS.WwiseMusicPlayer.Instance.MuteVoiceVolume = isMute
  end
  if isMute then
    slider:SetValueWithoutNotify(0)
  elseif iType == 0 then
    slider:SetValueWithoutNotify(CS.WwiseMusicPlayer.Instance.MasterVolume)
  elseif iType == 1 then
    slider:SetValueWithoutNotify(CS.WwiseMusicPlayer.Instance.MusicVolume)
  elseif iType == 2 then
    slider:SetValueWithoutNotify(CS.WwiseMusicPlayer.Instance.SFXVolume)
  elseif iType == 3 then
    slider:SetValueWithoutNotify(CS.WwiseMusicPlayer.Instance.VoiceVolume)
  end
  sliderText.text = tostring(math.floor(slider.value * 100))
  c_btn_mute.gameObject:SetActive(isMute)
  c_btn_voice.gameObject:SetActive(not isMute)
  self.m_isChanged = true
end

function Form_BattleSetting:Save()
  if self.m_btn_line_yes_ActiveToggle.isOn then
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowSkillTipsKey, 1)
    BattleGlobalManager:SetAllVisualCharacterLineVisible(true)
  else
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowSkillTipsKey, 0)
    BattleGlobalManager:SetAllVisualCharacterLineVisible(false)
  end
  if self.m_initShowSkillTips ~= nil and self.m_initShowSkillTips ~= UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowSkillTipsKey, 0) then
    self.m_isChanged = true
  end
  if self.m_btn_show_yes_ActiveToggle.isOn then
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowSkillCutInKey, 0)
  elseif self.m_btn_show_no_ActiveToggle.isOn then
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowSkillCutInKey, 1)
  elseif self.m_btn_show_once_ActiveToggle.isOn then
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowSkillCutInKey, 2)
  end
  local showBattleBloodValue = 0
  if self.m_btn_blood_yes_ActiveToggle.isOn then
    showBattleBloodValue = 0
  elseif self.m_btn_blood_no_ActiveToggle.isOn then
    showBattleBloodValue = 1
  elseif self.m_btn_blood_smart_ActiveToggle.isOn then
    showBattleBloodValue = 2
  end
  local curShowBattleBloodValue = UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowBattleBloodKey, 0)
  if curShowBattleBloodValue ~= showBattleBloodValue then
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowBattleBloodKey, showBattleBloodValue)
    CS.UI.UILuaHelper.SendReport(CS.LogicDefine.LogicReportType.eShowBattleBlood, showBattleBloodValue)
  end
  local showMaxSkillOffsetValue = 0
  if self.m_btn_indicator_yes_ActiveToggle.isOn then
    showMaxSkillOffsetValue = 1
  elseif self.m_btn_indicator_no_ActiveToggle.isOn then
    showMaxSkillOffsetValue = 0
  end
  local curShowMaxSkillOffsetValue = UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowMaxSkillOffsetKey, 0)
  if curShowMaxSkillOffsetValue ~= showMaxSkillOffsetValue then
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowMaxSkillOffsetKey, showMaxSkillOffsetValue)
    CS.UI.UILuaHelper.SendReport(CS.LogicDefine.LogicReportType.eShowMaxSkillOffset, showMaxSkillOffsetValue)
  end
  local showCameraShakeValue = 0
  if self.m_btn_lens_yes_ActiveToggle.isOn then
    showCameraShakeValue = 0
  elseif self.m_btn_lens_no_ActiveToggle.isOn then
    showCameraShakeValue = 1
  end
  local curShowCameraShakeValue = UILuaHelper.GetPlayerPreference(CS.LogicDefine.ShowCameraShakeKey, 0)
  if curShowCameraShakeValue ~= showCameraShakeValue then
    UILuaHelper.SetPlayerPreference(CS.LogicDefine.ShowCameraShakeKey, showCameraShakeValue)
    CS.UI.UILuaHelper.SendReport(CS.LogicDefine.LogicReportType.eShowCameraShake, showCameraShakeValue)
  end
  CS.WwiseMusicPlayer.Instance:SaveVoiceSetting()
  self:SavePush()
  self:Report()
end

function Form_BattleSetting:Report()
  if self.m_isChanged then
    self.m_isChanged = false
    local data = {}
    data.user_quality_settings = CS.GameQualityManager.Instance.CustomQualityLevel
    data.user_fps_settings = CS.GameQualityManager.Instance:GetCurFPS()
    data.volume_all = CS.WwiseMusicPlayer.Instance.MasterVolume
    data.volume_effect = CS.WwiseMusicPlayer.Instance.SFXVolume
    data.volume_voice = CS.WwiseMusicPlayer.Instance.VoiceVolume
    data.volume_music = CS.WwiseMusicPlayer.Instance.MusicVolume
    data.user_language_settings = CS.MultiLanguageManager.g_iLanguageID
    data.user_voice_language = CS.MultiLanguageManager.g_iLanguageVoiceID
    data.target_indicator = self.m_btn_line_yes_ActiveToggle.isOn and 1 or 0
    local settingPushIns = ConfigManager:GetConfigInsByName("SettingPush")
    local mPushOption = self.m_mPushOption
    if mPushOption == nil then
      mPushOption = PushNotificationManager:GetPushOption()
    end
    data.notice_collection = mPushOption[1] or settingPushIns:GetValue_ByPushID(1).m_Default
    data.notice_mail = mPushOption[2] or settingPushIns:GetValue_ByPushID(2).m_Default
    data.notice_support = mPushOption[3] or settingPushIns:GetValue_ByPushID(3).m_Default
    data.no_wifi_download = DownloadManager:CanDownloadInMobile() and 1 or 0
    ReportManager:ReportSettingsData(data)
  end
end

function Form_BattleSetting:OnBtnCloseClicked()
  StackFlow:RemoveUIFromStack(self:GetID())
end

function Form_BattleSetting:OnBtnReturnClicked()
  StackFlow:RemoveUIFromStack(self:GetID())
end

function Form_BattleSetting:OnBtnfightingClicked()
  self:SwitchTab(SettingTab.Battle)
end

function Form_BattleSetting:OnBtnsystemClicked()
  self:SwitchTab(SettingTab.System)
end

function Form_BattleSetting:OnBtnpicClicked()
  self:SwitchTab(SettingTab.Quality)
end

function Form_BattleSetting:OnBtnlangClicked()
  self:SwitchTab(SettingTab.Language)
end

function Form_BattleSetting:OnBtntipsClicked()
  self:SwitchTab(SettingTab.Push)
end

function Form_BattleSetting:OnBtndownloadClicked()
  self:SwitchTab(SettingTab.Download)
end

function Form_BattleSetting:OnAccountClicked()
  self:SwitchTab(SettingTab.Account)
end

function Form_BattleSetting:OnBtnredemptioncodeClicked()
  StackFlow:Push(UIDefines.ID_FORM_PERSONALCDKPOP)
end

function Form_BattleSetting:OnBtnplayercenterClicked()
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERPOP)
end

function Form_BattleSetting:OnBtnpilotcodeClicked()
  utils.popUpDirectionsUI({
    tipsID = 1029,
    func1 = function()
      if SDKUtil.HasBindingWithThirdParty() then
        utils.CheckAndPushCommonTips()
        return
      end
      SDKUtil.GetTransferCode(function(codeResult)
        if codeResult.resultCode == 0 and codeResult.msdkAccountTransferCode and codeResult.msdkAccountTransferCode.transferCodeStatus == 4 then
          local apply = {
            type = "apply",
            transferCode = codeResult.msdkAccountTransferCode.transferCode
          }
          StackPopup:Push(UIDefines.ID_FORM_PILOTCODEPOP, apply)
        else
          SDKUtil.CreateTransferCode(function(isSuccess, result)
            local apply = {
              type = "apply",
              transferCode = result.msdkAccountTransferCode.transferCode
            }
            if isSuccess then
              StackPopup:Push(UIDefines.ID_FORM_PILOTCODEPOP, apply)
            end
          end)
        end
      end)
    end
  })
end

function Form_BattleSetting:OnManageClicked()
  StackPopup:Push(UIDefines.ID_FORM_BATTLESYSTEMPOP1)
end

function Form_BattleSetting:OnBtncustomerserverClicked()
  SettingManager:PullAiHelpMessage()
end

function Form_BattleSetting:OnBtncustomerlistClicked()
  local urlString = ""
  if ChannelManager:IsChinaChannel() then
    urlString = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(210023).m_mMessage
  else
    urlString = SettingManager:GetUrlWithLanguageId(220013)
  end
  if ChannelManager:IsUSChannel() then
    urlString = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(230006).m_mMessage
  end
  if ChannelManager:IsDMMChannel() then
    urlString = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(230012).m_mMessage
  end
  urlString = string.replace(urlString, "\"\"", "\"")
  if urlString and urlString ~= "" then
    StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, urlString)
  end
end

function Form_BattleSetting:OnBtnsecretClicked()
  local urlString = ""
  if ChannelManager:IsChinaChannel() then
    urlString = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(210024).m_mMessage
  else
    urlString = SettingManager:GetUrlWithLanguageId(220014)
  end
  if ChannelManager:IsUSChannel() then
    urlString = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(230005).m_mMessage
  end
  if ChannelManager:IsDMMChannel() then
    urlString = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(230011).m_mMessage
  end
  urlString = string.replace(urlString, "\"\"", "\"")
  if urlString and urlString ~= "" then
    StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, urlString)
  end
end

function Form_BattleSetting:OnBtn3listClicked()
  local urlString = string.replace(ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(210025).m_mMessage, "\"\"", "\"")
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, urlString)
end

function Form_BattleSetting:OnBtnsystemlistClicked()
  local urlString = string.replace(ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(210026).m_mMessage, "\"\"", "\"")
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, urlString)
end

function Form_BattleSetting:OnBtnpersonlistClicked()
  local urlString = string.replace(ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(210027).m_mMessage, "\"\"", "\"")
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, urlString)
end

function Form_BattleSetting:SwitchTab(settingTab, forceRefresh)
  if self.m_settingTab == settingTab then
    if forceRefresh then
      self:RefreshSubPanel(settingTab)
    end
    return
  end
  self.m_settingTab = settingTab
  self:InitSubPanel(settingTab)
  for k, v in ipairs(self.m_subPanel) do
    if k == settingTab then
      v.tabBtn:SetActive(true)
      v.panel:SetActive(true)
      v.tabUnselect:SetActive(false)
      self:RefreshSubPanel(settingTab)
    else
      v.tabBtn:SetActive(false)
      v.panel:SetActive(false)
      v.tabUnselect:SetActive(true)
    end
  end
end

function Form_BattleSetting:OnSelectLanguageID(iLanguageID, iFilterIndex)
  local function completeCB(ret)
    TimeService:KillTimer(self.m_timer)
    
    self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
      iBatchID = self.m_iBatchId,
      bComplete = true
    })
    if ret then
      utils.CheckAndPushCommonTips({
        tipsID = 1605,
        func1 = function()
          self.m_selectLanguageIndex = iFilterIndex
          CS.MultiLanguageManager.Instance:ChangeLanguageID(iLanguageID)
          local languageStr = SettingManager:GetAiHelpCanIdentifyLanguage(iLanguageID)
          if ChannelManager:IsChinaChannel() then
          else
            CS.AiHelpManager.Instance:AiHelpSetSDKLanguage(languageStr)
          end
          CS.ApplicationManager.Instance:RestartGame()
        end,
        func2 = function()
          self.m_widgetBtnFilter:ForceChangeTabIndex(self.m_selectLanguageIndex)
        end
      })
    else
      self.m_widgetBtnFilter:ForceChangeTabIndex(self.m_selectLanguageIndex)
    end
  end
  
  local function startCB(curBytes, totalBytes)
    local delay = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("PushQuitCD").m_Value) or 0
    self.m_timer = TimeService:SetTimer(delay, 1, function()
      StackTop:Push(UIDefines.ID_FORM_DOWNLOADTIPS, {
        iBatchID = self.m_iBatchId,
        bCloseOnly = true,
        iTipsID = 100032,
        iButtonID = 100034
      })
    end)
    self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
      iBatchID = self.m_iBatchId,
      lCurBytes = curBytes,
      lTotalBytes = totalBytes
    })
  end
  
  local function progressCB(curBytes, totalBytes, speed)
    self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
      iBatchID = self.m_iBatchId,
      lCurBytes = curBytes,
      lTotalBytes = totalBytes
    })
  end
  
  self.m_iBatchId = DownloadManager:DownloadMultiLanguage(iLanguageID, completeCB, startCB, progressCB)
  self.m_isChanged = true
end

function Form_BattleSetting:OnSelectVoiceID(iLanguageID, filterIndex, tabConfig)
  local function DoDownload()
    local function completeCB(ret)
      self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
        iBatchID = self.m_iBatchId,
        
        bComplete = true
      })
      if ret then
        utils.CheckAndPushCommonTips({
          tipsID = 1602,
          fContentCB = function(content)
            return string.format(content, tabConfig.sTitle)
          end,
          func1 = function()
            CS.MultiLanguageManager.Instance:ChangeLanguageVoiceID(iLanguageID)
            self.m_selectVoiceIndex = filterIndex
          end,
          func2 = function()
            self.m_widgetBtnFilter2:ForceChangeTabIndex(self.m_selectVoiceIndex)
          end
        })
      else
        self.m_widgetBtnFilter2:ForceChangeTabIndex(self.m_selectVoiceIndex)
      end
    end
    
    local function startCB(curBytes, totalBytes)
      self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
        iBatchID = self.m_iBatchId,
        lCurBytes = curBytes,
        lTotalBytes = totalBytes
      })
    end
    
    local function progressCB(curBytes, totalBytes, speed)
      self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
        iBatchID = self.m_iBatchId,
        lCurBytes = curBytes,
        lTotalBytes = totalBytes
      })
    end
    
    self.m_iBatchId = DownloadManager:DownloadMultiLanguageVoice(iLanguageID, completeCB, startCB, progressCB)
    StackTop:Push(UIDefines.ID_FORM_DOWNLOADTIPS, {
      iBatchID = self.m_iBatchId,
      bCloseOnly = true,
      iTipsID = 100032,
      iButtonID = 100034
    })
  end
  
  if tabConfig.needDownloadSize > 0 then
    local sizeMB = tabConfig.needDownloadSize / 1024 / 1024
    if 1000 < sizeMB then
      sizeMB = string.format("%.02f%s", sizeMB / 1024, DownloadManager:GetGBStr())
    else
      sizeMB = string.format("%.02f%s", sizeMB, DownloadManager:GetMBStr())
    end
    utils.CheckAndPushCommonTips({
      tipsID = 1601,
      fContentCB = function(content)
        return string.format(content, tabConfig.sTitle, sizeMB)
      end,
      func1 = function()
        DoDownload()
      end,
      func2 = function()
        self.m_widgetBtnFilter2:ForceChangeTabIndex(self.m_selectVoiceIndex)
      end
    })
  else
    CS.MultiLanguageManager.Instance:ChangeLanguageVoiceID(iLanguageID)
    self.m_selectVoiceIndex = filterIndex
  end
  self.m_isChanged = true
end

function Form_BattleSetting:OnQualityItemClk()
  self.m_isChanged = true
end

function Form_BattleSetting:OnBtnMoreClicked()
  CS.UserCentricsCtrl.Instance:ShowSecondLayer()
end

function Form_BattleSetting:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BattleSetting", Form_BattleSetting)
return Form_BattleSetting
