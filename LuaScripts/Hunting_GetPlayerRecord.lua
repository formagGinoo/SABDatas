require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Hunting_GetPlayerRecord(sdpMsg, cbSuccess, cbFailed, cbTimeout, timeoutTime, retryCount, lockscreenTick)
  local client = self.CsSession:GetNetClient(CsNet.NetClientType.Game)
  if client == nil then
    log.error("Request Client Game NULL!")
    return
  end
  local messageId = MTTDProto.CmdId_Hunting_GetPlayerRecord_CS
  local cb = CsNet.NetSession.CreateRpcMsgCallback()
  if cbSuccess ~= nil or cbFailed ~= nil or cbTimeout ~= nil then
    cb.timeoutTick = CsNet.NetSession.GetSystemMillTime() + (timeoutTime or 3200)
    cb.timeoutRec = timeoutTime or 3200
    cb.retryCount = retryCount or 0
    cb.messageId = messageId
    
    function cb.callback(rec, msg, bt)
      if msg == nil then
        log.info("Hunting_GetPlayerRecord timeout: " .. tostring(rec.timeoutTick))
        if cbTimeout ~= nil then
          cbTimeout(rec)
        end
        return
      end
      if msg.rspcode == 0 then
        local sc = sdp.unpack(bt, MTTDProto.Cmd_Hunting_GetPlayerRecord_SC)
        if cbSuccess ~= nil then
          cbSuccess(sc, msg)
        end
      elseif cbFailed ~= nil then
        cbFailed(msg)
      else
        local fRpcCBFail = self.CsSession:GetRpcCallbackFail()
        if fRpcCBFail ~= nil then
          fRpcCBFail(msg)
        end
      end
    end
    
    if lockscreenTick ~= nil and lockscreenTick < 0 then
      cb.lockscreenTick = -1
    else
      cb.lockscreenTick = CsNet.NetSession.GetSystemMillTime() + (lockscreenTick or 0)
    end
    self.CsSession:RegisterRpcCallback(self.CsSession:GetCurrentSeq(), cb)
  end
  self.CsSession:LuaSendRawDataWithSpecifiedSeq(messageId, sdp.pack(sdpMsg), client)
end

function rpcs:Hunting_GetPlayerRecordNoCB(sdpMsg, timeout, retryCount)
  self:Hunting_GetPlayerRecord(sdpMsg, nil, nil, nil, timeout, retryCount)
end

rpcs.Hunting_GetPlayerRecord_Task = awrap(function(self, sdpMsg, timeout, retryCount, callback)
  self:Hunting_GetPlayerRecord(sdpMsg, function(sc, msg)
    callback(true, false, sc, msg)
  end, function(msg)
    callback(false, false, nil, msg)
  end, function(rec)
    callback(false, true, nil, nil)
  end, timeout, retryCount)
end)

function rpcs:Listen_Hunting_GetPlayerRecord(cb, tag)
  if cb == nil then
    log.info("ListenHunting_GetPlayerRecord cb == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Hunting_GetPlayerRecord_SC
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Hunting_GetPlayerRecord_SC)
      cb(true, sc, msg)
    else
      cb(false, nil, msg)
    end
  end, tag)
end

function rpcs:RemoveListen_Hunting_GetPlayerRecord_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Hunting_GetPlayerRecord_SC
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Hunting_GetPlayerRecord(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
