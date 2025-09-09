local Form_PersonalBlowWhistle = class("Form_PersonalBlowWhistle", require("UI/UIFrames/Form_PersonalBlowWhistleUI"))

function Form_PersonalBlowWhistle:AfterInit()
  self.super.AfterInit(self)
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
  self.ReportConfig = {
    maxReportsPerDay = 0,
    singlePlayerCooldownHours = 0,
    maxPlayersPerTimeWindow = 0,
    timeWindowHours = 0
  }
  self.ReportLimitData = {reportData = ""}
  self.PlayerReportTimes = {}
  self.WindowStartTime = 0
  self.ReportedCount = 0
  self.LastResetDay = 0
  self.DailyReportCount = 0
  self:InitData()
  self:addEventListener("eGameEvent_Role_RoleReport", handler(self, self.OnRecordReport))
end

function Form_PersonalBlowWhistle:InitData()
  self.ReportConfig.maxReportsPerDay = tonumber(ConfigManager:GetGlobalSettingsByKey("PersoncardReportDayMax"))
  self.ReportConfig.singlePlayerCooldownHours = tonumber(ConfigManager:GetGlobalSettingsByKey("PersoncardReportSingleTime"))
  local personcardReportLimit = string.split(ConfigManager:GetGlobalSettingsByKey("PersoncardReportLimit"), ";")
  self.ReportConfig.maxPlayersPerTimeWindow = tonumber(personcardReportLimit[2])
  self.ReportConfig.timeWindowHours = tonumber(personcardReportLimit[1])
end

function Form_PersonalBlowWhistle:OnActive()
  self.super.OnActive(self)
  self:ReSetData()
  self:CleanupExpiredData()
end

function Form_PersonalBlowWhistle:OnInactive()
  self.super.OnInactive(self)
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
  self.ReportLimitData.reportData = LocalDataManager:GetStringSimple("ReportLimitData", "")
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
  return self.DailyReportCount < self.ReportConfig.maxReportsPerDay
end

function Form_PersonalBlowWhistle:CheckSinglePlayerCooldown(currentTime)
  if not self.PlayerReportTimes[self.targetPlayerId] then
    return true
  end
  local lastReportTime = self.PlayerReportTimes[self.targetPlayerId]
  local cooldownSeconds = self.ReportConfig.singlePlayerCooldownHours
  return cooldownSeconds <= currentTime - lastReportTime
end

function Form_PersonalBlowWhistle:CheckTimeWindowLimit(currentTime)
  local windowStart = currentTime - self.ReportConfig.timeWindowHours
  if currentTime - self.WindowStartTime >= self.ReportConfig.timeWindowHours then
    self:ResetTimeWindow(currentTime)
  end
  if self.PlayerReportTimes[self.targetPlayerId] then
    local lastReportTime = self.PlayerReportTimes[self.targetPlayerId]
    if windowStart <= lastReportTime then
      return false
    end
  end
  local currentWindowReports = 0
  for playerId, reportTime in pairs(self.PlayerReportTimes) do
    if reportTime >= windowStart then
      currentWindowReports = currentWindowReports + 1
    end
  end
  return currentWindowReports < self.ReportConfig.maxPlayersPerTimeWindow
end

function Form_PersonalBlowWhistle:OnRecordReport()
  local currentTime = TimeUtil:GetServerTimeS()
  self.PlayerReportTimes[self.targetPlayerId] = currentTime
  self.ReportedCount = self.ReportedCount + 1
  self.DailyReportCount = self.DailyReportCount + 1
  self:SaveReportData()
end

function Form_PersonalBlowWhistle:ResetTimeWindow(currentTime)
  self.WindowStartTime = currentTime
  self.ReportedCount = 0
  self:CleanupExpiredData()
end

function Form_PersonalBlowWhistle:CleanupExpiredData()
  local currentTime = TimeUtil:GetServerTimeS()
  local maxAge = math.max(self.ReportConfig.singlePlayerCooldownHours, self.ReportConfig.timeWindowHours)
  local expiredPlayers = {}
  for playerId, reportTime in pairs(self.PlayerReportTimes) do
    if maxAge < currentTime - reportTime then
      table.insert(expiredPlayers, playerId)
    end
  end
  for _, playerId in ipairs(expiredPlayers) do
    self.PlayerReportTimes[playerId] = nil
  end
end

function Form_PersonalBlowWhistle:ParseReportData()
  if self.ReportLimitData.reportData == "" then
    self.PlayerReportTimes = {}
    self.WindowStartTime = TimeUtil:GetServerTimeS()
    self.ReportedCount = 0
    self.LastResetDay = self:GetCurrentDay()
    self.DailyReportCount = 0
    return
  end
  local parts = self:SplitString(self.ReportLimitData.reportData, "|")
  if 5 <= #parts then
    self.PlayerReportTimes = {}
    if parts[1] ~= "" then
      local playerReports = self:SplitString(parts[1], ",")
      for _, report in ipairs(playerReports) do
        local kvp = self:SplitString(report, ":")
        if #kvp == 2 then
          local timestamp = tonumber(kvp[2])
          if timestamp then
            self.PlayerReportTimes[kvp[1]] = timestamp
          end
        end
      end
    end
    local windowStart = tonumber(parts[2])
    if windowStart then
      self.WindowStartTime = windowStart
    end
    local count = tonumber(parts[3])
    if count then
      self.ReportedCount = count
    end
    local lastReset = tonumber(parts[4])
    if lastReset then
      self.LastResetDay = lastReset
    end
    local dailyCount = tonumber(parts[5])
    if dailyCount then
      self.DailyReportCount = dailyCount
    end
  end
end

function Form_PersonalBlowWhistle:SaveReportData()
  local playerReports = {}
  for playerId, timestamp in pairs(self.PlayerReportTimes) do
    table.insert(playerReports, string.format("%s:%d", playerId, timestamp))
  end
  self.ReportLimitData.reportData = string.format("%s|%d|%d|%d|%d", table.concat(playerReports, ","), self.WindowStartTime, self.ReportedCount, self.LastResetDay, self.DailyReportCount)
  LocalDataManager:SetStringSimple("ReportLimitData", self.ReportLimitData.reportData)
end

function Form_PersonalBlowWhistle:CheckAndResetDailyCount()
  local currentDay = self:GetCurrentDay()
  if currentDay > self.LastResetDay then
    self.DailyReportCount = 0
    self.LastResetDay = currentDay
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
    RoleManager:ReqRoleReportCS({
      targetPlayerId = self.targetPlayerId,
      targetPlayerZoneID = self.targetPlayerZoneID,
      reportReasonTypype = self:GetReportReasonType(),
      text = self.m_inputfield_InputField.text
    })
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
