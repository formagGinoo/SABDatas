local BaseManager = require("Manager/Base/BaseManager")
local LegacyManager = class("LegacyManager", BaseManager)
LegacyManager.MaxLegacySkillNum = 3
LegacyManager.MaxLegacyHeroPos = 6

function LegacyManager:OnCreate()
  self.m_allLegacyDataDic = {}
  self.m_legacyCfgCache = {}
  self.m_legacyEnterStatusList = nil
end

function LegacyManager:OnInitNetwork()
  RPCS():Listen_Push_LegacyData(handler(self, self.OnPushLegacyData), "LegacyManager")
end

function LegacyManager:OnUpdate(dt)
end

function LegacyManager:OnAfterFreshData()
  self.LegacyIns = ConfigManager:GetConfigInsByName("Legacy")
  self.LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")
  self:ReqLegacyGetList()
end

function LegacyManager:OnPushLegacyData(stLegacyData, msg)
  if not stLegacyData then
    return
  end
  local tempLegacyData = stLegacyData.stLegacy
  if not tempLegacyData then
    return
  end
  self:__FreshLegacyData(tempLegacyData)
  self:broadcastEvent("eGameEvent_Legacy_Fresh", {
    legacyID = tempLegacyData.iLegacyId
  })
end

function LegacyManager:ReqLegacyGetList()
  local msg = MTTDProto.Cmd_Legacy_GetList_CS()
  RPCS():Legacy_GetList(msg, handler(self, self.OnLegacyGetListSC))
end

function LegacyManager:OnLegacyGetListSC(stLegacyListSC, msg)
  if not stLegacyListSC then
    return
  end
  local legacyDataDic = stLegacyListSC.mCmdLegacy
  if not legacyDataDic then
    return
  end
  for _, tempLegacyData in pairs(legacyDataDic) do
    self:__FreshLegacyData(tempLegacyData)
  end
end

function LegacyManager:ReqLegacyUpgrade(legacyID)
  if not legacyID then
    return
  end
  local msg = MTTDProto.Cmd_Legacy_Upgrade_CS()
  msg.iLegacyId = legacyID
  RPCS():Legacy_Upgrade(msg, handler(self, self.OnLegacyUpgradeSC))
end

function LegacyManager:OnLegacyUpgradeSC(stLegacyUpgrade, msg)
  if not stLegacyUpgrade then
    return
  end
  local legacyID = stLegacyUpgrade.iLegacyId
  self:broadcastEvent("eGameEvent_Legacy_Upgrade", {legacyID = legacyID})
end

function LegacyManager:ReqLegacyInstall(heroID, legacyID)
  if not heroID then
    return
  end
  if not legacyID then
    return
  end
  local msg = MTTDProto.Cmd_Legacy_Install_CS()
  msg.iHeroId = heroID
  msg.iLegacyId = legacyID
  RPCS():Legacy_Install(msg, handler(self, self.OnLegacyInstallSC))
end

function LegacyManager:OnLegacyInstallSC(stLegacyInstall, msg)
  if not stLegacyInstall then
    return
  end
  local heroID = stLegacyInstall.iHeroId
  local legacyID = stLegacyInstall.iLegacyId
  self:broadcastEvent("eGameEvent_Legacy_Install", {heroID = heroID, legacyID = legacyID})
end

function LegacyManager:ReqLegacyUninstall(heroID)
  if not heroID then
    return
  end
  local msg = MTTDProto.Cmd_Legacy_Uninstall_CS()
  msg.iHeroId = heroID
  RPCS():Legacy_Uninstall(msg, handler(self, self.OnLegacyUninstallSC))
end

function LegacyManager:OnLegacyUninstallSC(stLegacyUninstall, msg)
  if not stLegacyUninstall then
    return
  end
  local heroID = stLegacyUninstall.iHeroId
  local legacyID = stLegacyUninstall.iLegacyId
  self:broadcastEvent("eGameEvent_Legacy_UnInstall", {heroID = heroID, legacyID = legacyID})
end

function LegacyManager:ReqLegacySwap(srcHeroID, dstHeroID)
  if not srcHeroID then
    return
  end
  if not dstHeroID then
    return
  end
  local msg = MTTDProto.Cmd_Legacy_Swap_CS()
  msg.iSrcHeroId = srcHeroID
  msg.iDstHeroId = dstHeroID
  RPCS():Legacy_Swap(msg, handler(self, self.OnLegacySwapSC))
end

function LegacyManager:OnLegacySwapSC(stLegacySwap, msg)
  if not stLegacySwap then
    return
  end
  local srcHeroID = stLegacySwap.iSrcHeroId
  local dstHeroID = stLegacySwap.iDstHeroId
  local legacyID = stLegacySwap.iLegacyId
  self:broadcastEvent("eGameEvent_Legacy_Swap", {
    srcHeroID = srcHeroID,
    dstHeroID = dstHeroID,
    legacyID = legacyID
  })
end

function LegacyManager:ReqLegacyInstallBatch(heroIDList, legacyID)
  if not heroIDList then
    return
  end
  if not legacyID then
    return
  end
  local msg = MTTDProto.Cmd_Legacy_InstallBatch_CS()
  msg.vHeroId = heroIDList
  msg.iLegacyId = legacyID
  RPCS():Legacy_InstallBatch(msg, handler(self, self.OnLegacyInstallBatchSC))
end

function LegacyManager:OnLegacyInstallBatchSC(stLegacyInstallBatch, msg)
  if not stLegacyInstallBatch then
    return
  end
  local heroIDList = stLegacyInstallBatch.vHeroId
  local legacyID = stLegacyInstallBatch.iLegacyId
  self:broadcastEvent("eGameEvent_Legacy_InstallBatch", {heroIDList = heroIDList, legacyID = legacyID})
end

function LegacyManager:__FreshLegacyData(legacyData)
  if not legacyData then
    return
  end
  local legacyID = legacyData.iLegacyId
  if not legacyID then
    return
  end
  local cacheLegacyData = self.m_allLegacyDataDic[legacyID]
  if cacheLegacyData == nil then
    local legacyCfg = self:GetLegacyCfgByID(legacyID)
    cacheLegacyData = {legacyCfg = legacyCfg, serverData = legacyData}
    self.m_allLegacyDataDic[legacyID] = cacheLegacyData
  else
    cacheLegacyData.serverData = legacyData
  end
end

function LegacyManager:GetEnterLegacyIDList()
  if not self.m_legacyEnterStatusList then
    local legacyIDList
    local clientDataStr = ClientDataManager:GetClientValueStringByKey(ClientDataManager.ClientKeyType.LegacyGuide)
    if clientDataStr == nil or clientDataStr == "" then
      legacyIDList = {}
    else
      legacyIDList = string.split(clientDataStr, "|")
    end
    self.m_legacyEnterStatusList = legacyIDList
  end
  return self.m_legacyEnterStatusList
end

function LegacyManager:IsLegacyHaveEnter(legacyID)
  if not legacyID then
    return
  end
  local legacyIDList = self:GetEnterLegacyIDList()
  for _, tempIDStr in ipairs(legacyIDList) do
    local tempID = tonumber(tempIDStr)
    if tempID == legacyID then
      return true
    end
  end
  return false
end

function LegacyManager:InsertEnterLegacyID(legacyID)
  if not legacyID then
    return
  end
  local legacyIDList = self:GetEnterLegacyIDList()
  legacyIDList[#legacyIDList + 1] = legacyID
  self.m_legacyEnterStatusList = legacyIDList
end

function LegacyManager:GetEnterLegacyFormatStr()
  local legacyIDList = self:GetEnterLegacyIDList()
  local enterLegacyIDTab = {}
  for i, v in ipairs(legacyIDList) do
    if i == 1 then
      enterLegacyIDTab[#enterLegacyIDTab + 1] = tostring(v)
    else
      enterLegacyIDTab[#enterLegacyIDTab + 1] = "|"
      enterLegacyIDTab[#enterLegacyIDTab + 1] = tostring(v)
    end
  end
  if #enterLegacyIDTab == 0 then
    return ""
  else
    return table.concat(enterLegacyIDTab)
  end
end

function LegacyManager:GetLegacyCfgByID(legacyID)
  if not legacyID then
    return
  end
  if not self.LegacyIns then
    return
  end
  local legacyCfg = self.m_legacyCfgCache[legacyID]
  if not legacyCfg then
    legacyCfg = self.LegacyIns:GetValue_ByID(legacyID)
    if legacyCfg:GetError() then
      return
    end
  end
  return legacyCfg
end

function LegacyManager:GetLegacyDataByID(legacyID)
  if not legacyID then
    return
  end
  return self.m_allLegacyDataDic[legacyID]
end

function LegacyManager:GetLegacyDataList(excludeID)
  local legacyDataList = {}
  for legacyID, legacyData in pairs(self.m_allLegacyDataDic) do
    if legacyID ~= excludeID then
      legacyDataList[#legacyDataList + 1] = legacyData
    end
  end
  return legacyDataList
end

function LegacyManager:IsLegacyWareRedDot()
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Legacy)
  if not openFlag then
    return 0
  end
  if not self.m_allLegacyDataDic or not next(self.m_allLegacyDataDic) then
    return 0
  end
  local isWare = false
  for _, legacyData in pairs(self.m_allLegacyDataDic) do
    if legacyData.serverData.vEquipBy and next(legacyData.serverData.vEquipBy) then
      isWare = true
      break
    end
  end
  if isWare then
    return 0
  else
    return 1
  end
end

function LegacyManager:IsLegacyCanUpgrade(legacyID)
  if not legacyID then
    return 0
  end
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Legacy)
  if not openFlag then
    return 0
  end
  local legacyData = self:GetLegacyDataByID(legacyID)
  if not legacyData then
    return 0
  end
  local legacyLv = legacyData.serverData.iLevel or 0
  if legacyLv == 0 then
    return 0
  end
  local legacyLvCfg = self.LegacyLevelIns:GetValue_ByIDAndLevel(legacyID, legacyLv)
  if legacyLvCfg:GetError() == true then
    return 0
  end
  local itemCostArray = legacyLvCfg.m_ItemCost
  if itemCostArray and itemCostArray.Length == 0 then
    return 0
  end
  local itemCount = itemCostArray.Length
  local isEnough = true
  for i = 1, itemCount do
    local tempItem = itemCostArray[i - 1]
    local itemID = tonumber(tempItem[0])
    local itemNum = tonumber(tempItem[1])
    local haveNum = ItemManager:GetItemNum(itemID, true)
    if itemNum > haveNum then
      isEnough = false
      break
    end
  end
  if isEnough then
    return 1
  else
    return 0
  end
end

function LegacyManager:SetLegacyEnter(legacyID)
  if not legacyID then
    return
  end
  local isHaveCacheEnter = self:IsLegacyHaveEnter(legacyID)
  if isHaveCacheEnter == true then
    return
  end
  self:InsertEnterLegacyID(legacyID)
  local formatStr = self:GetEnterLegacyFormatStr()
  ClientDataManager:SetClientValue(ClientDataManager.ClientKeyType.LegacyGuide, formatStr)
  self:broadcastEvent("eGameEvent_Legacy_SetLegacyEnter")
end

function LegacyManager:IsLegacyEnterHaveRedDot(legacyID)
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Legacy)
  if not openFlag then
    return 0
  end
  if not legacyID then
    return 0
  end
  local legacyData = self.m_allLegacyDataDic[legacyID]
  if not legacyData then
    return 0
  end
  local isLegacyHaveEnter = self:IsLegacyHaveEnter(legacyID)
  if isLegacyHaveEnter == true then
    return 0
  end
  return 1
end

function LegacyManager:IsAllLegacyEnterHaveRedDot()
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Legacy)
  if not openFlag then
    return 0
  end
  for _, tempLegacyData in pairs(self.m_allLegacyDataDic) do
    local tempRedDotPoint = self:IsLegacyEnterHaveRedDot(tempLegacyData.serverData.iLegacyId) or 0
    if 0 < tempRedDotPoint then
      return 1
    end
  end
  return 0
end

return LegacyManager
