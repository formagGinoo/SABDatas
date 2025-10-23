local Form_BossEquipmentPart = class("Form_BossEquipmentPart", require("UI/UIFrames/Form_BossEquipmentPartUI"))
local PartDunLevelIns = ConfigManager:GetConfigInsByName("DunLevel")
local PartDunDescIns = ConfigManager:GetConfigInsByName("PartDungeonDesc")
local MonsterGroupIns = ConfigManager:GetConfigInsByName("MonsterGroup")
local MonsterCfgIns = ConfigManager:GetConfigInsByName("Monster")

function Form_BossEquipmentPart:SetInitParam(param)
end

function Form_BossEquipmentPart:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curChapterCfg = tParam
    self.levelSubType = tParam.m_LevelSubType
  end
  self.m_equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  self.selctedTabIndex = 1
  self.curLevelCfg = nil
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1274)
  self.m_btn_Quick:SetActive(false)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnDungeonRewardItemClick)
  }
  local itemLevelData = {
    itemClkBackFun = handler(self, self.OnLevelItemClk)
  }
  self.m_PartLevelInfinityGrid = self:CreateInfinityGrid(self.m_pnl_tab_InfinityGrid, "EquipmentBoss/PartEqupLevelItem", itemLevelData)
  self.m_PartLevelInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnLevelItemClick))
  self.m_levelList = {}
  local itemTabData = {
    itemClkBackFun = handler(self, self.OnTabItemClk)
  }
  self.m_PartTabInfinityGrid = self:CreateInfinityGrid(self.m_tab_scrollView_InfinityGrid, "EquipmentBoss/PartEqupTabItem", itemTabData)
  self.m_PartTabInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnTabItemClick))
  self.m_tabList = {}
  local itemHeroData = {
    itemClkBackFun = handler(self, self.OnHeroItemClk)
  }
  self.m_HeroInfinityGrid = self:CreateInfinityGrid(self.m_list_item_InfinityGrid, "EquipmentBoss/PartEqupHeroItem", itemHeroData)
  self.m_heroList = {}
end

function Form_BossEquipmentPart:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshUI()
  self:OnFullBurstDayUpdate()
end

function Form_BossEquipmentPart:OnLevelItemClk(index, isLock)
  if self.m_levelList[index] and self.m_levelList[index].isLock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13035)
    return
  end
  if self.m_curLevelCfg and self.m_levelList[index].cfg and self.m_curLevelCfg == self.m_levelList[index].cfg then
    return
  end
  for i = 1, #self.m_levelList do
    self.m_levelList[i].selected = i == index
    if i == index then
      self.m_curLevelCfg = self.m_levelList[i].cfg
    end
  end
  local FormEnterStr = "BossEquipmentPart_in"
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, FormEnterStr)
  self.m_PartLevelInfinityGrid:ShowItemList(self.m_levelList)
  self:FreshTabList()
end

function Form_BossEquipmentPart:OnFullBurstDayUpdate()
  self.m_doublereward:SetActive(ActivityManager:IsFullBurstDayOpen())
end

function Form_BossEquipmentPart:FreshTabList()
  self.m_tabList = {}
  self.selctedTabIndex = 1
  local list = utils.changeCSArrayToLuaTable(self.m_curLevelCfg.m_DescID)
  for i = 1, #list do
    local tabData = {}
    tabData.cfg = PartDunDescIns:GetValue_ByID(list[i])
    tabData.selected = i == self.selctedTabIndex
    table.insert(self.m_tabList, tabData)
  end
  self.m_PartTabInfinityGrid:ShowItemList(self.m_tabList)
  self:ShowTabDesc()
  self.m_heroList = {}
  local heroList = utils.changeCSArrayToLuaTable(self.m_curLevelCfg.m_CharacterID)
  for i = 1, #heroList do
    local heroData = {}
    local cfg = HeroManager:GetHeroConfigByID(heroList[i])
    local url = ResourceUtil:GetHeroIconPath(heroList[i], cfg)
    heroData.m_RoleHead = url
    heroData.mID = heroList[i]
    heroData.isValid = HeroManager:GetHeroDataByConfigID(heroList[i]) ~= nil
    table.insert(self.m_heroList, heroData)
  end
  self.m_HeroInfinityGrid:ShowItemList(self.m_heroList)
  self:FreshBoss()
  self:FreshButtonsShow()
  self.m_btn_rewardpencent:SetActive(false)
  print("self.m_curLevelCfg.m_ItemID", self.m_curLevelCfg.m_mName)
  if self.m_curLevelCfg.m_ItemID and self.m_curLevelCfg.m_ItemID > 0 then
    self.m_btn_rewardpencent:SetActive(true)
    ResourceUtil:CreatIconById(self.m_img_rewardpencent_Image, self.m_curLevelCfg.m_ItemID)
  end
end

function Form_BossEquipmentPart:OnTabItemClk(index, isLock)
  for i = 1, #self.m_tabList do
    self.m_tabList[i].selected = i == index
  end
  self.selctedTabIndex = index
  self.m_PartTabInfinityGrid:ShowItemList(self.m_tabList)
  self:ShowTabDesc()
end

function Form_BossEquipmentPart:OnHeroItemClk(index, isLock)
  if self.m_heroList and self.m_heroList[index] then
    local heroData = self.m_heroList[index]
    utils.openItemDetailPop({
      iID = heroData.mID,
      iNum = 1
    })
  end
end

function Form_BossEquipmentPart:FreshButtonsShow()
  local maxUseTimes = self.m_equipmentHelper:GetChallengeDailyNum()
  local curUseTimes = self.m_equipmentHelper:GetLevelDailyData()
  local leftTimes = maxUseTimes - curUseTimes
  self.m_txt_Left_Time_Text.text = leftTimes .. "/" .. maxUseTimes
  self.m_txt_Left_Time_Grey_Text.text = leftTimes .. "/" .. maxUseTimes
  UILuaHelper.SetActive(self.m_btn_StartGrey, leftTimes <= 0)
  UILuaHelper.SetActive(self.m_btn_Start, 0 < leftTimes)
  local heroModify = self.m_curLevelCfg.m_HeroModify or 0
  UILuaHelper.SetActive(self.m_pnl_levellock, heroModify ~= 0)
  if heroModify ~= 0 then
    local HeroModifyIns = ConfigManager:GetConfigInsByName("HeroModify")
    local heroModifyCfg = HeroModifyIns:GetValue_ByID(heroModify)
    if heroModifyCfg:GetError() ~= true then
      self.m_txt_levellock_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(20204), heroModifyCfg.m_ForceLevel)
    end
  end
end

function Form_BossEquipmentPart:ShowTabDesc()
  if self.m_tabList and self.m_tabList[self.selctedTabIndex] then
    local descCfg = self.m_tabList[self.selctedTabIndex].cfg
    local strDesc = descCfg and descCfg.m_mDesc or ""
    local extraParam = {}
    local list = utils.changeCSArrayToLuaTable(descCfg.m_BuffParam)
    for i = 1, #list do
      local paramValue, paramType = HeroManager:GetSkillValueByIdAndLevel(list[i], self.skillLv)
      local paramFStr = "%.f"
      local paramFStr1 = "%.1f"
      if GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[paramType] then
        local paramF = GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.Fixed == paramType and paramFStr or paramFStr1
        paramValue = string.format(paramF, paramValue / GlobalConfig.SKILL_UPGRADE_PARAM_NUMBER[paramType])
      end
      if GlobalConfig.SKILL_UPGRADE_PARAM_TYPE.TenThousandPercent == paramType then
        paramValue = string.format(ConfigManager:GetCommonTextById(100009), tostring(paramValue))
      end
      table.insert(extraParam, paramValue)
    end
    if 0 < #list then
      strDesc = string.CS_Format(strDesc, table.unpack(extraParam))
    end
    self.m_txt_des_Text.text = strDesc
  end
end

function Form_BossEquipmentPart:OnBtndetailClicked()
  StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
    battleWorldID = self.m_curLevelCfg.m_MapID,
    stageStr = self.m_curLevelCfg.m_mName,
    skillLv = self.skillLv
  })
end

function Form_BossEquipmentPart:OnBtnSimClicked()
  LevelManager:SetPartDungState(true)
  BattleFlowManager:StartEnterBattle(LevelManager.LevelType.Dungeon, self.m_curLevelCfg.m_LevelID, true)
end

function Form_BossEquipmentPart:OnBtnStartClicked()
  LevelManager:SetPartDungState(true)
  BattleFlowManager:StartEnterBattle(LevelManager.LevelType.Dungeon, self.m_curLevelCfg.m_LevelID)
end

function Form_BossEquipmentPart:OnBtnStartGreyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20017))
end

function Form_BossEquipmentPart:OnBtnrewardpencentClicked()
  if self.m_curLevelCfg.m_ItemID and self.m_curLevelCfg.m_ItemID > 0 then
    utils.openItemDetailPop({
      iID = self.m_curLevelCfg.m_ItemID,
      iNum = 0
    })
  end
end

function Form_BossEquipmentPart:FreshUI()
  CS.UI.UILuaHelper.SetAtlasSprite(self.m_img_equiptype_Image, self.m_curChapterCfg.m_Icon)
  CS.UI.UILuaHelper.SetAtlasSprite(self.m_img_role_Image, self.m_curChapterCfg.m_Background)
  self.m_levelList = {}
  local chapterInfoAll = PartDunLevelIns:GetAll()
  local selectedItem
  for i, v in pairs(chapterInfoAll) do
    if v.m_LevelSubType == self.levelSubType then
      local levelData = {}
      levelData.cfg = v
      levelData.isLock = not self.m_equipmentHelper:IsPartLevelUnLock(v.m_LevelID)
      if levelData.isLock == false then
        selectedItem = levelData
      end
      levelData.selected = false
      table.insert(self.m_levelList, levelData)
    end
  end
  if selectedItem then
    selectedItem.selected = true
  end
  self.m_curLevelCfg = selectedItem and selectedItem.cfg or self.m_levelList[1].cfg
  self.m_PartLevelInfinityGrid:ShowItemList(self.m_levelList)
  self.m_btn_rewardpencent:SetActive(false)
  if self.m_curLevelCfg.m_ItemID and self.m_curLevelCfg.m_ItemID > 0 then
    self.m_btn_rewardpencent:SetActive(true)
  end
  self:FreshTabList()
end

function Form_BossEquipmentPart:FreshBoss()
  local battleWordID = self.m_curLevelCfg.m_MapID
  local battleCfg = ConfigManager:GetBattleWorldCfgById(battleWordID)
  local monsterGroupArray = ConfigManager:BattleWorldMonsterGroupList(battleCfg)
  local monsterGroupID = monsterGroupArray[0]
  local monsterGroupCfg = MonsterGroupIns:GetValue_ByID(monsterGroupID)
  local monsterList = monsterGroupCfg.m_MonsterList
  self.skillLv = monsterGroupCfg.m_MonsterSkillLevel
  if self.skillLv == nil or self.skillLv == 0 then
    self.skillLv = 1
  end
  local monsterTemp = monsterList[0]
  local monsterID = monsterTemp[1]
  local monsterCfg = MonsterCfgIns:GetValue_ByMonsterID(monsterID)
  self.m_txt_bossname_Text.text = monsterCfg and monsterCfg.m_mName or ""
end

function Form_BossEquipmentPart:OnEventLevelSweep(event, levelID, stageIndex)
  if self.m_curLevelCfg and levelID == self.m_curLevelCfg.m_LevelID then
    self:FreshButtonsShow()
  end
end

function Form_BossEquipmentPart:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_BossEquipmentPart:AddEventListeners()
  self:addEventListener("eGameEvent_Level_MopUp", handler(self, self.OnEventLevelSweep))
  self:addEventListener("eGameEvent_Activity_FullBurstDayUpdate", handler(self, self.OnFullBurstDayUpdate))
end

function Form_BossEquipmentPart:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BossEquipmentPart:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BossEquipmentPart:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_BOSSEQUIPMENTPART)
end

function Form_BossEquipmentPart:OnBtnrewardviewClicked()
  local param = {}
  param.levelSubType = self.levelSubType
  StackPopup:Push(UIDefines.ID_FORM_BOSSEQUIPMENTPARTREWARD, param)
end

function Form_BossEquipmentPart:OnBackHome()
  StackPopup:PopAll()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  LevelManager:SetPartDungState(false)
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
end

function Form_BossEquipmentPart:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BossEquipmentPart", Form_BossEquipmentPart)
return Form_BossEquipmentPart
