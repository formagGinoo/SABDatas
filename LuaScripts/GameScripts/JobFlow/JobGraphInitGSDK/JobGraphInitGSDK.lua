local JobGraphInitGSDK = class("JobGraphInitGSDK")
local Job_InitGSDK_Finished_Impl = require("JobFlow/JobGraphInitGSDK/Job_InitGSDK_Finished_Impl")
local Job_InitGSDK_Init_Impl = require("JobFlow/JobGraphInitGSDK/Job_InitGSDK_Init_Impl")
local Job_InitGSDK_Login_Impl = require("JobFlow/JobGraphInitGSDK/Job_InitGSDK_Login_Impl")
JobGraphInitGSDK.s_instance = nil

function JobGraphInitGSDK:ctor()
  self.m_builded = false
  self.m_csGraph = nil
end

function JobGraphInitGSDK.Instance()
  if JobGraphInitGSDK.s_instance == nil then
    JobGraphInitGSDK.s_instance = JobGraphInitGSDK.new()
    JobGraphInitGSDK.s_instance:BuildGraph()
    if __JobGraphs == nil then
      __JobGraphs = {}
    end
    __JobGraphs.JobGraphInitGSDK = JobGraphInitGSDK.s_instance
  end
  return JobGraphInitGSDK.s_instance
end

function JobGraphInitGSDK:BuildGraph()
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
    jn = JobNode.CreateNode("Finished", 0, 5, false, Job_InitGSDK_Finished_Impl.OnFinished, Job_InitGSDK_Finished_Impl.OnFinishedSuccess, Job_InitGSDK_Finished_Impl.OnFinishedFailed, Job_InitGSDK_Finished_Impl.OnFinishedTimeOut, Job_InitGSDK_Finished_Impl.OnFinishedDispose)
    csg:AddNode(jn)
    jn.X = 8
    jn.Y = -296
    jn = JobNode.CreateNode("Init", 0, 10, false, Job_InitGSDK_Init_Impl.OnInit, Job_InitGSDK_Init_Impl.OnInitSuccess, Job_InitGSDK_Init_Impl.OnInitFailed, Job_InitGSDK_Init_Impl.OnInitTimeOut, Job_InitGSDK_Init_Impl.OnInitDispose)
    csg:AddNode(jn)
    jn.X = -360
    jn.Y = -552
    jn = JobNode.CreateNode("Login", 0, 10, false, Job_InitGSDK_Login_Impl.OnLogin, Job_InitGSDK_Login_Impl.OnLoginSuccess, Job_InitGSDK_Login_Impl.OnLoginFailed, Job_InitGSDK_Login_Impl.OnLoginTimeOut, Job_InitGSDK_Login_Impl.OnLoginDispose)
    csg:AddNode(jn)
    jn.X = 8
    jn.Y = -552
    csg:GetNode(1):AddTrigger(csg:GetNode(3))
    csg:GetNode(2):AddTrigger(csg:GetNode(0))
    csg:GetNode(3):AddTrigger(csg:GetNode(2))
    self.m_builded = true
  end
end

function JobGraphInitGSDK:Reset()
  if self.m_csGraph ~= nil then
    self.m_csGraph:Reset()
  end
end

function JobGraphInitGSDK:Run(callback)
  if self.m_csGraph ~= nil then
    self.m_csGraph:Run(callback)
  end
end

function JobGraphInitGSDK:OnGUI()
  if self.m_csGraph ~= nil then
    self.m_csGraph:OnGUI()
  end
end

function JobGraphInitGSDK:GetJobProgress()
  if self.m_csGraph ~= nil then
    return self.m_csGraph:GetJobProgress()
  end
  return 0
end

function JobGraphInitGSDK:Dispose()
  if __JobGraphs ~= nil then
    __JobGraphs.JobGraphInitGSDK = nil
  end
  JobGraphInitGSDK.s_instance = nil
  if self.m_csGraph ~= nil then
    return self.m_csGraph:Dispose()
  end
  self.m_csGraph = nil
end

return JobGraphInitGSDK
