require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Listen_Push_Notify_SoloRaidReward(cbSuccess, tag, cbFailed)
  if cbSuccess == nil then
    log.info("ListenPush_Notify_SoloRaidReward cbSuccess == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Push_Notify_SoloRaidReward
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Push_Notify_SoloRaidReward)
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

function rpcs:RemoveListen_Push_Notify_SoloRaidReward_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Push_Notify_SoloRaidReward
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Push_Notify_SoloRaidReward(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
