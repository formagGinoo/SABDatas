local Form_Activity105Minigame = class("Form_Activity105Minigame", require("UI/UIFrames/Form_Activity105MinigameUI"))
local Mathf = CS.UnityEngine.Mathf
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Form_Activity105Minigame:SetInitParam(param)
end

function Form_Activity105Minigame:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil)
  self.m_btn_touch_BtnEx = self.m_btn_touch:GetComponent("ButtonExtensions")
  if not utils.isNull(self.m_btn_touch_BtnEx) then
    self.m_btn_touch_BtnEx.BeginDrag = handler(self, self.OnBeginDrag)
    self.m_btn_touch_BtnEx.Drag = handler(self, self.OnDrag)
    self.m_btn_touch_BtnEx.EndDrag = handler(self, self.OnEndBDrag)
  end
  self.iDragRightRange = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("MiniGameLegacyStageRightRange").m_Value or 0)
  self.iDragHintRange = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("MiniGameLegacyStageHintRange").m_Value or 0)
  self.iWaittingTime = 5
  self.iShowTipsTime = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("MiniGameLegacyStageTipsTime").m_Value or 0)
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  self.m_minigameHelper = HeroActivityManager:GetMinigameHelper()
  self.mSpecialClockAngle = {
    [1] = 0,
    [2] = 90,
    [3] = 180,
    [4] = 270
  }
end

function Form_Activity105Minigame:OnActive()
  self.super.OnActive(self)
  self.m_pnl_tips:SetActive(false)
  self.bIsFinish = false
  self.bIsNeedTimer = true
  self:InitData()
  self:RefreshUI()
  self.angleOffset = 90
  self.fTimer1 = 0
  self.fTimer2 = 0
  self.bIsShowTips = false
  self.m_fx_A:SetActive(false)
  self.m_fx_B:SetActive(false)
  self.m_pnl_tips02:SetActive(false)
  self:addEventListener("eGameEvent_ActMinigame_Finish", handler(self, self.OnMiniGameFinish))
end

function Form_Activity105Minigame:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_Activity105Minigame:OnUpdate(dt)
  if not self.bIsShowTips then
    self.fTimer2 = self.fTimer2 + dt
    if self.fTimer2 >= self.iShowTipsTime then
      self.fTimer2 = 0
      self.bIsShowTips = true
      self.m_pnl_tips02:SetActive(true)
    end
  end
  if self.bIsDragging or not self.bIsNeedTimer then
    return
  end
  self.fTimer1 = self.fTimer1 + dt
  if self.fTimer1 >= self.iWaittingTime then
    self.fTimer1 = 0
    self.m_pnl_tips:SetActive(true)
  end
  self:RemoveDialogueEndHandler()
end

function Form_Activity105Minigame:OnDestroy()
  self.super.OnDestroy(self)
  self:RemoveDialogueEndHandler()
end

function Form_Activity105Minigame:InitData()
  local params = self.m_csui.m_param
  if params then
    local str = params.str
    local temp = string.split(str, ",")
    self.iActId = tonumber(temp[1])
    self.iSubActId = tonumber(temp[2])
    self.iLevelId = tonumber(temp[3])
    params = nil
  end
end

function Form_Activity105Minigame:RefreshUI()
  local cfg = self.m_minigameHelper:GetLegacyStageCfgBySubActIdAndLevelId(self.iSubActId, self.iLevelId)
  if not cfg then
    self:CloseForm()
    return
  end
  self.m_txt_title_Text.text = cfg.m_mPuzzleTItle
  self.m_txt_titledesc_Text.text = cfg.m_mPuzzleDesc
  self.m_txt_tips_Text.text = cfg.m_mPuzzleHint
  local iRightAngle = cfg.m_AnswerID
  self.iSpecialMarkAngle = iRightAngle
end

function Form_Activity105Minigame:OnMiniGameFinish(award)
  self:ShowDialogue(award)
end

function Form_Activity105Minigame:RequestFinishMiniGame()
  if self.bIsFinish then
    return
  end
  self.bIsFinish = true
  local act_data = HeroActivityManager:GetHeroActData(self.iActId)
  if not act_data then
    return
  end
  local stMiniGame = act_data.server_data.stMiniGame
  if stMiniGame.mGameStat[self.iLevelId] ~= 1 then
    HeroActivityManager:ReqHeroActMiniGameFinishCS(self.iActId, self.iSubActId, self.iLevelId)
  else
    self:ShowDialogue()
  end
end

function Form_Activity105Minigame:ShowDialogue(award)
  local cfg = self.m_minigameHelper:GetLegacyStageCfgBySubActIdAndLevelId(self.iSubActId, self.iLevelId)
  if not cfg then
    self:CloseForm()
    return
  end
  self.message = {}
  self.message.vCineVoiceExpressionID = {}
  for i = 1, cfg.m_PlayDialogue.Length do
    table.insert(self.message.vCineVoiceExpressionID, cfg.m_PlayDialogue[i - 1])
  end
  self.message.iIndex = 0
  self.message.bAutoPlay = false
  self.message.bHideBtn = false
  if cfg.m_PlayDialogue.Length > 0 and cfg.m_PlayDialogue[0] == 1 then
    self.message.bHideBtn = true
  end
  self.award = award
  self.dialogueEndHandler = EventCenter.AddListener(EventDefine.eGameEvent_DialogueShowEnd, handler(self, self.OnDialogueEndEvent))
  EventCenter.Broadcast(EventDefine.eGameEvent_DialogueShow, self.message)
  EventCenter.Broadcast(EventDefine.eGameEvent_DialogueChangeSkip, true)
end

function Form_Activity105Minigame:RemoveDialogueEndHandler()
  if self.dialogueEndHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_DialogueShowEnd, self.dialogueEndHandler)
    self.dialogueEndHandler = nil
  end
end

function Form_Activity105Minigame:OnDialogueEndEvent()
  if self.message then
    if self.dialogueEndHandler then
      EventCenter.RemoveListener(EventDefine.eGameEvent_DialogueShowEnd, self.dialogueEndHandler)
      self.dialogueEndHandler = nil
    end
    if self.award and next(self.award) then
      utils.popUpRewardUI(self.award)
      self.award = nil
    end
    self:broadcastEvent("eGameEvent_Legacy_ActivityTreasureBoxOpen")
    self:CloseForm()
  end
end

function Form_Activity105Minigame:OnBeginDrag(pointerEventData)
  self.bIsDragging = true
  self.fTimer1 = 0
  self.m_pnl_tips:SetActive(false)
  local mousePos = CS.UnityEngine.Input.mousePosition
  mousePos = self.m_groupCam:ScreenToWorldPoint(mousePos)
  self.angleOffset = self:GetAngle(mousePos) - self.m_img_clockneedle.transform.eulerAngles.z
end

function Form_Activity105Minigame:OnDrag(pointerEventData)
  if self.bIsDragging then
    local mousePos = CS.UnityEngine.Input.mousePosition
    mousePos = self.m_groupCam:ScreenToWorldPoint(mousePos)
    local targetAngle = self:GetAngle(mousePos) - self.angleOffset
    targetAngle = (targetAngle + 360) % 360
    self.m_img_clockneedle.transform.rotation = CS.UnityEngine.Quaternion.Euler(0, 0, targetAngle)
    local delta = math.abs(targetAngle - self.iSpecialMarkAngle)
    if delta <= self.iDragHintRange / 2 then
      local iPercent = 1 - delta / (self.iDragHintRange / 2)
      self.m_fx_B.transform.localScale = Vector3.one * iPercent
      self.m_fx_B:SetActive(true)
    else
      self.m_fx_B:SetActive(false)
    end
    for index, angle in ipairs(self.mSpecialClockAngle) do
      if math.abs(targetAngle - angle) <= 5 then
        self["m_fx_glow1_" .. index]:SetActive(true)
        self["m_fx_glow2_" .. index]:SetActive(true)
      else
        self["m_fx_glow1_" .. index]:SetActive(false)
        self["m_fx_glow2_" .. index]:SetActive(false)
      end
    end
    self:CheckClockHandRotation(targetAngle)
  end
end

function Form_Activity105Minigame:CheckClockHandRotation(currentAngle)
  if not self.lastFrameAngle then
    self.lastFrameAngle = currentAngle
    return
  end
  local delta = math.abs(self.lastFrameAngle - currentAngle)
  self.lastFrameAngle = currentAngle
  if 1 < delta then
    self.bIsHolding = false
    if not self.bIsPlaying then
      CS.GlobalManager.Instance:TriggerWwiseBGMState(340)
      self.bIsPlaying = true
    end
  else
    if not self.bIsHolding then
      CS.GlobalManager.Instance:TriggerWwiseBGMState(342)
      self.bIsHolding = true
    end
    self.bIsPlaying = false
  end
end

function Form_Activity105Minigame:OnEndBDrag()
  self.bIsDragging = false
  local mousePos = CS.UnityEngine.Input.mousePosition
  mousePos = self.m_groupCam:ScreenToWorldPoint(mousePos)
  local targetAngle = self:GetAngle(mousePos) - self.angleOffset
  targetAngle = (targetAngle + 360) % 360
  local delta = math.abs(targetAngle - self.iSpecialMarkAngle)
  if delta <= self.iDragRightRange / 2 then
    self.bIsNeedTimer = false
    self.m_fx_B:SetActive(false)
    self.m_fx_A:SetActive(true)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(339)
    self:RequestFinishMiniGame()
    self.bIsPlaying = false
    self.bIsHolding = false
  else
    CS.GlobalManager.Instance:TriggerWwiseBGMState(342)
    self.bIsPlaying = false
    self.bIsHolding = false
  end
end

function Form_Activity105Minigame:GetAngle(mousePos)
  local direction = mousePos - self.m_btn_touch.transform.position
  direction:Normalize()
  local angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg
  return (angle + 360) % 360
end

function Form_Activity105Minigame:OnBackClk()
  self:CloseForm()
end

function Form_Activity105Minigame:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity105Minigame", Form_Activity105Minigame)
return Form_Activity105Minigame
