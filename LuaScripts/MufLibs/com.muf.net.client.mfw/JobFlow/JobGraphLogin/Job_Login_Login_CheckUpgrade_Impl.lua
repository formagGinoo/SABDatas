local Job_Login_Login_CheckUpgrade_Impl = {}
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_Login_Login_CheckUpgrade_Impl.PharseCDN(sURLPath)
  local server = string.gsub(sURLPath .. " ", "http://(.-)/.+", "%1")
  if string.find(server, "https:") then
    server = string.gsub(sURLPath .. " ", "https://(.-)/.+", "%1")
    return "https://" .. server
  else
    return "http://" .. server
  end
end

function Job_Login_Login_CheckUpgrade_Impl.ShowDebugChangeZone()
  local stLoginGetZoneSC = UserDataManager:GetLoginGetZoneSC()
  local sClientResVer = CS.VersionUtil.GetResVer(CS.VersionContext.GetContext().ClientLocalVersion)
  local iZonedID
  for _, stZoneInfo in ipairs(stLoginGetZoneSC.vZoneList) do
    if stZoneInfo.iStatus == MTTDProto.EM_ZoneStatus_Smooth and (stZoneInfo.iFlag == MTTDProto.EM_ZoneFlag_Normal or stZoneInfo.iFlag == MTTDProto.EM_ZoneFlag_New) then
      local sServerResVer = CS.VersionUtil.GetResVer(stZoneInfo.sVersion)
      if sClientResVer == sServerResVer then
        log.error(string.format("Recommend ZoneId: %s, ZoneName: %s", stZoneInfo.iZoneId, stZoneInfo.sZoneName))
        iZonedID = iZonedID or stZoneInfo.iZoneId
      end
    end
  end
  local iZonedIDCur = UserDataManager:GetZoneID()
  local iAccountID = UserDataManager:GetAccountID()
  if iZonedID ~= nil then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeChangeZoneTitle"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeChangeZoneDescMatch"),
      fContentCB = function(sContent)
        return string.format(sContent, sClientResVer, iZonedIDCur, iAccountID, iZonedID)
      end,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        Util.RequestGM(iZonedIDCur, "change_zone " .. iAccountID .. " " .. iZonedID)
        CS.ApplicationManager.Instance:ExitGame()
      end
    })
  else
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeChangeZoneTitle"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeChangeZoneDescNoMatch"),
      fContentCB = function(sContent)
        return string.format(sContent, sClientResVer, iZonedIDCur, iAccountID)
      end,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:ExitGame()
      end
    })
  end
end

function Job_Login_Login_CheckUpgrade_Impl.DownloadUpgradePatch(jobNode, scLoginCheckUpgrade, vResPatch)
  local sClientVersion = scLoginCheckUpgrade.sClientVersion
  
  local function OnDownloadUpgradePatchListComplete(sVersion, needSpaceSize)
    if sVersion == "0" then
      ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_DownloadPatchList_Failed")
      log.error(string.format("Download Upgrade Pathch Failed: CDN-%s, Version-%s", table.serialize(vResPatch), sClientVersion))
      if CS.ApplicationManager.Instance:IsEnableDebugNova() then
        Job_Login_Login_CheckUpgrade_Impl.ShowDebugChangeZone()
      else
        utils.CheckAndPushCommonTips({
          title = CS.ConfFact.LangFormat4DataInit("CommonError"),
          content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeDownloadFail"),
          funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
          btnNum = 1,
          bLockBack = true,
          func1 = function()
            CS.ApplicationManager.Instance:RestartGame()
          end
        })
      end
      jobNode.Status = JobStatus.Failed
      return
    end
    local versionContext = CS.VersionContext.GetContext()
    log.info("VersionContext.ClientLocalVersion :", versionContext.ClientLocalVersion)
    log.info("Server Client Version :", sVersion)
    local localResVersion = CS.VersionUtil.GetResVer(versionContext.ClientLocalVersion)
    local compare = CS.VersionUtil.CompareResVerPart(localResVersion, sVersion)
    log.info("Compare :", compare)
    if 0 <= compare then
      ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_DownloadPatchList_NotMatch")
      log.error(string.format("Download Upgrade Pathch NotMatch: CDN-%s, Version-%s", table.serialize(vResPatch), sClientVersion))
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeDownloadFail"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
        btnNum = 1,
        bLockBack = true,
        func1 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
      jobNode.Status = JobStatus.Failed
      return
    end
    local freeSpaceSize = CS.DeviceUtil.GetPersistentDataPathAvailableSize()
    local virNeedSpaceSize = (needSpaceSize or 0) / 1024 / 1024 * 6
    log.info("needSpaceSize: " .. needSpaceSize .. " freeSpaceSize: " .. freeSpaceSize)
    if freeSpaceSize < virNeedSpaceSize then
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("LowStorageWarning"),
        fContentCB = function(sContent)
          local sContentNew = string.customizereplace(sContent, {"{size1}"}, DownloadManager:GetDownloadSizeStr(freeSpaceSize))
          sContentNew = string.customizereplace(sContentNew, {"{size2}"}, DownloadManager:GetDownloadSizeStr(needSpaceSize * 6))
          return sContentNew
        end,
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
        btnNum = 1,
        bLockBack = true,
        bAutoClose = false,
        func1 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
      jobNode.Status = JobStatus.Failed
      return
    end
    ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_DownloadPatchList_Success")
    
    local function OnDownloadUpgradePatchProgress(stDownloadHandler)
      local iCurrDownloadSize = stDownloadHandler.CurrDownloadSize
      local iNeedDownloadSize = stDownloadHandler.NeedDownloadSize
      if iCurrDownloadSize < iNeedDownloadSize then
        jobNode.UnitProgress = iCurrDownloadSize / iNeedDownloadSize * 0.7 * 0.6
        local sProgress = DownloadManager:GetDownloadProgressStr(iCurrDownloadSize, iNeedDownloadSize)
        EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
      else
        local iCurrUnZipFileSize = stDownloadHandler.CurrUnZipFileSize
        local iNeedUnZipFileSize = stDownloadHandler.NeedUnZipFileSize
        if 0 < iNeedUnZipFileSize then
          jobNode.UnitProgress = (0.7 + iCurrUnZipFileSize / iNeedUnZipFileSize * 0.3) * 0.6
          local sProgress = string.format(CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeUnzip") .. " %d / %d", iCurrUnZipFileSize, iNeedUnZipFileSize)
          EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
        else
          jobNode.UnitProgress = 0.7
          local sProgress = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeUnzip") .. " -- / --"
          EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
        end
      end
    end
    
    local function OnDownloadUpgradePatchComplete(handler)
      if handler.Status == CS.MUF.Download.DownloadStatus.Success then
        ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_DownloadPatch_Success")
        log.info("UpgradePatch Succeed")
        CS.MUF.Download.UpgradePatch.Instance:CheckVersion()
        local iTimerCopyAddResPreProgress = -1
        
        local function OnCopyAddResPreFinished()
          ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_CopyAddResPre_Success")
          TimeService:KillTimer(iTimerCopyAddResPreProgress)
          CS.TGRPDownloaderAddResPre.Instance:ClearAddResPreDir()
          if DownloadManager:NeedRestartOnUpgradePatch() then
            utils.CheckAndPushCommonTips({
              title = CS.ConfFact.LangFormat4DataInit("UpdateComplete"),
              content = CS.ConfFact.LangFormat4DataInit("UpdateRestartConfirm"),
              funcText1 = CS.ConfFact.LangFormat4DataInit("PlayerCancelInfoYes"),
              btnNum = 1,
              bLockBack = true,
              func1 = function()
                CS.ApplicationManager.Instance:RestartGame()
              end
            })
          else
            EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = false})
            jobNode.UnitProgress = 1
            EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {
              jobFlow = require("JobFlow/JobGraphStartup/JobGraphStartup").Instance(),
              fMin = 0,
              fMax = 1
            })
            StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_LOGINANNOUNCEMENTUPGRADE)
            CS.VersionContext.GetContext():Reload()
            CS.LuaManager.Instance:ReloadLuaBundle()
            CS.MUF.Download.DownloadResource.Instance:Reload()
            CS.MultiLanguageManager.Instance:ReloadLanguageConfig()
            Job_Login_Login_CheckUpgrade_Impl.OnCheckUpgradeComplete(jobNode, scLoginCheckUpgrade)
          end
        end
        
        local function OnCopyAddResPreProgress()
          local iCopiedFiles = CS.TGRPDownloaderAddResPre.Instance.CopiedFiles
          local iCopiedFilesTotal = CS.TGRPDownloaderAddResPre.Instance.CopiedFilesTotal
          if iCopiedFiles >= iCopiedFilesTotal then
            OnCopyAddResPreFinished()
          end
          if iCopiedFilesTotal == 0 then
            iCopiedFilesTotal = 1
          end
          jobNode.UnitProgress = 0.6 + iCopiedFiles / iCopiedFilesTotal * 0.4
          local sProgress = string.format(CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeAddResPreCopy") .. " %d / %d", iCopiedFiles, iCopiedFilesTotal)
          EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowDownloadProgress, {bShow = true, sProgress = sProgress})
        end
        
        local sTargetResVersion = CS.VersionUtil.GetResVer(sClientVersion)
        local sAddResPreResVer = LocalDataManager:GetStringSimple("DownloadAddResPre_Start", "")
        if sTargetResVersion == sAddResPreResVer then
          ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_CopyAddResPre_Start")
          iTimerCopyAddResPreProgress = TimeService:SetTimer(0.05, -1, OnCopyAddResPreProgress)
          CS.TGRPDownloaderAddResPre.Instance:Copy2PersistentDataPath(sTargetResVersion)
        else
          OnCopyAddResPreFinished()
        end
      else
        ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_DownloadPatch_Failed" .. "Patch_DownloadPatch_Failed" .. "@" .. tostring(handler.ErrorCode) .. "@" .. tostring(handler.ErrorMessage))
        log.error("UpgradePatch Failed")
        local sErrorTips = ""
        if handler.ErrorCode == CS.MUF.Download.DownloadFileErrorCode.SpaceNotEnoughError then
          sErrorTips = CS.ConfFact.LangFormat4DataInit("LowStorageWarning")
          local sNeedSpace, sFreeSpace = handler.ErrorMessage:match("Need%s+(%d+).-Free%s+(%d+)")
          sErrorTips = string.gsub(sErrorTips, "{size1}", sFreeSpace .. CS.ConfFact.LangFormat4DataInit("MByte"))
          sErrorTips = string.gsub(sErrorTips, "{size2}", sNeedSpace .. CS.ConfFact.LangFormat4DataInit("MByte"))
        else
          sErrorTips = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeDownloadFail")
        end
        utils.CheckAndPushCommonTips({
          title = CS.ConfFact.LangFormat4DataInit("CommonError"),
          content = sErrorTips,
          funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
          btnNum = 1,
          bLockBack = true,
          func1 = function()
            CS.ApplicationManager.Instance:RestartGame()
          end
        })
        jobNode.Status = JobStatus.Failed
      end
    end
    
    if CS.MUF.Download.UpgradePatch.Instance:CheckPreRes(versionContext.ClientLocalVersion) then
      jobNode.UnitProgress = 1
      local fJobProgressMax = jobNode.Graph:GetJobProgress()
      jobNode.UnitProgress = 0
      local fJobProgressMin = jobNode.Graph:GetJobProgress()
      EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {
        jobFlow = jobNode.Graph,
        fMin = fJobProgressMin,
        fMax = fJobProgressMax,
        jobProgressSpeedMulti = 1
      })
      ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_DownloadPatch_Start")
      CS.MUF.Download.UpgradePatch.Instance:StartUpgradePatch(versionContext.ClientLocalVersion, false, OnDownloadUpgradePatchComplete, OnDownloadUpgradePatchProgress)
    else
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTitle"),
        content = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsForce"),
        fContentCB = function(sContent)
          local sContentNew = string.customizereplace(sContent, {"{size}"}, DownloadManager:GetDownloadSizeStr(needSpaceSize))
          return sContentNew
        end,
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonDownload"),
        btnNum = 1,
        bLockBack = true,
        func1 = function()
          jobNode.UnitProgress = 1
          local fJobProgressMax = jobNode.Graph:GetJobProgress()
          jobNode.UnitProgress = 0
          local fJobProgressMin = jobNode.Graph:GetJobProgress()
          EventCenter.Broadcast(EventDefine.eGameEvent_Login_SetProgressClamp, {
            jobFlow = jobNode.Graph,
            fMin = fJobProgressMin,
            fMax = fJobProgressMax,
            jobProgressSpeedMulti = 1
          })
          ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_DownloadPatch_Start")
          CS.MUF.Download.UpgradePatch.Instance:StartUpgradePatch(versionContext.ClientLocalVersion, false, OnDownloadUpgradePatchComplete, OnDownloadUpgradePatchProgress)
        end
      })
    end
  end
  
  ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Patch_DownloadPatchList_Start")
  CS.MUF.Download.UpgradePatch.Instance:DownloadUpgradeByServer(sClientVersion, vResPatch, OnDownloadUpgradePatchListComplete, 10, scLoginCheckUpgrade.sCdnVersion)
  StackFlow:Push(UIDefines.ID_FORM_LOGINANNOUNCEMENTUPGRADE)
end

function Job_Login_Login_CheckUpgrade_Impl.OnCheckUpgradeComplete(jobNode, scLoginCheckUpgrade)
  local loginContext = CS.LoginContext.GetContext()
  
  local function OnDownloadSharpFixPatchComplete(result)
    log.info("DownloadSharpFixPatch result : ", result)
    if result == 2 then
      CS.com.muf.sharpfix.SharpFixPatchManager.Instance:LoadAllSharpFixPatch()
    elseif result == 1 then
    else
      if result == 0 then
      else
      end
    end
  end
  
  CS.com.muf.sharpfix.SharpFixPatchManager.Instance:DownloadSharpFixPatchByServer(OnDownloadSharpFixPatchComplete)
  local vMiniPatch = {
    scLoginCheckUpgrade.sMiniPatchPath
  }
  local sMiniPatchCdn = Job_Login_Login_CheckUpgrade_Impl.PharseCDN(scLoginCheckUpgrade.sMiniPatchPath)
  for i = 1, #scLoginCheckUpgrade.vCdnList do
    local sCdn = scLoginCheckUpgrade.vCdnList[i]
    vMiniPatch[i + 1] = string.gsub(scLoginCheckUpgrade.sMiniPatchPath, sMiniPatchCdn, sCdn)
  end
  CS.TGRPDownloaderMiniPatch.IsMiniPatchOpen = scLoginCheckUpgrade.bMiniPatchOpen
  CS.TGRPDownloaderMiniPatch.IsMiniPatchReport = true
  CS.CDNHelper.Instance:SetMiniPatchCDNList(vMiniPatch)
  DownloadManager:SetMiniPatchConfig(scLoginCheckUpgrade.iMiniPatchVersion, scLoginCheckUpgrade.bMiniPatchBackground, scLoginCheckUpgrade.bMiniPatchRestart)
  local vStateScript = {
    scLoginCheckUpgrade.sStateScriptPath
  }
  local sStateScriptCdn = Job_Login_Login_CheckUpgrade_Impl.PharseCDN(scLoginCheckUpgrade.sStateScriptPath)
  for i = 1, #scLoginCheckUpgrade.vCdnList do
    local sCdn = scLoginCheckUpgrade.vCdnList[i]
    vStateScript[i + 1] = string.gsub(scLoginCheckUpgrade.sStateScriptPath, sStateScriptCdn, sCdn)
  end
  CS.TGRPDownloaderStateScript.IsOpen = scLoginCheckUpgrade.bStateScriptOpen
  CS.TGRPDownloaderStateScript.IsReport = true
  CS.CDNHelper.Instance:SetStateScriptCDNList(vStateScript)
  DownloadManager:SetStateScriptConfig(scLoginCheckUpgrade.iStateScriptVersion)
  if scLoginCheckUpgrade.vProxyConnServer ~= "" then
    ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "CheckUpgrade_ProxyConnServer:" .. table.serialize(scLoginCheckUpgrade.vProxyConnServer))
    for _, sIpData in pairs(scLoginCheckUpgrade.vProxyConnServer) do
      local stIpData = string.split(sIpData, ":")
      if #stIpData == 2 then
        log.info("vProxyConnServer: " .. stIpData[1] .. ":" .. stIpData[2])
        loginContext:AddGameServerIp(stIpData[1], tonumber(stIpData[2]))
      end
    end
    jobNode.Status = JobStatus.Success
  elseif scLoginCheckUpgrade.sConnServer ~= "" then
    ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "CheckUpgrade_ConnServer:" .. scLoginCheckUpgrade.sConnServer)
    local vIpData = string.split(scLoginCheckUpgrade.sConnServer, ";")
    for _, sIpData in pairs(vIpData) do
      local stIpData = string.split(sIpData, ":")
      if #stIpData == 2 then
        loginContext:AddGameServerIp(stIpData[1], tonumber(stIpData[2]))
      end
    end
    jobNode.Status = JobStatus.Success
  else
    ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "CheckUpgrade_ConnServer_Empty")
    jobNode.Status = JobStatus.Failed
  end
end

function Job_Login_Login_CheckUpgrade_Impl.TryCheckUpgrade(jobNode)
  ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "CheckUpgrade_Start")
  local reqMsg = MTTDProto.Cmd_Login_CheckUpgrade_CS()
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  reqMsg.iAccountId = loginContext.AccountID
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  reqMsg.sChannel = versionContext.Channel
  reqMsg.sSessionKey = loginContext.SessionKey
  reqMsg.iZoneId = loginContext.CurZoneInfo.iZoneId
  RPCS():Login_CheckUpgrade(reqMsg, function(sc, retMsg)
    ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "CheckUpgrade_Success")
    CS.UserData.Instance.loginCheckUpgrade = sc
    log.info("***** Cmd_Login_CheckUpgrade_CS Success")
    local loginContext = CS.LoginContext.GetContext()
    log.info("***** Cmd_Login_CheckUpgrade_CS sClientVersion :", sc.sClientVersion)
    loginContext.ClientLoginVersion = sc.sClientVersion
    log.info("***** Cmd_Login_CheckUpgrade_CS AccountID : ", loginContext.AccountID)
    local vResPatch = {
      sc.sResPatchVersion
    }
    local sResPatchCdn = Job_Login_Login_CheckUpgrade_Impl.PharseCDN(sc.sResPatchVersion)
    local vResVersion = {
      sc.sResAllVersion
    }
    local sResVersionCdn = Job_Login_Login_CheckUpgrade_Impl.PharseCDN(sc.sResAllVersion)
    local vActivityImage = {
      sc.sActivityPictureAddr
    }
    local sActivityImageCDN = Job_Login_Login_CheckUpgrade_Impl.PharseCDN(sc.sActivityPictureAddr)
    for i = 1, #sc.vCdnList do
      local sCdn = sc.vCdnList[i]
      vResPatch[i + 1] = string.gsub(sc.sResPatchVersion, sResPatchCdn, sCdn)
      vResVersion[i + 1] = string.gsub(sc.sResAllVersion, sResVersionCdn, sCdn)
      vActivityImage[i + 1] = string.gsub(sc.sActivityPictureAddr, sActivityImageCDN, sCdn)
    end
    loginContext.ResVersionList = vResVersion
    loginContext.ResPatchList = vResPatch
    CS.MUF.Download.DownloadResourceCDNStrategy.Instance:SetCDN(vResVersion)
    CS.MUF.Download.UpgradePatch.Instance:SetPatchCDNList(vResPatch)
    CS.CDNHelper.Instance:SetResVersion(vResVersion)
    CS.CDNHelper.Instance:SetCDNVersion(sc.sCdnVersion)
    CS.CDNHelper.Instance:SetActivityImageCDNList(vActivityImage)
    local strBigVer = CS.VersionUtil.GetBigVer(versionContext.ClientStreamVersion)
    log.info("***** Cmd_Login_CheckUpgrade_CS ClientStreamVersion : ", versionContext.ClientStreamVersion)
    log.info("***** Cmd_Login_CheckUpgrade_CS sc.sForceVersion : ", sc.sForceVersion)
    local iForceUpdateCompare = CS.VersionUtil.CompareBigVerPart(sc.sForceVersion, strBigVer)
    log.info("***** Cmd_Login_CheckUpgrade_CS iForceUpdateCompare : ", iForceUpdateCompare)
    if 0 < iForceUpdateCompare then
      ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "ForceUpdate")
      log.info("版本过低，需要进行强制更新")
      log.info("ApkUpdateAddr: " .. sc.sApkUpdateAddr)
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonPrompt"),
        content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeForce"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonDownload"),
        btnNum = 1,
        bLockBack = true,
        bAutoClose = false,
        func1 = function()
          CS.DeviceUtil.OpenURLNew(sc.sApkUpdateAddr)
        end
      })
      jobNode.Status = JobStatus.Failed
    else
      local serverResVer = CS.VersionUtil.GetResVer(sc.sClientVersion)
      log.info("***** Cmd_Login_CheckUpgrade_CS serverResVer : ", serverResVer)
      local localResVer = CS.VersionUtil.GetResVer(versionContext.ClientLocalVersion)
      log.info("***** Cmd_Login_CheckUpgrade_CS localResVer : ", localResVer)
      local compare = CS.VersionUtil.CompareResVerPart(serverResVer, localResVer)
      log.info("***** Cmd_Login_CheckUpgrade_CS compare : ", compare)
      if 0 < compare then
        if ChannelManager:IsWindows() then
          utils.CheckAndPushCommonTips({
            title = CS.ConfFact.LangFormat4DataInit("CommonPrompt"),
            content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeWindowsForce"),
            funcText1 = CS.ConfFact.LangFormat4DataInit("CommonDownload"),
            btnNum = 1,
            bLockBack = true,
            bAutoClose = false,
            func1 = function()
              CS.DeviceUtil.OpenURLNew(sc.sApkUpdateAddr)
            end
          })
          jobNode.Status = JobStatus.Failed
          return
        end
        Job_Login_Login_CheckUpgrade_Impl.DownloadUpgradePatch(jobNode, sc, vResPatch)
        return
      elseif compare < 0 then
        ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "Downgrade")
        if not IsWindowsEditor() then
          local streamResVer = CS.VersionUtil.GetResVer(versionContext.ClientStreamVersion)
          log.info("***** Cmd_Login_CheckUpgrade_CS streamResVer : ", streamResVer)
          local realCompare = CS.VersionUtil.CompareResVerPart(localResVer, streamResVer)
          log.info("***** Cmd_Login_CheckUpgrade_CS realCompare : ", realCompare)
          if 0 < realCompare then
          else
            if CS.ApplicationManager.Instance:IsEnableDebugNova() then
              Job_Login_Login_CheckUpgrade_Impl.ShowDebugChangeZone()
            else
              utils.CheckAndPushCommonTips({
                title = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeVersionErrorTitle"),
                content = CS.ConfFact.LangFormat4DataInit("LogicCheckUpgradeVersionErrorDesc"),
                funcText1 = CS.ConfFact.LangFormat4DataInit("CommonExit"),
                btnNum = 1,
                bLockBack = true,
                func1 = function()
                  CS.ApplicationManager.Instance:ExitGame()
                end
              })
            end
            jobNode.Status = JobStatus.Failed
          end
        else
          Job_Login_Login_CheckUpgrade_Impl.OnCheckUpgradeComplete(jobNode, sc)
        end
      else
        Job_Login_Login_CheckUpgrade_Impl.OnCheckUpgradeComplete(jobNode, sc)
      end
    end
  end, function(msg)
    ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "CheckUpgrade_Failed")
    log.info("--- login check upgrade failed : ", msg.rspcode, " ---")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRestart"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end,
      func2 = function()
        GameManager:ReGameLogin()
      end
    })
  end, function(rec)
    ReportManager:ReportLoginProcess("InitNetwork_Login_CheckUpgrade", "CheckUpgrade_Timeout")
    log.info("--- login check upgrade timeout ---")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRestart"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end,
      func2 = function()
        GameManager:ReGameLogin()
      end
    })
  end, nil, nil, -1)
end

function Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgrade(jobNode)
  Job_Login_Login_CheckUpgrade_Impl.TryCheckUpgrade(jobNode)
end

function Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgradeSuccess(jobNode)
end

function Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgradeFailed(jobNode)
end

function Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgradeTimeOut(jobNode)
end

function Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgradeDispose(jobNode)
end

return Job_Login_Login_CheckUpgrade_Impl
