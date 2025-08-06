local BaseManager = require("Manager/Base/BaseManager")
local EquipManager = class("EquipManager", BaseManager)

function EquipManager:OnCreate()
  self.m_EquipList = {}
  self.m_equipCfgCacheList = {}
end

function EquipManager:OnInitNetwork()
  RPCS():Listen_Push_EquipList(handler(self, self.OnPushSetEquipData), "EquipManager")
  RPCS():Listen_Push_DelEquip(handler(self, self.OnPushDelEquipData), "EquipManager")
end

function EquipManager:OnAfterInitConfig()
  self.m_equipCfgIns = ConfigManager:GetConfigInsByName("Equipment")
  self.m_equipCfgCacheList = {}
end

function EquipManager:ReqInstallEquip(iHeroId, iPos, iEquipUid)
  local reqMsg = MTTDProto.Cmd_Hero_InstallEquip_CS()
  reqMsg.iHeroId = iHeroId
  reqMsg.iPos = iPos
  reqMsg.iEquipUid = iEquipUid
  RPCS():Hero_InstallEquip(reqMsg, handler(self, self.OnReqInstallEquipSC))
end

function EquipManager:ReqUnInstallEquip(iHeroId, iPos)
  local reqMsg = MTTDProto.Cmd_Hero_UninstallEquip_CS()
  reqMsg.iHeroId = iHeroId
  reqMsg.iPos = iPos
  RPCS():Hero_UninstallEquip(reqMsg, handler(self, self.OnReqUnInstallEquipSC))
end

function EquipManager:ReqInstallEquipBatch(iHeroId, equipDataList)
  local reqMsg = MTTDProto.Cmd_Hero_InstallEquipBatch_CS()
  reqMsg.iHeroId = iHeroId
  reqMsg.mEquip = equipDataList
  RPCS():Hero_InstallEquipBatch(reqMsg, handler(self, self.OnReqInstallEquipBatchSC))
end

function EquipManager:ReqUnInstallAllEquip(iHeroId)
  local reqMsg = MTTDProto.Cmd_Hero_UninstallAllEquip_CS()
  reqMsg.iHeroId = iHeroId
  RPCS():Hero_UninstallAllEquip(reqMsg, handler(self, self.OnReqUnInstallAllEquipSC))
end

function EquipManager:ReqSwapEquip(iSrcHeroId, iDstHeroId, iPos)
  local reqMsg = MTTDProto.Cmd_Hero_SwapEquip_CS()
  reqMsg.iSrcHeroId = iSrcHeroId
  reqMsg.iDstHeroId = iDstHeroId
  reqMsg.iPos = iPos
  RPCS():Hero_SwapEquip(reqMsg, handler(self, self.OnReqSwapEquipSC))
end

function EquipManager:ReqEquipAddExp(iEquipUid, vUseItem, vUseEquip)
  local reqMsg = MTTDProto.Cmd_Equip_AddExp_CS()
  reqMsg.iEquipUid = iEquipUid
  reqMsg.vUseItem = vUseItem
  reqMsg.vUseEquip = vUseEquip
  RPCS():Equip_AddExp(reqMsg, handler(self, self.OnReqEquipAddExpSC))
end

function EquipManager:OnReqEquipAddExpSC(stEquipData, msg)
  self:broadcastEvent("eGameEvent_Equip_AddExp", {
    iLevel = stEquipData.iLevel,
    vReturnItem = stEquipData.vReturnItem,
    iExp = stEquipData.iExp
  })
end

function EquipManager:OnPushSetEquipData(stEquipData, msg)
  local equipList = stEquipData.vEquipList
  for i, v in pairs(equipList) do
    local index = self:CheckIsHaveEquip(v.iEquipUid)
    if 0 < index then
      self.m_EquipList[index] = v
    else
      self.m_EquipList[#self.m_EquipList + 1] = v
    end
  end
  self:broadcastEvent("eGameEvent_Equip_SetEquip")
end

function EquipManager:ClientUpdateEquipData(vEquipList)
  self:OnPushSetEquipData({vEquipList = vEquipList})
end

function EquipManager:OnPushDelEquipData(stEquipData, msg)
  local equipList = stEquipData.vEquipUid or {}
  for i, iEquipUid in pairs(equipList) do
    local index = self:CheckIsHaveEquip(iEquipUid)
    if 0 < index then
      table.remove(self.m_EquipList, index)
    end
  end
  self:broadcastEvent("eGameEvent_Equip_DelEquip")
end

function EquipManager:OnEquipGetListSC(stEquipListData, msg)
  log.info("EquipManager OnEquipGetListSC stEquipListData: ", tostring(stEquipListData))
  self.m_EquipList = {}
  local equipDataList = stEquipListData.mCmdEquips
  for _, v in pairs(equipDataList) do
    self.m_EquipList[#self.m_EquipList + 1] = v
  end
end

function EquipManager:OnReqInstallEquipSC(stEquipData, msg)
  local heroId = stEquipData.iHeroId
  local pos = stEquipData.iPos
  local equipId = stEquipData.iEquipUid
  self:broadcastEvent("eGameEvent_Equip_InstallEquip", pos)
end

function EquipManager:OnReqUnInstallEquipSC(stEquipData, msg)
  local heroId = stEquipData.iHeroId
  local pos = stEquipData.iPos
  self:broadcastEvent("eGameEvent_Equip_UnInstallEquip", pos)
end

function EquipManager:OnReqInstallEquipBatchSC(stEquipData, msg)
  self:broadcastEvent("eGameEvent_Equip_InstallEquip", stEquipData.mEquip)
end

function EquipManager:OnReqUnInstallAllEquipSC(stEquipData, msg)
  local heroId = stEquipData.iHeroId
  local pos = stEquipData.iPos
  self:broadcastEvent("eGameEvent_Equip_UnInstallEquip", pos)
end

function EquipManager:OnReqSwapEquipSC(stEquipData, msg)
  local heroId = stEquipData.iHeroId
  local pos = stEquipData.iPos
  self:broadcastEvent("eGameEvent_Equip_UnInstallEquip", pos)
end

function EquipManager:OnReqEquipOverload(iEquipUid)
  local reqMsg = MTTDProto.Cmd_Equip_Overload_CS()
  reqMsg.iEquipUid = iEquipUid
  RPCS():Equip_Overload(reqMsg, handler(self, self.OnReqEquipOverloadSC))
end

function EquipManager:OnReqEquipOverloadSC(stData, msg)
  self:broadcastEvent("eGameEvent_Equip_Overload", stData.iEquipUid)
end

function EquipManager:OnReqEquipSetEffectLock(iEquipUid, iSlot, bLock)
  local reqMsg = MTTDProto.Cmd_Equip_SetEffectLock_CS()
  reqMsg.iEquipUid = iEquipUid
  reqMsg.iSlot = iSlot
  reqMsg.bLock = bLock
  RPCS():Equip_SetEffectLock(reqMsg, handler(self, self.OnReqSetEffectLockSC))
end

function EquipManager:OnReqSetEffectLockSC(stData, msg)
  local equipData = self:GetEquipDataByID(stData.iEquipUid)
  if equipData then
    local equipDataNew = table.deepcopy(equipData)
    if equipDataNew.mOverloadEffect and equipDataNew.mOverloadEffect[stData.iSlot] then
      equipDataNew.mOverloadEffect[stData.iSlot].bLock = stData.bLock
      self:ClientUpdateEquipData({equipDataNew})
    end
  end
  self:broadcastEvent("eGameEvent_SetEffectLock", stData)
  if equipData and equipData.iOverloadHero then
    local heroData = HeroManager:GetHeroDataByID(equipData.iOverloadHero)
    local serverData = table.deepcopy(heroData.serverData)
    for i, v in pairs(serverData.mEquip) do
      if v.iEquipUid == stData.iEquipUid and v.mOverloadEffect[stData.iSlot] then
        v.mOverloadEffect[stData.iSlot].bLock = stData.bLock
      end
    end
    self:broadcastEvent("eGameEvent_OtherSystem_UpdateHeroData", serverData)
  end
end

function EquipManager:OnReqEquipReOverload(iEquipUid, bLevel)
  local reqMsg = MTTDProto.Cmd_Equip_ReOverload_CS()
  reqMsg.iEquipUid = iEquipUid
  reqMsg.bLevel = bLevel
  RPCS():Equip_ReOverload(reqMsg, handler(self, self.OnReqReOverloadSC))
end

function EquipManager:OnReqReOverloadSC(stData, msg)
  self:broadcastEvent("eGameEvent_ReOverload", stData.iEquipUid)
  local equipData = self:GetEquipDataByID(stData.iEquipUid)
  if equipData and equipData.iOverloadHero then
    local heroData = HeroManager:GetHeroDataByID(equipData.iOverloadHero)
    local serverData = table.deepcopy(heroData.serverData)
    for i, v in pairs(serverData.mEquip) do
      if v.iEquipUid == stData.iEquipUid then
        v.mChangingEffect = table.deepcopy(equipData.mChangingEffect)
      end
    end
    self:broadcastEvent("eGameEvent_OtherSystem_UpdateHeroData", serverData)
  end
end

function EquipManager:OnReqEquipSaveReOverload(iEquipUid, bSave)
  local reqMsg = MTTDProto.Cmd_Equip_SaveReOverload_CS()
  reqMsg.iEquipUid = iEquipUid
  reqMsg.bSave = bSave
  RPCS():Equip_SaveReOverload(reqMsg, handler(self, self.OnReqSaveReOverloadSC))
end

function EquipManager:OnReqSaveReOverloadSC(stData, msg)
  self:broadcastEvent("eGameEvent_SaveReOverload", stData)
end

function EquipManager:GetEquipList()
  return self.m_EquipList
end

function EquipManager:GetUnOverLoadEquipDataList()
  local tempHeroIdList = {}
  for _, v in ipairs(self.m_EquipList) do
    if v.iOverloadHero == 0 and v.iHeroId == 0 then
      tempHeroIdList[#tempHeroIdList + 1] = {
        iID = v.iBaseId,
        iNum = 1,
        data = v
      }
    end
  end
  return tempHeroIdList
end

function EquipManager:GetUnOverLoadEquipDataListByPos(pos)
  if not pos then
    return
  end
  local equipList = {}
  for _, v in ipairs(self.m_EquipList) do
    local cfg = self:GetEquipCfgByBaseId(v.iBaseId)
    if cfg and cfg.m_PosRes == pos and v.iOverloadHero == 0 and v.iHeroId == 0 then
      equipList[#equipList + 1] = {
        iID = v.iBaseId,
        iNum = 1,
        data = v
      }
    end
  end
  return equipList
end

function EquipManager:GetEquipDataByID(equipID)
  if not equipID then
    return
  end
  for _, v in ipairs(self.m_EquipList) do
    if v.iEquipUid == equipID then
      return v
    end
  end
  return nil
end

function EquipManager:GetEquipDataByCfgID(cfgID)
  if not cfgID then
    return
  end
  local equipList = {}
  for _, v in ipairs(self.m_EquipList) do
    if v.iBaseId == cfgID then
      equipList[#equipList + 1] = v
    end
  end
  return equipList
end

function EquipManager:GetEquipNumByCfgID(cfgID)
  local list = self:GetEquipDataByCfgID(cfgID) or {}
  return #list
end

function EquipManager:GetEquipDataByPos(pos)
  if not pos then
    return
  end
  local equipList = {}
  for _, v in ipairs(self.m_EquipList) do
    local cfg = self:GetEquipCfgByBaseId(v.iBaseId)
    if cfg and cfg.m_PosRes == pos then
      equipList[#equipList + 1] = v
    end
  end
  return equipList
end

function EquipManager:GetEquipCfgById(equipId)
  local equipData = self:GetEquipDataByID(equipId)
  if not equipData then
    log.error("can not GetEquipCfgById equipId == " .. tostring(equipId))
    return
  end
  local cfgData = self:GetEquipCfgByBaseId(equipData.iBaseId)
  return cfgData
end

function EquipManager:GetUnEquippedEquips()
  local equipList = {}
  for _, v in ipairs(self.m_EquipList) do
    if v.iHeroId == 0 then
      equipList[#equipList + 1] = v
    end
  end
  return equipList
end

function EquipManager:GetUnEquippedEquipsById(equipUid)
  local equipList = {}
  for _, v in ipairs(self.m_EquipList) do
    if v.iHeroId == 0 and v.iEquipUid ~= equipUid then
      equipList[#equipList + 1] = v
    end
  end
  return equipList
end

function EquipManager:GetEquipCfgByBaseId(cfgId)
  if not cfgId then
    log.error("EquipManager GetEquipCfgByBaseId cfgId == nil")
    return
  end
  if self.m_equipCfgCacheList[cfgId] then
    return self.m_equipCfgCacheList[cfgId]
  end
  if not self.m_equipCfgIns or self.m_equipCfgIns:GetCount() <= 0 then
    self.m_equipCfgIns = ConfigManager:GetConfigInsByName("Equipment")
  end
  local equipCfg = self.m_equipCfgIns:GetValue_ByEquipID(cfgId)
  if equipCfg:GetError() then
    return
  end
  self.m_equipCfgCacheList[cfgId] = equipCfg
  return equipCfg
end

function EquipManager:GetEquipByPosAndEquipType(pos, equipType, heroId, unEquipped)
  local equipList = {}
  if not pos or not equipType then
    log.error("EquipManager GetEquipByPosAndEquipType pos == nil or equipType == nil")
    return equipList
  end
  for _, v in ipairs(self.m_EquipList) do
    if (not unEquipped or unEquipped and v.iHeroId == 0) and v.iOverloadHero == 0 then
      local cfg = self:GetEquipCfgByBaseId(v.iBaseId)
      if cfg and cfg.m_PosRes == pos then
        local equipTypeRes = cfg.m_EquiptypeRes
        if equipType == equipTypeRes and (not heroId or heroId ~= v.iHeroId) then
          equipList[#equipList + 1] = {equipData = v, cfg = cfg}
        end
      end
    end
  end
  return equipList
end

function EquipManager:GetEquipListByEquipType(heroCfg, equippedDataList, unEquipped)
  local equipList = {}
  if not heroCfg then
    log.error("EquipManager GetEquipListByEquipType pos == nil or equipType == nil")
    return equipList
  end
  local equipType = heroCfg.m_Equiptype
  for _, v in ipairs(self.m_EquipList) do
    if (not unEquipped or unEquipped and v.iHeroId == 0) and v.iOverloadHero == 0 then
      local cfg = self:GetEquipCfgByBaseId(v.iBaseId)
      if (not equippedDataList[cfg.m_PosRes] or equippedDataList[cfg.m_PosRes].iOverloadHero == 0) and equipType == cfg.m_EquiptypeRes then
        if cfg and not equipList[cfg.m_PosRes] then
          equipList[cfg.m_PosRes] = {equipData = v, cfg = cfg}
        end
        if equipList[cfg.m_PosRes] then
          equipList[cfg.m_PosRes] = self:GetTheBestOfTwoEquips(equipList[cfg.m_PosRes], {equipData = v, cfg = cfg}, heroCfg.m_Camp)
        end
      end
    end
  end
  return equipList
end

function EquipManager:GetTheBestOfTwoEquips(equip1, equip2, heroCamp)
  local equipData1 = equip1.equipData
  local equipData2 = equip2.equipData
  local equipCfg1 = equip1.cfg
  local equipCfg2 = equip2.cfg
  if equipCfg1.m_Quality == equipCfg2.m_Quality then
    local equipCamp1 = equipCfg1.m_BonusCamp == heroCamp and 1 or 0
    local equipCamp2 = equipCfg2.m_BonusCamp == heroCamp and 1 or 0
    if equipCamp1 == equipCamp2 then
      return equipData1.iLevel > equipData2.iLevel and equip1 or equip2
    else
      return equipCamp1 > equipCamp2 and equip1 or equip2
    end
  else
    return equipCfg1.m_Quality > equipCfg2.m_Quality and equip1 or equip2
  end
end

function EquipManager:GetEquipCampExtAtt(baseId)
  if not baseId then
    log.error("EquipManager GetEquipCampExtAtt error baseId == nil  ")
    return
  end
  local cfg = self:GetEquipCfgByBaseId(baseId)
  if not cfg then
    log.error("EquipManager GetEquipAttrByBaseIdAndLv error baseId == " .. baseId)
    return
  end
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local PropertyIns = ConfigManager:GetConfigInsByName("Property")
  local EquipLevelIns = ConfigManager:GetConfigInsByName("EquipLevel")
  local levelTemplateID = cfg.m_LevelTemplate
  local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplateID, 0)
  if not lvCfg then
    return
  end
  local attrDic = {}
  local basePropertyCfg = PropertyIns:GetValue_ByPropertyID(lvCfg.m_PropertyID)
  local propertyIndexCfg = PropertyIndexIns:GetAll()
  for attrId, v in pairs(propertyIndexCfg) do
    if v.m_Compute == 1 then
      local propertyNum = basePropertyCfg["m_" .. v.m_ENName]
      local attParam = cfg["m_" .. v.m_ENName .. "Param"]
      if attParam and 0 < attParam then
        propertyNum = math.floor(propertyNum * attParam / 10000)
      end
      if v.m_ENName and propertyNum and 0 < propertyNum then
        attrDic[v.m_ENName] = propertyNum
      end
    end
  end
  return attrDic
end

function EquipManager:GetEquipBaseAttr(baseId, lv, campAdd)
  if not baseId or not lv then
    log.error("EquipManager GetEquipAttrByBaseIdAndLv error baseId == nil  or lv == nil ")
    return
  end
  local cfg = self:GetEquipCfgByBaseId(baseId)
  if not cfg then
    log.error("EquipManager GetEquipAttrByBaseIdAndLv error baseId == " .. baseId)
    return
  end
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local PropertyIns = ConfigManager:GetConfigInsByName("Property")
  local EquipLevelIns = ConfigManager:GetConfigInsByName("EquipLevel")
  local levelTemplateID = cfg.m_LevelTemplate
  local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplateID, lv)
  if not lvCfg then
    return
  end
  local attrInfoList = {}
  local attrList = {}
  local attrDic = {}
  local basePropertyCfg = PropertyIns:GetValue_ByPropertyID(lvCfg.m_PropertyID)
  local propertyIndexCfg = PropertyIndexIns:GetAll()
  for attrId, v in pairs(propertyIndexCfg) do
    if v.m_Compute == 1 then
      local propertyNum = basePropertyCfg["m_" .. v.m_ENName]
      local attParam = cfg["m_" .. v.m_ENName .. "Param"]
      if campAdd and attParam and 0 < attParam then
        local addAttrs = self:GetEquipCampExtAtt(baseId)
        if 0 < table.getn(addAttrs) and addAttrs[v.m_ENName] then
          propertyNum = propertyNum + (addAttrs[v.m_ENName] or 0)
        end
      end
      if v.m_ENName and propertyNum and 0 < propertyNum then
        attrInfoList[#attrInfoList + 1] = {
          cfg = v,
          num = propertyNum,
          id = attrId
        }
        attrList[#attrList + 1] = {attrId, propertyNum}
      end
      attrDic[v.m_ENName] = propertyNum
    end
  end
  return attrInfoList, attrList, attrDic
end

function EquipManager:GetEquipOverLoadBaseAttr(baseId, lv)
  if not baseId or not lv then
    log.error("EquipManager GetEquipAttrByBaseIdAndLv error baseId == nil  or lv == nil ")
    return
  end
  local cfg = self:GetEquipCfgByBaseId(baseId)
  if not cfg then
    log.error("EquipManager GetEquipAttrByBaseIdAndLv error baseId == " .. baseId)
    return
  end
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local PropertyIns = ConfigManager:GetConfigInsByName("Property")
  local EquipLevelIns = ConfigManager:GetConfigInsByName("EquipLevel")
  local overloadLevelTemplateID = cfg.m_OverloadLevelTemplate
  local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(overloadLevelTemplateID, lv)
  if not lvCfg then
    return
  end
  local attrInfoList = {}
  local attrList = {}
  local attrDic = {}
  local basePropertyCfg = PropertyIns:GetValue_ByPropertyID(lvCfg.m_PropertyID)
  local propertyIndexCfg = PropertyIndexIns:GetAll()
  for attrId, v in pairs(propertyIndexCfg) do
    if v.m_Compute == 1 then
      local propertyNum = basePropertyCfg["m_" .. v.m_ENName]
      if v.m_ENName and propertyNum and 0 < propertyNum then
        attrInfoList[#attrInfoList + 1] = {
          cfg = v,
          num = propertyNum,
          id = attrId
        }
        attrList[#attrList + 1] = {attrId, propertyNum}
      end
      attrDic[v.m_ENName] = propertyNum
    end
  end
  return attrInfoList, attrList, attrDic
end

function EquipManager:GetEquipOverLoadExAttr(iEquipUid)
  local equipData = self:GetEquipDataByID(iEquipUid)
  local attrInfoList = {}
  local attrList = {}
  local attrDic = {}
  if equipData and equipData.mOverloadEffect and table.getn(equipData.mOverloadEffect) > 0 then
    local PropertyIns = ConfigManager:GetConfigInsByName("Property")
    local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
    local propertyIndexCfg = PropertyIndexIns:GetAll()
    local attrOverloadEffect = equipData.mOverloadEffect
    for pos, propertyID in pairs(attrOverloadEffect) do
      local basePropertyCfg = PropertyIns:GetValue_ByPropertyID(propertyID)
      for attrId, v in pairs(propertyIndexCfg) do
        if v.m_Compute == 1 then
          local propertyNum = basePropertyCfg["m_" .. v.m_ENName]
          if v.m_ENName and propertyNum and 0 < propertyNum then
            attrInfoList[pos] = {
              cfg = v,
              num = propertyNum,
              id = attrId
            }
            attrList[pos] = {attrId, propertyNum}
          end
          if not attrDic[v.m_ENName] then
            attrDic[v.m_ENName] = propertyNum
          else
            attrDic[v.m_ENName] = attrDic[v.m_ENName] + propertyNum
          end
        end
      end
    end
  end
  return attrInfoList, attrList, attrDic
end

function EquipManager:GetHeroEquippedDataByHeroServerData(severHeroData)
  local equipDataMap = severHeroData.mEquip
  if not equipDataMap then
    return
  end
  local retTab = {}
  for pos, equipData in pairs(equipDataMap) do
    local tmp = {
      equipBaseId = equipData.iBaseId,
      level = equipData.iLevel,
      iOverloadHero = equipData.iOverloadHero
    }
    retTab[#retTab + 1] = tmp
  end
  return retTab
end

function EquipManager:GetEquipAttrByParam(iHeroId, equipBaseId, level)
  if not (iHeroId and equipBaseId) or not level then
    return
  end
  local flag = self:CheckIsShowCampAttAddExtByCfgId(equipBaseId, iHeroId)
  local _, _, attrDic = self:GetEquipBaseAttr(equipBaseId, level, flag)
  return attrDic
end

function EquipManager:GetEquipOverLoadAttrByParam(iHeroId, equipBaseId, level)
  if not (iHeroId and equipBaseId) or not level then
    return
  end
  local _, _, attrDic = self:GetEquipOverLoadBaseAttr(equipBaseId, level)
  return attrDic
end

function EquipManager:CheckIsShowCampAttAddExtByCfgId(equipBaseId, heroConfigID)
  local equipCfg = self:GetEquipCfgByBaseId(equipBaseId)
  if equipCfg then
    local heroCfg = HeroManager:GetHeroConfigByID(heroConfigID)
    if heroCfg.m_Camp == equipCfg.m_BonusCamp then
      return true
    end
  end
  return false
end

function EquipManager:CheckIsShowCampAttAddExt(equipUid)
  local equipData = self:GetEquipDataByID(equipUid)
  if equipData then
    local iHeroId = equipData.iHeroId
    if iHeroId and 0 < iHeroId then
      local heroData = HeroManager:GetHeroDataByID(iHeroId)
      local heroCfg = heroData.characterCfg
      local equipCfg = self:GetEquipCfgById(equipUid)
      if heroCfg.m_Camp == equipCfg.m_BonusCamp then
        return true
      end
    end
  end
  return false
end

function EquipManager:CheckEquipShowCampAttAddExt(equipBaseId, heroId)
  local heroData = HeroManager:GetHeroDataByID(heroId)
  local heroCfg = heroData.characterCfg
  local equipCfg = self:GetEquipCfgByBaseId(equipBaseId)
  if heroCfg.m_Camp == equipCfg.m_BonusCamp then
    return true
  end
  return false
end

function EquipManager:CheckIsHaveEquip(equipId)
  local index = 0
  for m, n in ipairs(self.m_EquipList) do
    if equipId == n.iEquipUid then
      index = m
    end
  end
  return index
end

function EquipManager:GetBestEquipsForHero(heroId)
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Equip)
  if isOpen ~= true then
    return {}
  end
  local equippedList = HeroManager:GetHeroEquippedDataByID(heroId)
  local bestEquippedList = {}
  local heroCfg = HeroManager:GetHeroConfigByID(heroId)
  local heroCamp = heroCfg.m_Camp
  local posEquipList = self:GetEquipListByEquipType(heroCfg, equippedList, true)
  for pos = 1, 4 do
    local equipData = equippedList[pos]
    if not equipData or equipData and equipData.iOverloadHero == 0 then
      local firstEquipData = posEquipList[pos]
      if not equipData and firstEquipData then
        bestEquippedList[pos] = firstEquipData.equipData.iEquipUid
      elseif firstEquipData then
        local serverEquipData = firstEquipData.equipData
        local equipCfg1 = self:GetEquipCfgByBaseId(equipData.iBaseId)
        local quality1 = equipCfg1.m_Quality
        local equipCfg2 = self:GetEquipCfgByBaseId(serverEquipData.iBaseId)
        local quality2 = equipCfg2.m_Quality
        if quality1 < quality2 then
          bestEquippedList[pos] = serverEquipData.iEquipUid
        elseif quality2 == quality1 and equipCfg1.m_BonusCamp ~= heroCamp and heroCamp == equipCfg2.m_BonusCamp then
          bestEquippedList[pos] = serverEquipData.iEquipUid
        elseif quality2 == quality1 and equipCfg1.m_BonusCamp == heroCamp and heroCamp == equipCfg2.m_BonusCamp and serverEquipData.iLevel > equipData.iLevel then
          bestEquippedList[pos] = serverEquipData.iEquipUid
        elseif quality2 == quality1 and equipCfg1.m_BonusCamp ~= heroCamp and heroCamp ~= equipCfg2.m_BonusCamp and serverEquipData.iLevel > equipData.iLevel then
          bestEquippedList[pos] = serverEquipData.iEquipUid
        end
      end
    end
  end
  return bestEquippedList
end

function EquipManager:SortEquipList(equipList, camp)
  if #equipList <= 1 then
    return equipList
  end
  
  local function sortFun(data1, data2)
    local equipCfg1 = self:GetEquipCfgByBaseId(data1.iID)
    local equipCfg2 = self:GetEquipCfgByBaseId(data2.iID)
    local equipData1 = data1.customData
    local equipData2 = data2.customData
    local quality1 = equipCfg1.m_Quality
    local quality2 = equipCfg2.m_Quality
    local equipCamp1 = equipCfg1.m_BonusCamp == camp and 1 or 0
    local equipCamp2 = equipCfg2.m_BonusCamp == camp and 1 or 0
    if quality1 == quality2 then
      if equipCamp1 == equipCamp2 then
        if equipData1.iLevel == equipData2.iLevel then
          return equipData1.iHeroId < equipData2.iHeroId
        else
          return equipData1.iLevel > equipData2.iLevel
        end
      else
        return equipCamp1 > equipCamp2
      end
    else
      return quality1 > quality2
    end
  end
  
  table.sort(equipList, sortFun)
  return equipList
end

function EquipManager:SortEquipListByQuality(equipList, filterDown)
  if #equipList <= 1 then
    return equipList
  end
  
  local function sortFun(data1, data2)
    local equipCfg1 = self:GetEquipCfgByBaseId(data1.iID)
    local equipCfg2 = self:GetEquipCfgByBaseId(data2.iID)
    local quality1 = equipCfg1.m_Quality
    local quality2 = equipCfg2.m_Quality
    if data1.data and data2.data then
      if quality1 == quality2 then
        if data1.data.iLevel == data2.data.iLevel then
          if data1.data.iHeroId == data2.data.iHeroId then
            return data1.iID > data2.iID
          else
            return data1.data.iHeroId > data2.data.iHeroId
          end
        else
          return data1.data.iLevel > data2.data.iLevel
        end
      elseif filterDown == false then
        return quality1 > quality2
      else
        return quality1 < quality2
      end
    else
      return data1.iID < data2.iID
    end
  end
  
  table.sort(equipList, sortFun)
  return equipList
end

function EquipManager:SortEquipListByLevel(equipList, filterDown)
  if #equipList <= 1 then
    return equipList
  end
  
  local function sortFun(data1, data2)
    local equipCfg1 = self:GetEquipCfgByBaseId(data1.iID)
    local equipCfg2 = self:GetEquipCfgByBaseId(data2.iID)
    local quality1 = equipCfg1.m_Quality
    local quality2 = equipCfg2.m_Quality
    if data1.data and data2.data then
      if data1.data.iLevel == data2.data.iLevel then
        if quality1 == quality2 then
          return data1.data.iHeroId > data2.data.iHeroId
        else
          return quality1 > quality2
        end
      elseif filterDown == false then
        return data1.data.iLevel > data2.data.iLevel
      else
        return data1.data.iLevel < data2.data.iLevel
      end
    else
      return data1.iID < data2.iID
    end
  end
  
  table.sort(equipList, sortFun)
  return equipList
end

function EquipManager:IsHeroCanEquipped(heroID)
  local showPoint = 0
  local equippedList = HeroManager:GetHeroEquippedDataByID(heroID)
  if not equippedList then
    return 0
  end
  local equippedCount = table.getn(equippedList)
  if equippedCount == 0 then
    local equipList = self:GetBestEquipsForHero(heroID) or {}
    if table.getn(equipList) == 0 then
      return 0
    else
      if not HeroManager then
        return 0
      end
      local limitHeroLv = tonumber(ConfigManager:GetGlobalSettingsByKey("EquipTabReddotHeroLvl"))
      local heroData = HeroManager:GetHeroDataByID(heroID)
      if not heroData then
        return 0
      end
      if limitHeroLv < heroData.serverData.iLevel then
        return 0
      end
      if not LevelManager then
        return 0
      end
      local limitMainLevelID = tonumber(ConfigManager:GetGlobalSettingsByKey("EquipTabReddotMainLvl"))
      local limitLevelHavePass = LevelManager:GetLevelMainHelper():IsLevelHavePass(limitMainLevelID)
      if limitLevelHavePass == true then
        return 0
      end
      return 1
    end
  else
    local equipList = self:GetBestEquipsForHero(heroID) or {}
    if 0 < table.getn(equipList) then
      showPoint = 1
    end
  end
  return showPoint
end

function EquipManager:GetEquipEXPValueById(equipUid)
  local EquipLevelIns = ConfigManager:GetConfigInsByName("EquipLevel")
  local equipData = self:GetEquipDataByID(equipUid)
  local equipCfg = self:GetEquipCfgByBaseId(equipData.iBaseId)
  local levelTemplateID = equipData.iOverloadHero == 0 and equipCfg.m_LevelTemplate or equipCfg.m_OverloadLevelTemplate
  local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplateID, equipData.iLevel)
  if lvCfg:GetError() then
    return 0
  end
  return lvCfg.m_EXPValue + equipData.iExp
end

function EquipManager:GetExpsCanUpgradeLvAndRemainingExp(equipUid, addExp)
  local EquipLevelIns = ConfigManager:GetConfigInsByName("EquipLevel")
  local equipData = self:GetEquipDataByID(equipUid)
  local equipCfg = self:GetEquipCfgByBaseId(equipData.iBaseId)
  if not equipData then
    log.error("GetExpsCanUpgradeLvAndRemainingExp is error")
    return
  end
  if equipCfg:GetError() then
    log.error("GetExpsCanUpgradeLvAndRemainingExp GetEquipCfgByBaseId is error")
    return
  end
  local lvUp = 0
  local curExp = (equipData.iExp or 0) + (addExp or 0)
  local levelTemplate = equipData.iOverloadHero == 0 and equipCfg.m_LevelTemplate or equipCfg.m_OverloadLevelTemplate
  for i = 0, 99 do
    local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplate, equipData.iLevel + i)
    if not lvCfg:GetError() and 0 < lvCfg.m_EXPConsume then
      local EXPConsume = lvCfg.m_EXPConsume
      if 0 < curExp - EXPConsume then
        lvUp = lvUp + 1
        curExp = curExp - EXPConsume
      elseif curExp - EXPConsume == 0 then
        lvUp = lvUp + 1
        curExp = 0
        break
      else
        break
      end
    else
      return curExp, lvUp
    end
  end
  return curExp, lvUp
end

function EquipManager:CheckEquipCanLvUp(iEquipUid)
  local EquipLevelIns = ConfigManager:GetConfigInsByName("EquipLevel")
  local equipData = self:GetEquipDataByID(iEquipUid)
  if not equipData then
    return
  end
  local equipCfg = self:GetEquipCfgByBaseId(equipData.iBaseId)
  local levelTemplate = equipData.iOverloadHero == 0 and equipCfg.m_LevelTemplate or equipCfg.m_OverloadLevelTemplate
  local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplate, equipData.iLevel)
  if not lvCfg:GetError() and 0 < lvCfg.m_EXPConsume then
    return true
  end
  return false
end

function EquipManager:CheckEquipCanOverloadById(iEquipUid)
  local equipData = self:GetEquipDataByID(iEquipUid)
  if not equipData then
    return false
  end
  local equipCfg = self:GetEquipCfgByBaseId(equipData.iBaseId)
  if equipCfg.m_Quality ~= GlobalConfig.QUALITY_EQUIP_ENUM.T9 then
    return false
  end
  local iHeroId = equipData.iHeroId
  if iHeroId and 0 < iHeroId then
    local heroData = HeroManager:GetHeroDataByID(iHeroId)
    local heroCfg = heroData.characterCfg
    if heroCfg.m_Camp ~= equipCfg.m_BonusCamp or equipCfg.m_BonusCamp == 0 then
      return false
    end
  else
    return false
  end
  local canLvUpFlag = self:CheckEquipCanLvUp(iEquipUid)
  if canLvUpFlag then
    return false
  end
  return true
end

function EquipManager:GetEquipEffectCfgByIdLv(groupId, level)
  local EquipEffectIns = ConfigManager:GetConfigInsByName("EquipEffect")
  local lvCfg = EquipEffectIns:GetValue_ByGroupIDAndEffectLevel(groupId, level)
  if not lvCfg:GetError() then
    return lvCfg
  end
end

function EquipManager:GetEquipEffectCfgByGroupId(groupId)
  local EquipEffectIns = ConfigManager:GetConfigInsByName("EquipEffect")
  local cfgList = EquipEffectIns:GetValue_ByGroupID(groupId)
  return cfgList
end

function EquipManager:GetEquipEffectSlotLockCfgByLockNum(lockNum)
  local EquipEffectIns = ConfigManager:GetConfigInsByName("EquipEffectSlotLock")
  local cfg = EquipEffectIns:GetValue_ByLockCnt(lockNum)
  if not cfg:GetError() then
    return cfg
  end
end

function EquipManager:CheckEquipEffectIsLockBySlot(equipUid, slot, equipData)
  equipData = equipData or self:GetEquipDataByID(equipUid)
  if equipData and equipData.mOverloadEffect and table.getn(equipData.mOverloadEffect) > 0 then
    local effectData = equipData.mOverloadEffect[slot]
    if effectData then
      return effectData.bLock, effectData
    end
  end
  return nil
end

function EquipManager:GetEquipEffectLockOrReOverLoadCost(equipUid, equipData)
  equipData = equipData or self:GetEquipDataByID(equipUid)
  if equipData and equipData.mOverloadEffect and table.getn(equipData.mOverloadEffect) > 0 then
    local lockNum = 0
    for i, v in pairs(equipData.mOverloadEffect) do
      if v.bLock then
        lockNum = lockNum + 1
      end
    end
    local costCfg = self:GetEquipEffectSlotLockCfgByLockNum(lockNum)
    return lockNum, costCfg.m_LockCost, costCfg.m_ReOverloadCost
  end
end

function EquipManager:GetHeroEquippedPosByData(equipData)
  if not equipData then
    return
  end
  local heroId = equipData.iHeroId
  local equips = HeroManager:GetHeroEquippedDataByID(heroId)
  if not equips then
    return
  end
  for pos, v in pairs(equips) do
    if v.iEquipUid == equipData.iEquipUid then
      return pos
    end
  end
end

function EquipManager:EquipmentStacked(itemList)
  local newList = {}
  local stackTab = {}
  for i, v in pairs(itemList) do
    local itemId = v.iID
    itemId = itemId or v.data_id
    if ResourceUtil:GetResourceTypeById(itemId) == ResourceUtil.RESOURCE_TYPE.EQUIPS then
      local equipData = v.data
      equipData = equipData or v.customData
      equipData = equipData or v.equipData
      if equipData then
        if (equipData.iHeroId == 0 or equipData.iHeroId == nil) and (equipData.iLevel == 0 or equipData.iLevel == nil) and (equipData.iExp == 0 or equipData.iExp == nil) then
          if not stackTab[itemId] then
            stackTab[itemId] = {}
          end
          table.insert(stackTab[itemId], v)
        else
          table.insert(newList, v)
        end
      else
        if not stackTab[itemId] then
          stackTab[itemId] = {}
        end
        table.insert(stackTab[itemId], v)
      end
    else
      table.insert(newList, v)
    end
  end
  for equipBaseId, list in pairs(stackTab) do
    if list[1] and list[1].iNum then
      list[1].iNum = #list
    elseif list[1] and list[1].data_num then
      list[1].data_num = #list
    end
    newList[#newList + 1] = list[1]
  end
  return newList, stackTab
end

function EquipManager:GetSameEquipByEquipUid(equipUid)
  local equipList = {}
  local equipData = self:GetEquipDataByID(equipUid)
  if equipData then
    local equipDataList = self:GetEquipDataByCfgID(equipData.iBaseId)
    for i, v in ipairs(equipDataList) do
      if v.iHeroId == 0 and v.iLevel == equipData.iLevel and v.iExp == equipData.iExp then
        equipList[#equipList + 1] = v
      end
    end
    
    local function sortFun(a, b)
      return tonumber(a.iEquipUid) < tonumber(b.iEquipUid)
    end
    
    table.sort(equipDataList, sortFun)
  end
  return equipList
end

function EquipManager:GetEquipTypeCfgById(equipType)
  local EquipTypeCfgIns = ConfigManager:GetConfigInsByName("EquipType")
  local stItemData = EquipTypeCfgIns:GetValue_ByEquiptypeID(equipType)
  if stItemData:GetError() then
    log.error("ResourceUtil CreateEquipTypeImg equipType  " .. tostring(equipType))
    return
  end
  return stItemData
end

return EquipManager
