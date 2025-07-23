local UISubPanelBase = require("UI/Common/UISubPanelBase")
local LevelDetailSubPanel = class("LevelDetailSubPanel", UISubPanelBase)
local MonsterGroupIns = ConfigManager:GetConfigInsByName("MonsterGroup")
local MonsterIns = ConfigManager:GetConfigInsByName("Monster")
local ResultConditionTypeIns = ConfigManager:GetConfigInsByName("ResultConditionType")
local TowerIns = ConfigManager:GetConfigInsByName("Tower")
local HeroModifyIns = ConfigManager:GetConfigInsByName("HeroModify")
local string_format = string.format
local ipairs = _ENV.ipairs
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local EnterAnimStr = "level_detail_in"
local OutAnimStr = "level_detail_out"

function LevelDetailSubPanel:OnInit()
  self.m_levelType = nil
  self.m_curSubLevelType = nil
  self.m_curLevelID = nil
  self.m_levelNameStr = nil
  self.m_curLevelDegree = nil
  if self.m_initData then
    self.m_bgClkBack = self.m_initData.bgBackFun
  end
  UILuaHelper.SetActive(self.m_btn_detail_bg, self.m_bgClkBack ~= nil)
  self.m_ItemWidgetList = {}
  self.m_rewardItemBase = self.m_reward_root.transform:Find("c_common_item")
  UILuaHelper.SetActive(self.m_rewardItemBase, false)
  self.m_DialogueItemWidgetList = {}
  self.m_curBattleWorldCfg = nil
  local initEnemyGridData = {
    itemClkBackFun = handler(self, self.OnEnemyIconClk)
  }
  self.m_enemy_listInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_enemy_list_InfinityGrid, "Monster/UIMonsterSmallItem", initEnemyGridData)
  self.m_enemyList = {}
  UILuaHelper.SetCanvasGroupAlpha(self.m_level_panel_detail, 0)
  self.m_monsterLv = nil
  self:InitUI()
end

function LevelDetailSubPanel:OnFreshData()
  self.m_levelType = self.m_panelData.levelType
  self.m_curLevelID = self.m_panelData.levelID
  self.m_levelCfg = LevelManager:GetLevelCfgByTypeAndLevelID(self.m_levelType, self.m_curLevelID)
  self.m_curSubLevelType = self.m_levelCfg.m_LevelSubType
  self:FreshLevelInfo()
  self:FreshEnterBattle()
  UILuaHelper.SetActive(self.m_detail_bg, self.m_levelType ~= LevelManager.LevelType.Tower)
  self:CheckShowAnimIn()
end

function LevelDetailSubPanel:AddEventListeners()
end

function LevelDetailSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function LevelDetailSubPanel:OnEventSetForm(param)
end

function LevelDetailSubPanel:OnDestroy()
  LevelDetailSubPanel.super.OnDestroy(self)
  if self.m_detailOutTimer ~= nil then
    TimeService:KillTimer(self.m_detailOutTimer)
    self.m_detailOutTimer = nil
  end
end

function LevelDetailSubPanel:InitUI()
  self.m_multiColor = self.m_img_extips2:GetComponent("MultiColorChange")
end

function LevelDetailSubPanel:IsSubTowerHaveLeftTimes()
  if self.m_levelType ~= LevelManager.LevelType.Tower then
    return
  end
  if self.m_curSubLevelType == LevelManager.TowerLevelSubType.Main then
    return true
  end
  local maxTimes = TowerIns:GetValue_ByLevelSubType(self.m_curSubLevelType).m_Times or 0
  local curTimes = LevelManager:GetLevelTowerHelper():GetDailyTimesBySubLevelType(self.m_curSubLevelType) or 0
  local leftTimes = maxTimes - curTimes
  if 0 < leftTimes then
    return true
  else
    return false
  end
end

function LevelDetailSubPanel:GetMainLevelDegree()
  if self.m_levelType ~= LevelManager.LevelType.MainLevel then
    return
  end
  local mainHelper = LevelManager:GetLevelMainHelper()
  local chapterData = mainHelper:GetChapterDataByLevelID(self.m_curLevelID)
  if not chapterData then
    return
  end
  local chapterCfg = chapterData.chapterCfg
  if not chapterCfg then
    return
  end
  return chapterCfg.m_ChapterType
end

function LevelDetailSubPanel:MonsterIsInList(monsterIDList, checkMonsterID)
  if not monsterIDList then
    return
  end
  if not checkMonsterID then
    return
  end
  for _, monsterID in ipairs(monsterIDList) do
    if monsterID == checkMonsterID then
      return true
    end
  end
  return false
end

function LevelDetailSubPanel:IsTowerLevelNoCampHero()
  if self.m_levelType ~= LevelManager.LevelType.Tower then
    return
  end
  if not self.m_curSubLevelType then
    return
  end
  local towerCfg = TowerIns:GetValue_ByLevelSubType(self.m_curSubLevelType)
  if towerCfg:GetError() == true then
    return
  end
  local campLimitType = towerCfg.m_CampResID
  if campLimitType == 0 then
    return false
  end
  local allHeroDataList = HeroManager:GetHeroList()
  if not allHeroDataList then
    return
  end
  for i, tempHeroData in ipairs(allHeroDataList) do
    local heroCfg = tempHeroData.characterCfg
    local heroCamp = heroCfg.m_Camp
    if heroCamp == campLimitType then
      return false
    end
  end
  return true
end

function LevelDetailSubPanel:GetMinePower()
  local tempPower = 0
  if self.m_levelType == LevelManager.LevelType.Tower and self.m_curSubLevelType ~= LevelManager.TowerLevelSubType.Main then
    local towerCfg = TowerIns:GetValue_ByLevelSubType(self.m_curSubLevelType)
    if towerCfg:GetError() == true then
      return
    end
    local campLimitType = towerCfg.m_CampResID
    if campLimitType == 0 then
      return
    end
    local allHeroDataList = HeroManager:GetHeroList()
    if not allHeroDataList then
      return
    end
    local heroPowerNumList = {}
    for i, tempHeroData in ipairs(allHeroDataList) do
      local heroCfg = tempHeroData.characterCfg
      local heroCamp = heroCfg.m_Camp
      if heroCamp == campLimitType then
        heroPowerNumList[#heroPowerNumList + 1] = tempHeroData.serverData.iPower
      end
    end
    table.sort(heroPowerNumList, function(a, b)
      return b < a
    end)
    for i = 1, FormPlotMaxNum do
      local powerNum = heroPowerNumList[i]
      if powerNum then
        tempPower = tempPower + powerNum
      end
    end
  else
    tempPower = HeroManager:GetTopFiveHeroPower() or 0
  end
  return tempPower
end

function LevelDetailSubPanel:FreshLevelInfo()
  local levelNameStr, elementArray, rewardArray, monsterStr
  local levelCfg = self.m_levelCfg
  self.m_curBattleWorldCfg = nil
  if levelCfg then
    levelNameStr = levelCfg.m_LevelName or levelCfg.m_mName
    elementArray = levelCfg.m_Element
    rewardArray = levelCfg.m_FirstBonusClient or levelCfg.m_ClientMustDrop
    monsterStr = levelCfg.m_Monster
    local mapID = levelCfg.m_MapID
    self.m_curBattleWorldCfg = ConfigManager:GetBattleWorldCfgById(mapID)
  end
  self.m_levelNameStr = levelNameStr
  if self.m_levelType == LevelManager.LevelType.MainLevel then
    self.m_curLevelDegree = self:GetMainLevelDegree()
  else
    self.m_curLevelDegree = nil
  end
  self.m_monsterStr = monsterStr
  self.m_txt_level_name_Text.text = levelNameStr or ""
  self:FreshRewardList(rewardArray)
  self:FreshEnemyList()
  self:FreshDailyTimes()
  self:FreshLevelTypeTag()
  self:CheckFreshHardStatus()
  self:CheckFreshExLevelTipsShow()
  self:FreshForceLevel()
end

function LevelDetailSubPanel:CheckFreshHardStatus()
  local isMainHard = self.m_levelType == LevelManager.LevelType.MainLevel and self.m_curLevelDegree == LevelManager.ChapterType.Hard
  UILuaHelper.SetActive(self.m_bg_hard, isMainHard)
end

function LevelDetailSubPanel:CheckFreshExLevelTipsShow()
  local isExLevel = self.m_levelType == LevelManager.LevelType.MainLevel and self.m_curSubLevelType == LevelManager.MainLevelSubType.ExLevel
  local isHardLevel = self.m_levelType == LevelManager.LevelType.MainLevel and self.m_curSubLevelType == LevelManager.MainLevelSubType.HardLevel
  UILuaHelper.SetActive(self.m_z_txt_ex_tips, isExLevel)
  UILuaHelper.SetActive(self.m_img_extips, isExLevel or isHardLevel)
  UILuaHelper.SetActive(self.m_z_txt_difficult, isHardLevel)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_name_parent)
  UILuaHelper.SetActive(self.m_topbg_normal, not isExLevel and not isHardLevel)
  UILuaHelper.SetActive(self.m_topbg_hard, isHardLevel)
  UILuaHelper.SetActive(self.m_topbg_ex, isExLevel)
  UILuaHelper.SetActive(self.m_bg_ex, isExLevel)
  if self.m_multiColor then
    self.m_multiColor:SetColorByIndex(isExLevel and 1 or 0)
  end
end

function LevelDetailSubPanel:FreshForceLevel()
  if not self.m_levelCfg then
    return
  end
  local heroModify = self.m_levelCfg.m_HeroModify or 0
  UILuaHelper.SetActive(self.m_pnl_levellock, heroModify ~= 0)
  UILuaHelper.SetActive(self.m_pnl_battleinfor, heroModify == 0)
  if heroModify ~= 0 then
    local heroModifyCfg = HeroModifyIns:GetValue_ByID(heroModify)
    if heroModifyCfg:GetError() ~= true then
      self.m_txt_levellock_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(20204), heroModifyCfg.m_ForceLevel)
    end
  else
    local power = self:GetMinePower()
    self.m_txt_ourside_Text.text = power
    if self.m_curBattleWorldCfg then
      local fightValue = self.m_curBattleWorldCfg.m_FightValue
      self.m_txt_enemy1_Text.text = fightValue
      UILuaHelper.SetActive(self.m_bg_red, power < fightValue)
      UILuaHelper.SetActive(self.m_bg_blue, power >= fightValue)
      if power >= fightValue then
        UILuaHelper.SetColor(self.m_z_txt_ourside_Text, 54, 142, 114)
        UILuaHelper.SetColor(self.m_txt_ourside_Text, 54, 142, 114)
        UILuaHelper.SetColor(self.m_img_battle_ourside_Image, 54, 142, 114)
      else
        UILuaHelper.SetColor(self.m_z_txt_ourside_Text, 188, 68, 60)
        UILuaHelper.SetColor(self.m_txt_ourside_Text, 188, 68, 60)
        UILuaHelper.SetColor(self.m_img_battle_ourside_Image, 188, 68, 60)
      end
    else
      UILuaHelper.SetActive(self.m_pnl_battleinfor, false)
      log.error("show power is error BattleWorldCfg is nil")
    end
  end
end

function LevelDetailSubPanel:FreshDailyTimes()
  if self.m_levelType == LevelManager.LevelType.Tower and self.m_curSubLevelType ~= LevelManager.TowerLevelSubType.Main then
    UILuaHelper.SetActive(self.m_txt_battle_time, true)
    local curTimes = LevelManager:GetLevelTowerHelper():GetDailyTimesBySubLevelType(self.m_curSubLevelType) or 0
    local maxTimes = TowerIns:GetValue_ByLevelSubType(self.m_curSubLevelType).m_Times
    local leftTimes = maxTimes - curTimes
    self.m_txt_battle_time_Text.text = string_format(ConfigManager:GetCommonTextById(20036), leftTimes, maxTimes)
  else
    UILuaHelper.SetActive(self.m_txt_battle_time, false)
  end
end

function LevelDetailSubPanel:FreshLevelTypeTag()
  if not self.m_curBattleWorldCfg then
    return
  end
  local resultConditionType = ConfigManager:BattleConditionStart(self.m_curBattleWorldCfg)
  local resultConditionCfg = ResultConditionTypeIns:GetValue_ByConditionTypeID(resultConditionType)
  if resultConditionCfg:GetError() then
    return
  end
  local resultTypePath = resultConditionCfg.m_ConditionTypeMark
  local resultNote = resultConditionCfg.m_mNote
  UILuaHelper.SetAtlasSprite(self.m_img_type_Image, resultTypePath)
  self.m_txt_type_Text.text = resultNote
end

function LevelDetailSubPanel:FreshEnemyList()
  if not self.m_curBattleWorldCfg then
    self.m_enemy_listInfinityGrid:ShowItemList({})
    return
  end
  local monsterGroupArray = ConfigManager:BattleWorldMonsterGroupList(self.m_curBattleWorldCfg)
  if not monsterGroupArray or monsterGroupArray.Length == 0 then
    self.m_enemy_listInfinityGrid:ShowItemList({})
    return
  end
  local areaIDList = utils.changeCSArrayToLuaTable(ConfigManager:BattleWorldAreaIDList(self.m_curBattleWorldCfg))
  local monsterDic = {}
  local isHaveHide = false
  local arrayLen = monsterGroupArray.Length
  for i = 0, arrayLen - 1 do
    local monsterGroupID = monsterGroupArray[i]
    local monsterGroupCfg = MonsterGroupIns:GetValue_ByID(monsterGroupID)
    local isShow = table.indexof(areaIDList, monsterGroupCfg.m_WaveIndex - 1)
    if not monsterGroupCfg:GetError() and isShow then
      local monsterList = monsterGroupCfg.m_MonsterList
      if monsterList and monsterList.Length > 0 then
        local monsterLen = monsterList.Length
        local hideMonsterIDList = utils.changeCSArrayToLuaTable(monsterGroupCfg.m_Hide) or {}
        local notShowMonsterIDList = utils.changeCSArrayToLuaTable(monsterGroupCfg.m_MosterHideView) or {}
        for monsterIndex = 0, monsterLen - 1 do
          local monsterTemp = monsterList[monsterIndex]
          if monsterTemp and monsterTemp[1] then
            local monsterID = monsterTemp[1]
            if self:MonsterIsInList(notShowMonsterIDList, monsterID) ~= true and monsterDic[monsterID] == nil then
              local monsterCfg = MonsterIns:GetValue_ByMonsterID(monsterID)
              if monsterCfg and not monsterCfg:GetError() then
                local isHide = self:MonsterIsInList(hideMonsterIDList, monsterID)
                local battleCamp = monsterCfg.m_BattleCamp
                local isNeedCreat = true
                if isHide and isHaveHide == true then
                  isNeedCreat = false
                end
                if battleCamp == 0 or battleCamp == 1 then
                  isNeedCreat = false
                end
                if isNeedCreat then
                  local tempEnemyTab = {monsterCfg = monsterCfg, isHide = isHide}
                  monsterDic[monsterID] = tempEnemyTab
                  if isHide then
                    isHaveHide = true
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  local tempEnemyList = {}
  for _, monsterData in pairs(monsterDic) do
    if monsterData.monsterCfg and monsterData.monsterCfg.m_MonsterType and monsterData.monsterCfg.m_MonsterType ~= HeroManager.MonsterType.Pitfall then
      tempEnemyList[#tempEnemyList + 1] = monsterData
    end
  end
  self.m_enemyList = HeroManager:GetHeroSort():GetMonsterListSort(tempEnemyList)
  self.m_enemy_listInfinityGrid:ShowItemList(self.m_enemyList)
  if 0 < table.getn(self.m_enemyList) then
    self.m_enemy_listInfinityGrid:LocateTo(0)
  end
end

function LevelDetailSubPanel:FreshRewardList(rewardArray)
  if not rewardArray then
    return
  end
  if not rewardArray or rewardArray.Length <= 0 then
    return
  end
  local itemWidgets = self.m_ItemWidgetList
  local dataLen = rewardArray.Length
  local parentTrans = self.m_reward_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans.transform).gameObject
      itemObj.name = self.m_rewardItemBase.name .. i
      local itemWidget = self:createCommonItem(itemObj)
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidgets[#itemWidgets + 1] = itemWidget
      itemWidget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
end

function LevelDetailSubPanel:FreshEnterBattle()
  self.m_txt_lock_des_Text.text = ConfigManager:GetCommonTextById(20016)
  local isHavePass = LevelManager:IsLevelHavePass(self.m_levelType, self.m_curLevelID)
  if self.m_levelType == LevelManager.LevelType.MainLevel then
    local isReplay = self.m_levelCfg.m_Replay == 1
    local mainHelper = LevelManager:GetLevelMainHelper()
    local isUnlock = mainHelper:IsLevelUnLock(self.m_curLevelID)
    UILuaHelper.SetActive(self.m_btn_battle, isUnlock and not isHavePass)
    UILuaHelper.SetActive(self.m_node_lock, not isUnlock and not isHavePass)
    UILuaHelper.SetActive(self.m_node_nocount, false)
    UILuaHelper.SetActive(self.m_node_pass, isHavePass and not isReplay)
    UILuaHelper.SetActive(self.m_btn_Story_Back, isHavePass and isReplay)
  elseif self.m_levelType == LevelManager.LevelType.Tower then
    local towerHelper = LevelManager:GetLevelTowerHelper()
    local isUnlock = towerHelper:IsLevelUnLock(self.m_curLevelID)
    local isHaveLeftTimes = self:IsSubTowerHaveLeftTimes()
    UILuaHelper.SetActive(self.m_btn_battle, isUnlock and not isHavePass and isHaveLeftTimes)
    UILuaHelper.SetActive(self.m_node_pass, isHavePass)
    UILuaHelper.SetActive(self.m_node_lock, isUnlock ~= true)
    UILuaHelper.SetActive(self.m_node_nocount, not isHaveLeftTimes and not isHavePass and isUnlock)
    UILuaHelper.SetActive(self.m_btn_Story_Back, false)
  end
end

function LevelDetailSubPanel:CheckShowAnimIn()
  if self.m_levelType == LevelManager.LevelType.Tower then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, EnterAnimStr)
end

function LevelDetailSubPanel:CheckShowAnimOut(endFun)
  if self.m_detailOutTimer ~= nil then
    return
  end
  local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_level_panel_detail, EnterAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_level_panel_detail, OutAnimStr)
  self.m_detailOutTimer = TimeService:SetTimer(detailAnimLen, 1, function()
    if endFun then
      endFun()
    end
    self.m_detailOutTimer = nil
  end)
end

function LevelDetailSubPanel:OnBtndetailbgClicked()
  self:CheckShowAnimOut(function()
    if self.m_bgClkBack then
      self.m_bgClkBack()
    end
  end)
end

function LevelDetailSubPanel:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function LevelDetailSubPanel:OnBtnbattleClicked()
  if not self.m_curLevelID then
    return
  end
  local isHavePass = LevelManager:IsLevelHavePass(self.m_levelType, self.m_curLevelID)
  if isHavePass == true and self.m_levelType ~= LevelManager.LevelType.Dungeon then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 30008)
    return
  end
  if self.m_levelType == LevelManager.LevelType.Tower then
    local isNoCampHero = self:IsTowerLevelNoCampHero()
    if isNoCampHero == true then
      utils.CheckAndPushCommonTips({
        tipsID = 1223,
        func1 = function()
          BattleFlowManager:StartEnterBattle(self.m_levelType, self.m_curLevelID)
        end
      })
    else
      BattleFlowManager:StartEnterBattle(self.m_levelType, self.m_curLevelID)
    end
  else
    BattleFlowManager:StartEnterBattle(self.m_levelType, self.m_curLevelID)
  end
end

function LevelDetailSubPanel:OnEnemyIconClk(monsterID)
  if not monsterID then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
    battleWorldID = self.m_curBattleWorldCfg.m_MapID,
    stageStr = self.m_levelNameStr
  })
end

function LevelDetailSubPanel:OnBtnStoryBackClicked()
  if not self.m_curLevelID then
    return
  end
  BattleFlowManager:EnterShowPlot(self.m_curLevelID, self.m_curBattleWorldCfg.m_MapID, self.m_levelType, {
    self.m_curLevelID
  }, function(backFun)
    LevelManager:LoadLevelMapScene(function()
      log.info("LevelDetailSubPanel OnBtnStoryBackClicked LevelMap LoadBack")
      BattleFlowManager:CheckSetEnterTimer(LevelManager.LevelType.MainLevel)
      local formStr = "Form_LevelMain"
      StackFlow:Push(UIDefines.ID_FORM_LEVELMAIN)
      if backFun then
        backFun(formStr)
      end
    end)
  end)
end

return LevelDetailSubPanel
