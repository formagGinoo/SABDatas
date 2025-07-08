local JPushManager = class("JPushManager")

function JPushManager:ctor()
end

function JPushManager:OnEnterBackgound()
  self.isEnterBackgound = true
end

function JPushManager:OnEnterForegound()
  self.isEnterBackgound = false
end

function JPushManager:IsJPushConnect()
  return not CS.JPushSDKBridge.Instance:IsJPushConnect()
end

function JPushManager:ResumeJPush()
  CS.JPushSDKBridge.Instance:ResumePush()
end

function JPushManager:StopJPush()
  CS.JPushSDKBridge.Instance:StopPush()
end

function JPushManager:CheckPermission()
  return CS.JPushSDKBridge.Instance:CheckPermission()
end

function JPushManager:RequestPermission()
  return CS.JPushSDKBridge.Instance:RequestPermission()
end

function JPushManager:RemoveNotification(name)
end

function JPushManager:AddPushNotification(param)
  local nId = param.id
  local content = param.body
  local title = param.title
  local extraData = {priority = 1}
  local extrasStr = json.encode(extraData)
  local builderId = 0
  local broadcastTime = param.delay
  log.info("Jpush 推送 " .. table.serialize(param))
  CS.JPushSDKBridge.Instance:AddLocalNotification(builderId, content, title, nId, broadcastTime, extrasStr)
end

function JPushManager:AddLocalNotificationByDate(builderId, content, title, nId, year, month, day, hour, minute, second, extrasStr)
  CS.JPushSDKBridge.Instance:AddLocalNotificationByDate(builderId, content, title, nId, year, month, day, hour, minute, second, extrasStr)
end

function JPushManager:RemovePushNotification(name)
  local notification_id = PushNotificationManager:GetPushId_ByName(name)
  CS.JPushSDKBridge.Instance:RemoveLocalNotification(notification_id)
end

function JPushManager:ClearLocalNotifications()
  CS.JPushSDKBridge.Instance:ClearLocalNotifications()
end

function JPushManager:RemoveAllPushNotification()
  CS.JPushSDKBridge.Instance:ClearAllNotifications()
end

function JPushManager:ClearNotificationById(name)
  local notification_id = PushNotificationManager:GetPushId_ByName(name)
  CS.JPushSDKBridge.Instance:ClearNotificationById(notification_id)
end

function JPushManager:AddReceiveMessageCallback(callback)
  CS.JPushSDKBridge.Instance.onReceiveMessage = callback
end

function JPushManager:AddReceiveNotificationCallback(callback)
  CS.JPushSDKBridge.Instance.onReceiveNotification = callback
end

function JPushManager:AddOpenNotificationCallback(callback)
  CS.JPushSDKBridge.Instance.onOpenNotification = callback
end

function JPushManager:AddJPushTagOperateResultCallback(callback)
  CS.JPushSDKBridge.Instance.onJPushTagOperateResult = callback
end

function JPushManager:AddJPushAliasOperateResultCallback(callback)
  CS.JPushSDKBridge.Instance.onJPushAliasOperateResult = callback
end

function JPushManager:AddGetRegistrationIdCallback(callback)
  CS.JPushSDKBridge.Instance.onGetRegistrationId = callback
end

function JPushManager:AddMobileNumberOperatorResultCallback(callback)
  CS.JPushSDKBridge.Instance.onMobileNumberOperatorResult = callback
end

return JPushManager
