platformType = CS.UnityEngine.Application.platform

function IsAndroidPlatform()
  if platformType == CS.UnityEngine.RuntimePlatform.Android then
    return true
  end
  return false
end

function IsIPhonePlatform()
  if platformType == CS.UnityEngine.RuntimePlatform.IPhonePlayer then
    return true
  end
  return false
end

function IsWindowsPlatform()
  if platformType == CS.UnityEngine.RuntimePlatform.WindowsPlayer then
    return true
  end
  return false
end

function IsWindowsEditor()
  if platformType == CS.UnityEngine.RuntimePlatform.WindowsEditor then
    return true
  end
  return false
end
