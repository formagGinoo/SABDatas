local JobGraphInitMSDK = class("JobGraphInitMSDK")
local Job_InitMSDK_Finished_Impl = require("JobFlow/JobGraphInitMSDK/Job_InitMSDK_Finished_Impl")
local Job_InitMSDK_Init_Impl = require("JobFlow/JobGraphInitMSDK/Job_InitMSDK_Init_Impl")
local Job_InitMSDK_LoginWithDid_Impl = require("JobFlow/JobGraphInitMSDK/Job_InitMSDK_LoginWithDid_Impl")
local Job_InitMSDK_AccountInit_Impl = require("JobFlow/JobGraphInitMSDK/Job_InitMSDK_AccountInit_Impl")
local Job_InitMSDK_GetAccountInfo_Impl = require("JobFlow/JobGraphInitMSDK/Job_InitMSDK_GetAccountInfo_Impl")
local Job_InitMSDK_AccountBinding_Impl = require("JobFlow/JobGraphInitMSDK/Job_InitMSDK_AccountBinding_Impl")
local Job_InitMSDK_UserAgreement_Impl = require("JobFlow/JobGraphInitMSDK/Job_InitMSDK_UserAgreement_Impl")
JobGraphInitMSDK.s_instance = nil

function JobGraphInitMSDK:ctor()
  self.m_builded = false
  self.m_csGraph = nil
end

function JobGraphInitMSDK.Instance()
  if JobGraphInitMSDK.s_instance == nil then
    JobGraphInitMSDK.s_instance = JobGraphInitMSDK.new()
    JobGraphInitMSDK.s_instance:BuildGraph()
    if __JobGraphs == nil then
      __JobGraphs = {}
    end
    __JobGraphs.JobGraphInitMSDK = JobGraphInitMSDK.s_instance
  end
  return JobGraphInitMSDK.s_instance
end

function JobGraphInitMSDK:BuildGraph()
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
    jn = JobNode.CreateNode("Finished", 0, 5, false, Job_InitMSDK_Finished_Impl.OnFinished, Job_InitMSDK_Finished_Impl.OnFinishedSuccess, Job_InitMSDK_Finished_Impl.OnFinishedFailed, Job_InitMSDK_Finished_Impl.OnFinishedTimeOut, Job_InitMSDK_Finished_Impl.OnFinishedDispose)
    csg:AddNode(jn)
    jn.X = 600
    jn.Y = -296
    jn = JobNode.CreateNode("Init", 0, 10, false, Job_InitMSDK_Init_Impl.OnInit, Job_InitMSDK_Init_Impl.OnInitSuccess, Job_InitMSDK_Init_Impl.OnInitFailed, Job_InitMSDK_Init_Impl.OnInitTimeOut, Job_InitMSDK_Init_Impl.OnInitDispose)
    csg:AddNode(jn)
    jn.X = -360
    jn.Y = -552
    jn = JobNode.CreateNode("LoginWithDid", 0, 10, false, Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDid, Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDidSuccess, Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDidFailed, Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDidTimeOut, Job_InitMSDK_LoginWithDid_Impl.OnLoginWithDidDispose)
    csg:AddNode(jn)
    jn.X = 344
    jn.Y = -552
    jn = JobNode.CreateNode("AccountInit", 0, 10, false, Job_InitMSDK_AccountInit_Impl.OnAccountInit, Job_InitMSDK_AccountInit_Impl.OnAccountInitSuccess, Job_InitMSDK_AccountInit_Impl.OnAccountInitFailed, Job_InitMSDK_AccountInit_Impl.OnAccountInitTimeOut, Job_InitMSDK_AccountInit_Impl.OnAccountInitDispose)
    csg:AddNode(jn)
    jn.X = -8
    jn.Y = -552
    jn = JobNode.CreateNode("GetAccountInfo", 0, 10, false, Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfo, Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfoSuccess, Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfoFailed, Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfoTimeOut, Job_InitMSDK_GetAccountInfo_Impl.OnGetAccountInfoDispose)
    csg:AddNode(jn)
    jn.X = -408
    jn.Y = -296
    jn = JobNode.CreateNode("AccountBinding", 0, 10, false, Job_InitMSDK_AccountBinding_Impl.OnAccountBinding, Job_InitMSDK_AccountBinding_Impl.OnAccountBindingSuccess, Job_InitMSDK_AccountBinding_Impl.OnAccountBindingFailed, Job_InitMSDK_AccountBinding_Impl.OnAccountBindingTimeOut, Job_InitMSDK_AccountBinding_Impl.OnAccountBindingDispose)
    csg:AddNode(jn)
    jn.X = 232
    jn.Y = -296
    jn = JobNode.CreateNode("UserAgreement", 0, 10, false, Job_InitMSDK_UserAgreement_Impl.OnUserAgreement, Job_InitMSDK_UserAgreement_Impl.OnUserAgreementSuccess, Job_InitMSDK_UserAgreement_Impl.OnUserAgreementFailed, Job_InitMSDK_UserAgreement_Impl.OnUserAgreementTimeOut, Job_InitMSDK_UserAgreement_Impl.OnUserAgreementDispose)
    csg:AddNode(jn)
    jn.X = -88
    jn.Y = -296
    csg:GetNode(1):AddTrigger(csg:GetNode(6))
    csg:GetNode(2):AddTrigger(csg:GetNode(0))
    csg:GetNode(3):AddTrigger(csg:GetNode(4))
    csg:GetNode(4):AddTrigger(csg:GetNode(2))
    csg:GetNode(5):AddTrigger(csg:GetNode(3))
    csg:GetNode(6):AddTrigger(csg:GetNode(7))
    csg:GetNode(7):AddTrigger(csg:GetNode(5))
    self.m_builded = true
  end
end

function JobGraphInitMSDK:Reset()
  if self.m_csGraph ~= nil then
    self.m_csGraph:Reset()
  end
end

function JobGraphInitMSDK:Run(callback)
  if self.m_csGraph ~= nil then
    self.m_csGraph:Run(callback)
  end
end

function JobGraphInitMSDK:OnGUI()
  if self.m_csGraph ~= nil then
    self.m_csGraph:OnGUI()
  end
end

function JobGraphInitMSDK:GetJobProgress()
  if self.m_csGraph ~= nil then
    return self.m_csGraph:GetJobProgress()
  end
  return 0
end

function JobGraphInitMSDK:Dispose()
  if __JobGraphs ~= nil then
    __JobGraphs.JobGraphInitMSDK = nil
  end
  JobGraphInitMSDK.s_instance = nil
  if self.m_csGraph ~= nil then
    return self.m_csGraph:Dispose()
  end
  self.m_csGraph = nil
end

return JobGraphInitMSDK
