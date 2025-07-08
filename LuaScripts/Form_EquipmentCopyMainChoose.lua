local Form_EquipmentCopyMainChoose = class("Form_EquipmentCopyMainChoose", require("UI/UIFrames/Form_EquipmentCopyMainChooseUI"))

function Form_EquipmentCopyMainChoose:SetInitParam(param)
end

function Form_EquipmentCopyMainChoose:Init(gameObject, csui)
  self:CheckCreateVariable(csui)
  self:InitCreateBossClickFun()
  Form_EquipmentCopyMainChoose.super.Init(self, gameObject, csui)
end

function Form_EquipmentCopyMainChoose:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBack), nil, handler(self, self.OnBackHome), 1102)
  self.m_equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  self:PlayVoiceOnFirstEnter()
end

function Form_EquipmentCopyMainChoose:OnActive()
  self.super.OnActive(self)
  self.m_boss_levelSubType_list = {}
  self:AddEventListeners()
  self:RefreshBossPanel()
  self.m_ownerModule:CreateBossPosNode()
  GlobalManagerIns:TriggerWwiseBGMState(154)
  GlobalManagerIns:TriggerWwiseBGMState(155)
  self:StartLoopBirdMusic()
  self:CheckParamAndOpenChapter()
  self:OnFullBurstDayUpdate()
end

function Form_EquipmentCopyMainChoose:OnInactive()
  self.super.OnInactive(self)
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
  GlobalManagerIns:TriggerWwiseBGMState(156)
  if self.m_birdLoopTimer then
    TimeService:KillTimer(self.m_birdLoopTimer)
    self.m_birdLoopTimer = nil
  end
  GlobalManagerIns:TriggerWwiseBGMState(163)
  self:RemoveAllEventListeners()
end

function Form_EquipmentCopyMainChoose:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_FullBurstDayUpdate", handler(self, self.OnFullBurstDayUpdate))
end

function Form_EquipmentCopyMainChoose:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipmentCopyMainChoose:OnFullBurstDayUpdate()
  for i = 1, self.m_uiVariables.BossNum do
    UILuaHelper.SetActive(self["m_doublereward_boss" .. i], ActivityManager:IsFullBurstDayOpen())
  end
end

function Form_EquipmentCopyMainChoose:CheckParamAndOpenChapter()
  local tParam = self.m_csui.m_param
  if tParam then
    local tempChapterIndex = tParam.chapterIndex
    if tempChapterIndex then
      self:GotoDunChapterByOrderId(tempChapterIndex)
    end
    self.m_csui.m_param = nil
  end
end

function Form_EquipmentCopyMainChoose:StartLoopBirdMusic()
  if self.m_birdLoopTimer then
    TimeService:KillTimer(self.m_birdLoopTimer)
    self.m_birdLoopTimer = nil
  end
  self.m_birdLoopTimer = TimeService:SetTimer(self.m_uiVariables.BirdLoopDelayTime, -1, function()
    GlobalManagerIns:TriggerWwiseBGMState(157)
  end)
end

function Form_EquipmentCopyMainChoose:RefreshBossPanel()
  local num = self.m_equipmentHelper:GetChallengeDailyNum()
  local times = self.m_equipmentHelper:GetLevelDailyData()
  local cfgList = self.m_equipmentHelper:GetTodayAllBossCfg()
  if not cfgList then
    log.error("GetTodayAllBossCfg  error !!!")
    return
  end
  self.m_boss_levelSubType_list = {}
  self.m_txt_lefttimes_Text.text = string.format(ConfigManager:GetCommonTextById(20048), num - times, num)
  for i = 1, self.m_uiVariables.BossNum do
    local cfg = cfgList[i]
    if cfg then
      self.m_boss_levelSubType_list[cfg.m_Order] = cfg.m_LevelSubType
      local levelSubType = cfg.m_LevelSubType
      if self["m_pnl_boss" .. i] then
        if cfg.m_Hide == 1 then
          self["m_pnl_boss" .. i]:SetActive(false)
        else
          self["m_pnl_boss" .. i]:SetActive(true)
        end
      end
      local isUnlock, unlockType, unlockStr = self.m_equipmentHelper:IsChapterSubTypeUnlock(levelSubType)
      self["m_node_boss_lock" .. i]:SetActive(not isUnlock)
      self["m_txt_name_list" .. i .. "_Text"].text = cfg.m_mNameList
      self["m_txt_boss_unlock" .. i .. "_Text"].text = unlockStr
      self["m_txt_boss_name" .. i .. "_Text"].text = cfg.m_mBossName
      self["m_img_bg_bloodc" .. i]:SetActive(isUnlock)
      self["m_img_bg_bloodc_lock" .. i]:SetActive(not isUnlock)
      self["m_icon_equip" .. i]:SetActive(isUnlock)
      self["m_txt_name_list" .. i]:SetActive(isUnlock)
      self["m_txt_name_listlock" .. i]:SetActive(not isUnlock)
      self["m_txt_name_listlock" .. i .. "_Text"].text = cfg.m_mNameList
      if isUnlock then
        local multiColor = self["m_txt_name_list" .. i .. "_Text"]:GetComponent("MultiColorChange")
        multiColor:SetColorByIndex(0)
        local multiColor2 = self["m_txt_boss_name" .. i .. "_Text"]:GetComponent("MultiColorChange")
        multiColor2:SetColorByIndex(0)
      else
        local multiColor = self["m_txt_name_listlock" .. i .. "_Text"]:GetComponent("MultiColorChange")
        multiColor:SetColorByIndex(1)
        local multiColor2 = self["m_txt_boss_name" .. i .. "_Text"]:GetComponent("MultiColorChange")
        multiColor2:SetColorByIndex(1)
      end
    end
  end
end

function Form_EquipmentCopyMainChoose:InitCreateBossClickFun()
  local bossNum = self.m_uiVariables.BossNum
  for i = 1, bossNum do
    self["OnBtnboss" .. i .. "Clicked"] = function()
      self:OnBossTodayClicked(i)
    end
  end
  for i = 1, bossNum do
    self["OnBtnbosslock" .. i .. "Clicked"] = function()
      self:OnBossTodayClicked(i)
    end
  end
end

function Form_EquipmentCopyMainChoose:OnBossTodayClicked(order)
  local flag = true
  for i, levelSubType in pairs(self.m_boss_levelSubType_list) do
    flag = self.m_equipmentHelper:CheckTodayBossIsTrue(levelSubType)
    if not flag then
      break
    end
  end
  if flag then
    self:GotoDunChapterByOrderId(order)
  else
    utils.popUpDirectionsUI({
      tipsID = 1128,
      func1 = function()
        self:OnBack()
      end
    })
  end
end

function Form_EquipmentCopyMainChoose:GotoDunChapterByOrderId(orderId)
  local chapterInfo = self.m_equipmentHelper:GetDunChapterByOrderId(orderId)
  if not chapterInfo then
    return
  end
  local isUnlock, unlockType, unlockStr = self.m_equipmentHelper:IsChapterSubTypeUnlock(chapterInfo.m_LevelSubType)
  if not isUnlock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, unlockStr)
    return
  end
  self.m_ownerModule:CreateBoss3DResBySortId(orderId)
  StackFlow:Push(UIDefines.ID_FORM_EQUIPMENTCOPYMAIN, {chapterIndex = orderId})
end

function Form_EquipmentCopyMainChoose:OnBack()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
  self.m_ownerModule:ClearAllBossRes()
end

function Form_EquipmentCopyMainChoose:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    GameSceneManager:CheckChangeSceneToMainCity(nil, true)
  end
  self.m_ownerModule:ClearAllBossRes()
end

function Form_EquipmentCopyMainChoose:IsFullScreen()
  return true
end

function Form_EquipmentCopyMainChoose:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_EquipmentCopyMainChoose:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  self.m_equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if self.m_equipmentHelper then
    local posNameList, bossNameList, animNameList = self.m_equipmentHelper:GetTodayBossResName()
    for i, v in pairs(posNameList) do
      vResourceExtra[#vResourceExtra + 1] = {
        sName = v,
        eType = DownloadManager.ResourceType.Prefab
      }
    end
    for i, v in pairs(bossNameList) do
      vResourceExtra[#vResourceExtra + 1] = {
        sName = v,
        eType = DownloadManager.ResourceType.Role
      }
    end
    for i, v in pairs(animNameList) do
      vResourceExtra[#vResourceExtra + 1] = {
        sName = v,
        eType = DownloadManager.ResourceType.Animation
      }
    end
  end
  return vPackage, vResourceExtra
end

function Form_EquipmentCopyMainChoose:PlayVoiceOnFirstEnter()
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("DungeonVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
end

local fullscreen = true
ActiveLuaUI("Form_EquipmentCopyMainChoose", Form_EquipmentCopyMainChoose)
return Form_EquipmentCopyMainChoose
