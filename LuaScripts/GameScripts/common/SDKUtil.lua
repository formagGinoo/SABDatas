local json = require("common/json")
SDKUtil = {}
local MSDKLogin = CS.MSDKLogin.Instance
local SDKOperateTipID = {BindThirdParty = 50001}
SDKUtil.LoginMode = {
  Google = 1,
  FaceBook = 2,
  X = 3,
  Kakao = 4,
  TikTok = 5,
  InitiationCode = 6,
  Apple = 7
}
local sdkInstance

local function BoxTipByTextId(id)
  local sErrorTips = ""
  if 0 <= id then
    sErrorTips = CS.ConfFact.LangFormat4DataInit("MSDKErrorCode" .. tostring(id))
  else
    sErrorTips = CS.ConfFact.LangFormat4DataInit("MSDKErrorCodeM" .. tostring(-id))
  end
  utils.CheckAndPushCommonTips({
    content = sErrorTips,
    btnNum = 1,
    funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm")
  })
  return true
end

local function SDKLoginErrorResult(result)
  local resultCode = result.resultCode
  if not result.resultCode then
    resultCode = result.code
  end
  if resultCode == -1 then
    return
  end
  if resultCode == 5002010 or resultCode == 4000000 then
    resultCode = 5002041
  end
  if BoxTipByTextId(resultCode) then
    return
  end
  local errorMsg = result.resultMessage
  local findPos, _ = string.find(errorMsg, "errorMsg")
  if findPos then
    local msgBody = json.decode(errorMsg)
    if msgBody and msgBody.errorMsg then
      errorMsg = msgBody.errorMsg
    end
  end
  utils.CheckAndPushCommonTips({
    content = errorMsg,
    bUseSystemWord = true,
    btnNum = 1,
    funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm")
  })
end

local function SDKSuccess(tipId)
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tipId)
end

function SDKUtil.HasBindingWithThirdParty()
  local account = MSDKLogin.Account
  if account and account.accountTPInfos ~= nil then
    return true
  end
  return false
end

function SDKUtil.BindingWithThirdPartyNoneCallback()
  SDKUtil.BindingWithThirdParty(nil)
end

function SDKUtil.BindingWithThirdParty(thirdParty, onResult)
  local function sdkResult(isSucess, result)
    if not isSucess then
      SDKLoginErrorResult(result)
    end
    if onResult then
      onResult(isSucess)
    end
  end
  
  MSDKLogin:BindingWithThirdParty(thirdParty, sdkResult)
end

function SDKUtil.UnbindingWithThirdParty(thirdParty, onResult)
  local function sdkResult(isSucess, result)
    if not isSucess then
      SDKLoginErrorResult(result)
    end
    if onResult then
      onResult(isSucess)
    end
  end
  
  CS.MSDKLogin.Instance:UnbindingWithThirdParty(thirdParty, sdkResult)
end

function SDKUtil.LoginWithThirdParty(thirdParty, onResult)
  local function sdkResult(isSucess, result)
    if isSucess then
      SDKSuccess(SDKOperateTipID.BindThirdParty)
    else
      SDKLoginErrorResult(result)
    end
    if onResult then
      onResult(isSucess)
    end
  end
  
  MSDKLogin:LoginWithThirdParty(thirdParty, sdkResult)
end

function SDKUtil.GetTransferCode(onResult)
  local function sdkResult(result)
    if onResult then
      onResult(isSucess)
    end
  end
  
  MSDKLogin:GetTransferCode(onResult)
end

function SDKUtil.CreateTransferCode(onResult)
  local function sdkResult(isSucess, result)
    if not isSucess then
      SDKLoginErrorResult(result)
    end
    if onResult then
      onResult(result)
    end
  end
  
  MSDKLogin:CreateTransferCode("NovaTransferCode2024", onResult)
end

function SDKUtil.LoginWithTransferCode(code, onResult)
  local function sdkResult(isSucess, result)
    if not isSucess then
      SDKLoginErrorResult(result)
    end
    if onResult then
      onResult(isSucess)
    end
  end
  
  MSDKLogin:LoginWithTransferCode(code, "NovaTransferCode2024", sdkResult)
end

function SDKUtil.SwitchAccount(thirdParty)
  CS.MSDKLogin.Instance:LoginWithThirdParty(thirdParty, function(isSuccess, thirdParty)
    if isSuccess then
      if ChannelManager:IsChinaChannel() then
        CS.AIHelp.AIHelpSupport.ResetUserInfo()
      else
        CS.AiHelpManager.Instance:AiHelpResetUserInfo()
      end
      ApplicationManager:RestartGame()
    end
  end)
end

function SDKUtil.CheckIsShowLoginMode(loginMode)
  if ChannelManager:IsDMMChannel() then
    return false
  end
  if ChannelManager:IsWindows() and loginMode == SDKUtil.LoginMode.InitiationCode then
    return false
  end
  local id = CS.LuaCallCS.GetSystemLanguage()
  local versionContext = CS.VersionContext.GetContext() or {}
  local channel = versionContext.Channel or ""
  if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer and loginMode == SDKUtil.LoginMode.Google then
    return false
  end
  if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer and loginMode == SDKUtil.LoginMode.Apple then
    return true
  end
  if id == "Japanese" and (string.find(channel, "_jp") or string.find(channel, "_ap")) then
    return loginMode == SDKUtil.LoginMode.Google or loginMode == SDKUtil.LoginMode.FB or loginMode == SDKUtil.LoginMode.InitiationCode
  elseif id == "Korean" and string.find(channel, "_ap") then
    return loginMode == SDKUtil.LoginMode.Google or loginMode == SDKUtil.LoginMode.FB or loginMode == SDKUtil.LoginMode.Kakao
  elseif string.find(channel, "_ap") or string.find(channel, "_jp") then
    return loginMode == SDKUtil.LoginMode.Google or loginMode == SDKUtil.LoginMode.FB
  else
    return loginMode == SDKUtil.LoginMode.Google or loginMode == SDKUtil.LoginMode.FB
  end
end
