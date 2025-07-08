require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Listen_Notify_StartSelect(cbSuccess, tag, cbFailed)
  if cbSuccess == nil then
    log.info("ListenNotify_StartSelect cbSuccess == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Notify_StartSelect
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Notify_StartSelect)
      cbSuccess(sc, msg)
    elseif cbFailed ~= nil then
      cbFailed(msg)
    else
      local fRpcCBFail = self.CsSession:GetRpcCallbackFail()
      if fRpcCBFail ~= nil then
        fRpcCBFail(msg)
      end
    end
  end, tag)
end

function rpcs:RemoveListen_Notify_StartSelect_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Notify_StartSelect
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Notify_StartSelect(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
