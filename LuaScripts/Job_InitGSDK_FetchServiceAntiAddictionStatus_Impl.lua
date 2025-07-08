local Job_InitGSDK_FetchServiceAntiAddictionStatus_Impl = {}

function Job_InitGSDK_FetchServiceAntiAddictionStatus_Impl.OnFetchServiceAntiAddictionStatus(jobNode)
  GSDKManager:FetchServiceAntiAddictionStatusFromServer(function(isSuccess, code)
    if isSuccess then
      log.info("FetchServiceAntiAddictionStatusFromServer Success")
      jobNode.Status = JobStatus.Success
    else
      log.info("FetchServiceAntiAddictionStatusFromServer Failed")
      jobNode.Status = JobStatus.Failed
    end
  end)
end

function Job_InitGSDK_FetchServiceAntiAddictionStatus_Impl.OnFetchServiceAntiAddictionStatusSuccess(jobNode)
end

function Job_InitGSDK_FetchServiceAntiAddictionStatus_Impl.OnFetchServiceAntiAddictionStatusFailed(jobNode)
end

function Job_InitGSDK_FetchServiceAntiAddictionStatus_Impl.OnFetchServiceAntiAddictionStatusTimeOut(jobNode)
end

function Job_InitGSDK_FetchServiceAntiAddictionStatus_Impl.OnFetchServiceAntiAddictionStatusDispose(jobNode)
end

return Job_InitGSDK_FetchServiceAntiAddictionStatus_Impl
