local Job_Login_Login_GetBulletin_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_Login_Login_GetBulletin_Impl.IsNewPlayer()
  local stLoginGetZoneSC = UserDataManager:GetLoginGetZoneSC()
  if nil == stLoginGetZoneSC.vZoneList or nil == stLoginGetZoneSC.vRoleList then
    return true
  end
  for _, roleInfo in pairs(stLoginGetZoneSC.vRoleList) do
    if nil ~= roleInfo then
      return false
    end
  end
  return true
end

function Job_Login_Login_GetBulletin_Impl.GetZone(fSuccessCB, fFailCB, fTimeoutCB)
  local function OnGetZone(sc, msg)
    CS.UserData.Instance.loginGetZone = sc
    
    UserDataManager:SetLoginGetZoneSC(sc)
    if nil ~= fSuccessCB then
      fSuccessCB()
    end
  end
  
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  local reqMsg = MTTDProto.Cmd_Login_GetZone_CS()
  reqMsg.iAccountId = loginContext.AccountID
  reqMsg.sSessionKey = loginContext.SessionKey
  reqMsg.sChannel = versionContext.Channel
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  RPCS():Login_GetZone(reqMsg, OnGetZone, fFailCB, fTimeoutCB, nil, nil, -1)
end

function Job_Login_Login_GetBulletin_Impl.TryShowBulletin(vBulletinInfo, fShowBulletinInfoCB)
  ReportManager:ReportLoginProcess("InitNetwork_Login_GetBulletin", "GetZone_Start")
  
  local function OnGetZoneCB()
    ReportManager:ReportLoginProcess("InitNetwork_Login_GetBulletin", "GetZone_Success")
    if vBulletinInfo and 0 < #vBulletinInfo then
      local stBulletinInfo = vBulletinInfo[1]
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowBtnAnnouncement, stBulletinInfo)
      local iCount = CS.UnityEngine.PlayerPrefs.GetInt("BulletinId" .. stBulletinInfo.iBulletinId)
      local iNotPopup = CS.UnityEngine.PlayerPrefs.GetInt("BulletinNotPopup", 0)
      local iNextPopupTime = CS.UnityEngine.PlayerPrefs.GetInt("BulletinNextPopupTime" .. stBulletinInfo.iBulletinId, 0)
      if iNotPopup == 0 or iNextPopupTime <= TimeUtil:GetServerTimeS() then
        if stBulletinInfo.iDisplayGrade == MTTDProto.CmdBulletinDisplayGrade_A then
          Job_Login_Login_GetBulletin_Impl.ShowBulletin(stBulletinInfo, iCount, fShowBulletinInfoCB)
        elseif Job_Login_Login_GetBulletin_Impl.IsNewPlayer() then
          if fShowBulletinInfoCB then
            fShowBulletinInfoCB()
          end
        else
          Job_Login_Login_GetBulletin_Impl.ShowBulletin(stBulletinInfo, iCount, fShowBulletinInfoCB)
        end
        return
      end
    end
    if fShowBulletinInfoCB then
      fShowBulletinInfoCB()
    end
  end
  
  local function OnGetZoneFail(msg)
    ReportManager:ReportLoginProcess("InitNetwork_Login_GetBulletin", "GetZone_Failed")
    log.info("--- login GetZone failed : ", msg.rspcode, " ---")
    if fShowBulletinInfoCB then
      fShowBulletinInfoCB()
    end
  end
  
  local function OnGetZoneTimeout(rec)
    ReportManager:ReportLoginProcess("InitNetwork_Login_GetBulletin", "GetZone_Timeout")
    log.info("--- login GetZone timeout ---")
    if fShowBulletinInfoCB then
      fShowBulletinInfoCB()
    end
  end
  
  Job_Login_Login_GetBulletin_Impl.GetZone(OnGetZoneCB, OnGetZoneFail, OnGetZoneTimeout)
end

function Job_Login_Login_GetBulletin_Impl.ShowBulletin(stBulletinInfo, iBulletinShowCount, fGetBulletinFinishCB)
  if nil == stBulletinInfo or nil == stBulletinInfo.sTitle or nil == stBulletinInfo.vContent or nil == stBulletinInfo.vContent[1] or nil == stBulletinInfo.vContent[1].sContent or nil == stBulletinInfo.iBulletinId or nil == iBulletinShowCount then
    fGetBulletinFinishCB()
    return
  end
  CS.UnityEngine.PlayerPrefs.SetInt("BulletinId" .. stBulletinInfo.iBulletinId, iBulletinShowCount + 1)
  StackFlow:Push(UIDefines.ID_FORM_LOGINANNOUNCEMENT, {stBulletinInfo = stBulletinInfo, fCloseCB = fGetBulletinFinishCB})
end

function Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletin(jobNode)
  ReportManager:ReportLoginProcess("InitNetwork_Login_GetBulletin", "GetBulletin_Start")
  
  local function OnGetBulletinFinish()
    jobNode.Status = JobStatus.Success
  end
  
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  local reqMsg = MTTDProto.Cmd_Login_GetBulletin_CS()
  reqMsg.iCurrId = 0
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
  RPCS():Login_GetBulletin(reqMsg, function(sc, msg)
    ReportManager:ReportLoginProcess("InitNetwork_Login_GetBulletin", "GetBulletin_Success")
    log.info("--- login get bulletin success : ", msg.rspcode, " ---")
    CS.UserData.Instance.loginGetBulletin = sc
    UserDataManager:SetLoginGetBulletinSC(sc)
    if sc.vMaintainInfo and #sc.vMaintainInfo > 0 then
      table.sort(sc.vMaintainInfo, function(a, b)
        return a.iMaintainRemainSecs > b.iMaintainRemainSecs
      end)
      for i, v in ipairs(sc.vMaintainInfo) do
        if 0 <= v.iMaintainRemainSecs then
          StackFlow:Push(UIDefines.ID_FORM_LOGINANNOUNCEMENTMAINTAIN, {stMaintainInfo = v})
          return
        end
      end
    end
    Job_Login_Login_GetBulletin_Impl.TryShowBulletin(sc.vInfo, OnGetBulletinFinish)
  end, function(msg)
    ReportManager:ReportLoginProcess("InitNetwork_Login_GetBulletin", "GetBulletin_Failed")
    log.info("--- login get bulletin failed : ", msg.rspcode, " ---")
    OnGetBulletinFinish()
  end, function(rec)
    ReportManager:ReportLoginProcess("InitNetwork_Login_GetBulletin", "GetBulletin_Timeout")
    log.info("--- login get bulletin timeout ---")
    OnGetBulletinFinish()
  end, nil, nil, -1)
end

function Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletinSuccess(jobNode)
end

function Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletinFailed(jobNode)
end

function Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletinTimeOut(jobNode)
end

function Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletinDispose(jobNode)
end

return Job_Login_Login_GetBulletin_Impl
