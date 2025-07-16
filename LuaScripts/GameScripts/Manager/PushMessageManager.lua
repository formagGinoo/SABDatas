local BaseManager = require("Manager/Base/BaseManager")
local PushMessageManager = class("PushMessageManager", BaseManager)

function PushMessageManager:OnCreate()
end

function PushMessageManager:OnInitNetwork()
  RPCS():Listen_Push_KickPlayer(handler(self, self.OnPushMessage), "PushMessageManager")
end

function PushMessageManager:OnPushMessage(messageData, msg)
  local tipsId, yesCallBack, cancelCallBack = 9999
  if messageData.iReason == MTTDProto.KickReason_ClientNewVersion then
    tipsId = 9999
  elseif messageData.iReason == MTTDProto.KickReason_Maintain then
    tipsId = 9998
  elseif messageData.iReason == MTTDProto.KickReason_RepeatedLogin then
    tipsId = 9995
  elseif messageData.iReason == MTTDProto.KickReason_BanLogin then
    tipsId = 9994
  elseif messageData.iReason == MTTDProto.KickReason_OnlyRecharge then
    tipsId = 9996
  elseif messageData.iReason == MTTDProto.KickReason_Addict then
    tipsId = 9997
  end
  
  function yesCallBack()
    CS.ApplicationManager.Instance:RestartGame()
  end
  
  self:broadcastEvent("eGameEvent_NetKickOut")
  self:OpenServerPushMessageDetailPop(tipsId, yesCallBack, cancelCallBack)
end

function PushMessageManager:OpenServerPushMessageDetailPop(tipsId, yesCallBack, cancelCallBack)
  if not tipsId then
    log.error("PushMessageManager  OpenServerPushMessageDetailPop error tipsId == nil")
    return
  end
  CS.CommonHelper.SetTopUIExclude(UIDefines.ID_FORM_COMMONTIPS, true)
  utils.CheckAndPushCommonTips({
    tipsID = tipsId,
    bLockBack = true,
    bLockTop = true,
    func1 = function()
      if yesCallBack then
        yesCallBack()
      end
    end,
    func2 = function()
      if cancelCallBack then
        cancelCallBack()
      end
    end
  })
end

return PushMessageManager
