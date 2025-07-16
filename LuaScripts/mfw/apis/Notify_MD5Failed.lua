require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Listen_Notify_MD5Failed(cbSuccess, tag, cbFailed)
  if cbSuccess == nil then
    log.info("ListenNotify_MD5Failed cbSuccess == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Notify_MD5Failed
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Notify_MD5Failed)
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

function rpcs:RemoveListen_Notify_MD5Failed_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Notify_MD5Failed
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Notify_MD5Failed(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
