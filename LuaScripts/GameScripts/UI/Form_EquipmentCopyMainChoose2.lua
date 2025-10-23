local Form_EquipmentCopyMainChoose2 = class("Form_EquipmentCopyMainChoose2", require("UI/UIFrames/Form_EquipmentCopyMainChoose2UI"))

function Form_EquipmentCopyMainChoose2:SetInitParam(param)
end

function Form_EquipmentCopyMainChoose2:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_spineBg = self.m_img_choose_bg.transform:Find("dungeon_bg")
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBack), nil, handler(self, self.OnBackHome), 1274)
  self.m_equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  self.m_iTimeDurationOneSecond = 1
  self.EndTimeStr = ""
end

function Form_EquipmentCopyMainChoose2:Init(gameObject, csui)
  self:CheckCreateVariable(csui)
  self:InitCreateBossClickFun()
  Form_EquipmentCopyMainChoose2.super.Init(self, gameObject, csui)
end

function Form_EquipmentCopyMainChoose2:InitCreateBossClickFun()
  local bossNum = 4
  for i = 1, bossNum do
    self["OnBtnpart" .. i .. "Clicked"] = function()
      self:OnBossTodayClicked(i)
    end
  end
  for i = 1, bossNum do
    self["OnBtnpartgrey" .. i .. "Clicked"] = function()
      self:OnLockClicked(i)
    end
  end
end

function Form_EquipmentCopyMainChoose2:OnBossTodayClicked(bossIndex)
  StackPopup:Push(UIDefines.ID_FORM_BOSSEQUIPMENTPART, self.cfgList[bossIndex])
end

function Form_EquipmentCopyMainChoose2:OnLockClicked(bossIndex)
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13033)
end

function Form_EquipmentCopyMainChoose2:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_PartDungeonWelfare_TotalScoreChange_FreshRedDot", handler(self, self.OnEventPartDungeonWelfareFreshRedPoint))
end

function Form_EquipmentCopyMainChoose2:OnEventPartDungeonWelfareFreshRedPoint(param)
  UILuaHelper.SetActive(self.m_enter_redpoint, true)
end

function Form_EquipmentCopyMainChoose2:OnActive()
  self.super.OnActive(self)
  self.m_img_bg_basicsel:SetActive(false)
  self.m_img_bg_partsel:SetActive(true)
  self:AddEventListeners()
  self:RefreshActivityEnter()
  self:RefreshBossPanel()
end

function Form_EquipmentCopyMainChoose2:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
  self.m_iTimeTick = nil
end

function Form_EquipmentCopyMainChoose2:OnUpdate(dt)
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick - dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond - dt
  if self.m_iTimeDurationOneSecond <= 0 then
    self.m_iTimeDurationOneSecond = 1
    local lastTimeCur = TimeUtil:SecondsToFormatCNStr4(self.m_iTimeTick)
    self.m_txt_entertime_Text.text = string.gsubnumberreplace(self.EndTimeStr, lastTimeCur)
  end
  if self.m_iTimeTick <= 0 and self.m_stActivity then
    self:CloseForm()
  end
end

function Form_EquipmentCopyMainChoose2:OnDestroy()
  if self.m_detailOutTimer then
    TimeService:KillTimer(self.m_detailOutTimer)
    self.m_detailOutTimer = nil
  end
  if self.m_enterUnlockTimer then
    TimeService:KillTimer(self.m_enterUnlockTimer)
    self.m_enterUnlockTimer = nil
  end
  self.super.OnDestroy(self)
  UILuaHelper.CheckClearSkeletonAssetData(self.m_spineBg)
  self.m_spineBg = nil
end

function Form_EquipmentCopyMainChoose2:RefreshBossPanel()
  local num = self.m_equipmentHelper:GetChallengeDailyNum()
  local times = self.m_equipmentHelper:GetLevelDailyData()
  local cfgList = self.m_equipmentHelper:GetPartChapterCfg()
  if not cfgList then
    log.error("GetTodayAllBossCfg  error !!!")
    return
  end
  self.m_spineBg.gameObject:SetActive(true)
  local hasShowUnlock = LocalDataManager:GetIntSimple("Form_EquipmentCopyMainChoose2Unlock", 0) == 1
  if not hasShowUnlock then
    local FormEnterStr = "EquipmentCopyMainChoose2_in"
    local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, FormEnterStr) - 0.4
    self.m_enterUnlockTimer = TimeService:SetTimer(detailAnimLen, 1, function()
      LocalDataManager:SetIntSimple("Form_EquipmentCopyMainChoose2Unlock", 1)
      self:ShowUnlockEffect()
      self.m_enterUnlockTimer = nil
    end)
  end
  self.cfgList = cfgList
  self.m_boss_levelSubType_list = {}
  self.m_txt_lefttimes_Text.text = string.format(ConfigManager:GetCommonTextById(20048), num - times, num)
  for i = 1, self.m_uiVariables.BossNum do
    local cfg = cfgList[i]
    if cfg then
      if self["m_pnl_boss" .. i] then
        if cfg.m_Hide == 1 then
          self["m_pnl_boss" .. i]:SetActive(false)
        else
          self["m_pnl_boss" .. i]:SetActive(true)
        end
      end
      local sysUnlock = self.m_equipmentHelper:IsPartSubTypeUnlock(cfg.m_LevelSubType)
      local isUnlock = sysUnlock and hasShowUnlock
      self["m_btn_part" .. i]:SetActive(isUnlock)
      self["m_txt_parttitle" .. i .. "_Text"].text = cfg.m_mName
      self["m_txt_partdesc" .. i .. "_Text"].text = cfg.m_mDesc
      self["m_btn_part_grey" .. i]:SetActive(not isUnlock)
      self["m_txt_parttitle_grey" .. i .. "_Text"].text = cfg.m_mName
      self["m_txt_partdesc_grey" .. i .. "_Text"].text = cfg.m_mDesc
      self["m_pnl_opened" .. i]:SetActive(self.isShowActivity and self:CheckShowOpenTips(cfg.m_LevelSubType))
      CS.UI.UILuaHelper.SetAtlasSprite(self["m_img_part_grey" .. i .. "_Image"], cfg.m_Icon)
      CS.UI.UILuaHelper.SetAtlasSprite(self["m_img_part" .. i .. "_Image"], cfg.m_Icon)
      self["m_doublereward_boss" .. i]:SetActive(ActivityManager:IsFullBurstDayOpen() and sysUnlock)
    end
  end
end

function Form_EquipmentCopyMainChoose2:RefreshActivityEnter()
  self.m_stActivity = ActivityManager:GetActivityByType(MTTD.ActivityType_PartDungeonWelfare)
  self.isShowActivity = false
  UILuaHelper.SetActive(self.m_txt_entertime, false)
  if self.m_stActivity and self.m_stActivity:checkCondition() then
    self.isShowActivity = true
    UILuaHelper.SetActive(self.m_enter_redpoint, self.m_stActivity:checkShowRed())
    UILuaHelper.SetAtlasSprite(self.m_icon_boos_Image, self.m_stActivity:GetIcon())
    local endTime, endTimeStr = self.m_stActivity:GetEndTime()
    if 0 < endTime then
      UILuaHelper.SetActive(self.m_txt_entertime, true)
      self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
      local lastTimeCur = TimeUtil:SecondsToFormatCNStr4(self.m_iTimeTick)
      self.m_txt_entertime_Text.text = string.gsubnumberreplace(endTimeStr, lastTimeCur)
      self.EndTimeStr = endTimeStr
    else
      self.m_iTimeTick = nil
      self.isShowActivity = false
    end
  end
  UILuaHelper.SetActive(self.m_btn_enter, self.isShowActivity)
end

function Form_EquipmentCopyMainChoose2:CheckShowOpenTips(subType)
  local show = false
  if self.m_stActivity then
    local subTypeArr = self.m_stActivity:GetFightSubType()
    for _, v in pairs(subTypeArr) do
      if v == subType then
        show = true
        break
      end
    end
  end
  return show
end

function Form_EquipmentCopyMainChoose2:OnBtnbasicClicked()
  LevelManager:SetPartDungState(false)
  StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE)
  self:CloseForm()
end

function Form_EquipmentCopyMainChoose2:OnBack()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE2)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
  LevelManager:SetPartDungState(false)
  self:DestroyBigSystemUIImmediately()
end

function Form_EquipmentCopyMainChoose2:ShowUnlockEffect()
  self.m_btn_part1:SetActive(false)
  self.m_btn_part_grey1:SetActive(true)
  local EnterAnimStr = "m_EquipmentCopyMainChoose2_look_in"
  local OutAnimStr = "m_EquipmentCopyMainChoose2_look_out"
  local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_part1, OutAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_pnl_part1, OutAnimStr)
  self.m_detailOutTimer = TimeService:SetTimer(detailAnimLen, 1, function()
    self.m_btn_part1:SetActive(true)
    self.m_btn_part_grey1:SetActive(false)
    UILuaHelper.PlayAnimationByName(self.m_pnl_part1, EnterAnimStr)
    self.m_detailOutTimer = nil
  end)
end

function Form_EquipmentCopyMainChoose2:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    GameSceneManager:CheckChangeSceneToMainCity(nil, true)
  end
  LevelManager:SetPartDungState(false)
  self:DestroyBigSystemUIImmediately()
end

function Form_EquipmentCopyMainChoose2:OnBtnenterClicked()
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_PartDungeonWelfare)
  if activity and activity:checkCondition() then
    StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTLIMITTIMEACTIVITY, {activity = activity})
  else
    utils.popUpDirectionsUI({tipsID = 20083})
  end
end

function Form_EquipmentCopyMainChoose2:IsFullScreen()
  return true
end

ActiveLuaUI("Form_EquipmentCopyMainChoose2", Form_EquipmentCopyMainChoose2)
return Form_EquipmentCopyMainChoose2
