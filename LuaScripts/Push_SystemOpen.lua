require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Listen_Push_SystemOpen(cbSuccess, tag, cbFailed)
  if cbSuccess == nil then
    log.info("ListenPush_SystemOpen cbSuccess == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Push_SystemOpen
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Push_SystemOpen)
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

function rpcs:RemoveListen_Push_SystemOpen_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Push_SystemOpen
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Push_SystemOpen(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
