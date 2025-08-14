require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Listen_Notify_EndPlay(cbSuccess, tag, cbFailed)
  if cbSuccess == nil then
    log.info("ListenNotify_EndPlay cbSuccess == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Notify_EndPlay
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Notify_EndPlay)
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

function rpcs:RemoveListen_Notify_EndPlay_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Notify_EndPlay
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Notify_EndPlay(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
