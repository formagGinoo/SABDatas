local HeroSort = class("HeroSort")
local table_sort = table.sort
local next = _ENV.next
local ipairs = _ENV.ipairs

function HeroSort:ctor()
end

HeroSortCfg = {
  {iIndex = 1, sTitle = 2000},
  {iIndex = 2, sTitle = 2001},
  {iIndex = 3, sTitle = 2002},
  {iIndex = 4, sTitle = 2003},
  {iIndex = 6, sTitle = 2015}
}
HeroGuideSortCfg = {
  {iIndex = 1, sTitle = 2000},
  {iIndex = 2, sTitle = 2001},
  {iIndex = 3, sTitle = 2002},
  {iIndex = 4, sTitle = 2003},
  {iIndex = 6, sTitle = 2015}
}
HeroCouncilSortCfg = {
  {iIndex = 1, sTitle = 2000},
  {iIndex = 2, sTitle = 2001},
  {iIndex = 3, sTitle = 2002},
  {iIndex = 4, sTitle = 220001},
  {iIndex = 5, sTitle = 2003},
  {iIndex = 6, sTitle = 2015}
}

local function PowerCheck(a, b, isReverse)
  local aiPower = a.serverData.iPower and a.serverData.iPower or 0
  local biPower = b.serverData.iPower and b.serverData.iPower or 0
  if aiPower == biPower then
    return 0
  end
  if isReverse then
    return aiPower < biPower
  else
    return aiPower > biPower
  end
end

local function QualityCheck(a, b, isReverse)
  if a.characterCfg.m_Quality == b.characterCfg.m_Quality then
    return 0
  end
  if isReverse then
    return a.characterCfg.m_Quality < b.characterCfg.m_Quality
  else
    return a.characterCfg.m_Quality > b.characterCfg.m_Quality
  end
end

local function LevelCheck(a, b, isReverse)
  local aiLevel = a.serverData.iLevel and a.serverData.iLevel or 0
  local biLevel = b.serverData.iLevel and b.serverData.iLevel or 0
  if aiLevel == biLevel then
    return 0
  end
  if isReverse then
    return aiLevel < biLevel
  else
    return aiLevel > biLevel
  end
end

local function TimeCheck(a, b, isReverse)
  local aiTime = a.serverData.iTime and a.serverData.iTime or 0
  local biTime = b.serverData.iTime and b.serverData.iTime or 0
  local aIsZero = aiTime == 0
  local bIsZero = biTime == 0
  if aiTime == biTime then
    return 0
  end
  if aIsZero ~= bIsZero then
    return bIsZero
  end
  if isReverse then
    return aiTime < biTime
  else
    return aiTime > biTime
  end
end

local function IDCheck(a, b, isReverse)
  if a.serverData.iHeroId == b.serverData.iHeroId then
    return 0
  end
  if isReverse then
    return a.serverData.iHeroId < b.serverData.iHeroId
  else
    return a.serverData.iHeroId > b.serverData.iHeroId
  end
end

local function BreakCheck(a, b, isReverse)
  local aiBreak = a.serverData.iBreak and a.serverData.iBreak or 0
  local biBreak = b.serverData.iBreak and b.serverData.iBreak or 0
  if aiBreak == biBreak then
    return 0
  end
  if isReverse then
    return aiBreak < biBreak
  else
    return aiBreak > biBreak
  end
end

local function CampCheck(a, b, isReverse)
  if a.characterCfg.m_Camp == b.characterCfg.m_Camp then
    return 0
  end
  if isReverse then
    return a.characterCfg.m_Camp > b.characterCfg.m_Camp
  else
    return a.characterCfg.m_Camp < b.characterCfg.m_Camp
  end
end

local function AttractCheck(a, b, isReverse)
  local aiAttractRank = a.serverData.iAttractRank and a.serverData.iAttractRank or 0
  local biAttractRank = b.serverData.iAttractRank and b.serverData.iAttractRank or 0
  local aiAttractExp = (AttractManager:GetHeroAttractById(a.serverData.iHeroId) or {}).iAttractExp or 0
  local biAttractExp = (AttractManager:GetHeroAttractById(b.serverData.iHeroId) or {}).iAttractExp or 0
  if aiAttractRank ~= biAttractRank then
    if isReverse then
      return aiAttractRank < biAttractRank
    else
      return aiAttractRank > biAttractRank
    end
  end
  if aiAttractExp ~= biAttractExp then
    if isReverse then
      return aiAttractExp < biAttractExp
    else
      return aiAttractExp > biAttractExp
    end
  end
  return 0
end

local DefaultSort = {
  [1] = PowerCheck,
  [2] = QualityCheck,
  [3] = LevelCheck,
  [4] = TimeCheck,
  [5] = IDCheck,
  [6] = BreakCheck
}

function HeroSort:SortHeroList(heroList, priority, isReverse)
  if not heroList or not next(heroList) then
    return
  end
  if not priority then
    return
  end
  table_sort(heroList, function(a, b)
    local prioritySortFun = DefaultSort[priority]
    if prioritySortFun then
      local checkResult = prioritySortFun(a, b, isReverse)
      if checkResult ~= 0 then
        return checkResult
      end
    end
    for i, _ in ipairs(DefaultSort) do
      if i ~= priority then
        local checkFun = DefaultSort[i]
        if checkFun then
          local checkResult = checkFun(a, b, isReverse)
          if checkResult ~= 0 then
            return checkResult
          end
        end
      end
    end
  end)
end

local HeroGuideSort = {
  [1] = PowerCheck,
  [2] = QualityCheck,
  [3] = LevelCheck,
  [4] = TimeCheck,
  [5] = IDCheck,
  [6] = BreakCheck,
  [7] = CampCheck
}
local HeroGuideOtherSort = {
  [1] = {sortIndex = 2},
  [2] = {sortIndex = 7},
  [3] = {sortIndex = 1}
}

function HeroSort:SortHeroGuideList(heroList, priority, isReverse)
  if not heroList or not next(heroList) then
    return
  end
  if not priority then
    return
  end
  table_sort(heroList, function(a, b)
    local prioritySortFun = HeroGuideSort[priority]
    if prioritySortFun then
      local checkResult = prioritySortFun(a, b, isReverse)
      if checkResult ~= 0 then
        return checkResult
      end
    end
    for i, tempTab in ipairs(HeroGuideOtherSort) do
      if tempTab.sortIndex ~= priority then
        local checkFun = HeroGuideSort[tempTab.sortIndex]
        if checkFun then
          local checkResult = checkFun(a, b, isReverse)
          if checkResult ~= 0 then
            return checkResult
          end
        end
      end
    end
  end)
end

local HeroCouncilSort = {
  [1] = PowerCheck,
  [2] = QualityCheck,
  [3] = LevelCheck,
  [4] = AttractCheck,
  [5] = TimeCheck,
  [6] = IDCheck,
  [7] = BreakCheck
}

function HeroSort:SortCouncilHeroList(heroList, priority, isReverse)
  if not heroList or not next(heroList) then
    return
  end
  if not priority then
    return
  end
  table_sort(heroList, function(a, b)
    local prioritySortFun = HeroCouncilSort[priority]
    if prioritySortFun then
      local checkResult = prioritySortFun(a, b, isReverse)
      if checkResult ~= 0 then
        return checkResult
      end
    end
    for i, _ in ipairs(HeroCouncilSort) do
      if i ~= priority then
        local checkFun = HeroCouncilSort[i]
        if checkFun then
          local checkResult = checkFun(a, b, isReverse)
          if checkResult ~= 0 then
            return checkResult
          end
        end
      end
    end
  end)
end

function HeroSort.HeroCampFilter(heroData, paramNum)
  if paramNum == nil or paramNum == 0 then
    return true
  end
  return heroData.characterCfg.m_Camp == paramNum
end

function HeroSort.HeroCareerFilter(heroData, paramNum)
  if paramNum == nil or paramNum == 0 then
    return true
  end
  return heroData.characterCfg.m_Career == paramNum
end

function HeroSort.HeroEquipTypeFilter(heroData, paramNum)
  if paramNum == nil or paramNum == 0 then
    return true
  end
  return heroData.characterCfg.m_Equiptype == paramNum
end

function HeroSort.HeroMoonTypeFilter(heroData, paramNum)
  if paramNum == nil or paramNum == 0 then
    return true
  end
  return heroData.characterCfg.m_MoonType == paramNum
end

function HeroSort:CheckHeroIsInFilter(heroData, filterData)
  if not heroData then
    return
  end
  for filterType, paramNum in pairs(filterData) do
    local filterFun = HeroManager.HeroFilterFunctionCfg[filterType]
    local isInList = filterFun(heroData, paramNum)
    if isInList ~= true then
      return false
    end
  end
  return true
end

function HeroSort:FilterHeroList(heroList, filterData)
  if not heroList then
    return
  end
  if not filterData or not next(filterData) then
    return heroList
  end
  local showHeroList = {}
  for _, heroData in ipairs(heroList) do
    if self:CheckHeroIsInFilter(heroData, filterData) == true then
      showHeroList[#showHeroList + 1] = heroData
    end
  end
  return showHeroList
end

function HeroSort:GetMonsterListSort(monsterDataList)
  if not monsterDataList then
    return
  end
  table.sort(monsterDataList, function(a, b)
    if a.isHide ~= b.isHide then
      return a.isHide
    end
    if a.monsterCfg.m_MonsterType ~= b.monsterCfg.m_MonsterType then
      return HeroManager.MonsterTypeSort[a.monsterCfg.m_MonsterType] < HeroManager.MonsterTypeSort[b.monsterCfg.m_MonsterType]
    end
    return a.monsterCfg.m_MonsterID < b.monsterCfg.m_MonsterID
  end)
  return monsterDataList
end

return HeroSort
