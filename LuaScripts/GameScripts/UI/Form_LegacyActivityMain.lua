local Form_LegacyActivityMain = class("Form_LegacyActivityMain", require("UI/UIFrames/Form_LegacyActivityMainUI"))
local SubPanelManager = _ENV.SubPanelManager
local LegacyLevelManager = _ENV.LegacyLevelManager
local titleAnimationData = {
  en = "m_PicPath10",
  ja = "m_PicPath22",
  cn = "m_PicPath6",
  ht = "m_PicPath41",
  kr = "m_PicPath23"
}

function Form_LegacyActivityMain:SetInitParam(param)
end

function Form_LegacyActivityMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1167)
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnChapterItemClk(itemIndex)
    end,
    itemExClkBackFun = function(itemIndex)
      self:OnExChapterItemClk(itemIndex)
    end
  }
  self.m_luaChapterInfinityGrid = self:CreateInfinityGrid(self.m_chapter_list_InfinityGrid, "LegacyActivity/UILegacyChapterItem", initGridData)
  self.m_showChapterItemDataList = nil
  self.m_curChooseChapterIndex = nil
  self.m_paramChapterIndex = nil
  self.m_isParamChooseEx = nil
  self.m_isChooseEx = nil
  self.m_isShowSubPanel = nil
  self.m_luaDetailLevel = nil
  self.m_chapterListScrollRect = self.m_chapter_list:GetComponent(T_ScrollRect)
  self.m_btnExtension = self.m_chapter_list:GetComponent("ButtonExtensions")
  if self.m_btnExtension then
    self.m_btnExtension.BeginDrag = handler(self, self.OnRectBeginDrag)
    self.m_btnExtension.EndDrag = handler(self, self.OnRectEndDrag)
  end
  self.m_scrollRectContent = self.m_chapterListScrollRect.content
  self.m_isInitParam = nil
  self.m_viewPortW = nil
  self.m_viewContentW = nil
  self.m_minContentX = nil
  self.m_maxContentX = nil
  self.m_contentLen = nil
  self.m_rotationParamDeltaNum = nil
  self:InitViewPortParam()
  self:CheckRegisterRedDot()
  self:InitTitleAnimation()
  self.m_isHaveInitList = false
end

function Form_LegacyActivityMain:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  GlobalManagerIns:TriggerWwiseBGMState(164)
  GlobalManagerIns:TriggerWwiseBGMState(206)
end

function Form_LegacyActivityMain:OnOpen()
  Form_LegacyActivityMain.super.OnOpen(self)
  if not self.m_isHaveInitList and self.m_chapterListScrollRect then
    self.m_chapterListScrollRect.onValueChanged:RemoveAllListeners()
  end
  self:FreshData()
  self:FreshUI()
  if not self.m_isHaveInitList and self.m_chapterListScrollRect then
    self.m_chapterListScrollRect.onValueChanged:AddListener(function()
      self:OnChapterListContentChange()
    end)
  end
  self.m_isHaveInitList = true
end

function Form_LegacyActivityMain:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
  GlobalManagerIns:TriggerWwiseBGMState(165)
end

function Form_LegacyActivityMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_chapterListScrollRect then
    self.m_chapterListScrollRect.onValueChanged:RemoveAllListeners()
  end
  self.m_isHaveInitList = false
  for i = 1, self.m_itemInitShowNum do
    if self["ItemInitTimer" .. i] then
      TimeService:KillTimer(self["ItemInitTimer" .. i])
      self["ItemInitTimer" .. i] = nil
    end
  end
end

function Form_LegacyActivityMain:FreshData()
  self.m_isShowSubPanel = nil
  self:FreshChapterDataList()
  local tParam = self.m_csui.m_param
  if tParam then
    local paramChapterID = tParam.chapterID
    self.m_paramChapterIndex = self:GetChapterIndexByID(paramChapterID)
    self.m_isParamChooseEx = tParam.isChooseEx
    self.m_isShowSubPanel = tParam.isShowSubPanel
    self.m_csui.m_param = nil
  end
end

function Form_LegacyActivityMain:FreshChapterDataList()
  local showChapterItemDataList = {}
  local normalChapterDataList = LegacyLevelManager:GetNormalChapterList()
  for _, chapterData in ipairs(normalChapterDataList) do
    local tempItemData = {
      chapterData = chapterData,
      isChoose = false,
      isChooseEx = nil,
      progressNum = nil,
      isUnlock = nil,
      exProgressNum = nil,
      isExUnlock = nil
    }
    showChapterItemDataList[#showChapterItemDataList + 1] = tempItemData
  end
  self.m_showChapterItemDataList = showChapterItemDataList
end

function Form_LegacyActivityMain:GetChapterIndexByID(chapterID)
  if not chapterID then
    return
  end
  for i, v in ipairs(self.m_showChapterItemDataList) do
    if v.chapterData.chapterCfg.m_ChapterID == chapterID then
      return i
    end
  end
end

function Form_LegacyActivityMain:GetCurProgressChapterIndex()
end

function Form_LegacyActivityMain:ClearCacheData()
end

function Form_LegacyActivityMain:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnItemJump))
end

function Form_LegacyActivityMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LegacyActivityMain:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_legacy_guide_red_dot, RedDotDefine.ModuleType.LegacyGuideEntry)
end

function Form_LegacyActivityMain:InitViewPortParam()
  TimeService:SetTimer(self.m_uiVariables.InitParamWaitTime, 1, function()
    self.m_viewPortW, _ = UILuaHelper.GetUISizeDelta(self.m_chapter_list)
    self.m_viewContentW, _ = UILuaHelper.GetUISizeDelta(self.m_scrollRectContent)
    self.m_minContentX = -(self.m_viewContentW - self.m_viewPortW)
    self.m_maxContentX = 0
    self.m_contentLen = self.m_maxContentX - self.m_minContentX
    self.m_rotationParamDeltaNum = self.m_uiVariables.MaxRotationNum - self.m_uiVariables.MinRotationNum
    self.m_isInitParam = true
    self:FreshRotationShow()
  end)
end

function Form_LegacyActivityMain:InitTitleAnimation()
  for _, v in pairs(titleAnimationData) do
    self[v]:SetActive(false)
  end
  local picId = self.m_img_frame:GetComponent("UIMultiLanPic").PicID
  local multiLanPicPath = UILuaHelper.GetMultiLanguagePicPath(picId)
  local last_two_chars = string.sub(multiLanPicPath, -2)
  local animationObj = self[titleAnimationData[last_two_chars]]
  if animationObj then
    animationObj:SetActive(true)
  end
end

function Form_LegacyActivityMain:FreshUI()
  self.m_luaChapterInfinityGrid:ShowItemList(self.m_showChapterItemDataList)
  local moveChapterIndex = self.m_paramChapterIndex or LegacyLevelManager:GetNormalCurChapterIndex()
  if 0 < moveChapterIndex then
    self.m_luaChapterInfinityGrid:LocateTo(moveChapterIndex - 1)
  end
  self:CheckShowEnterAnim(function()
    self:FreshChapterChoose(self.m_paramChapterIndex, self.m_isParamChooseEx)
    self.m_paramChapterIndex = nil
    self.m_isParamChooseEx = nil
  end)
end

function Form_LegacyActivityMain:FreshRotationShow()
  local contentX, _, _ = UILuaHelper.GetLocalPosition(self.m_scrollRectContent)
  local deltaContentX = contentX - self.m_minContentX
  local rotationNum = deltaContentX / self.m_contentLen * self.m_rotationParamDeltaNum + self.m_uiVariables.MinRotationNum
  UILuaHelper.SetLocalEuler(self.m_img_arrow02, 0, 0, rotationNum)
end

function Form_LegacyActivityMain:OnRectBeginDrag()
  GlobalManagerIns:TriggerWwiseBGMState(166)
end

function Form_LegacyActivityMain:OnRectEndDrag()
  GlobalManagerIns:TriggerWwiseBGMState(167)
end

function Form_LegacyActivityMain:FreshChapterChoose(chooseChapterIndex, isChooseEx)
  if self.m_curChooseChapterIndex then
    local showChapterItem = self.m_luaChapterInfinityGrid:GetShowItemByIndex(self.m_curChooseChapterIndex)
    if showChapterItem then
      showChapterItem:ChangeChooseStatus(false)
      showChapterItem:CheckFreshRedDot()
    elseif self.m_showChapterItemDataList[self.m_curChooseChapterIndex] then
      self.m_showChapterItemDataList[self.m_curChooseChapterIndex].isChoose = false
      self.m_showChapterItemDataList[self.m_curChooseChapterIndex].isChooseEx = nil
    end
    self.m_curChooseChapterIndex = nil
  end
  if chooseChapterIndex then
    local chooseShowItem = self.m_luaChapterInfinityGrid:GetShowItemByIndex(chooseChapterIndex)
    if chooseShowItem then
      chooseShowItem:ChangeChooseStatus(true, isChooseEx)
    elseif self.m_showChapterItemDataList[chooseChapterIndex] then
      self.m_showChapterItemDataList[chooseChapterIndex].isChoose = true
      self.m_showChapterItemDataList[chooseChapterIndex].isChooseEx = isChooseEx
    end
    self.m_curChooseChapterIndex = chooseChapterIndex
  end
  self:FreshLevelListSubPanelShow()
end

function Form_LegacyActivityMain:FreshLevelListSubPanelShow()
  if self.m_curChooseChapterIndex and self.m_showChapterItemDataList[self.m_curChooseChapterIndex] then
    UILuaHelper.SetActive(self.m_root_stage, true)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(17)
    local showChapterItem = self.m_showChapterItemDataList[self.m_curChooseChapterIndex]
    local chapterData = not self.m_isChooseEx and showChapterItem.chapterData or showChapterItem.chapterData.exChapterData
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LegacyLevelDetailSubPanel", self.m_root_stage, self, {
        bgBackFun = function()
          self:OnLevelDetailBgClk()
        end
      }, {
        chapterData = chapterData,
        isExChapter = self.m_isChooseEx
      }, function(luaPanel)
        self.m_luaDetailLevel = luaPanel
      end)
    else
      self.m_luaDetailLevel:FreshData({
        chapterData = chapterData,
        isExChapter = self.m_isChooseEx
      })
    end
  else
    CS.GlobalManager.Instance:TriggerWwiseBGMState(31)
    UILuaHelper.SetActive(self.m_root_stage, false)
  end
end

function Form_LegacyActivityMain:OnItemJump()
  self:OnLevelDetailBgClk()
end

function Form_LegacyActivityMain:CheckShowEnterAnim(endFun)
  local showLuaInfinityGrid = self.m_luaChapterInfinityGrid
  local showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempHeroItem in ipairs(showItemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
  end
  TimeService:SetTimer(self.m_uiVariables.ItemListDelayTime, 1, function()
    self:ShowItemListAnim(endFun)
  end)
end

function Form_LegacyActivityMain:ShowItemListAnim(endFun)
  local itemAnimStr = self.m_uiVariables.ItemAnimStr
  local itemDeltaTime = self.m_uiVariables.ItemDeltaTime
  local showLuaInfinityGrid = self.m_luaChapterInfinityGrid
  local showItemList = showLuaInfinityGrid:GetAllShownItemList()
  self.m_itemInitShowNum = #showItemList
  for i, tempHeroItem in ipairs(showItemList) do
    local tempObj = tempHeroItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    if i == 1 then
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, itemAnimStr)
    else
      do
        local leftIndex = i - 1
        self["ItemInitTimer" .. i] = TimeService:SetTimer(leftIndex * itemDeltaTime, 1, function()
          UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
          UILuaHelper.PlayAnimationByName(tempObj, itemAnimStr)
          if i == self.m_itemInitShowNum and endFun then
            endFun()
          end
        end)
      end
    end
  end
end

function Form_LegacyActivityMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
  self:CloseForm()
end

function Form_LegacyActivityMain:OnLevelDetailBgClk()
  if not self.m_curChooseChapterIndex then
    return
  end
  self.m_isChooseEx = nil
  self:FreshChapterChoose(nil)
end

function Form_LegacyActivityMain:OnChapterItemClk(itemIndex)
  if not itemIndex then
    return
  end
  if itemIndex == self.m_curChooseChapterIndex then
    return
  end
  self.m_isChooseEx = false
  self:SetRedPointFlag(itemIndex)
  self:FreshChapterChoose(itemIndex, self.m_isChooseEx)
end

function Form_LegacyActivityMain:OnExChapterItemClk(itemIndex)
  if not itemIndex then
    return
  end
  if itemIndex == self.m_curChooseChapterIndex then
    return
  end
  self.m_isChooseEx = true
  self:SetRedPointFlag(itemIndex)
  self:FreshChapterChoose(itemIndex, self.m_isChooseEx)
end

function Form_LegacyActivityMain:SetRedPointFlag(itemIndex)
  if self.m_showChapterItemDataList then
    local data = self.m_showChapterItemDataList[itemIndex]
    if data and data.chapterData and data.chapterData.chapterCfg and data.chapterData.chapterCfg.m_ChapterID then
      LocalDataManager:SetIntSimple("Red_Point_DailyLegacyLevel_" .. data.chapterData.chapterCfg.m_ChapterID, TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
    end
  end
end

function Form_LegacyActivityMain:OnBtnLegacyGuideClicked()
  StackFlow:Push(UIDefines.ID_FORM_LEGACYACTIVITYGUIDE)
end

function Form_LegacyActivityMain:OnChapterListContentChange()
  if not self.m_isInitParam then
    return
  end
  self:FreshRotationShow()
end

function Form_LegacyActivityMain:IsFullScreen()
  return true
end

function Form_LegacyActivityMain:GetDownloadResourceExtra(tParam)
  local vSubPanelName = {
    "LegacyLevelDetailSubPanel"
  }
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(vSubPanelName) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
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
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_LegacyActivityMain", Form_LegacyActivityMain)
return Form_LegacyActivityMain
