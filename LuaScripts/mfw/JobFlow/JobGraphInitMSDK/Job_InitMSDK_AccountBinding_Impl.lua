local Job_InitMSDK_AccountBinding_Impl = {}

function Job_InitMSDK_AccountBinding_Impl.OnAccountBinding(jobNode)
  if CS.UnityEngine.Application.isEditor then
    jobNode.Status = JobStatus.Success
    return
  end
  if SDKUtil.HasBindingWithThirdParty() then
    jobNode.Status = JobStatus.Success
    return
  end
  local hasTipAccountBinding = CS.UI.UILuaHelper.GetPlayerPreference("TipAccountBinding", 0)
  if hasTipAccountBinding == 1 then
    jobNode.Status = JobStatus.Success
    return
  end
  
  local function onBindformClose(opType)
    CS.UI.UILuaHelper.SetPlayerPreference("TipAccountBinding", 1)
    jobNode.Status = JobStatus.Success
  end
  
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERACCOUNTBIND, onBindformClose)
end

function Job_InitMSDK_AccountBinding_Impl.OnAccountBindingSuccess(jobNode)
end

function Job_InitMSDK_AccountBinding_Impl.OnAccountBindingFailed(jobNode)
end

function Job_InitMSDK_AccountBinding_Impl.OnAccountBindingTimeOut(jobNode)
end

function Job_InitMSDK_AccountBinding_Impl.OnAccountBindingDispose(jobNode)
end

return Job_InitMSDK_AccountBinding_Impl
