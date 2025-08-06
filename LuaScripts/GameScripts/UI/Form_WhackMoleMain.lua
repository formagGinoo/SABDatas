local Form_WhackMoleMain = class("Form_WhackMoleMain", require("UI/UIFrames/Form_WhackMoleMainUI"))
local ITEM_HEIGHT = 180

function Form_WhackMoleMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_levelListScrollRect = self.m_level_list:GetComponent(T_ScrollRect)
  self.ScrollRectHandler = handler(self, self.OnScrollValueChanged)
  self.firstListen = true
  self.levelViewCenterPosY = nil
  UILuaHelper.SetActive(self.m_btn_start_grey, false)
  UILuaHelper.SetActive(self.m_btn_home, true)
  self.m_levelListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_level_list_InfinityGrid, "WhackMole/UIWhackMoleLevelItem")
  CS.UnityEngine.Canvas.ForceUpdateCanvases()
  self.decNum = 1
  self.extraItemNum = math.floor(self:GetCacheItemNum() / 2)
  self.selectIndex = 1 + self.extraItemNum
  self:addEventListener("eGameEvent_WhackMole_Level_Select", function(selectIndex)
    self.m_levelListInfinityGrid:ScrollTo(selectIndex - self.decNum)
  end)
  self:addEventListener("eGameEvent_ActMinigame_Finish", function()
    local preIndex = self.selectIndex
    self:OnRefreshData()
    if self.selectIndex == preIndex and self.m_levelListInfinityGrid then
      self.m_levelListInfinityGrid:GetShowItemByIndex(self.selectIndex):ShowSelectStyle(true)
    else
      self.m_levelListInfinityGrid:ScrollTo(self.selectIndex - self.decNum)
    end
  end)
  self.m_isGetFirstCfg = false
end

function Form_WhackMoleMain:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.main_id = tParam.main_id
  self.sub_id = tParam.sub_id
  self.firstListen = true
  self:OnFirstRefreshData()
  self:OnRefreshData()
  self.m_levelListScrollRect.onValueChanged:RemoveListener(self.ScrollRectHandler)
  self.m_levelListScrollRect.onValueChanged:AddListener(self.ScrollRectHandler)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(300)
end

function Form_WhackMoleMain:OnRefreshData()
  self:OnRefreshLevelData()
  self:OnRefreshLevelList()
  self:RegisterOrUpdateRedDotItem(self.m_reddot_task, RedDotDefine.ModuleType.HeroActMiniGameTask, {
    actId = self.main_id,
    whackMoleTaskId = HeroActivityManager:GetSubFuncID(self.main_id, HeroActivityManager.SubActTypeEnum.GameTask)
  })
end

function Form_WhackMoleMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_WhackMoleMain:OnDestroy()
  self.super.OnDestroy(self)
  self.m_levelListScrollRect.onValueChanged:RemoveListener(self.ScrollRectHandler)
  self:clearEventListener()
end

function Form_WhackMoleMain:OnBackClk()
  self:CloseForm()
end

function Form_WhackMoleMain:OnFirstRefreshData()
  if self.m_isGetFirstCfg then
    self.m_isGetFirstCfg = true
    return
  end
  self.m_levelConfigs = {}
  local format_configs = {}
  local tempAllCfg = HeroActivityManager:GetActWhackMoleInfoCfgByID(self.sub_id)
  for _, config in pairs(tempAllCfg) do
    local m_levelID = config.m_LevelID
    if m_levelID and 0 < m_levelID then
      format_configs[m_levelID] = config
    end
  end
  self.m_levelConfigs = format_configs
end

function Form_WhackMoleMain:OnScrollValueChanged()
  if self.firstListen then
    local firstShowItem = self.m_levelListInfinityGrid:GetShowItemByIndex(self.selectIndex)
    if firstShowItem then
      firstShowItem:ShowSelectStyle(true)
    end
    self.m_levelListInfinityGrid:ScrollTo(self.selectIndex - self.decNum)
    if not self.levelViewCenterPosY then
      self.levelViewCenterPosY = self.m_levelListInfinityGrid:GetShowItemByIndex(self.extraItemNum + 1).m_itemTemplateCache.transform.position.y
    end
    self.firstListen = false
    return
  end
  self:UpdateCenterSelection()
end

function Form_WhackMoleMain:UpdateCenterSelection()
  local minDistance = math.huge
  local centerIndex = self.selectIndex
  local items = self.m_levelListInfinityGrid:GetAllShownItemList()
  if not items then
    return
  end
  for i, item in ipairs(items) do
    local itemPos = item.m_itemTemplateCache.transform.position
    local distance = math.abs(itemPos.y - self.levelViewCenterPosY)
    if minDistance > distance then
      minDistance = distance
      centerIndex = item.m_itemIndex
    end
  end
  if centerIndex ~= self.selectIndex then
    self:SetSelectIndex(centerIndex)
  end
end

function Form_WhackMoleMain:SetSelectIndex(selectIndex)
  if selectIndex < self.extraItemNum + 1 or self.maxIndex and selectIndex > self.maxIndex then
    return
  end
  local curShowItem = self.m_levelListInfinityGrid:GetShowItemByIndex(self.selectIndex)
  if curShowItem then
    curShowItem:ShowSelectStyle(false)
  end
  self.selectIndex = selectIndex
  self.m_levelListInfinityGrid:GetShowItemByIndex(self.selectIndex):ShowSelectStyle(true)
  local data = self.levelDataList[selectIndex]
  local isActive = false
  if data and data.levelState == 2 then
    isActive = true
  else
    isActive = false
  end
  UILuaHelper.SetActive(self.m_btn_start_grey, isActive)
end

function Form_WhackMoleMain:OnRefreshLevelData()
  self.levelDataList = {}
  self.m_format_configs = {}
  if self.selectIndex ~= self.extraItemNum + 1 then
    self.m_levelListInfinityGrid:GetShowItemByIndex(self.selectIndex):ShowSelectStyle(false)
  end
  for _ = 1, self.extraItemNum do
    table.insert(self.levelDataList, {})
  end
  self.m_miniGameServerDataStat = HeroActivityManager:GetHeroActData(self.main_id).server_data.stMiniGame.mGameStat
  for i, v in pairs(self.m_levelConfigs) do
    local levelState = 2
    local timeNotCome = true
    local unLockTime
    local tempData = {}
    local open_time = TimeUtil:TimeStringToTimeSec2(v.m_OpenTime) or 0
    local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = self.main_id,
      m_MemoryID = v.m_LevelID
    })
    if is_corved then
      open_time = t1
    end
    local cur_time = TimeUtil:GetServerTimeS()
    local is_in_time = open_time <= cur_time
    if is_in_time then
      timeNotCome = false
      local is_done = self.m_miniGameServerDataStat[v.m_LevelID] == 1
      if is_done then
        levelState = 0
      else
        local is_pre_done = false
        if not v.m_PreLevel or 0 >= v.m_PreLevel then
          is_pre_done = true
          levelState = 1
        else
          local config = HeroActivityManager:GetActWhackMoleInfoCfgByIDAndLevelId(self.sub_id, v.m_PreLevel)
          if config:GetError() then
            log.error("获取打地鼠前置关卡数据配置失败，参数无效！", self.sub_id, v.m_PreLevel)
            return
          end
          is_pre_done = self.m_miniGameServerDataStat[config.m_LevelID] == 1
          if is_pre_done then
            levelState = 1
          end
        end
      end
      if levelState == 1 then
        self.selectIndex = self.extraItemNum + i
      end
    else
      unLockTime = open_time
    end
    tempData = {
      levelCfg = v,
      levelState = levelState,
      timeNotCome = timeNotCome
    }
    table.insert(self.levelDataList, tempData)
  end
  self.maxIndex = #self.levelDataList
  for _ = 1, self.extraItemNum do
    table.insert(self.levelDataList, {})
  end
  if self.m_miniGameServerDataStat[#self.m_levelConfigs] == 1 then
    self.selectIndex = #self.m_levelConfigs + self.extraItemNum
  end
end

function Form_WhackMoleMain:GetCacheItemNum()
  local count = math.ceil(self.m_levelListScrollRect.viewport.rect.height / ITEM_HEIGHT)
  if count % 2 == 0 then
    self.decNum = 2
  end
  return count
end

function Form_WhackMoleMain:OnRefreshLevelList()
  self.m_levelListInfinityGrid:ShowItemList(self.levelDataList)
end

function Form_WhackMoleMain:OnBtntaskClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.main_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.main_id, HeroActivityManager.SubActTypeEnum.GameTask)
  })
end

function Form_WhackMoleMain:OnBtnstartClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(318)
  StackFlow:Push(UIDefines.ID_FORM_WHACKMOLEBATTLEMAIN, {
    iSubActId = HeroActivityManager:GetSubFuncID(self.main_id, HeroActivityManager.SubActTypeEnum.MiniGame),
    iLevelID = self.selectIndex - self.extraItemNum,
    iActId = self.main_id
  })
end

function Form_WhackMoleMain:OnBtnstartgreyClicked()
  local curLevelData = self.levelDataList[self.selectIndex]
  if curLevelData.timeNotCome then
    local open_time = TimeUtil:TimeStringToTimeSec2(curLevelData.levelCfg.m_OpenTime) or 0
    local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = self.main_id,
      m_MemoryID = curLevelData.levelCfg.m_LevelID
    })
    if is_corved then
      open_time = t1
    end
    UILuaHelper.ShowClientMessageFormate(10511, TimeUtil:TimerToString3(open_time))
  elseif self.levelDataList[self.selectIndex - 1] then
    local preLevelName = self.levelDataList[self.selectIndex - 1].levelCfg.m_mName
    UILuaHelper.ShowClientMessageFormate(10510, tostring(preLevelName))
  end
end

function Form_WhackMoleMain:IsFullScreen()
  return true
end

ActiveLuaUI("Form_WhackMoleMain", Form_WhackMoleMain)
return Form_WhackMoleMain
