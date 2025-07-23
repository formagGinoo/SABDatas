local Form_Heroheat = class("Form_Heroheat", require("UI/UIFrames/Form_HeroheatUI"))
local LineUpRecommendIns = ConfigManager:GetConfigInsByName("LineUpRecommend")
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local LeftTabType = {NormalTab = 1, TreeTab = 2}
local allTxt = UILuaHelper.GetCommonText(100601)

function Form_Heroheat:SetInitParam(param)
end

function Form_Heroheat:AfterInit()
  self.super.AfterInit(self)
  self.m_lineUpRecommend_Tab_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_lineUpcommend_Tab_InfinityGrid, "UIHeroListSmallItem5")
  self.m_lineUpRecommend_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_lineUpcommend_InfinityGrid, "UIHeroListSmallItem5")
  self.m_HeroHotListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_heroHot_InfinityGrid, "UIHeroHotItem")
end

function Form_Heroheat:OnActive()
  self.super.OnActive(self)
  self.m_curChooseID = 101
  self.m_bIsFirstFresh = false
  self.m_curChooseSubTabRoot = 1
  self.m_curChooseSubTab = 1
  self.m_lineUpRecommendAllInfo = {}
  self.m_TabItemCache = {}
  self.recommendLineUpList = {}
  self.topselectType = 0
  self.allDataList = {}
  self.heroHotList = {}
  self.nextRefreshTime = 0
  self:AddEventListeners()
  self:FreshData()
  self:CloseAllTopTabSelectImg()
  self:FreshUI()
end

function Form_Heroheat:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_openTime = TimeUtil:GetServerTimeS()
  ReportManager:ReportSystemOpen(GlobalConfig.SYSTEM_ID.CharacterHeat, self.m_openTime, self.m_curChooseID)
  if self.RefreshNextTimeTimer ~= nil then
    TimeService:KillTimer(self.RefreshNextTimeTimer)
    self.RefreshNextTimeTimer = nil
  end
end

function Form_Heroheat:OnDestroy()
  if self.m_lineUpRecommend_Tab_InfinityGrid then
    self.m_lineUpRecommend_Tab_InfinityGrid:dispose()
    self.m_lineUpRecommend_Tab_InfinityGrid = nil
  end
  if self.m_lineUpRecommend_InfinityGrid then
    self.m_lineUpRecommend_InfinityGrid:dispose()
    self.m_lineUpRecommend_InfinityGrid = nil
  end
  if self.m_HeroHotListInfinityGrid then
    self.m_HeroHotListInfinityGrid:dispose()
    self.m_HeroHotListInfinityGrid = nil
  end
  self.super.OnDestroy(self)
end

function Form_Heroheat:FreshData()
  self:GetHeroManagerData()
  self:RefreshHeroHeatList()
  self:DealTimer()
end

function Form_Heroheat:GetHeroManagerData()
  self.allDataList = HeroManager:GetRecommendData()
  self.heroHotList = self.allDataList.vHero
  self.recommendLineUpList = self.allDataList.mFlow
  self.nextRefreshTime = self.allDataList.iNextRefreshTime or 0
end

function Form_Heroheat:DealTimer()
  if self.RefreshNextTimeTimer ~= nil then
    TimeService:KillTimer(self.RefreshNextTimeTimer)
    self.RefreshNextTimeTimer = nil
  end
  self.RefreshNextTimeTimer = TimeService:SetTimer(1, -1, function()
    local time = self.nextRefreshTime - TimeUtil:GetServerTimeS()
    self.m_txt_lefttime_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(time)
    if time < 1 then
      if self.RefreshNextTimeTimer ~= nil then
        TimeService:KillTimer(self.RefreshNextTimeTimer)
        self.RefreshNextTimeTimer = nil
        utils.CheckAndPushCommonTips({
          tipsID = 1165,
          bLockBack = true,
          func1 = function()
            StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HEROHEAT)
          end
        })
        log.error("倒计时结束跨天刷新")
      end
      self.m_txt_lefttime_Text.text = 0
    end
  end)
end

function Form_Heroheat:FreshUI()
  self:FreshLeftTab(self.m_lineUpRecommendAllInfo, self.m_layout_left.transform, self.m_item_tab, self.m_TabItemCache)
end

function Form_Heroheat:FreshLeftTab(tabDataList, itemParentTran, item, itemCacheList, botherIndex)
  local childCount = itemParentTran.childCount
  for i = 0, childCount - 1 do
    local child = itemParentTran:GetChild(i)
    if child.gameObject.activeSelf then
      child.gameObject:SetActive(false)
    end
  end
  local elementCount = #tabDataList
  for i = childCount, elementCount - 1 do
    GameObject.Instantiate(item, itemParentTran)
  end
  for i, v in ipairs(tabDataList) do
    local child = itemParentTran:GetChild(i - 1).gameObject
    UILuaHelper.SetActive(child, true)
    self:OnInitTabItem(child, i - 1, itemCacheList, tabDataList, botherIndex)
  end
  if tabDataList[1].m_TabType == LeftTabType.TreeTab then
    local function PlayAnimation()
      local currentIndex = 0
      
      if not self.itemAnimTimer then
        TimeService.KillTimer(self.itemAnimTimer)
        self.itemAnimTimer = nil
      end
      self.itemAnimTimer = TimeService:SetTimer(0.1, elementCount, function()
        if currentIndex < elementCount then
          currentIndex = currentIndex + 1
        else
          TimeService.KillTimer(self.itemAnimTimer)
          self.itemAnimTimer = nil
          return
        end
        local child = itemParentTran:GetChild(currentIndex - 1).gameObject
        child:SetActive(true)
        UILuaHelper.PlayAnimationByName(child, "Heroheat_min_character")
      end)
    end
    
    for i = 1, elementCount do
      local child = itemParentTran:GetChild(i - 1).gameObject
      child:SetActive(false)
    end
    PlayAnimation()
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_left)
end

function Form_Heroheat:OnInitTabItem(go, index, cacheItem, data, botherIndex)
  local idx = index + 1
  local transform = go.transform
  local item = cacheItem[idx]
  local data = data[idx]
  if not item then
    if data.m_TabType == LeftTabType.NormalTab then
      item = {
        btn = transform:Find("m_tab_character"):GetComponent(T_Button),
        m_item_minParent = transform:Find("m_item_min_character").gameObject,
        m_item_minItem = transform:Find("m_item_min_character/m_pnl_itemincharacter").gameObject,
        m_tab_select = transform:Find("m_tab_character/m_tab_charactersel").gameObject,
        m_tab_unselect = transform:Find("m_tab_character/m_tab_characternor").gameObject,
        m_tab_selectText = transform:Find("m_tab_character/m_tab_charactersel/m_txt_tab_charactersel"):GetComponent(T_TextMeshProUGUI),
        m_tab_unselectText = transform:Find("m_tab_character/m_tab_characternor/m_txt_tabcharacternor"):GetComponent(T_TextMeshProUGUI),
        m_redPoint = transform:Find("m_tab_character/m_redpoint_chara").gameObject,
        m_subItemCache = {}
      }
    else
      item = {
        btn = transform:GetComponent(T_Button),
        m_tab_select = transform:Find("m_tab_mincharactersel").gameObject,
        m_tab_unselect = transform:Find("m_tab_mincharacternor").gameObject,
        m_tab_selectText = transform:Find("m_tab_mincharactersel/m_txt_tab4_name"):GetComponent(T_TextMeshProUGUI),
        m_tab_unselectText = transform:Find("m_tab_mincharacternor/m_txt_tab3_name"):GetComponent(T_TextMeshProUGUI),
        botherIndex = botherIndex,
        m_redPoint = transform:Find("m_redpoint_min").gameObject
      }
    end
    cacheItem[idx] = item
  end
  item.m_tab_selectText.text = data.m_mFuncName
  item.m_tab_unselectText.text = data.m_mFuncName
  UILuaHelper.SetActive(item.m_redPoint, false)
  if LocalDataManager:GetIntSimple("LineUpRecommend" .. data.m_ID, 0) == 0 then
    UILuaHelper.SetActive(item.m_redPoint, true)
  end
  local isSelected = false
  if data.m_TabType == LeftTabType.NormalTab then
    if self.m_curChooseSubTabRoot == idx then
      isSelected = true
      if self.m_txt_frame_big_title_Text then
        self.m_txt_frame_big_title_Text.text = data.m_mFuncName
      end
    end
    item.m_item_minParent:SetActive(false)
  end
  if data.m_TabType == LeftTabType.TreeTab and self.m_curChooseSubTab == idx then
    isSelected = true
  end
  item.m_tab_select:SetActive(isSelected)
  item.m_tab_unselect:SetActive(not isSelected)
  if isSelected then
    if data.m_TabType == LeftTabType.NormalTab then
      self.m_bIsFirstFresh = true
    end
    LocalDataManager:SetIntSimple("LineUpRecommend" .. data.m_ID, 1)
    UILuaHelper.SetActive(item.m_redPoint, false)
    self:FreshContentList()
  end
  if item.btn then
    UILuaHelper.BindButtonClickManual(self, item.btn, function()
      for _, cacheItem in ipairs(cacheItem) do
        cacheItem.m_tab_select:SetActive(false)
        cacheItem.m_tab_unselect:SetActive(true)
      end
      self.m_curChooseID = data.m_ID
      item.m_tab_select:SetActive(true)
      item.m_tab_unselect:SetActive(false)
      if data.m_TabType == LeftTabType.NormalTab then
        if self.m_curChooseSubTabRoot == idx then
          return
        end
        if self.m_txt_frame_big_title_Text then
          self.m_txt_frame_big_title_Text.text = data.m_mFuncName
        end
        for i, v in ipairs(self.m_TabItemCache) do
          v.m_item_minParent:SetActive(false)
        end
        if data.m_IsTreeStructure == 1 then
          item.m_item_minParent:SetActive(true)
          local dataList = {}
          local subTab = utils.changeCSArrayToLuaTable(data.m_SubTab)
          for _, subID in ipairs(subTab) do
            local cfg = LineUpRecommendIns:GetValue_ByID(subID)
            if cfg:GetError() then
              log.error("Form_Heroheat GetValue_ByID is error " .. tostring(subID))
              return
            end
            table.insert(dataList, cfg)
          end
          self.m_curChooseSubTab = 1
          self:FreshLeftTab(dataList, item.m_item_minParent.transform, item.m_item_minItem, item.m_subItemCache, idx)
          self.m_curChooseID = dataList[1].m_ID
        end
        self.m_curChooseSubTabRoot = idx
        self.m_curChooseSubTab = 1
        UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_left)
      else
        if self.m_curChooseSubTab == idx then
          return
        end
        for i, v in ipairs(self.m_TabItemCache) do
          v.m_tab_select:SetActive(false)
          v.m_tab_unselect:SetActive(true)
        end
        self.m_TabItemCache[item.botherIndex].m_tab_select:SetActive(true)
        self.m_TabItemCache[item.botherIndex].m_tab_unselect:SetActive(false)
        self.m_curChooseSubTabRoot = item.botherIndex
        self.m_curChooseSubTab = idx
      end
      self:FreshContentList()
      LocalDataManager:SetIntSimple("LineUpRecommend" .. data.m_ID, 1)
      UILuaHelper.SetActive(item.m_redPoint, false)
      self:broadcastEvent("eGameEvent_Hero_heatRedCheck")
    end)
  end
end

function Form_Heroheat:RefreshHeroHeatList()
  self.m_lineUpRecommendAllInfo = {}
  local HeroheatInfoAll = LineUpRecommendIns:GetAll()
  for i, v in pairs(HeroheatInfoAll) do
    local open_flag = UnlockSystemUtil:IsSystemOpen(v.m_FuncID)
    if open_flag and v.m_TabType == LeftTabType.NormalTab then
      self.m_lineUpRecommendAllInfo[#self.m_lineUpRecommendAllInfo + 1] = v
    end
  end
end

function Form_Heroheat:FreshContentList()
  self.m_openTime = TimeUtil:GetServerTimeS()
  if not self.m_bIsFirstFresh then
    ReportManager:ReportSystemOpen(GlobalConfig.SYSTEM_ID.CharacterHeat, self.m_openTime, self.m_curChooseID)
  end
  ReportManager:ReportSystemOpen(GlobalConfig.SYSTEM_ID.CharacterHeat, self.m_openTime, self.m_curChooseID)
  self.curChooseTabCfg = LineUpRecommendIns:GetValue_ByID(self.m_curChooseID)
  if self.curChooseTabCfg:GetError() then
    log.error("Form_Heroheat GetValue_ByID is error ")
    return
  end
  self.m_pnl_tabgroup:SetActive(false)
  self.m_pnl_lineUpcommend:SetActive(false)
  self.m_pnl_lineUpcommend_Tab:SetActive(false)
  self.m_pnl_heroHotList:SetActive(false)
  self:CloseAllTopTabSelectImg()
  UILuaHelper.SetActive(self.m_pnl_tabtop0, false)
  if self.curChooseTabCfg.m_UIType == 1 then
    self:FreshHeroHotList()
  elseif self.curChooseTabCfg.m_UIType == 2 then
    self:FreshLineUp()
  else
    if self.curChooseTabCfg.m_UIType == 3 then
      self:FreshLineUpWithSub()
    else
    end
  end
end

function Form_Heroheat:FreshHeroHotList()
  self.topselectType = 0
  UILuaHelper.SetActive(self.m_img_tab_sel0, self.topselectType == 0)
  self.m_txt_topline_Text.text = allTxt
  self.m_pnl_tabgroup:SetActive(true)
  self.m_pnl_heroHotList:SetActive(true)
  local subTab = utils.changeCSArrayToLuaTable(self.curChooseTabCfg.m_ThreeLevelTabs)
  self:InitializeTabSelection(subTab, self.curChooseTabCfg.m_ThreeLevelTabIcon, self.heroHotList, self.RefreshHeroListData, self.m_txt_topline_Text)
  self:RefreshHeroListData(self.heroHotList)
end

function Form_Heroheat:RefreshHeroListData(vHero)
  local tempData = {}
  if self.topselectType ~= 0 then
    for i = 1, #vHero do
      local data = CharacterInfoIns:GetValue_ByHeroID(vHero[i].iHeroId)
      if data:GetError() then
        log.error("Form_Heroheat GetValue_ByHeroID is error ")
        return
      end
      local campId = data.m_Camp
      if self.topselectType == campId then
        table.insert(tempData, vHero[i])
      end
    end
  else
    tempData = vHero
  end
  self.m_HeroHotListInfinityGrid:SetCellPerLine(2)
  self.m_HeroHotListInfinityGrid:ShowItemList(tempData)
  self.m_HeroHotListInfinityGrid:LocateTo(0)
end

function Form_Heroheat:FreshLineUp()
  self.m_pnl_tabgroup:SetActive(false)
  self.m_pnl_lineUpcommend:SetActive(true)
  self:RefreshListBasedOnSelection(self.recommendLineUpList, self.m_lineUpRecommend_InfinityGrid)
end

function Form_Heroheat:FreshLineUpWithSub()
  self.topselectType = 1
  local tabName = self.curChooseTabCfg.m_ThreeLevelTabIcon
  if tabName == "DungeonChapter" then
    tabName = "DunChapter"
  end
  local cfg = ConfigManager:GetConfigInsByName(tabName)
  if not cfg then
    log.error("Form_HeroHeat TopTabCfg is Error" .. tabName)
    return
  end
  local Allcfg = cfg:GetAll()
  self.m_txt_lineupcommend_Text.text = Allcfg[self.topselectType].m_mHeroHeartText
  UILuaHelper.SetActive(self.m_img_tab_sel1, self.topselectType == 1)
  self.m_pnl_tabgroup:SetActive(true)
  self.m_pnl_lineUpcommend_Tab:SetActive(true)
  local subTab = utils.changeCSArrayToLuaTable(self.curChooseTabCfg.m_ThreeLevelTabs)
  self:InitializeTabSelection(subTab, self.curChooseTabCfg.m_ThreeLevelTabIcon, self.recommendLineUpList, self.RefreshLineUpRecommend, self.m_txt_lineupcommend_Text)
  self:RefreshLineUpRecommend(self.recommendLineUpList)
end

function Form_Heroheat:InitializeTabSelection(subTab, tableName, dataSource, refreshFunction, topText)
  if tableName == "DungeonChapter" then
    tableName = "DunChapter"
  end
  local cfg = ConfigManager:GetConfigInsByName(tableName)
  if not cfg then
    log.error("Form_HeroHeat TopTabCfg is Error" .. tableName)
    return
  end
  self:CloseAllTopTabImg()
  local Allcfg = cfg:GetAll()
  for i = 1, #subTab do
    UILuaHelper.SetActive(self["m_pnl_tabtop" .. subTab[i]], true)
    local nolImg = self["m_icon_tab" .. subTab[i]].transform:GetComponent(T_Image)
    if subTab[i] ~= 0 then
      UILuaHelper.SetAtlasSprite(nolImg, Allcfg[subTab[i]].m_HeroHeartIcon)
    end
    local btn = self["m_pnl_tabtop" .. subTab[i]].transform:GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(btn, function()
      self.topselectType = subTab[i]
      refreshFunction(self, dataSource)
      self:CloseAllTopTabSelectImg()
      UILuaHelper.SetActive(self["m_img_tab_sel" .. subTab[i]], true)
      if topText then
        if subTab[i] ~= 0 then
          topText.text = Allcfg[subTab[i]].m_mHeroHeartText
        else
          topText.text = allTxt
        end
      end
      UILuaHelper.SetColorByMultiIndex(self["m_icon_tab" .. subTab[i]], 1)
    end)
  end
end

function Form_Heroheat:RefreshLineUpRecommend(vRecommend)
  self:RefreshListBasedOnSelection(vRecommend, self.m_lineUpRecommend_Tab_InfinityGrid)
end

function Form_Heroheat:RefreshListBasedOnSelection(dataList, grid)
  if not dataList then
    log.error("recommendData server data is nil")
    return
  end
  local tempData = {}
  local data = dataList[self.m_curChooseID]
  if not data or not data.mvForm then
    grid:ShowItemList(tempData)
    return
  end
  if #data.mvForm > 1 then
    tempData = data.mvForm[self.topselectType]
  else
    tempData = data.mvForm[1]
  end
  if tempData then
    grid:SetCellPerLine(1)
    grid:ShowItemList(tempData)
    grid:LocateTo(0)
  end
end

function Form_Heroheat:AddEventListeners()
end

function Form_Heroheat:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Heroheat:OnBtntipsClicked()
  if self.curChooseTabCfg:GetError() then
    log.error("Form_Heroheat GetValue_ByDisplayID is error ")
    return
  end
  utils.popUpDirectionsUI({
    tipsID = self.curChooseTabCfg.m_HelpID
  })
end

function Form_Heroheat:CloseAllTopTabSelectImg()
  for i = 0, 7 do
    UILuaHelper.SetActive(self["m_img_tab_sel" .. i], false)
    UILuaHelper.SetColorByMultiIndex(self["m_icon_tab" .. i], 0)
  end
end

function Form_Heroheat:CloseAllTopTabImg()
  for i = 0, 7 do
    UILuaHelper.SetActive(self["m_pnl_tabtop" .. i], false)
  end
end

function Form_Heroheat:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Heroheat", Form_Heroheat)
return Form_Heroheat
