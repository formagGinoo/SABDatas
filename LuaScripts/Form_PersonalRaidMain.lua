local Form_PersonalRaidMain = class("Form_PersonalRaidMain", require("UI/UIFrames/Form_PersonalRaidMainUI"))
local PVP_NEW_RANK_PAGE_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewRankPagecnt")) or 0
local STAGE_NUM = 8

function Form_PersonalRaidMain:SetInitParam(param)
end

function Form_PersonalRaidMain:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1141)
  local cfgList = self:GenerateData()
  local stageNum = table.getn(cfgList) == 0 and STAGE_NUM or table.getn(cfgList)
  self.m_stageObjList = {}
  self.m_personalraidmain_item:SetActive(false)
  for i = 1, stageNum do
    local cloneObj = ResourceUtil:CreateItem(self.m_personalraidmain_item, self.m_boss_level_pnl.transform)
    local textLevel = cloneObj.transform:Find("btn_incident/m_txt_levelnum"):GetComponent(T_TextMeshProUGUI)
    local selObj = cloneObj.transform:Find("btn_incident/m_bg_sel").gameObject
    local pnlLock = cloneObj.transform:Find("btn_incident/m_pnl_lock").gameObject
    local bgNml = cloneObj.transform:Find("btn_incident/m_bg_nml").gameObject
    local selHardObj = cloneObj.transform:Find("btn_incident/m_bg_selhard").gameObject
    local pnlLockHard = cloneObj.transform:Find("btn_incident/m_pnl_lockhard").gameObject
    local bgNmlHard = cloneObj.transform:Find("btn_incident/m_bg_nmlhard").gameObject
    local btn_incident = cloneObj.transform:Find("btn_incident"):GetComponent(T_Button)
    btn_incident.onClick:RemoveAllListeners()
    btn_incident.onClick:AddListener(function()
      self:OnSelectStageClicked(i)
    end)
    self.m_stageObjList[#self.m_stageObjList + 1] = {
      obj = cloneObj,
      textLevel = textLevel,
      selObj = selObj,
      pnlLock = pnlLock,
      bgNml = bgNml,
      selHardObj = selHardObj,
      pnlLockHard = pnlLockHard,
      bgNmlHard = bgNmlHard
    }
  end
  self.m_rewardObjParent = self.m_scroll_reward:GetComponent("ScrollRect").content
  self.m_rewardItemsTemplate = self.m_scroll_reward:GetComponent("ScrollRect").content.transform:Find("c_common_item").gameObject
  self.m_rewardItemsTemplate:SetActive(false)
  self.m_vRewardObjItems = {}
end

function Form_PersonalRaidMain:OnActive()
  self.super.OnActive(self)
  self:DestroyItem()
  self.m_bossId = 0
  self.m_rewardItemList = {}
  self.m_stageInfoList = self:GenerateData() or {}
  self.m_selStageIndex = self:EnterChooseStageIndex()
  self.m_curBattleCount = 0
  self.m_activeEndTime = 0
  self.m_activeBattleEndTime = 0
  self:RefreshUI()
  self:refreshLoopScroll()
  if 0 < table.getn(self.m_stageInfoList) then
    self.m_loop_scroll_view:moveToCellIndex(self.m_selStageIndex)
  end
  self:AddEventListeners()
  local tmpStr = LocalDataManager:GetStringSimple("PersonalRaidMain", "")
  if tmpStr ~= "Main_one" then
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Main_one")
    LocalDataManager:SetStringSimple("PersonalRaidMain", "Main_one")
  else
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Main_in")
  end
  self.m_txt_rank_Text.text = ""
  PersonalRaidManager:ReqSoloRaidGetMyRankCS()
end

function Form_PersonalRaidMain:OnInactive()
  self.super.OnInactive(self)
  self:DestroyItem()
  self.m_bossId = 0
  self.m_activeBattleEndTime = 0
  self.m_rewardItemList = {}
  self:RemoveAllEventListeners()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  if self.m_downTimer2 then
    TimeService:KillTimer(self.m_downTimer2)
    self.m_downTimer2 = nil
  end
end

function Form_PersonalRaidMain:AddEventListeners()
  self:addEventListener("eGameEvent_UpDataRankList", handler(self, self.OnUpDateRankBack))
  self:addEventListener("eGameEvent_SoloRaid_GetMyRank", handler(self, self.OnGetMyRank))
  self:addEventListener("eGameEvent_SoloRaid_ChooseRaid", handler(self, self.OnChooseRaidBack))
  self:addEventListener("eGameEvent_SoloRaid_RefreshRaidData", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_SoloRaid_DailyRefresh", handler(self, self.OnBackClk))
end

function Form_PersonalRaidMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PersonalRaidMain:RefreshUI()
  local cfg = self.m_stageInfoList[self.m_selStageIndex]
  if not cfg then
    log.error("Form_PersonalRaidMain m_stageInfoList m_selStageIndex == nil Index =  " .. tostring(self.m_selStageIndex))
    return
  end
  self:RefreshRewardList(cfg)
  self:RefreshStageUI(cfg)
  self:ShowActiveBattleTime()
  self:ShowActiveTime()
  local cfgNum = 0
  local num = 0
  local mode = PersonalRaidManager:CheckLevelModeById(cfg.m_LevelID)
  if mode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Normal then
    cfgNum = PersonalRaidManager:GetNormalStageChallengeCfgNum()
    num = PersonalRaidManager:GetNormalDailyNum()
  elseif mode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard then
    cfgNum = PersonalRaidManager:GetHardStageChallengeCfgNum()
    num = PersonalRaidManager:GetChallengeDailyNum()
  end
  self.m_curBattleCount = cfgNum - num
  self.m_txt_battletimes_Text.text = string.format(ConfigManager:GetCommonTextById(20048), cfgNum - num, cfgNum)
  self.m_img_gogrey:SetActive(self.m_curBattleCount == 0)
  self.m_img_gosel:SetActive(0 < self.m_curBattleCount and mode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Normal)
  self.m_img_gohard:SetActive(0 < self.m_curBattleCount and mode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
  self.m_btn_quick:SetActive(mode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Normal and 0 < self.m_activeBattleEndTime)
  local isPass = PersonalRaidManager:IsLevelDailyHavePass(cfg.m_LevelID)
  if self.m_curBattleCount == 0 or not isPass then
    self.m_img_bg_quickgrey:SetActive(true)
    self.m_img_bg_quick:SetActive(false)
  elseif 0 < self.m_curBattleCount and isPass then
    self.m_img_bg_quickgrey:SetActive(false)
    self.m_img_bg_quick:SetActive(true)
  end
  PersonalRaidManager:SetCurBattleTimes(0)
end

function Form_PersonalRaidMain:ShowActiveBattleTime()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_SoloRaid)
  if activity and activity.GetPersonalRaidBattleEndTime then
    local endTime = activity:GetPersonalRaidBattleEndTime()
    self.m_activeBattleEndTime = endTime - TimeUtil:GetServerTimeS()
    self.m_txt_txt_rankleft_Text.text = TimeUtil:SecondsToFormatCNStr(self.m_activeBattleEndTime)
    self.m_pnl_timeleft:SetActive(self.m_activeBattleEndTime > 0)
    self.m_pnl_rankend:SetActive(self.m_activeBattleEndTime <= 0)
    self.m_btn_go:SetActive(self.m_activeBattleEndTime > 0)
    if self.m_downTimer then
      TimeService:KillTimer(self.m_downTimer)
      self.m_downTimer = nil
    end
    self.m_downTimer = TimeService:SetTimer(1, -1, function()
      self.m_activeBattleEndTime = self.m_activeBattleEndTime - 1
      if self.m_activeBattleEndTime < 0 then
        TimeService:KillTimer(self.m_downTimer)
        self.m_pnl_timeleft:SetActive(false)
      end
      self.m_txt_txt_rankleft_Text.text = TimeUtil:SecondsToFormatCNStr(self.m_activeBattleEndTime)
    end)
  else
    self.m_pnl_timeleft:SetActive(false)
  end
end

function Form_PersonalRaidMain:ShowActiveTime()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_SoloRaid)
  if activity and activity.GetPersonalRaidEndTime then
    local endTime = activity:GetPersonalRaidEndTime()
    self.m_activeEndTime = endTime - TimeUtil:GetServerTimeS()
    if self.m_downTimer2 then
      TimeService:KillTimer(self.m_downTimer2)
      self.m_downTimer2 = nil
    end
    self.m_downTimer2 = TimeService:SetTimer(self.m_activeEndTime, -1, function()
      TimeService:KillTimer(self.m_downTimer2)
      if self.CloseForm then
        self:CloseForm()
      end
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13004)
    end)
  end
end

function Form_PersonalRaidMain:RefreshStageUI(cfg)
  for i = 1, STAGE_NUM do
    local item = self.m_stageObjList[i]
    local info = self.m_stageInfoList[i]
    if item then
      if info then
        item.obj:SetActive(true)
        local mode = PersonalRaidManager:CheckLevelModeById(info.m_LevelID)
        local isPass = PersonalRaidManager:IsLevelHavePass(info.m_LevelUnlock)
        if mode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Normal then
          item.selObj:SetActive(self.m_selStageIndex == i)
          item.pnlLock:SetActive(not isPass)
          item.bgNml:SetActive(true)
          item.selHardObj:SetActive(false)
          item.bgNmlHard:SetActive(false)
          item.textLevel.text = info.m_mName
        else
          item.textLevel.text = ""
          item.selObj:SetActive(false)
          item.bgNml:SetActive(false)
          item.selHardObj:SetActive(self.m_selStageIndex == i)
          item.pnlLockHard:SetActive(not isPass)
          item.bgNmlHard:SetActive(true)
        end
      else
        item.obj:SetActive(false)
      end
    end
  end
  local isPass = PersonalRaidManager:IsLevelHavePass(cfg.m_LevelUnlock)
  self.m_pnl_rightbtn:SetActive(isPass)
  self.m_pnl_before:SetActive(not isPass)
  local bossCfg = PersonalRaidManager:GetSoloRaidBossCfgById(cfg.m_BOSSID)
  if bossCfg then
    self.m_txt_rolename_Text.text = tostring(bossCfg.m_mName)
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_btn_role_Image, bossCfg.m_Background2)
  end
end

function Form_PersonalRaidMain:RefreshRewardList(cfg)
  local firstRewardList = utils.changeCSArrayToLuaTable(cfg.m_ClientMustDropFirst)
  local rewardList = utils.changeCSArrayToLuaTable(cfg.m_ClientMustDrop)
  local proRewardList = utils.changeCSArrayToLuaTable(cfg.m_ClientProDrop)
  local rewardTab = {}
  local customDataTab = {}
  self.m_rewardItemList = {}
  local isPass = PersonalRaidManager:IsLevelHavePass(cfg.m_LevelID)
  if isPass then
    for i, v in ipairs(proRewardList) do
      rewardTab[#rewardTab + 1] = {
        v[1],
        1
      }
      customDataTab[#customDataTab + 1] = {
        percentage = v[2]
      }
    end
    for i, v in ipairs(rewardList) do
      customDataTab[#customDataTab + 1] = {percentage = 100}
    end
    table.insertto(rewardTab, rewardList)
  else
    for i, v in ipairs(firstRewardList) do
      rewardTab[#rewardTab + 1] = v
      customDataTab[#customDataTab + 1] = {percentage = 100}
    end
  end
  self.m_img_bg_first:SetActive(not isPass)
  if table.getn(rewardTab) > 0 then
    for i, v in ipairs(rewardTab) do
      local rewardData = ResourceUtil:GetProcessRewardData(v, customDataTab[i])
      self.m_rewardItemList[#self.m_rewardItemList + 1] = rewardData
    end
    self:RefreshRewardUI(self.m_rewardItemList)
    self.m_pnl_reward:SetActive(true)
    self.m_pnl_noreward:SetActive(false)
    self.m_img_bossblood:SetActive(false)
    self.m_z_txt_mode:SetActive(true)
  else
    self.m_pnl_reward:SetActive(false)
    self.m_pnl_noreward:SetActive(true)
    self.m_img_bossblood:SetActive(true)
    self.m_z_txt_mode:SetActive(false)
  end
end

function Form_PersonalRaidMain:RefreshRewardUI(rewardList)
  for i = 1, #rewardList do
    local stGetItemData = rewardList[i]
    local rateItem = self.m_vRewardObjItems[i]
    if rateItem == nil then
      rateItem = {}
      rateItem.go = CS.UnityEngine.GameObject.Instantiate(self.m_rewardItemsTemplate, self.m_rewardObjParent.transform)
      rateItem.commonItem = self:createCommonItem(rateItem.go)
      self.m_vRewardObjItems[i] = rateItem
    end
    rateItem.go:SetActive(true)
    if rateItem.commonItem then
      rateItem.commonItem:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
      rateItem.commonItem:SetItemInfo(stGetItemData)
    end
  end
  for j = #rewardList + 1, #self.m_vRewardObjItems do
    self.m_vRewardObjItems[j].go:SetActive(false)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_rewardObjParent)
end

function Form_PersonalRaidMain:GenerateData()
  self.m_bossId = PersonalRaidManager:GetBossId()
  local cfgList = PersonalRaidManager:GetSoloRaidLevelCfgListByBossId(self.m_bossId)
  return cfgList
end

function Form_PersonalRaidMain:refreshLoopScroll()
  local data = self.m_stageInfoList
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scroll_view
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_PersonalRaidMain:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local name = cell_data.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard and "" or cell_data.m_mName
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_levelnum", name)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_boss", cell_data.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
  local m_txt_levelnum = LuaBehaviourUtil.findGameObject(luaBehaviour, "m_txt_levelnum")
  if not utils.isNull(m_txt_levelnum) then
    UILuaHelper.SetLocalScale(self.m_txt_levelnum, 1, 1, 1)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(m_txt_levelnum.transform:DOScaleX(0, 0.05))
    sequence:Append(m_txt_levelnum.transform:DOScaleX(1, 0.1))
    sequence:SetAutoKill(true)
  end
  local isPass = PersonalRaidManager:IsLevelHavePass(cell_data.m_LevelUnlock)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_unlocktips", not isPass)
end

function Form_PersonalRaidMain:RefreshOwnerRankInfo(data)
  if not data.iMyRank or data.iMyRank == 0 or data.iMyRank == "0" then
    self.m_txt_rank_Text.text = ""
  else
    local str = PersonalRaidManager:GetRankNameByRankAndTotal(data.iMyRank, data.iRankSize)
    self.m_txt_rank_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20303), str)
  end
end

function Form_PersonalRaidMain:OnBtnleftpageClicked()
  if self.m_loop_scroll_view then
    local page, maxIndex = self.m_loop_scroll_view:moveHorizontalPage(-1)
    if maxIndex then
      page = maxIndex
      self.m_loop_scroll_view:moveHorizontalPage(maxIndex)
    end
    self.m_selStageIndex = page + 1
    self.m_loop_scroll_view:updateCellIndex(page)
    self:RefreshUI()
  end
  UILuaHelper.PlayAnimationByName(self.m_scroll_reward, "m_pnl_reward_item_in")
end

function Form_PersonalRaidMain:OnBtnrightpageClicked()
  if self.m_loop_scroll_view then
    local page, maxIndex = self.m_loop_scroll_view:moveHorizontalPage(1)
    if maxIndex then
      page = 0
      self.m_loop_scroll_view:moveHorizontalPage(-maxIndex)
    end
    self.m_selStageIndex = page + 1
    self.m_loop_scroll_view:updateCellIndex(page)
    self:RefreshUI()
  end
  UILuaHelper.PlayAnimationByName(self.m_scroll_reward, "m_pnl_reward_item_in")
end

function Form_PersonalRaidMain:OnSelectStageClicked(index)
  if self.m_loop_scroll_view then
    local addPage = index - self.m_selStageIndex
    local page, maxIndex = self.m_loop_scroll_view:moveHorizontalPage(addPage)
    self.m_selStageIndex = page + 1
    self.m_loop_scroll_view:updateCellIndex(page)
    self:RefreshUI()
  end
end

function Form_PersonalRaidMain:EnterChooseStageIndex()
  for i, v in ipairs(self.m_stageInfoList) do
    if not PersonalRaidManager:IsLevelHavePass(v.m_LevelID) then
      return i, v.m_BOSSID
    end
  end
  local cfgNum = PersonalRaidManager:GetNormalStageChallengeCfgNum()
  local num = PersonalRaidManager:GetNormalDailyNum()
  local index = #self.m_stageInfoList
  if 0 < cfgNum - num then
    index = #self.m_stageInfoList - 1
  end
  local cfg = self.m_stageInfoList[index]
  if not cfg then
    log.error(" EnterChooseStageIndex  m_stageInfoList len = 0 ")
    return
  end
  return index, cfg.m_BOSSID
end

function Form_PersonalRaidMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PersonalRaidMain:OnBtndetailClicked()
  local itemCfg = self.m_stageInfoList[self.m_selStageIndex] or {}
  StackPopup:Push(UIDefines.ID_FORM_LEVELMONSTERPREVIEW, {
    battleWorldID = itemCfg.m_MapID,
    stageStr = itemCfg.m_mName
  })
end

function Form_PersonalRaidMain:OnBtnrankClicked()
  RankManager:ReqArenaRankListCS(RankManager.RankType.PersonalRaid, 1, PVP_NEW_RANK_PAGE_CNT)
end

function Form_PersonalRaidMain:OnGetMyRank(data)
  self:RefreshOwnerRankInfo(data)
end

function Form_PersonalRaidMain:OnUpDateRankBack(rankType)
  if rankType == RankManager.RankType.PersonalRaid then
    StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDRANKLIST)
  end
end

function Form_PersonalRaidMain:OnBtnsimClicked()
  local cfg = self.m_stageInfoList[self.m_selStageIndex]
  local data = {
    mapId = cfg.m_LevelID,
    simFlag = true
  }
  BattlePersonalRaidManager:EnterBattleBefore(data)
  BattleFlowManager:StartEnterBattle(PersonalRaidManager.FightType_SoloRaid, cfg.m_LevelID)
end

function Form_PersonalRaidMain:OnBtnquickClicked()
  if self.m_curBattleCount == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13001)
    return
  end
  local cfg = self.m_stageInfoList[self.m_selStageIndex]
  local isPass = PersonalRaidManager:IsLevelDailyHavePass(cfg.m_LevelID)
  if not isPass then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13008)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDMAIN_QUICKBATTLE, cfg)
end

function Form_PersonalRaidMain:OnBtngoClicked()
  if self.m_curBattleCount == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13001)
    return
  end
  local cfg = self.m_stageInfoList[self.m_selStageIndex]
  PersonalRaidManager:ReqSoloRaidChooseRaidCS(cfg.m_LevelID)
end

function Form_PersonalRaidMain:OnChooseRaidBack()
  StackFlow:Push(UIDefines.ID_FORM_PERSONALRAIDBOSS)
  self:CloseForm()
end

function Form_PersonalRaidMain:GetDownloadResourceExtra(tParam)
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

function Form_PersonalRaidMain:OnItemIconClicked(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function Form_PersonalRaidMain:OnBackClk()
  self:CloseForm()
end

function Form_PersonalRaidMain:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_PersonalRaidMain:OnBtnteamClicked()
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.Form)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_TEAM, {
    FormTypeBase = HeroManager.TeamTypeBase.SoloRaid
  })
end

function Form_PersonalRaidMain:DestroyItem()
  if self.m_vRewardObjItems and #self.m_vRewardObjItems > 0 then
    for i = #self.m_vRewardObjItems, 1, -1 do
      CS.UnityEngine.GameObject.Destroy(self.m_vRewardObjItems[i].go)
      self.m_vRewardObjItems[i] = nil
    end
  end
  self.m_vRewardObjItems = {}
end

function Form_PersonalRaidMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidMain", Form_PersonalRaidMain)
return Form_PersonalRaidMain
