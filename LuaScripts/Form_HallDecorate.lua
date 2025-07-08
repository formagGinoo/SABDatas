local Form_HallDecorate = class("Form_HallDecorate", require("UI/UIFrames/Form_HallDecorateUI"))
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local DefaultTypeIndex = 1
local MainBgType = RoleManager.MainBgType
local PosTypeToStrTab = {
  [MainBgType.Role] = "role",
  [MainBgType.Activity] = "activity",
  [MainBgType.Fashion] = "fashion"
}
local DefaultCampIndex = 0
local MainBackgroundIns = ConfigManager:GetConfigInsByName("MainBackground")
local HallRoleTabIconAnimStr = "HallDecorate_pagetab_in"
local HallRoleItemListAnimStr = "HallDecorate_pagerole_in"
local HallActivityPageAnimStr = "HallDecorate_pageactivity_in"

function Form_HallDecorate:Init(gameObject, csui)
  self:CheckCreateVariable(csui)
  self:CreateTabClkBackFunctions()
  Form_HallDecorate.super.Init(self, gameObject, csui)
end

function Form_HallDecorate:SetInitParam(param)
end

function Form_HallDecorate:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1196)
  self.TypeToggleTab = {
    [MainBgType.Role] = {
      panelNode = self.m_pnl_decoraterole,
      contentAnimStr = "HallDecorate_decoraterole_in",
      nodeSelect = self.m_img_tab_role,
      pageNode = self.m_page_role,
      freshFun = self.ChangeRoleShow,
      freshLeftUpContentFun = self.FreshLeftUpContentRole
    },
    [MainBgType.Activity] = {
      panelNode = self.m_pnl_decorate_act,
      contentAnimStr = "HallDecorate_decoratebanner_in",
      nodeSelect = self.m_img_tab_selactivity,
      pageNode = self.m_page_activity,
      freshFun = self.ChangeActShow,
      freshLeftUpContentFun = self.FreshLeftUpContentActivity
    }
  }
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnRoleItemClk(itemIndex)
    end
  }
  self.m_luaRoleInfinityGrid = self:CreateInfinityGrid(self.m_list_role_item_InfinityGrid, "HallDecorate/UIDecorateRoleItem", initGridData)
  local initActGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnActivityItemClk(itemIndex)
    end
  }
  self.m_luaActivityInfinityGrid = self:CreateInfinityGrid(self.m_list_act_item_InfinityGrid, "HallDecorate/UIDecorateActivityItem", initActGridData)
  self.m_bg_root_trans = self.m_bg_root.transform
  self.m_content_node_Trans = self.m_content_node.transform
  self.m_blurNode_Trans = self.m_blurNode.transform
  self.m_curChoosePosIndex = nil
  self.m_curTypeIndex = nil
  self.m_curCampIndex = nil
  self.m_allRoleDataList = nil
  self.m_filterCampRoleDataList = nil
  self.m_allActivityDataList = nil
  self.m_showPosDataList = nil
  self.m_curMainBackgroundCfg = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_curShowRoleData = nil
  self:InitCloseSubNodeStatus()
  self.m_curBgPrefabStr = nil
  self.m_curBgNodeObj = nil
end

function Form_HallDecorate:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  RoleManager:CheckSetFirstEnterHallDecorate()
  self:RegisterRedDot()
end

function Form_HallDecorate:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
  self:CheckRecycleBgNode()
end

function Form_HallDecorate:OnDestroy()
  self:CheckRecycleSpine(true)
  self:CheckRecycleBgNode()
  self.super.OnDestroy(self)
end

function Form_HallDecorate:FreshData()
  self.m_curMainBackgroundCfg = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curMainBackgroundCfg = RoleManager:GetMainBackgroundCfg(tParam.userMainBackgroundID)
    self.m_csui.m_param = nil
  end
  self:InitPosStatus()
  self:InitCreateRoleList()
  self:InitCreateActivityList()
end

function Form_HallDecorate:ClearCacheData()
end

function Form_HallDecorate:InitPosStatus()
  self.m_showPosDataList = {}
  local heroPosData = RoleManager:GetMainBackGroundDataList()
  for i = 1, RoleManager.MaxHallBgPosNum do
    local tempPosData = heroPosData[i] or {
      iType = MainBgType.Empty,
      id = 0
    }
    local posData = {
      serverData = tempPosData,
      curChooseData = table.deepcopy(tempPosData)
    }
    self.m_showPosDataList[#self.m_showPosDataList + 1] = posData
  end
end

function Form_HallDecorate:InitCreateRoleList()
  self.m_allRoleDataList = {}
  local allHeroDataList = HeroManager:GetHeroList()
  for i, v in ipairs(allHeroDataList) do
    local tempData = {
      isSelect = false,
      characterCfg = v.characterCfg,
      heroID = v.characterCfg.m_HeroID
    }
    self.m_allRoleDataList[#self.m_allRoleDataList + 1] = tempData
  end
  table.sort(self.m_allRoleDataList, function(a, b)
    local qualityA = a.characterCfg.m_Quality
    local qualityB = b.characterCfg.m_Quality
    if qualityA ~= qualityB then
      return qualityA > qualityB
    end
    return a.heroID < b.heroID
  end)
end

function Form_HallDecorate:FreshRoleDataListChooseStatus()
  if not self.m_showPosDataList then
    return
  end
  if not self.m_curChoosePosIndex then
    return
  end
  local tempShowPosData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not tempShowPosData then
    return
  end
  local curChooseData = tempShowPosData.curChooseData
  for _, v in ipairs(self.m_allRoleDataList) do
    v.isSelect = curChooseData.iType == MainBgType.Role and v.heroID == curChooseData.iId
  end
end

function Form_HallDecorate:GetRolePosChooseFilterListIndex()
  if not self.m_showPosDataList then
    return
  end
  if not self.m_curChoosePosIndex then
    return
  end
  local tempShowPosData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not tempShowPosData then
    return
  end
  local curChooseData = tempShowPosData.curChooseData
  if curChooseData.iType ~= MainBgType.Role then
    return
  end
  for i, v in ipairs(self.m_filterCampRoleDataList) do
    if v.heroID == curChooseData.iId then
      return i
    end
  end
end

function Form_HallDecorate:FreshCampFilterRoleList()
  if not self.m_allRoleDataList then
    return
  end
  if not self.m_curCampIndex then
    return
  end
  if self.m_curCampIndex == DefaultCampIndex then
    self.m_filterCampRoleDataList = self.m_allRoleDataList
  else
    self.m_filterCampRoleDataList = {}
    for _, v in ipairs(self.m_allRoleDataList) do
      if v.characterCfg.m_Camp == self.m_curCampIndex then
        self.m_filterCampRoleDataList[#self.m_filterCampRoleDataList + 1] = v
      end
    end
  end
end

function Form_HallDecorate:GetRoleDataByID(roleID)
  if not roleID then
    return
  end
  for i, v in ipairs(self.m_allRoleDataList) do
    if v.heroID == roleID then
      return v
    end
  end
end

function Form_HallDecorate:InitCreateActivityList()
  local allMainBgCfgDic = MainBackgroundIns:GetAll()
  self.m_allActivityDataList = {}
  for _, v in pairs(allMainBgCfgDic) do
    local tempHideType = RoleManager:GetMainBackgroundHideTypeValue(v.m_BDID, v.m_HideType) or 0
    if tempHideType ~= 1 then
      local tempMainBgData = {
        isSelect = false,
        mainBackgroundCfg = v,
        bgID = v.m_BDID,
        isHave = 0 < ItemManager:GetItemNum(v.m_BDID)
      }
      self.m_allActivityDataList[#self.m_allActivityDataList + 1] = tempMainBgData
    end
  end
  table.sort(self.m_allActivityDataList, function(a, b)
    local isHaveA = a.isHave
    local isHaveB = b.isHave
    if isHaveA ~= isHaveB then
      return isHaveA
    end
    return a.bgID < b.bgID
  end)
end

function Form_HallDecorate:FreshActivityDataListChooseStatus()
  if not self.m_showPosDataList then
    return
  end
  if not self.m_curChoosePosIndex then
    return
  end
  local tempShowPosData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not tempShowPosData then
    return
  end
  local curChooseData = tempShowPosData.curChooseData
  for _, v in ipairs(self.m_allActivityDataList) do
    v.isSelect = curChooseData.iType == MainBgType.Activity and v.bgID == curChooseData.iId
  end
end

function Form_HallDecorate:GetActivityDataByID(bgID)
  if not bgID then
    return
  end
  for i, v in ipairs(self.m_allActivityDataList) do
    if v.bgID == bgID then
      return v
    end
  end
end

function Form_HallDecorate:GetActivityPosChooseListIndex()
  if not self.m_showPosDataList then
    return
  end
  if not self.m_curChoosePosIndex then
    return
  end
  local tempShowPosData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not tempShowPosData then
    return
  end
  local curChooseData = tempShowPosData.curChooseData
  if curChooseData.iType ~= MainBgType.Activity then
    return
  end
  for i, v in ipairs(self.m_allActivityDataList) do
    if v.bgID == curChooseData.iId then
      return i
    end
  end
end

function Form_HallDecorate:GetTypeIndexWithChoosePos()
  if not self.m_curChoosePosIndex then
    return
  end
  if not self.m_showPosDataList then
    return
  end
  local tempShowPosData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not tempShowPosData then
    return
  end
  local curChooseData = tempShowPosData.curChooseData
  if curChooseData.iType == MainBgType.Empty then
    return DefaultTypeIndex
  else
    return curChooseData.iType
  end
end

function Form_HallDecorate:ChangeCurPoseChooseData(mainBgType, id)
  if not self.m_curChoosePosIndex then
    return
  end
  if not mainBgType then
    return
  end
  id = id or 0
  local posData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not posData then
    return
  end
  posData.curChooseData.iType = mainBgType
  posData.curChooseData.iId = id
end

function Form_HallDecorate:ChangeCurPoseDataChooseStatus(isSelect)
  if not self.m_curChoosePosIndex then
    return
  end
  local posData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not posData then
    return
  end
  local curChooseData = posData.curChooseData
  local type = curChooseData.iType
  if type == MainBgType.Empty then
    return
  end
  if type == MainBgType.Role then
    local tempRoleData = self:GetRoleDataByID(curChooseData.iId)
    if tempRoleData then
      tempRoleData.isSelect = isSelect
    end
  elseif type == MainBgType.Activity then
    local tempActData = self:GetActivityDataByID(curChooseData.iId)
    if tempActData then
      tempActData.isSelect = isSelect
    end
  end
end

function Form_HallDecorate:IsChoosePosHaveChange()
  if not self.m_showPosDataList then
    return
  end
  for i, v in ipairs(self.m_showPosDataList) do
    if v.curChooseData.iType ~= v.serverData.iType or v.curChooseData.iId ~= v.serverData.iId then
      return true
    end
  end
  return false
end

function Form_HallDecorate:IsChoosePosAllEmpty()
  if not self.m_showPosDataList then
    return
  end
  local isAllEmpty = true
  for i, v in ipairs(self.m_showPosDataList) do
    if v.curChooseData.iType ~= MainBgType.Empty and v.curChooseData.iId ~= 0 then
      isAllEmpty = false
      break
    end
  end
  return isAllEmpty
end

function Form_HallDecorate:GetAllPosCurChooseDataList()
  if not self.m_showPosDataList then
    return
  end
  local allPosCurChooseDataList = {}
  for i, v in ipairs(self.m_showPosDataList) do
    allPosCurChooseDataList[#allPosCurChooseDataList + 1] = v.curChooseData
  end
  return allPosCurChooseDataList
end

function Form_HallDecorate:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_activity_red_dot, RedDotDefine.ModuleType.HallDecorateActTab)
end

function Form_HallDecorate:AddEventListeners()
  self:addEventListener("eGameEvent_Role_SetMainBackground", handler(self, self.OnRoleSetMainBGBack))
end

function Form_HallDecorate:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HallDecorate:OnRoleSetMainBGBack()
  if not self.m_showPosDataList then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13016)
  self:CloseForm()
end

function Form_HallDecorate:InitCloseSubNodeStatus()
  for i, v in pairs(self.TypeToggleTab) do
    UILuaHelper.SetActive(v.panelNode, false)
    UILuaHelper.SetActive(v.nodeSelect, false)
    UILuaHelper.SetActive(v.pageNode, false)
  end
  for i = 1, RoleManager.MaxHallBgPosNum do
    UILuaHelper.SetActive(self["m_img_select" .. i], false)
  end
  for i = 0, self.m_uiVariables.MaxCampIndex do
    UILuaHelper.SetActive(self["m_tab_camp_sel" .. i], false)
  end
end

function Form_HallDecorate:FreshUI()
  self:CheckFreshShowBgAndVagueContent()
  self:FreshPosListShow()
  local showPosIndex = RoleManager:GetMainBackGroundIndex()
  self:ChangePoseShow(showPosIndex, false, false, false, false)
end

function Form_HallDecorate:CheckRecycleBgNode()
  if self.m_curBgPrefabStr and self.m_curBgNodeObj then
    utils.RecycleInParentUIPrefab(self.m_curBgPrefabStr, self.m_curBgNodeObj)
  end
  self.m_curBgPrefabStr = nil
  self.m_curBgNodeObj = nil
end

function Form_HallDecorate:CheckFreshShowBgAndVagueContent()
  if self.m_curMainBackgroundCfg then
    local tempPrefabStr = self.m_curMainBackgroundCfg.m_Prefabs
    if tempPrefabStr and tempPrefabStr ~= "" then
      utils.TryLoadUIPrefabInParent(self.m_bg_root_trans, tempPrefabStr, function(nameStr, gameObject)
        self.m_curBgPrefabStr = nameStr
        self.m_curBgNodeObj = gameObject
        UILuaHelper.SetActiveChildren(self.m_bg_root_trans, false)
        local usePrefabStr = self.m_curMainBackgroundCfg.m_Prefabs
        if usePrefabStr and usePrefabStr ~= "" then
          local subNode = self.m_bg_root_trans:Find(usePrefabStr)
          if subNode then
            UILuaHelper.SetActive(subNode, true)
          end
        end
        self:CheckShowVague()
      end)
    end
  else
    UILuaHelper.SetActiveChildren(self.m_bg_root_trans, false)
    self:CheckShowVague()
  end
end

function Form_HallDecorate:CheckShowVague()
  TimeService:SetTimer(0.01, 1, function()
    UILuaHelper.SetActive(self.m_content_node, false)
    UILuaHelper.SetActive(self.m_blurNode_Trans, false)
    UIManager:OpenUIGuassianBlur(self:GetID(), self.m_blurNode_Trans, function()
      UILuaHelper.SetActive(self.m_blurNode_Trans, true)
      UILuaHelper.SetActive(self.m_content_node, true)
    end)
  end)
end

function Form_HallDecorate:FreshPosListShow()
  for i = 1, RoleManager.MaxHallBgPosNum do
    self:FreshPoseStatusByIndex(i)
  end
end

function Form_HallDecorate:FreshPoseStatusByIndex(posIndex)
  if not posIndex then
    return
  end
  local tempPosData = self.m_showPosDataList[posIndex]
  if not tempPosData then
    return
  end
  local tempType = tempPosData.curChooseData.iType
  local isNotEmpty = tempType ~= MainBgType.Empty
  UILuaHelper.SetActive(self["m_choosetypesel" .. posIndex], isNotEmpty)
  if isNotEmpty then
    UILuaHelper.SetActiveChildren(self["m_choosetypesel" .. posIndex], false)
    local typeStr = "m_type" .. PosTypeToStrTab[tempType] .. posIndex
    if self[typeStr] then
      UILuaHelper.SetActive(self[typeStr], true)
    end
  end
end

function Form_HallDecorate:ChangePoseShow(index, isNoChangeSubType, isOnlyFreshList, isShowContentAnim, isShowRightPanelAnim)
  if self.m_curChoosePosIndex then
    UILuaHelper.SetActive(self["m_img_select" .. self.m_curChoosePosIndex], false)
  end
  self.m_curChoosePosIndex = index
  UILuaHelper.SetActive(self["m_img_select" .. self.m_curChoosePosIndex], true)
  self:FreshRoleDataListChooseStatus()
  self:FreshActivityDataListChooseStatus()
  local typeIndex = self:GetTypeIndexWithChoosePos()
  self:ChangeBgTypeShow(typeIndex, isNoChangeSubType, isOnlyFreshList, isShowRightPanelAnim)
  self:CheckFreshLeftUpContent(isShowContentAnim)
  self:FreshRightDownButtonStatus()
end

function Form_HallDecorate:ChangeBgTypeShow(index, isNoChangeSubType, isOnlyFreshList, isShowRightPanelAnim)
  if self.m_curTypeIndex then
    local lastTypeIndex = self.m_curTypeIndex
    local typeTab = self.TypeToggleTab[lastTypeIndex]
    if typeTab then
      UILuaHelper.SetActive(typeTab.nodeSelect, false)
      UILuaHelper.SetActive(typeTab.pageNode, false)
    end
  end
  self.m_curTypeIndex = index
  local curTypeTab = self.TypeToggleTab[index]
  if curTypeTab then
    UILuaHelper.SetActive(curTypeTab.nodeSelect, true)
    UILuaHelper.SetActive(curTypeTab.pageNode, true)
    if curTypeTab.freshFun then
      curTypeTab.freshFun(self, isNoChangeSubType, isOnlyFreshList, isShowRightPanelAnim)
    end
  end
end

function Form_HallDecorate:CheckFreshLeftUpContent(isShowContentAnim)
  if not self.m_curChoosePosIndex then
    return
  end
  local typeIndex = self:GetTypeIndexWithChoosePos()
  if not typeIndex then
    return
  end
  local curTypeTab = self.TypeToggleTab[typeIndex]
  if not curTypeTab then
    return
  end
  for i, v in pairs(self.TypeToggleTab) do
    UILuaHelper.SetActive(v.panelNode, i == typeIndex)
    if isShowContentAnim and i == typeIndex then
      UILuaHelper.PlayAnimationByName(v.panelNode, v.contentAnimStr)
    end
  end
  if curTypeTab.freshLeftUpContentFun then
    curTypeTab.freshLeftUpContentFun(self)
  end
end

function Form_HallDecorate:FreshRightDownButtonStatus()
  if not self.m_curChoosePosIndex then
    return
  end
  local isHaveChange = self:IsChoosePosHaveChange()
  UILuaHelper.SetActive(self.m_btn_reset, isHaveChange)
  UILuaHelper.SetActive(self.m_btn_reset_gray, not isHaveChange)
end

function Form_HallDecorate:CheckFreshCurBgTypeListShow()
  if not self.m_curTypeIndex then
    return
  end
  local typeToggleTab = self.TypeToggleTab[self.m_curTypeIndex]
  if not typeToggleTab then
    return
  end
  if typeToggleTab.freshFun then
    typeToggleTab.freshFun(self, false, true)
  end
end

function Form_HallDecorate:ChangeRoleShow(isNoChangeSubType, isOnlyFreshList, isShowRightPanelAnim)
  local toShowCampIndex = DefaultCampIndex
  if isNoChangeSubType then
    toShowCampIndex = self.m_curCampIndex or DefaultCampIndex
  end
  if isShowRightPanelAnim then
    UILuaHelper.PlayAnimationByName(self.m_tab_icon, HallRoleTabIconAnimStr)
  else
    UILuaHelper.StopAnimation(self.m_tab_icon)
    UILuaHelper.ResetAnimationByName(self.m_tab_icon, HallRoleTabIconAnimStr, -1)
  end
  self:ChangeRoleCampShow(toShowCampIndex, isOnlyFreshList, isShowRightPanelAnim)
end

function Form_HallDecorate:ChangeRoleCampShow(campIndex, isOnlyFresh, isShowRightPanelAnim)
  if self.m_curCampIndex then
    UILuaHelper.SetActive(self["m_tab_camp_sel" .. self.m_curCampIndex], false)
  end
  self.m_curCampIndex = campIndex
  UILuaHelper.SetActive(self["m_tab_camp_sel" .. campIndex], true)
  self:FreshCampFilterRoleList()
  self:FreshRoleListShow(not isOnlyFresh)
  if isShowRightPanelAnim then
    UILuaHelper.SetActive(self.m_list_role_item, false)
    UILuaHelper.SetActive(self.m_list_role_item, true)
    UILuaHelper.PlayAnimationByName(self.m_list_role_item, HallRoleItemListAnimStr)
  else
    UILuaHelper.StopAnimation(self.m_list_role_item)
    UILuaHelper.ResetAnimationByName(self.m_list_role_item, HallRoleItemListAnimStr, -1)
  end
end

function Form_HallDecorate:FreshRoleListShow(isRePos)
  self.m_luaRoleInfinityGrid:ShowItemList(self.m_filterCampRoleDataList)
  UILuaHelper.SetActive(self.m_z_txt_none, #self.m_filterCampRoleDataList == 0)
  if isRePos then
    self.m_luaRoleInfinityGrid:LocateTo()
  end
end

function Form_HallDecorate:FreshLeftUpContentRole()
  if not self.m_curChoosePosIndex then
    return
  end
  local posData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not posData then
    return
  end
  local tempCurChooseData = posData.curChooseData
  local bgType = tempCurChooseData.iType
  local isNotEmpty = bgType ~= MainBgType.Empty
  UILuaHelper.SetActive(self.m_pnl_role_empty, not isNotEmpty)
  UILuaHelper.SetActive(self.m_pnl_role, isNotEmpty)
  if isNotEmpty then
    local roleData = self:GetRoleDataByID(tempCurChooseData.iId)
    if not roleData then
      return
    end
    self.m_curShowRoleData = roleData
    self:FreshCampImageShow()
    self.m_txt_heroname_Text.text = roleData.characterCfg.m_mName
    self:FreshShowSpine()
  end
end

function Form_HallDecorate:FreshCampImageShow()
  if not self.m_curShowRoleData then
    return
  end
  local campCfg = CampCfgIns:GetValue_ByCampID(self.m_curShowRoleData.characterCfg.m_Camp)
  if not campCfg:GetError() then
    UILuaHelper.SetAtlasSprite(self.m_img_camp_Image, campCfg.m_CampIcon)
  end
end

function Form_HallDecorate:FreshShowSpine()
  if not self.m_curShowRoleData then
    return
  end
  self:ShowHeroSpine(self.m_curShowRoleData.characterCfg.m_Spine)
end

function Form_HallDecorate:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HallDecorate:ShowHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.MainShowSmall
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack()
  end)
end

function Form_HallDecorate:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  local spinePlaceObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spinePlaceObj, true)
  local spineRootObj = self.m_curHeroSpineObj.spineObj
  UILuaHelper.SpineResetMatParam(spineRootObj)
  UILuaHelper.SetSpineTimeScale(spineRootObj, 1)
  UILuaHelper.SpinePlayAnimWithBack(spineRootObj, 0, "idle", false, false)
  UILuaHelper.SpineResetInit(spineRootObj)
  UILuaHelper.SetSpineTimeScale(spineRootObj, 0)
  if spineRootObj:GetComponent("SpineSkeletonPosControl") then
    spineRootObj:GetComponent("SpineSkeletonPosControl"):OnResetInit()
  end
end

function Form_HallDecorate:ChangeActShow(isNoChangeSubType, isOnlyFreshList, isShowRightPanelAnim)
  if not self.m_allActivityDataList then
    return
  end
  self:FreshActivityListShow(not isOnlyFreshList)
  if isShowRightPanelAnim then
    UILuaHelper.PlayAnimationByName(self.m_page_activity, HallActivityPageAnimStr)
  else
    UILuaHelper.StopAnimation(self.m_page_activity)
    UILuaHelper.ResetAnimationByName(self.m_page_activity, HallActivityPageAnimStr, -1)
  end
end

function Form_HallDecorate:FreshActivityListShow(isRePos)
  self.m_luaActivityInfinityGrid:ShowItemList(self.m_allActivityDataList)
  if isRePos then
    self.m_luaActivityInfinityGrid:LocateTo()
  end
end

function Form_HallDecorate:FreshLeftUpContentActivity()
  if not self.m_curChoosePosIndex then
    return
  end
  local posData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not posData then
    return
  end
  local tempCurChooseData = posData.curChooseData
  local bgType = tempCurChooseData.iType
  local isNotEmpty = bgType ~= MainBgType.Empty
  UILuaHelper.SetActive(self.m_pnl_act_empty, not isNotEmpty)
  UILuaHelper.SetActive(self.m_pnl_act, isNotEmpty)
  if isNotEmpty then
    local actData = self:GetActivityDataByID(tempCurChooseData.iId)
    if actData then
      self.m_txt_bg_name_Text.text = actData.mainBackgroundCfg.m_mBDName
      UILuaHelper.SetAtlasSprite(self.m_img_act_bg_Image, actData.mainBackgroundCfg.m_SmallPic)
    end
  end
end

function Form_HallDecorate:CreateTabClkBackFunctions()
  for i = 1, RoleManager.MaxHallBgPosNum do
    self["OnBtnchoosetype" .. i .. "Clicked"] = function()
      self:OnPosClk(i)
    end
  end
  for i = 0, self.m_uiVariables.MaxBgType do
    self["OnBtnType" .. i .. "Clicked"] = function()
      self:OnTypeClk(i)
    end
  end
  for i = 0, self.m_uiVariables.MaxCampIndex do
    self["OnBtnCamp" .. i .. "Clicked"] = function()
      self:OnCampClk(i)
    end
  end
end

function Form_HallDecorate:OnPosClk(index)
  if not index then
    return
  end
  if index == self.m_curChoosePosIndex then
    return
  end
  self:ChangePoseShow(index, false, true, true, false)
end

function Form_HallDecorate:OnTypeClk(index)
  if not index then
    return
  end
  if index == self.m_curTypeIndex then
    return
  end
  self:ChangeBgTypeShow(index, false, false, true)
end

function Form_HallDecorate:OnCampClk(index)
  if not index then
    return
  end
  if index == self.m_curCampIndex then
    return
  end
  self:ChangeRoleCampShow(index, false, true)
end

function Form_HallDecorate:OnBackClk()
  self:CheckRecycleSpine(true)
  GlobalManagerIns:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HallDecorate:OnBackHome()
  self:CheckRecycleSpine(true)
  StackPopup:PopAll()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
end

function Form_HallDecorate:OnRoleItemClk(itemIndex)
  if not itemIndex then
    return
  end
  local curPoseData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not curPoseData then
    return
  end
  local curChooseData = curPoseData.curChooseData
  if curChooseData.iType == MainBgType.Role then
    local showListIndex = self:GetRolePosChooseFilterListIndex()
    if showListIndex then
      local showItem = self.m_luaRoleInfinityGrid:GetShowItemByIndex(showListIndex)
      if showItem then
        showItem:ChangeItemChooseStatus(false)
      else
        self.m_filterCampRoleDataList[showListIndex].isSelect = false
      end
    else
      local lastChoseRoleData = self:GetRoleDataByID(curChooseData.iId)
      if lastChoseRoleData then
        lastChoseRoleData.isSelect = false
      end
    end
  else
    self:ChangeCurPoseDataChooseStatus(false)
  end
  local toSelRoleData = self.m_filterCampRoleDataList[itemIndex]
  if toSelRoleData.heroID == curChooseData.iId then
    self:ChangeCurPoseChooseData(MainBgType.Empty, 0)
  else
    local showItem = self.m_luaRoleInfinityGrid:GetShowItemByIndex(itemIndex)
    if showItem then
      showItem:ChangeItemChooseStatus(true)
    else
      self.m_filterCampRoleDataList[itemIndex].isSelect = true
    end
    self:ChangeCurPoseChooseData(MainBgType.Role, self.m_filterCampRoleDataList[itemIndex].heroID)
  end
  self:FreshPoseStatusByIndex(self.m_curChoosePosIndex)
  self:CheckFreshLeftUpContent(true)
  self:FreshRightDownButtonStatus()
end

function Form_HallDecorate:OnActivityItemClk(itemIndex)
  if not itemIndex then
    return
  end
  local curPoseData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not curPoseData then
    return
  end
  local curChooseData = curPoseData.curChooseData
  if curChooseData.iType == MainBgType.Activity then
    local showListIndex = self:GetActivityPosChooseListIndex()
    if showListIndex then
      local showItem = self.m_luaActivityInfinityGrid:GetShowItemByIndex(showListIndex)
      if showItem then
        showItem:ChangeItemChooseStatus(false)
      else
        self.m_allActivityDataList[showListIndex].isSelect = false
      end
    end
  else
    self:ChangeCurPoseDataChooseStatus(false)
  end
  local toSelActData = self.m_allActivityDataList[itemIndex]
  if toSelActData.bgID == curChooseData.iId then
    self:ChangeCurPoseChooseData(MainBgType.Empty, 0)
  else
    local showItem = self.m_luaActivityInfinityGrid:GetShowItemByIndex(itemIndex)
    if showItem then
      showItem:ChangeItemChooseStatus(true)
    else
      self.m_allActivityDataList[itemIndex].isSelect = true
    end
    self:ChangeCurPoseChooseData(MainBgType.Activity, self.m_allActivityDataList[itemIndex].bgID)
  end
  self:FreshPoseStatusByIndex(self.m_curChoosePosIndex)
  self:CheckFreshLeftUpContent(true)
  self:FreshRightDownButtonStatus()
end

function Form_HallDecorate:OnBtnresetClicked()
  if not self.m_showPosDataList then
    return
  end
  for _, v in ipairs(self.m_showPosDataList) do
    v.curChooseData = table.deepcopy(v.serverData)
  end
  self:FreshPosListShow()
  self:FreshRoleDataListChooseStatus()
  self:FreshActivityDataListChooseStatus()
  self:CheckFreshCurBgTypeListShow()
  self:CheckFreshLeftUpContent(true)
  self:FreshRightDownButtonStatus()
end

function Form_HallDecorate:OnBtnresetgrayClicked()
  if not self.m_showPosDataList then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13015)
end

function Form_HallDecorate:OnBtnpreviewClicked()
  if not self.m_curChoosePosIndex then
    return
  end
  local posData = self.m_showPosDataList[self.m_curChoosePosIndex]
  if not posData then
    return
  end
  local curChooseData = posData.curChooseData
  if curChooseData.iType == MainBgType.Empty then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13013)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_HALLDECORATESHOW, {
    mainBgData = curChooseData,
    closeBackFun = function()
      self:OnPreShowBack()
    end
  })
end

function Form_HallDecorate:OnPreShowBack()
  self:CheckFreshLeftUpContent()
end

function Form_HallDecorate:OnBtnsaveClicked()
  if not self.m_curChoosePosIndex then
    return
  end
  local isHaveChange = self:IsChoosePosHaveChange()
  if isHaveChange == false then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13015)
    return
  end
  local isAllPosEmpty = self:IsChoosePosAllEmpty()
  if isAllPosEmpty == true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13014)
    return
  end
  local allMainBgChooseList = self:GetAllPosCurChooseDataList()
  if not allMainBgChooseList then
    return
  end
  RoleManager:ReqRoleSetMainBackground(allMainBgChooseList)
end

function Form_HallDecorate:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroDataList = HeroManager:GetHeroList()
  if heroDataList and next(heroDataList) then
    for i, v in pairs(heroDataList) do
      if v.characterCfg and v.characterCfg.m_HeroID then
        local heroID = v.characterCfg.m_HeroID
        vPackage[#vPackage + 1] = {
          sName = tostring(heroID),
          eType = DownloadManager.ResourcePackageType.Character
        }
      end
    end
  end
  return vPackage, vResourceExtra
end

function Form_HallDecorate:IsFullScreen()
  return true
end

function Form_HallDecorate:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HallDecorate", Form_HallDecorate)
return Form_HallDecorate
