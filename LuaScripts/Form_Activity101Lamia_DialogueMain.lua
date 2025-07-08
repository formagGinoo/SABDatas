local Form_Activity101Lamia_DialogueMain = class("Form_Activity101Lamia_DialogueMain", require("UI/UIFrames/Form_Activity101Lamia_DialogueMainUI"))
local PageMaxNum = 4
local DragLimitNum = 100
local ChooseItemPreStr = "m_item_choose"
local UILamiaLevelItem = require("UI/Item/LamiaLevel/UILamiaLevelItem")
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree
local Lamia_DialogueMainchoose_in = "Lamia_DialogueMainchoose_in"
local Lamia_DialogueMainchoose_loop = "Lamia_DialogueMainchoose_loop"
local Lamia_DialogueMainchoose_out = "Lamia_DialogueMainchoose_out"
local Lamia_DialogueMainlist_right_out = "Lamia_DialogueMainlist_right_out"
local Lamia_DialogueMainlist_left_out = "Lamia_DialogueMainlist_left_out"
local Lamia_DialogueMainlist_left_in = "Lamia_DialogueMainlist_left_in"
local Lamia_DialogueMainlist_in = "Lamia_DialogueMainlist_in"
local Lamia_DialogueMainlist_loop = "Lamia_DialogueMainlist_loop"

function Form_Activity101Lamia_DialogueMain:AfterInit()
  self.super.AfterInit(self)
  self.DegreeCfgTab[LevelDegree.Normal].contentNode = self.m_content_nml
  self.DegreeCfgTab[LevelDegree.Normal].itemPreName = "m_item_nml"
  self.DegreeCfgTab[LevelDegree.Normal].starListRoot = self.m_pnl_list_extension_star_normal
  self.DegreeCfgTab[LevelDegree.Normal].itemClass = UILamiaLevelItem
  self.DegreeCfgTab[LevelDegree.Hard].contentNode = self.m_content_hard
  self.DegreeCfgTab[LevelDegree.Hard].itemPreName = "m_item_hard"
  self.DegreeCfgTab[LevelDegree.Hard].starListRoot = self.m_pnl_list_extension_star_hard
  self.DegreeCfgTab[LevelDegree.Hard].itemClass = UILamiaLevelItem
  self.m_btnExtension = self.m_button_extension:GetComponent("ButtonExtensions")
  if self.m_btnExtension then
    self.m_btnExtension.BeginDrag = handler(self, self.OnImgBeginDrag)
    self.m_btnExtension.EndDrag = handler(self, self.OnImgEndBDrag)
  end
  self.m_curDegreeIndex = nil
  self.m_startDragPos = nil
  self:InitChooseItems()
  self.m_img_star_grey:SetActive(false)
end

function Form_Activity101Lamia_DialogueMain:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(144)
end

function Form_Activity101Lamia_DialogueMain:OnInactive()
  self.super.OnInactive(self)
  self:ClearData()
  if self.m_mainListLooptimer then
    TimeService:KillTimer(self.m_mainListLooptimer)
  end
  if self.m_mainChooseloopTimer then
    TimeService:KillTimer(self.m_mainChooseloopTimer)
  end
  if self.m_mainChooseoutTimer then
    TimeService:KillTimer(self.m_mainChooseoutTimer)
  end
  if self.m_aniOutTimer then
    TimeService:KillTimer(self.m_aniOutTimer)
  end
  if self.m_aniInTimer then
    TimeService:KillTimer(self.m_aniInTimer)
  end
  if self.m_rightOutTimer then
    TimeService:KillTimer(self.m_rightOutTimer)
  end
end

function Form_Activity101Lamia_DialogueMain:ClearData()
  self.m_intoModel = nil
end

function Form_Activity101Lamia_DialogueMain:FreshDegreeLevelList()
  for _, v in ipairs(self.DegreeCfgTab) do
    local levelData = self.m_levelHelper:GetLevelDataByActAndSubID(self.m_activityID, v.activitySubID) or {}
    local levelCfgList = levelData.levelCfgList
    local nextLevelCfg = self.m_levelHelper:GetNextShowLevelCfg(self.m_activityID, v.activitySubID) or {}
    local nextLevelID = nextLevelCfg.m_LevelID or 0
    local showLevelItemList = {}
    local moveIndex = 1
    for index, tempCfg in ipairs(levelCfgList) do
      local isCurrent = tempCfg.m_LevelID == nextLevelID
      local tempShowLevelItem = {levelCfg = tempCfg, isChoose = isCurrent}
      showLevelItemList[#showLevelItemList + 1] = tempShowLevelItem
      if isCurrent then
        moveIndex = index
        v.currentID = tempCfg.m_LevelID
      end
    end
    v.levelList = showLevelItemList
    local levelNum = #showLevelItemList
    local maxPageNum = math.floor(levelNum / PageMaxNum)
    local leftNum = levelNum % PageMaxNum
    if 0 < leftNum then
      maxPageNum = maxPageNum + 1
    end
    v.maxPageNum = maxPageNum
    self:InitPageItems(v, moveIndex)
  end
end

function Form_Activity101Lamia_DialogueMain:InitPageItems(degreeCfgTab, moveIndex)
  if not degreeCfgTab then
    return
  end
  local itemComponents = degreeCfgTab.itemComponents
  local itemClass = degreeCfgTab.itemClass
  local itemPreName = degreeCfgTab.itemPreName
  local pageIndex = math.floor(moveIndex / PageMaxNum)
  local leftNum = moveIndex % PageMaxNum
  if leftNum <= 0 and 0 < pageIndex then
    pageIndex = pageIndex - 1
  end
  if itemComponents == nil or #itemComponents == 0 then
    itemComponents = {}
    for i = 1, PageMaxNum do
      local itemIndex = pageIndex * PageMaxNum + i
      local itemData = degreeCfgTab.levelList[itemIndex]
      local itemCom = itemClass.new(nil, self[itemPreName .. i], degreeCfgTab.initData, itemData, itemIndex)
      itemComponents[#itemComponents + 1] = itemCom
    end
    degreeCfgTab.itemComponents = itemComponents
  else
    self:FreshPageItems(degreeCfgTab, pageIndex)
  end
  degreeCfgTab.pageIndex = pageIndex
end

function Form_Activity101Lamia_DialogueMain:FreshPageItems(degreeCfgTab, pageIndex)
  if not degreeCfgTab then
    return
  end
  local itemComponents = degreeCfgTab.itemComponents
  for i = 1, PageMaxNum do
    local tempCom = itemComponents[i]
    local itemIndex = pageIndex * PageMaxNum + i
    local itemData = degreeCfgTab.levelList[itemIndex]
    tempCom:FreshData(itemData, itemIndex)
  end
  degreeCfgTab.pageIndex = pageIndex
end

function Form_Activity101Lamia_DialogueMain:GetLevelIndexByLevelID(levelDegree, levelID)
  if not levelDegree then
    return
  end
  if not levelID then
    return
  end
  local levelDataList = self.DegreeCfgTab[levelDegree].levelList
  for i, v in ipairs(levelDataList) do
    if v.levelCfg.m_LevelID == levelID then
      return i
    end
  end
end

function Form_Activity101Lamia_DialogueMain:GetShowItemComByIndex(levelDegree, levelID)
  if not levelDegree then
    return
  end
  if not levelID then
    return
  end
  local itemComponents = self.DegreeCfgTab[levelDegree].itemComponents
  for i, tempCom in ipairs(itemComponents) do
    if tempCom.m_itemData.levelCfg.m_LevelID == levelID then
      return tempCom
    end
  end
end

function Form_Activity101Lamia_DialogueMain:InitChooseItems()
  self.m_chooseItemComList = {}
  for i = 1, PageMaxNum do
    local itemCom = UILamiaLevelItem.new(nil, self[ChooseItemPreStr .. i], nil, nil, i)
    self.m_chooseItemComList[#self.m_chooseItemComList + 1] = itemCom
  end
end

function Form_Activity101Lamia_DialogueMain:FreshUI()
  self.super.FreshUI(self)
  self:FreshLevelTab(self.m_curDegreeIndex)
  self:FreshDegreeLevelList()
  self:CheckInitUpdateStarList()
end

function Form_Activity101Lamia_DialogueMain:CheckInitUpdateStarList()
  for _, tempDegreeCfgTab in ipairs(self.DegreeCfgTab) do
    self:FreshStarListNum(tempDegreeCfgTab)
    self:FreshStarListShow(tempDegreeCfgTab)
  end
end

function Form_Activity101Lamia_DialogueMain:FreshLevelTab(index)
  self.super.FreshLevelTab(self, index)
  if index then
    local curDegreeData = self.DegreeCfgTab[index]
    UILuaHelper.SetActive(curDegreeData.contentNode, true)
    local aniLen = UILuaHelper.GetAnimationLengthByName(curDegreeData.contentNode, "Lamia_DialogueMainlist_left_in")
    self.m_mainListLooptimer = TimeService:SetTimer(aniLen, 1, function()
      UILuaHelper.PlayAnimationByName(curDegreeData.contentNode, "Lamia_DialogueMainlist_loop")
    end)
  end
end

function Form_Activity101Lamia_DialogueMain:CloseAllDegreeNode(ignoreIndex)
  self.super.CloseAllDegreeNode(self, ignoreIndex)
  for i, v in ipairs(self.DegreeCfgTab) do
    if ignoreIndex ~= i then
      UILuaHelper.SetActive(v.contentNode, false)
    end
  end
end

function Form_Activity101Lamia_DialogueMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetailLamiaSubPanel", self.m_level_detail_root, self, {
        bgBackFun = handler(self, self.OnLevelDetailBgClick)
      }, {
        activityID = self.m_activityID,
        levelID = self.m_curDetailLevelID
      }, function(luaPanel)
        self.m_luaDetailLevel = luaPanel
        self.m_luaDetailLevel:AddEventListeners()
      end)
    else
      self.m_luaDetailLevel:FreshData({
        activityID = self.m_activityID,
        levelID = self.m_curDetailLevelID
      })
    end
    UILuaHelper.SetActive(self.m_button_extension_choose, true)
    self:FreshChooseItemNode()
    UILuaHelper.PlayAnimationByName(self.m_button_extension_choose, Lamia_DialogueMainchoose_in)
    GlobalManagerIns:TriggerWwiseBGMState(95)
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_button_extension_choose, Lamia_DialogueMainchoose_in)
    self.m_mainChooseloopTimer = TimeService:SetTimer(aniLen, 1, function()
      UILuaHelper.PlayAnimationByName(self.m_button_extension_choose, Lamia_DialogueMainchoose_loop)
    end)
  else
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_button_extension_choose, Lamia_DialogueMainchoose_out)
    GlobalManagerIns:TriggerWwiseBGMState(96)
    UILuaHelper.PlayAnimationByName(self.m_button_extension_choose, Lamia_DialogueMainchoose_out)
    self.m_mainChooseoutTimer = TimeService:SetTimer(aniLen, 1, function()
      UILuaHelper.SetActive(self.m_level_detail_root, false)
      UILuaHelper.SetActive(self.m_button_extension_choose, false)
    end)
  end
end

function Form_Activity101Lamia_DialogueMain:FreshChooseItemNode()
  if not self.m_curDetailLevelID then
    return
  end
  if not self.m_curDegreeIndex then
    return
  end
  local chooseItemIndex = self:GetLevelIndexByLevelID(self.m_curDegreeIndex, self.m_curDetailLevelID)
  if not chooseItemIndex then
    return
  end
  local onePageIndex = chooseItemIndex % PageMaxNum
  if onePageIndex == 0 then
    onePageIndex = PageMaxNum
  end
  local itemData = self.DegreeCfgTab[self.m_curDegreeIndex].levelList[chooseItemIndex]
  if not itemData then
    return
  end
  for i, chooseItem in ipairs(self.m_chooseItemComList) do
    chooseItem:SetActive(i == onePageIndex)
    if i == onePageIndex then
      chooseItem:FreshData(itemData, chooseItemIndex)
    end
  end
end

function Form_Activity101Lamia_DialogueMain:CheckChangeLastPageShow()
  if not self.m_curDegreeIndex then
    return
  end
  local degreeCfgTab = self.DegreeCfgTab[self.m_curDegreeIndex]
  if not degreeCfgTab then
    return
  end
  local pageIndex = degreeCfgTab.pageIndex
  if not pageIndex then
    return
  end
  if pageIndex <= 0 then
    return
  end
  pageIndex = pageIndex - 1
  self:PlayChangePageAni(degreeCfgTab.contentNode, false, function()
    self:FreshPageItems(degreeCfgTab, pageIndex)
    self:FreshStarListShow(degreeCfgTab)
  end)
end

function Form_Activity101Lamia_DialogueMain:CheckChangeNextPageShow()
  if not self.m_curDegreeIndex then
    return
  end
  local degreeCfgTab = self.DegreeCfgTab[self.m_curDegreeIndex]
  if not degreeCfgTab then
    return
  end
  local pageIndex = degreeCfgTab.pageIndex
  if not pageIndex then
    return
  end
  local pageMaxNum = degreeCfgTab.maxPageNum - 1
  if pageIndex >= pageMaxNum then
    return
  end
  pageIndex = pageIndex + 1
  self:PlayChangePageAni(degreeCfgTab.contentNode, true, function()
    self:FreshPageItems(degreeCfgTab, pageIndex)
    self:FreshStarListShow(degreeCfgTab)
  end)
end

function Form_Activity101Lamia_DialogueMain:PlayChangePageAni(contentNode, is_next, call_back)
  local ani_out_name = is_next and Lamia_DialogueMainlist_left_out or Lamia_DialogueMainlist_right_out
  local ani_in_name = is_next and Lamia_DialogueMainlist_left_in or Lamia_DialogueMainlist_in
  local aniLen = UILuaHelper.GetAnimationLengthByName(contentNode, ani_out_name)
  UILuaHelper.PlayAnimationByName(contentNode, ani_out_name)
  self.m_aniOutTimer = TimeService:SetTimer(aniLen, 1, function()
    if call_back then
      call_back()
    end
    aniLen = UILuaHelper.GetAnimationLengthByName(contentNode, ani_in_name)
    UILuaHelper.PlayAnimationByName(contentNode, ani_in_name)
    self.m_aniInTimer = TimeService:SetTimer(aniLen, 1, function()
      UILuaHelper.PlayAnimationByName(contentNode, Lamia_DialogueMainlist_loop)
    end)
  end)
end

function Form_Activity101Lamia_DialogueMain:FreshStarListNum(degreeCfgTab)
  local maxPageNum = degreeCfgTab.maxPageNum
  local starNodeList = degreeCfgTab.starNodeList
  local curHaveStarNodeNum = #starNodeList
  if maxPageNum < curHaveStarNodeNum then
    for i = maxPageNum + 1, curHaveStarNodeNum do
      local tempStarNode = starNodeList[i]
      UILuaHelper.SetActive(tempStarNode.rootNode, false)
    end
  elseif maxPageNum > curHaveStarNodeNum then
    for i = curHaveStarNodeNum + 1, maxPageNum do
      local starRootObj = GameObject.Instantiate(self.m_img_star_grey, degreeCfgTab.starListRoot.transform).gameObject
      UILuaHelper.SetActive(starRootObj, true)
      local tempStarNode = {
        rootNode = starRootObj,
        starLight = starRootObj.transform:Find("m_img_star_light"),
        lineGray = starRootObj.transform:Find("m_line_gray")
      }
      starNodeList[#starNodeList + 1] = tempStarNode
    end
  end
  local endNode = starNodeList[#starNodeList]
  if endNode then
    UILuaHelper.SetActive(endNode.lineGray, false)
  end
end

function Form_Activity101Lamia_DialogueMain:FreshStarListShow(degreeCfgTab)
  local curPageIndex = degreeCfgTab.pageIndex + 1
  local maxPageNum = degreeCfgTab.maxPageNum
  for i = 1, maxPageNum do
    local starNode = degreeCfgTab.starNodeList[i]
    UILuaHelper.SetActive(starNode.rootNode, true)
    if starNode then
      UILuaHelper.SetActive(starNode.starLight, i == curPageIndex)
    end
  end
end

function Form_Activity101Lamia_DialogueMain:OnImgBeginDrag(pointerEventData)
  self.m_isDrag = true
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
end

function Form_Activity101Lamia_DialogueMain:OnImgEndBDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_startDragPos.x
  local absDeltaNum = math.abs(deltaNum)
  if absDeltaNum < DragLimitNum then
    return
  end
  if 0 < deltaNum then
    self:CheckChangeLastPageShow()
  else
    self:CheckChangeNextPageShow()
  end
  self.m_startDragPos = nil
end

function Form_Activity101Lamia_DialogueMain:OnNormalItemClick(index)
  if not index then
    return
  end
  local degreeCfgTab = self.DegreeCfgTab[LevelDegree.Normal]
  local levelList = degreeCfgTab.levelList
  if not levelList then
    return
  end
  local currentID = degreeCfgTab.currentID
  if currentID then
    local lastIndex = self:GetLevelIndexByLevelID(LevelDegree.Normal, currentID)
    local lastItem = self:GetShowItemComByIndex(LevelDegree.Normal, currentID)
    if lastItem then
      lastItem:ChangeChoose(false)
    else
      degreeCfgTab.levelList[lastIndex].isChoose = false
    end
  end
  local curLevelData = levelList[index]
  local curLevelID = curLevelData.levelCfg.m_LevelID
  degreeCfgTab.currentID = curLevelID
  self.m_curDetailLevelID = curLevelID
  self:FreshLevelDetailShow()
end

function Form_Activity101Lamia_DialogueMain:OnHardItemClick(index)
  if not index then
    return
  end
  local degreeCfgTab = self.DegreeCfgTab[LevelDegree.Hard]
  local levelList = degreeCfgTab.levelList
  if not levelList then
    return
  end
  local currentID = degreeCfgTab.currentID
  if currentID then
    local lastIndex = self:GetLevelIndexByLevelID(LevelDegree.Hard, currentID)
    local lastItem = self:GetShowItemComByIndex(LevelDegree.Hard, currentID)
    if lastItem then
      lastItem:ChangeChoose(false)
    else
      degreeCfgTab.levelList[lastIndex].isChoose = false
    end
  end
  local curLevelData = levelList[index]
  local curLevelID = curLevelData.levelCfg.m_LevelID
  degreeCfgTab.currentID = curLevelID
  self.m_curDetailLevelID = curLevelID
  self:FreshLevelDetailShow()
end

function Form_Activity101Lamia_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == LevelDegree.Normal then
    return
  end
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_content_nml, Lamia_DialogueMainlist_right_out)
  UILuaHelper.PlayAnimationByName(self.m_content_nml, Lamia_DialogueMainlist_right_out)
  self.m_rightOutTimer = TimeService:SetTimer(aniLen, 1, function()
    self:FreshLevelTab(LevelDegree.Normal)
  end)
end

function Form_Activity101Lamia_DialogueMain:OnBtnHardClicked()
  if self.m_curDegreeIndex == LevelDegree.Hard then
    return
  end
  if self.m_isHarLock then
    local clientMsgStr = ConfigManager:GetClientMessageTextById(40039)
    clientMsgStr = string.CS_Format(clientMsgStr, self:GetHardLevelUnlockStr(), self:GetHardTimeUnlockStr())
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, clientMsgStr)
    return
  end
  LevelHeroLamiaActivityManager:SetActivitySubEnter(self.DegreeCfgTab[LevelDegree.Hard].activitySubID)
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_content_hard, Lamia_DialogueMainlist_right_out)
  UILuaHelper.PlayAnimationByName(self.m_content_hard, Lamia_DialogueMainlist_right_out)
  TimeService:SetTimer(aniLen, 1, function()
    self:FreshLevelTab(LevelDegree.Hard)
  end)
  LocalDataManager:SetIntSimple("HeroActDialogueMainHardEntry" .. self.m_activityID, 1, true)
  self.m_hard_new:SetActive(false)
end

function Form_Activity101Lamia_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID
  })
end

function Form_Activity101Lamia_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

ActiveLuaUI("Form_Activity101Lamia_DialogueMain", Form_Activity101Lamia_DialogueMain)
return Form_Activity101Lamia_DialogueMain
