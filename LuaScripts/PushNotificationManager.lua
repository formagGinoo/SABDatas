local BaseManager = require("Manager/Base/BaseManager")
local PushNotificationManager = class("PushNotificationManager", BaseManager)
PushNotificationManager.PushName = {
  land = 1,
  mail = 2,
  test = 99
}

function PushNotificationManager:OnCreate()
  if not ChannelManager:IsUsingQSDK() then
    self.m_notificationImp = require("Manager/PushNotificationSystem/NotificationGeneral").new()
  end
  if ChannelManager:IsChinaChannel() then
    self.m_notificationImp = require("Manager/JPushNotification/JPushManager").new()
  end
end

function PushNotificationManager:OnInitNetwork()
  self.m_inited = true
  self:RegisterTest()
  self.m_globalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  self.m_settingPushIns = ConfigManager:GetConfigInsByName("SettingPush")
  self:addEventListener("eGameEvent_PauseGame", handler(self, self.OnPauseGame))
end

function PushNotificationManager:RegisterTest()
  if not UILuaHelper.IsAbleDebugger() then
    return
  end
  SROptionsModify.AddSROptionMethod("推送测试", function()
    self:TestNotification()
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("DMM购买测试", function()
    CS.DMMGameStoreManager.Instance:SimulatePurchase()
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("第三方绑定", function()
    CS.MSDKLogin.Instance:BindingWithThirdParty("GP", function(isSuccess, thirdParty)
      if isSuccess then
        log.info("绑定成功")
      else
        log.info("绑定失败")
      end
    end)
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("第三方解绑", function()
    CS.MSDKLogin.Instance:UnbindingWithThirdParty("GP", function(isSuccess, thirdParty)
      if isSuccess then
        log.info("解绑成功")
      else
        log.info("解绑失败")
      end
    end)
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("第三方账号切换", function()
    CS.MSDKLogin.Instance:LoginWithThirdParty("GP", function(isSuccess, thirdParty)
      if isSuccess then
        log.info("第三方账号切换成功")
      else
        log.info("第三方账号切换失败")
      end
    end)
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("退出游戏", function()
    CS.ApplicationManager.Instance:ExitGame()
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("部分表格重载", function()
    CS.Util.ReloadTables(ConfigManager.m_mConfigInstanceCache)
  end, "Debug", 0)
  SROptionsModify.AddSROptionMethod("测试客户端数据上报", function()
    ReportManager:ReportClientDebugInfo("test", "test1")
  end, "Debug", 0)
end

function PushNotificationManager:TestNotification()
  self.m_isTest = true
  CS.MUFSDK:SetSandbox(true)
  self:RefreshPushById(self.PushName.test)
end

function PushNotificationManager:RefreshPushes()
  self:RefreshPushById(self.PushName.land)
end

function PushNotificationManager:RefreshPushById(pushId)
  local delayTime = -1
  if pushId == self.PushName.land then
    if UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK) then
      local AFK_STORAGE = tonumber(self.m_globalManagerIns:GetValue_ByName("AFKStorage").m_Value) or 36000
      local receivedTime = HangUpManager.m_iTakeRewardTime
      local elapsedTime = TimeUtil:GetServerTimeS() - receivedTime
      if AFK_STORAGE <= elapsedTime then
        delayTime = self.m_globalManagerIns:GetValue_ByName("PushQuitCD").m_Value or -1
      else
        delayTime = AFK_STORAGE - elapsedTime
      end
    end
  elseif pushId == self.PushName.test then
    delayTime = 180
  end
  self:AddPush(pushId, delayTime)
end

function PushNotificationManager:IsPushOn(pushIdx, config)
  if config.m_PushType == 1 and self:CheckPermission() == false then
    return false
  end
  local isOpen = self.m_mPushOption[pushIdx]
  if isOpen == nil then
    isOpen = config.m_Default
  end
  return isOpen == 1
end

function PushNotificationManager:IsLocal(pushIdx, config)
  return config.m_PushType == 1
end

function PushNotificationManager:AddPush(pushIdx, delayTime)
  if nil == pushIdx or nil == delayTime or delayTime == -1 then
    return
  end
  if pushIdx == self.PushName.test then
    self:RemoveNotification("test_notification")
    self:CreateNotification("test_notification", delayTime, "", 1, false, "test three minutes", "test three minutes ! test ! test !", 1, pushIdx)
    return
  end
  local config = self.m_settingPushIns:GetValue_ByPushID(pushIdx)
  if nil == config then
    return
  end
  if self:IsPushOn(pushIdx, config) and self:IsLocal(pushIdx, config) then
    self:RemoveNotification(config.m_PushSDK)
    self:CreateNotification(config.m_PushSDK, delayTime, "", 1, false, config.m_mPushTitle, config.m_mPushText, config.m_Sort, pushIdx)
  end
end

function PushNotificationManager:RefreshPushNotifications()
  if self.m_notificationImp then
    self.m_notificationImp:RemoveAllPushNotification()
    self:RefreshPushes()
  end
end

function PushNotificationManager:GetPushId_ByName(name)
  local pushIdx = 99
  local cfgs = self.m_settingPushIns:GetAll()
  for i, itemCfg in pairs(cfgs) do
    if itemCfg.m_PushSDK == name then
      pushIdx = itemCfg.m_PushID
      break
    end
  end
  return pushIdx
end

function PushNotificationManager:CreateNotification(name, delay, sound, badge, isRepeat, title, body, priority, pushIdx)
  local param = {}
  param.name = name
  param.title = title
  param.delay = delay
  param.sound = sound
  param.badge = badge
  param["repeat"] = isRepeat
  param.body = body
  param.priority = priority
  param.id = pushIdx
  if self.m_notificationImp then
    self.m_notificationImp:AddPushNotification(param)
  end
end

function PushNotificationManager:RemoveNotification(name)
  if self.m_notificationImp then
    self.m_notificationImp:RemovePushNotification(name)
  end
end

function PushNotificationManager:RemovePushesByIndex(pushIdx, extra)
  local config = self.m_settingPushIns:GetValue_ByPushID(pushIdx)
  if nil ~= config then
    if extra then
      self:RemoveNotification(config.m_PushSDK .. extra)
    else
      self:RemoveNotification(config.m_PushSDK)
    end
  end
end

function PushNotificationManager:OnPauseGame(bPaused)
  if bPaused then
    self:OnEnterBackground()
  else
    self:OnEnterForeground()
  end
end

function PushNotificationManager:OnEnterBackground()
  if nil == self.m_notificationImp then
    return
  end
  if not self.m_inited then
    return
  end
  if not self.m_isTest then
    self:RefreshPushNotifications()
  end
  if self.m_notificationImp.OnEnterBackground then
    self.m_notificationImp:OnEnterBackground()
  end
end

function PushNotificationManager:OnEnterForeground()
  if nil ~= self.m_notificationImp and nil ~= self.m_notificationImp.OnEnterForeground then
    self.m_notificationImp:OnEnterForeground()
  end
end

function PushNotificationManager:SwitchToAppSettings()
end

function PushNotificationManager:GetLaunchNotification()
  if self.m_notificationImp and self.m_notificationImp.GetLaunchNotification then
    return self.m_notificationImp:GetLaunchNotification()
  end
  return nil
end

function PushNotificationManager:GetLaunchExtras()
  if self.m_notificationImp and self.m_notificationImp.GetLaunchExtras then
    return self.m_notificationImp:GetLaunchExtras()
  end
  return nil
end

function PushNotificationManager:CheckPermission()
  if self.m_notificationImp and self.m_notificationImp.CheckPermission then
    return self.m_notificationImp:CheckPermission()
  end
  return true
end

function PushNotificationManager:RequestPermission()
  if self.m_notificationImp and self.m_notificationImp.RequestPermission then
    self.m_notificationImp:RequestPermission()
  end
end

function PushNotificationManager:SetPushOptionFromServer(mPushOption)
  self.m_mPushOption = mPushOption
end

function PushNotificationManager:GetPushOption()
  return self.m_mPushOption
end

function PushNotificationManager:SyncPushOptionToServer(mPushOption)
  local reqMsg = MTTDProto.Cmd_Role_SetPushOption_CS()
  reqMsg.mPushOption = mPushOption
  RPCS():Role_SetPushOption(reqMsg, function()
    self.m_mPushOption = mPushOption
  end)
end

return PushNotificationManager
