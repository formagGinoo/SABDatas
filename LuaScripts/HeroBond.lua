local HeroBond = class("HeroBond")
local BondIns = ConfigManager:GetConfigInsByName("Bond")
local BondEffectIns = ConfigManager:GetConfigInsByName("BondEffect")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function HeroBond:ctor()
  self.m_BondHeroCache = {}
end

function HeroBond:GetBondEffectCfgList(bondCfg)
  if not bondCfg then
    return
  end
  local bondEffect = bondCfg.m_BondEffectList
  local bondEffectCfgList = {}
  if not bondEffect then
    return bondEffectCfgList
  end
  for i = 0, bondEffect.Length - 1 do
    local bondEffectID = bondEffect[i]
    local bondEffectCfg = BondEffectIns:GetValue_ByID(bondEffectID)
    bondEffectCfgList[#bondEffectCfgList + 1] = bondEffectCfg
  end
  return bondEffectCfgList
end

function HeroBond:GetBondActiveStage(bondData)
  if not bondData then
    return 0
  end
  local peopleNum = #bondData.bondHeroList
  local bondActiveStage = 0
  for i, bondEffectCfg in ipairs(bondData.bondEffectCfgList) do
    if peopleNum >= bondEffectCfg.m_RequiredCount then
      bondActiveStage = i
    end
  end
  return bondActiveStage
end

function HeroBond:GetBondDicByHeroList(heroDataList)
  if not heroDataList then
    return
  end
  local bondsDic = {}
  for index, heroData in ipairs(heroDataList) do
    local characterCfg = heroData.characterCfg
    local bonds = characterCfg.m_Bond
    if bonds and bonds.Length > 0 then
      for i = 0, bonds.Length - 1 do
        local bondID = bonds[i]
        if bondsDic[bondID] == nil then
          local bondCfg = BondIns:GetValue_ByID(bondID)
          bondsDic[bondID] = {
            bondID = bondID,
            bondCfg = bondCfg,
            bondHeroList = {characterCfg},
            bondEffectCfgList = self:GetBondEffectCfgList(bondCfg),
            bondActiveStage = 0
          }
        else
          local bondHeroList = bondsDic[bondID].bondHeroList
          bondHeroList[#bondHeroList + 1] = characterCfg
        end
      end
    end
  end
  for _, bondData in pairs(bondsDic) do
    local bondActiveStage = self:GetBondActiveStage(bondData)
    bondData.bondActiveStage = bondActiveStage
  end
  return bondsDic
end

function HeroBond:SortBondList(bondsList)
  if not bondsList then
    return
  end
  table.sort(bondsList, function(a, b)
    if a.bondActiveStage ~= b.bondActiveStage then
      return a.bondActiveStage > b.bondActiveStage
    end
    if a.bondActiveStage == 0 then
      local heroNumA = #a.bondHeroList
      local heroNumB = #b.bondHeroList
      if heroNumA == heroNumB then
        return a.bondID < b.bondID
      else
        return heroNumA > heroNumB
      end
    else
      return a.bondID < b.bondID
    end
  end)
  return bondsList
end

function HeroBond:GetBondsByHeroList(heroDataList)
  if not heroDataList then
    return
  end
  if not next(heroDataList) then
    return {}
  end
  local bondsDic = self:GetBondDicByHeroList(heroDataList)
  local bondsList = {}
  for _, bondData in pairs(bondsDic) do
    if bondData then
      bondsList[#bondsList + 1] = bondData
    end
  end
  bondsList = self:SortBondList(bondsList)
  return bondsList
end

function HeroBond:GetActiveBondsByHeroList(heroDataList)
  if not heroDataList then
    return
  end
  if not next(heroDataList) then
    return {}
  end
  local bondsDic = self:GetBondDicByHeroList(heroDataList)
  local bondsList = {}
  for _, bondData in pairs(bondsDic) do
    if bondData and bondData.bondActiveStage > 0 then
      bondsList[#bondsList + 1] = bondData
    end
  end
  bondsList = self:SortBondList(bondsList)
  return bondsList
end

function HeroBond:GetHeroIDListByBondID(bondID)
  if not bondID then
    return
  end
  if self.m_BondHeroCache[bondID] then
    return self.m_BondHeroCache[bondID]
  end
  local heroIDList = {}
  local allHeroCfg = CharacterInfoIns:GetAll()
  for heroID, heroCfg in pairs(allHeroCfg) do
    if heroCfg.m_OnSale == 0 then
      local heroBond = heroCfg.m_Bond
      if heroBond and 0 < heroBond.Length then
        for i = 0, heroBond.Length - 1 do
          local tempBondID = heroBond[i]
          if tempBondID == bondID then
            heroIDList[#heroIDList + 1] = heroID
            break
          end
        end
      end
    end
  end
  self.m_BondHeroCache[bondID] = heroIDList
  return heroIDList
end

function HeroBond:GetAllBondList(isShowAllBond)
  local allBondCfg = BondIns:GetAll()
  local allBondList = {}
  for bondID, bondCfg in pairs(allBondCfg) do
    local bondData = {
      bondID = bondID,
      bondCfg = bondCfg,
      bondHeroList = {},
      isShowAllBond = isShowAllBond,
      bondEffectCfgList = self:GetBondEffectCfgList(bondCfg),
      bondActiveStage = 0
    }
    allBondList[#allBondList + 1] = bondData
  end
  allBondList = self:SortBondList(allBondList)
  return allBondList
end

return HeroBond
