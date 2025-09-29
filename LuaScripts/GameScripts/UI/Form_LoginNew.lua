local Form_LoginNew = class("Form_LoginNew", require("UI/UIFrames/Form_LoginNewUI"))
local JobFlowNodeConfig = {
  InitConfig = {bInitConfig = true},
  InitMSDK = {
    bInitLang = true,
    sDescIndex = "LoginInitMSDK"
  },
  InitNetwork = {
    bInitLang = true,
    sDescIndex = "LoginInitNetwork"
  },
  InitNetworkGame = {
    bInitLang = true,
    sDescIndex = "LoginInitNetworkGame"
  },
  DownloadAllResource = {bInitLang = false, iDescTextID = 2012}
}
local JobProgressSpeedMultiDefault = 0.1

function Form_LoginNew:SetInitParam(param)
end

function Form_LoginNew:AfterInit()
  self.super.AfterInit(self)
  local obj = CS.UnityEngine.GameObject.Find("Form_Viedo"):GetComponent("Canvas")
  obj.sortingOrder = 2000
  local bConnectGameServer = false
  self.prefabName = nil
  if self.m_csui.m_param ~= nil then
    bConnectGameServer = self.m_csui.m_param.bConnectGameServer
    self.prefabName = self.m_csui.m_param.prefabName
  end
  self.m_loginVideoNode = nil
  self.loadFinish = false
  if not string.isnullorempty(self.prefabName) then
    CS.UIManager.Instance:LoadUIPrefab(self.prefabName, function(uiName, uiObject)
      CS.UI.UILuaHelper.SetParent(uiObject, self.m_root_login, true)
      self.m_loginVideoNode = uiObject.transform
      self:LoadSelfChildrenNode()
    end)
  end
end

function Form_LoginNew:OnBackPressed()
  if ChannelManager:IsUsingQSDK() then
    QSDKManager:Exit()
  end
end

function Form_LoginNew:OnEventFreshVersionInfo()
  local versionContext = CS.VersionContext.GetContext()
  self.m_txt_version_Text.text = versionContext.ClientLocalVersionFull
end

function Form_LoginNew:OnQSDKLoginFailed(jobNode)
  self.m_qsdkLoginFailed = true
  self.m_jobNode = jobNode
  self.m_pnl_start:SetActive(true)
end

function Form_LoginNew:OnEventSetRegisterRedDot()
  self:CheckRegisterRedDot()
end

function Form_LoginNew:OnActive()
end

function Form_LoginNew:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_loginVideoNode then
    CS.UnityEngine.GameObject.Destroy(self.m_loginVideoNode.gameObject)
    CS.MUF.Resource.ResourceManager.UnloadAsset(self.prefabName, CS.MUF.Resource.ResourceType.UI)
    self.m_loginVideoNode = nil
  end
end

function Form_LoginNew:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_serverReddotLogin, RedDotDefine.ModuleType.LoginCustomerService)
end

function Form_LoginNew:OnStateChange(node, before, after)
  if not self.loadFinish then
    return
  end
  self.m_jobProgress = self.m_jobTargetProgress
  self.m_jobTargetProgress = self.m_jobFlow:GetJobProgress()
  local stNodeConfig = JobFlowNodeConfig[node.Name]
  if stNodeConfig then
    if stNodeConfig.bInitLang then
      self.m_txt_detail_Text.text = CS.ConfFact.LangFormat4DataInit(stNodeConfig.sDescIndex)
    elseif stNodeConfig.bInitConfig then
      self.m_bInitConfig = true
    else
      local stCommonTextData = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(stNodeConfig.iDescTextID)
      if stCommonTextData and stCommonTextData.m_mMessage then
        self.m_txt_detail_Text.text = stCommonTextData.m_mMessage
      end
    end
  end
end

function Form_LoginNew:ShowVersionAndRoleID()
end

function Form_LoginNew:OnPnlstartClicked()
  CS.UI.UILuaHelper.StartPlaySFX("Play_ui_button_enter")
  if self.m_qsdkLoginFailed then
    self.m_qsdkLoginFailed = false
    self.m_pnl_start:SetActive(false)
    
    local function OnLoginSuccessCB(accountInfo)
      log.info("QSDK OnLoginSuccessCB")
      ReportManager:ReportLoginProcess("InitQSDK_Login", "Success", true)
      QSDKManager:SetAccountInfo(accountInfo)
      self.m_jobNode.Status = JobStatus.Success
    end
    
    local function OnLoginFailCB(errorCode)
      log.info("QSDK OnLoginFailCB: " .. tostring(errorCode))
      ReportManager:ReportLoginProcess("InitQSDK_Login", "Failed_" .. tostring(errorCode), true)
      if QSDKManager:IsHuawei() then
        self:broadcastEvent("eGameEvent_QSDKLogin_Failed", self.m_jobNode)
      end
    end
    
    QSDKManager:Login(OnLoginSuccessCB, OnLoginFailCB)
    return
  end
  self.m_z_txt_ver:SetActive(false)
  self.m_pnl_start:SetActive(false)
  self.m_pnl_button:SetActive(false)
  self.m_pnl_accountinfo:SetActive(false)
  self:PlayOpenDoorAnimAndEnterGame()
  UILuaHelper.SetActive(self.m_btn_cadpa, false)
  UILuaHelper.PlayAnimationByName(self.m_content_node, "LoginNew_out")
  SettingManager:SetEnterHallInLogin(true)
  CS.VideoManager.Instance:Stop()
  StackSpecial:RemoveUIFromStack(UIDefines.ID_FORM_VIEDO)
end

function Form_LoginNew:PlayOpenDoorAnimAndEnterGame()
  TimeService:SetTimer(0.1, 1, function()
    GuideManager:OnInitEventListener()
    CS.GameFlowManager.Instance:OnJobStartupFinished()
    ReportManager:SetLoginTime()
  end)
end

function Form_LoginNew:OnInactive()
  if self.m_iHandlerBackPressed then
    self:removeEventListener("eGameEvent_OnBackPressed", self.m_iHandlerBackPressed)
    self.m_iHandlerBackPressed = nil
  end
end

function Form_LoginNew:OnUpdate(dt)
  if self.m_jobFlow == nil or not self.loadFinish then
    return
  end
  self.m_jobTargetProgress = self.m_jobFlow:GetJobProgress()
  local fAddProgress = dt * self.m_jobProgressSpeedMulti * (self.m_jobProgressClampMax - self.m_jobProgressClampMin)
  if self.m_jobProgress + fAddProgress < self.m_jobTargetProgress then
    self.m_jobProgress = self.m_jobProgress + fAddProgress
  else
    self.m_jobProgress = self.m_jobTargetProgress
  end
  self.m_bar_Image.fillAmount = math.max(self.m_jobProgress - self.m_jobProgressClampMin, 0) / (self.m_jobProgressClampMax - self.m_jobProgressClampMin)
  local anchoredPositionBarLight = self.m_bar_light:GetComponent("RectTransform").anchoredPosition
  anchoredPositionBarLight.x = self.m_bar:GetComponent("RectTransform").sizeDelta.x * self.m_bar_Image.fillAmount
  self.m_bar_light:GetComponent("RectTransform").anchoredPosition = anchoredPositionBarLight
  if ChannelManager ~= nil and self.m_bInitChannelManager == false then
    self.m_bInitChannelManager = true
    self.m_btn_pilotcode:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.InitiationCode))
  end
  if self.m_jobProgress == 1 then
    self.m_jobFlow = nil
    self.m_pnl_load:SetActive(false)
    self.m_pnl_start:SetActive(true)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(259)
    if self.m_btn_cadpa and ChannelManager:IsChinaChannel() then
      self.m_btn_cadpa:SetActive(true)
    end
    if self.m_pnl_statementinfo and ChannelManager:IsChinaChannel() then
      self.m_pnl_statementinfo:SetActive(true)
    end
    if not ChannelManager:IsChinaChannel() then
      if ChannelManager:IsDMMChannel() then
        self.m_btn_account:SetActive(false)
      else
        self.m_btn_account:SetActive(true)
      end
    else
      if ChannelManager:IsUsingQSDK() then
        if ChannelManager:IsIOS() then
          self.m_btn_account:SetActive(true)
        elseif QSDKManager:GetParentChannelType() == "134" and QSDKManager:IsFunctionSupport(209) then
          self.m_btn_account:SetActive(true)
        else
          self.m_btn_account:SetActive(false)
        end
      else
      end
      if ChannelManager:IsWegameChannel() and self.m_btn_binding then
        self.m_btn_binding:SetActive(true)
      end
    end
    self:PlayerLogVoice()
    self.m_btn_setting:SetActive(true)
    self.m_btn_install:SetActive(not ChannelManager:IsWindows())
  end
end

function Form_LoginNew:OnEventShowBtnAnnouncement(stBulletinInfo)
  self.m_btn_announcement:SetActive(stBulletinInfo ~= nil)
  self.m_stBulletinInfo = stBulletinInfo
end

function Form_LoginNew:OnBtnannouncementClicked()
  CS.UI.UILuaHelper.StartPlaySFX("Play_ui_button_confirm")
  local stLoginGetBulletinSC = UserDataManager:GetLoginGetBulletinSC()
  if nil ~= stLoginGetBulletinSC and nil ~= stLoginGetBulletinSC.vInfo and #stLoginGetBulletinSC.vInfo > 0 then
    local stBulletinInfo = stLoginGetBulletinSC.vInfo[1]
    StackFlow:Push(UIDefines.ID_FORM_LOGINANNOUNCEMENT, {stBulletinInfo = stBulletinInfo})
  end
end

function Form_LoginNew:OnBtnaccountClicked()
  if ChannelManager:IsUsingQSDK() then
    if ChannelManager:IsIOS() then
      QSDKManager:CallFunction(function()
        log.info("enter usercenter success")
      end, function()
        log.info("enter usercenter failed")
      end, 102)
    elseif QSDKManager:GetParentChannelType() == "134" and QSDKManager:IsFunctionSupport(209) then
      QSDKManager:CallFunction(function()
        log.info("open usercenter success")
      end, function()
        log.info("open usercenter failed")
      end, 209)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERPOP)
  end
end

function Form_LoginNew:OnBtnbindingClicked()
  local phone = self:CheckBindingStatus()
  if phone then
    StackPopup:Push(UIDefines.ID_FORM_BONDPHONEPOP, {iType = 2, phone = phone})
  else
    StackPopup:Push(UIDefines.ID_FORM_BONDPHONEPOP, {iType = 1})
  end
end

function Form_LoginNew:OnEventShowDownloadProgress(stDownloadProgressInfo)
  if stDownloadProgressInfo.bShow then
    self.m_txt_download_total:SetActive(true)
    self.m_txt_download_total_Text.text = stDownloadProgressInfo.sProgress
  else
    self.m_txt_download_total:SetActive(false)
  end
end

function Form_LoginNew:OnEventShowAccountInfo(stShowAccountInfo)
  self.m_z_txt_ver:SetActive(true)
  self.m_z_txt_ver_Text.text = CS.ConfFact.LangFormat4DataInit("LoginVersionDesc")
  self.m_pnl_accountinfo:SetActive(true)
  self.m_pnl_accountinfo.transform:Find("txt_zone"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("LoginZoneDesc")
  if stShowAccountInfo.iAccountID then
    self.m_txt_accountid:SetActive(true)
    self.m_txt_accountid_Text.text = stShowAccountInfo.iAccountID
  else
    self.m_txt_accountid:SetActive(false)
  end
  self.m_pnl_accountinfo.transform:Find("txt_account"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("LoginAccountDesc")
  if stShowAccountInfo.iZoneID then
    self.m_txt_zoneid:SetActive(true)
    self.m_txt_zoneid_Text.text = stShowAccountInfo.iZoneID
  else
    self.m_txt_zoneid:SetActive(false)
  end
end

function Form_LoginNew:OnBtnservercenterClicked()
  if not RoleManager:GetUID() then
    return
  end
  SettingManager:PullAiHelpMessage("E002")
end

function Form_LoginNew:OnBtninstallClicked()
  local function OnDownloadStart(curBytes, totalBytes)
    self.m_pnl_load:SetActive(true)
    
    self.m_pnl_start:SetActive(false)
    self.m_txt_download_total:SetActive(true)
    self.m_txt_download_total_Text.text = DownloadManager:GetDownloadSizeStr(curBytes) .. "/" .. DownloadManager:GetDownloadSizeStr(totalBytes)
    self.m_txt_detail_Text.text = ConfigManager:GetCommonTextById(100718)
    self.m_bar_Image.fillAmount = math.max(curBytes, 0) / totalBytes
    local anchoredPositionBarLight = self.m_bar_light:GetComponent("RectTransform").anchoredPosition
    anchoredPositionBarLight.x = self.m_bar:GetComponent("RectTransform").sizeDelta.x * self.m_bar_Image.fillAmount
    self.m_bar_light:GetComponent("RectTransform").anchoredPosition = anchoredPositionBarLight
  end
  
  local function OnDownloadComplete(ret)
    if ret then
      log.info("下载完成")
    else
      log.info("下载失败")
    end
    self.m_txt_download_total:SetActive(false)
    self.m_pnl_load:SetActive(false)
    self.m_pnl_start:SetActive(true)
  end
  
  local function OnDownloadProgress(curBytes, totalBytes, speed)
    self.m_txt_download_total_Text.text = DownloadManager:GetDownloadSizeStr(curBytes) .. "/" .. DownloadManager:GetDownloadSizeStr(totalBytes)
  end
  
  StackPopup:Push(UIDefines.ID_FORM_LOGININSTALLPOP, {
    onDownloadComplete = function(complted, totalcount, filelist, filelength)
      if complted == totalcount then
        if 0 < filelength then
          if filelength > CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024 then
            utils.CheckAndPushCommonTips({
              tipsID = 1252,
              bLockBack = true,
              fContentCB = function(sContent)
                local totalSize = DownloadManager:GetDownloadSizeStr(filelength)
                local avalibaleSize = DownloadManager:GetDownloadSizeStr(CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024)
                local neededSize = DownloadManager:GetDownloadSizeStr(filelength - CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024)
                local sContentNew = string.customizereplace(sContent, {
                  "{needed_size}"
                }, neededSize)
                sContentNew = string.customizereplace(sContentNew, {
                  "{available_size}"
                }, avalibaleSize)
                sContentNew = string.customizereplace(sContentNew, {
                  "{total_size}"
                }, totalSize)
                return sContentNew
              end
            })
          else
            utils.CheckAndPushCommonTips({
              tipsID = 1251,
              bLockBack = true,
              fContentCB = function(sContent)
                local sContentNew = string.customizereplace(sContent, {"{size}"}, DownloadManager:GetDownloadSizeStr(filelength))
                return sContentNew
              end,
              func1 = function()
                CS.TGRPDownloader.DownloadResListWithDesc(filelist, "verifyFile", OnDownloadComplete, OnDownloadStart, OnDownloadProgress, 0)
              end
            })
          end
          log.info("校验失败" .. DownloadManager:GetDownloadSizeStr(filelength))
        else
          StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, 21010)
        end
        self.m_pnl_load:SetActive(false)
        self.m_pnl_start:SetActive(true)
        self.m_pnl_button:SetActive(true)
      else
        self.m_txt_download_total:SetActive(true)
        self.m_txt_download_total_Text.text = complted .. "/" .. totalcount
        self.m_txt_detail_Text.text = ConfigManager:GetCommonTextById(100717)
        self.m_bar_Image.fillAmount = math.max(complted, 0) / totalcount
        local anchoredPositionBarLight = self.m_bar_light:GetComponent("RectTransform").anchoredPosition
        anchoredPositionBarLight.x = self.m_bar:GetComponent("RectTransform").sizeDelta.x * self.m_bar_Image.fillAmount
        self.m_bar_light:GetComponent("RectTransform").anchoredPosition = anchoredPositionBarLight
        self.m_pnl_load:SetActive(true)
        self.m_pnl_start:SetActive(false)
      end
    end,
    onBeginDownload = function()
      self.m_pnl_button:SetActive(false)
    end
  })
end

function Form_LoginNew:OnEventSetProgressClamp(stProgressClampInfo)
  if stProgressClampInfo.jobFlow ~= nil then
    self.m_jobFlow = stProgressClampInfo.jobFlow
  end
  self.m_jobTargetProgress = self.m_jobFlow:GetJobProgress()
  self.m_jobProgress = self.m_jobTargetProgress
  self.m_jobProgressClampMin = stProgressClampInfo.fMin
  self.m_jobProgressClampMax = stProgressClampInfo.fMax
  self.m_jobProgressSpeedMulti = stProgressClampInfo.jobProgressSpeedMulti or JobProgressSpeedMultiDefault
end

function Form_LoginNew:OnBtncadpaClicked()
  if self.m_bInitConfig then
    StackPopup:Push(UIDefines.ID_FORM_LOGINAGEPROMPT)
  end
end

function Form_LoginNew:OnBtnuseragreementClicked()
  local stCommonText = string.replace(ConfigManager:GetCommonTextById(210113), "\"\"", "\"")
  if stCommonText and stCommonText ~= "???" then
    StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, stCommonText)
  end
end

function Form_LoginNew:OnBtnpilotcodeClicked()
  StackPopup:Push(UIDefines.ID_FORM_PILOTCODEPOP, {type = "login"})
end

function Form_LoginNew:OnBtnsettingClicked()
  if ChannelManager:IsWindows() then
    StackFlow:Push(UIDefines.ID_FORM_BATTLESETTING, {
      hideTypeList = {5, 6}
    })
  else
    StackFlow:Push(UIDefines.ID_FORM_BATTLESETTING)
  end
end

function Form_LoginNew:PlayerLogVoice()
  local voice = ConfigManager:GetGlobalSettingsByKey("LogoVoice")
  local voiceList = string.split(voice, ";")
  if 0 < #voiceList then
    local tempRandom = math.random(1, #voiceList)
    CS.UI.UILuaHelper.StartPlaySFX(voiceList[tempRandom], nil, function(playingId)
      self.m_playingId = playingId
    end, function()
      self.m_playingId = nil
    end)
  end
end

function Form_LoginNew:CheckBindingStatus()
  local vAccountInfo = UserDataManager:GetAccountInfo()
  if vAccountInfo then
    for k, v in pairs(vAccountInfo) do
      if string.find(v.sAccountName, "quicksdk") then
        return v.mData.quick_username
      end
    end
  end
  return nil
end

function Form_LoginNew:LoadSelfChildrenNode()
  self.m_GmPos = self.m_loginVideoNode:Find("m_GmPos").gameObject
  self.m_pnl_start = self.m_loginVideoNode:Find("m_pnl_start").gameObject
  self.m_pnl_start_Button = self.m_loginVideoNode:Find("m_pnl_start"):GetComponent("Button")
  self:BindCallback(self.m_pnl_start_Button, handler(self, self.OnPnlstartClicked))
  self.m_content_node = self.m_loginVideoNode:Find("m_content_node").gameObject
  self.m_btn_cadpa = self.m_loginVideoNode:Find("m_content_node/m_btn_cadpa").gameObject
  self.m_btn_cadpa_Button = self.m_loginVideoNode:Find("m_content_node/m_btn_cadpa"):GetComponent("Button")
  self:BindCallback(self.m_btn_cadpa_Button, handler(self, self.OnBtncadpaClicked))
  self.m_pnl_button = self.m_loginVideoNode:Find("m_content_node/m_pnl_button").gameObject
  self.m_btn_account = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_account").gameObject
  self.m_btn_account_Button = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_account"):GetComponent("Button")
  self:BindCallback(self.m_btn_account_Button, handler(self, self.OnBtnaccountClicked))
  self.m_LoginAccount_redPoint = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_account/m_LoginAccount_redPoint").gameObject
  self.m_btn_announcement = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_announcement").gameObject
  self.m_btn_announcement_Button = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_announcement"):GetComponent("Button")
  self:BindCallback(self.m_btn_announcement_Button, handler(self, self.OnBtnannouncementClicked))
  self.m_btn_servercenter = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_servercenter").gameObject
  self.m_btn_servercenter_Button = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_servercenter"):GetComponent("Button")
  self:BindCallback(self.m_btn_servercenter_Button, handler(self, self.OnBtnservercenterClicked))
  self.m_serverReddotLogin = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_servercenter/icon_servercenter/m_serverReddotLogin").gameObject
  self.m_btn_pilotcode = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_pilotcode").gameObject
  self.m_btn_pilotcode_Button = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_pilotcode"):GetComponent("Button")
  self:BindCallback(self.m_btn_pilotcode_Button, handler(self, self.OnBtnpilotcodeClicked))
  self.m_btn_setting = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_setting").gameObject
  self.m_btn_setting_Button = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_setting"):GetComponent("Button")
  self:BindCallback(self.m_btn_setting_Button, handler(self, self.OnBtnsettingClicked))
  self.m_btn_install = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_install").gameObject
  self.m_btn_install_Button = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_install"):GetComponent("Button")
  self:BindCallback(self.m_btn_install_Button, handler(self, self.OnBtninstallClicked))
  self.m_btn_binding = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_binding").gameObject
  self.m_btn_binding_Button = self.m_loginVideoNode:Find("m_content_node/m_pnl_button/m_btn_binding"):GetComponent("Button")
  self:BindCallback(self.m_btn_binding_Button, handler(self, self.OnBtnbindingClicked))
  self.m_pnl_load = self.m_loginVideoNode:Find("m_content_node/m_pnl_load").gameObject
  self.m_pnl_bottom = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom").gameObject
  self.m_bar_bg = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_bar_bg").gameObject
  self.m_bar_bg_01 = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_bar_bg/m_bar_bg_01").gameObject
  self.m_bar = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_bar_bg/m_bar").gameObject
  self.m_bar_Image = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_bar_bg/m_bar"):GetComponent("Image")
  self.m_bar_light = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_bar_bg/m_bar_light").gameObject
  self.m_txt_detail1 = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_txt_detail1").gameObject
  self.m_txt_detail1_Text = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_txt_detail1"):GetComponent("TextPro")
  self.m_txt_download_total = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_txt_download_total").gameObject
  self.m_txt_download_total_Text = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_txt_download_total"):GetComponent("TextPro")
  self.m_txt_detail = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_txt_detail").gameObject
  self.m_txt_detail_Text = self.m_loginVideoNode:Find("m_content_node/m_pnl_load/m_pnl_bottom/m_txt_detail"):GetComponent("TextPro")
  self.m_z_txt_ver = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_z_txt_ver").gameObject
  self.m_z_txt_ver_Text = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_z_txt_ver"):GetComponent("TextPro")
  self.m_txt_version = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_z_txt_ver/m_txt_version").gameObject
  self.m_txt_version_Text = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_z_txt_ver/m_txt_version"):GetComponent("TextPro")
  self.m_pnl_accountinfo = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_pnl_accountinfo").gameObject
  self.m_txt_accountid = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_pnl_accountinfo/m_txt_accountid").gameObject
  self.m_txt_accountid_Text = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_pnl_accountinfo/m_txt_accountid"):GetComponent("TextPro")
  self.m_txt_zoneid = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_pnl_accountinfo/m_txt_zoneid").gameObject
  self.m_txt_zoneid_Text = self.m_loginVideoNode:Find("m_content_node/bg_ver/m_pnl_accountinfo/m_txt_zoneid"):GetComponent("TextPro")
  CS.UI.UILuaHelper.FreshViewMultiLanguage(self.m_loginVideoNode.gameObject)
  self:OnLoadFinishCallBack()
  self.loadFinish = true
end

function Form_LoginNew:OnLoadFinishCallBack()
  TimeService:SetTimer(1.0E-4, 1, function()
    require("common/GlobalRequire")
    if bConnectGameServer then
      local ConnectGameServerFlow = require("JobFlow/JobGraphConnectGameServer/JobGraphConnectGameServer")
      self.m_jobFlow = ConnectGameServerFlow.Instance()
      self.m_jobFlow:Run(handler(self, self.OnStateChange))
    else
      local StartupFlow = require("JobFlow/JobGraphStartup/JobGraphStartup")
      self.m_jobFlow = StartupFlow.Instance()
      self.m_jobFlow:Run(handler(self, self.OnStateChange))
    end
  end)
  self.m_pnl_load:SetActive(true)
  self.m_pnl_start:SetActive(false)
  self.m_btn_setting:SetActive(false)
  if self.m_btn_binding then
    self.m_btn_binding:SetActive(false)
  end
  if self.m_btn_cadpa then
    self.m_btn_cadpa:SetActive(false)
  end
  if self.m_pnl_statementinfo then
    self.m_pnl_statementinfo:SetActive(false)
  end
  self.m_txt_detail_Text.text = ""
  self.m_bar_Image.fillAmount = 0
  local anchoredPositionBarLight = self.m_bar_light:GetComponent("RectTransform").anchoredPosition
  anchoredPositionBarLight.x = 0
  self.m_bar_light:GetComponent("RectTransform").anchoredPosition = anchoredPositionBarLight
  self.m_jobProgress = 0
  self.m_jobTargetProgress = 0
  self.m_jobProgressClampMin = 0
  self.m_jobProgressClampMax = 1
  self.m_jobProgressSpeedMulti = JobProgressSpeedMultiDefault
  self.m_txt_download_total:SetActive(false)
  self.m_btn_account:SetActive(false)
  self.m_btn_announcement:SetActive(false)
  self.m_btn_pilotcode:SetActive(false)
  self.m_btn_install:SetActive(false)
  self:ShowVersionAndRoleID()
  self:addEventListener("eGameEvent_Login_ShowBtnAnnouncement", handler(self, self.OnEventShowBtnAnnouncement))
  self:addEventListener("eGameEvent_Login_ShowDownloadProgress", handler(self, self.OnEventShowDownloadProgress))
  self:addEventListener("eGameEvent_Login_ShowAccountInfo", handler(self, self.OnEventShowAccountInfo))
  self:addEventListener("eGameEvent_Login_SetProgressClamp", handler(self, self.OnEventSetProgressClamp))
  self:addEventListener("eGameEvent_Login_SetRegisterRedDot", handler(self, self.OnEventSetRegisterRedDot))
  self:addEventListener("eGameEvent_Login_FreshVersionInfo", handler(self, self.OnEventFreshVersionInfo))
  self:addEventListener("eGameEvent_QSDKLogin_Failed", handler(self, self.OnQSDKLoginFailed))
  self.m_iHandlerBackPressed = self:addEventListener("eGameEvent_OnBackPressed", handler(self, self.OnBackPressed))
  self.m_z_txt_ver:SetActive(false)
  local versionContext = CS.VersionContext.GetContext()
  self.m_txt_version_Text.text = versionContext.ClientLocalVersionFull
  self.m_pnl_accountinfo:SetActive(false)
  self.m_txt_accountid:SetActive(false)
  self.m_txt_zoneid:SetActive(false)
  StackTop:Push(UIDefines.ID_FORM_SCREEN_CLICK)
  self.m_bInitChannelManager = false
  if self.m_btn_useragreement then
    self.m_btn_useragreement:SetActive(false)
  end
  if self.m_GmPos then
    self.m_GmPos:SetActive(false)
    if CS.ApplicationManager.Instance:IsEnableDebugNova() and CS.UI.UILuaHelper.IsAbleDebugger() then
      self.m_GmPos:SetActive(true)
    end
  end
end

local fullscreen = true
ActiveLuaUI("Form_LoginNew", Form_LoginNew)
return Form_LoginNew
