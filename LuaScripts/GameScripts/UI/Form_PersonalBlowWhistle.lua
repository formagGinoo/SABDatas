local Form_PersonalBlowWhistle = class("Form_PersonalBlowWhistle", require("UI/UIFrames/Form_PersonalBlowWhistleUI"))
local ReportConfig = {
  maxReportsPerDay = 0,
  singlePlayerCooldownHours = 0,
  maxPlayersPerTimeWindow = 0,
  timeWindowHours = 0
}
local ReportLimitData = {reportData = ""}
local PlayerReportTimes = {}
local WindowStartTime = 0
local ReportedCount = 0
local LastResetDay = 0
local DailyReportCount = 0

function Form_PersonalBlowWhistle:AfterInit()
  self.super.AfterInit(self)
  self:InitData()
  self.toggles = {}
  local itemInstance = self.m_toggle_1
  local maxToggleCount = string.split(ConfigManager:GetGlobalSettingsByKey("PersoncardReportType"), ";")
  local index = 1
  for _, v in pairs(maxToggleCount) do
    local go = GameObject.Instantiate(itemInstance, self.m_toggle_list.transform)
    local commonTextStr = string.split(v, "/")
    go.transform:Find("txt_name_1"):GetComponent("TextMeshProUGUI").text = UILuaHelper.GetCommonText(tonumber(commonTextStr[2]))
    go.name = index
    index = index + 1
    table.insert(self.toggles, {
      reasonType = tonumber(commonTextStr[1]),
      go = go
    })
  end
  itemInstance:SetActive(false)
end

function Form_PersonalBlowWhistle:InitData()
  ReportConfig.maxReportsPerDay = tonumber(ConfigManager:GetGlobalSettingsByKey("PersoncardReportDayMax"))
  ReportConfig.singlePlayerCooldownHours = tonumber(ConfigManager:GetGlobalSettingsByKey("PersoncardReportSingleTime"))
  local personcardReportLimit = string.split(ConfigManager:GetGlobalSettingsByKey("PersoncardReportLimit"), ";")
  ReportConfig.maxPlayersPerTimeWindow = tonumber(personcardReportLimit[2])
  ReportConfig.timeWindowHours = tonumber(personcardReportLimit[1])
end

function Form_PersonalBlowWhistle:OnActive()
  self.super.OnActive(self)
  self:ReSetData()
  self:CleanupExpiredData()
end

function Form_PersonalBlowWhistle:OnInactive()
  self.super.OnInactive(self)
end

function Form_PersonalBlowWhistle:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PersonalBlowWhistle:ReSetData()
  if self.toggles[1] then
    self.toggles[1].go:GetComponent("ActiveToggle").isOn = true
  end
  if self.m_csui.m_param then
    self.m_z_txt_name_Text.text = self.m_csui.m_param.name
    self.targetPlayerId = self.m_csui.m_param.uid or 0
    self.targetPlayerZoneID = self.m_csui.m_param.zoneID or 0
  end
  self.m_inputfield_InputField.text = ""
  ReportLimitData.reportData = LocalDataManager:GetStringSimple("ReportLimitData", "")
  self:ParseReportData()
end

function Form_PersonalBlowWhistle:CanReportPlayer()
  local currentTime = TimeUtil:GetServerTimeS()
  if not self:CheckDailyLimit() then
    return false
  end
  if not self:CheckSinglePlayerCooldown(currentTime) then
    return false
  end
  if not self:CheckTimeWindowLimit(currentTime) then
    return false
  end
  return true
end

function Form_PersonalBlowWhistle:CheckDailyLimit()
  self:CheckAndResetDailyCount()
  return DailyReportCount < ReportConfig.maxReportsPerDay
end

function Form_PersonalBlowWhistle:CheckSinglePlayerCooldown(currentTime)
  if not PlayerReportTimes[self.targetPlayerId] then
    return true
  end
  local lastReportTime = PlayerReportTimes[self.targetPlayerId]
  local cooldownSeconds = ReportConfig.singlePlayerCooldownHours
  return cooldownSeconds <= currentTime - lastReportTime
end

function Form_PersonalBlowWhistle:CheckTimeWindowLimit(currentTime)
  local windowStart = currentTime - ReportConfig.timeWindowHours
  if currentTime - WindowStartTime >= ReportConfig.timeWindowHours then
    self:ResetTimeWindow(currentTime)
  end
  if PlayerReportTimes[self.targetPlayerId] then
    local lastReportTime = PlayerReportTimes[self.targetPlayerId]
    if windowStart <= lastReportTime then
      return false
    end
  end
  local currentWindowReports = 0
  for playerId, reportTime in pairs(PlayerReportTimes) do
    if reportTime >= windowStart then
      currentWindowReports = currentWindowReports + 1
    end
  end
  return currentWindowReports < ReportConfig.maxPlayersPerTimeWindow
end

function Form_PersonalBlowWhistle:RecordReport()
  local currentTime = TimeUtil:GetServerTimeS()
  PlayerReportTimes[self.targetPlayerId] = currentTime
  ReportedCount = ReportedCount + 1
  DailyReportCount = DailyReportCount + 1
  self:SaveReportData()
end

function Form_PersonalBlowWhistle:ResetTimeWindow(currentTime)
  WindowStartTime = currentTime
  ReportedCount = 0
  self:CleanupExpiredData()
end

function Form_PersonalBlowWhistle:CleanupExpiredData()
  local currentTime = TimeUtil:GetServerTimeS()
  local maxAge = math.max(ReportConfig.singlePlayerCooldownHours, ReportConfig.timeWindowHours)
  local expiredPlayers = {}
  for playerId, reportTime in pairs(PlayerReportTimes) do
    if maxAge < currentTime - reportTime then
      table.insert(expiredPlayers, playerId)
    end
  end
  for _, playerId in ipairs(expiredPlayers) do
    PlayerReportTimes[playerId] = nil
  end
end

function Form_PersonalBlowWhistle:ParseReportData()
  if ReportLimitData.reportData == "" then
    PlayerReportTimes = {}
    WindowStartTime = TimeUtil:GetServerTimeS()
    ReportedCount = 0
    LastResetDay = self:GetCurrentDay()
    DailyReportCount = 0
    return
  end
  local parts = self:SplitString(ReportLimitData.reportData, "|")
  if 5 <= #parts then
    PlayerReportTimes = {}
    if parts[1] ~= "" then
      local playerReports = self:SplitString(parts[1], ",")
      for _, report in ipairs(playerReports) do
        local kvp = self:SplitString(report, ":")
        if #kvp == 2 then
          local timestamp = tonumber(kvp[2])
          if timestamp then
            PlayerReportTimes[kvp[1]] = timestamp
          end
        end
      end
    end
    local windowStart = tonumber(parts[2])
    if windowStart then
      WindowStartTime = windowStart
    end
    local count = tonumber(parts[3])
    if count then
      ReportedCount = count
    end
    local lastReset = tonumber(parts[4])
    if lastReset then
      LastResetDay = lastReset
    end
    local dailyCount = tonumber(parts[5])
    if dailyCount then
      DailyReportCount = dailyCount
    end
  end
end

function Form_PersonalBlowWhistle:SaveReportData()
  local playerReports = {}
  for playerId, timestamp in pairs(PlayerReportTimes) do
    table.insert(playerReports, string.format("%s:%d", playerId, timestamp))
  end
  ReportLimitData.reportData = string.format("%s|%d|%d|%d|%d", table.concat(playerReports, ","), WindowStartTime, ReportedCount, LastResetDay, DailyReportCount)
  LocalDataManager:SetStringSimple("ReportLimitData", ReportLimitData.reportData)
end

function Form_PersonalBlowWhistle:CheckAndResetDailyCount()
  local currentDay = self:GetCurrentDay()
  if currentDay > LastResetDay then
    DailyReportCount = 0
    LastResetDay = currentDay
    self:SaveReportData()
  end
end

function Form_PersonalBlowWhistle:GetCurrentDay()
  local currentTime = TimeUtil:GetServerTimeS()
  return math.floor((currentTime - 14400) / 86400)
end

function Form_PersonalBlowWhistle:SplitString(str, delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(str, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(str, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(str, delimiter, from)
  end
  table.insert(result, string.sub(str, from))
  return result
end

function Form_PersonalBlowWhistle:OnNodelightClicked()
  if self:CanReportPlayer() then
    local reqMsg = MTTDProto.Cmd_Role_Report_CS()
    reqMsg.iType = 10
    reqMsg.iTargetUid = self.targetPlayerId
    reqMsg.iZoneId = self.targetPlayerZoneID
    reqMsg.iReportReasonType = self:GetReportReasonType()
    reqMsg.sReason = self.m_inputfield_InputField.text
    RPCS():Role_Report(reqMsg, function(sc)
      self:RecordReport()
    end)
  end
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(13029))
  self:CloseForm()
end

function Form_PersonalBlowWhistle:GetReportReasonType()
  for _, v in pairs(self.toggles) do
    if v.go:GetComponent("ActiveToggle").isOn == true then
      return {
        v.reasonType
      }
    end
  end
  return {}
end

function Form_PersonalBlowWhistle:OnBtnReturnClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_PersonalBlowWhistle", Form_PersonalBlowWhistle)
return Form_PersonalBlowWhistle
