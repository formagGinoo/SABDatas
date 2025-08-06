local Form_Tower = class("Form_Tower", require("UI/UIFrames/Form_TowerUI"))
local DefaultLevelIndex = 1
local DefaultTowerIndex = 1
local TowerIns = ConfigManager:GetConfigInsByName("Tower")
local UpLevelAnimStr = "TowerChoose_turn_up"
local DownLevelAnimStr = "TowerChoose_turn_down"
local DragLimitNum = 50

function Form_Tower:SetInitParam(param)
end

function Form_Tower:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1103)
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_levelTowerHelper = LevelManager:GetLevelHelperByType(LevelManager.LevelType.Tower)
  self.m_tower_BtnEx = self.m_tower_buttonEx:GetComponent("ButtonExtensions")
  if self.m_tower_BtnEx then
    self.m_tower_BtnEx.BeginDrag = handler(self, self.OnImgBeginDrag)
    self.m_tower_BtnEx.EndDrag = handler(self, self.OnImgEndDrag)
  end
  self.m_startDragPos = nil
  self.m_curTowerIndex = nil
  self.m_luaDetailLevel = nil
  self.m_curShowLevelList = nil
  self.m_curLevelIndex = nil
  self.m_curShowLevelCfg = nil
  self.m_nextImportantLevelCfg = nil
  self.m_curImportantLevelIndex = nil
  self.m_TopItemWidgetList = {}
  self.m_rewardTopItemBase = self.m_top_reward_root.transform:Find("c_common_item")
  UILuaHelper.SetActive(self.m_rewardTopItemBase, false)
  self.m_CenterItemWidgetList = {}
  self.m_rewardCenterItemBase = self.m_center_reward_root.transform:Find("c_common_item")
  UILuaHelper.SetActive(self.m_rewardCenterItemBase, false)
  self.m_openTowerTypeList = nil
  self.m_towerBgNodeDic = {}
end

function Form_Tower:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  BattleFlowManager:CheckSetEnterTimer(LevelManager.LevelType.Tower)
  local towerSubType = self.m_openTowerTypeList[self.m_curTowerIndex]
  if towerSubType then
    LevelManager:CheckSetSubTowerDailyEnterTime(towerSubType)
  end
  GlobalManagerIns:TriggerWwiseBGMState(13)
end

function Form_Tower:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:ClearData()
end

function Form_Tower:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:dispose()
    self.m_luaDetailLevel = nil
  end
  if CS.GameQualityManager.DestroyLevelMapAsset and self.m_towerBgNodeDic then
    for levelSubType, tempBgNode in pairs(self.m_towerBgNodeDic) do
      if tempBgNode then
        GameObject.Destroy(tempBgNode.gameObject)
        CS.MUF.Resource.ResourceManager.UnloadAsset("ui_tower_tower_bg" .. levelSubType, CS.MUF.Resource.ResourceType.UI)
      end
    end
    self.m_towerBgNodeDic = {}
  end
end

function Form_Tower:AddEventListeners()
  self:addEventListener("eGameEvent_Level_DailyReset", handler(self, self.OnEventDailyReset))
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:AddEventListeners()
  end
end

function Form_Tower:RemoveAllEventListeners()
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:RemoveAllEventListeners()
  end
  self:clearEventListener()
end

function Form_Tower:OnEventDailyReset()
  self:OnBackClk()
end

function Form_Tower:FreshOpenTowerList()
  self.m_openTowerTypeList = {}
  for _, levelSubType in pairs(LevelManager.TowerLevelSubType) do
    local isInOpen = self.m_levelTowerHelper:IsLevelSubTypeInOpen(levelSubType)
    local isUnlock = self.m_levelTowerHelper:IsLevelSubTypeUnlock(levelSubType)
    if isInOpen == true and isUnlock == true then
      self.m_openTowerTypeList[#self.m_openTowerTypeList + 1] = levelSubType
    end
  end
  table.sort(self.m_openTowerTypeList, function(a, b)
    return a < b
  end)
end

function Form_Tower:GetTowerIndexBySubType(levelSubType)
  if not levelSubType then
    return
  end
  if not self.m_openTowerTypeList then
    return
  end
  for i, tempSubType in ipairs(self.m_openTowerTypeList) do
    if tempSubType == levelSubType then
      return i
    end
  end
end

function Form_Tower:ClearData()
end

function Form_Tower:FreshData()
  self:FreshOpenTowerList()
end

function Form_Tower:FreshTowerTypeData(isSelectDefault)
  if not self.m_curTowerIndex then
    return
  end
  local towerSubType = self.m_openTowerTypeList[self.m_curTowerIndex]
  self.m_curShowLevelList = self.m_levelTowerHelper:GetTowerLevelList(towerSubType)
  self:FreshTowerName(towerSubType)
  self:FreshSubTypeLevelIndex(isSelectDefault)
  self:FreshNextImportantCfg()
end

function Form_Tower:FreshTowerName(towerSubType)
  if not towerSubType then
    return
  end
  local towerCfg = TowerIns:GetValue_ByLevelSubType(towerSubType)
  if towerCfg:GetError() then
    return
  end
  self.m_txt_tower_name_Text.text = towerCfg.m_mName
end

function Form_Tower:FreshNextImportantCfg()
  if not self.m_curShowLevelList then
    return
  end
  if not self.m_curTowerIndex then
    return
  end
  local subTowerType = self.m_openTowerTypeList[self.m_curTowerIndex]
  if not subTowerType then
    return
  end
  local curLevelCfg = self.m_levelTowerHelper:GetNextShowLevelCfg(subTowerType)
  local nextImportantLevelCfg, curImportantLevelIndex
  local curLevelID = curLevelCfg.m_LevelID
  local isOverNextLevel = false
  for index, tempLevelCfg in ipairs(self.m_curShowLevelList) do
    if curLevelID == tempLevelCfg.m_LevelID then
      isOverNextLevel = true
    end
    if isOverNextLevel and tempLevelCfg.m_ImportantTag == 1 then
      nextImportantLevelCfg = tempLevelCfg
      curImportantLevelIndex = index
      break
    end
  end
  self.m_nextImportantLevelCfg = nextImportantLevelCfg
  self.m_curImportantLevelIndex = curImportantLevelIndex
end

function Form_Tower:FreshSubTypeLevelIndex(isSelectDefault)
  if not self.m_curTowerIndex then
    return
  end
  local subTowerType = self.m_openTowerTypeList[self.m_curTowerIndex]
  if not subTowerType then
    return
  end
  local curLevelCfg = self.m_levelTowerHelper:GetNextShowLevelCfg(subTowerType)
  if isSelectDefault then
    self.m_curLevelIndex = DefaultLevelIndex
    if curLevelCfg and self.m_curShowLevelList then
      for index, tempLevelCfg in ipairs(self.m_curShowLevelList) do
        if curLevelCfg.m_LevelID == tempLevelCfg.m_LevelID then
          self.m_curLevelIndex = index
          break
        end
      end
    end
  else
    self.m_curLevelIndex = self.m_curLevelIndex or DefaultLevelIndex
  end
  self.m_curShowLevelCfg = self.m_curShowLevelList[self.m_curLevelIndex]
end

function Form_Tower:FreshUI()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self:FreshOpenTowerShow()
  local towerSubType = tParam.subType or LevelManager.TowerLevelSubType.Main
  local towerIndex = self:GetTowerIndexBySubType(towerSubType)
  towerIndex = towerIndex or DefaultTowerIndex
  self.m_csui.m_param = nil
  self:FreshChangeSubType(towerIndex)
end

function Form_Tower:FreshOpenTowerShow()
  for i = 1, LevelManager.TowerEnumMaxNum do
    UILuaHelper.SetActive(self["m_icon_select" .. i], false)
    UILuaHelper.SetActive(self["m_icon_unselect" .. i], self.m_openTowerTypeList[i] ~= nil)
  end
  local openTowerNum = #self.m_openTowerTypeList
  UILuaHelper.SetActive(self.m_btn_LastTower, 1 < openTowerNum)
  UILuaHelper.SetActive(self.m_btn_NextTower, 1 < openTowerNum)
end

function Form_Tower:FreshChangeSubType(towerIndex)
  local lastTowerIndex = self.m_curTowerIndex
  if lastTowerIndex then
    local lastSelectImg = self["m_icon_select" .. lastTowerIndex]
    UILuaHelper.SetActive(lastSelectImg, false)
  end
  if towerIndex then
    local curSelectImg = self["m_icon_select" .. towerIndex]
    UILuaHelper.SetActive(curSelectImg, true)
    self.m_curTowerIndex = towerIndex
    self:FreshTowerTypeData(true)
    self:FreshTowerUI()
  end
  UILuaHelper.SetActive(self.m_img_last_tower_normal, 1 < towerIndex)
  UILuaHelper.SetActive(self.m_img_last_tower_gray, towerIndex <= 1)
  local maxChooseTowerNum = #self.m_openTowerTypeList
  UILuaHelper.SetActive(self.m_img_next_tower_normal, towerIndex < maxChooseTowerNum)
  UILuaHelper.SetActive(self.m_img_next_tower_gray, towerIndex >= maxChooseTowerNum)
  self:CheckFreshTowerBg()
end

function Form_Tower:FreshTowerUI()
  if not self.m_curShowLevelList then
    return
  end
  if not self.m_curShowLevelCfg then
    return
  end
  self:FreshNextImportantReward()
  self:FreshShowChooseLevel()
  self:FreshShowLevelDetail()
end

function Form_Tower:FreshShowChooseLevel()
  if not self.m_curShowLevelCfg then
    return
  end
  self.m_level_name_Text.text = self.m_curShowLevelCfg.m_LevelName
  self:FreshTopOrCenterRewardActive()
end

function Form_Tower:FreshTopOrCenterRewardActive()
  if not self.m_nextImportantLevelCfg then
    UILuaHelper.SetActive(self.m_reward_top, false)
    UILuaHelper.SetActive(self.m_reward_center, false)
    return
  end
  UILuaHelper.SetActive(self.m_reward_center, self.m_curImportantLevelIndex == self.m_curLevelIndex)
  UILuaHelper.SetActive(self.m_reward_top, self.m_curLevelIndex < self.m_curImportantLevelIndex)
end

function Form_Tower:FreshShowLevelDetail()
  if not self.m_curShowLevelCfg then
    return
  end
  UILuaHelper.SetActive(self.m_level_detail_root, true)
  local levelSubType = self.m_curShowLevelCfg.m_LevelSubType
  local levelID = self.m_curShowLevelCfg.m_LevelID
  if self.m_luaDetailLevel == nil then
    SubPanelManager:LoadSubPanel("LevelDetailSubPanel", self.m_level_detail_root, self, {}, {
      levelType = LevelManager.LevelType.Tower,
      levelSubType = levelSubType,
      levelID = levelID
    }, function(luaPanel)
      self.m_luaDetailLevel = luaPanel
      self.m_luaDetailLevel:AddEventListeners()
    end)
  else
    self.m_luaDetailLevel:FreshData({
      levelType = LevelManager.LevelType.Tower,
      levelSubType = levelSubType,
      levelID = levelID
    })
  end
end

function Form_Tower:FreshNextImportantReward()
  if not self.m_nextImportantLevelCfg then
    return
  end
  self.m_txt_reward_stage_Text.text = self.m_nextImportantLevelCfg.m_LevelName
  local rewardArray = self.m_nextImportantLevelCfg.m_FirstBonusClient
  self:FreshTopRewardList(rewardArray)
  self:FreshCenterRewardList(rewardArray)
end

function Form_Tower:FreshTopRewardList(rewardArray)
  if not rewardArray then
    return
  end
  if not rewardArray or rewardArray.Length <= 0 then
    return
  end
  local itemWidgets = self.m_TopItemWidgetList
  local dataLen = rewardArray.Length
  local parentTrans = self.m_top_reward_root
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
      local itemObj = GameObject.Instantiate(self.m_rewardTopItemBase, parentTrans.transform).gameObject
      itemObj.name = self.m_rewardTopItemBase.name .. i
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

function Form_Tower:FreshCenterRewardList(rewardArray)
  if not rewardArray then
    return
  end
  if not rewardArray or rewardArray.Length <= 0 then
    return
  end
  local itemWidgets = self.m_CenterItemWidgetList
  local dataLen = rewardArray.Length
  local parentTrans = self.m_center_reward_root
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
      local itemObj = GameObject.Instantiate(self.m_rewardCenterItemBase, parentTrans.transform).gameObject
      itemObj.name = self.m_rewardCenterItemBase.name .. i
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

function Form_Tower:CheckShowLastLevel()
  if self.m_curLevelIndex <= 1 then
    return
  end
  self.m_level_name_anim_Text.text = self.m_curShowLevelCfg.m_LevelName
  self.m_curLevelIndex = self.m_curLevelIndex - 1
  self.m_curShowLevelCfg = self.m_curShowLevelList[self.m_curLevelIndex]
  self:FreshShowChooseLevel()
  self:FreshShowLevelDetail()
  UILuaHelper.PlayAnimationByName(self.m_center_node, UpLevelAnimStr)
end

function Form_Tower:CheckShowNextLevel()
  if self.m_curLevelIndex >= #self.m_curShowLevelList then
    return
  end
  self.m_level_name_anim_Text.text = self.m_curShowLevelCfg.m_LevelName
  self.m_curLevelIndex = self.m_curLevelIndex + 1
  self.m_curShowLevelCfg = self.m_curShowLevelList[self.m_curLevelIndex]
  self:FreshShowChooseLevel()
  self:FreshShowLevelDetail()
  UILuaHelper.PlayAnimationByName(self.m_center_node, DownLevelAnimStr)
end

function Form_Tower:CheckFreshTowerBg()
  if not self.m_curTowerIndex then
    return
  end
  if not self.m_openTowerTypeList then
    return
  end
  local levelSubType = self.m_openTowerTypeList[self.m_curTowerIndex]
  local bgNode = self.m_towerBgNodeDic[levelSubType]
  for levelType, tempBgNode in pairs(self.m_towerBgNodeDic) do
    if tempBgNode and levelType ~= levelSubType then
      UILuaHelper.SetActive(tempBgNode, false)
    end
  end
  if bgNode then
    UILuaHelper.SetActive(bgNode, true)
  else
    UIManager:LoadUIPrefab("ui_tower_tower_bg" .. levelSubType, function(uiName, uiObject)
      UILuaHelper.SetParent(uiObject, self.m_bg_root, true)
      self.m_towerBgNodeDic[levelSubType] = uiObject
    end, function(errorStr)
    end)
  end
end

function Form_Tower:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:Push(UIDefines.ID_FORM_TOWERCHOOSE)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_TOWER)
  self:DestroyBigSystemUIImmediately()
end

function Form_Tower:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    GameSceneManager:CheckChangeSceneToMainCity(nil, true)
  end
  self:DestroyBigSystemUIImmediately()
end

function Form_Tower:OnBtnLastClicked()
  self:CheckShowLastLevel()
end

function Form_Tower:OnBtnNextClicked()
  self:CheckShowNextLevel()
end

function Form_Tower:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_Tower:OnBtnjumpClicked()
  self:FreshSubTypeLevelIndex(true)
  self:FreshNextImportantReward()
  self:FreshShowChooseLevel()
  self:FreshShowLevelDetail()
end

function Form_Tower:OnBtnLastTowerClicked()
  local curTowerIndex = self.m_curTowerIndex
  if curTowerIndex <= 1 then
    return
  end
  self:FreshChangeSubType(curTowerIndex - 1)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Tower_in")
end

function Form_Tower:OnBtnNextTowerClicked()
  local curTowerIndex = self.m_curTowerIndex
  if curTowerIndex >= #self.m_openTowerTypeList then
    return
  end
  self:FreshChangeSubType(curTowerIndex + 1)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Tower_in")
end

function Form_Tower:OnBtnRankClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40026)
end

function Form_Tower:OnImgBeginDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
end

function Form_Tower:OnImgEndDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.y - self.m_startDragPos.y
  local absDeltaNum = math.abs(deltaNum)
  if absDeltaNum < DragLimitNum then
    return
  end
  if 0 < deltaNum then
    self:CheckShowLastLevel()
  else
    self:CheckShowNextLevel()
  end
  self.m_startDragPos = nil
end

function Form_Tower:IsFullScreen()
  return true
end

function Form_Tower:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra("LevelDetailSubPanel")
  if vPackageSub ~= nil then
    for i = 1, #vPackageSub do
      vPackage[#vPackage + 1] = vPackageSub[i]
    end
  end
  if vResourceExtraSub ~= nil then
    for i = 1, #vResourceExtraSub do
      vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
    end
  end
  for _, subLevelType in pairs(LevelManager.TowerLevelSubType) do
    vResourceExtra[#vResourceExtra + 1] = {
      sName = "ui_tower_tower_bg" .. subLevelType,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Tower", Form_Tower)
return Form_Tower
