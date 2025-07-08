local Job_InitGSDK_FetchRealNameState_Impl = {}

function Job_InitGSDK_FetchRealNameState_Impl.OnFetchRealNameState(jobNode)
  GSDKManager:FetchRealNameState(function(isSuccess, code)
    if isSuccess then
      jobNode.Status = JobStatus.Success
    else
      jobNode.Status = JobStatus.Failed
    end
  end)
end

function Job_InitGSDK_FetchRealNameState_Impl.OnFetchRealNameStateSuccess(jobNode)
end

function Job_InitGSDK_FetchRealNameState_Impl.OnFetchRealNameStateFailed(jobNode)
end

function Job_InitGSDK_FetchRealNameState_Impl.OnFetchRealNameStateTimeOut(jobNode)
end

function Job_InitGSDK_FetchRealNameState_Impl.OnFetchRealNameStateDispose(jobNode)
end

return Job_InitGSDK_FetchRealNameState_Impl
