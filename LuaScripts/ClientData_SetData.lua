require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:ClientData_SetData(sdpMsg, cbSuccess, cbFailed, cbTimeout, timeoutTime, retryCount, lockscreenTick)
  local client = self.CsSession:GetNetClient(CsNet.NetClientType.Game)
  if client == nil then
    log.error("Request Client Game NULL!")
    return
  end
  local messageId = MTTDProto.CmdId_ClientData_SetData_CS
  local cb = CsNet.NetSession.CreateRpcMsgCallback()
  if cbSuccess ~= nil or cbFailed ~= nil or cbTimeout ~= nil then
    cb.timeoutTick = CsNet.NetSession.GetSystemMillTime() + (timeoutTime or 3200)
    cb.timeoutRec = timeoutTime or 3200
    cb.retryCount = retryCount or 0
    cb.messageId = messageId
    
    function cb.callback(rec, msg, bt)
      if msg == nil then
        log.info("ClientData_SetData timeout: " .. tostring(rec.timeoutTick))
        if cbTimeout ~= nil then
          cbTimeout(rec)
        end
        return
      end
      if msg.rspcode == 0 then
        local sc = sdp.unpack(bt, MTTDProto.Cmd_ClientData_SetData_SC)
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

function rpcs:ClientData_SetDataNoCB(sdpMsg, timeout, retryCount)
  self:ClientData_SetData(sdpMsg, nil, nil, nil, timeout, retryCount)
end

rpcs.ClientData_SetData_Task = awrap(function(self, sdpMsg, timeout, retryCount, callback)
  self:ClientData_SetData(sdpMsg, function(sc, msg)
    callback(true, false, sc, msg)
  end, function(msg)
    callback(false, false, nil, msg)
  end, function(rec)
    callback(false, true, nil, nil)
  end, timeout, retryCount)
end)

function rpcs:Listen_ClientData_SetData(cb, tag)
  if cb == nil then
    log.info("ListenClientData_SetData cb == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_ClientData_SetData_SC
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_ClientData_SetData_SC)
      cb(true, sc, msg)
    else
      cb(false, nil, msg)
    end
  end, tag)
end

function rpcs:RemoveListen_ClientData_SetData_ByTag(tag)
  local messageId = -MTTDProto.CmdId_ClientData_SetData_SC
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_ClientData_SetData(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
