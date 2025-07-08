require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Listen_Push_Notify_FBFace(cbSuccess, tag, cbFailed)
  if cbSuccess == nil then
    log.info("ListenPush_Notify_FBFace cbSuccess == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Push_Notify_FBFace
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Push_Notify_FBFace)
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

function rpcs:RemoveListen_Push_Notify_FBFace_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Push_Notify_FBFace
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Push_Notify_FBFace(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
