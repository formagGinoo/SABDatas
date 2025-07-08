local BaseManager = require("Manager/Base/BaseManager")
local LocalDataManager = class("LocalDataManager", BaseManager)

function LocalDataManager:OnCreate()
  self.m_mSavedCache = {}
end

function LocalDataManager:GenLocalDataKey(key, iAccountID, iZoneID)
  if key == nil then
    return ""
  end
  return string.format("%s_%s_%s", key, tostring(iAccountID or 0), tostring(iZoneID or 0))
end

function LocalDataManager:GetInt(key, default, iAccountID, iZoneID)
  local sKey = self:GenLocalDataKey(key, iAccountID, iZoneID)
  if sKey == "" then
    return default
  end
  local iDefault = checknumber(default)
  if self.m_mSavedCache[sKey] == nil then
    self.m_mSavedCache[sKey] = CS.UnityEngine.PlayerPrefs.GetInt(sKey, iDefault)
  end
  return self.m_mSavedCache[sKey]
end

function LocalDataManager:GetIntSimple(key, default)
  return self:GetInt(key, default, UserDataManager:GetAccountID(), UserDataManager:GetZoneID())
end

function LocalDataManager:SetInt(key, value, iAccountID, iZoneID, bFlush)
  local sKey = self:GenLocalDataKey(key, iAccountID, iZoneID)
  if sKey == "" then
    return
  end
  local iValue = checknumber(value)
  self.m_mSavedCache[sKey] = iValue
  CS.UnityEngine.PlayerPrefs.SetInt(sKey, iValue)
  if bFlush then
    CS.UnityEngine.PlayerPrefs.Save()
  end
end

function LocalDataManager:SetIntSimple(key, value, bFlush)
  return self:SetInt(key, value, UserDataManager:GetAccountID(), UserDataManager:GetZoneID(), bFlush)
end

function LocalDataManager:GetFloat(key, default, iAccountID, iZoneID)
  local sKey = self:GenLocalDataKey(key, iAccountID, iZoneID)
  if sKey == "" then
    return default
  end
  local fDefault = checknumber(default)
  if self.m_mSavedCache[sKey] == nil then
    self.m_mSavedCache[sKey] = CS.UnityEngine.PlayerPrefs.GetFloat(sKey, fDefault)
  end
  return self.m_mSavedCache[sKey]
end

function LocalDataManager:GetFloatSimple(key, default)
  return self:GetFloat(key, default, UserDataManager:GetAccountID(), UserDataManager:GetZoneID())
end

function LocalDataManager:SetFloat(key, value, iAccountID, iZoneID, bFlush)
  local sKey = self:GenLocalDataKey(key, iAccountID, iZoneID)
  if sKey == "" then
    return
  end
  local fValue = checknumber(value)
  self.m_mSavedCache[sKey] = fValue
  CS.UnityEngine.PlayerPrefs.SetFloat(sKey, fValue)
  if bFlush then
    CS.UnityEngine.PlayerPrefs.Save()
  end
end

function LocalDataManager:SetFloatSimple(key, value, bFlush)
  return self:SetFloat(key, value, UserDataManager:GetAccountID(), UserDataManager:GetZoneID(), bFlush)
end

function LocalDataManager:GetString(key, default, iAccountID, iZoneID)
  local sKey = self:GenLocalDataKey(key, iAccountID, iZoneID)
  if sKey == "" then
    return default
  end
  local sDefault = tostring(default or "")
  if self.m_mSavedCache[sKey] == nil then
    self.m_mSavedCache[sKey] = CS.UnityEngine.PlayerPrefs.GetString(sKey, sDefault)
  end
  return self.m_mSavedCache[sKey]
end

function LocalDataManager:GetStringSimple(key, default)
  return self:GetString(key, default, UserDataManager:GetAccountID(), UserDataManager:GetZoneID())
end

function LocalDataManager:SetString(key, value, iAccountID, iZoneID, bFlush)
  local sKey = self:GenLocalDataKey(key, iAccountID, iZoneID)
  if sKey == "" then
    return
  end
  local sValue = tostring(value or "")
  self.m_mSavedCache[sKey] = sValue
  CS.UnityEngine.PlayerPrefs.SetString(sKey, sValue)
  if bFlush then
    CS.UnityEngine.PlayerPrefs.Save()
  end
end

function LocalDataManager:SetStringSimple(key, value, bFlush)
  return self:SetString(key, value, UserDataManager:GetAccountID(), UserDataManager:GetZoneID(), bFlush)
end

function LocalDataManager:DeleteKey(key, iAccountID, iZoneID)
  local sKey = self:GenLocalDataKey(key, iAccountID, iZoneID)
  if sKey == "" then
    return
  end
  CS.UnityEngine.PlayerPrefs.DeleteKey(sKey)
end

function LocalDataManager:DeleteKeySimple(key)
  return self:DeleteKey(key, UserDataManager:GetAccountID(), UserDataManager:GetZoneID())
end

return LocalDataManager
