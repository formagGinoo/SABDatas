require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Listen_Push_RoomDiscard(cbSuccess, tag, cbFailed)
  if cbSuccess == nil then
    log.info("ListenPush_RoomDiscard cbSuccess == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Push_RoomDiscard
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Push_RoomDiscard)
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

function rpcs:RemoveListen_Push_RoomDiscard_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Push_RoomDiscard
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Push_RoomDiscard(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
