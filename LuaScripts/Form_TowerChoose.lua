local Form_TowerChoose = class("Form_TowerChoose", require("UI/UIFrames/Form_TowerChooseUI"))
local TowerCfgIns = ConfigManager:GetConfigInsByName("Tower")
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local UpdateDeltaNum = 3
local string_format = string.format
local WeekNum = 7
local OneDayMaxCampNum = 2

function Form_TowerChoose:SetInitParam(param)
end

function Form_TowerChoose:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1103)
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_levelTowerHelper = LevelManager:GetLevelHelperByType(LevelManager.LevelType.Tower)
  self.m_isCanUpdateLeftTime = false
  self.m_curDeltaTimeNum = 0
  self.m_openItemList = {}
  self.m_openItemDataList = {}
  self:InitCreateOpenCampList()
  self:InitOpenList()
  self:PlayVoiceOnFirstEnter()
end

function Form_TowerChoose:OnActive()
  self.super.OnActive(self)
  self:CheckRegisterRedDot()
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  BattleFlowManager:CheckSetEnterTimer(LevelManager.LevelType.Tower)
  GlobalManagerIns:TriggerWwiseBGMState(13)
  GlobalManagerIns:TriggerWwiseBGMState(149)
end

function Form_TowerChoose:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:ClearData()
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function Form_TowerChoose:OnUpdate(dt)
  self:CheckUpdateLeftTime()
end

function Form_TowerChoose:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_TowerChoose:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_main_tower_redpoint, RedDotDefine.ModuleType.LevelSubTowerEntry, LevelManager.TowerLevelSubType.Main)
  for i = 1, LevelManager.TowerTribeMaxNum do
    local subLevelType = LevelManager.TowerLevelSubType["Tribe" .. i]
    local subTowerRedDotNode = self["m_icon_redpoint" .. i]
    if subTowerRedDotNode then
      self:RegisterOrUpdateRedDotItem(subTowerRedDotNode, RedDotDefine.ModuleType.LevelSubTowerEntry, subLevelType)
    end
  end
end

function Form_TowerChoose:AddEventListeners()
  self:addEventListener("eGameEvent_Level_StageTimesFresh", handler(self, self.OnEventFreshDailyTimes))
end

function Form_TowerChoose:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_TowerChoose:OnEventFreshDailyTimes()
  self:FreshUI()
end

function Form_TowerChoose:ClearData()
end

function Form_TowerChoose:FreshData()
end

function Form_TowerChoose:IsHaveSubTowerUnlock()
  local isHaveSubTowerUnlock = false
  for i = 1, LevelManager.TowerTribeMaxNum do
    local subLevelType = LevelManager.TowerLevelSubType["Tribe" .. i]
    local isUnlock = self.m_levelTowerHelper:IsLevelSubTypeUnlock(subLevelType)
    if isUnlock == true then
      isHaveSubTowerUnlock = true
      return isHaveSubTowerUnlock
    end
  end
  return isHaveSubTowerUnlock
end

function Form_TowerChoose:InitCreateOpenCampList()
  self.m_openItemDataList = {}
  for i = 1, WeekNum do
    self.m_openItemDataList[i] = {}
  end
  for i = 1, LevelManager.TowerTribeMaxNum do
    local subTowerType = LevelManager.TowerLevelSubType["Tribe" .. i]
    local towerSubTypeCfg = TowerCfgIns:GetValue_ByLevelSubType(subTowerType)
    local openDateArray = towerSubTypeCfg.m_OpenDate
    local campID = towerSubTypeCfg.m_CampResID
    for j = 0, openDateArray.Length - 1 do
      local openDate = openDateArray[j]
      local campIDList = self.m_openItemDataList[openDate]
      campIDList[#campIDList + 1] = campID
    end
  end
end

function Form_TowerChoose:CheckUpdateLeftTime()
  if not self.m_isCanUpdateLeftTime then
    return
  end
  if self.m_curDeltaTimeNum <= UpdateDeltaNum then
    self.m_curDeltaTimeNum = self.m_curDeltaTimeNum + 1
  else
    self.m_curDeltaTimeNum = 0
    self:ShowLeftTimeStr()
  end
end

function Form_TowerChoose:ShowLeftTimeStr()
  local nextResetTimer = TimeUtil:GetServerNextCommonResetTime()
  local curTimer = TimeUtil:GetServerTimeS()
  if nextResetTimer < curTimer then
    return
  end
  local leftTimeSec = nextResetTimer - curTimer
  self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(leftTimeSec)
end

function Form_TowerChoose:FreshUI()
  self:FreshMainTowerInfo()
  self:FreshTribeTowersInfo()
  self:FreshOpenList()
  self:FreshOpenListChoose()
end

function Form_TowerChoose:FreshMainTowerInfo()
  local mainTowerSubType = LevelManager.TowerLevelSubType.Main
  local towerSubTypeCfg = TowerCfgIns:GetValue_ByLevelSubType(mainTowerSubType)
  self.m_txt_stage_name_Text.text = towerSubTypeCfg.m_mName
  local curLevelCfg = self.m_levelTowerHelper:GetNextShowLevelCfg(mainTowerSubType)
  self.m_txt_stage_num_Text.text = curLevelCfg.m_LevelName
end

function Form_TowerChoose:FreshTribeTowersInfo()
  local MaxSubTowerType = LevelManager.TowerTribeMaxNum
  for subTowerNum = 1, MaxSubTowerType do
    local subTowerType = LevelManager.TowerLevelSubType["Tribe" .. subTowerNum]
    local towerSubTypeCfg = TowerCfgIns:GetValue_ByLevelSubType(subTowerType)
    if not towerSubTypeCfg:GetError() then
      self[string_format("m_txt_name_tower%s_Text", subTowerNum)].text = towerSubTypeCfg.m_mName
      local curLevelCfg = self.m_levelTowerHelper:GetNextShowLevelCfg(subTowerType)
      self[string_format("m_txt_stage_num%s_Text", subTowerNum)].text = curLevelCfg.m_LevelName
      local isSubTypeUnlock, type, unlock_str = self.m_levelTowerHelper:IsLevelSubTypeUnlock(subTowerType)
      local isOpen = self.m_levelTowerHelper:IsLevelSubTypeInOpen(subTowerType) and isSubTypeUnlock == true
      UILuaHelper.SetActive(self["m_lock" .. subTowerNum], isSubTypeUnlock ~= true)
      UILuaHelper.SetActive(self["m_img_close" .. subTowerNum], isSubTypeUnlock == true and isOpen ~= true)
      UILuaHelper.SetActive(self["m_tower_base_info" .. subTowerNum], isSubTypeUnlock == true)
      self["m_txt_tips" .. subTowerNum .. "_Text"].text = unlock_str
      local enterStatusTips
      if isOpen then
        local maxPassNum = towerSubTypeCfg.m_Times
        local curTimes = self.m_levelTowerHelper:GetDailyTimesBySubLevelType(subTowerType)
        if curTimes < 0 then
          curTimes = 0
        end
        local leftNum = maxPassNum - curTimes
        enterStatusTips = string_format(CommonTextIns:GetValue_ById(20036).m_mMessage, leftNum, maxPassNum)
      elseif isSubTypeUnlock then
        enterStatusTips = towerSubTypeCfg.m_mOpeningDays
      else
        enterStatusTips = CommonTextIns:GetValue_ById(20038).m_mMessage
      end
      self[string_format("m_state_tips%s_Text", subTowerNum)].text = enterStatusTips
      self:FreshTribeTowerCampIcon(self[string_format("m_img_camp%d_Image", subTowerNum)], towerSubTypeCfg.m_CampResID)
    end
  end
end

function Form_TowerChoose:FreshTribeTowerCampIcon(iconImg, campID)
  if not iconImg then
    return
  end
  if not campID then
    return
  end
  local campCfg = CampCfgIns:GetValue_ByCampID(campID)
  if campCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(iconImg, campCfg.m_TowerIcon)
end

function Form_TowerChoose:InitOpenList()
  for i = 1, WeekNum do
    local campIDList = self.m_openItemDataList[i]
    local parentRoot = self["m_item" .. i].transform
    local openItem = self:InitCreateOpenItem(parentRoot, campIDList, i)
    self.m_openItemList[i] = openItem
  end
end

function Form_TowerChoose:InitCreateOpenItem(parentRoot, campIDList, index)
  local cloneObj = GameObject.Instantiate(self.m_base_open_item, parentRoot).gameObject
  UILuaHelper.SetActive(cloneObj, true)
  UILuaHelper.SetLocalPosition(cloneObj, 0, 0, 0)
  local rootTrans = cloneObj.transform
  local selectNode = rootTrans:Find("node_select")
  local unSelectNode = rootTrans:Find("node_unselect")
  local txtSelectAllNode = rootTrans:Find("node_select/txt_all")
  local txtUnSelectAllNode = rootTrans:Find("node_unselect/txt_all")
  local selectIconListNode = rootTrans:Find("node_select/node_icon_list")
  local unSelectIconListNode = rootTrans:Find("node_unselect/node_icon_list")
  local isAllCamp = #campIDList >= LevelManager.TowerTribeMaxNum
  UILuaHelper.SetActive(txtSelectAllNode, isAllCamp)
  UILuaHelper.SetActive(txtUnSelectAllNode, isAllCamp)
  UILuaHelper.SetActive(selectIconListNode, not isAllCamp)
  UILuaHelper.SetActive(unSelectIconListNode, not isAllCamp)
  if not isAllCamp then
    for i = 1, OneDayMaxCampNum do
      local tempImg = rootTrans:Find("node_select/node_icon_list/img_select" .. i):GetComponent(T_Image)
      local tempUnSelectImg = rootTrans:Find("node_unselect/node_icon_list/img_select" .. i):GetComponent(T_Image)
      UILuaHelper.SetActive(tempImg, campIDList[i] ~= nil)
      UILuaHelper.SetActive(tempUnSelectImg, campIDList[i] ~= nil)
      if campIDList[i] then
        self:FreshTribeTowerCampIcon(tempImg, campIDList[i])
        self:FreshTribeTowerCampIcon(tempUnSelectImg, campIDList[i])
      end
    end
  end
  local chooseItem = {
    index = index,
    rootNode = cloneObj,
    selectNode = selectNode,
    unSelectNode = unSelectNode
  }
  return chooseItem
end

function Form_TowerChoose:FreshOpenList()
  local isHaveSubTowerUnlock = self:IsHaveSubTowerUnlock()
  if isHaveSubTowerUnlock then
    UILuaHelper.SetActive(self.m_itemList, true)
    UILuaHelper.SetActive(self.m_camp_tower_lock, false)
    self.m_isCanUpdateLeftTime = true
    self:FreshOpenListChoose()
  else
    self.m_isCanUpdateLeftTime = false
    UILuaHelper.SetActive(self.m_itemList, false)
    UILuaHelper.SetActive(self.m_camp_tower_lock, true)
  end
end

function Form_TowerChoose:FreshOpenListChoose()
  local curWDay = TimeUtil:GetServerTimeWeekDayHaveCommonOffset()
  for i, openItem in ipairs(self.m_openItemList) do
    UILuaHelper.SetActive(openItem.selectNode, i == curWDay)
    UILuaHelper.SetActive(openItem.unSelectNode, i ~= curWDay)
    if self["m_z_txt_day" .. i] then
      UILuaHelper.SetActive(self["m_z_txt_day" .. i], i ~= curWDay)
    end
    if self["m_z_txt_red_day" .. i] then
      UILuaHelper.SetActive(self["m_z_txt_red_day" .. i], i == curWDay)
    end
  end
end

function Form_TowerChoose:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HALLACTIVITYMAIN)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_TOWERCHOOSE)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
end

function Form_TowerChoose:OnBtnstartClicked()
  self:OnEnterTower(LevelManager.TowerLevelSubType.Main)
end

function Form_TowerChoose:OnBtnSubTower1Clicked()
  self:OnEnterTower(LevelManager.TowerLevelSubType.Tribe1)
end

function Form_TowerChoose:OnBtnSubTower2Clicked()
  self:OnEnterTower(LevelManager.TowerLevelSubType.Tribe2)
end

function Form_TowerChoose:OnBtnSubTower3Clicked()
  self:OnEnterTower(LevelManager.TowerLevelSubType.Tribe3)
end

function Form_TowerChoose:OnBtnSubTower4Clicked()
  self:OnEnterTower(LevelManager.TowerLevelSubType.Tribe4)
end

function Form_TowerChoose:OnEnterTower(subTowerType)
  if not subTowerType then
    return
  end
  local towerSubTypeCfg = TowerCfgIns:GetValue_ByLevelSubType(subTowerType)
  if towerSubTypeCfg:GetError() then
    return
  end
  local isSubTypeUnlock = self.m_levelTowerHelper:IsLevelSubTypeUnlock(subTowerType)
  if isSubTypeUnlock ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, towerSubTypeCfg.m_ClientMessage)
    return
  end
  local isSubTypeInOpen = self.m_levelTowerHelper:IsLevelSubTypeInOpen(subTowerType)
  if isSubTypeInOpen ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 21006)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_TOWER, {subType = subTowerType})
end

function Form_TowerChoose:OnBtnRankClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40026)
end

function Form_TowerChoose:PlayVoiceOnFirstEnter()
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("TowerVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
end

function Form_TowerChoose:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_TowerChoose", Form_TowerChoose)
return Form_TowerChoose
