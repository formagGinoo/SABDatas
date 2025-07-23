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
    if tipsId == 9999 then
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("UpdateComplete"),
        content = CS.ConfFact.LangFormat4DataInit("UpdateRestartConfirm"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("PlayerCancelInfoYes"),
        btnNum = 1,
        bLockBack = true,
        bLockTop = true,
        func1 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
    else
      CS.ApplicationManager.Instance:RestartGame()
    end
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
  if tipsId == 9999 then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsTitle9999"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent9999"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 1,
      bLockBack = true,
      bLockTop = true,
      func1 = function()
        if yesCallBack then
          yesCallBack()
        end
      end
    })
  elseif tipsId == 9998 then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsTitle9998"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent9998"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 1,
      bLockBack = true,
      bLockTop = true,
      func1 = function()
        if yesCallBack then
          yesCallBack()
        end
      end
    })
  elseif tipsId == 9997 then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsTitle9997"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent9997"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonUnderstand"),
      btnNum = 1,
      bLockBack = true,
      bLockTop = true,
      func1 = function()
        if yesCallBack then
          yesCallBack()
        end
      end
    })
  elseif tipsId == 9996 then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsTitle9996"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent9996"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonUnderstandAndLogOut"),
      btnNum = 1,
      bLockBack = true,
      bLockTop = true,
      func1 = function()
        if yesCallBack then
          yesCallBack()
        end
      end
    })
  elseif tipsId == 9995 then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsTitle9995"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent9995"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonUnderstandAndLogOut"),
      btnNum = 1,
      bLockBack = true,
      bLockTop = true,
      func1 = function()
        if yesCallBack then
          yesCallBack()
        end
      end
    })
  elseif tipsId == 9994 then
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsTitle9994"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent9994"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonUnderstand"),
      btnNum = 1,
      bLockBack = true,
      bLockTop = true,
      func1 = function()
        if yesCallBack then
          yesCallBack()
        end
      end
    })
  else
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
end

return PushMessageManager
