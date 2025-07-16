local BaseManager = require("Manager/Base/BaseManager")
local UserDataManager = class("UserDataManager", BaseManager)

function UserDataManager:OnCreate()
  self.m_iZoneID = 0
  self.m_iAccountID = 0
  self.m_sZoneName = nil
  self.m_sAccountName = nil
  self.m_sAndroidId = nil
  self.m_bEuropeOpenProtocol = false
end

function UserDataManager:GetZoneID()
  return self.m_iZoneID
end

function UserDataManager:SetZoneID(iZoneID)
  self.m_iZoneID = iZoneID
end

function UserDataManager:GetIsEuropeOpenProtocol()
  return self.m_bEuropeOpenProtocol
end

function UserDataManager:SetIsEuropeOpenProtocol(isEurope)
  self.m_bEuropeOpenProtocol = isEurope
end

function UserDataManager:GetZoneName()
  return self.m_sZoneName
end

function UserDataManager:SetZoneName(zoneNameStr)
  self.m_sZoneName = zoneNameStr
end

function UserDataManager:GetAccountID()
  return self.m_iAccountID
end

function UserDataManager:SetAccountID(iAccountID)
  self.m_iAccountID = iAccountID
end

function UserDataManager:GetAccountName()
  return self.m_sAccountName
end

function UserDataManager:SetAccountName(accountNameStr)
  self.m_sAccountName = accountNameStr
end

function UserDataManager:GetLoginGetZoneSC()
  return self.m_stLoginGetZoneSC
end

function UserDataManager:SetLoginGetZoneSC(stLoginGetZoneSC)
  self.m_stLoginGetZoneSC = stLoginGetZoneSC
end

function UserDataManager:GetLoginGetBulletinSC()
  return self.m_stLoginGetBulletinSC
end

function UserDataManager:GetBulletinUpgradeInfo()
  return self.m_vBulletinUpgradeInfo or {}
end

function UserDataManager:SetLoginGetBulletinSC(stLoginGetBulletinSC)
  self.m_stLoginGetBulletinSC = stLoginGetBulletinSC
  self.m_vBulletinUpgradeInfo = {}
  for k, v in ipairs(stLoginGetBulletinSC.vUpdateInfo) do
    local bContentMulti = false
    for k1, v1 in ipairs(v.vContent) do
      bContentMulti = true
      table.insert(self.m_vBulletinUpgradeInfo, {
        sTitle = v1.sTitle,
        sContent = v1.sContent
      })
    end
    if not bContentMulti then
      table.insert(self.m_vBulletinUpgradeInfo, {
        sTitle = v.sTitle,
        sContent = v.sContent
      })
    end
  end
end

function UserDataManager:GetAndroidID()
  return self.m_sAndroidId
end

function UserDataManager:SetAndroidID(sAndroidId)
  self.m_sAndroidId = sAndroidId
end

return UserDataManager
