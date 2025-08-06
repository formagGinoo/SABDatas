local Form_LevelMain = class("Form_LevelMain", require("UI/UIFrames/Form_LevelMainUI"))
local DefaultDegree = LevelManager.MainLevelSubType.MainStory
local DefaultChapterIndex = 1
local ChapterOutAnim = "chapter_out"
local DurationTime = 0.08
local PanelOutAnimStr = "LevelMain_out"
local ChapterChangeNextAnimStr = "txt_superior"
local ChapterChangeLastAnimStr = "txt_down"
local ChapterTaskOutAnim = "m_chapter_task_panel_out"
local CloudInAnimStr = "LexelMain_cloud_in"
local CloudOutAnimStr = "LexelMain_cloud_out"
local math_floor = math.floor
local BackTimeNum = 0.5

function Form_LevelMain:SetInitParam(param)
end

function Form_LevelMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("panel_content/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1104)
  local resourceBarRoot = self.m_rootTrans:Find("panel_content/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_widgetTaskEnter = self:createTaskBar(self.m_common_task_enter)
  local normalInitData = {
    itemClkBackFun = handler(self, self.OnNormalChapterItemClick)
  }
  local hardInitData = {
    itemClkBackFun = handler(self, self.OnHardChapterItemClick)
  }
  self.m_luaNormalChapterGrid = require("UI/Common/UIInfinityGrid").new(self.m_infinity_normal_list_InfinityGrid, "Level/UILevelNormalChapterItem", normalInitData)
  self.m_luaHardChapterGrid = require("UI/Common/UIInfinityGrid").new(self.m_infinity_hard_list_InfinityGrid, "Level/UILevelHardChapterItem", hardInitData)
  self.m_TipsNode:SetActive(true)
  self.tipsNodeHelper = self.m_TipsNode:GetComponent("PrefabHelper")
  self.tipsNodeHelper:RegisterCallback(handler(self, self.OnInitTipsItem))
  self.m_levelMainHelper = LevelManager:GetLevelMainHelper()
  self.m_allChapterData = self.m_levelMainHelper:GetMainLevelData()
  self.m_chapterItemListData = nil
  self.m_paramChapterIndex = nil
  self.m_paramLevelSubType = nil
  self.m_paramLevelID = nil
  self.m_paramIsCheckNewUnlock = nil
  self.m_curShowLevelSubType = nil
  self.m_ShowDegreeData = {
    [LevelManager.MainLevelSubType.MainStory] = {curShowChapterIndex = nil, progressChapterIndex = nil},
    [LevelManager.MainLevelSubType.HardLevel] = {curShowChapterIndex = nil, progressChapterIndex = nil}
  }
  self.m_isShowChapterList = false
  self.m_curDetailLevelID = nil
  self.m_luaDetailLevel = nil
  self.m_levelMapManager = nil
  self.m_UILockID = nil
  self.m_isShowChapterTaskPanel = false
  self.m_showChapterTaskDataList = {}
  UILuaHelper.SetActive(self.m_chapter_task_base_item, false)
  self.m_chapterTaskItemList = {}
  self.m_baseRewardItem = self.m_reward_pop_node.transform:Find("c_common_item")
  local tempItemCom = self:createCommonItem(self.m_baseRewardItem)
  tempItemCom:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnChapterTaskRewardItemClk(itemID, itemNum, itemCom)
  end)
  self.m_ItemWidgetList = {
    [1] = tempItemCom
  }
  self.m_isShowChapterTaskRewardPop = false
  self.m_curShowChapterTaskIndex = nil
  self.m_isEnterAnimEnd = false
end

function Form_LevelMain:OnOpen()
  Form_LevelMain.super.OnOpen(self)
  self:FreshData()
  self:InitLevelMapManagerStatus()
  GlobalManagerIns:TriggerWwiseBGMState(23, false)
  self:FreshUI()
end

function Form_LevelMain:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
end

function Form_LevelMain:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if self.m_unlockLevelEndTimer then
    TimeService:KillTimer(self.m_unlockLevelEndTimer)
    self.m_unlockLevelEndTimer = nil
  end
end

function Form_LevelMain:OnUncoverd()
  if not self.m_curShowLevelSubType then
    return
  end
  local chapterItemList = self.m_chapterItemListData[self.m_curShowLevelSubType]
  if not chapterItemList or not next(chapterItemList) then
    return
  end
  local curShowChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  local curChapterItemData = chapterItemList[curShowChapterIndex]
  if not curChapterItemData then
    return
  end
  local chapterID = curChapterItemData.chapterData.chapterCfg.m_ChapterID
  self:FreshMainExplore(chapterID)
end

function Form_LevelMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_luaNormalChapterGrid then
    self.m_luaNormalChapterGrid:dispose()
    self.m_luaNormalChapterGrid = nil
  end
  if self.m_luaHardChapterGrid then
    self.m_luaHardChapterGrid:dispose()
    self.m_luaHardChapterGrid = nil
  end
  self.super.OnDestroy(self)
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:dispose()
    self.m_luaDetailLevel = nil
  end
  if self.m_chapterChangeTimer then
    TimeService:KillTimer(self.m_chapterChangeTimer)
    self.m_chapterChangeTimer = nil
  end
  if self.m_unlockLevelTimer then
    TimeService:KillTimer(self.m_unlockLevelTimer)
    self.m_unlockLevelTimer = nil
  end
  if self.m_unlockLevelEndTimer then
    TimeService:KillTimer(self.m_unlockLevelEndTimer)
    self.m_unlockLevelEndTimer = nil
  end
  self:ClearData()
end

function Form_LevelMain:GetDownloadResourceExtra(tParam)
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
  return vPackage, vResourceExtra
end

function Form_LevelMain:AddEventListeners()
  self:addEventListener("eGameEvent_Task_Change_State", handler(self, self.OnEventTaskChangeState))
  self:addEventListener("eGameEvent_MainExplore_TakeClueReward", function(id)
    self:FreshExploreNode(id)
    self:FreshMainExplore(id)
  end)
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:AddEventListeners()
  end
end

function Form_LevelMain:RemoveAllEventListeners()
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:RemoveAllEventListeners()
  end
  self:clearEventListener()
end

function Form_LevelMain:OnEventTaskChangeState(param)
  if not param then
    return
  end
  if not self.m_curShowLevelSubType then
    return
  end
  local chapterItemList = self.m_chapterItemListData[self.m_curShowLevelSubType]
  if not chapterItemList or not next(chapterItemList) then
    return
  end
  local curShowChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  local curChapterItemData = chapterItemList[curShowChapterIndex]
  if not curChapterItemData then
    return
  end
  self.m_showChapterTaskDataList = self.m_levelMainHelper:GetChapterProgressTaskList(curChapterItemData.chapterData.chapterCfg.m_ChapterID)
  self:FreshChapterTaskList()
end

function Form_LevelMain:IsEnterAnimEnd()
  return self.m_isEnterAnimEnd
end

function Form_LevelMain:ClearData()
end

function Form_LevelMain:FreshData()
  local tParam = self.m_csui.m_param
  self.m_paramLevelSubType = nil
  self.m_paramChapterIndex = nil
  self.m_paramLevelID = nil
  self.m_paramIsCheckNewUnlock = nil
  self.m_isEnterAnimEnd = false
  if tParam then
    self.m_paramLevelSubType = tParam.levelSubType
    self.m_paramChapterIndex = tParam.chapterIndex
    self.m_paramLevelID = tParam.levelID
    self.m_paramIsCheckNewUnlock = tParam.isCheckShowNewAnim
    self.m_csui.m_param = nil
  end
end

function Form_LevelMain:FreshCurChapterData(showLevelSubType, chapterIndex)
  for key, v in pairs(self.m_ShowDegreeData) do
    if showLevelSubType and showLevelSubType == key and chapterIndex then
      v.curShowChapterIndex = chapterIndex
    else
      v.curShowChapterIndex = self.m_levelMainHelper:GetCurChapterIndex(key) or DefaultChapterIndex
    end
    v.progressChapterIndex = self.m_levelMainHelper:GetCurChapterIndex(key) or DefaultChapterIndex
  end
  self.m_curShowLevelSubType = showLevelSubType
end

function Form_LevelMain:FreshChapterListData()
  if not self.m_allChapterData then
    return
  end
  self.m_chapterItemListData = {}
  for levelSubType, chapterDataList in pairs(self.m_allChapterData) do
    if self.m_chapterItemListData[levelSubType] == nil then
      self.m_chapterItemListData[levelSubType] = {}
    end
    local chapterList = self.m_chapterItemListData[levelSubType]
    local curShowChapterIndex = self.m_ShowDegreeData[levelSubType].curShowChapterIndex
    local progressChapterIndex = self.m_ShowDegreeData[levelSubType].progressChapterIndex
    for index, chapterData in ipairs(chapterDataList) do
      local chapterItem = {
        chapterData = chapterData,
        isChoose = index == curShowChapterIndex,
        isProgressChapter = index == progressChapterIndex
      }
      chapterList[#chapterList + 1] = chapterItem
    end
  end
end

function Form_LevelMain:FormTenNumStr(num)
  if not num then
    return "00"
  end
  if num < 10 then
    return string.format("0%d", num)
  end
  return tostring(num)
end

function Form_LevelMain:InitLevelMapManagerStatus()
  local levelMapMgrObj = GameObject.Find("LevelMapManager")
  if levelMapMgrObj then
    self.m_levelMapManager = levelMapMgrObj:GetComponent("LevelMapManager")
    self.m_levelMapManager:SetLevelClickBackFun(function(levelID, chapterID)
      self:OnLevelItemIconClicked(levelID, chapterID)
    end)
    self.m_levelMapManager:SetMainExploreClickFun(function(chapterID, clueID)
      self:OnMainExploreItemClicked(chapterID, clueID)
    end)
    local oueScreenMgrObj = GameObject.Find("OutScreenManager")
    if oueScreenMgrObj then
      self.oueScreenMgr = oueScreenMgrObj:GetComponent("OutScreenManager")
      self.oueScreenMgr:Init(self.m_rootTrans:GetComponent("Canvas"), self.m_levelMapManager)
    end
    if self.m_levelMapManager._seamlessMap2D then
      self.m_levelMapManager._seamlessMap2D.enabled = false
    end
  end
end

function Form_LevelMain:FreshUI()
  local showLevelSubType = self.m_paramLevelSubType or self.m_curShowLevelSubType
  local isSubTypeUnlock = self.m_levelMainHelper:IsLevelSubTypeUnlock(showLevelSubType)
  if isSubTypeUnlock ~= true then
    showLevelSubType = nil
  end
  showLevelSubType = showLevelSubType or DefaultDegree
  self.m_isShowChapterList = false
  self:FreshCurChapterData(showLevelSubType, self.m_paramChapterIndex)
  self:FreshChapterListData()
  self.m_curDetailLevelID = self.m_paramLevelID or nil
  self:FreshLevelDetailShow()
  self:InitShowChapterList()
  self:StartLockAndShowCloud(true)
  self:FreshChangeDegree(showLevelSubType, true, function()
    self:CheckInitCameraAnim()
  end)
end

function Form_LevelMain:FreshMainExplore(chapterID)
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.MainExplore)
  self.m_btn_explore:SetActive(openFlag)
  if not openFlag then
    return
  end
  local iClueCount, iMaxCount = MainExploreManager:GetCurChapterExploreInfo(chapterID)
  local bHaveReddot = false
  if iClueCount and iMaxCount then
    self.m_txt_num_explore_Text.text = iClueCount .. "/" .. iMaxCount
    local data = MainExploreManager:GetServerChapterRewardData()
    local is_got = false
    for _, v in ipairs(data or {}) do
      if chapterID == v then
        is_got = true
        break
      end
    end
    bHaveReddot = not is_got and iMaxCount <= iClueCount
    self.m_redpoint_explore:SetActive(bHaveReddot)
  else
    self.m_btn_explore:SetActive(false)
  end
  if not bHaveReddot then
    self:RegisterOrUpdateRedDotItem(self.m_redpoint_explore, RedDotDefine.ModuleType.MainExploreEntry)
  end
end

function Form_LevelMain:CheckFreshChapterTaskRedDot(chapterID)
  if self.m_showChapterTaskDataList == nil or next(self.m_showChapterTaskDataList) == nil then
    return
  end
  self:RegisterOrUpdateRedDotItem(self.m_FX_btn_Reward_Get, RedDotDefine.ModuleType.TaskChapterProgress, chapterID)
end

function Form_LevelMain:FreshChangeDegree(levelSubType, isNotShowCloudAnim, backFun)
  if not levelSubType then
    return
  end
  self.m_curShowLevelSubType = levelSubType
  self:FreshChapterList()
  local curShowChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.MainStory then
    UILuaHelper.SetActive(self.m_node_normal, true)
    UILuaHelper.SetActive(self.m_node_hard, false)
    self:FreshChangeNormalChapterChoose(curShowChapterIndex, isNotShowCloudAnim, function()
      if backFun then
        backFun()
      end
    end)
    local tempIndex = self.m_ShowDegreeData[LevelManager.MainLevelSubType.HardLevel].curShowChapterIndex
    self:CheckShowHardEfx(tempIndex)
  elseif self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
    UILuaHelper.SetActive(self.m_node_normal, false)
    UILuaHelper.SetActive(self.m_node_hard, true)
    self:FreshChangeHardChapterChoose(curShowChapterIndex, isNotShowCloudAnim, function()
      if backFun then
        backFun()
      end
    end)
  end
end

function Form_LevelMain:FreshChapterListPanelShow()
  if self.m_isShowChapterList then
    UILuaHelper.SetActive(self.m_chapter_panel, true)
    UILuaHelper.SetActive(self.m_common_task_enter, false)
    UILuaHelper.SetActive(self.m_pnl_left_down, false)
  else
    UILuaHelper.SetActive(self.m_chapter_panel, false)
    local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Task)
    UILuaHelper.SetActive(self.m_common_task_enter, openFlag)
    UILuaHelper.SetActive(self.m_pnl_left_down, true)
  end
end

function Form_LevelMain:ShowChapterListAnim()
  if not self.m_isShowChapterList then
    return
  end
  local luaListInfinityGrid, animStr
  if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.MainStory then
    luaListInfinityGrid = self.m_luaNormalChapterGrid
    animStr = "chapter_normal"
  elseif self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
    luaListInfinityGrid = self.m_luaHardChapterGrid
    animStr = "chapter_hard"
  end
  if not luaListInfinityGrid then
    return
  end
  local showItemList = luaListInfinityGrid:GetAllShownItemList()
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    if i == 0 then
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, animStr)
    else
      TimeService:SetTimer(i * DurationTime, 1, function()
        UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
        UILuaHelper.PlayAnimationByName(tempObj, animStr)
      end)
    end
  end
end

function Form_LevelMain:InitShowChapterList()
  UILuaHelper.SetActive(self.m_chapter_panel, true)
  UILuaHelper.SetActive(self.m_infinity_normal_list, true)
  UILuaHelper.SetActive(self.m_infinity_hard_list, true)
  self.m_luaNormalChapterGrid:ShowItemList(self.m_chapterItemListData[LevelManager.MainLevelSubType.MainStory])
  self.m_luaHardChapterGrid:ShowItemList(self.m_chapterItemListData[LevelManager.MainLevelSubType.HardLevel])
  self:FreshChapterListPanelShow()
end

function Form_LevelMain:FreshChapterList()
  UILuaHelper.SetActive(self.m_infinity_normal_list, self.m_curShowLevelSubType == LevelManager.MainLevelSubType.MainStory)
  UILuaHelper.SetActive(self.m_infinity_hard_list, self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel)
end

function Form_LevelMain:CheckFreshShowChapterInfo()
  if not self.m_curShowLevelSubType then
    return
  end
  local chapterItemList = self.m_chapterItemListData[self.m_curShowLevelSubType]
  if not chapterItemList or not next(chapterItemList) then
    return
  end
  local chapterLen = #chapterItemList
  local curShowChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  local curChapterItemData = chapterItemList[curShowChapterIndex]
  if not curChapterItemData then
    return
  end
  local haveProcessNum, levelTotalNum = self.m_levelMainHelper:GetChapterProgress(curChapterItemData.chapterData)
  local isNormal = self.m_curShowLevelSubType == LevelManager.MainLevelSubType.MainStory
  local isHard = self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel
  UILuaHelper.SetActive(self.m_icon_chapter_normal, isNormal)
  UILuaHelper.SetActive(self.m_img_mask_normal, isNormal)
  UILuaHelper.SetActive(self.m_img_line_chapter, isNormal)
  UILuaHelper.SetActive(self.m_icon_chapter_hard, isHard)
  UILuaHelper.SetActive(self.m_Switch_Hrad_FX, isHard)
  UILuaHelper.SetActive(self.m_img_mask1_hard, isHard)
  UILuaHelper.SetActive(self.m_img_line_chapterhard, isHard)
  UILuaHelper.SetActive(self.m_img_normal, isNormal)
  UILuaHelper.SetActive(self.m_img_hard, isHard)
  self.m_txt_jindu_num_Text.text = string.format("%d/%d", haveProcessNum, levelTotalNum)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_chapter_progress_root)
  self.m_txt_chapter_now_Text.text = curChapterItemData.chapterData.chapterCfg.m_ChapterTitle
  self.m_txt_chapter_hard_Text.text = curChapterItemData.chapterData.chapterCfg.m_ChapterTitle
  UILuaHelper.SetActive(self.m_txt_chapter_hard_Text, isHard)
  self.m_txt_cur_chapter_name_Text.text = curChapterItemData.chapterData.chapterCfg.m_mChapterName
  self.m_txt_cur_chapter_num_Text.text = curChapterItemData.chapterData.chapterCfg.m_ChapterTitle
  if curShowChapterIndex <= 1 then
    UILuaHelper.SetActive(self.m_btn_chapter_before, false)
  else
    UILuaHelper.SetActive(self.m_btn_chapter_before, true)
    local lastChapterIndex = curShowChapterIndex - 1
    self.m_txt_chapter_before_Text.text = self:FormTenNumStr(lastChapterIndex)
  end
  local nextChapterIndex = curShowChapterIndex + 1
  if chapterLen < nextChapterIndex then
    UILuaHelper.SetActive(self.m_btn_chapter_next, false)
    UILuaHelper.SetActive(self.m_btn_chapter_next_lock, false)
  else
    local nextChapterItemData = chapterItemList[nextChapterIndex]
    local nextChapterCfg = nextChapterItemData.chapterData.chapterCfg
    local isChapterUnlock = self.m_levelMainHelper:IsChapterUnlock(nextChapterCfg.m_ChapterID)
    if isChapterUnlock == true then
      UILuaHelper.SetActive(self.m_btn_chapter_next, true)
      UILuaHelper.SetActive(self.m_btn_chapter_next_lock, false)
      self.m_txt_chapter_next_Text.text = self:FormTenNumStr(nextChapterIndex)
    else
      UILuaHelper.SetActive(self.m_btn_chapter_next, false)
      UILuaHelper.SetActive(self.m_btn_chapter_next_lock, true)
      self.m_txt_chapter_next_lock_Text.text = self:FormTenNumStr(nextChapterIndex)
    end
  end
  local chapterID = curChapterItemData.chapterData.chapterCfg.m_ChapterID
  self:FreshChapterTaskShow(chapterID)
  self:FreshMainExplore(chapterID)
end

function Form_LevelMain:CheckMoveProgressChapterLevelPos()
  if not self.m_curShowLevelSubType then
    return
  end
  local curShowChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  local progressChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].progressChapterIndex
  if curShowChapterIndex == progressChapterIndex and self.m_curShowNextLevelInfo then
    local levelID = self.m_curShowNextLevelInfo.m_LevelID
    self.m_levelMapManager:SetDetailCameraPosByLevelID(levelID or 0)
  end
end

function Form_LevelMain:StartLockAndShowCloud(isToEnd)
  if self.m_chapterWaitCloseCloudTimer then
    TimeService:KillTimer(self.m_chapterWaitCloseCloudTimer)
    self.m_chapterWaitCloseCloudTimer = nil
  end
  self:CheckUnLock()
  self.m_lockerID = UILockIns:Lock(self.m_uiVariables.WaitLoadChapterTime)
  self:FreshShowChapterChangeCloudShow(true)
  self:PlayCloudAnimation(true, isToEnd)
end

function Form_LevelMain:PlayCloudAnimation(isIn, isToEnd)
  local animTrans
  if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
    animTrans = self.m_pnl_switchhard
  else
    animTrans = self.m_pnl_switch
  end
  if isToEnd then
    UILuaHelper.ResetAnimationByName(animTrans, isIn and CloudInAnimStr or CloudOutAnimStr, -1)
  else
    UILuaHelper.PlayAnimationByName(animTrans, isIn and CloudInAnimStr or CloudOutAnimStr)
  end
end

function Form_LevelMain:WaitMoveAndUnlock(endBackFun)
  if self.m_chapterWaitCloudUnlockTimer then
    TimeService:KillTimer(self.m_chapterWaitCloudUnlockTimer)
    self.m_chapterWaitCloudUnlockTimer = nil
  end
  self.m_chapterWaitCloudUnlockTimer = TimeService:SetTimer(self.m_uiVariables.ChapterCloudTimeNum, 1, function()
    self.m_chapterWaitCloudUnlockTimer = nil
    self:CheckUnLock()
    self:PlayCloudAnimation(false)
  end)
  if self.m_chapterWaitCloseCloudTimer then
    TimeService:KillTimer(self.m_chapterWaitCloseCloudTimer)
    self.m_chapterWaitCloseCloudTimer = nil
  end
  local animTrans
  if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
    animTrans = self.m_pnl_switchhard
  else
    animTrans = self.m_pnl_switch
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(animTrans, CloudOutAnimStr)
  self.m_chapterWaitCloseCloudTimer = TimeService:SetTimer(self.m_uiVariables.ChapterCloudTimeNum + animLen, 1, function()
    self.m_chapterWaitCloseCloudTimer = nil
    self:FreshShowChapterChangeCloudShow(false)
    if endBackFun then
      endBackFun()
    end
  end)
end

function Form_LevelMain:FreshShowChapterChangeCloudShow(isShow)
  if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
    UILuaHelper.SetActive(self.m_pnl_switchhard, isShow)
    UILuaHelper.SetActive(self.m_pnl_switch, false)
  else
    UILuaHelper.SetActive(self.m_pnl_switch, isShow)
    UILuaHelper.SetActive(self.m_pnl_switchhard, false)
  end
  if isShow then
    if not self.m_curShowLevelSubType then
      return
    end
    local chapterItemList = self.m_chapterItemListData[self.m_curShowLevelSubType]
    if not chapterItemList or not next(chapterItemList) then
      return
    end
    local curShowChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
    local curChapterItemData = chapterItemList[curShowChapterIndex]
    if not curChapterItemData then
      return
    end
    if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
      self.m_txt_switchtohard_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(20324), curChapterItemData.chapterData.chapterCfg.m_ChapterTitle)
    else
      self.m_txt_switchto_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(20324), curChapterItemData.chapterData.chapterCfg.m_ChapterTitle)
    end
  end
end

function Form_LevelMain:CheckFreshShowNextLevelInfo()
  if not self.m_curShowLevelSubType then
    return
  end
  self.m_curShowNextLevelInfo = nil
  local nextLevelInfo = self.m_levelMainHelper:GetNextShowLevelCfg(self.m_curShowLevelSubType)
  if nextLevelInfo then
    self.m_curShowNextLevelInfo = nextLevelInfo
    UILuaHelper.SetActive(self.m_btn_next_stage, true)
    self.m_txt_stage_num_Text.text = self.m_curShowNextLevelInfo.m_LevelName
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_grouprd)
  else
    UILuaHelper.SetActive(self.m_btn_next_stage, false)
  end
end

function Form_LevelMain:FreshLevelItems(backFun)
  if not self.m_curShowLevelSubType then
    return
  end
  local chapterItemListData = self.m_chapterItemListData[self.m_curShowLevelSubType]
  local chapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  local chapterItemData = chapterItemListData[chapterIndex]
  local storyLevelList = chapterItemData.chapterData.storyLevelList
  local exLevelList = chapterItemData.chapterData.exLevelList
  local chapterID = chapterItemData.chapterData.chapterCfg.m_ChapterID
  local levelMapNodeInfoList = List(typeof(CS.LevelMap.LevelMapNodeInfo))()
  for i, mainLevelCfg in ipairs(storyLevelList) do
    if mainLevelCfg then
      local levelID = mainLevelCfg.m_LevelID
      local tempTab = {
        levelID = levelID,
        levelName = mainLevelCfg.m_LevelName,
        levelNodeName = mainLevelCfg.m_mNodeName,
        isHavePass = self.m_levelMainHelper:IsLevelHavePass(levelID),
        isCurrent = self.m_curShowNextLevelInfo and levelID == self.m_curShowNextLevelInfo.m_LevelID,
        isSelect = false,
        specialIconPath = mainLevelCfg.m_NodePic,
        headIconPath = mainLevelCfg.m_Portrait
      }
      levelMapNodeInfoList:Add(tempTab)
    end
  end
  local exLevelMapNodeInfoList = List(typeof(CS.LevelMap.LevelMapNodeInfo))()
  for i, mainLevelCfg in ipairs(exLevelList) do
    if mainLevelCfg then
      local levelID = mainLevelCfg.m_LevelID
      local isCurrent = not self.m_levelMainHelper:IsLevelHavePass(levelID) and self.m_levelMainHelper:IsLevelUnLock(levelID)
      local tempTab = {
        levelID = levelID,
        levelName = mainLevelCfg.m_LevelName,
        levelNodeName = mainLevelCfg.m_mNodeName,
        isHavePass = self.m_levelMainHelper:IsLevelHavePass(levelID),
        isCurrent = isCurrent,
        isSelect = false,
        specialIconPath = mainLevelCfg.m_NodePic,
        headIconPath = mainLevelCfg.m_Portrait
      }
      exLevelMapNodeInfoList:Add(tempTab)
    end
  end
  if self.m_levelMapManager then
    self.m_levelMapManager:ChangeChapterID(chapterID, levelMapNodeInfoList, exLevelMapNodeInfoList, function()
      self:FreshExploreNode(chapterID)
      if self.m_levelMainHelper:IsChapterAllStoryLevelHavePass(chapterID) then
        self.exLevelMapNodeInfoList = exLevelMapNodeInfoList
        self.tipsNodeHelper:CheckAndCreateObjs(exLevelMapNodeInfoList.Count)
      else
        self.tipsNodeHelper:CheckAndCreateObjs(0)
      end
      if backFun then
        backFun()
      end
    end)
  end
end

function Form_LevelMain:FreshShowNormalLevelList(backFun)
  if not self.m_curShowLevelSubType then
    return
  end
  if self.m_curShowLevelSubType ~= LevelManager.MainLevelSubType.MainStory then
    return
  end
  self:FreshLevelItems(backFun)
end

function Form_LevelMain:FreshShowHardLevelList(backFun)
  if not self.m_curShowLevelSubType then
    return
  end
  if self.m_curShowLevelSubType ~= LevelManager.MainLevelSubType.HardLevel then
    return
  end
  self:FreshLevelItems(backFun)
end

function Form_LevelMain:FreshExploreNode(chapterID)
  local unlockExploreList = MainExploreManager:GetExploreInfoByChapterID(chapterID)
  local exploreNodeInfoList = List(typeof(CS.LevelMap.MainExploreNodeInfo))()
  for i, v in ipairs(unlockExploreList) do
    exploreNodeInfoList:Add({
      clueID = v.clueID,
      isShowClue = v.isShowClue
    })
  end
  self.m_levelMapManager:FreshExploreNode(exploreNodeInfoList)
end

function Form_LevelMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      SubPanelManager:LoadSubPanel("LevelDetailSubPanel", self.m_level_detail_root, self, {
        bgBackFun = handler(self, self.OnLevelDetailBgClick)
      }, {
        levelType = LevelManager.LevelType.MainLevel,
        levelSubType = self.m_curShowLevelSubType,
        levelID = self.m_curDetailLevelID
      }, function(luaPanel)
        self.m_luaDetailLevel = luaPanel
        self.m_luaDetailLevel:AddEventListeners()
      end)
    else
      if KeyboardMappingManager then
        KeyboardMappingManager:SetSubConfigInValid(self:GetFramePrefabName(), SubPanelManager.SubPanelCfg.LevelDetailSubPanel and SubPanelManager.SubPanelCfg.LevelDetailSubPanel.PrefabPath or "", self.m_luaDetailLevel, true, false)
      end
      self.m_luaDetailLevel:FreshData({
        levelType = LevelManager.LevelType.MainLevel,
        levelSubType = self.m_curShowLevelSubType,
        levelID = self.m_curDetailLevelID
      })
    end
  else
    UILuaHelper.SetActive(self.m_level_detail_root, false)
  end
end

function Form_LevelMain:FreshChangeLevelNodeChoose(levelID, isChoose)
  if not levelID then
    return
  end
  self.m_levelMapManager:ChangeLevelNodeChoose(levelID, isChoose)
end

function Form_LevelMain:FreshChangeNormalChapterChoose(itemIndex, isNotShowCloudAnim, backFun)
  if not itemIndex then
    return
  end
  local lastIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  if lastIndex then
    local chapterItemCom = self.m_luaNormalChapterGrid:GetShowItemByIndex(lastIndex)
    if chapterItemCom then
      chapterItemCom:ChangeItemChoose(false)
    else
      local chapterItemData = self.m_chapterItemListData[LevelManager.MainLevelSubType.MainStory][lastIndex]
      if chapterItemData then
        chapterItemData.isChoose = false
      end
    end
  end
  self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex = itemIndex
  if itemIndex then
    local curChapterItemCom = self.m_luaNormalChapterGrid:GetShowItemByIndex(itemIndex)
    if curChapterItemCom then
      curChapterItemCom:ChangeItemChoose(true)
    else
      local chapterItemData = self.m_chapterItemListData[LevelManager.MainLevelSubType.MainStory][itemIndex]
      if chapterItemData then
        chapterItemData.isChoose = true
      end
    end
  end
  self:CheckFreshShowChapterInfo()
  self:CheckFreshShowNextLevelInfo()
  if not isNotShowCloudAnim then
    self:StartLockAndShowCloud()
  end
  self:FreshShowNormalLevelList(function()
    self:CheckMoveProgressChapterLevelPos()
    if not isNotShowCloudAnim then
      self:WaitMoveAndUnlock()
    end
    if backFun then
      backFun()
    end
  end)
end

function Form_LevelMain:FreshChangeHardChapterChoose(itemIndex, isNotShowCloudAnim, backFun)
  if not itemIndex then
    return
  end
  local lastIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  if lastIndex then
    local chapterItemCom = self.m_luaHardChapterGrid:GetShowItemByIndex(lastIndex)
    if chapterItemCom then
      chapterItemCom:ChangeItemChoose(false)
    else
      local chapterItemData = self.m_chapterItemListData[LevelManager.MainLevelSubType.HardLevel][lastIndex]
      if chapterItemData then
        chapterItemData.isChoose = false
      end
    end
  end
  self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex = itemIndex
  if itemIndex then
    local curChapterItemCom = self.m_luaHardChapterGrid:GetShowItemByIndex(itemIndex)
    if curChapterItemCom then
      curChapterItemCom:ChangeItemChoose(true)
    else
      local chapterItemData = self.m_chapterItemListData[LevelManager.MainLevelSubType.HardLevel][itemIndex]
      if chapterItemData then
        chapterItemData.isChoose = true
      end
    end
  end
  self:CheckFreshShowChapterInfo()
  self:CheckFreshShowNextLevelInfo()
  if not isNotShowCloudAnim then
    self:StartLockAndShowCloud()
  end
  self:FreshShowHardLevelList(function()
    self:CheckMoveProgressChapterLevelPos()
    if not isNotShowCloudAnim then
      self:WaitMoveAndUnlock()
    end
    if backFun then
      backFun()
    end
  end)
end

function Form_LevelMain:CheckShowHardEfx()
  if self.m_levelMainHelper:IsLevelSubTypeUnlock(LevelManager.MainLevelSubType.HardLevel) ~= true then
    self.m_fx_btn_hard:SetActive(false)
    return
  end
  local nextLevelInfo = self.m_levelMainHelper:GetNextShowLevelCfg(LevelManager.MainLevelSubType.HardLevel)
  if nextLevelInfo then
    local m_curBattleWorldCfg = ConfigManager:GetBattleWorldCfgById(nextLevelInfo.m_MapID)
    local enemy_power = m_curBattleWorldCfg.m_FightValue
    local role_power = HeroManager:GetTopFiveHeroPower()
    if enemy_power <= role_power then
      self.m_fx_btn_hard:SetActive(true)
    else
      self.m_fx_btn_hard:SetActive(false)
    end
  else
    self.m_fx_btn_hard:SetActive(false)
  end
end

function Form_LevelMain:CheckInitCameraAnim()
  if self.m_levelMapManager then
    if self.m_curDetailLevelID then
      self:FreshChangeLevelNodeChoose(self.m_curDetailLevelID, self.m_curDetailLevelID ~= nil)
      self.m_levelMapManager:SetDetailCameraPosByLevelID(self.m_curDetailLevelID or 0)
    elseif self.m_curShowNextLevelInfo then
      local levelID = self.m_curShowNextLevelInfo.m_LevelID
      self.m_levelMapManager:SetDetailCameraPosByLevelID(levelID or 0)
    end
    self.m_levelMapManager:ChangeCameraToDetail()
    self.m_levelMapManager:StartCameraAnim()
    self:WaitMoveAndUnlock(handler(self, self.SetEnterAnimEndFun))
  end
  self:CheckShowNewChapterOrLevel()
end

function Form_LevelMain:SetEnterAnimEndFun()
  self.m_isEnterAnimEnd = true
end

function Form_LevelMain:CheckShowNewChapterOrLevel()
  local newUnlockChapterData = self.m_levelMainHelper:GetTopPassChangeChapter()
  if not newUnlockChapterData then
    self:CheckShowNewLevelUnlock(function()
      self:CheckChapterResourceDownload(function()
        MainExploreManager:CheckPushNewClueTips()
      end)
    end)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_LEVELNEWCHAPTER, {
    lastChapterID = newUnlockChapterData.lastChapterID,
    newChapterID = newUnlockChapterData.newChapterID,
    closeBackFun = function()
      self:CheckShowNewChapterOrLevel()
    end
  })
end

function Form_LevelMain:CheckChapterResourceDownload(callback)
  local levelMainHelper = LevelManager:GetLevelMainHelper()
  if not levelMainHelper then
    return
  end
  local chapterCfg = levelMainHelper:GetCurrentLevelCfg(LevelManager.MainLevelSubType.MainStory)
  if not CS.DeviceUtil.IsWIFIConnected() and not GuideManager:GuideIsActive() and chapterCfg and self:CanShowLevelDownloadTriggerTips(chapterCfg.m_ChapterID) then
    self:SetLevelDownloadTriggerTips(chapterCfg.m_ChapterID)
    local _vPackage = {}
    local _vExtraResource = {}
    _vPackage[#_vPackage + 1] = {
      sName = "Pack_MainLevel_" .. chapterCfg.m_ChapterID - 1,
      eType = DownloadManager.ResourcePackageType.Custom
    }
    local _vResourceAB = DownloadManager:GetResourceABList(_vPackage, _vExtraResource)
    local _lSizeTotal = DownloadManager:GetResourceABListTotalBytes(_vResourceAB)
    local _lSizeDownloaded = DownloadManager:GetResourceABListDownloadedBytes(_vResourceAB)
    if _lSizeTotal - _lSizeDownloaded <= 0 or DownloadManager.m_hasSetTips then
      if callback then
        callback()
      end
      return
    end
    DownloadManager.m_hasSetTips = true
    utils.CheckAndPushCommonTips({
      tipsID = 9963,
      fContentCB = function(sContent)
        local sContentNew = string.customizereplace(sContent, {"{size}"}, DownloadManager:GetDownloadSizeStr(_lSizeTotal - _lSizeDownloaded))
        return sContentNew
      end,
      bLockBack = true,
      func1 = function()
        DownloadManager:DownloadResource(_vPackage, _vExtraResource, "Pack_MainLevel_" .. chapterCfg.m_ChapterID - 1, nil, nil, nil, 99, DownloadManager.NetworkStatus.Mobile)
        if callback then
          callback()
        end
      end,
      func2 = function()
        if callback then
          callback()
        end
      end
    })
  elseif callback then
    callback()
  end
end

function Form_LevelMain:CanShowLevelDownloadTriggerTips(iCurChapterID)
  if self.m_iLevelDownloadTriggerTipsTime == nil then
    local str = LocalDataManager:GetStringSimple("LevelDownloadTriggerTips", "")
    if str == "" then
      return true
    end
    local vStr = string.split(str, "_")
    self.m_iLevelDownloadTriggerTipsTime = tonumber(vStr[1])
    self.m_iLevelDownloadChapterID = tonumber(vStr[2])
  end
  local iTimeCur = TimeUtil:GetServerTimeS()
  return iTimeCur >= self.m_iLevelDownloadTriggerTipsTime or iCurChapterID > self.m_iLevelDownloadChapterID
end

function Form_LevelMain:SetLevelDownloadTriggerTips(iCurChapterID)
  local iTimeNextDay = TimeUtil:GetServerNextCommonResetTime()
  self.m_iLevelDownloadTriggerTipsTime = iTimeNextDay
  self.m_iLevelDownloadChapterID = LevelManager.MainLevelSubType.MainStory
  LocalDataManager:SetStringSimple("LevelDownloadTriggerTips", iTimeNextDay .. "_" .. iCurChapterID)
end

function Form_LevelMain:CheckShowNewLevelUnlock(endBackFun)
  if not self.m_paramIsCheckNewUnlock then
    if endBackFun then
      endBackFun()
    end
    return
  end
  local newUnlockLevelData = self.m_levelMainHelper:GetPassChangeLevel()
  if not newUnlockLevelData then
    if endBackFun then
      endBackFun()
    end
    return
  end
  if self.m_unlockLevelTimer then
    TimeService:KillTimer(self.m_unlockLevelTimer)
    self.m_unlockLevelTimer = nil
  end
  local lastLevelID = newUnlockLevelData.lastLevelID
  local newLevelID = newUnlockLevelData.newLevelID
  local playUnlockAnimLen = 0
  if self.m_levelMapManager then
    playUnlockAnimLen = self.m_levelMapManager:CheckResetUnlockLevelToAnimStart(newLevelID, lastLevelID)
  end
  self.m_unlockLevelTimer = TimeService:SetTimer(self.m_uiVariables.UnlockLevelAnimWaiteTime, 1, function()
    if self.m_levelMapManager then
      self.m_levelMapManager:CheckPlayUnlockLevelAnim(newLevelID, lastLevelID)
    end
    self.m_unlockLevelTimer = nil
  end)
  self:CheckUnlockNewLevel()
  self.m_newLevelLockerID = UILockIns:Lock(self.m_uiVariables.UnlockLevelAnimWaiteTime + playUnlockAnimLen)
  if self.m_unlockLevelEndTimer then
    TimeService:KillTimer(self.m_unlockLevelEndTimer)
    self.m_unlockLevelEndTimer = nil
  end
  self.m_unlockLevelEndTimer = TimeService:SetTimer(self.m_uiVariables.UnlockLevelAnimWaiteTime + playUnlockAnimLen, 1, function()
    if endBackFun then
      endBackFun()
    end
    self.m_unlockLevelEndTimer = nil
  end)
end

function Form_LevelMain:FreshChapterTaskShow(chapterID)
  if not chapterID then
    return
  end
  local openFlag, _ = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.ChapterReward)
  self.m_showChapterTaskDataList = self.m_levelMainHelper:GetChapterProgressTaskList(chapterID)
  if openFlag ~= true or self.m_showChapterTaskDataList == nil or next(self.m_showChapterTaskDataList) == nil then
    UILuaHelper.SetActive(self.m_btn_Reward, false)
    self:ChangeChapterTaskRewardPanelShow(false, true)
  else
    UILuaHelper.SetActive(self.m_btn_Reward, true)
    self:FreshChapterTaskProgress()
    self:FreshChapterTaskList()
    self:CheckFreshChapterTaskRedDot(chapterID)
  end
end

function Form_LevelMain:FreshChapterTaskProgress()
  if not self.m_curShowLevelSubType then
    return
  end
  local chapterItemList = self.m_chapterItemListData[self.m_curShowLevelSubType]
  if not chapterItemList or not next(chapterItemList) then
    return
  end
  local curShowChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  local curChapterItemData = chapterItemList[curShowChapterIndex]
  if not curChapterItemData then
    return
  end
  local haveProcessNum, levelTotalNum = self.m_levelMainHelper:GetChapterProgress(curChapterItemData.chapterData)
  local rateNum = haveProcessNum / levelTotalNum
  if 1 < rateNum then
    rateNum = 1
  end
  local percentNum = math_floor(rateNum * 100)
  local percentStr = percentNum .. "%"
  self.m_txt_chapter_progress_Text.text = percentStr
  self.m_txt_point_now_Text.text = percentStr
  self.m_reward_bar_Slider.value = rateNum
  self.m_bar_reward_Image.fillAmount = rateNum
end

function Form_LevelMain:FreshChapterTaskList()
  if self.m_showChapterTaskDataList == nil or next(self.m_showChapterTaskDataList) == nil then
    return
  end
  local itemList = self.m_chapterTaskItemList
  local dataLen = #self.m_showChapterTaskDataList
  local parentTrans = self.m_chapter_reward_list
  local childCount = #itemList
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local item = itemList[i]
      local itemData = self.m_showChapterTaskDataList[i]
      self:FreshChapterTaskItemData(item, itemData)
      UILuaHelper.SetActive(item.root, true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_chapter_task_base_item, parentTrans.transform).gameObject
      local item = self:InitChapterTaskItem(itemObj, i)
      local itemData = self.m_showChapterTaskDataList[i]
      self:FreshChapterTaskItemData(item, itemData)
      itemList[#itemList + 1] = item
      UILuaHelper.SetActive(item.root, true)
    elseif i <= childCount and i > dataLen then
      local item = itemList[i]
      item.itemData = nil
      UILuaHelper.SetActive(item.root, false)
    end
  end
end

function Form_LevelMain:InitChapterTaskItem(itemObj, index)
  if not itemObj then
    return
  end
  local itemTrans = itemObj.transform
  local node_have_receive = itemTrans:Find("m_chapter_task_have_receive")
  local node_can_receive = itemTrans:Find("m_chapter_task_can_receive")
  local node_cannot_receive = itemTrans:Find("m_chapter_task_cannot_receive")
  local txt_chapter_task_num = itemTrans:Find("m_txt_chapter_task_num"):GetComponent(T_TextMeshProUGUI)
  local node_reward_pop_root = itemTrans:Find("m_reward_pop_root")
  local itemButton = itemTrans:GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(self, itemButton, function()
    self:OnChapterTaskItemClk(index)
  end)
  local item = {
    itemData = nil,
    root = itemTrans,
    node_have_receive = node_have_receive,
    node_can_receive = node_can_receive,
    node_cannot_receive = node_cannot_receive,
    txt_chapter_task_num = txt_chapter_task_num,
    node_reward_pop_root = node_reward_pop_root
  }
  return item
end

function Form_LevelMain:FreshChapterTaskItemData(item, itemData)
  if not item then
    return
  end
  if not itemData then
    return
  end
  item.itemData = itemData
  local progressNum = math_floor(itemData.cfg.m_ObjectiveCount / 100)
  item.txt_chapter_task_num.text = progressNum .. "%"
  local taskState = itemData.serverData.iState
  UILuaHelper.SetActive(item.node_have_receive, taskState == TaskManager.TaskState.Completed)
  UILuaHelper.SetActive(item.node_can_receive, taskState == TaskManager.TaskState.Finish)
  UILuaHelper.SetActive(item.node_cannot_receive, taskState == TaskManager.TaskState.Doing)
end

function Form_LevelMain:ChangeChapterTaskRewardPanelShow(isShow, isNoAnim)
  if isNoAnim then
    self:FreshChapterTaskPanelShow(isShow)
    return
  end
  if not isShow then
    if self.m_chapterTaskPanelOutTimer ~= nil then
      return
    end
    local outLen = UILuaHelper.GetAnimationLengthByName(self.m_chapter_task_panel, ChapterTaskOutAnim)
    UILuaHelper.PlayAnimationByName(self.m_chapter_task_panel, ChapterTaskOutAnim)
    self.m_chapterTaskPanelOutTimer = TimeService:SetTimer(outLen, 1, function()
      self:FreshChapterTaskPanelShow(isShow)
      self.m_chapterTaskPanelOutTimer = nil
    end)
  else
    self:FreshChapterTaskPanelShow(isShow)
  end
end

function Form_LevelMain:FreshChapterTaskPanelShow(isShow)
  if isShow then
    UILuaHelper.SetActive(self.m_chapter_task_panel, true)
  else
    UILuaHelper.SetActive(self.m_chapter_task_panel, false)
    self:FreshShowChapterTaskRewardTips(false)
  end
  self.m_isShowChapterTaskPanel = isShow
end

function Form_LevelMain:FreshChapterTaskRewardPopItemList(chapterTaskIndex)
  if not chapterTaskIndex then
    return
  end
  local chapterTaskItem = self.m_chapterTaskItemList[chapterTaskIndex]
  if not chapterTaskItem then
    return
  end
  local chapterItemData = chapterTaskItem.itemData
  local rewardArray = chapterItemData.cfg.m_Reward
  if not rewardArray then
    return
  end
  if not rewardArray or rewardArray.Length <= 0 then
    return
  end
  UILuaHelper.SetParent(self.m_reward_pop_node, chapterTaskItem.node_reward_pop_root, true)
  self.m_curShowChapterTaskIndex = chapterTaskIndex
  local itemWidgets = self.m_ItemWidgetList
  local dataLen = rewardArray.Length
  local parentTrans = self.m_reward_pop_node
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
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_baseRewardItem, parentTrans.transform).gameObject
      itemObj.name = self.m_rewardItemBase.name .. i
      local itemWidget = self:createCommonItem(itemObj)
      local itemArray = rewardArray[i - 1]
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = tonumber(itemArray[0]),
        iNum = tonumber(itemArray[1])
      })
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnChapterTaskRewardItemClk(itemID, itemNum, itemCom)
      end)
      itemWidgets[#itemWidgets + 1] = itemWidget
      itemWidget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
end

function Form_LevelMain:FreshShowChapterTaskRewardTips(isShow)
  UILuaHelper.SetActive(self.m_reward_pop_node, isShow)
  self.m_isShowChapterTaskRewardPop = isShow
end

function Form_LevelMain:AfterChangeToMainCity()
  self:CheckUnLock()
  self.m_levelMapManager = nil
end

function Form_LevelMain:OnNormalChapterItemClick(itemIndex)
  if not itemIndex then
    return
  end
  if self.m_curShowLevelSubType ~= LevelManager.MainLevelSubType.MainStory then
    return
  end
  if self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex == itemIndex then
    return
  end
  self:FreshChangeNormalChapterChoose(itemIndex)
end

function Form_LevelMain:OnHardChapterItemClick(itemIndex)
  if not itemIndex then
    return
  end
  if self.m_curShowLevelSubType ~= LevelManager.MainLevelSubType.HardLevel then
    return
  end
  if self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex == itemIndex then
    return
  end
  self:FreshChangeHardChapterChoose(itemIndex)
end

function Form_LevelMain:OnLevelDetailBgClick()
  if KeyboardMappingManager then
    KeyboardMappingManager:SetSubConfigInValid(self:GetFramePrefabName(), SubPanelManager.SubPanelCfg.LevelDetailSubPanel and SubPanelManager.SubPanelCfg.LevelDetailSubPanel.PrefabPath or "", nil, nil, true)
  end
  if self.m_curDetailLevelID then
    local tempLevelID = self.m_curDetailLevelID
    self.m_curDetailLevelID = nil
    self:FreshLevelDetailShow()
    self:FreshChangeLevelNodeChoose(tempLevelID, self.m_curDetailLevelID ~= nil)
  end
end

function Form_LevelMain:OnLevelItemIconClicked(levelID, chapterID)
  if not levelID then
    return
  end
  if self.m_curDetailLevelID == levelID then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(17)
  self.m_curDetailLevelID = levelID
  self:FreshLevelDetailShow()
  self:FreshChangeLevelNodeChoose(self.m_curDetailLevelID, self.m_curDetailLevelID ~= nil)
end

function Form_LevelMain:OnMainExploreItemClicked(chapterID, clueID)
  if clueID and 0 < clueID then
    MainExploreManager:RqsTakeClueReward(chapterID, clueID)
    return
  end
end

function Form_LevelMain:OnInitTipsItem(go, index)
  local levelID = self.exLevelMapNodeInfoList[index].levelID
  local is_pass = self.m_levelMainHelper:IsLevelHavePass(levelID)
  if is_pass then
    go:SetActive(false)
    return
  end
  local rect = go.transform:Find("rotateNode"):GetComponent("RectTransform")
  local is_show = self.oueScreenMgr:FreshOutTips(rect, index)
  go:SetActive(is_show)
  go.transform.localScale = Vector3.one
  local btn = go:GetComponent("Button")
  btn.onClick:RemoveAllListeners()
  btn.onClick:AddListener(function()
    self.m_levelMapManager:SetDetailCameraPosByLevelID(levelID or 0)
  end)
end

function Form_LevelMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_LEVELMAIN)
  StackFlow:Push(UIDefines.ID_FORM_HALL)
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, PanelOutAnimStr)
  self:CheckUnLock()
  self:CheckUnlockNewLevel()
  self.m_lockerID = UILockIns:Lock(BackTimeNum)
  TimeService:SetTimer(BackTimeNum, 1, function()
    LevelManager:BackMainCityScene(function()
      self:AfterChangeToMainCity()
    end, true)
  end)
end

function Form_LevelMain:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, PanelOutAnimStr)
  self:CheckUnLock()
  self:CheckUnlockNewLevel()
  self.m_lockerID = UILockIns:Lock(BackTimeNum)
  TimeService:SetTimer(BackTimeNum, 1, function()
    LevelManager:BackMainCityScene(function()
      self:AfterChangeToMainCity()
    end, true)
  end)
end

function Form_LevelMain:CheckUnLock()
  if self.m_lockerID and UILockIns:IsValidLocker(self.m_lockerID) then
    UILockIns:Unlock(self.m_lockerID)
  end
  self.m_lockerID = nil
end

function Form_LevelMain:CheckUnlockNewLevel()
  if self.m_newLevelLockerID and UILockIns:IsValidLocker(self.m_newLevelLockerID) then
    UILockIns:Unlock(self.m_newLevelLockerID)
  end
  self.m_newLevelLockerID = nil
end

function Form_LevelMain:OnBtnDegreeClicked()
  local toShowLevelSubType = LevelManager.MainLevelSubType.MainStory
  if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.MainStory then
    toShowLevelSubType = LevelManager.MainLevelSubType.HardLevel
  end
  if toShowLevelSubType == LevelManager.MainLevelSubType.HardLevel and self.m_levelMainHelper:IsLevelSubTypeUnlock(LevelManager.MainLevelSubType.HardLevel) ~= true then
    StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 30009)
    return
  end
  self:FreshChangeDegree(toShowLevelSubType)
end

function Form_LevelMain:OnBtnchapternowClicked()
  if not self.m_curShowLevelSubType then
    return
  end
  self.m_isShowChapterList = true
  self:FreshChapterListPanelShow()
  self:ShowChapterListAnim()
end

function Form_LevelMain:OnBtnchaptercloseClicked()
  if self.m_chapterPanelOutTimer ~= nil then
    return
  end
  local chapterOutLen = UILuaHelper.GetAnimationLengthByName(self.m_chapter_panel, ChapterOutAnim)
  UILuaHelper.PlayAnimationByName(self.m_chapter_panel, ChapterOutAnim)
  self.m_chapterPanelOutTimer = TimeService:SetTimer(chapterOutLen, 1, function()
    self.m_isShowChapterList = false
    self:FreshChapterListPanelShow()
    self.m_chapterPanelOutTimer = nil
  end)
end

function Form_LevelMain:OnBtnchapternextClicked()
  if not self.m_curShowLevelSubType then
    return
  end
  if self.m_chapterChangeTimer then
    TimeService:KillTimer(self.m_chapterChangeTimer)
    self.m_chapterChangeTimer = nil
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_left_down, ChapterChangeNextAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_pnl_left_down, ChapterChangeNextAnimStr)
  self.m_chapterChangeTimer = TimeService:SetTimer(animLen, 1, function()
    local curChooseIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
    local nextChooseIndex = curChooseIndex + 1
    if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.MainStory then
      self:FreshChangeNormalChapterChoose(nextChooseIndex)
    elseif self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
      self:FreshChangeHardChapterChoose(nextChooseIndex)
    end
    self.m_chapterChangeTimer = nil
  end)
end

function Form_LevelMain:OnBtnchapternextlockClicked()
  StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 30011)
end

function Form_LevelMain:OnBtnchapterbeforeClicked()
  if not self.m_curShowLevelSubType then
    return
  end
  if self.m_chapterChangeTimer then
    TimeService:KillTimer(self.m_chapterChangeTimer)
    self.m_chapterChangeTimer = nil
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_left_down, ChapterChangeLastAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_pnl_left_down, ChapterChangeLastAnimStr)
  self.m_chapterChangeTimer = TimeService:SetTimer(animLen, 1, function()
    local curChooseIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
    local nextChooseIndex = curChooseIndex - 1
    if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.MainStory then
      self:FreshChangeNormalChapterChoose(nextChooseIndex)
    elseif self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
      self:FreshChangeHardChapterChoose(nextChooseIndex)
    end
    self.m_chapterChangeTimer = nil
  end)
end

function Form_LevelMain:FreshChooseCurProgressLevel()
  if self.m_curDetailLevelID ~= self.m_curShowNextLevelInfo.m_LevelID then
    self.m_curDetailLevelID = self.m_curShowNextLevelInfo.m_LevelID
    self:FreshLevelDetailShow()
    self:FreshChangeLevelNodeChoose(self.m_curDetailLevelID, self.m_curDetailLevelID ~= nil)
  end
end

function Form_LevelMain:OnBtnnextstageClicked()
  if not self.m_curShowLevelSubType then
    return
  end
  if not self.m_curShowNextLevelInfo then
    return
  end
  local curProgressChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].progressChapterIndex
  local curChooseChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  if curChooseChapterIndex ~= curProgressChapterIndex then
    if self.m_curShowLevelSubType == LevelManager.MainLevelSubType.MainStory then
      self:FreshChangeNormalChapterChoose(curProgressChapterIndex, false, function()
        self:FreshChooseCurProgressLevel()
      end)
    elseif self.m_curShowLevelSubType == LevelManager.MainLevelSubType.HardLevel then
      self:FreshChangeHardChapterChoose(curProgressChapterIndex, false, function()
        self:FreshChooseCurProgressLevel()
      end)
    end
  else
    self:FreshChooseCurProgressLevel()
  end
end

function Form_LevelMain:OnBtnRewardClicked()
  local isShow = not self.m_isShowChapterTaskPanel
  self:ChangeChapterTaskRewardPanelShow(isShow, false)
end

function Form_LevelMain:OnBtnChapterTaskCloseClicked()
  self:ChangeChapterTaskRewardPanelShow(false, false)
end

function Form_LevelMain:OnChapterTaskItemClk(chapterTaskIndex)
  if not chapterTaskIndex then
    return
  end
  local chapterTaskData = self.m_showChapterTaskDataList[chapterTaskIndex]
  if not chapterTaskData then
    return
  end
  local serverData = chapterTaskData.serverData
  if not serverData then
    return
  end
  local state = serverData.iState
  if state == TaskManager.TaskState.Finish then
    TaskManager:ReqTakeReward(TaskManager.TaskType.ChapterProgress, serverData.iId)
  else
    if self.m_curShowChapterTaskIndex ~= chapterTaskIndex then
      self:FreshChapterTaskRewardPopItemList(chapterTaskIndex)
    end
    local isShow = not self.m_isShowChapterTaskRewardPop
    self:FreshShowChapterTaskRewardTips(isShow)
  end
end

function Form_LevelMain:OnChapterTaskRewardItemClk(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_LevelMain:OnBtnexploreClicked()
  if not self.m_curShowLevelSubType then
    return
  end
  local chapterItemList = self.m_chapterItemListData[self.m_curShowLevelSubType]
  if not chapterItemList or not next(chapterItemList) then
    return
  end
  local curShowChapterIndex = self.m_ShowDegreeData[self.m_curShowLevelSubType].curShowChapterIndex
  local curChapterItemData = chapterItemList[curShowChapterIndex]
  if not curChapterItemData then
    return
  end
  local chapterID = curChapterItemData.chapterData.chapterCfg.m_ChapterID
  StackFlow:Push(UIDefines.ID_FORM_MAINEXPLORESTORY, {
    chapterID = chapterID,
    call_back = function()
      self:FreshMainExplore(chapterID)
    end
  })
end

function Form_LevelMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LevelMain", Form_LevelMain)
return Form_LevelMain
