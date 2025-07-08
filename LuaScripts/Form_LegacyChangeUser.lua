local Form_LegacyChangeUser = class("Form_LegacyChangeUser", require("UI/UIFrames/Form_LegacyChangeUserUI"))
local PreItemStr = "c_common_hero_middle"
local HeroSortCfg = _ENV.HeroSortCfg
local DefaultChooseFilterIndex = 1
local LegacyLevelIns = ConfigManager:GetConfigInsByName("LegacyLevel")

function Form_LegacyChangeUser:SetInitParam(param)
end

function Form_LegacyChangeUser:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_curLegacyData = nil
  self.m_heroWidgetList = {}
  self:InitHeroWidgetList()
  self.m_legacyHeroPosDataList = nil
  self.m_legacyHeroPosChooseList = nil
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClick)
  }
  self.m_luaHeroListInfinityGrid = self:CreateInfinityGrid(self.m_dispatch_hero_list_InfinityGrid, "LegacyActivity/UILegacyChangeUserHeroItem", initGridData)
  local goFilterBtnRoot = self.m_rootTrans:Find("content_node/pnl_filter/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  self.m_heroSort = HeroManager:GetHeroSort()
  self.m_allHeroList = nil
  self.m_allShowHeroList = nil
  self.m_curFilterIndex = nil
  self.m_bFilterDown = nil
  self.m_filterData = {}
  self.m_isHaveChange = nil
end

function Form_LegacyChangeUser:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(168)
end

function Form_LegacyChangeUser:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_LegacyChangeUser:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LegacyChangeUser:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curLegacyData = tParam.legacyData
    self.m_csui.m_param = nil
  end
  self:FreshHeroListDataAndChooseStatus()
  self:FreshLegacyHeroPosDataList()
end

function Form_LegacyChangeUser:ClearCacheData()
end

function Form_LegacyChangeUser:GetHeroDataByID(heroID)
  if not heroID then
    return
  end
  if not self.m_allHeroList then
    return
  end
  for _, v in ipairs(self.m_allHeroList) do
    if v.serverData.iHeroId == heroID then
      return v
    end
  end
  return nil
end

function Form_LegacyChangeUser:FreshLegacyHeroPosDataList()
  if not self.m_curLegacyData then
    return
  end
  self.m_legacyHeroPosDataList = {}
  local heroIDList = self.m_curLegacyData.serverData.vEquipBy or {}
  local legacyLvCfgDic = LegacyLevelIns:GetValue_ByID(self.m_curLegacyData.serverData.iLegacyId)
  local legacyLv = self.m_curLegacyData.serverData.iLevel
  if legacyLvCfgDic then
    for _, tempLegacyLvCfg in pairs(legacyLvCfgDic) do
      local wearableNum = tempLegacyLvCfg.m_Wearable
      local heroData = self:GetHeroDataByID(heroIDList[wearableNum])
      if heroData then
        heroData.isChoose = true
      end
      local tempHeroPosData
      if self.m_legacyHeroPosDataList[wearableNum] == nil then
        tempHeroPosData = {
          legacyLvCfg = tempLegacyLvCfg,
          legacyLv = tempLegacyLvCfg.m_Level,
          heroData = heroData,
          isOpen = legacyLv >= tempLegacyLvCfg.m_Level
        }
        self.m_legacyHeroPosDataList[wearableNum] = tempHeroPosData
      else
        tempHeroPosData = self.m_legacyHeroPosDataList[wearableNum]
        if tempLegacyLvCfg.m_Level < tempHeroPosData.legacyLv then
          tempHeroPosData.legacyLvCfg = tempLegacyLvCfg
          tempHeroPosData.legacyLv = tempLegacyLvCfg.m_Level
          tempHeroPosData.isOpen = legacyLv >= tempLegacyLvCfg.m_Level
        end
      end
    end
  end
  self:SetLegacyPosChooseDataToInit()
end

function Form_LegacyChangeUser:SetLegacyPosChooseDataToInit()
  if not self.m_legacyHeroPosDataList then
    return
  end
  self.m_legacyHeroPosChooseList = {}
  for key, tempHeroPosData in pairs(self.m_legacyHeroPosDataList) do
    if tempHeroPosData.heroData then
      tempHeroPosData.heroData.isChoose = true
    end
    local tempChooseData = {
      legacyLvCfg = tempHeroPosData.legacyLvCfg,
      legacyLv = tempHeroPosData.legacyLv,
      heroData = tempHeroPosData.heroData,
      isOpen = tempHeroPosData.isOpen
    }
    self.m_legacyHeroPosChooseList[key] = tempChooseData
  end
end

function Form_LegacyChangeUser:ResetChoosePosDataStatusList()
  for _, tempHeroPosData in pairs(self.m_legacyHeroPosChooseList) do
    if tempHeroPosData.heroData then
      tempHeroPosData.heroData.isChoose = false
    end
  end
end

function Form_LegacyChangeUser:FreshHeroListDataAndChooseStatus()
  self.m_allHeroList = HeroManager:GetHeroList() or {}
  local tempAllHeroDataList = {}
  for _, tempHeroData in ipairs(self.m_allHeroList) do
    local userHeroData = {
      serverData = tempHeroData.serverData,
      characterCfg = tempHeroData.characterCfg,
      isChoose = false
    }
    tempAllHeroDataList[#tempAllHeroDataList + 1] = userHeroData
  end
  self.m_allHeroList = tempAllHeroDataList
end

function Form_LegacyChangeUser:GetShowHeroIndexByID(heroID)
  if not heroID then
    return
  end
  for i, tempHeroData in ipairs(self.m_allShowHeroList) do
    if tempHeroData.serverData.iHeroId == heroID then
      return i
    end
  end
end

function Form_LegacyChangeUser:GetAllHeroIndexByID(heroID)
  if not heroID then
    return
  end
  for i, tempHeroData in ipairs(self.m_allHeroList) do
    if tempHeroData.serverData.iHeroId == heroID then
      return i
    end
  end
end

function Form_LegacyChangeUser:GetEmptyHeroPosIndex()
  if not self.m_legacyHeroPosChooseList then
    return
  end
  for i = 1, LegacyManager.MaxLegacyHeroPos do
    local heroPosData = self.m_legacyHeroPosChooseList[i]
    if heroPosData.isOpen and heroPosData.heroData == nil then
      return i
    end
  end
end

function Form_LegacyChangeUser:GetNextLockHeroPosAndUnlockStr()
  if not self.m_legacyHeroPosChooseList then
    return
  end
  if self.m_legacyHeroPosChooseList[LegacyManager.MaxLegacyHeroPos] and self.m_legacyHeroPosChooseList[LegacyManager.MaxLegacyHeroPos].heroData ~= nil then
    return LegacyManager.MaxLegacyHeroPos, 46001
  end
  for i = 1, LegacyManager.MaxLegacyHeroPos do
    local heroPosData = self.m_legacyHeroPosChooseList[i]
    if heroPosData.isOpen ~= true and heroPosData.heroData == nil then
      local commonTextStr = ConfigManager:GetCommonTextById(100506)
      local showStr = string.CS_Format(commonTextStr, heroPosData.legacyLv)
      return i, showStr
    end
  end
end

function Form_LegacyChangeUser:IsChoosePosHaveChange()
  for _, serverHeroPosData in pairs(self.m_legacyHeroPosDataList) do
    if serverHeroPosData.heroData then
      local isReduce = true
      for n, chooseHeroPosData in pairs(self.m_legacyHeroPosChooseList) do
        if chooseHeroPosData.heroData and chooseHeroPosData.heroData.serverData.iHeroId == serverHeroPosData.heroData.serverData.iHeroId then
          isReduce = false
        end
      end
      if isReduce then
        return true
      end
    end
  end
  for _, chooseHeroPosData in pairs(self.m_legacyHeroPosChooseList) do
    if chooseHeroPosData.heroData then
      local isAdd = true
      for m, serverHeroPosData in pairs(self.m_legacyHeroPosDataList) do
        if serverHeroPosData.heroData and serverHeroPosData.heroData.serverData.iHeroId == chooseHeroPosData.heroData.serverData.iHeroId then
          isAdd = false
        end
      end
      if isAdd then
        return true
      end
    end
  end
  return false
end

function Form_LegacyChangeUser:GetChooseHeroIDList()
  local chooseHeroIDList = {}
  for i, chooseHeroPosData in pairs(self.m_legacyHeroPosChooseList) do
    local heroData = chooseHeroPosData.heroData
    if heroData then
      chooseHeroIDList[#chooseHeroIDList + 1] = heroData.serverData.iHeroId
    end
  end
  return chooseHeroIDList
end

function Form_LegacyChangeUser:AddEventListeners()
  self:addEventListener("eGameEvent_Legacy_InstallBatch", handler(self, self.OnInstallBatchBack))
end

function Form_LegacyChangeUser:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LegacyChangeUser:OnInstallBatchBack(param)
  if not param then
    return
  end
  local legacyID = param.legacyID
  if legacyID == self.m_curLegacyData.serverData.iLegacyId then
    self:CloseForm()
  end
end

function Form_LegacyChangeUser:InitHeroWidgetList()
  for i = 1, LegacyManager.MaxLegacyHeroPos do
    local tempHeroRoot = self.m_hero_list.transform:Find(PreItemStr .. i)
    local heroWid
    if tempHeroRoot then
      heroWid = self:createHeroIcon(tempHeroRoot)
      heroWid:SetHeroIconClickCB(function()
        self:OnHeroPosIconClk(i)
      end)
      self.m_heroWidgetList[#self.m_heroWidgetList + 1] = heroWid
    end
  end
end

function Form_LegacyChangeUser:FreshUI()
  self:FreshLegacyBaseInfo()
  self.m_bFilterDown = false
  self.m_curFilterIndex = DefaultChooseFilterIndex
  self.m_filterData = {}
  self.m_widgetBtnFilter:RefreshTabConfig(HeroSortCfg, self.m_curFilterIndex, self.m_bFilterDown, function(filterIndex, isFilterDown)
    self:OnHeroSortChanged(filterIndex, isFilterDown)
  end)
  self:OnFilterChanged()
  self:FreshChooseStatus()
end

function Form_LegacyChangeUser:FreshLegacyBaseInfo()
  if not self.m_curLegacyData then
    return
  end
  self.m_txt_legacy_name_Text.text = self.m_curLegacyData.legacyCfg.m_mName
end

function Form_LegacyChangeUser:FreshHeroList()
  self.m_luaHeroListInfinityGrid:ShowItemList(self.m_allShowHeroList)
end

function Form_LegacyChangeUser:OnFilterChanged()
  self.m_allShowHeroList = self.m_heroSort:FilterHeroList(self.m_allHeroList, self.m_filterData)
  self:OnHeroSortChanged(self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_LegacyChangeUser:OnHeroSortChanged(iIndex, bDown)
  self.m_curFilterIndex = iIndex
  self.m_bFilterDown = bDown
  self:FreshSortHero()
  self:FreshHeroList()
end

function Form_LegacyChangeUser:FreshSortHero()
  local heroSort = HeroManager:GetHeroSort()
  heroSort:SortHeroList(self.m_allShowHeroList, self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_LegacyChangeUser:FreshChooseStatus()
  for i = 1, LegacyManager.MaxLegacyHeroPos do
    local tempHeroPosData = self.m_legacyHeroPosChooseList[i]
    if tempHeroPosData then
      UILuaHelper.SetActive(self["m_img_hero_bg" .. i], true)
      local isOpen = tempHeroPosData.isOpen
      local isHaveHeroData = tempHeroPosData.heroData ~= nil
      local node_add = self["m_Img_add" .. i]
      local node_lock = self["m_Img_lock" .. i]
      UILuaHelper.SetActive(node_add, isOpen and not isHaveHeroData)
      UILuaHelper.SetActive(node_lock, not isOpen and not isHaveHeroData)
      self.m_heroWidgetList[i]:SetActive(isOpen and isHaveHeroData)
      if not isOpen then
        self["m_txt_camplevel" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(20033), tempHeroPosData.legacyLv)
      end
      if isHaveHeroData then
        self.m_heroWidgetList[i]:SetHeroData(tempHeroPosData.heroData.serverData)
      end
    else
      UILuaHelper.SetActive(self["m_img_hero_bg" .. i], false)
      self.m_heroWidgetList[i]:SetActive(false)
    end
  end
  self:FreshResetStatus()
end

function Form_LegacyChangeUser:UnChooseHeroListItem(heroData)
  if not heroData then
    return
  end
  local showItemIndex = self:GetShowHeroIndexByID(heroData.serverData.iHeroId)
  if showItemIndex then
    local showItem = self.m_luaHeroListInfinityGrid:GetShowItemByIndex(showItemIndex)
    if showItem then
      showItem:ChangeChooseItem(false)
    else
      self.m_allShowHeroList[showItemIndex].isChoose = false
    end
  else
    local heroIndex = self:GetAllHeroIndexByID(heroData.serverData.iHeroId)
    if heroIndex then
      local tempHeroData = self.m_allHeroList[heroIndex]
      if tempHeroData then
        tempHeroData.isChoose = false
      end
    end
  end
end

function Form_LegacyChangeUser:UnChoosePoseHeroData(posIndex)
  if not posIndex then
    return
  end
  for i = posIndex, LegacyManager.MaxLegacyHeroPos do
    local heroPosData = self.m_legacyHeroPosChooseList[i]
    if i < LegacyManager.MaxLegacyHeroPos then
      local nextPosData = self.m_legacyHeroPosChooseList[i + 1]
      heroPosData.heroData = nextPosData.heroData
    else
      heroPosData.heroData = nil
    end
  end
end

function Form_LegacyChangeUser:GetHeroPoseIndexByHeroData(heroData)
  for i = 1, LegacyManager.MaxLegacyHeroPos do
    local tempHeroPosData = self.m_legacyHeroPosChooseList[i]
    if tempHeroPosData and tempHeroPosData.heroData and tempHeroPosData.heroData.serverData.iHeroId == heroData.serverData.iHeroId then
      return i
    end
  end
end

function Form_LegacyChangeUser:FreshResetStatus()
  local isHaveChange = self:IsChoosePosHaveChange()
  self.m_isHaveChange = isHaveChange
  UILuaHelper.SetActive(self.m_btn_reset, isHaveChange)
  UILuaHelper.SetActive(self.m_btn_reset_gray, not isHaveChange)
end

function Form_LegacyChangeUser:OnHeroPosIconClk(i)
  if not i then
    return
  end
  local heroPosData = self.m_legacyHeroPosChooseList[i]
  if not heroPosData then
    return
  end
  local tempHeroData = heroPosData.heroData
  self:UnChoosePoseHeroData(i)
  self:FreshChooseStatus()
  self:UnChooseHeroListItem(tempHeroData)
end

function Form_LegacyChangeUser:OnHeroItemClick(i)
  if not i then
    return
  end
  local itemIndex = i + 1
  local heroData = self.m_allShowHeroList[itemIndex]
  if heroData.isChoose then
    local heroPosIndex = self:GetHeroPoseIndexByHeroData(heroData)
    if heroPosIndex then
      self:UnChoosePoseHeroData(heroPosIndex)
      self:FreshChooseStatus()
    end
    local showItem = self.m_luaHeroListInfinityGrid:GetShowItemByIndex(itemIndex)
    if showItem then
      showItem:ChangeChooseItem(false)
    else
      self.m_allShowHeroList[itemIndex].isChoose = false
    end
    CS.GlobalManager.Instance:TriggerWwiseBGMState(189)
  else
    local emptyHeroPosIndex = self:GetEmptyHeroPosIndex()
    if emptyHeroPosIndex then
      local showItem = self.m_luaHeroListInfinityGrid:GetShowItemByIndex(itemIndex)
      if showItem then
        showItem:ChangeChooseItem(true)
      else
        self.m_allShowHeroList[itemIndex].isChoose = true
      end
      self.m_legacyHeroPosChooseList[emptyHeroPosIndex].heroData = heroData
      self:FreshChooseStatus()
    else
      local _, unlockStr = self:GetNextLockHeroPosAndUnlockStr()
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, unlockStr)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(3)
    end
  end
end

function Form_LegacyChangeUser:OnBtnFilterClicked()
  local function chooseBackFun(filterData)
    self.m_filterData = filterData
    
    self:OnFilterChanged()
    UILuaHelper.SetActive(self.m_filter_select, false)
    if self.m_filterData then
      for _, value in pairs(self.m_filterData) do
        if value ~= 0 then
          UILuaHelper.SetActive(self.m_filter_select, true)
          break
        end
      end
    end
  end
  
  utils.openForm_filter(self.m_filterData, self.m_btn_Filter.transform, {x = 0, y = 0}, {x = -35, y = 40}, chooseBackFun, false)
end

function Form_LegacyChangeUser:OnHeroPosLockClk(i)
  if not i then
    return
  end
  local heroPosData = self.m_legacyHeroPosChooseList[i]
  if not heroPosData then
    return
  end
  local commonTextStr = ConfigManager:GetCommonTextById(100506)
  local showStr = string.CS_Format(commonTextStr, heroPosData.legacyLv)
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, showStr)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(3)
end

function Form_LegacyChangeUser:OnBtnLock1Clicked()
  self:OnHeroPosLockClk(1)
end

function Form_LegacyChangeUser:OnBtnLock2Clicked()
  self:OnHeroPosLockClk(2)
end

function Form_LegacyChangeUser:OnBtnLock3Clicked()
  self:OnHeroPosLockClk(3)
end

function Form_LegacyChangeUser:OnBtnLock4Clicked()
  self:OnHeroPosLockClk(4)
end

function Form_LegacyChangeUser:OnBtnLock5Clicked()
  self:OnHeroPosLockClk(5)
end

function Form_LegacyChangeUser:OnBtnLock6Clicked()
  self:OnHeroPosLockClk(6)
end

function Form_LegacyChangeUser:OnBtnresetClicked()
  self:ResetChoosePosDataStatusList()
  self:SetLegacyPosChooseDataToInit()
  self:FreshChooseStatus()
  self:FreshHeroList()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(187)
end

function Form_LegacyChangeUser:OnBtnresetgrayClicked()
end

function Form_LegacyChangeUser:OnBtnquitClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(61)
  self:CloseForm()
end

function Form_LegacyChangeUser:OnBtnsendsureClicked()
  if self.m_isHaveChange then
    StackFlow:Push(UIDefines.ID_FORM_LEGACYACTIVITYCHANGEPOP, {
      legacyData = self.m_curLegacyData,
      chooseHeroIDList = self:GetChooseHeroIDList()
    })
  else
    self:CloseForm()
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(36)
end

function Form_LegacyChangeUser:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LegacyChangeUser", Form_LegacyChangeUser)
return Form_LegacyChangeUser
