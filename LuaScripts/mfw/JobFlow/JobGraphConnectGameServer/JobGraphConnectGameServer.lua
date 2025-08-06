local JobGraphConnectGameServer = class("JobGraphConnectGameServer")
local Job_ConnectGameServer_Finished_Impl = require("JobFlow/JobGraphConnectGameServer/Job_ConnectGameServer_Finished_Impl")
local Job_ConnectGameServer_ConnectGameServer_Impl = require("JobFlow/JobGraphConnectGameServer/Job_ConnectGameServer_ConnectGameServer_Impl")
local Job_ConnectGameServer_Game_Role_Init_Impl = require("JobFlow/JobGraphConnectGameServer/Job_ConnectGameServer_Game_Role_Init_Impl")
local Job_ConnectGameServer_TGRPCheckRes_Impl = require("JobFlow/JobGraphConnectGameServer/Job_ConnectGameServer_TGRPCheckRes_Impl")
JobGraphConnectGameServer.s_instance = nil

function JobGraphConnectGameServer:ctor()
  self.m_builded = false
  self.m_csGraph = nil
end

function JobGraphConnectGameServer.Instance()
  if JobGraphConnectGameServer.s_instance == nil then
    JobGraphConnectGameServer.s_instance = JobGraphConnectGameServer.new()
    JobGraphConnectGameServer.s_instance:BuildGraph()
    if __JobGraphs == nil then
      __JobGraphs = {}
    end
    __JobGraphs.JobGraphConnectGameServer = JobGraphConnectGameServer.s_instance
  end
  return JobGraphConnectGameServer.s_instance
end

function JobGraphConnectGameServer:BuildGraph()
  if not self.m_builded then
    self.m_csGraph = JobGraphBase.CreateGraph()
    local csg = self.m_csGraph
    local jn = null
    local en = null
    local an = null
    en = EntryNode.CreateNode()
    csg:AddNode(en)
    csg:SetEntry(en)
    en.X = -648
    en.Y = -552
    jn = JobNode.CreateNode("Finished", 0, 5, false, Job_ConnectGameServer_Finished_Impl.OnFinished, Job_ConnectGameServer_Finished_Impl.OnFinishedSuccess, Job_ConnectGameServer_Finished_Impl.OnFinishedFailed, Job_ConnectGameServer_Finished_Impl.OnFinishedTimeOut, Job_ConnectGameServer_Finished_Impl.OnFinishedDispose)
    csg:AddNode(jn)
    jn.X = 760
    jn.Y = -584
    jn = JobNode.CreateNode("ConnectGameServer", 0, 10, false, Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServer, Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServerSuccess, Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServerFailed, Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServerTimeOut, Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServerDispose)
    csg:AddNode(jn)
    jn.X = -392
    jn.Y = -584
    jn = JobNode.CreateNode("Game_Role_Init", 0, 10, false, Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_Init, Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_InitSuccess, Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_InitFailed, Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_InitTimeOut, Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_InitDispose)
    csg:AddNode(jn)
    jn.X = -8
    jn.Y = -584
    jn = JobNode.CreateNode("TGRPCheckRes", 0, 5, false, Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckRes, Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckResSuccess, Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckResFailed, Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckResTimeOut, Job_ConnectGameServer_TGRPCheckRes_Impl.OnTGRPCheckResDispose)
    csg:AddNode(jn)
    jn.X = 376
    jn.Y = -584
    csg:GetNode(1):AddTrigger(csg:GetNode(4))
    csg:GetNode(2):AddTrigger(csg:GetNode(0))
    csg:GetNode(3):AddTrigger(csg:GetNode(2))
    csg:GetNode(4):AddTrigger(csg:GetNode(3))
    self.m_builded = true
  end
end

function JobGraphConnectGameServer:Reset()
  if self.m_csGraph ~= nil then
    self.m_csGraph:Reset()
  end
end

function JobGraphConnectGameServer:Run(callback)
  if self.m_csGraph ~= nil then
    self.m_csGraph:Run(callback)
  end
end

function JobGraphConnectGameServer:OnGUI()
  if self.m_csGraph ~= nil then
    self.m_csGraph:OnGUI()
  end
end

function JobGraphConnectGameServer:GetJobProgress()
  if self.m_csGraph ~= nil then
    return self.m_csGraph:GetJobProgress()
  end
  return 0
end

function JobGraphConnectGameServer:Dispose()
  if __JobGraphs ~= nil then
    __JobGraphs.JobGraphConnectGameServer = nil
  end
  JobGraphConnectGameServer.s_instance = nil
  if self.m_csGraph ~= nil then
    return self.m_csGraph:Dispose()
  end
  self.m_csGraph = nil
end

return JobGraphConnectGameServer
