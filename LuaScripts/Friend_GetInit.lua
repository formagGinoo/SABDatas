require("rpcs")
local rpcs = RPCS()
local CsNet = CS.com.muf.net.client.mfw
local log = require("common/log")

function rpcs:Friend_GetInit(sdpMsg, cbSuccess, cbFailed, cbTimeout, timeoutTime, retryCount, lockscreenTick)
  local client = self.CsSession:GetNetClient(CsNet.NetClientType.Game)
  if client == nil then
    log.error("Request Client Game NULL!")
    return
  end
  local messageId = MTTDProto.CmdId_Friend_GetInit_CS
  local cb = CsNet.NetSession.CreateRpcMsgCallback()
  if cbSuccess ~= nil or cbFailed ~= nil or cbTimeout ~= nil then
    cb.timeoutTick = CsNet.NetSession.GetSystemMillTime() + (timeoutTime or 3200)
    cb.timeoutRec = timeoutTime or 3200
    cb.retryCount = retryCount or 0
    cb.messageId = messageId
    
    function cb.callback(rec, msg, bt)
      if msg == nil then
        log.info("Friend_GetInit timeout: " .. tostring(rec.timeoutTick))
        if cbTimeout ~= nil then
          cbTimeout(rec)
        end
        return
      end
      if msg.rspcode == 0 then
        local sc = sdp.unpack(bt, MTTDProto.Cmd_Friend_GetInit_SC)
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

function rpcs:Friend_GetInitNoCB(sdpMsg, timeout, retryCount)
  self:Friend_GetInit(sdpMsg, nil, nil, nil, timeout, retryCount)
end

rpcs.Friend_GetInit_Task = awrap(function(self, sdpMsg, timeout, retryCount, callback)
  self:Friend_GetInit(sdpMsg, function(sc, msg)
    callback(true, false, sc, msg)
  end, function(msg)
    callback(false, false, nil, msg)
  end, function(rec)
    callback(false, true, nil, nil)
  end, timeout, retryCount)
end)

function rpcs:Listen_Friend_GetInit(cb, tag)
  if cb == nil then
    log.info("ListenFriend_GetInit cb == nil")
    return
  end
  local messageId = -MTTDProto.CmdId_Friend_GetInit_SC
  return self.CsSession:Listen(messageId, function(msg)
    if msg.rspcode == 0 then
      local sc = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Friend_GetInit_SC)
      cb(true, sc, msg)
    else
      cb(false, nil, msg)
    end
  end, tag)
end

function rpcs:RemoveListen_Friend_GetInit_ByTag(tag)
  local messageId = -MTTDProto.CmdId_Friend_GetInit_SC
  self.CsSession:RemoveListenByTagAndId(tag, messageId)
end

function rpcs:RemoveListen_Friend_GetInit(handler)
  self.CsSession:RemoveListenByHandler(handler)
end
