local Job_Startup_CheckAccountState_Impl = {}

function Job_Startup_CheckAccountState_Impl.OnCheckAccountState(jobNode)
  Job_Startup_CheckAccountState_Impl.CheckAccountState()
  TimeService:SetTimer(1.0E-4, 1, function()
    jobNode.Status = JobStatus.Success
  end)
end

function Job_Startup_CheckAccountState_Impl:CheckAccountState()
  CS.AccountManager.Instance:RequestCDStatus(function(msdkCDResult)
    if not msdkCDResult then
      return
    end
    if msdkCDResult.resultCode == 0 then
      if msdkCDResult.resultAction == 0 then
        local stateAccount = msdkCDResult.msdkAccountCDStatus.state
        if stateAccount == 1 then
        else
          if stateAccount == 2 then
            StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERDELSUCCESSPOP, {isClamDown = true})
          else
          end
        end
      end
    elseif msdkCDResult.resultAction == 0 then
    end
  end)
end

function Job_Startup_CheckAccountState_Impl.OnCheckAccountStateSuccess(jobNode)
end

function Job_Startup_CheckAccountState_Impl.OnCheckAccountStateFailed(jobNode)
end

function Job_Startup_CheckAccountState_Impl.OnCheckAccountStateTimeOut(jobNode)
end

function Job_Startup_CheckAccountState_Impl.OnCheckAccountStateDispose(jobNode)
end

return Job_Startup_CheckAccountState_Impl
