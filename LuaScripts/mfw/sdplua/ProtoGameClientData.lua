local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_ClientData_SetData_CS = 14101
CmdId_ClientData_SetData_SC = 14102
CmdId_ClientData_GetData_CS = 14103
CmdId_ClientData_GetData_SC = 14104
Cmd_ClientData_SetData_CS = sdp.SdpStruct("Cmd_ClientData_SetData_CS")
Cmd_ClientData_SetData_CS.Definition = {
  "mData",
  mData = {
    0,
    0,
    sdp.SdpMap(8, CmdClientData),
    nil
  }
}
Cmd_ClientData_SetData_SC = sdp.SdpStruct("Cmd_ClientData_SetData_SC")
Cmd_ClientData_SetData_SC.Definition = {}
Cmd_ClientData_GetData_CS = sdp.SdpStruct("Cmd_ClientData_GetData_CS")
Cmd_ClientData_GetData_CS.Definition = {}
Cmd_ClientData_GetData_SC = sdp.SdpStruct("Cmd_ClientData_GetData_SC")
Cmd_ClientData_GetData_SC.Definition = {
  "mData",
  mData = {
    0,
    0,
    sdp.SdpMap(8, CmdClientData),
    nil
  }
}
