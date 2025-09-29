local Form_Activity110MiniGameBattleMain = class("Form_Activity110MiniGameBattleMain", require("UI/UIFrames/Form_Activity110MiniGameBattleMainUI"))
local startTips = ConfigManager:GetCommonTextById(101001)
local spineName = "fanu_base_lounge"
local defaultSpineAnim = "idle_01"
local showTypeStr = "herodetail"
local MiniGameA10LevelInfoIns = ConfigManager:GetConfigInsByName("MiniGameA10LevelInfo")
local MiniGameA10CharPartsIns = ConfigManager:GetConfigInsByName("MiniGameA10CharParts")
local MiniGameA10RewardGroupIns = ConfigManager:GetConfigInsByName("MiniGameA10RewardGroup")

function Form_Activity110MiniGameBattleMain:SetInitParam(param)
end

function Form_Activity110MiniGameBattleMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("m_content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil)
  self.m_spineClick = self.m_root_hero:GetComponent("SpineClick")
  if self.m_spineClick then
    self.m_spineClick.raycaster = self.m_rootTrans:GetComponent("GraphicRaycasterBugFixed")
    self.m_spineClick.Touched = handler(self, self.OnSpineTouchClick)
  end
  self.m_allCharPartsCfgList = nil
  self.m_allRewardGroupCfgList = nil
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  self.m_curHeroSpineObj = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_clickRight = self.m_img_bg_check:GetComponent("MultiColorChange")
  self.m_clickWrong = self.m_img_bg_check2:GetComponent("MultiColorChange")
  self.m_clickPoint = self.m_txt_bigpoint:GetComponent("MultiColorChange")
end

function Form_Activity110MiniGameBattleMain:OnActive()
  self.super.OnActive(self)
  self.m_lvId = nil
  self.m_curLevelCfg = nil
  self.m_curRandomEventList = {}
  self.m_gameOverTimer = nil
  self.m_curPoint = 0
  self.m_curStep = {}
  self.m_totalStep = {}
  self.m_clickSpineAnimSpeed = 1
  self.m_mainActId = nil
  self.m_subActId = nil
  self.m_curStepPoint = 0
  self:FreshData()
  self:ShowHeroSpine(spineName)
  self:FreshStartCountDown()
  self.m_isFinish = 0
  self.m_accuracy = 0
  self.m_isParticipate = 0
end

function Form_Activity110MiniGameBattleMain:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_lvId = self.m_csui.m_param.lvId
    self.m_mainActId = self.m_csui.m_param.main_id
    self.m_subActId = self.m_csui.m_param.sub_id
  end
  self.m_curLevelCfg = MiniGameA10LevelInfoIns:GetValue_BySubActIDAndLevelID(self.m_subActId, self.m_lvId)
  if not (self.m_curLevelCfg and not self.m_curLevelCfg:GetError() and self.m_mainActId) or not self.m_subActId then
    log.error("Form_Activity110MiniGameBattleMain")
    self:CloseForm()
  end
  if self.m_curLevelCfg.m_ActionSpeed > 0 then
    self.m_clickSpineAnimSpeed = self.m_curLevelCfg.m_ActionSpeed // 100
  end
  self:DealRandomEvent()
  self.m_txt_endtime_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20376), self.m_curLevelCfg.m_Times)
end

function Form_Activity110MiniGameBattleMain:DealRandomEvent()
  self.m_curRandomEventList = {}
  local randomPoolList = utils.changeCSArrayToLuaTable(self.m_curLevelCfg.m_CharParts)
  local poolLength = #randomPoolList
  for i = 1, self.m_curLevelCfg.m_MaxAreaNum do
    local num = math.random(1, poolLength)
    self.m_curRandomEventList[#self.m_curRandomEventList + 1] = randomPoolList[num]
  end
end

function Form_Activity110MiniGameBattleMain:ShowHeroSpine(showSpineStr)
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(showSpineStr, showTypeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleCurSpine()
    self.m_curHeroSpineObj = spineLoadObj
    if self.m_spineClick and self.m_curHeroSpineObj and not utils.isNull(self.m_curHeroSpineObj.spineObj) then
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spineObj, false)
      self:OnLoadSpineBack(showSpineStr)
    end
  end)
end

function Form_Activity110MiniGameBattleMain:OnLoadSpineBack(showSpineStr)
  if not self.m_curHeroSpineObj then
    return
  end
  UILuaHelper.SetActive(self.m_curHeroSpineObj.spineObj, true)
  UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
  UILuaHelper.SetSpineTimeScale(self.m_curHeroSpineObj.spineObj, 1)
  if self.m_spineClick and not utils.isNull(self.m_curHeroSpineObj) then
    local spineStr = self.m_curHeroSpineObj.assetSpineStr
    self.m_spineClick:BindingSpine("hero_place_" .. spineStr .. "," .. showTypeStr .. "," .. spineStr)
  end
  self:PlaySpineAnimWithStr(defaultSpineAnim, true)
end

function Form_Activity110MiniGameBattleMain:CheckRecycleCurSpine(isResetParam)
  if not self.m_curHeroSpineObj then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  if isResetParam then
    UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
  end
  if self.m_spineClick then
    self.m_spineClick:DestroyFollowerList()
  end
  self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
  self.m_curHeroSpineObj = nil
end

function Form_Activity110MiniGameBattleMain:OnSpineTouchClick(name, localpos)
  if not self.m_iCanClick then
    return
  end
  local partCfg = self:GetSpineAnimByCollision(name)
  if partCfg and self:IsEffectClicked(partCfg.m_ID) then
    if self.m_nextTips then
      TimeService:KillTimer(self.m_nextTips)
      self.m_nextTips = nil
    end
    UILuaHelper.SetActive(self.m_tips_root, false)
    if not utils.isNull(self.m_lastNextTips) then
      UILuaHelper.SetActive(self.m_lastNextTips, false)
    end
    self.m_isParticipate = 1
    local step = #self.m_curStep + 1
    local totalStep = #self.m_totalStep + 1
    local isRight = self.m_curRandomEventList[step] == partCfg.m_ID
    local clickedVoiceId = isRight and 388 or 389
    CS.GlobalManager.Instance:TriggerWwiseBGMState(clickedVoiceId)
    self.m_curStep[step] = isRight
    self.m_totalStep[totalStep] = isRight
    self.m_curStepPoint = isRight and self.m_curLevelCfg.m_Points[0] or self.m_curLevelCfg.m_Points[1]
    local curSpineName = isRight and partCfg.m_Action or partCfg.m_RefuseAction
    self.m_curPoint = self.m_curPoint + self.m_curStepPoint
    if 0 > self.m_curPoint then
      self.m_curPoint = 0
    end
    if #self.m_curStep ~= table.getn(self.m_curRandomEventList) then
      self:DealPlayerIdleTimeoutTips()
    end
    self:PlaySpineAnimWithStr(curSpineName, false, function()
      self:PlaySpineAnimWithStr(defaultSpineAnim, true)
    end, self.m_clickSpineAnimSpeed)
    self:FreshPoint(true)
    self:FreshClickResult()
    self:OnClickResponse(isRight)
    self:FreshSubtitles(partCfg, isRight)
  end
end

function Form_Activity110MiniGameBattleMain:OnClickResponse(isRight)
  local mouseX = Input.mousePosition.x
  local mouseY = Input.mousePosition.y
  local localPosX, localPosY = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_content_node, mouseX, mouseY, self.m_groupCam)
  UILuaHelper.SetLocalPosition(self.m_btn_check, localPosX, localPosY, 0)
  UILuaHelper.SetActive(self.m_btn_check, true)
  UILuaHelper.PlayAnimationByName(self.m_btn_check, "m_btn_check")
  local colorIndex = isRight and 0 or 1
  self.m_clickRight:SetColorByIndex(colorIndex)
  self.m_clickWrong:SetColorByIndex(colorIndex)
end

function Form_Activity110MiniGameBattleMain:DealPlayerIdleTimeoutTips()
  local tipsDuring = math.floor(self.m_curLevelCfg.m_TipsCD / 1000)
  self.m_nextTips = TimeService:SetTimer(tipsDuring, 1, function()
    local nextStep = #self.m_curStep + 1
    local nextEventId = self.m_curRandomEventList[nextStep]
    if not utils.isNull(self["m_tips_" .. nextEventId]) then
      UILuaHelper.SetActive(self.m_tips_root, true)
      UILuaHelper.SetActive(self.m_img_clicked, false)
      UILuaHelper.SetActive(self["m_tips_" .. nextEventId], true)
      UILuaHelper.PlayAnimationByName(self["m_tips_" .. nextEventId], "m_pnl_game_tips_loop")
      self.m_lastNextTips = self["m_tips_" .. nextEventId]
      if self.m_nextTips then
        TimeService:KillTimer(self.m_nextTips)
        self.m_nextTips = nil
      end
    end
  end)
end

function Form_Activity110MiniGameBattleMain:PlaySpineAnimWithStr(animStr, isLoop, endFun, speed)
  if animStr and UILuaHelper.CheckIsHaveSpineAnim(self.m_curHeroSpineObj.spineObj, animStr) then
    speed = speed or 1
    UILuaHelper.SpinePlayAnimWithBack(self.m_curHeroSpineObj.spineObj, 0, animStr, isLoop, false, endFun, speed)
  end
end

function Form_Activity110MiniGameBattleMain:FreshSubtitles(cfg, isRight)
  local randomIndex = isRight and 0 or 1
  if cfg and cfg.m_Subtitle and cfg.m_Subtitle[randomIndex] then
    UILuaHelper.SetActive(self.m_pnl_wrongtips, true)
    UILuaHelper.PlayAnimationByName(self.m_pnl_wrongtips, "m_pnl_wrongtips")
    self.m_txt_wrongtips_Text.text = CS.MultiLanguageManager.Instance:GetPlotText(cfg.m_Subtitle[randomIndex])
  else
    UILuaHelper.SetActive(self.m_pnl_wrongtips, false)
  end
  if cfg.m_Voice[randomIndex] then
    CS.UI.UILuaHelper.StartPlaySFX(cfg.m_Voice[randomIndex], nil, function(playingId)
      self.m_playingId = playingId
    end, function()
      self.m_playingId = nil
    end)
  end
  CS.UI.UILuaHelper.StartPlaySFX("Play_ui_Activity110MiniGameMain_Touch", nil, function(playingId)
    self.m_playingId1 = playingId
  end, function()
    self.m_playingId1 = nil
  end)
end

function Form_Activity110MiniGameBattleMain:FreshPoint(isClick)
  if isClick and self.m_curStepPoint then
    local colorIndex = self.m_curStepPoint > 0 and 0 or 1
    local showAddPoint = self.m_curStepPoint > 0 and "+" .. tostring(self.m_curStepPoint) or tostring(self.m_curStepPoint)
    UILuaHelper.SetActive(self.m_txt_bigpoint, true)
    UILuaHelper.PlayAnimationByName(self.m_txt_bigpoint, "m_pnl_result_text_bigpoint")
    self.m_txt_bigpoint_Text.text = tostring(showAddPoint)
    self.m_clickPoint:SetColorByIndex(colorIndex)
  else
    UILuaHelper.SetActive(self.m_txt_bigpoint, false)
  end
  self.m_txt_point_Text.text = tostring(self.m_curPoint)
end

function Form_Activity110MiniGameBattleMain:FreshClickResult()
  local curStep = #self.m_curStep
  self["m_img_right" .. curStep]:SetActive(self.m_curStep[curStep])
  self["m_img_wrong" .. curStep]:SetActive(not self.m_curStep[curStep])
  if curStep == #self.m_curRandomEventList then
    self.m_curStep = {}
    self.m_iCanClick = false
    self.m_tipsTimer = TimeService:SetTimer(1, 1, function()
      if self.m_isFinish == 1 then
        return
      end
      self:DealRandomEvent()
      self:FreshStartBattleUI()
      TimeService:KillTimer(self.m_tipsTimer)
      self.m_tipsTimer = nil
    end)
  end
end

function Form_Activity110MiniGameBattleMain:FreshSettlement(levelId)
  local format_configs = {}
  local idGroupList = MiniGameA10RewardGroupIns:GetValue_ByGroupID(levelId)
  for _, cfg in pairs(idGroupList) do
    local point = cfg.m_Condition
    if point then
      format_configs[point] = cfg
    end
  end
  local curPointLevel = 0
  for point, cfg in pairs(format_configs) do
    if curPointLevel < cfg.m_Gear and point <= self.m_curPoint then
      curPointLevel = cfg.m_Gear
    end
  end
  UILuaHelper.SetActive(self.m_pnl_levels, curPointLevel == 4)
  UILuaHelper.SetActive(self.m_pnl_levela, curPointLevel ~= 4)
  UILuaHelper.SetActive(self.m_img_S, curPointLevel == 4)
  UILuaHelper.SetActive(self.m_img_A, curPointLevel == 3)
  UILuaHelper.SetActive(self.m_img_B, curPointLevel == 2)
  UILuaHelper.SetActive(self.m_img_C, curPointLevel == 1)
  local endVoiceId = curPointLevel == 4 and 394 or 395
  CS.GlobalManager.Instance:TriggerWwiseBGMState(endVoiceId)
  local isRightNum = 0
  for step, result in ipairs(self.m_totalStep) do
    if result == true then
      isRightNum = isRightNum + 1
    end
  end
  if isRightNum == 0 then
    self.m_accuracy = 0
  else
    self.m_accuracy = math.floor(isRightNum / #self.m_totalStep * 100)
  end
  if curPointLevel ~= 4 then
    self.m_txt_settlement2a_Text.text = tostring(self.m_accuracy) .. "%"
    self.m_txt_settlement1a_Text.text = tostring(self.m_curPoint)
  else
    self.m_txt_settlement2s_Text.text = tostring(self.m_accuracy) .. "%"
    self.m_txt_settlement1s_Text.text = tostring(self.m_curPoint)
  end
end

function Form_Activity110MiniGameBattleMain:FreshStartCountDown()
  UILuaHelper.SetActive(self.m_pnl_start, true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(390)
  UILuaHelper.SetActive(self.m_pnl_game, false)
  UILuaHelper.SetActive(self.m_pnl_settlement, false)
  UILuaHelper.SetActive(self.m_root_hero, false)
  self.m_txt_start_Text.text = startTips
  local aniLength = UILuaHelper.GetAnimationLengthByName(self.m_pnl_start, "Activity110MiniGameBattleMain_start")
  self.m_startCountDownTimer = TimeService:SetTimer(aniLength, 1, function()
    UILuaHelper.SetActive(self.m_pnl_start, false)
    UILuaHelper.SetActive(self.m_btn_check, false)
    UILuaHelper.SetActive(self.m_pnl_game, true)
    UILuaHelper.SetActive(self.m_pnl_settlement, false)
    UILuaHelper.SetActive(self.m_root_hero, true)
    self:FreshStartBattleUI(true)
    TimeService:KillTimer(self.m_startCountDownTimer)
    self.m_startCountDownTimer = nil
  end)
end

function Form_Activity110MiniGameBattleMain:FreshStartBattleUI(isFirst)
  UILuaHelper.SetActive(self.m_tips_root, true)
  UILuaHelper.SetActive(self.m_img_clicked, true)
  UILuaHelper.SetActive(self.m_tips_1001, false)
  UILuaHelper.SetActive(self.m_tips_1002, false)
  UILuaHelper.SetActive(self.m_tips_1003, false)
  UILuaHelper.SetActive(self.m_tips_1004, false)
  UILuaHelper.SetActive(self.m_tips_1005, false)
  UILuaHelper.SetActive(self.m_txt_bigpoint, false)
  UILuaHelper.SetActive(self.m_pnl_startgame, false)
  UILuaHelper.SetActive(self.m_pnl_wrongtips, false)
  self:PlaySpineAnimWithStr(defaultSpineAnim, true)
  self.m_curStepPoint = 0
  self:FreshPoint()
  local poolLength = #self.m_curRandomEventList
  local curShowTipsIndex = 0
  self.m_lastTipsObj = nil
  local showTime = self.m_curLevelCfg.m_AskTimes // poolLength / 1000
  self.m_showTipsTime = TimeService:SetTimer(showTime, poolLength + 1, function()
    curShowTipsIndex = curShowTipsIndex + 1
    if self.m_isFinish == 1 then
      UILuaHelper.SetActive(self.m_tips_root, false)
      TimeService:KillTimer(self.m_showTipsTime)
      self.m_showTipsTime = nil
      return
    end
    if curShowTipsIndex ~= poolLength + 1 then
      local eventId = self.m_curRandomEventList[curShowTipsIndex]
      if self.m_lastTipsObj then
        UILuaHelper.SetActive(self.m_lastTipsObj, false)
        UILuaHelper.PlayAnimationByName(self.m_lastTipsObj, "m_pnl_game_tips_out")
      end
      if not utils.isNull(self["m_tips_" .. eventId]) then
        UILuaHelper.SetActive(self["m_tips_" .. eventId], true)
        UILuaHelper.PlayAnimationByName(self["m_tips_" .. eventId], "m_pnl_game_tips_in")
        self.m_lastTipsObj = self["m_tips_" .. eventId]
      end
    else
      if not utils.isNull(self.m_lastTipsObj) then
        UILuaHelper.SetActive(self.m_lastTipsObj, false)
      end
      UILuaHelper.SetActive(self.m_tips_root, false)
      UILuaHelper.SetActive(self.m_pnl_startgame, true)
      for i = 1, 6 do
        if not utils.isNull(self["m_img_right" .. i]) then
          self["m_img_bg" .. i]:SetActive(i <= #self.m_curRandomEventList)
          if i <= #self.m_curRandomEventList then
            self["m_img_right" .. i]:SetActive(false)
            self["m_img_wrong" .. i]:SetActive(false)
          end
        end
      end
      self.m_iCanClick = true
      if isFirst then
        self:FreshGameOverTimer()
      end
      TimeService:KillTimer(self.m_showTipsTime)
      self.m_showTipsTime = nil
    end
  end)
end

function Form_Activity110MiniGameBattleMain:OnInactive()
  self.super.OnInactive(self)
  if self.m_startCountDownTimer then
    TimeService:KillTimer(self.m_startCountDownTimer)
    self.m_startCountDownTimer = nil
  end
  self:ClearGameOverTimer()
  if self.m_nextTips then
    TimeService:KillTimer(self.m_nextTips)
    self.m_nextTips = nil
  end
  if self.m_tipsTimer then
    TimeService:KillTimer(self.m_tipsTimer)
    self.m_tipsTimer = nil
  end
  if self.m_showTipsTime then
    TimeService:KillTimer(self.m_showTipsTime)
    self.m_showTipsTime = nil
  end
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
  if self.m_playingId1 then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId1)
  end
  self:CheckRecycleCurSpine()
  local params = {
    LevelId = self.m_curLevelCfg.m_LevelID,
    Accuracy = self.m_accuracy,
    IsParticipate = self.m_isParticipate,
    IsFinish = self.m_isFinish
  }
  ReportManager:ReportMessage(CS.ReportDataDefines.MiniGame110_Participate, params)
end

function Form_Activity110MiniGameBattleMain:FreshGameOverTimer()
  local endTime = self.m_curLevelCfg.m_Times + TimeUtil:GetServerTimeS()
  self.m_txt_endtime_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20376), self.m_curLevelCfg.m_Times)
  self:ClearGameOverTimer()
  self.m_gameOverTimer = TimeService:SetTimer(1, -1, function()
    local time = endTime - TimeUtil:GetServerTimeS()
    self.m_txt_endtime_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20376), time)
    if time <= 0 then
      self.m_pnl_settlement:SetActive(true)
      self:FreshSettlement(self.m_curLevelCfg.m_LevelID)
      HeroActivityManager:ReqHeroActMiniGameFinishCS(self.m_mainActId, self.m_subActId, self.m_curLevelCfg.m_LevelID, self.m_curPoint)
      self.m_isFinish = 1
      self.m_iCanClick = false
      self:ClearGameOverTimer()
    end
  end)
end

function Form_Activity110MiniGameBattleMain:ClearGameOverTimer()
  if self.m_gameOverTimer then
    TimeService:KillTimer(self.m_gameOverTimer)
    self.m_gameOverTimer = nil
  end
end

function Form_Activity110MiniGameBattleMain:GetSpineAnimByCollision(collisionName)
  if not self.m_allCharPartsCfgList then
    self.m_allCharPartsCfgList = MiniGameA10CharPartsIns:GetAll()
  end
  for _, partCfg in pairs(self.m_allCharPartsCfgList) do
    if partCfg and partCfg.m_Collision == collisionName then
      return partCfg
    end
  end
end

function Form_Activity110MiniGameBattleMain:IsEffectClicked(partId)
  local randomPoolList = utils.changeCSArrayToLuaTable(self.m_curLevelCfg.m_CharParts)
  for _, part in pairs(randomPoolList) do
    if part == partId then
      return true
    end
  end
  return false
end

function Form_Activity110MiniGameBattleMain:OnBackClk()
  if self.m_isFinish ~= 1 then
    utils.CheckAndPushCommonTips({
      tipsID = 1266,
      func1 = function()
        self:CloseForm()
        self:OnBackToMain()
      end
    })
  else
    self:CloseForm()
    self:OnBackToMain()
  end
end

function Form_Activity110MiniGameBattleMain:OnBackToMain()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110MINIGAMEMAIN, {
    lvId = self.m_lvId,
    main_id = self.m_mainActId,
    sub_id = self.m_subActId
  })
end

function Form_Activity110MiniGameBattleMain:OnBtncloseFinishClicked()
  self:CloseForm()
  self:OnBackToMain()
end

function Form_Activity110MiniGameBattleMain:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackPopup:PopAll()
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_Activity110MiniGameBattleMain:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Activity110MiniGameBattleMain", Form_Activity110MiniGameBattleMain)
return Form_Activity110MiniGameBattleMain
