local Form_HeroList = class("Form_HeroList", require("UI/UIFrames/Form_HeroListUI"))
local HeroSortCfg = _ENV.HeroSortCfg
local HeroGuideSortCfg = _ENV.HeroGuideSortCfg
local DefaultChooseFilterIndex = 1
local ipairs = _ENV.ipairs
local GlobalSettingsIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local DurationTime = GlobalSettingsIns:GetValue_ByName("ItemDurationTime").m_Value or 0.03
local CardInAnimStr = "card_in"
local SizeRate = {width = 16, height = 9}
local FiveWidth = 1300
local SixWidth = 1600
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local CharacterLimitBreakIns = ConfigManager:GetConfigInsByName("CharacterLimitBreak")
local LineUpRecommendIns = ConfigManager:GetConfigInsByName("LineUpRecommend")
local filterMoonTypeTime = 0.7

function Form_HeroList:SetInitParam(param)
end

function Form_HeroList:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1101)
  self.m_greyMat = self.m_img_grey_cache_Image.material
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClick)
  }
  self.m_luaHeroListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_hero_list_InfinityGrid, "UIHeroListItem", initGridData)
  local initGuideGridData = {
    greyMat = self.m_greyMat,
    itemClkBackFun = handler(self, self.OnHeroGuideItemClick)
  }
  self.m_luaHeroGuideInfinityGrid = self:CreateInfinityGrid(self.m_hero_guide_list_InfinityGrid, "UIHeroListGuideItem", initGuideGridData)
  local goFilterBtnRoot = self.m_rootTrans:Find("content_node/ui_common_filter").gameObject
  self.m_widgetBtnFilter = self:createFilterButton(goFilterBtnRoot)
  self.m_heroSort = HeroManager:GetHeroSort()
  self.m_heroGuideHelper = HeroManager:GetHeroGuideHelper()
  self.m_allHeroList = nil
  self.m_allShowHeroList = nil
  self.m_curFilterIndex = nil
  self.m_bFilterDown = nil
  self.m_itemInitShowNum = 0
  self.m_LineItemCount = nil
  self.m_isInit = true
  self.m_filterData = {}
  self:AdaptListItemNum()
  self.m_allGuideHeroList = nil
  self.m_allShowGuideHeroList = nil
  self.m_isShowHeroList = true
end

function Form_HeroList:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  local is_from_hall = self.m_csui.m_param and self.m_csui.m_param.is_from_hall
  if is_from_hall then
    self.m_curFilterIndex = nil
    self.m_bFilterDown = nil
    self.m_filterData = {}
  end
  self:FreshUI()
  self:CheckShowEnterAnim()
  UILuaHelper.SetActive(self.m_filter_select, false)
  self.m_filterMoon = 0
  self.m_filterData[HeroManager.FilterType.MoonType] = self.m_filterMoon
  if not self.m_LockScrollPos or is_from_hall then
    self.m_luaHeroListInfinityGrid:LocateTo()
    if self.m_csui.m_param then
      self.m_csui.m_param.is_from_hall = nil
    end
  end
  self.m_LockScrollPos = false
  GlobalManagerIns:TriggerWwiseBGMState(24, false)
  GlobalManagerIns:TriggerWwiseBGMState(19)
  self.isCanClickMoonType = true
end

function Form_HeroList:OnOpen()
end

function Form_HeroList:OnUncoverd()
  self:OnEventCheckHeroHeatRed()
end

function Form_HeroList:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_luaHeroListInfinityGrid:UnRegisterAllRedDotItem()
end

function Form_HeroList:OnDestroy()
  if self.m_luaHeroListInfinityGrid then
    self.m_luaHeroListInfinityGrid:dispose()
    self.m_luaHeroListInfinityGrid = nil
  end
  self.super.OnDestroy(self)
  for i = 1, self.m_itemInitShowNum do
    if self["ItemInitTimer" .. i] then
      TimeService:KillTimer(self["ItemInitTimer" .. i])
      self["ItemInitTimer" .. i] = nil
    end
  end
end

function Form_HeroList:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_heatRedCheck", handler(self, self.OnEventCheckHeroHeatRed))
end

function Form_HeroList:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HeroList:ClearData()
end

function Form_HeroList:FreshData()
  self.m_allHeroList = HeroManager:GetHeroList() or {}
  self.m_allGuideHeroList = self.m_heroGuideHelper:GetHeroGuideList()
end

function Form_HeroList:GuideSortHero(heroID)
  for i, v in ipairs(self.m_allShowHeroList) do
    if v.serverData.iHeroId == heroID then
      self.m_allShowHeroList[i] = self.m_allShowHeroList[1]
      self.m_allShowHeroList[1] = v
      break
    end
  end
  self.m_luaHeroListInfinityGrid:ShowItemList(self.m_allShowHeroList)
end

function Form_HeroList:FreshSortHero()
  local heroSort = HeroManager:GetHeroSort()
  local vFavouritHero = {}
  local vNormalHero = {}
  for k, v in ipairs(self.m_allShowHeroList) do
    if v.serverData.bLove then
      vFavouritHero[#vFavouritHero + 1] = v
    else
      vNormalHero[#vNormalHero + 1] = v
    end
  end
  if 0 < #vFavouritHero then
    heroSort:SortHeroList(vFavouritHero, self.m_curFilterIndex, self.m_bFilterDown)
  end
  if 0 < #vNormalHero then
    heroSort:SortHeroList(vNormalHero, self.m_curFilterIndex, self.m_bFilterDown)
  end
  self.m_allShowHeroList = {}
  table.insertto(self.m_allShowHeroList, vFavouritHero)
  table.insertto(self.m_allShowHeroList, vNormalHero)
end

function Form_HeroList:FreshSortHeroGuide()
  local heroSort = HeroManager:GetHeroSort()
  heroSort:SortHeroGuideList(self.m_allShowGuideHeroList, self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_HeroList:OnEventCheckHeroHeatRed()
  self.m_lineUpRecommendAllInfo = {}
  local HeroheatInfoAll = LineUpRecommendIns:GetAll()
  if TimeUtil:GetServerTimeS() > HeroManager:GetRecommendNextRefreshTime() then
    for i, v in pairs(HeroheatInfoAll) do
      local open_flag = UnlockSystemUtil:IsSystemOpen(v.m_FuncID)
      if open_flag then
        LocalDataManager:SetIntSimple("LineUpRecommend" .. v.m_ID, 0)
      end
    end
    UILuaHelper.SetActive(self.m_hot_reddot, true)
    return
  end
  UILuaHelper.SetActive(self.m_hot_reddot, false)
  for i, v in pairs(HeroheatInfoAll) do
    local open_flag = UnlockSystemUtil:IsSystemOpen(v.m_FuncID)
    if open_flag and v.m_TabType == 1 and LocalDataManager:GetIntSimple("LineUpRecommend" .. v.m_ID, 0) == 0 then
      UILuaHelper.SetActive(self.m_hot_reddot, true)
      break
    end
  end
end

function Form_HeroList:AdaptListItemNum()
  local size = utils.getScreenSafeAreaRealSize()
  local sizeRate = size.width / size.height
  local baseRate = SizeRate.width / SizeRate.height
  local listW = FiveWidth
  local sizeCount = 5
  if sizeRate > baseRate then
    listW = SixWidth
    sizeCount = 6
  else
    listW = FiveWidth
    sizeCount = 5
  end
  self.m_LineItemCount = sizeCount
  UILuaHelper.SetSizeWithCurrentAnchors(self.m_hero_list, listW)
  UILuaHelper.SetSizeWithCurrentAnchors(self.m_hero_guide_list, listW)
  self.m_luaHeroListInfinityGrid:SetCellPerLine(sizeCount)
  self.m_luaHeroGuideInfinityGrid:SetCellPerLine(sizeCount)
end

function Form_HeroList:FreshUI()
  self.m_isShowHeroList = true
  self:FreshHeroGuideTabShow()
  if self.m_curFilterIndex == nil then
    self.m_bFilterDown = false
    self.m_curFilterIndex = self.m_curFilterIndex or DefaultChooseFilterIndex
  end
  self.m_widgetBtnFilter:RefreshTabConfig(HeroSortCfg, self.m_curFilterIndex, self.m_bFilterDown, function(filterIndex, isFilterDown)
    self:OnHeroSortChanged(filterIndex, isFilterDown)
    self:CheckShowEnterAnim()
  end)
  self:OnFilterChanged()
  self:FreshProgressNum()
  self:RefreshHeroHeat()
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Form)
  self.m_btn_R3:SetActive(openFlag)
end

function Form_HeroList:FreshHeroGuideTabShow()
  UILuaHelper.SetActive(self.m_hero_list, self.m_isShowHeroList)
  UILuaHelper.SetActive(self.m_hero_guide_list, not self.m_isShowHeroList)
  UILuaHelper.SetActive(self.m_bg_sel_blood, self.m_isShowHeroList)
  UILuaHelper.SetActive(self.m_bg_sel_blood2, not self.m_isShowHeroList)
  UILuaHelper.SetActive(self.m_icon_dependents_nml, not self.m_isShowHeroList)
  UILuaHelper.SetActive(self.m_icon_dependents_sel, self.m_isShowHeroList)
  UILuaHelper.SetActive(self.m_icon_book_nml, self.m_isShowHeroList)
  UILuaHelper.SetActive(self.m_icon_book_sel, not self.m_isShowHeroList)
  UILuaHelper.SetColorByMultiIndex(self.m_z_txt_dependents, self.m_isShowHeroList and 1 or 0)
  UILuaHelper.SetColorByMultiIndex(self.m_z_txt_book, not self.m_isShowHeroList and 1 or 0)
  local moonType = self.m_filterData[HeroManager.FilterType.MoonType] or 0
  UILuaHelper.SetActive(self.m_pnl_moomselect00, moonType == 0)
  UILuaHelper.SetActive(self.m_pnl_moomselect01, moonType == 1)
  UILuaHelper.SetActive(self.m_pnl_moomselect02, moonType == 2)
  UILuaHelper.SetActive(self.m_pnl_moomselect03, moonType == 3)
end

function Form_HeroList:FreshHeroList()
  self.m_luaHeroListInfinityGrid:ShowItemList(self.m_allShowHeroList)
end

function Form_HeroList:RefreshHeroHeat()
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.CharacterHeat)
  self.m_btn_heroheat:SetActive(openFlag)
  self:OnEventCheckHeroHeatRed()
end

function Form_HeroList:FreshHeroGuideList()
  self.m_luaHeroGuideInfinityGrid:ShowItemList(self.m_allShowGuideHeroList)
end

function Form_HeroList:CheckShowEnterAnim()
  local showLuaInfinityGrid = self.m_isShowHeroList and self.m_luaHeroListInfinityGrid or self.m_luaHeroGuideInfinityGrid
  local showHeroItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showHeroItemList
  for i, tempHeroItem in ipairs(showHeroItemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  if self.m_isInit then
    TimeService:SetTimer(0.1, 1, function()
      self:ShowItemListAnim()
    end)
    self.m_isInit = false
  else
    TimeService:SetTimer(0.1, 1, function()
      self:ShowItemListAnim()
    end)
  end
end

function Form_HeroList:ShowItemListAnim()
  local showLuaInfinityGrid = self.m_isShowHeroList and self.m_luaHeroListInfinityGrid or self.m_luaHeroGuideInfinityGrid
  local showHeroItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showHeroItemList
  for i, tempHeroItem in ipairs(showHeroItemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    local leftIndex = i % self.m_LineItemCount
    leftIndex = leftIndex - 1
    if leftIndex < 0 then
      leftIndex = self.m_LineItemCount - 1
    end
    if leftIndex == 0 then
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, CardInAnimStr)
    else
      self["ItemInitTimer" .. i] = TimeService:SetTimer(leftIndex * DurationTime, 1, function()
        UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
        UILuaHelper.PlayAnimationByName(tempObj, CardInAnimStr)
      end)
    end
  end
end

function Form_HeroList:OnFilterChanged()
  if self.m_isShowHeroList then
    self.m_allShowHeroList = self.m_heroSort:FilterHeroList(self.m_allHeroList, self.m_filterData)
  else
    self.m_allShowGuideHeroList = self.m_heroSort:FilterHeroList(self.m_allGuideHeroList, self.m_filterData)
  end
  self:OnHeroSortChanged(self.m_curFilterIndex, self.m_bFilterDown)
end

function Form_HeroList:FreshProgressNum()
  local curHaveHeroNum = #(self.m_allHeroList or {})
  local totalHeroNum = #(self.m_allGuideHeroList or {})
  self.m_txt_hero_num_Text.text = curHaveHeroNum .. "/" .. totalHeroNum
end

function Form_HeroList:OnHeroItemClick(index, go)
  local itemIndex = index + 1
  local chooseHeroData = self.m_allShowHeroList[itemIndex]
  if not chooseHeroData then
    return
  end
  GlobalManagerIns:TriggerWwiseBGMState(20)
  StackFlow:Push(UIDefines.ID_FORM_HERODETAIL, {
    heroDataList = self.m_allShowHeroList,
    chooseHeroIndex = itemIndex
  })
  self.m_LockScrollPos = true
end

function Form_HeroList:OnHeroGuideItemClick(index, go)
  local itemIndex = index + 1
  local chooseGuideHeroData = self.m_allShowGuideHeroList[itemIndex]
  if not chooseGuideHeroData then
    return
  end
  GlobalManagerIns:TriggerWwiseBGMState(20)
  StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
    heroID = chooseGuideHeroData.serverData.iHeroId
  })
end

function Form_HeroList:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HeroList:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_HeroList:OnHeroSortChanged(iIndex, bDown)
  self.m_curFilterIndex = iIndex
  self.m_bFilterDown = bDown
  if self.m_isShowHeroList then
    self:FreshSortHero()
    self:FreshHeroList()
  else
    self:FreshSortHeroGuide()
    self:FreshHeroGuideList()
  end
end

function Form_HeroList:OnBtnFilterClicked()
  local function chooseBackFun(filterData)
    self.m_filterData = filterData
    
    UILuaHelper.SetActive(self.m_filter_select, false)
    if self.m_filterData then
      for _, value in pairs(self.m_filterData) do
        if value ~= 0 then
          UILuaHelper.SetActive(self.m_filter_select, true)
          break
        end
      end
    end
    self:OnFilterChanged()
    self:CheckShowEnterAnim()
  end
  
  utils.openForm_filter(self.m_filterData, self.m_btn_Filter.transform, {x = 0.5, y = 0}, {x = 0, y = 40}, chooseBackFun, true)
end

function Form_HeroList:OnBtnR3Clicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Form)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tis_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_TEAM)
end

function Form_HeroList:OnBtndependentsClicked()
  if self.m_isShowHeroList == true then
    return
  end
  self.m_filterMoon = 0
  self.m_isShowHeroList = true
  self.m_filterData = {}
  self.m_bFilterDown = nil
  self:FreshHeroGuideTabShow()
  self.m_curFilterIndex = DefaultChooseFilterIndex
  self.m_widgetBtnFilter:RefreshTabConfig(HeroSortCfg, self.m_curFilterIndex, self.m_bFilterDown, function(filterIndex, isFilterDown)
    self:OnHeroSortChanged(filterIndex, isFilterDown)
    self:CheckShowEnterAnim()
  end)
  self:OnFilterChanged()
  self.m_luaHeroListInfinityGrid:LocateTo()
end

function Form_HeroList:OnBtnbookClicked()
  if self.m_isShowHeroList == false then
    return
  end
  self.m_filterMoon = 0
  self.m_isShowHeroList = false
  self.m_curFilterIndex = DefaultChooseFilterIndex
  self.m_bFilterDown = nil
  self.m_filterData = {}
  self:FreshHeroGuideTabShow()
  self.m_widgetBtnFilter:RefreshTabConfig(HeroGuideSortCfg, self.m_curFilterIndex, self.m_bFilterDown, function(filterIndex, isFilterDown)
    self:OnHeroSortChanged(filterIndex, isFilterDown)
    self:CheckShowEnterAnim()
  end)
  self:OnFilterChanged()
  self.m_luaHeroGuideInfinityGrid:LocateTo()
end

function Form_HeroList:OnBtnheroheatClicked()
  if HeroManager:GetRecommendNextRefreshTime() < TimeUtil:GetServerTimeS() then
    local msg = MTTDProto.Cmd_Recommend_GetInit_CS()
    RPCS():Recommend_GetInit(msg, handler(self, self.OnGetRecommendData))
  else
    StackFlow:Push(UIDefines.ID_FORM_HEROHEAT)
  end
end

function Form_HeroList:OnGetRecommendData(stdata)
  HeroManager:SetRecommendData(stdata)
  StackFlow:Push(UIDefines.ID_FORM_HEROHEAT)
end

function Form_HeroList:OnMoonClk(moonIndex)
  if not moonIndex then
    return
  end
  if moonIndex == self.m_filterMoon then
    return
  end
  self.m_filterMoon = moonIndex
  self:FilterMoonData()
end

function Form_HeroList:OnBtnmoon00Clicked()
  if self.isCanClickMoonType then
    self:OnMoonClk(0)
    self:MoonFilterCd()
  end
end

function Form_HeroList:OnBtnmoon01Clicked()
  if self.isCanClickMoonType then
    self:OnMoonClk(1)
    self:MoonFilterCd()
  end
end

function Form_HeroList:OnBtnmoon02Clicked()
  if self.isCanClickMoonType then
    self:OnMoonClk(2)
    self:MoonFilterCd()
  end
end

function Form_HeroList:OnBtnmoon03Clicked()
  if self.isCanClickMoonType then
    self:OnMoonClk(3)
    self:MoonFilterCd()
  end
end

function Form_HeroList:MoonFilterCd()
  self.m_btn_moon00.transform:GetComponent("ButtonScale").enabled = false
  self.m_btn_moon01.transform:GetComponent("ButtonScale").enabled = false
  self.m_btn_moon02.transform:GetComponent("ButtonScale").enabled = false
  self.m_btn_moon03.transform:GetComponent("ButtonScale").enabled = false
  self.isCanClickMoonType = false
  TimeService:SetTimer(filterMoonTypeTime, 1, function()
    self.isCanClickMoonType = true
    self.m_btn_moon00.transform:GetComponent("ButtonScale").enabled = true
    self.m_btn_moon01.transform:GetComponent("ButtonScale").enabled = true
    self.m_btn_moon02.transform:GetComponent("ButtonScale").enabled = true
    self.m_btn_moon03.transform:GetComponent("ButtonScale").enabled = true
  end)
end

function Form_HeroList:FilterMoonData()
  UILuaHelper.SetActive(self.m_pnl_moomselect00, self.m_filterMoon == 0)
  UILuaHelper.SetActive(self.m_pnl_moomselect01, self.m_filterMoon == 1)
  UILuaHelper.SetActive(self.m_pnl_moomselect02, self.m_filterMoon == 2)
  UILuaHelper.SetActive(self.m_pnl_moomselect03, self.m_filterMoon == 3)
  self.m_filterData[HeroManager.FilterType.MoonType] = self.m_filterMoon
  self:OnFilterChanged()
  self:CheckShowEnterAnim()
end

function Form_HeroList:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HeroList", Form_HeroList)
return Form_HeroList
