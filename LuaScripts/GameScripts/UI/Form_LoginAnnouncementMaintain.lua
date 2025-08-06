local Form_LoginAnnouncementMaintain = class("Form_LoginAnnouncementMaintain", require("UI/UIFrames/Form_LoginAnnouncementMaintainUI"))

function Form_LoginAnnouncementMaintain:SetInitParam(param)
end

function Form_LoginAnnouncementMaintain:AfterInit()
  self.m_iRequestServerStatusInterval = 300
  self.m_iRequestServerStatusCountdown = 0
  self.m_iTimeDurationOneSecond = 0
  self.m_panelMaintainContent = {}
  self.m_panelMaintainContentTemplate:SetActive(false)
  self.m_iMaintainTitleHeight = self.m_textTitleTemplate:GetComponent("RectTransform").sizeDelta.y
  self.m_iMaintainContentAnchorY = self.m_textContentTemplate:GetComponent("RectTransform").anchoredPosition.y
end

function Form_LoginAnnouncementMaintain:OnActive()
  self.m_stMaintainInfo = self.m_csui.m_param.stMaintainInfo
  self:ResetMaintain()
  self.m_panelServer.transform:Find("PanelCountDown/TextCountDownDesc"):GetComponent(T_Text).text = CS.ConfFact.LangFormat4DataInit("LoginAnnouncementMaintainCountDownDesc")
  self.m_Btn_Close:GetComponent(T_Button).onClick:RemoveAllListeners()
  self.m_Btn_Return:SetActive(false)
  self.m_Btn_Return:GetComponent(T_Button).onClick:RemoveAllListeners()
end

function Form_LoginAnnouncementMaintain:ResetMaintain()
  self.m_bBulletInRequest = false
  self.m_iRequestServerStatusCountdown = self.m_iRequestServerStatusInterval
  self.m_iTimeCountDown = self.m_stMaintainInfo.iMaintainRemainSecs
  if self.m_iTimeCountDown == 0 then
    self.m_iTimeCountDown = self.m_iRequestServerStatusInterval
  end
  self.m_iRealTimeSinceStartup = CS.UnityEngine.Time.realtimeSinceStartup
  self.m_textTitle_Text.text = self.m_stMaintainInfo.sTitle
  local iMaintainCount = 0
  if self.m_stMaintainInfo.vContent then
    local panelMaintainContentParent = self.m_scrollViewContent:GetComponent("ScrollRect").content
    iMaintainCount = #self.m_stMaintainInfo.vContent
    for i = iMaintainCount, 1, -1 do
      local contentOne = self.m_stMaintainInfo.vContent[i]
      local panelMaintainContent = self.m_panelMaintainContent[i]
      if panelMaintainContent == nil then
        panelMaintainContent = CS.UnityEngine.GameObject.Instantiate(self.m_panelMaintainContentTemplate, panelMaintainContentParent)
        self.m_panelMaintainContent[i] = panelMaintainContent
      end
      panelMaintainContent:SetActive(true)
      local bShowTitle = false
      local textMaintainTitle = panelMaintainContent.transform:Find("m_textTitleTemplate").gameObject
      if contentOne.sTitle and contentOne.sTitle ~= "" then
        textMaintainTitle:SetActive(true)
        bShowTitle = true
        textMaintainTitle:GetComponent(T_Text).text = contentOne.sTitle
      else
        textMaintainTitle:SetActive(false)
      end
      local textMaintainContent = panelMaintainContent.transform:Find("m_textContentTemplate").gameObject
      if contentOne.sContent and contentOne.sContent ~= "" then
        textMaintainContent:SetActive(true)
        textMaintainContent:GetComponent(T_Text).text = contentOne.sContent
      else
        textMaintainContent:SetActive(false)
      end
    end
  end
  for i = iMaintainCount + 1, #self.m_panelMaintainContent do
    self.m_panelMaintainContent[i]:SetActive(false)
  end
  self.m_textCountDown_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_iTimeCountDown)
  self.m_textGo_Text.text = self.m_stMaintainInfo.sHyperlinkName
end

function Form_LoginAnnouncementMaintain:OnUpdate(dt)
  if self.m_bBulletInRequest then
    return
  end
  local iDeltaTime = CS.UnityEngine.Time.realtimeSinceStartup - self.m_iRealTimeSinceStartup
  if iDeltaTime < 0 then
    log.error("Form_LoginAnnouncementMaintain:OnUpdate() iDeltaTime < 0, reset to 0")
    iDeltaTime = 0
  end
  self.m_iRealTimeSinceStartup = CS.UnityEngine.Time.realtimeSinceStartup
  self.m_iRequestServerStatusCountdown = self.m_iRequestServerStatusCountdown - iDeltaTime
  if 0 >= self.m_iRequestServerStatusCountdown then
  end
  self.m_iTimeCountDown = self.m_iTimeCountDown - iDeltaTime
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + iDeltaTime
  if self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    if 0 >= self.m_iTimeCountDown then
      self.m_iTimeCountDown = 0
      self.m_bBulletInRequest = true
      self:TryShowRestart()
    end
    self.m_textCountDown_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_iTimeCountDown)
  end
end

function Form_LoginAnnouncementMaintain:TryShowRestart()
  utils.CheckAndPushCommonTips({
    title = "",
    content = CS.ConfFact.LangFormat4DataInit("UpdateRestartConfirm"),
    funcText1 = CS.ConfFact.LangFormat4DataInit("PlayerCancelInfoYes"),
    btnNum = 1,
    bLockBack = true,
    func1 = function()
      CS.ApplicationManager.Instance:RestartGame()
    end
  })
end

function Form_LoginAnnouncementMaintain:requestServerStatus()
  self.m_iRequestServerStatusCountdown = self.m_iRequestServerStatusInterval
  
  local function OnBulletinGetSuccess(sc, msg)
    self.m_bBulletInRequest = false
    CS.UserData.Instance.loginGetBulletin = sc
    UserDataManager:SetLoginGetBulletinSC(sc)
    if sc.vMaintainInfo and #sc.vMaintainInfo > 0 then
      table.sort(sc.vMaintainInfo, function(a, b)
        return a.iMaintainRemainSecs > b.iMaintainRemainSecs
      end)
      for i, v in ipairs(sc.vMaintainInfo) do
        if 0 <= v.iMaintainRemainSecs then
          self.m_stMaintainInfo = v
          self:ResetMaintain()
          break
        end
      end
    else
      self.m_bBulletInRequest = true
      self:TryShowRestart()
    end
  end
  
  local function OnBulletinGetFail(msg)
    log.info("--- login get bulletin failed : ", msg.rspcode, " ---")
    self.m_bBulletInRequest = false
    self.m_iRequestServerStatusCountdown = self.m_iRequestServerStatusInterval
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end
  
  local function OnBulletinGetTimeout(rec)
    log.info("--- login get bulletin timeout ---")
    self.m_bBulletInRequest = false
    self.m_iRequestServerStatusCountdown = self.m_iRequestServerStatusInterval
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end
  
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  local reqMsg = MTTDProto.Cmd_Login_GetBulletin_CS()
  reqMsg.bHasAudit = loginContext.CurZoneInfo.iFlag == MTTDProto.EM_ZoneFlag_Audit
  local languageInfo = CData_MultiLanguage:GetValue_ByID(CS.MultiLanguageManager.g_iLanguageID)
  reqMsg.iLanguageId = languageInfo and languageInfo.m_LanID or 101
  reqMsg.iZoneId = loginContext.CurZoneInfo.iZoneId
  if ChannelManager:IsAndroid() then
    reqMsg.iOSType = MTTDProto.OSType_Android
  elseif ChannelManager:IsIOS() then
    reqMsg.iOSType = MTTDProto.OSType_IOS
  else
    reqMsg.iOSType = MTTDProto.OSType_Win
  end
  reqMsg.sChannel = versionContext.Channel
  reqMsg.sCountry = loginContext.Country
  reqMsg.iAccountId = loginContext.AccountID
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  RPCS():Login_GetBulletin(reqMsg, OnBulletinGetSuccess, OnBulletinGetFail, OnBulletinGetTimeout)
end

function Form_LoginAnnouncementMaintain:OnBtnGoClicked()
  if self.m_stMaintainInfo.sHyperlink then
    CS.DeviceUtil.OpenURLNew(self.m_stMaintainInfo.sHyperlink)
  end
end

function Form_LoginAnnouncementMaintain:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_LoginAnnouncementMaintain", Form_LoginAnnouncementMaintain)
return Form_LoginAnnouncementMaintain
