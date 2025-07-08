local NotificationGeneral = class("NotificationGeneral")

function NotificationGeneral:ctor()
end

function NotificationGeneral:OnEnterBackgound()
  self.isEnterBackgound = true
end

function NotificationGeneral:OnEnterForegound()
  self.isEnterBackgound = false
end

function NotificationGeneral:AddPushNotification(param)
  if true == self.isEnterBackgound then
    return
  end
  local myDict = CS.System.Collections.Generic.Dictionary(CS.System.String, CS.System.Object)()
  for k, v in pairs(param) do
    myDict:Add(k, tostring(v))
  end
  log.info("AddPushNotification:" .. table.serialize(param))
  CS.MSDKPushNotification.Instance:AddPushNotification(myDict)
end

function NotificationGeneral:RemovePushNotification(name)
  CS.MSDKPushNotification.Instance:RemovePushNotification(name)
end

function NotificationGeneral:RemoveAllPushNotification()
  CS.MSDKPushNotification.Instance:RemoveAllPushNotification()
end

function NotificationGeneral:RemoveVeryclosedNotification(second)
  CS.MSDKPushNotification.Instance:RemoveVeryclosedNotification(second)
end

function NotificationGeneral:GetLaunchNotification()
  return CS.MSDKPushNotification.Instance:GetLaunchNotification()
end

function NotificationGeneral:GetLaunchExtras()
  return CS.MSDKPushNotification.Instance:GetLaunchExtras()
end

function NotificationGeneral:CheckPermission()
  return CS.MSDKPushNotification.Instance:CheckPermission()
end

function NotificationGeneral:RequestPermission()
  return CS.MSDKPushNotification.Instance:RequestPermission()
end

return NotificationGeneral
