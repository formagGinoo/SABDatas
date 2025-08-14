require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Listen_Push_Activity_Change(cbSuccess, tag, cbFailed)
  if cbSuccess == nil then
    log.info("ListenPush_Activity_Change cbSuccess == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Push_Activity_Change
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Push_Activity_Change)
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

function rpcs:RemoveListen_Push_Activity_Change_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Push_Activity_Change
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Push_Activity_Change(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
