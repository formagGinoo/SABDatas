local Job_InitMSDK_UserAgreement_Impl = {}

function Job_InitMSDK_UserAgreement_Impl.OnUserAgreement(jobNode)
  if CS.UnityEngine.Application.isEditor then
    jobNode.Status = JobStatus.Success
    return
  end
  local account = CS.MSDKLogin.Instance.Account
  if account and account.accountTPInfos ~= nil then
    jobNode.Status = JobStatus.Success
    if ChannelManager:IsEUChannel() and not ChannelManager:IsWindows() and CS.UserCentricsCtrl.Instance.bIsFirstInit then
      CS.UserCentricsCtrl.Instance:AcceptAll()
    end
    return
  end
  local hasTipUserAgreement = CS.UI.UILuaHelper.GetPlayerPreference("TipUserAgreement", 0)
  if hasTipUserAgreement == 1 then
    jobNode.Status = JobStatus.Success
    return
  end
  
  local function onUserAgreementformClose(agree)
    if agree then
      TimeService:SetTimer(0.1, 1, function()
        jobNode.Status = JobStatus.Success
        CS.UI.UILuaHelper.SetPlayerPreference("TipUserAgreement", 1)
      end)
    else
      jobNode.Status = JobStatus.Failed
      CS.ApplicationManager.Instance:RestartGame()
    end
  end
  
  StackPopup:Push(UIDefines.ID_FORM_PLAYERPROTOCOLPOP, onUserAgreementformClose)
  if ChannelManager:IsEUChannel() and not ChannelManager:IsWindows() then
    CS.UserCentricsCtrl.Instance:TrackShowCMP()
  end
end

function Job_InitMSDK_UserAgreement_Impl.OnUserAgreementSuccess(jobNode)
end

function Job_InitMSDK_UserAgreement_Impl.OnUserAgreementFailed(jobNode)
end

function Job_InitMSDK_UserAgreement_Impl.OnUserAgreementTimeOut(jobNode)
end

function Job_InitMSDK_UserAgreement_Impl.OnUserAgreementDispose(jobNode)
end

return Job_InitMSDK_UserAgreement_Impl
