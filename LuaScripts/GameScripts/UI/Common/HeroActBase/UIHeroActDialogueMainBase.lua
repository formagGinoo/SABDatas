local UIHeroActDialogueMainBase = class("UIHeroActDialogueMainBase", require("UI/Common/UIBase"))
local HeroActivityManager = _ENV.HeroActivityManager
local LevelHeroLamiaActivityManager = _ENV.LevelHeroLamiaActivityManager
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree

function UIHeroActDialogueMainBase:AfterInit()
  UIHeroActDialogueMainBase.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1117)
  self.m_activityID = nil
  self.m_intoModel = nil
  self.m_luaDetailLevel = nil
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.m_isHarLock = nil
  self.m_lockTips = nil
  self.m_chooseItemComList = nil
  local normalInitData = {
    itemClkBackFun = handler(self, self.OnNormalItemClick)
  }
  local hardInitData = {
    itemClkBackFun = handler(self, self.OnHardItemClick)
  }
  self.DegreeCfgTab = {
    [LevelDegree.Normal] = {
      nodeSelect = self.m_normal_select,
      bgNode = self.m_bg_nml,
      extensionChooseBg = self.m_img_masktop_nml,
      nodeUnSelect = self.m_normal_unselect,
      activitySubID = nil,
      activitySubType = HeroActivityManager.SubActTypeEnum.NormalLevel,
      activitySubIndex = 1,
      levelList = nil,
      currentID = nil,
      itemComponents = nil,
      pageIndex = nil,
      initData = normalInitData,
      starNodeList = {},
      maxPageNum = nil
    },
    [LevelDegree.Hard] = {
      nodeSelect = self.m_hard_select,
      bgNode = self.m_hard_bg,
      extensionChooseBg = self.m_img_masktop_hard,
      nodeUnSelect = self.m_hard_unselect,
      activitySubID = nil,
      activitySubType = HeroActivityManager.SubActTypeEnum.DiffLevel,
      activitySubIndex = 1,
      levelList = nil,
      currentID = nil,
      itemComponents = nil,
      pageIndex = nil,
      initData = hardInitData,
      starNodeList = {},
      maxPageNum = nil
    }
  }
end

function UIHeroActDialogueMainBase:OnActive()
  UIHeroActDialogueMainBase.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  self:RegisterRedDot()
  self.openTime = TimeUtil:GetServerTimeS()
  self.report_name = self.m_activityID .. "/" .. self:GetFramePrefabName()
  HeroActivityManager:ReportActOpen(self.report_name, {
    openTime = self.openTime
  })
end

function UIHeroActDialogueMainBase:OnInactive()
  UIHeroActDialogueMainBase.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:UnRegisterAllRedDotItem()
  HeroActivityManager:ReportActClose(self.report_name, {
    openTime = self.openTime
  })
end

function UIHeroActDialogueMainBase:OnDestroy()
  UIHeroActDialogueMainBase.super.OnDestroy(self)
  self:ClearCacheData()
  self:UnRegisterAllRedDotItem()
end

function UIHeroActDialogueMainBase:ClearCacheData()
  self.m_activityID = nil
  self.m_curDegreeIndex = nil
  self.m_curDetailLevelID = nil
end

function UIHeroActDialogueMainBase:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_hard_red_dot, RedDotDefine.ModuleType.HeroActActivityEntry, self.DegreeCfgTab[LevelDegree.Hard].activitySubID)
  if not utils.isNull(self.m_task_red_dot) then
    self:RegisterOrUpdateRedDotItem(self.m_task_red_dot, RedDotDefine.ModuleType.HeroActTaskEntry, self.m_activityID)
  end
  self:RegisterOrUpdateRedDotItem(self.m_recount_red_dot, RedDotDefine.ModuleType.HeroActMemoryEntry, self.m_activityID)
  if not utils.isNull(self.m_store_redpoint) then
    self:RegisterOrUpdateRedDotItem(self.m_store_redpoint, RedDotDefine.ModuleType.HeroActShopEntry, self.m_activityID)
  end
end

function UIHeroActDialogueMainBase:AddEventListeners()
  self:addEventListener("eGameEvent_Level_Lamia_Sweep", handler(self, self.OnEventLamiaSweep))
  self:addEventListener("eGameEvent_HeroAct_DailyReset", handler(self, self.OnHeroActDailyReset))
  self:addEventListener("eGameEvent_Level_Lamia_StageFresh", handler(self, self.OnFreshLamiaStageFresh))
  self:addEventListener("eGameEvent_RefreshShopData", handler(self, self.OnEventShopRefresh))
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:AddEventListeners()
  end
end

function UIHeroActDialogueMainBase:OnHeroActDailyReset()
  if not self.m_activityID then
    return
  end
  local isOpen = HeroActivityManager:IsSubActIsOpenByID(self.m_activityID, self.DegreeCfgTab[LevelDegree.Hard].activitySubID)
  if isOpen ~= true then
    self:ClearCacheData()
    self:CloseForm()
    return
  end
  self:FreshFreeNums()
  self:FreshHardLockStatus()
end

function UIHeroActDialogueMainBase:GetHardLevelUnlockStr()
  local hardSubActID = self.DegreeCfgTab[LevelDegree.Hard].activitySubID
  local activitySubInfoCfg = HeroActivityManager:GetSubInfoByID(hardSubActID)
  if not activitySubInfoCfg then
    return
  end
  local unlockTypeList = utils.changeCSArrayToLuaTable(activitySubInfoCfg.m_UnlockType)
  local unlockDataList = utils.changeCSArrayToLuaTable(activitySubInfoCfg.m_UnlockData)
  if unlockTypeList == nil or next(unlockTypeList) == nil then
    return
  end
  local unlockStr = ""
  for i, type in ipairs(unlockTypeList) do
    if type == HeroActivityManager.SubActUnlockType.ActLamiaLevel then
      local levelID = unlockDataList[i][1]
      if levelID then
        unlockStr = self.m_levelHelper:GetLevelUnlockNameStr(tonumber(levelID)) or ""
        break
      end
    end
  end
  return unlockStr
end

function UIHeroActDialogueMainBase:GetHardTimeUnlockStr()
  local hardSubActID = self.DegreeCfgTab[LevelDegree.Hard].activitySubID
  local activitySubInfoCfg = HeroActivityManager:GetSubInfoByID(hardSubActID)
  if not activitySubInfoCfg then
    return
  end
  local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.sub, hardSubActID)
  if is_corved then
    return TimeUtil:TimerToString3(t1)
  end
  return activitySubInfoCfg.m_OpenTime
end

function UIHeroActDialogueMainBase:GetChooseIndex()
  local degreeCfgTab = self.DegreeCfgTab[LevelDegree.Normal]
  if not degreeCfgTab then
    return
  end
  local levelList = degreeCfgTab.levelList
  if not levelList then
    return
  end
  local lastLevelData = levelList[#levelList]
  if not lastLevelData then
    return
  end
  local lastLeveCfg = lastLevelData.levelCfg
  if not lastLeveCfg then
    return
  end
  if not self.m_isHarLock and self.m_levelHelper:IsLevelHavePass(lastLeveCfg.m_LevelID) == true then
    return LevelDegree.Hard
  end
end

function UIHeroActDialogueMainBase:RemoveAllEventListeners()
  if self.m_luaDetailLevel then
    self.m_luaDetailLevel:RemoveAllEventListeners()
  end
  self:clearEventListener()
end

function UIHeroActDialogueMainBase:OnEventLamiaSweep(param)
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_VICTORY, {
    levelType = LevelHeroLamiaActivityManager.LevelType.Lamia,
    activityID = param.activityID,
    levelID = param.levelID,
    rewardData = param.reward,
    extraReward = param.extraReward,
    isSweep = true
  })
  self:FreshFreeNums()
end

function UIHeroActDialogueMainBase:OnFreshLamiaStageFresh()
  if not self.m_activityID then
    return
  end
  self:FreshFreeNums()
end

function UIHeroActDialogueMainBase:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_activityID = tonumber(tParam.main_id)
    self.m_intoModel = tonumber(tParam.model)
    self.m_csui.m_param = nil
  end
end

function UIHeroActDialogueMainBase:FreshUI()
  self:FreshDegreeSubActivityID()
  self:FreshHardLockStatus()
  self.m_curDetailLevelID = nil
  self:FreshLevelDetailShow()
  self:FreshFreeNums()
  self:CheckPopUpLastPassSpecialReward()
end

function UIHeroActDialogueMainBase:CheckPopUpLastPassSpecialReward()
  local lastPassSpecialRewardLevelID = self.m_levelHelper:CheckPopUpLastSpecialRewardLevel()
  if not lastPassSpecialRewardLevelID then
    return
  end
  local lastPassLevelCfg = self.m_levelHelper:GetLevelCfgByID(lastPassSpecialRewardLevelID)
  if not lastPassLevelCfg then
    return
  end
  local specialArray = lastPassLevelCfg.m_Special
  local specialRewardItemID = specialArray[0]
  StackPopup:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITEM, {
    item_id = specialRewardItemID,
    backFun = handler(self, self.CheckPopUpLastPassSpecialReward)
  })
end

function UIHeroActDialogueMainBase:FreshFreeNums()
  local totalFreeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ActLamiaPassDailyLimit") or 0)
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_activityID)
  if not mainActInfoCfg then
    log.error("UIHeroActDialogueMainBase:FreshFreeNums error! mainActInfoCfg = " .. tostring(mainActInfoCfg))
    return
  end
  local costItemID = mainActInfoCfg.m_PassItem
  local itemNum = ItemManager:GetItemNum(costItemID)
  self.m_txt_consume_num_Text.text = itemNum
  local freeItemId = mainActInfoCfg.m_FreePassItem
  local freeitemNum = ItemManager:GetItemNum(freeItemId) or 0
  if not utils.isNull(self.m_txt_consume_numadd_Text) then
    self.m_txt_consume_numadd_Text.text = freeitemNum .. "/" .. totalFreeNum
  end
end

function UIHeroActDialogueMainBase:FreshShopEnterItem()
end

function UIHeroActDialogueMainBase:FreshLevelTab(index)
  self:CloseAllDegreeNode(index)
  if index then
    self.m_curDegreeIndex = index
    local curDegreeData = self.DegreeCfgTab[index]
    UILuaHelper.SetActive(curDegreeData.nodeSelect, true)
    UILuaHelper.SetActive(curDegreeData.nodeUnSelect, false)
    UILuaHelper.SetActive(curDegreeData.bgNode, true)
    if curDegreeData.extensionChooseBg then
      UILuaHelper.SetActive(curDegreeData.extensionChooseBg, true)
    end
  end
end

function UIHeroActDialogueMainBase:CloseAllDegreeNode(ignoreIndex)
  for i, v in ipairs(self.DegreeCfgTab) do
    if ignoreIndex ~= i then
      UILuaHelper.SetActive(v.nodeUnSelect, true)
      UILuaHelper.SetActive(v.nodeSelect, false)
      UILuaHelper.SetActive(v.bgNode, false)
      if v.extensionChooseBg then
        UILuaHelper.SetActive(v.extensionChooseBg, false)
      end
    end
  end
end

function UIHeroActDialogueMainBase:FreshDegreeSubActivityID()
  for _, v in ipairs(self.DegreeCfgTab) do
    local subActivityID = HeroActivityManager:GetSubFuncID(self.m_activityID, v.activitySubType, v.activitySubIndex)
    v.activitySubID = subActivityID
  end
end

function UIHeroActDialogueMainBase:FreshHardLockStatus()
  local subActivityID = self.DegreeCfgTab[LevelDegree.Hard].activitySubID
  local isOpen = HeroActivityManager:IsSubActIsOpenByID(self.m_activityID, subActivityID)
  if not utils.isNull(self.m_txt_locktime) then
    if not isOpen then
      local isInTime = HeroActivityManager:IsSubActInOpenTime(subActivityID)
      UILuaHelper.SetActive(self.m_txt_locktime, not isInTime)
      UILuaHelper.SetActive(self.m_txt_lock_condition, isInTime)
      if isInTime then
        self.m_txt_lock_condition_Text.text = self:GetHardLevelUnlockStr()
      else
        self.m_txt_locktime_Text.text = self:GetHardTimeUnlockStr()
      end
    else
      UILuaHelper.SetActive(self.m_txt_locktime, false)
      UILuaHelper.SetActive(self.m_txt_lock_condition, false)
    end
  end
  UILuaHelper.SetActive(self.m_hard_lock, not isOpen)
  self.m_isHarLock = not isOpen
  local flag = LocalDataManager:GetIntSimple("HeroActDialogueMainHardEntry" .. self.m_activityID, 0) == 0
  self.m_hard_new:SetActive(flag)
end

function UIHeroActDialogueMainBase:FreshLevelDetailShow()
end

function UIHeroActDialogueMainBase:OnBackClk()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.m_activityID
  })
  self:ClearCacheData()
  self:CloseForm()
end

function UIHeroActDialogueMainBase:OnBtntaskClicked()
  if not self.m_activityID then
    return
  end
  HeroActivityManager:GotoHeroActivity({
    main_id = self.m_activityID,
    sub_id = HeroActivityManager:GetSubFuncID(self.m_activityID, HeroActivityManager.SubActTypeEnum.Task)
  })
end

function UIHeroActDialogueMainBase:OnBtnrecountClicked()
  if not self.m_activityID then
    return
  end
  HeroActivityManager:GotoHeroActivity({
    main_id = self.m_activityID,
    sub_id = HeroActivityManager:GetSubFuncID(self.m_activityID, HeroActivityManager.SubActTypeEnum.MiniGame)
  })
end

function UIHeroActDialogueMainBase:OnEventShopRefresh()
  local config = HeroActivityManager:GetMainInfoByActID(self.m_activityID)
  if not self.m_activityID then
    return
  end
  if not config then
    log.error("UIHeroActDialogueMainBase:OnEventShopRefresh error! config = " .. tostring(config))
    return
  end
  if self.bIsWaitingShopData then
    QuickOpenFuncUtil:OpenFunc(config.m_ShopJumpID)
    self.bIsWaitingShopData = false
  end
end

function UIHeroActDialogueMainBase:OnBtnshopClicked()
  if not self.m_activityID then
    return
  end
  local config = HeroActivityManager:GetMainInfoByActID(self.m_activityID)
  if not config then
    return
  end
  local jumpIns = ConfigManager:GetConfigInsByName("Jump")
  local jump_item = jumpIns:GetValue_ByJumpID(config.m_ShopJumpID)
  local windowId = jump_item.m_Param.Length > 0 and tonumber(jump_item.m_Param[0]) or 0
  local shop_list = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Activity)
  local shop_id
  for i, v in ipairs(shop_list) do
    if v.m_WindowID == windowId then
      shop_id = v.m_ShopID
    end
  end
  local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
    id = self.m_activityID,
    shop_id = shop_id
  })
  if is_corved and not TimeUtil:IsInTime(t1, t2) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
    return
  end
  self.bIsWaitingShopData = true
  ShopManager:ReqGetShopData(shop_id)
end

function UIHeroActDialogueMainBase:OnIconshopClicked()
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_activityID)
  if not mainActInfoCfg then
    return
  end
  local itemID = mainActInfoCfg.m_ShopItem
  local itemNum = ItemManager:GetItemNum(itemID)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function UIHeroActDialogueMainBase:OnLevelDetailBgClick()
  if self.m_curDetailLevelID then
    self.m_curDetailLevelID = nil
    self:FreshLevelDetailShow()
  end
end

function UIHeroActDialogueMainBase:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  if tParam.main_id then
    local act_id = tParam.main_id
    local subActivityID = HeroActivityManager:GetSubFuncID(act_id, HeroActivityManager.SubActTypeEnum.NormalLevel)
    local subActivityInfoCfg = HeroActivityManager:GetSubInfoByID(subActivityID)
    if subActivityInfoCfg then
      local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(subActivityInfoCfg.m_SubPrefab)
      if vPackageSub ~= nil then
        for m = 1, #vPackageSub do
          vPackage[#vPackage + 1] = vPackageSub[m]
        end
      end
      if vResourceExtraSub ~= nil then
        for n = 1, #vResourceExtraSub do
          vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[n]
        end
      end
    end
  end
  return vPackage, vResourceExtra
end

function UIHeroActDialogueMainBase:IsFullScreen()
  return true
end

return UIHeroActDialogueMainBase
