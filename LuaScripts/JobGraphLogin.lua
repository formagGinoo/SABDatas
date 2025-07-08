local JobGraphLogin = class("JobGraphLogin")
local Job_Login_ConnectServer_Impl = require("JobFlow/JobGraphLogin/Job_Login_ConnectServer_Impl")
local Job_Login_Login_Auth_Impl = require("JobFlow/JobGraphLogin/Job_Login_Login_Auth_Impl")
local Job_Login_Login_GetBulletin_Impl = require("JobFlow/JobGraphLogin/Job_Login_Login_GetBulletin_Impl")
local Job_Login_Login_CheckUpgrade_Impl = require("JobFlow/JobGraphLogin/Job_Login_Login_CheckUpgrade_Impl")
local Job_Login_Finished_Impl = require("JobFlow/JobGraphLogin/Job_Login_Finished_Impl")
local Job_Login_GetSelfIp_Impl = require("JobFlow/JobGraphLogin/Job_Login_GetSelfIp_Impl")
local Job_Login_MiniPatchUpgrade_Impl = require("JobFlow/JobGraphLogin/Job_Login_MiniPatchUpgrade_Impl")
JobGraphLogin.s_instance = nil

function JobGraphLogin:ctor()
  self.m_builded = false
  self.m_csGraph = nil
end

function JobGraphLogin.Instance()
  if JobGraphLogin.s_instance == nil then
    JobGraphLogin.s_instance = JobGraphLogin.new()
    JobGraphLogin.s_instance:BuildGraph()
    if __JobGraphs == nil then
      __JobGraphs = {}
    end
    __JobGraphs.JobGraphLogin = JobGraphLogin.s_instance
  end
  return JobGraphLogin.s_instance
end

function JobGraphLogin:BuildGraph()
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
    en.Y = -520
    jn = JobNode.CreateNode("ConnectServer", 0, 10, false, Job_Login_ConnectServer_Impl.OnConnectServer, Job_Login_ConnectServer_Impl.OnConnectServerSuccess, Job_Login_ConnectServer_Impl.OnConnectServerFailed, Job_Login_ConnectServer_Impl.OnConnectServerTimeOut, Job_Login_ConnectServer_Impl.OnConnectServerDispose)
    csg:AddNode(jn)
    jn.X = -296
    jn.Y = -504
    jn = JobNode.CreateNode("Login_Auth", 0, 10, false, Job_Login_Login_Auth_Impl.OnLogin_Auth, Job_Login_Login_Auth_Impl.OnLogin_AuthSuccess, Job_Login_Login_Auth_Impl.OnLogin_AuthFailed, Job_Login_Login_Auth_Impl.OnLogin_AuthTimeOut, Job_Login_Login_Auth_Impl.OnLogin_AuthDispose)
    csg:AddNode(jn)
    jn.X = 376
    jn.Y = -632
    jn = JobNode.CreateNode("Login_GetBulletin", 0, 10, false, Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletin, Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletinSuccess, Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletinFailed, Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletinTimeOut, Job_Login_Login_GetBulletin_Impl.OnLogin_GetBulletinDispose)
    csg:AddNode(jn)
    jn.X = -312
    jn.Y = -216
    jn = JobNode.CreateNode("Login_CheckUpgrade", 0, 10, false, Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgrade, Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgradeSuccess, Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgradeFailed, Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgradeTimeOut, Job_Login_Login_CheckUpgrade_Impl.OnLogin_CheckUpgradeDispose)
    csg:AddNode(jn)
    jn.X = 72
    jn.Y = -216
    jn = JobNode.CreateNode("Finished", 0, 5, false, Job_Login_Finished_Impl.OnFinished, Job_Login_Finished_Impl.OnFinishedSuccess, Job_Login_Finished_Impl.OnFinishedFailed, Job_Login_Finished_Impl.OnFinishedTimeOut, Job_Login_Finished_Impl.OnFinishedDispose)
    csg:AddNode(jn)
    jn.X = 760
    jn.Y = -216
    jn = JobNode.CreateNode("GetSelfIp", 0, 10, false, Job_Login_GetSelfIp_Impl.OnGetSelfIp, Job_Login_GetSelfIp_Impl.OnGetSelfIpSuccess, Job_Login_GetSelfIp_Impl.OnGetSelfIpFailed, Job_Login_GetSelfIp_Impl.OnGetSelfIpTimeOut, Job_Login_GetSelfIp_Impl.OnGetSelfIpDispose)
    csg:AddNode(jn)
    jn.X = -296
    jn.Y = -712
    an = AndNode.CreateNode()
    csg:AddNode(an)
    an.X = 116.1371
    an.Y = -597.941
    jn = JobNode.CreateNode("MiniPatchUpgrade", 0, 10, false, Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgrade, Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgradeSuccess, Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgradeFailed, Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgradeTimeOut, Job_Login_MiniPatchUpgrade_Impl.OnMiniPatchUpgradeDispose)
    csg:AddNode(jn)
    jn.X = 408
    jn.Y = -216
    csg:GetNode(1):AddTrigger(csg:GetNode(0))
    csg:GetNode(2):AddTrigger(csg:GetNode(7))
    csg:GetNode(3):AddTrigger(csg:GetNode(2))
    csg:GetNode(4):AddTrigger(csg:GetNode(3))
    csg:GetNode(5):AddTrigger(csg:GetNode(8))
    csg:GetNode(6):AddTrigger(csg:GetNode(0))
    csg:GetNode(7):AddTrigger(csg:GetNode(1))
    csg:GetNode(7):AddTrigger(csg:GetNode(6))
    csg:GetNode(8):AddTrigger(csg:GetNode(4))
    self.m_builded = true
  end
end

function JobGraphLogin:Reset()
  if self.m_csGraph ~= nil then
    self.m_csGraph:Reset()
  end
end

function JobGraphLogin:Run(callback)
  if self.m_csGraph ~= nil then
    self.m_csGraph:Run(callback)
  end
end

function JobGraphLogin:OnGUI()
  if self.m_csGraph ~= nil then
    self.m_csGraph:OnGUI()
  end
end

function JobGraphLogin:GetJobProgress()
  if self.m_csGraph ~= nil then
    return self.m_csGraph:GetJobProgress()
  end
  return 0
end

function JobGraphLogin:Dispose()
  if __JobGraphs ~= nil then
    __JobGraphs.JobGraphLogin = nil
  end
  JobGraphLogin.s_instance = nil
  if self.m_csGraph ~= nil then
    return self.m_csGraph:Dispose()
  end
  self.m_csGraph = nil
end

return JobGraphLogin
