local BaseManager = require("Manager/Base/BaseManager")
local DownloadManager = class("DownloadManager", BaseManager)
local DownloadResource = CS.MUF.Download.DownloadResource.Instance
local ResourcePackageAllStr = "All"
DownloadManager.NetworkStatus = {
  None = 0,
  Wifi = 1,
  Mobile = 2
}
DownloadManager.TaskTag = {
  Base = 0,
  Newbie = 1,
  MainLevel = 2,
  Activity = 3,
  Ignore = 4
}

function DownloadManager:OnCreate()
  self.ResourcePackageType = CS.MUF.Resource.ResourcePackageType
  self.ResourceType = CS.MUF.Resource.ResourceType
  self.m_bDownloadAddResAllInit = false
  self.m_bDownloadAddResAll = false
  self.m_vDownloadAddResAllConfig = {}
  self.m_vTaskDownloadResourceAll = {}
  self.m_bDownloadResourceUILock = false
  self.m_vDownloadResourceWithUIConfig = {}
  self.m_vDownloadResourceRetryConfig = {}
  self.m_eNetworkStatus = self.NetworkStatus.None
  if CS.DeviceUtil.IsWIFIConnected() then
    self.m_eNetworkStatus = self.NetworkStatus.Wifi
  elseif CS.DeviceUtil.IsMobileConnected() then
    self.m_eNetworkStatus = self.NetworkStatus.Mobile
  end
  self.m_bDownloadInMobile = nil
  self.m_iDownloadResourceWithUIMobileTipsTime = nil
  self.m_vDownloadResourceAllConfig = {}
  self.m_iConfigUID = 0
  self:addEventListener("eGameEvent_NetworkGame_Reconnect", handler(self, self.OnEventNetworkGameReconnect))
  self:addEventListener("eGameEvent_ResourceDownload_UIManualClosed", handler(self, self.OnDownloadUIManualClosed))
end

function DownloadManager:GetPackageAdditionalResource(sPackageName, ePackageType)
  local vPackageAdditional = {}
  local vExtraResourceAdditional = {}
  if ePackageType == self.ResourcePackageType.Custom then
    if sPackageName == "Pack_Prologue" then
      local iMainLevelMapChapterIDMax = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("NewBieMainLevelMapResource").m_Value)
      local mMainLevelMapText2DRes = {}
      for iChapterID = 1, iMainLevelMapChapterIDMax do
        local stLevelMapConfig = ConfigManager:GetConfigInsByName("LevelMapConfig"):GetValue_ByChapter(iChapterID)
        if not stLevelMapConfig:GetError() then
          for i = 0, stLevelMapConfig.m_Texture2DRes.Length - 1 do
            local sName = stLevelMapConfig.m_Texture2DRes[i]
            if mMainLevelMapText2DRes[sName] == nil then
              mMainLevelMapText2DRes[sName] = true
              vExtraResourceAdditional[#vExtraResourceAdditional + 1] = {
                sName = sName,
                eType = self.ResourceType.Texture2DRes
              }
            end
          end
        end
      end
    elseif sPackageName == "Pack_NewUser_UI" then
      local iMainLevelMapChapterIDMax = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("PackNewUserUIMainLevelMapResource").m_Value)
      local mMainLevelMapText2DRes = {}
      for iChapterID = 1, iMainLevelMapChapterIDMax do
        local stLevelMapConfig = ConfigManager:GetConfigInsByName("LevelMapConfig"):GetValue_ByChapter(iChapterID)
        if not stLevelMapConfig:GetError() then
          for i = 0, stLevelMapConfig.m_Texture2DRes.Length - 1 do
            local sName = stLevelMapConfig.m_Texture2DRes[i]
            if mMainLevelMapText2DRes[sName] == nil then
              mMainLevelMapText2DRes[sName] = true
              vExtraResourceAdditional[#vExtraResourceAdditional + 1] = {
                sName = sName,
                eType = self.ResourceType.Texture2DRes
              }
            end
          end
        end
      end
    elseif sPackageName == "Pack_Hall" and NetworkManager and NetworkManager.m_bNetworkInited then
      local heroPosData = RoleManager:GetMainBackGroundDataList()
      if heroPosData and next(heroPosData) then
        for i, v in pairs(heroPosData) do
          if v.iType == RoleManager.MainBgType.Role then
            vPackageAdditional[#vPackageAdditional + 1] = {
              sName = tostring(v.iId),
              eType = self.ResourcePackageType.Character
            }
          elseif v.iType == RoleManager.MainBgType.Activity then
            local mainBgCfg = RoleManager:GetMainBackgroundCfg(v.iId)
            if mainBgCfg then
              vExtraResourceAdditional[#vExtraResourceAdditional + 1] = {
                sName = mainBgCfg.m_Prefabs,
                eType = self.ResourceType.UI
              }
            end
          elseif v.iType == RoleManager.MainBgType.Fashion then
            local fashionID = v.iId
            local fashionInfo = HeroManager:GetHeroFashion():GetFashionInfoByID(fashionID)
            if fashionInfo then
              vPackageAdditional[#vPackageAdditional + 1] = {
                sName = tostring(fashionInfo.m_CharacterId),
                eType = self.ResourcePackageType.Character
              }
            end
          end
        end
      end
      local prefabs = HeroActivityManager:GetSignPrefabList()
      if 0 < #prefabs then
        for i, v in ipairs(prefabs) do
          if v and v ~= "" then
            vPackageAdditional[#vPackageAdditional + 1] = {
              sName = v,
              eType = self.ResourcePackageType.UI
            }
          end
        end
      end
      local signFacePanelList = ActivityManager:SignPushFacePanelDownLoadInHall()
      if 0 < #signFacePanelList then
        for i, v in ipairs(signFacePanelList) do
          if v and v ~= "" then
            vPackageAdditional[#vPackageAdditional + 1] = {
              sName = v,
              eType = self.ResourcePackageType.UI
            }
          end
        end
      end
      local gachaFacePanelList, vExtraSubPanelData = ActivityManager:GachaPushFacePanelDownLoadInHall()
      if 0 < #gachaFacePanelList then
        for i, v in ipairs(gachaFacePanelList) do
          if v and v ~= "" then
            vPackageAdditional[#vPackageAdditional + 1] = {
              sName = v,
              eType = self.ResourcePackageType.UI
            }
          end
        end
      end
      if 0 < #vExtraSubPanelData then
        for i, v in ipairs(vExtraSubPanelData) do
          if v then
            vExtraResourceAdditional[#vExtraResourceAdditional + 1] = v
          end
        end
      end
      local vPackageTimeline = ActivityManager:TimelinePushfacePanelDownLoadInHall()
      if 0 < #vPackageTimeline then
        for i, v in ipairs(vPackageTimeline) do
          vPackageAdditional[#vPackageAdditional + 1] = v
        end
      end
      local monthlyCardPanel = MonthlyCardManager:IsCanMonthlyCardPushFace()
      if monthlyCardPanel and monthlyCardPanel ~= "" then
        vPackageAdditional[#vPackageAdditional + 1] = {
          sName = monthlyCardPanel,
          eType = self.ResourcePackageType.UI
        }
      end
      if GuildManager:CheckGuildBossIsOpen() then
        vPackageAdditional[#vPackageAdditional + 1] = {
          sName = "Form_GuildRaidBossRoundTips",
          eType = self.ResourcePackageType.UI
        }
        vPackageAdditional[#vPackageAdditional + 1] = {
          sName = "Form_GuildRaidRanKChangeTips",
          eType = self.ResourcePackageType.UI
        }
      end
      if PersonalRaidManager:IsPersonalRaidOpen() then
        vPackageAdditional[#vPackageAdditional + 1] = {
          sName = "Form_PersonalRaidNewDifficult",
          eType = self.ResourcePackageType.UI
        }
      end
      vPackageAdditional[#vPackageAdditional + 1] = {
        sName = "Form_Push_Gift",
        eType = self.ResourcePackageType.UI
      }
      vPackageAdditional[#vPackageAdditional + 1] = {
        sName = "Form_Push_Gift_Reserve",
        eType = self.ResourcePackageType.UI
      }
      local vAudioBnkId = {
        13,
        91,
        92
      }
      for i, v in ipairs(vAudioBnkId) do
        local temptable = utils.changeCSArrayToLuaTable(UILuaHelper.GetAudioResById(v))
        if temptable then
          for _, value in pairs(temptable) do
            vExtraResourceAdditional[#vExtraResourceAdditional + 1] = {
              sName = value,
              eType = self.ResourceType.Audio
            }
          end
        end
      end
      local FirstVideoResNameList = {
        "Gacha_Enter_1stTime",
        "Censor_Black"
      }
      local str = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.Gacha) or ""
      if str ~= GachaManager.FirstGachaStr then
        for i, v in ipairs(FirstVideoResNameList) do
          vExtraResourceAdditional[#vExtraResourceAdditional + 1] = {
            sName = v .. ".mp4",
            eType = self.ResourceType.Video
          }
        end
      end
      local VideoPlot = {
        "Gacha_Enter_1stTime"
      }
      for i, v in ipairs(VideoPlot) do
        vExtraResourceAdditional[#vExtraResourceAdditional + 1] = {
          sName = v .. ".srt",
          eType = self.ResourceType.Subtitle
        }
      end
    end
  elseif ePackageType == self.ResourcePackageType.Character and NetworkManager and NetworkManager.m_bNetworkInited and ActivityManager:IsInCensorOpen() == true then
    local characterID = tonumber(sPackageName)
    local heroCfg = HeroManager:GetHeroConfigByID(characterID)
    if heroCfg and heroCfg.m_Spine then
      local tempSpineStr = heroCfg.m_Spine
      local verifySpineStr = ConfigManager:GetVerifyPathBySourceStr(tempSpineStr)
      if verifySpineStr and verifySpineStr ~= "" then
        vExtraResourceAdditional[#vExtraResourceAdditional + 1] = {
          sName = verifySpineStr,
          eType = self.ResourceType.UI
        }
        vExtraResourceAdditional[#vExtraResourceAdditional + 1] = {
          sName = "hero_place_" .. verifySpineStr,
          eType = self.ResourceType.UI
        }
      end
    end
  end
  return vPackageAdditional, vExtraResourceAdditional
end

function DownloadManager:GetResourceABList(vPackage, vExtraResource, bAll)
  if bAll == nil then
    bAll = false
  end
  vExtraResource = vExtraResource or {}
  local vResourceAB = {}
  local mResourceAB = {}
  local vResourceABDownloaded = {}
  local mResourceABDownloaded = {}
  if vPackage ~= nil then
    local vPackageAll = {}
    local vPackageAdditional = vPackage
    local vPackageAdditionalNext = {}
    while 0 < #vPackageAdditional do
      for i = 1, #vPackageAdditional do
        local sPackageName = vPackageAdditional[i].sName
        local ePackageType = vPackageAdditional[i].eType
        vPackageAll[#vPackageAll + 1] = {sName = sPackageName, eType = ePackageType}
        local stFileInfoResult = DownloadResource:GetFileInfoListShouldDownloadByPackage(sPackageName, ePackageType, bAll)
        local vResourceABPackage, vResourceABPackageDownloaded = stFileInfoResult.Item1, stFileInfoResult.Item2
        for j = 1, vResourceABPackage.Count do
          local stFileInfo = vResourceABPackage[j - 1]
          local sResPath = stFileInfo:GetResPath()
          if mResourceAB[sResPath] == nil then
            mResourceAB[sResPath] = true
            vResourceAB[#vResourceAB + 1] = sResPath
          end
        end
        for j = 1, vResourceABPackageDownloaded.Count do
          local stFileInfo = vResourceABPackageDownloaded[j - 1]
          local sResPath = stFileInfo:GetResPath()
          if mResourceABDownloaded[sResPath] == nil then
            mResourceABDownloaded[sResPath] = true
            vResourceABDownloaded[#vResourceABDownloaded + 1] = sResPath
          end
        end
        local vPackageAdditionalTmp, vExtraResourceAdditional = self:GetPackageAdditionalResource(sPackageName, ePackageType)
        for j = 1, #vPackageAdditionalTmp do
          local bNew = true
          for k = 1, #vPackageAll do
            if vPackageAll[k].sName == vPackageAdditionalTmp[j].sName and vPackageAll[k].eType == vPackageAdditionalTmp[j].eType then
              bNew = false
              break
            end
          end
          if bNew then
            vPackageAdditionalNext[#vPackageAdditionalNext + 1] = vPackageAdditionalTmp[j]
          end
        end
        for j = 1, #vExtraResourceAdditional do
          vExtraResource[#vExtraResource + 1] = vExtraResourceAdditional[j]
        end
      end
      vPackageAdditional = vPackageAdditionalNext
      vPackageAdditionalNext = {}
    end
  end
  for i = 1, #vExtraResource do
    local sResName = vExtraResource[i].sName
    local sResType = vExtraResource[i].eType
    if DownloadResource:ShouldDownloadResource(sResName, sResType) then
      local vResourceABExtraResource = DownloadResource:GetRelatedFileInfo(sResName, sResType)
      for i = 1, vResourceABExtraResource.Count do
        local stFileInfo = vResourceABExtraResource[i - 1]
        local sResPath = stFileInfo:GetResPath()
        if mResourceAB[sResPath] == nil then
          mResourceAB[sResPath] = true
          vResourceAB[#vResourceAB + 1] = sResPath
        end
      end
    end
  end
  return vResourceAB, vResourceABDownloaded
end

function DownloadManager:GetResourceABListTotalBytes(vResourceAB)
  return CS.TGRPDownloader.GetListResDataTotalBytes(vResourceAB)
end

function DownloadManager:GetResourceABListDownloadedBytes(vResourceAB)
  return CS.TGRPDownloader.GetListResDataDownloadedBytes(vResourceAB)
end

function DownloadManager:ShouldDownloadResource(sFileName, eResourceType)
  return DownloadResource:ShouldDownloadResource(sFileName, eResourceType)
end

function DownloadManager:DownloadResource(vPackage, vExtraResource, sDesc, fStart, fProgress, fComplete, iPriority, eNetworkStatus, vResourceABSpecified)
  local vResourceAB
  if vResourceABSpecified then
    vResourceAB = vResourceABSpecified
  else
    vResourceAB = self:GetResourceABList(vPackage, vExtraResource)
  end
  if #vResourceAB == 0 then
    if fComplete then
      fComplete(true)
    end
    return -1
  end
  log.info("DownloadManager:DownloadResource Package: " .. table.serialize(vPackage or {}))
  log.info("DownloadManager:DownloadResource ExtraResource: " .. table.serialize(vExtraResource or {}))
  log.info("DownloadManager:DownloadResource AB Num: " .. #vResourceAB)
  if eNetworkStatus == nil then
    eNetworkStatus = self.NetworkStatus.Wifi
  end
  local iConfigUID = self.m_iConfigUID
  self.m_iConfigUID = self.m_iConfigUID + 1
  local iBatchID = -1
  local stDownloadResourceConfig = {
    iConfigUID = iConfigUID,
    bUI = false,
    vPackage = vPackage,
    vExtraResource = vExtraResource,
    vResourceABSpecified = vResourceAB,
    sDesc = sDesc,
    fStart = fStart,
    fProgress = fProgress,
    fComplete = fComplete,
    iPriority = iPriority,
    eNetworkStatus = eNetworkStatus,
    lCurBytes = 0,
    lTotalBytes = 0
  }
  
  local function OnDownloadStart(curBytes, totalBytes)
    stDownloadResourceConfig.lCurBytes = curBytes
    stDownloadResourceConfig.lTotalBytes = totalBytes
    if fStart then
      fStart(curBytes, totalBytes)
    end
  end
  
  local function OnDownloadProgress(curBytes, totalBytes, speed)
    stDownloadResourceConfig.lCurBytes = curBytes
    stDownloadResourceConfig.lTotalBytes = totalBytes
    if fProgress then
      fProgress(curBytes, totalBytes, speed)
    end
  end
  
  local function OnDownloadComplete(ret)
    if ret then
      stDownloadResourceConfig.lCurBytes = stDownloadResourceConfig.lTotalBytes
      if fComplete then
        fComplete(ret)
      end
    else
      log.error("Download Failed: " .. iBatchID)
      table.insert(self.m_vDownloadResourceRetryConfig, stDownloadResourceConfig)
    end
    table.removebyvalue(self.m_vDownloadResourceAllConfig, stDownloadResourceConfig)
  end
  
  iPriority = iPriority or 0
  iBatchID = CS.TGRPDownloader.DownloadResListWithDesc(vResourceAB, sDesc, OnDownloadComplete, OnDownloadStart, OnDownloadProgress, iPriority)
  if 0 <= iBatchID then
    stDownloadResourceConfig.iBatchID = iBatchID
    table.insert(self.m_vDownloadResourceAllConfig, stDownloadResourceConfig)
    if self.m_eNetworkStatus ~= self.NetworkStatus.Wifi and eNetworkStatus == self.NetworkStatus.Wifi and not self:CanDownloadInMobile() then
      CS.TGRPDownloader.PauseDownload(iBatchID)
    end
  end
  return iBatchID
end

function DownloadManager:DownloadResourceWithUI(vPackage, vExtraResource, sDesc, fStart, fProgress, fComplete, iPriority, eNetworkStatus, tUIExtraParam, vResourceABSpecified, fPlayerCancelDownloadCB)
  if ChannelManager:IsWindows() then
    if fComplete then
      fComplete(true)
    end
    return false
  end
  local vResourceAB
  if vResourceABSpecified then
    vResourceAB = vResourceABSpecified
  else
    vResourceAB = self:GetResourceABList(vPackage, vExtraResource)
  end
  if #vResourceAB == 0 then
    if tUIExtraParam and tUIExtraParam.iBatchIDPre then
      self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
        iBatchID = tUIExtraParam.iBatchIDPre,
        bComplete = true
      })
    end
    if fComplete then
      fComplete(true)
    end
    return false
  end
  local lTotalBytes = self:GetResourceABListTotalBytes(vResourceAB)
  local lDownloadedBytes = self:GetResourceABListDownloadedBytes(vResourceAB)
  local lUndownloadedBytes = lTotalBytes - lDownloadedBytes
  log.info("DownloadManager:DownloadResourceWithUI Package: " .. table.serialize(vPackage or {}))
  log.info("DownloadManager:DownloadResourceWithUI ExtraResource: " .. table.serialize(vExtraResource or {}))
  log.info("DownloadManager:DownloadResourceWithUI AB Num: " .. #vResourceAB)
  if eNetworkStatus == nil then
    eNetworkStatus = self.NetworkStatus.Wifi
  end
  if tUIExtraParam == nil then
    tUIExtraParam = {}
  end
  local iConfigUID = self.m_iConfigUID
  self.m_iConfigUID = self.m_iConfigUID + 1
  
  local function ConfirmDownloadResource()
    local iBatchID = -1
    local stDownloadResourceConfig = {
      iConfigUID = iConfigUID,
      bUI = true,
      vPackage = vPackage,
      vExtraResource = vExtraResource,
      vResourceABSpecified = vResourceAB,
      sDesc = sDesc,
      fStart = fStart,
      fProgress = fProgress,
      fComplete = fComplete,
      iPriority = iPriority,
      eNetworkStatus = eNetworkStatus,
      tUIExtraParam = tUIExtraParam,
      lCurBytes = 0,
      lTotalBytes = 0
    }
    
    local function OnDownloadStart(curBytes, totalBytes)
      stDownloadResourceConfig.lCurBytes = curBytes
      stDownloadResourceConfig.lTotalBytes = totalBytes
      self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
        iBatchID = iBatchID,
        lCurBytes = curBytes,
        lTotalBytes = totalBytes
      })
      if stDownloadResourceConfig.fStart then
        stDownloadResourceConfig.fStart(curBytes, totalBytes)
      end
    end
    
    local function OnDownloadProgress(curBytes, totalBytes, speed)
      stDownloadResourceConfig.lCurBytes = curBytes
      stDownloadResourceConfig.lTotalBytes = totalBytes
      self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {
        iBatchID = iBatchID,
        lCurBytes = curBytes,
        lTotalBytes = totalBytes
      })
      if stDownloadResourceConfig.fProgress then
        stDownloadResourceConfig.fProgress(curBytes, totalBytes, speed)
      end
    end
    
    local function OnDownloadComplete(ret)
      local iCostTime
      if stDownloadResourceConfig.iStartDownloadTime then
        iCostTime = (TimeUtil:GetServerTimeMS() - stDownloadResourceConfig.iStartDownloadTime) * 0.001
      else
        iCostTime = 0
      end
      if ret then
        ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "CompleteDownload", iBatchID, iCostTime)
        stDownloadResourceConfig.lCurBytes = stDownloadResourceConfig.lTotalBytes
        self:broadcastEvent("eGameEvent_ResourceDownload_Progress", {iBatchID = iBatchID, bComplete = true})
        if stDownloadResourceConfig.fComplete then
          stDownloadResourceConfig.fComplete(ret)
        end
      else
        log.error("Download Failed: " .. iBatchID)
        ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "CompleteDownloadFail", iBatchID, iCostTime)
        table.insert(self.m_vDownloadResourceRetryConfig, stDownloadResourceConfig)
      end
      self:RemoveDownloadResourceWithUIConfig(iBatchID)
      table.removebyvalue(self.m_vDownloadResourceAllConfig, stDownloadResourceConfig)
    end
    
    iPriority = iPriority or 0
    iBatchID = CS.TGRPDownloader.DownloadResListWithDesc(vResourceAB, sDesc, OnDownloadComplete, OnDownloadStart, OnDownloadProgress, iPriority)
    if 0 <= iBatchID then
      stDownloadResourceConfig.iBatchID = iBatchID
      stDownloadResourceConfig.iStartDownloadTime = TimeUtil:GetServerTimeMS()
      table.insert(self.m_vDownloadResourceAllConfig, stDownloadResourceConfig)
      self:AddDownloadResourceWithUIConfig(iBatchID, stDownloadResourceConfig)
      if self.m_eNetworkStatus ~= self.NetworkStatus.Wifi and eNetworkStatus == self.NetworkStatus.Wifi and not self:CanDownloadInMobile() then
        CS.TGRPDownloader.PauseDownload(iBatchID)
      end
      local iBatchIDPre = tUIExtraParam.iBatchIDPre
      if iBatchIDPre then
        self:broadcastEvent("eGameEvent_ResourceDownload_UpdateBatchID", {iBatchID = iBatchID, iBatchIDPre = iBatchIDPre})
      end
    end
    ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "StartDownload", iBatchID)
    if self.m_eNetworkStatus == self.NetworkStatus.Mobile and not GuideManager:GuideIsActive() and self:CanShowDownloadTriggerTips() then
      if self.m_hasSetTips then
        return
      end
      self.m_confirmTimes = self.m_confirmTimes or 0
      self.m_confirmTimes = self.m_confirmTimes + 1
      if self.m_StreamingTriggerCountThreshold == nil then
        self.m_StreamingTriggerCountThreshold = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("StreamingTriggerCountThreshold").m_Value)
      end
      if self.m_confirmTimes == self.m_StreamingTriggerCountThreshold then
        self:SetDownloadTriggerTips()
        local _vPackage = {}
        local _vExtraResource = {}
        local sPackages = ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("StreamingResourcePackOnMobileData").m_Value
        local vUIPackages = string.split(sPackages, "/")
        for k, v in ipairs(vUIPackages) do
          _vPackage[#_vPackage + 1] = {
            sName = v,
            eType = self.ResourcePackageType.Custom
          }
        end
        local _vResourceAB = self:GetResourceABList(_vPackage, _vExtraResource)
        local _lSizeTotal = self:GetResourceABListTotalBytes(_vResourceAB)
        local _lSizeDownloaded = self:GetResourceABListDownloadedBytes(_vResourceAB)
        if 0 < _lSizeTotal - _lSizeDownloaded then
          self.m_hasSetTips = true
          utils.CheckAndPushCommonTips({
            tipsID = 9964,
            fContentCB = function(sContent)
              local sContentNew = string.customizereplace(sContent, {"{size}"}, self:GetDownloadSizeStr(_lSizeTotal - _lSizeDownloaded))
              return sContentNew
            end,
            bLockBack = true,
            func1 = function()
              self:DownloadResource(_vPackage, _vExtraResource, "StreamingResourcePackOnMobileData", nil, nil, nil, 99, self.NetworkStatus.Mobile)
            end,
            func2 = function()
            end
          })
        end
      end
    end
  end
  
  local function CancelDownloadResource()
    local iNewbieMainLevelID = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("NewbieMainLevelID").m_Value)
    local bNewbie = not LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, iNewbieMainLevelID)
    if bNewbie then
      CS.ApplicationManager.Instance:RestartGame()
    end
    if fPlayerCancelDownloadCB then
      fPlayerCancelDownloadCB()
    end
  end
  
  local lSpaceFree = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
  if lUndownloadedBytes > lSpaceFree then
    ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "NotEnoughSpace")
    utils.CheckAndPushCommonTips({
      tipsID = 9962,
      fContentCB = function(sContent)
        local sContentNew = string.customizereplace(sContent, {"{size1}"}, DownloadManager:GetDownloadSizeStr(lSpaceFree))
        sContentNew = string.customizereplace(sContentNew, {"{size2}"}, DownloadManager:GetDownloadSizeStr(lUndownloadedBytes))
        return sContentNew
      end,
      bLockBack = true,
      func1 = CancelDownloadResource
    })
    return
  end
  if self.m_eNetworkStatus ~= self.NetworkStatus.Wifi and eNetworkStatus == self.NetworkStatus.Wifi and not self:CanDownloadInMobile() and not tUIExtraParam.bHideMobileTips then
    if self.m_iDownloadResourceWithUIMobileTipsBigSize == nil then
      self.m_iDownloadResourceWithUIMobileTipsBigSize = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("InGameMinResourceLimit").m_Value) * 1024 * 1024
    end
    if lUndownloadedBytes > self.m_iDownloadResourceWithUIMobileTipsBigSize and self:CanShowDownloadResourceUIMobileTips() and not GuideManager:GuideIsActive() then
      ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "ConfirmTips")
      local tipsId = 9970
      utils.CheckAndPushCommonTips({
        tipsID = tipsId,
        fContentCB = function(sContent)
          local sContentNew = string.customizereplace(sContent, {"{size}"}, self:GetDownloadSizeStr(lUndownloadedBytes))
          return sContentNew
        end,
        bLockBack = true,
        func1 = function()
          eNetworkStatus = self.NetworkStatus.Mobile
          ConfirmDownloadResource()
        end,
        func2 = CancelDownloadResource,
        bShowToggleYes = true,
        bToggleYesDefault = false,
        sToggleYesDesc = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(2024).m_mMessage,
        fToggleYesCB = function(bToggle)
          if bToggle then
            ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "ConfirmTips_ToggleNotShowToday")
            self:SetDownloadResourceUIMobileTips()
          end
        end
      })
    else
      if lUndownloadedBytes <= self.m_iDownloadResourceWithUIMobileTipsBigSize then
        ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "NoConfirmTips_Small")
      else
        ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "NoConfirmTips_NotShowToday")
      end
      eNetworkStatus = self.NetworkStatus.Mobile
      ConfirmDownloadResource()
    end
  else
    if self.m_eNetworkStatus == self.NetworkStatus.Wifi then
      ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "NoConfirmTips_Wifi")
    elseif self:CanDownloadInMobile() then
      ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "NoConfirmTips_CanDownloadInMobile")
    else
      ReportManager:ReportDownloadResourceWithUI(iConfigUID, sDesc, lTotalBytes, lDownloadedBytes, "NoConfirmTips")
    end
    ConfirmDownloadResource()
  end
end

function DownloadManager:AddDownloadResourceWithUIConfig(iBatchID, stDownloadResourceConfig)
  if iBatchID == nil or stDownloadResourceConfig == nil then
    return
  end
  local stDownloadResourceConfigOri = self:GetDownloadResourceWithUIConfig(iBatchID)
  if stDownloadResourceConfigOri ~= nil then
    log.error("DownloadManager:AddDownloadResourceWithUIConfig Already Exist: " .. iBatchID)
    return
  end
  stDownloadResourceConfig.iBatchID = iBatchID
  table.insert(self.m_vDownloadResourceWithUIConfig, stDownloadResourceConfig)
  self:TryShowDownloadResourceUI()
end

function DownloadManager:TryShowDownloadResourceUI()
  if self.m_bDownloadResourceUILock then
    return
  end
  if #self.m_vDownloadResourceWithUIConfig == 0 then
    return
  end
  self.m_bDownloadResourceUILock = true
  local stDownloadResourceConfig = self.m_vDownloadResourceWithUIConfig[1]
  StackTop:Push(UIDefines.ID_FORM_DOWNLOADTIPS, {
    iBatchID = stDownloadResourceConfig.iBatchID,
    tUIExtraParam = stDownloadResourceConfig.tUIExtraParam
  })
end

function DownloadManager:TryShowDownloadResourceUIError()
  if self.m_bDownloadResourceUIErrorLock then
    return
  end
  if #self.m_vDownloadResourceRetryConfig == 0 then
    return
  end
  if self.m_eNetworkStatus == self.NetworkStatus.None then
    return
  end
  self.m_bDownloadResourceUIErrorLock = true
  local bSpaceNotEnough = false
  local lSpaceFree = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
  local lSpaceNeed = 0
  for _, stDownloadResourceConfig in ipairs(self.m_vDownloadResourceRetryConfig) do
    if stDownloadResourceConfig.lTotalBytes ~= nil and stDownloadResourceConfig.lCurBytes ~= nil then
      lSpaceNeed = stDownloadResourceConfig.lTotalBytes - stDownloadResourceConfig.lCurBytes
      if lSpaceFree < lSpaceNeed then
        bSpaceNotEnough = true
        break
      end
    end
  end
  if bSpaceNotEnough then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LowStorageWarning"),
      fContentCB = function(sContent)
        local sContentNew = string.customizereplace(sContent, {"{size1}"}, DownloadManager:GetDownloadSizeStr(lSpaceFree))
        sContentNew = string.customizereplace(sContentNew, {"{size2}"}, DownloadManager:GetDownloadSizeStr(lSpaceNeed))
        return sContentNew
      end,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  else
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsTitle9967"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent9967"),
      fAutoConfirmDelay = 15,
      funcText1 = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsButton19967"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 6,
      bLockBack = true,
      func1 = function()
        self.m_bDownloadResourceUIErrorLock = false
        self:RetryDownloadResource()
      end,
      func2 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end
end

function DownloadManager:HideShowDownloadResourceUI()
  self.m_bDownloadResourceUILock = false
end

function DownloadManager:GetDownloadResourceWithUIConfig(iBatchID)
  if iBatchID == nil then
    return nil
  end
  for i = 1, #self.m_vDownloadResourceWithUIConfig do
    local stDownloadResourceConfig = self.m_vDownloadResourceWithUIConfig[i]
    if stDownloadResourceConfig.iBatchID == iBatchID then
      return stDownloadResourceConfig
    end
  end
  return nil
end

function DownloadManager:RemoveDownloadResourceWithUIConfig(iBatchID)
  if iBatchID == nil then
    return
  end
  for i = 1, #self.m_vDownloadResourceWithUIConfig do
    local stDownloadResourceConfig = self.m_vDownloadResourceWithUIConfig[i]
    if stDownloadResourceConfig.iBatchID == iBatchID then
      table.remove(self.m_vDownloadResourceWithUIConfig, i)
      break
    end
  end
end

function DownloadManager:OnDownloadUIManualClosed(stInfo)
  if stInfo == nil or stInfo.iBatchID == nil then
    return
  end
  local iBatchID = stInfo.iBatchID
  for i = 1, #self.m_vDownloadResourceWithUIConfig do
    local stDownloadResourceConfig = self.m_vDownloadResourceWithUIConfig[i]
    if stDownloadResourceConfig.iBatchID == iBatchID then
      stDownloadResourceConfig.fStart = nil
      stDownloadResourceConfig.fProgress = nil
      stDownloadResourceConfig.fComplete = nil
      break
    end
  end
end

function DownloadManager:OnTaskGetListSC(stQuestGetListSC)
  self.m_vTaskDownloadResourceAll = {}
  local iCount = 0
  local configInstance = ConfigManager:GetConfigInsByName("TaskResourceDownload")
  for _, v in pairs(stQuestGetListSC.vQuest) do
    local tConfigTaskResourceDownload = configInstance:GetValue_ByTaskID(v.iId)
    if not tConfigTaskResourceDownload:GetError() and tConfigTaskResourceDownload.m_TaskTag ~= self.TaskTag.Newbie and tConfigTaskResourceDownload.m_TaskTag ~= self.TaskTag.Ignore then
      iCount = iCount + 1
      local mProgress = {}
      local vResourcePackageInfo = tConfigTaskResourceDownload.m_ResourcePackage
      for i = 1, vResourcePackageInfo.Length do
        local stResourcePackageInfo = vResourcePackageInfo[i - 1]
        if v.iState == MTTDProto.QuestState_Doing then
          mProgress[stResourcePackageInfo[0]] = {
            lCurBytes = 0,
            lTotalBytes = 0,
            fProgress = 0
          }
        else
          mProgress[stResourcePackageInfo[0]] = {
            lCurBytes = 0,
            lTotalBytes = 0,
            fProgress = 1
          }
        end
      end
      self.m_vTaskDownloadResourceAll[iCount] = {
        iID = v.iId,
        tConfig = tConfigTaskResourceDownload,
        iState = v.iState,
        mProgress = mProgress
      }
    end
  end
  for _, iQuestId in pairs(stQuestGetListSC.vOver) do
    local tConfigTaskResourceDownload = configInstance:GetValue_ByTaskID(iQuestId)
    if not tConfigTaskResourceDownload:GetError() and tConfigTaskResourceDownload.m_TaskTag ~= self.TaskTag.Newbie and tConfigTaskResourceDownload.m_TaskTag ~= self.TaskTag.Ignore then
      iCount = iCount + 1
      local mProgress = {}
      local vResourcePackageInfo = tConfigTaskResourceDownload.m_ResourcePackage
      for i = 1, vResourcePackageInfo.Length do
        local stResourcePackageInfo = vResourcePackageInfo[i - 1]
        mProgress[stResourcePackageInfo[0]] = {
          lCurBytes = 0,
          lTotalBytes = 0,
          fProgress = 1
        }
      end
      self.m_vTaskDownloadResourceAll[iCount] = {
        iID = iQuestId,
        tConfig = tConfigTaskResourceDownload,
        iState = MTTDProto.QuestState_Over,
        mProgress = mProgress
      }
    end
  end
end

function DownloadManager:GetTaskDownloadResourceAll()
  if self.m_vTaskDownloadResourceAll == nil then
    return {}
  end
  local vTaskDownloadResourceAllTmp = {}
  local iCount = 0
  for i, v in pairs(self.m_vTaskDownloadResourceAll) do
    local bAdd = true
    local tConfigTaskResourceDownload = v.tConfig
    if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Activity and not self:TaskDownloadActivityCanShow(v.iID) then
      bAdd = false
    end
    if bAdd then
      iCount = iCount + 1
      vTaskDownloadResourceAllTmp[iCount] = v
    end
  end
  return vTaskDownloadResourceAllTmp
end

function DownloadManager:RequestFinishResourceQuest(iID)
  local function OnFinishResourceQuestSC(stFinishResourceQuestSC, msg)
    for i, v in pairs(self.m_vTaskDownloadResourceAll) do
      if v.iID == stFinishResourceQuestSC.iQuestId then
        v.iState = MTTDProto.QuestState_Finish
        
        break
      end
    end
    self:broadcastEvent("eGameEvent_ResourceDownload_QuestFinish", {
      iID = stFinishResourceQuestSC.iQuestId
    })
  end
  
  local stFinishResourceQuestCS = MTTDProto.Cmd_Quest_FinishResourceQuest_CS()
  stFinishResourceQuestCS.iQuestId = iID
  RPCS():Quest_FinishResourceQuest(stFinishResourceQuestCS, OnFinishResourceQuestSC)
end

function DownloadManager:RequestQuestTakeReward(iID)
  if iID == nil then
    return
  end
  
  local function OnTakeRewardSC(stTakeRewardSC, msg)
    for i, v in pairs(self.m_vTaskDownloadResourceAll) do
      if v.iID == iID then
        v.iState = MTTDProto.QuestState_Over
        break
      end
    end
    self:broadcastEvent("eGameEvent_ResourceDownload_QuestTakeReward", {
      vReward = stTakeRewardSC.vReward
    })
  end
  
  local stTakeRewardCS = MTTDProto.Cmd_Quest_TakeReward_CS()
  stTakeRewardCS.iQuestType = MTTDProto.QuestType_Resource
  stTakeRewardCS.vQuestId = {iID}
  RPCS():Quest_TakeReward(stTakeRewardCS, OnTakeRewardSC)
end

function DownloadManager:SetTaskDownloadProgress(iTaskID, sPackageName, lCurBytes, lTotalBytes, fProgress)
  for i, v in pairs(self.m_vTaskDownloadResourceAll) do
    if v.iID == iTaskID then
      local bComplete = true
      for sPackageNameTmp, stProgressInfo in pairs(v.mProgress) do
        if sPackageNameTmp == sPackageName then
          stProgressInfo.lCurBytes = lCurBytes
          stProgressInfo.lTotalBytes = lTotalBytes
          stProgressInfo.fProgress = fProgress
        end
        if stProgressInfo.fProgress ~= 1 then
          bComplete = false
        end
      end
      if bComplete then
        if v.iState == MTTDProto.QuestState_Doing then
          self:RequestFinishResourceQuest(v.iID)
          break
        end
        self:broadcastEvent("eGameEvent_ResourceDownload_QuestFinish", {iID = iTaskID})
      end
      break
    end
  end
end

function DownloadManager:GetFileInfoListShouldDownload()
  return DownloadResource:GetFileInfoListShouldDownload()
end

function DownloadManager:GetFileInfoListShouldDownloadAll()
  return DownloadResource:GetFileInfoListShouldDownloadAll()
end

function DownloadManager:DownloadAddResAll_Single(tConfigTaskResourceDownload, mFilePathIncluded, lFileSizeIncluded)
  local iTaskID = tConfigTaskResourceDownload.m_TaskID
  local stDownloadAddResAllConfig = {
    iTaskID = iTaskID,
    bDownload = false,
    vSubConfig = {}
  }
  local bAll = false
  local bDownload = false
  if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.MainLevel then
    local iMainLevelID = tConfigTaskResourceDownload.m_TaskCondition
    bDownload = self:TaskDownloadCommonCanDownload(iTaskID) or LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, iMainLevelID)
  elseif tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Activity then
    bDownload = self:TaskDownloadCommonCanDownload(iTaskID) or self:TaskDownloadActivityCanDownload(iTaskID)
  else
    bDownload = true
  end
  stDownloadAddResAllConfig.bDownload = bDownload
  local lSpaceFree = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
  local vResourcePackageInfo = tConfigTaskResourceDownload.m_ResourcePackage
  local vResourcePackageInfoSorted = {}
  for i = 1, vResourcePackageInfo.Length do
    vResourcePackageInfoSorted[i] = vResourcePackageInfo[i - 1]
  end
  table.sort(vResourcePackageInfoSorted, function(a, b)
    return a[1] < b[1]
  end)
  for i = 1, #vResourcePackageInfoSorted do
    local stResourcePackageInfo = vResourcePackageInfoSorted[i]
    local sResourcePackageName = stResourcePackageInfo[0]
    if sResourcePackageName == ResourcePackageAllStr then
      bAll = true
      break
    end
    local stSubConfig = {
      sResourcePackageName = sResourcePackageName,
      iBatchID = -1,
      lSize = 0
    }
    table.insert(stDownloadAddResAllConfig.vSubConfig, stSubConfig)
    local iResourcePackagePriority = tConfigTaskResourceDownload.m_Priority * 100 + stResourcePackageInfo[1]
    local vPackage = {
      {
        sName = sResourcePackageName,
        eType = self.ResourcePackageType.Custom
      }
    }
    local vResourceAB, vResourceABDownloaded = self:GetResourceABList(vPackage, nil, true)
    local vResourceABReal, vResourceABDownloadedReal
    if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Newbie then
      vResourceABReal = vResourceAB
      vResourceABDownloadedReal = vResourceABDownloaded
    else
      vResourceABReal = {}
      local iCountReal = 0
      for k = 1, #vResourceAB do
        local sFilePath = vResourceAB[k]
        if not mFilePathIncluded[sFilePath] then
          mFilePathIncluded[sFilePath] = true
          iCountReal = iCountReal + 1
          vResourceABReal[iCountReal] = sFilePath
        end
      end
      vResourceABDownloadedReal = {}
      iCountReal = 0
      for k = 1, #vResourceABDownloaded do
        local sFilePath = vResourceABDownloaded[k]
        if not mFilePathIncluded[sFilePath] then
          mFilePathIncluded[sFilePath] = true
          iCountReal = iCountReal + 1
          vResourceABDownloadedReal[iCountReal] = sFilePath
        end
      end
    end
    local lTotalBytes = self:GetResourceABListTotalBytes(vResourceABReal)
    local lDownloadedBytes = self:GetResourceABListDownloadedBytes(vResourceABReal)
    local lRemainBytes = lTotalBytes - lDownloadedBytes
    local lTotalBytesBase = self:GetResourceABListTotalBytes(vResourceABDownloadedReal)
    
    local function OnDownloadPackageStart(curBytes, totalBytes)
      curBytes = lTotalBytesBase + curBytes
      totalBytes = lTotalBytesBase + totalBytes
      log.info(string.format("DownloadAddResAll_Single %s: ResourcePackageName %s, Download Start %s", iTaskID, sResourcePackageName, self:GetDownloadProgressStr(curBytes, totalBytes)))
      stSubConfig.lSize = totalBytes - curBytes
      self:SetTaskDownloadProgress(iTaskID, sResourcePackageName, curBytes, totalBytes, 0)
      if self.m_bDownloadAddResAllInit then
        local lSpaceFreeTmp = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
        if lSpaceFreeTmp < stSubConfig.lSize then
          self:PauseDownloadAddResAll()
        end
        if stDownloadAddResAllConfig.bDownload == false then
          CS.TGRPDownloader.PauseDownload(stSubConfig.iBatchID)
        end
        if self.m_eNetworkStatus ~= self.NetworkStatus.Wifi and not self:CanDownloadInMobile() then
          CS.TGRPDownloader.PauseDownload(stSubConfig.iBatchID)
        end
        if not ActivityManager:IsOpenBackgroundDownloadAllResource() then
          CS.TGRPDownloader.PauseDownload(stSubConfig.iBatchID)
        end
      end
    end
    
    local function OnDownloadPackageProgress(curBytes, totalBytes, speed)
      curBytes = lTotalBytesBase + curBytes
      totalBytes = lTotalBytesBase + totalBytes
      log.info(string.format("DownloadAddResAll_Single %s: ResourcePackageName %s, Download Progress %s", iTaskID, sResourcePackageName, self:GetDownloadProgressStr(curBytes, totalBytes)))
      stSubConfig.lSize = totalBytes - curBytes
      self:SetTaskDownloadProgress(iTaskID, sResourcePackageName, curBytes, totalBytes, 0)
    end
    
    local function OnDownloadPackageComplete(ret)
      stSubConfig.iBatchID = nil
      if ret then
        log.info(string.format("DownloadAddResAll_Single %s: ResourcePackageName %s, Download Complete", iTaskID, sResourcePackageName))
        stSubConfig.lSize = 0
        self:SetTaskDownloadProgress(iTaskID, sResourcePackageName, lTotalBytesBase + lTotalBytes, lTotalBytesBase + lTotalBytes, 1)
      else
        log.error(string.format("DownloadAddResAll_Single %s: ResourcePackageName %s, Download Fail", iTaskID, sResourcePackageName))
      end
    end
    
    log.info(string.format("DownloadAddResAll_Single %s: ResourcePackageName %s, Priority %d, Total %.02f MB, Left %.02f MB", iTaskID, sResourcePackageName, iResourcePackagePriority, (lTotalBytes + lTotalBytesBase) / 1024 / 1024, (lTotalBytes - lDownloadedBytes) / 1024 / 1024))
    if 0 < lRemainBytes then
      self:SetTaskDownloadProgress(iTaskID, sResourcePackageName, lTotalBytesBase + lDownloadedBytes, lTotalBytesBase + lTotalBytes, 0)
      local iBatchID = CS.TGRPDownloader.DownloadResListWithDescNoStart(vResourceABReal, sResourcePackageName, OnDownloadPackageComplete, OnDownloadPackageStart, OnDownloadPackageProgress, iResourcePackagePriority)
      stSubConfig.iBatchID = iBatchID
      stSubConfig.lSize = lRemainBytes
      lFileSizeIncluded = lFileSizeIncluded + lRemainBytes
      if bDownload and lSpaceFree >= lFileSizeIncluded then
        CS.TGRPDownloader.StartDownload(iBatchID)
      end
    else
      self:SetTaskDownloadProgress(iTaskID, sResourcePackageName, lTotalBytesBase + lTotalBytes, lTotalBytesBase + lTotalBytes, 1)
    end
  end
  if not bAll then
    table.insert(self.m_vDownloadAddResAllConfig, stDownloadAddResAllConfig)
  end
  return lFileSizeIncluded
end

function DownloadManager:DownloadAddResAll_SingleIgnore(tConfigTaskResourceDownload, mFilePathIncluded)
  local vResourcePackageInfo = tConfigTaskResourceDownload.m_ResourcePackage
  local vResourcePackageInfoSorted = {}
  for i = 1, vResourcePackageInfo.Length do
    vResourcePackageInfoSorted[i] = vResourcePackageInfo[i - 1]
  end
  table.sort(vResourcePackageInfoSorted, function(a, b)
    return a[1] < b[1]
  end)
  for i = 1, #vResourcePackageInfoSorted do
    local stResourcePackageInfo = vResourcePackageInfoSorted[i]
    local sResourcePackageName = stResourcePackageInfo[0]
    if sResourcePackageName == ResourcePackageAllStr then
      break
    end
    local vPackage = {
      {
        sName = sResourcePackageName,
        eType = self.ResourcePackageType.Custom
      }
    }
    local vResourceAB, vResourceABDownloaded = self:GetResourceABList(vPackage, nil, true)
    for k = 1, #vResourceAB do
      local sFilePath = vResourceAB[k]
      if not mFilePathIncluded[sFilePath] then
        mFilePathIncluded[sFilePath] = true
      end
    end
    for k = 1, #vResourceABDownloaded do
      local sFilePath = vResourceABDownloaded[k]
      if not mFilePathIncluded[sFilePath] then
        mFilePathIncluded[sFilePath] = true
      end
    end
  end
end

function DownloadManager:DownloadAddResAll_Other(tConfigTaskResourceDownload, mFilePathIncluded, lFileSizeIncluded)
  local iTaskID = tConfigTaskResourceDownload.m_TaskID
  local stDownloadAddResAllConfig = {
    iTaskID = iTaskID,
    bDownload = true,
    vSubConfig = {}
  }
  table.insert(self.m_vDownloadAddResAllConfig, stDownloadAddResAllConfig)
  local iResourcePackagePriority
  local vResourcePackageInfo = tConfigTaskResourceDownload.m_ResourcePackage
  for j = 1, vResourcePackageInfo.Length do
    local stResourcePackageInfo = vResourcePackageInfo[j - 1]
    local sResourcePackageName = stResourcePackageInfo[0]
    if sResourcePackageName == ResourcePackageAllStr then
      iResourcePackagePriority = tConfigTaskResourceDownload.m_Priority * 100 + stResourcePackageInfo[1]
      break
    end
  end
  local stSubConfig = {
    sResourcePackageName = ResourcePackageAllStr,
    iBatchID = -1,
    lSize = 0
  }
  table.insert(stDownloadAddResAllConfig.vSubConfig, stSubConfig)
  local lSpaceFree = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
  local vFileInfoAll = self:GetFileInfoListShouldDownloadAll()
  local vFilePathAllOther = {}
  local iCountAllOtherReal = 0
  for i = 0, vFileInfoAll.Count - 1 do
    local sFilePath = vFileInfoAll[i]:GetResPath()
    if not mFilePathIncluded[sFilePath] then
      iCountAllOtherReal = iCountAllOtherReal + 1
      vFilePathAllOther[iCountAllOtherReal] = sFilePath
    end
  end
  local lTotalBytesAllOther = self:GetResourceABListTotalBytes(vFilePathAllOther)
  local lDownloadedBytesAllOther = self:GetResourceABListDownloadedBytes(vFilePathAllOther)
  local lRemainBytesAllOther = lTotalBytesAllOther - lDownloadedBytesAllOther
  
  local function OnDownloadAllOtherStart(curBytes, totalBytes)
    log.info(string.format("DownloadAddResAll_Other %s: ResourcePackageName AllOther, Download Start %s", iTaskID, self:GetDownloadProgressStr(curBytes, totalBytes)))
    stSubConfig.lSize = totalBytes - curBytes
    self:SetTaskDownloadProgress(iTaskID, ResourcePackageAllStr, curBytes, totalBytes, 0)
    if self.m_bDownloadAddResAllInit then
      local lSpaceFreeTmp = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
      if lSpaceFreeTmp < stSubConfig.lSize then
        self:PauseDownloadAddResAll()
      end
      if stDownloadAddResAllConfig.bDownload == false then
        CS.TGRPDownloader.PauseDownload(stSubConfig.iBatchID)
      end
      if self.m_eNetworkStatus ~= self.NetworkStatus.Wifi and not self:CanDownloadInMobile() then
        CS.TGRPDownloader.PauseDownload(stSubConfig.iBatchID)
      end
      if not ActivityManager:IsOpenBackgroundDownloadAllResource() then
        CS.TGRPDownloader.PauseDownload(stSubConfig.iBatchID)
      end
    end
  end
  
  local function OnDownloadAllOtherProgress(curBytes, totalBytes, speed)
    log.info(string.format("DownloadAddResAll_Other %s: ResourcePackageName AllOther, Download Progress %s", iTaskID, self:GetDownloadProgressStr(curBytes, totalBytes)))
    stSubConfig.lSize = totalBytes - curBytes
    self:SetTaskDownloadProgress(iTaskID, ResourcePackageAllStr, curBytes, totalBytes, 0)
  end
  
  local function OnDownloadAllOtherComplete(ret)
    stSubConfig.iBatchID = nil
    if ret then
      log.info(string.format("DownloadAddResAll_Other %s: ResourcePackageName AllOther, Download Complete", iTaskID))
      stSubConfig.lSize = 0
      self:SetTaskDownloadProgress(iTaskID, ResourcePackageAllStr, lTotalBytesAllOther, lTotalBytesAllOther, 1)
    else
      log.error(string.format("DownloadAddResAll_Other %s: ResourcePackageName AllOther, Download Fail", iTaskID))
      if not ret then
        self.m_bDownloadAddResAll = false
      end
    end
  end
  
  if 0 < lRemainBytesAllOther then
    self:SetTaskDownloadProgress(iTaskID, ResourcePackageAllStr, lDownloadedBytesAllOther, lTotalBytesAllOther, 0)
    local iBatchID = CS.TGRPDownloader.DownloadResListWithDescNoStart(vFilePathAllOther, "All", OnDownloadAllOtherComplete, OnDownloadAllOtherStart, OnDownloadAllOtherProgress, iResourcePackagePriority)
    stSubConfig.iBatchID = iBatchID
    stSubConfig.lSize = lRemainBytesAllOther
    lFileSizeIncluded = lFileSizeIncluded + lRemainBytesAllOther
    if lSpaceFree >= lFileSizeIncluded then
      CS.TGRPDownloader.StartDownload(iBatchID)
    end
  else
    self:SetTaskDownloadProgress(iTaskID, ResourcePackageAllStr, lTotalBytesAllOther, lTotalBytesAllOther, 1)
  end
end

function DownloadManager:DownloadAddResAll()
  if self.m_bDownloadAddResAll then
    return
  end
  self.m_bDownloadAddResAll = true
  self.m_vDownloadAddResAllConfig = {}
  local mFilePathIncluded = {}
  local lFileSizeIncluded = 0
  local tConfigTaskResourceDownloadAll
  local vConfigTaskResourceDownload = {}
  local vConfigTaskResourceDownloadIgnore = {}
  local configInstance = ConfigManager:GetConfigInsByName("TaskResourceDownload")
  local iNewbieMainLevelID = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("ResourceTaskTagMainLevelID").m_Value)
  local bNewbie = not LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, iNewbieMainLevelID)
  for _, tConfigTaskResourceDownload in pairs(configInstance:GetAll()) do
    if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Newbie then
      if bNewbie then
        vConfigTaskResourceDownload[#vConfigTaskResourceDownload + 1] = tConfigTaskResourceDownload
      end
    elseif tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Ignore then
      vConfigTaskResourceDownloadIgnore[#vConfigTaskResourceDownloadIgnore + 1] = tConfigTaskResourceDownload
    else
      vConfigTaskResourceDownload[#vConfigTaskResourceDownload + 1] = tConfigTaskResourceDownload
    end
  end
  table.sort(vConfigTaskResourceDownload, function(a, b)
    return a.m_Priority < b.m_Priority
  end)
  for i = 1, #vConfigTaskResourceDownload do
    local tConfigTaskResourceDownload = vConfigTaskResourceDownload[i]
    local vResourcePackageInfo = tConfigTaskResourceDownload.m_ResourcePackage
    for j = 1, vResourcePackageInfo.Length do
      local stResourcePackageInfo = vResourcePackageInfo[j - 1]
      local sResourcePackageName = stResourcePackageInfo[0]
      if sResourcePackageName == ResourcePackageAllStr then
        tConfigTaskResourceDownloadAll = tConfigTaskResourceDownload
        break
      end
    end
    lFileSizeIncluded = self:DownloadAddResAll_Single(tConfigTaskResourceDownload, mFilePathIncluded, lFileSizeIncluded)
  end
  if tConfigTaskResourceDownloadAll then
    for i = 1, #vConfigTaskResourceDownloadIgnore do
      local tConfigTaskResourceDownload = vConfigTaskResourceDownloadIgnore[i]
      self:DownloadAddResAll_SingleIgnore(tConfigTaskResourceDownload, mFilePathIncluded)
    end
    self:DownloadAddResAll_Other(tConfigTaskResourceDownloadAll, mFilePathIncluded, lFileSizeIncluded)
  end
  self.m_bDownloadAddResAllInit = true
  if not ActivityManager:IsOpenBackgroundDownloadAllResource() or self.m_eNetworkStatus ~= self.NetworkStatus.Wifi and not self:CanDownloadInMobile() then
    self:PauseDownloadAddResAll()
  end
end

function DownloadManager:PauseDownloadAddResAll()
  for _, stConfig in ipairs(self.m_vDownloadAddResAllConfig) do
    if stConfig.bDownload then
      for _, stSubConfig in ipairs(stConfig.vSubConfig) do
        if stSubConfig.iBatchID and stSubConfig.iBatchID >= 0 then
          CS.TGRPDownloader.PauseDownload(stSubConfig.iBatchID)
        end
      end
    end
  end
end

function DownloadManager:ResumeDownloadAddResAll()
  local lFileSizeIncluded = 0
  local lSpaceFree = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
  for _, stConfig in ipairs(self.m_vDownloadAddResAllConfig) do
    for _, stSubConfig in ipairs(stConfig.vSubConfig) do
      if stSubConfig.iBatchID and 0 <= stSubConfig.iBatchID then
        lFileSizeIncluded = lFileSizeIncluded + stSubConfig.lSize
        if lSpaceFree < lFileSizeIncluded then
          return
        end
        if stConfig.bDownload then
          CS.TGRPDownloader.StartDownload(stSubConfig.iBatchID)
        end
      end
    end
  end
end

function DownloadManager:IsAutoDownloadAddResAllSingle(iTaskID)
  for _, stConfig in ipairs(self.m_vDownloadAddResAllConfig) do
    if stConfig.iTaskID == iTaskID then
      return stConfig.bDownload
    end
  end
  return false
end

function DownloadManager:ResumeDownloadAddResAllSingle(iTaskID)
  local bResume = false
  for _, stConfig in ipairs(self.m_vDownloadAddResAllConfig) do
    if stConfig.iTaskID == iTaskID then
      if not stConfig.bDownload then
        stConfig.bDownload = true
        bResume = true
      end
      break
    end
  end
  if bResume then
    if ActivityManager:IsOpenBackgroundDownloadAllResource() and (self.m_eNetworkStatus == self.NetworkStatus.Wifi or self:CanDownloadInMobile()) then
      self:ResumeDownloadAddResAll()
    end
    self:broadcastEvent("eGameEvent_ResourceDownload_QuestRefresh", {iID = iTaskID})
  end
end

function DownloadManager:ReserveDownloadByManual(iTaskID)
  LocalDataManager:SetIntSimple("DownloadAddResAllSingle_Manual" .. iTaskID, 1)
  self:ResumeDownloadAddResAllSingle(iTaskID)
end

function DownloadManager:ReserveDownloadByMainLevelID(iMainLevelID)
  for _, stConfig in pairs(self.m_vDownloadAddResAllConfig) do
    local tConfigTaskResourceDownload = ConfigManager:GetConfigInsByName("TaskResourceDownload"):GetValue_ByTaskID(stConfig.iTaskID)
    if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.MainLevel and tConfigTaskResourceDownload.m_TaskCondition == iMainLevelID then
      self:ResumeDownloadAddResAllSingle(stConfig.iTaskID)
      break
    end
  end
end

function DownloadManager:TaskDownloadActivityCanShow(iTaskID)
  local iActivityID
  local tConfigTaskResourceDownload = ConfigManager:GetConfigInsByName("TaskResourceDownload"):GetValue_ByTaskID(iTaskID)
  if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Activity then
    iActivityID = tConfigTaskResourceDownload.m_ActivityID
  end
  if iActivityID == nil then
    return false
  end
  local allGachaPushFace = ActivityManager:GetActivityListByType(MTTD.ActivityType_GachaJump)
  for _, act in pairs(allGachaPushFace) do
    if act:GetReserverDownloadActivityID() == iActivityID then
      return true
    end
  end
  local eOpenState, _ = HeroActivityManager:GetActOpenState(iActivityID)
  if eOpenState == HeroActivityManager.ActOpenState.Normal or eOpenState == HeroActivityManager.ActOpenState.WaitingClose then
    return true
  end
  return false
end

function DownloadManager:TaskDownloadCommonCanDownload(iTaskID)
  local iCanDownload = LocalDataManager:GetIntSimple("DownloadAddResAllSingle_Manual" .. iTaskID, 0)
  if iCanDownload == 1 then
    return true
  end
  return false
end

function DownloadManager:TaskDownloadActivityCanDownload(iTaskID)
  local iActivityID
  local tConfigTaskResourceDownload = ConfigManager:GetConfigInsByName("TaskResourceDownload"):GetValue_ByTaskID(iTaskID)
  if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Activity then
    iActivityID = tConfigTaskResourceDownload.m_ActivityID
  end
  if iActivityID == nil then
    return false
  end
  local allGachaPushFace = ActivityManager:GetActivityListByType(MTTD.ActivityType_GachaJump)
  for _, act in pairs(allGachaPushFace) do
    if act:GetReserverDownloadActivityID() == iActivityID then
      local iCanDownload = LocalDataManager:GetIntSimple("DownloadAddResAllSingle_Activity" .. iActivityID, 0)
      if iCanDownload == 1 then
        return true
      end
    end
  end
  local eOpenState, _ = HeroActivityManager:GetActOpenState(iActivityID)
  if eOpenState == HeroActivityManager.ActOpenState.Normal or eOpenState == HeroActivityManager.ActOpenState.WaitingClose then
    return true
  end
  return false
end

function DownloadManager:ReserveDownloadByActivityID(iActivityID)
  for _, stConfig in pairs(self.m_vDownloadAddResAllConfig) do
    local tConfigTaskResourceDownload = ConfigManager:GetConfigInsByName("TaskResourceDownload"):GetValue_ByTaskID(stConfig.iTaskID)
    if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Activity and tConfigTaskResourceDownload.m_ActivityID == iActivityID then
      self:ResumeDownloadAddResAllSingle(stConfig.iTaskID)
      break
    end
  end
  LocalDataManager:SetIntSimple("DownloadAddResAllSingle_Activity" .. iActivityID, 1)
end

function DownloadManager:TaskDownloadActivityUpdateState()
  for _, stConfig in pairs(self.m_vDownloadAddResAllConfig) do
    if stConfig.bDownload == false then
      local tConfigTaskResourceDownload = ConfigManager:GetConfigInsByName("TaskResourceDownload"):GetValue_ByTaskID(stConfig.iTaskID)
      if tConfigTaskResourceDownload.m_TaskTag == self.TaskTag.Activity and self:TaskDownloadActivityCanDownload(stConfig.iTaskID) then
        self:ResumeDownloadAddResAllSingle(stConfig.iTaskID)
      end
    end
  end
end

function DownloadManager:GetDownloadAddResAllStatus()
  local lDownloadedBytes = 0
  local lTotalBytes = 0
  local vTaskDownloadResourceAll = self:GetTaskDownloadResourceAll()
  for _, v in pairs(vTaskDownloadResourceAll) do
    for sPackageNameTmp, stProgressInfo in pairs(v.mProgress) do
      lDownloadedBytes = lDownloadedBytes + stProgressInfo.lCurBytes
      lTotalBytes = lTotalBytes + stProgressInfo.lTotalBytes
    end
  end
  return lDownloadedBytes, lTotalBytes
end

function DownloadManager:DownloadMultiLanguage(iLanguageID, fCompleteCB, fStartCB, fProgressCB)
  local function OnDownloadMultiLanguageStart(curBytes, totalBytes)
    if fStartCB then
      fStartCB(curBytes, totalBytes)
    end
  end
  
  local function OnDownloadMultiLanguageProgress(curBytes, totalBytes, speed)
    if fProgressCB then
      fProgressCB(curBytes, totalBytes, speed)
    end
  end
  
  local function OnDownloadMultiLanguageComplete(ret)
    if fCompleteCB then
      fCompleteCB(ret)
    end
  end
  
  local vPackage = {}
  local vExtraResource = {}
  local stLanguageElment = CData_MultiLanguage:GetValue_ByID(iLanguageID)
  vExtraResource[#vExtraResource + 1] = {
    sName = "AllLanguage" .. stLanguageElment.m_LanguageObject,
    eType = self.ResourceType.Language
  }
  vExtraResource[#vExtraResource + 1] = {
    sName = "AddLanguage" .. stLanguageElment.m_LanguageObject,
    eType = self.ResourceType.Language
  }
  vExtraResource[#vExtraResource + 1] = {
    sName = "LanResObj_" .. stLanguageElment.m_Translation .. "_add",
    eType = self.ResourceType.LanResObj
  }
  local iBatchID = self:DownloadResource(vPackage, vExtraResource, "MultiLan" .. tostring(iLanguageID), OnDownloadMultiLanguageStart, OnDownloadMultiLanguageProgress, OnDownloadMultiLanguageComplete, 0, self.NetworkStatus.Mobile)
  return iBatchID
end

function DownloadManager:DownloadMultiLanguageVoice(iLanguageID, fCompleteCB, fStartCB, fProgressCB)
  local function OnDownloadMultiLanguageStart(curBytes, totalBytes)
    if fStartCB then
      fStartCB(curBytes, totalBytes)
    end
  end
  
  local function OnDownloadMultiLanguageProgress(curBytes, totalBytes, speed)
    if fProgressCB then
      fProgressCB(curBytes, totalBytes, speed)
    end
  end
  
  local function OnDownloadMultiLanguageComplete(ret)
    if fCompleteCB then
      fCompleteCB(ret)
    end
  end
  
  local stLanguageElment = CData_MultiLanguage:GetValue_ByID(iLanguageID)
  local sLabelName = "multilanvo_" .. stLanguageElment.m_SoundType
  return CS.TGRPDownloader.DownloadResByLabel(sLabelName, OnDownloadMultiLanguageComplete, OnDownloadMultiLanguageStart, OnDownloadMultiLanguageProgress, 0)
end

function DownloadManager:GetTotalBytesByLabel(sLabelName)
  return CS.TGRPDownloader.GetTotalBytesByLabel(sLabelName)
end

function DownloadManager:GetDownloadedBytesByLabel(sLabelName)
  return CS.TGRPDownloader.GetDownloadedBytesByLabel(sLabelName)
end

function DownloadManager:DeleteMultiLanguageVoice(iLanguageID)
  local stLanguageElment = CData_MultiLanguage:GetValue_ByID(iLanguageID)
  local sLabelName = "multilanvo_" .. stLanguageElment.m_SoundType
  CS.TGRPDownloader.DeleteResByLabel(sLabelName)
end

function DownloadManager:SetThrottleNetSpeed(iSpeed)
  CS.TGRPDownloader.SetThrottleNetSpeed(iSpeed)
end

function DownloadManager:InitDebugOptions()
  if not UILuaHelper.IsAbleDebugger() then
    return
  end
  SROptionsModify.AddSROptionMethod("设置下载限速10MB/s", function()
    self:SetThrottleNetSpeed(10485760)
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("设置下载限速1MB/s", function()
    self:SetThrottleNetSpeed(1048576)
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("解除下载限速", function()
    self:SetThrottleNetSpeed(0)
  end, "Debug", 0)
end

function DownloadManager:OnUpdate(dt)
  self:TryShowDownloadResourceUI()
  self:CheckNetworkStatus()
  self:TryShowDownloadResourceUIError()
  self:TaskDownloadActivityUpdateState()
end

function DownloadManager:OnEventNetworkGameReconnect()
  log.info("DownloadManager:OnEventNetworkGameReconnect")
end

function DownloadManager:RetryDownloadResource()
  local vDownloadResourceRetryConfig = self.m_vDownloadResourceRetryConfig
  self.m_vDownloadResourceAllConfig = {}
  self.m_vDownloadResourceRetryConfig = {}
  for _, stDownloadResourceConfig in ipairs(vDownloadResourceRetryConfig) do
    local vPackage = stDownloadResourceConfig.vPackage
    local vExtraResource = stDownloadResourceConfig.vExtraResource
    local vResourceABSpecified = stDownloadResourceConfig.vResourceABSpecified
    local sDesc = stDownloadResourceConfig.sDesc
    local fStart = stDownloadResourceConfig.fStart
    local fProgress = stDownloadResourceConfig.fProgress
    local fComplete = stDownloadResourceConfig.fComplete
    local iPriority = stDownloadResourceConfig.iPriority
    local eNetworkStatus = stDownloadResourceConfig.eNetworkStatus
    if stDownloadResourceConfig.bUI then
      local tUIExtraParam = stDownloadResourceConfig.tUIExtraParam
      tUIExtraParam.bHideMobileTips = true
      tUIExtraParam.iBatchIDPre = stDownloadResourceConfig.iBatchID
      self:DownloadResourceWithUI(vPackage, vExtraResource, sDesc, fStart, fProgress, fComplete, iPriority, eNetworkStatus, tUIExtraParam, vResourceABSpecified)
    else
      self:DownloadResource(vPackage, vExtraResource, sDesc, fStart, fProgress, fComplete, iPriority, eNetworkStatus, vResourceABSpecified)
    end
  end
end

function DownloadManager:CheckNetworkStatus()
  local eNetworkStatusPre = self.m_eNetworkStatus
  if CS.DeviceUtil.IsWIFIConnected() then
    if eNetworkStatusPre ~= self.NetworkStatus.Wifi then
      self.m_eNetworkStatus = self.NetworkStatus.Wifi
      ReportManager:ReportNetworkStatus(self.m_eNetworkStatus)
      if eNetworkStatusPre == self.NetworkStatus.Mobile then
        if not self:CanDownloadInMobile() then
          self:ResumeDownloadAddResAll()
        end
      elseif eNetworkStatusPre == self.NetworkStatus.None and self.m_bDownloadAddResAllInit then
        self:DownloadAddResAll()
      end
    end
  elseif CS.DeviceUtil.IsMobileConnected() then
    if eNetworkStatusPre ~= self.NetworkStatus.Mobile then
      self.m_eNetworkStatus = self.NetworkStatus.Mobile
      ReportManager:ReportNetworkStatus(self.m_eNetworkStatus)
      if eNetworkStatusPre == self.NetworkStatus.Wifi then
        if not self:CanDownloadInMobile() then
          self:PauseDownloadAddResAll()
        end
      elseif eNetworkStatusPre == self.NetworkStatus.None and self.m_bDownloadAddResAllInit then
        self:DownloadAddResAll()
      end
    end
  else
    self.m_eNetworkStatus = self.NetworkStatus.None
  end
end

function DownloadManager:CanDownloadInMobile()
  if self.m_bDownloadInMobile == nil then
    local iDownloadInMobile = LocalDataManager:GetIntSimple("DownloadInMobile", 0)
    self.m_bDownloadInMobile = iDownloadInMobile == 1
  end
  return self.m_bDownloadInMobile
end

function DownloadManager:SwitchDownloadInMobile()
  self.m_bDownloadInMobile = not self.m_bDownloadInMobile
  LocalDataManager:SetIntSimple("DownloadInMobile", self.m_bDownloadInMobile and 1 or 0)
  ReportManager:ReportSettings_DownloadInMobile(self.m_bDownloadInMobile)
  if self.m_eNetworkStatus ~= self.NetworkStatus.Wifi then
    if self.m_bDownloadInMobile then
      self:ResumeDownloadAddResAll()
    else
      self:PauseDownloadAddResAll()
    end
  end
end

function DownloadManager:CanShowDownloadResourceUIMobileTips()
  if self.m_iDownloadResourceWithUIMobileTipsTime == nil then
    self.m_iDownloadResourceWithUIMobileTipsTime = LocalDataManager:GetIntSimple("DownloadResourceWithUIMobileTips", 0)
  end
  local iTimeCur = TimeUtil:GetServerTimeS()
  return iTimeCur >= self.m_iDownloadResourceWithUIMobileTipsTime
end

function DownloadManager:SetDownloadResourceUIMobileTips()
  local iTimeNextDay = TimeUtil:GetServerNextCommonResetTime()
  self.m_iDownloadResourceWithUIMobileTipsTime = iTimeNextDay
  LocalDataManager:SetIntSimple("DownloadResourceWithUIMobileTips", iTimeNextDay)
end

function DownloadManager:CanShowDownloadTriggerTips()
  if self.m_iDownloadTriggerTipsTime == nil then
    self.m_iDownloadTriggerTipsTime = LocalDataManager:GetIntSimple("DownloadTriggerTips", 0)
  end
  local iTimeCur = TimeUtil:GetServerTimeS()
  return iTimeCur >= self.m_iDownloadTriggerTipsTime
end

function DownloadManager:SetDownloadTriggerTips()
  local iTimeNextDay = TimeUtil:GetServerNextCommonResetTime()
  self.m_iDownloadTriggerTipsTime = iTimeNextDay
  LocalDataManager:SetIntSimple("DownloadTriggerTips", iTimeNextDay)
end

function DownloadManager:SetMiniPatchConfig(sMiniPatchVersion, bMiniPatchBackground, bMiniPatchNeedRestart)
  self.m_sMiniPatchVersion = sMiniPatchVersion
  self.m_bMiniPatchBackground = bMiniPatchBackground
  self.m_bMiniPatchNeedRestart = bMiniPatchNeedRestart
end

function DownloadManager:GetMiniPatchVersion()
  return self.m_sMiniPatchVersion
end

function DownloadManager:IsMiniPatchBackground()
  return self.m_bMiniPatchBackground
end

function DownloadManager:IsMiniPatchNeedRestart()
  return self.m_bMiniPatchNeedRestart
end

function DownloadManager:NeedRestartOnUpgradePatch()
  return true
end

function DownloadManager:GetBStr()
  if self.m_sBStr == nil then
    self.m_sBStr = CS.ConfFact.LangFormat4DataInit("Byte")
  end
  return self.m_sBStr
end

function DownloadManager:GetKBStr()
  if self.m_sKBStr == nil then
    self.m_sKBStr = CS.ConfFact.LangFormat4DataInit("KByte")
  end
  return self.m_sKBStr
end

function DownloadManager:GetMBStr()
  if self.m_sMBStr == nil then
    self.m_sMBStr = CS.ConfFact.LangFormat4DataInit("MByte")
  end
  return self.m_sMBStr
end

function DownloadManager:GetGBStr()
  if self.m_sGBStr == nil then
    self.m_sGBStr = CS.ConfFact.LangFormat4DataInit("GByte")
  end
  return self.m_sGBStr
end

function DownloadManager:GetDownloadSizeStr(lSizeBytes)
  local lSizeKB = lSizeBytes / 1024
  if lSizeKB < 1024 then
    return string.format("%.1f%s", lSizeKB, self:GetKBStr())
  end
  local lSizeMB = lSizeKB / 1024
  if lSizeMB < 1024 then
    return string.format("%.1f%s", lSizeMB, self:GetMBStr())
  end
  return string.format("%.1f%s", lSizeMB / 1024, self:GetGBStr())
end

function DownloadManager:GetDownloadProgressStr(lCurBytes, lTotalBytes)
  local sProgress
  if lTotalBytes < 102.4 then
    local sBStr = self:GetBStr()
    sProgress = string.format("%d %s / %d %s", lCurBytes, sBStr, lTotalBytes, sBStr)
  elseif lTotalBytes < 104857.6 then
    local sKBStr = self:GetKBStr()
    sProgress = string.format("%.02f %s / %.02f %s", lCurBytes / 1024, sKBStr, lTotalBytes / 1024, sKBStr)
  else
    local sMBStr = self:GetMBStr()
    sProgress = string.format("%.02f %s / %.02f %s", lCurBytes / 1024 / 1024, sMBStr, lTotalBytes / 1024 / 1024, sMBStr)
  end
  return sProgress
end

return DownloadManager
