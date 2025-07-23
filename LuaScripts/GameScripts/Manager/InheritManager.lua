local BaseManager = require("Manager/Base/BaseManager")
local InheritManager = class("InheritManager", BaseManager)

function InheritManager:OnCreate()
  self.m_inherit_level = 0
  self.m_bEvolve = false
  self.m_mainHero = {}
  self.m_inheritLevelParam = {}
  self.m_inheritMaxEvoLevel = 0
  self.m_inheritGrids = {}
end

function InheritManager:OnInitNetwork()
  RPCS():Listen_Push_InheritLevel(handler(self, self.OnPushInheritLevel), "InheritManager")
  RPCS():Listen_Push_InheritGrid(handler(self, self.OnPushInheritGrid), "InheritManager")
end

function InheritManager:OnAfterInitConfig()
  local inheritLevelParam = ConfigManager:GetGlobalSettingsByKey("InheritLevelParam")
  self.m_inheritLevelParam = utils.changeStringRewardToLuaTable(inheritLevelParam) or {}
  if self.m_inheritLevelParam[1] and self.m_inheritLevelParam[1][1] then
    self.m_inheritEvoBeginLevel = self.m_inheritLevelParam[1][1]
  end
  self.m_inheritMaxEvoLevel = self:GetInheritMaxEvoLevel()
  self.LvExpItemID = tonumber(ConfigManager:GetGlobalSettingsByKey("CharacterlvEXPitem"))
  self.LvMoneyItemID = tonumber(ConfigManager:GetGlobalSettingsByKey("CharacterlvCurrencyitem"))
  self.LvBreakthroughItemID = tonumber(ConfigManager:GetGlobalSettingsByKey("CharacterlvBreakthroughitem"))
end

function InheritManager:OnPushInheritLevel(data, msg)
  self.m_inherit_level = data.iLevel
  self.m_mainHero = data.vMainHero
  self:broadcastEvent("eGameEvent_Inherit_Push")
  HeroManager:FreshUpdateCirculationEntryRedDot()
end

function InheritManager:OnPushInheritGrid(data, msg)
  for iPos, stGrid in pairs(data.mGrid) do
    self.m_inheritGrids[iPos + 1] = stGrid
  end
end

function InheritManager:ReqUnLockSystemInheritData()
  local inheritCSMsg = MTTDProto.Cmd_Inherit_GetData_CS()
  RPCS():Inherit_GetData(inheritCSMsg, handler(self, self.OnUnLockSystemInheritDataSC))
end

function InheritManager:OnUnLockSystemInheritDataSC(data, msg)
  self.m_inherit_level = data.iLevel
  self.m_mainHero = data.vMainHero
  self.m_inheritGrids = data.vGrid
  self.m_bEvolve = data.bEvolve
  self:broadcastEvent("eGameEvent_Inherit_UnLock")
end

function InheritManager:ReqInheritData()
  local inheritCSMsg = MTTDProto.Cmd_Inherit_GetData_CS()
  RPCS():Inherit_GetData(inheritCSMsg, handler(self, self.OnGetInheritDataSC))
end

function InheritManager:OnGetInheritDataSC(data, msg)
  self.m_inherit_level = data.iLevel
  self.m_mainHero = data.vMainHero
  self.m_inheritGrids = data.vGrid
  self.m_bEvolve = data.bEvolve
  self:broadcastEvent("eGameEvent_Inherit_Init")
end

function InheritManager:ReqInheritAddHero(iHeroId, iPos)
  local inheritCSMsg = MTTDProto.Cmd_Inherit_AddHero_CS()
  inheritCSMsg.iHeroId = iHeroId
  inheritCSMsg.iPos = iPos - 1
  RPCS():Inherit_AddHero(inheritCSMsg, handler(self, self.OnInheritAddHeroSC))
end

function InheritManager:OnInheritAddHeroSC(data, msg)
  local stGrid = data.stGrid
  local iPos = data.iPos + 1
  local iHeroId = data.iHeroId
  self.m_inheritGrids[iPos] = stGrid
  self:broadcastEvent("eGameEvent_Inherit_Change")
end

function InheritManager:ReqInheritDelHero(iPos)
  local inheritCSMsg = MTTDProto.Cmd_Inherit_DelHero_CS()
  inheritCSMsg.iPos = iPos - 1
  RPCS():Inherit_DelHero(inheritCSMsg, handler(self, self.OnInheritDelHeroSC))
end

function InheritManager:OnInheritDelHeroSC(data, msg)
  local stGrid = data.stGrid
  local iPos = data.iPos + 1
  local iHeroId = data.iHeroId
  self.m_inheritGrids[iPos] = stGrid
  self:broadcastEvent("eGameEvent_Inherit_Change")
end

function InheritManager:ReqInheritUnlockGrid()
  local inheritCSMsg = MTTDProto.Cmd_Inherit_UnlockGrid_CS()
  RPCS():Inherit_UnlockGrid(inheritCSMsg, handler(self, self.OnInheritUnlockGridSC))
end

function InheritManager:OnInheritUnlockGridSC(data, msg)
  local stGrid = data.stGrid
  local iPos = data.iPos + 1
  self.m_inheritGrids[iPos] = stGrid
  self:broadcastEvent("eGameEvent_Inherit_Change")
end

function InheritManager:ReqInheritResetGrid(iPos)
  local inheritCSMsg = MTTDProto.Cmd_Inherit_ResetGrid_CS()
  inheritCSMsg.iPos = iPos - 1
  RPCS():Inherit_ResetGrid(inheritCSMsg, handler(self, self.OnInheritResetGridSC))
end

function InheritManager:OnInheritResetGridSC(data, msg)
  local stGrid = data.stGrid
  local iPos = data.iPos + 1
  self.m_inheritGrids[iPos] = stGrid
  self:broadcastEvent("eGameEvent_Inherit_Change")
end

function InheritManager:ReqInheritEvolve()
  local inheritCSMsg = MTTDProto.Cmd_Inherit_Evolve_CS()
  RPCS():Inherit_Evolve(inheritCSMsg, handler(self, self.OnInheritEvolveSC))
end

function InheritManager:OnInheritEvolveSC(data, msg)
  self.m_bEvolve = data.bEvolve
  self:broadcastEvent("eGameEvent_Inherit_Evolve")
end

function InheritManager:ReqInheritLevelUp(iNum)
  local inheritCSMsg = MTTDProto.Cmd_Inherit_LevelUp_CS()
  inheritCSMsg.iNum = iNum
  RPCS():Inherit_LevelUp(inheritCSMsg, handler(self, self.OnInheritLevelUpSC))
end

function InheritManager:OnInheritLevelUpSC(data, msg)
  self.m_inherit_level = data.iNewLevel
  self:broadcastEvent("eGameEvent_Inherit_LevelUp", data)
end

function InheritManager:GetListOfInheritableHeroes()
  local inheritList = {}
  local tempList = {}
  local heroList = HeroManager:GetHeroList()
  for i, v in pairs(heroList) do
    local index = table.indexof(self.m_mainHero, v.serverData.iHeroId)
    if index == false then
      tempList[#tempList + 1] = v
    end
  end
  for i, v in ipairs(tempList) do
    local isHave = false
    for _, gridsInfo in ipairs(self.m_inheritGrids) do
      if v.serverData.iHeroId == gridsInfo.iHeroId then
        isHave = true
        break
      end
    end
    if isHave == false then
      inheritList[#inheritList + 1] = v
    end
  end
  return inheritList
end

function InheritManager:GetTopFiveHero()
  local heroList = {}
  for i, heroID in ipairs(self.m_mainHero) do
    heroList[#heroList + 1] = HeroManager:GetHeroDataByID(heroID)
  end
  return heroList
end

function InheritManager:GetInheritLevel()
  return self.m_inherit_level
end

function InheritManager:GetInheritList()
  return self.m_inheritGrids
end

function InheritManager:GetIsHaveHeroGridsNum()
  local num = 0
  for i, v in ipairs(self.m_inheritGrids) do
    if v.iHeroId ~= 0 then
      num = num + 1
    end
  end
  return num
end

function InheritManager:GetIsOpenGridsNum()
  return table.getn(self.m_inheritGrids)
end

function InheritManager:GetInheritPosById(heroId)
  local pos = 0
  for index, gridsInfo in ipairs(self.m_inheritGrids) do
    if heroId == gridsInfo.iHeroId then
      pos = index
      break
    end
  end
  return pos
end

function InheritManager:GetTopFiveHeroIds()
  return self.m_mainHero
end

function InheritManager:CheckCanResetLvById(heroId)
  local heroData = HeroManager:GetHeroDataByID(heroId)
  if heroData then
    local serverData = heroData.serverData
    local iOriLevel = serverData.iOriLevel
    local evoFlag = self:GetInheritIsEvo()
    if evoFlag then
      local index = table.indexof(self.m_mainHero, heroId)
      if index == false then
        return iOriLevel == 0, true
      else
        return false, true
      end
    else
      return iOriLevel == 0, true
    end
  end
  return false, false
end

function InheritManager:GetInheritLevelCfg(level)
  local levelCfg = ConfigManager:GetConfigInsByName("InheritLevel")
  local cfg = levelCfg:GetValue_ByLevel(level)
  if cfg:GetError() then
    log.error("InheritManager GetInheritLevelCfg  level  " .. tostring(level))
    return
  end
  return cfg
end

function InheritManager:GetInheritMaxEvoLevel()
  local levelCfgList = {}
  local levelCfg = ConfigManager:GetConfigInsByName("InheritLevel")
  local cfgAll = levelCfg:GetAll()
  for i, v in pairs(cfgAll) do
    levelCfgList[#levelCfgList + 1] = v
  end
  
  local function sortFun(data1, data2)
    return data1.m_Level > data2.m_Level
  end
  
  table.sort(levelCfgList, sortFun)
  local cfg = levelCfgList[1]
  if cfg then
    return cfg.m_Level
  else
    log.error("GetInheritMaxEvoLevel error  cfg == nil")
  end
end

function InheritManager:GetInheritEvoBeginLevel()
  return self.m_inheritEvoBeginLevel
end

function InheritManager:GetInheritIsEvo()
  return self.m_bEvolve
end

function InheritManager:GetInheritMaxLv()
  local level = self.m_inheritEvoBeginLevel
  if self.m_bEvolve and table.getn(self.m_inheritLevelParam) > 0 then
    local countParam = self.m_inheritLevelParam[2][1]
    local breakCountParam = self.m_inheritLevelParam[3][1]
    local heroList = HeroManager:GetHeroList()
    local heroCount = table.getn(heroList)
    local heroBreak = 0
    for i, v in ipairs(heroList) do
      heroBreak = heroBreak + v.serverData.iBreak
    end
    level = math.floor(level + countParam * heroCount / 10000 + heroBreak * breakCountParam / 10000)
  end
  return math.min(self.m_inheritMaxEvoLevel, level)
end

function InheritManager:GetInheritLevelUpItemId()
  return self.LvExpItemID, self.LvMoneyItemID, self.LvBreakthroughItemID
end

function InheritManager:GetInheritLevelUpNeedItem(afterLevel, curLv)
  if not afterLevel then
    return
  end
  curLv = curLv or self:GetInheritLevel()
  if afterLevel < curLv then
    return
  end
  local itemList = {}
  local expId, goldId, breakId = self:GetInheritLevelUpItemId()
  local expNum, goldNum, breakNum = 0, 0, 0
  for i = curLv, afterLevel - 1 do
    local cfg = self:GetInheritLevelCfg(i)
    if cfg then
      expNum = expNum + cfg.m_ExpItem
      goldNum = goldNum + cfg.m_GoldItem
      breakNum = breakNum + cfg.m_BreakthroughItem
    end
  end
  itemList = {
    {expId, expNum},
    {goldId, goldNum},
    {breakId, breakNum}
  }
  return itemList
end

function InheritManager:GetInheritItemLevelNum(itemList, curLv)
  if table.getn(itemList) == 0 then
    return 0
  end
  curLv = curLv or self:GetInheritLevel()
  local maxLevel = self:GetInheritMaxLv()
  local expNum, goldNum, breakNum = 0, 0, 0
  for i = curLv, maxLevel do
    local cfg = self:GetInheritLevelCfg(i)
    if cfg then
      expNum = expNum + cfg.m_ExpItem
      goldNum = goldNum + cfg.m_GoldItem
      breakNum = breakNum + cfg.m_BreakthroughItem
      if expNum > itemList[1] or goldNum > itemList[2] or breakNum > itemList[3] then
        return i - curLv
      end
    end
  end
  return maxLevel - curLv
end

return InheritManager
