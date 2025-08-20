local BaseManager = require("Manager/Base/BaseManager")
local ReportManager = class("ReportManager", BaseManager)
local MSDKManagerInstance = CS.MSDKManager.Instance

function ReportManager:OnCreate()
  self.m_cacheReportData = {}
  self.m_loginTime = 0
  self.m_bInitNetwork = false
end

function ReportManager:OnInitNetwork()
  self.m_bInitNetwork = true
end

function ReportManager:GetLoginTime()
  return self.m_loginTime or 0
end

function ReportManager:SetLoginTime()
  self.m_loginTime = TimeUtil:GetServerTimeS()
  local report_time_interval = tonumber(ConfigManager:GetGlobalSettingsByKey("iReportInterval") or 60)
  TimeService:SetTimer(report_time_interval, -1, function()
    self:ReportSystemInfo()
  end)
end

function ReportManager:ReportSystemOpen(systemId, openTime, extData)
  local openInfo = {}
  if not self.m_cacheReportData[systemId] then
    self.m_cacheReportData[systemId] = {}
  end
  openInfo.open_time = openTime
  openInfo.ext_data = extData
  self.m_cacheReportData[systemId][openTime] = openInfo
end

function ReportManager:ReportSystemClose(systemId, openTime)
  if not self.m_cacheReportData[systemId] then
    self.m_cacheReportData[systemId] = {}
    self.m_cacheReportData[systemId][openTime] = {}
  elseif not self.m_cacheReportData[systemId][openTime] then
    self.m_cacheReportData[systemId][openTime] = {}
  end
  self.m_cacheReportData[systemId][openTime].close_time = TimeUtil:GetServerTimeS()
end

function ReportManager:ReportSystemInfo()
  local systemsInfo = {}
  for systemId, v in pairs(self.m_cacheReportData) do
    local info = {}
    info.enter_num = 0
    info.online_time = 0
    info.login_time = self.m_loginTime
    info.log_details = {}
    info.module_id = systemId
    info.report_time = TimeUtil:GetServerTimeS()
    for time, n in pairs(v) do
      local open_time = n.open_time
      local close_time = n.close_time
      local add_open, add_close
      if open_time then
        info.enter_num = info.enter_num + 1
      else
        open_time = time
        add_open = true
      end
      if not close_time then
        close_time = open_time
        add_close = true
      end
      info.online_time = info.online_time + close_time - open_time
      info.log_details[tostring(table.getn(info.log_details) + 1)] = {
        open_time = open_time,
        close_time = close_time,
        add_open = add_open,
        add_close = add_close,
        ext_data = n.ext_data
      }
    end
    systemsInfo[tostring(systemId)] = info
  end
  if 0 < table.getn(systemsInfo) then
    for i, info in pairs(systemsInfo) do
      local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Module_log)
      stReportData.Enter_num = info.enter_num
      stReportData.Online_time = info.online_time
      stReportData.Login_time = info.login_time
      stReportData.Module_id = info.module_id
      stReportData.Report_time = info.report_time
      local jsonData = info.log_details
      if type(jsonData) == "table" then
        jsonData = json.encode(jsonData)
      end
      stReportData.Log_details = jsonData
      CS.ReportService.Instance:Report(stReportData)
      CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
    end
  end
  self.m_cacheReportData = {}
end

function ReportManager:ReportGachaPushFace(iActivityId, planner_comment, jumpType, isJump, popTime, openTime)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.C_universal_popup)
  stReportData.Activity_id = iActivityId
  stReportData.Planner_comment = planner_comment
  stReportData.Jump_type = jumpType
  stReportData.IsJump = isJump
  stReportData.PopTime = popTime
  stReportData.Open_time = openTime
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportFirstPackageInfo(bPAD)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_firstpack)
  stReportData.Is_pad = bPAD
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:CanReportLoginProcess()
  if self.m_bCanReportLoginProcess == nil then
    local iReportTime = 0
    local iReportCount = 0
    local sReportInfo = CS.UnityEngine.PlayerPrefs.GetString("LoginProcessReport", "")
    if sReportInfo ~= "" then
      local vReportInfo = string.split(sReportInfo, "_")
      iReportTime = tonumber(vReportInfo[1])
      iReportCount = tonumber(vReportInfo[2])
    end
    local iCurTime = os.time()
    if iReportTime < iCurTime then
      self.m_bCanReportLoginProcess = true
      iReportCount = 0
    elseif iReportCount < 3 then
      self.m_bCanReportLoginProcess = true
    else
      self.m_bCanReportLoginProcess = false
    end
    if self.m_bCanReportLoginProcess then
      local tDateNextDay = os.date("*t", iCurTime + 86400)
      tDateNextDay.hour = 0
      tDateNextDay.min = 0
      tDateNextDay.sec = 0
      local iNextDayTime = os.time(tDateNextDay)
      CS.UnityEngine.PlayerPrefs.SetString("LoginProcessReport", iNextDayTime .. "_" .. iReportCount + 1)
    end
  end
  return self.m_bCanReportLoginProcess
end

function ReportManager:ReportLoginProcess(sJobName, sJobDetail, bImmediately)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_login_process)
  stReportData.Job_name = sJobName
  stReportData.Job_detail = sJobDetail
  if bImmediately then
    CS.ReportService.Instance:ReportImmediately(stReportData)
  else
    CS.ReportService.Instance:Report(stReportData)
  end
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportSettings_DownloadInMobile(bCanDownloadInMobile)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_settings_downloadinmobile)
  stReportData.BCanDownloadInMobile = tostring(bCanDownloadInMobile)
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportNetworkStatus(eNetworkStatus)
  if not self.m_bInitNetwork then
    return
  end
  local stNetworkStatusInfo = {}
  if eNetworkStatus == DownloadManager.NetworkStatus.Wifi then
    stNetworkStatusInfo.network_status = "wifi"
  elseif eNetworkStatus == DownloadManager.NetworkStatus.Mobile then
    stNetworkStatusInfo.network_status = "mobile"
  else
    stNetworkStatusInfo.network_status = "none"
  end
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_networkstatus)
  stReportData.Network_status = stNetworkStatusInfo.network_status
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportDownloadResourceWithUI(iUniqueID, sDesc, lTotalBytes, lDownloadedBytes, sDescExtra, iBatchId, iCostTime)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_downloadwithui)
  stReportData.Uid = iUniqueID
  stReportData.Desc = sDesc
  stReportData.Total_bytes = lTotalBytes
  stReportData.Downloaded_bytes = lDownloadedBytes
  stReportData.Desc_extra = sDescExtra
  if iBatchId == nil then
    stReportData.Batchid = -1
  else
    stReportData.Batchid = iBatchId
  end
  if iCostTime == nil then
    stReportData.Cost_time = -1
  else
    stReportData.Cost_time = iCostTime
  end
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportWithPlayerData()
  local data = {}
  data.time = os.date("%Y/%m/%d %H:%M:%S", TimeUtil:GetServerTimeS())
  data.uid = RoleManager:GetUID()
  data.zoneid = UserDataManager:GetZoneID()
  data.player_level = RoleManager:GetLevel()
  local levelMainHelper = LevelManager:GetLevelMainHelper()
  if levelMainHelper then
    data.main_story = levelMainHelper:GetCurChapterIndex(LevelManager.MainLevelSubType.MainStory)
  end
  return data
end

function ReportManager:ReportProductView(reportData)
  local data = self:ReportWithPlayerData()
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_product_view)
  stReportData.Time = data.time
  stReportData.Player_level = data.player_level
  if data.main_story then
    stReportData.Main_story = data.main_story
  end
  stReportData.StayTime = reportData.stayTime or ""
  stReportData.WindowId = reportData.windowId or ""
  stReportData.StoreName = reportData.storeName or ""
  stReportData.GiftPackType = reportData.giftPackType or ""
  stReportData.StoreId = reportData.storeId or ""
  stReportData.IGroupIndex = reportData.iGroupIndex or ""
  stReportData.ISubProductID = reportData.iSubProductID or ""
  stReportData.IActivityID = reportData.iActivityID or ""
  stReportData.IExpireTime = reportData.iExpireTime or ""
  stReportData.SGoods = reportData.sGoods or ""
  stReportData.SGoodsIndex = reportData.sGoodsIndex or ""
  stReportData.ITriggerParam = reportData.iTriggerParam or ""
  stReportData.ITotalRecharge = reportData.iTotalRecharge or ""
  stReportData.ITriggerIndex = reportData.iTriggerIndex or ""
  stReportData.StoreDes = reportData.storeDes or ""
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportProductBuyView(reportData)
  local data = self:ReportWithPlayerData()
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_product_buy_view)
  stReportData.Time = data.time
  stReportData.Player_level = data.player_level
  if data.main_story then
    stReportData.Main_story = data.main_story
  end
  stReportData.ActivityId = reportData.activityId or ""
  stReportData.StoreId = reportData.storeId or ""
  stReportData.GoodsId = reportData.goodsId or ""
  stReportData.GiftPackType = reportData.giftPackType or ""
  stReportData.GroudId = reportData.groudId or ""
  stReportData.GiftPushForm = reportData.giftPushForm or ""
  stReportData.ITriggerParam = reportData.iTriggerParam or ""
  stReportData.ITotalRecharge = reportData.iTotalRecharge or ""
  stReportData.ITriggerIndex = reportData.iTriggerIndex or ""
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportProductBuyBtn(reportData)
  local data = self:ReportWithPlayerData()
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_product_click)
  stReportData.Time = data.time
  stReportData.Player_level = data.player_level
  if data.main_story then
    stReportData.Main_story = data.main_story
  end
  stReportData.ActivityId = reportData.activityId or ""
  stReportData.StoreId = reportData.storeId or ""
  stReportData.GoodsId = reportData.goodsId or ""
  stReportData.GiftPackType = reportData.giftPackType or ""
  stReportData.GroudId = reportData.groudId or ""
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportTaskIdReperted(reportData)
  local data = self:ReportWithPlayerData()
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Task_id_repeated_error)
  stReportData.Time = data.time
  stReportData.Player_level = data.player_level
  if data.main_story then
    stReportData.Main_story = data.main_story
  end
  stReportData.SRepeatedTaskId = reportData.sRepeatedTaskId or ""
  stReportData.TaskType = reportData.taskType or ""
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportSimRoonEventError(reportData)
  local data = self:ReportWithPlayerData()
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Battle_sim_room_event_error)
  stReportData.Time = data.time
  stReportData.Player_level = data.player_level
  if data.main_story then
    stReportData.Main_story = data.main_story
  end
  stReportData.ICurEvent = reportData.iCurEvent or ""
  stReportData.IStatus = reportData.iStatus or ""
  stReportData.IRegionId = reportData.iRegionId or ""
  stReportData.IFlowId = reportData.iFlowId or ""
  stReportData.ICurOrder = reportData.iCurOrder or ""
  stReportData.IStartRegion = reportData.iStartRegion or ""
  stReportData.VChooseEvent = reportData.vChooseEvent or ""
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportAccountBindStep(reportData)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Login_step_user_account)
  stReportData.Account = reportData.account or ""
  stReportData.Event = reportData.event or ""
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportLoginProtocolStep(reportData)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Login_step_user_protocol)
  stReportData.Account = reportData.account or ""
  stReportData.Event = reportData.event or ""
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportSettingsData(settingData)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_change_settings)
  stReportData.User_quality_settings = settingData.user_quality_settings
  stReportData.User_fps_settings = settingData.user_fps_settings
  stReportData.Volume_all = settingData.volume_all
  stReportData.Volume_effect = settingData.volume_effect
  stReportData.Volume_voice = settingData.volume_voice
  stReportData.Volume_music = settingData.volume_music
  stReportData.User_language_settings = settingData.user_language_settings
  stReportData.User_voice_language = settingData.user_voice_language
  stReportData.Target_indicator = settingData.target_indicator
  stReportData.Notice_collection = settingData.notice_collection
  stReportData.Notice_mail = settingData.notice_mail
  stReportData.Notice_support = settingData.notice_support
  stReportData.No_wifi_download = settingData.no_wifi_download
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportSystemModuleOpen(moduleNameStr, paramStr)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_module_open)
  stReportData.Module_name = moduleNameStr
  if paramStr then
    stReportData.ParamStr = paramStr
  end
  stReportData.Login_time = self.m_loginTime
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportClientDebugInfo(debugInfoStr, debugInfoDescStr)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_debug_info)
  stReportData.Desc = debugInfoStr
  if debugInfoDescStr then
    stReportData.Detail_desc = debugInfoDescStr
  end
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportClientNetShowReconnect(iStatus, sDetail)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Net_show_reconnect)
  stReportData.Status = iStatus
  stReportData.Detail = sDetail
  stReportData.Login_country = CS.UserData.Instance.sLoginRoleCountry
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportFlog(flogLevel)
  if ChannelManager:IsChinaChannel() then
    CS.UI.UILuaHelper.ReportFlogCn(flogLevel)
  else
    CS.UI.UILuaHelper.ReportFlog(flogLevel)
  end
end

function ReportManager:ReportClientGlobalResEnabled(bEnabled)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(CS.ReportDataDefines.Client_useGlobal)
  stReportData.Enabled = bEnabled
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportMessage(reportDataDefine, params)
  local stReportData = CS.ReportDataPool.Instance:RequestReportDataByType(reportDataDefine)
  if params then
    for key, v in pairs(params) do
      stReportData[key] = v
    end
  end
  CS.ReportService.Instance:Report(stReportData)
  CS.ReportDataPool.Instance:ReturnReportDataByType(stReportData)
end

function ReportManager:ReportData(tag, data)
  local jsonData = data
  if type(data) == "table" then
    jsonData = json.encode(data)
  end
  MSDKManagerInstance:ReportEventByLuaJson(tag, jsonData)
end

function ReportManager:ReportTrackAttributionEvent(tag, data)
  local jsonData = data
  if type(data) == "table" then
    jsonData = json.encode(data)
  end
  MSDKManagerInstance:ReportTrackAttributionEvent(tag, jsonData)
end

return ReportManager
