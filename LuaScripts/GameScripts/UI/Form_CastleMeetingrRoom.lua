local Form_CastleMeetingrRoom = class("Form_CastleMeetingrRoom", require("UI/UIFrames/Form_CastleMeetingrRoomUI"))
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local MaxHeroCount = 5
local DialogueType = {
  Start = 1,
  End = 2,
  Solo = 3
}

function Form_CastleMeetingrRoom:SetInitParam(param)
end

function Form_CastleMeetingrRoom:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnHomeClk), 1180)
end

function Form_CastleMeetingrRoom:OnActive()
  self.super.OnActive(self)
  self.bIsdialguing = false
  self.bOriAutoDialogue = StoryManager:getAutoStatus()
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(195)
end

function Form_CastleMeetingrRoom:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if self.dialogueEndHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_DialogueShowEnd, self.dialogueEndHandler)
    self.dialogueEndHandler = nil
  end
  self:CheckKillTimer()
  StoryManager:setAutoStatus(self.bOriAutoDialogue)
end

function Form_CastleMeetingrRoom:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleMeetingrRoom:AddEventListeners()
  self:addEventListener("eGameEvent_LoadCouncilHallRoleStart", handler(self, self.OnLoadCouncilHallHeroStart))
  self:addEventListener("eGameEvent_LoadCouncilHallRoleFinish", handler(self, self.OnLoadCouncilHallHeroEnd))
  self:addEventListener("eGameEvent_OnRolePlayDialogue", handler(self, self.OnHeroSaying))
  self:addEventListener("eGameEvent_OnAttract_GetAttract", handler(self, self.OnDailyReset))
end

function Form_CastleMeetingrRoom:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CastleMeetingrRoom:OnDailyReset()
  if self.bIsdialguing then
    return
  end
  self:FreshData()
  self:FreshUI()
end

function Form_CastleMeetingrRoom:OnLoadCouncilHallHeroStart()
  self.m_pnl_invitewaiting:SetActive(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(190)
end

function Form_CastleMeetingrRoom:OnLoadCouncilHallHeroEnd()
  self.m_pnl_invitewaiting:SetActive(false)
end

function Form_CastleMeetingrRoom:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    local m_placeCfg = CastleManager:GetCastlePlaceCfgByID(tParam.placeID)
    self.m_widgetBtnBack:SetExplainID(m_placeCfg.m_Tips)
    self.m_csui.m_param = nil
  end
  local stCouncil = CouncilHallManager:GetCouncilData()
  self.vDailyIssue = stCouncil.vDailyIssue
  self.iChosenIssue = stCouncil.iChosenIssue
  self.vHero = stCouncil.vHero
  self.curIssueIdx = 1
  self.curIssue = self.iChosenIssue and self.iChosenIssue > 0 and self.iChosenIssue or self.vDailyIssue[self.curIssueIdx]
end

function Form_CastleMeetingrRoom:FreshUI()
  self:ResetUI()
  self:FreshIssueInfo()
end

function Form_CastleMeetingrRoom:ResetUI()
  self.m_pnl_meetingentered:SetActive(true)
  self.m_pnl_meetingstart:SetActive(false)
  self.m_pnl_invitewaiting:SetActive(false)
  self.m_img_bg_meeing:SetActive(false)
  self.m_messageRoot:SetActive(true)
  self.m_favorabilityRoot:SetActive(true)
  self.m_meeting_dialogue:SetActive(false)
  for i = 1, MaxHeroCount do
    self["m_btn_message" .. i]:SetActive(false)
    self["m_img_favorability" .. i]:SetActive(false)
    self["m_icon_speak" .. i]:SetActive(false)
    self["m_UIFX_yes" .. i]:SetActive(false)
    self["m_UIFX_no" .. i]:SetActive(false)
    self["m_UIFX_shock" .. i]:SetActive(false)
  end
end

function Form_CastleMeetingrRoom:FreshIssueInfo()
  if self.iChosenIssue and self.iChosenIssue > 0 then
    self.m_btn_refesh:SetActive(false)
    self.m_btn_end:SetActive(true)
    self.m_btn_chooserole:SetActive(false)
    self.m_btn_start_grey:SetActive(true)
    self.m_btn_start_normal:SetActive(false)
  else
    self.m_btn_refesh:SetActive(true)
    self.m_btn_end:SetActive(false)
    self.m_btn_chooserole:SetActive(true)
    if self.vHero and 0 < #self.vHero then
      self.m_btn_start_grey:SetActive(false)
      self.m_btn_start_normal:SetActive(true)
    else
      self.m_btn_start_grey:SetActive(true)
      self.m_btn_start_normal:SetActive(false)
    end
  end
  local cfg = CouncilHallManager:GetCouncilHallIssueCfgByID(self.curIssue)
  self.m_txt_meetingcontent_Text.text = cfg.m_mIssue
  self.m_txt_meetingcontent02_Text.text = cfg.m_mIssue
  self.m_txt_meeting_Text.text = cfg.m_mIssue
  self.m_txt_title_Text.text = cfg.m_mAgreeText
  self.m_txt_title02_Text.text = cfg.m_mNeutralText
  self.m_txt_title03_Text.text = cfg.m_mDisgreeText
end

function Form_CastleMeetingrRoom:SetHeroMessageShow(hero_id)
  for index, v in ipairs(self.vHero) do
    local trueIdx = self:HeroIdx2TopUIIdx(index)
    self["m_icon_speak" .. trueIdx]:SetActive(hero_id == v)
  end
end

function Form_CastleMeetingrRoom:HeroIdx2TopUIIdx(index)
  local poscfg = CouncilHallManager:GetCouncilHallPositionByCount(#self.vHero)
  local positionList = utils.changeCSArrayToLuaTable(poscfg.m_PositionList)
  return positionList[index]
end

function Form_CastleMeetingrRoom:CheckAndShowMascotAction(idx)
  local mascotList = CouncilHallManager:GetMascotList()
  local curObj = mascotList[idx]
  if not self.curShowActionIdx then
    UILuaHelper.PlayAnimatorByNameInChildren(curObj, "show_speak_Start")
    self.curShowActionIdx = idx
    return
  end
  if self.curShowActionIdx ~= idx then
    local preObj = mascotList[self.curShowActionIdx]
    UILuaHelper.PlayAnimatorByNameInChildren(preObj, "show_speak_End")
    UILuaHelper.PlayAnimatorByNameInChildren(curObj, "show_speak_Start")
    self.curShowActionIdx = idx
  end
end

function Form_CastleMeetingrRoom:TopUIIdx2HeroIdx(index)
  local poscfg = CouncilHallManager:GetCouncilHallPositionByCount(#self.vHero)
  local positionList = utils.changeCSArrayToLuaTable(poscfg.m_PositionList)
  for i, v in ipairs(positionList) do
    if v == index then
      return i
    end
  end
end

function Form_CastleMeetingrRoom:CheckKillTimer()
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
  self.m_UILockID = nil
end

function Form_CastleMeetingrRoom:StartDialogue()
  self.m_pnl_meetingentered:SetActive(false)
  self.m_pnl_meetingstart:SetActive(true)
  self.m_img_bg_meeing:SetActive(true)
  self.bIsdialguing = true
  self.timer = TimeService:SetTimer(2, 1, function()
    self:PlayText(DialogueType.Start)
  end)
end

function Form_CastleMeetingrRoom:PlayText(type, param)
  self.m_pnl_meetingstart:SetActive(false)
  local textList, textToHeroIDList, mHeroId2TextList
  if type == DialogueType.Start then
    textList, textToHeroIDList, mHeroId2TextList = CouncilHallManager:GetCurIssueStartText(self.curIssue)
    self.mHeroId2TextList = mHeroId2TextList
    self.m_img_bg_meeing:SetActive(true)
    self.curShowActionIdx = nil
  elseif type == DialogueType.End then
    self.mHeroId2TextList = {}
    textList, textToHeroIDList = CouncilHallManager:GetCurIssueEndRoleAndText(self.curIssue, param)
  elseif type == DialogueType.Solo then
    textList = param
    self.m_meeting_dialogue:SetActive(false)
  end
  self.curDialogueType = type
  self.textToHeroIDList = textToHeroIDList
  self.message = {}
  self.message.vCineVoiceExpressionID = textList or {}
  self.message.iIndex = 0
  self.message.bAutoPlay = false
  self.message.bHideBtn = true
  StoryManager:setAutoStatus(false)
  self.dialogueEndHandler = EventCenter.AddListener(EventDefine.eGameEvent_DialogueShowEnd, handler(self, self.OnDialogueEndEvent))
  EventCenter.Broadcast(EventDefine.eGameEvent_DialogueShow, self.message)
  EventCenter.Broadcast(EventDefine.eGameEvent_DialogueChangeSkip, true)
end

function Form_CastleMeetingrRoom:OnHeroSaying(textstr)
  if self.curDialogueType == DialogueType.Start then
    local hero_id = self.textToHeroIDList[textstr]
    self:SetHeroMessageShow(hero_id)
    self:CheckAndShowMascotAction(hero_id)
  elseif self.curDialogueType == DialogueType.End then
    local data = self.textToHeroIDList[textstr]
    if data then
      for i = 1, MaxHeroCount do
        self["m_img_favorability" .. i]:SetActive(false)
        self["m_UIFX_yes" .. i]:SetActive(false)
        self["m_UIFX_no" .. i]:SetActive(false)
        self["m_UIFX_shock" .. i]:SetActive(false)
      end
      local heroObjList = CouncilHallManager:GetShowHeroList()
      local hero_id = data.heroData.iHeroId
      for index, id in ipairs(self.vHero) do
        if id == hero_id then
          local trueIdx = self:HeroIdx2TopUIIdx(index)
          self["m_txt_favorability" .. trueIdx .. "_Text"].text = "+" .. data.heroData.iAddExp
          self["m_img_favorability" .. trueIdx]:SetActive(true)
          local obj = heroObjList[index]
          if data.ResultType == MTTDProto.CouncilHeroResultType_Same or data.ResultType == MTTDProto.CouncilHeroResultType_Critical then
            UILuaHelper.PlayAnimatorByNameInChildren(obj, "show_yes")
            if data.ResultType == MTTDProto.CouncilHeroResultType_Same then
              self["m_UIFX_yes" .. trueIdx]:SetActive(true)
              CS.GlobalManager.Instance:TriggerWwiseBGMState(192)
            else
              self["m_UIFX_shock" .. trueIdx]:SetActive(true)
              CS.GlobalManager.Instance:TriggerWwiseBGMState(194)
            end
          else
            UILuaHelper.PlayAnimatorByNameInChildren(obj, "show_no")
            self["m_UIFX_no" .. trueIdx]:SetActive(true)
            CS.GlobalManager.Instance:TriggerWwiseBGMState(193)
          end
        end
      end
    end
  elseif self.curDialogueType == DialogueType.Solo then
  end
end

function Form_CastleMeetingrRoom:OnDialogueEndEvent()
  if self.message then
    if self.dialogueEndHandler then
      EventCenter.RemoveListener(EventDefine.eGameEvent_DialogueShowEnd, self.dialogueEndHandler)
      self.dialogueEndHandler = nil
    end
    self.message = nil
  end
  if self.curDialogueType == DialogueType.Start then
    self.m_meeting_dialogue:SetActive(true)
    for index, v in ipairs(self.vHero) do
      local trueIdx = self:HeroIdx2TopUIIdx(index)
      self["m_icon_speak" .. trueIdx]:SetActive(false)
      self["m_btn_message" .. trueIdx]:SetActive(true)
    end
    CS.GlobalManager.Instance:TriggerWwiseBGMState(191)
  elseif self.curDialogueType == DialogueType.End then
    self:CheckAndPushLevelUp()
    self.iChosenIssue = self.curIssue
    self:FreshUI()
  elseif self.curDialogueType == DialogueType.Solo then
    self.m_meeting_dialogue:SetActive(true)
  end
end

function Form_CastleMeetingrRoom:ShowHeroSoloDialogue(idx)
  local trueIdx = self:TopUIIdx2HeroIdx(idx)
  local heroid = self.vHero[trueIdx]
  local textList = self.mHeroId2TextList[heroid]
  if textList then
    self:PlayText(DialogueType.Solo, textList)
  end
end

function Form_CastleMeetingrRoom:CheckAndPushLevelUp()
  local data = self.LevelUpHeroList and self.LevelUpHeroList[1] or nil
  if not data then
    return
  end
  table.remove(self.LevelUpHeroList, 1)
  local newRank = data.m_newRank
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTLEVELUP, {
    curShowHeroData = data.heroData,
    iOldRank = data.m_oldRank,
    iNewRank = newRank,
    callback = function()
      self:CheckAndPushLevelUp()
    end
  })
end

function Form_CastleMeetingrRoom:RqsEndCouncil(councilOpinionType)
  self.mOldRankList = {}
  for i, hero_id in ipairs(self.vHero) do
    local m_curShowHeroData = HeroManager:GetHeroDataByID(hero_id)
    local m_oldRank = m_curShowHeroData.serverData.iAttractRank
    self.mOldRankList[hero_id] = m_oldRank
  end
  CouncilHallManager:RqsEndCouncil(self.curIssue, councilOpinionType, handler(self, self.StartEndFlow))
  self.m_meeting_dialogue:SetActive(false)
end

function Form_CastleMeetingrRoom:StartEndFlow(vHeroResult)
  self:PlayText(DialogueType.End, vHeroResult)
  for i = 1, MaxHeroCount do
    self["m_btn_message" .. i]:SetActive(false)
    self["m_icon_speak" .. i]:SetActive(false)
  end
  self.LevelUpHeroList = {}
  for i, hero_id in ipairs(self.vHero) do
    local m_curShowHeroData = HeroManager:GetHeroDataByID(hero_id)
    local m_newRank = m_curShowHeroData.serverData.iAttractRank
    local m_oldRank = self.mOldRankList[hero_id]
    if m_newRank ~= m_oldRank then
      self.LevelUpHeroList[#self.LevelUpHeroList + 1] = {
        heroData = m_curShowHeroData,
        m_oldRank = m_oldRank,
        m_newRank = m_newRank
      }
    end
  end
end

function Form_CastleMeetingrRoom:OnBackClk()
  self:CloseForm()
  ModuleManager:GetModuleByName("CastleModule"):EnterModule()
end

function Form_CastleMeetingrRoom:OnHomeClk()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_CastleMeetingrRoom:OnBtnchooseroleClicked()
  StackFlow:Push(UIDefines.ID_FORM_CASTLEMEETINGPOP)
end

function Form_CastleMeetingrRoom:OnBtnrefeshClicked()
  if self.curIssueIdx >= #self.vDailyIssue then
    self.curIssueIdx = 1
  else
    self.curIssueIdx = self.curIssueIdx + 1
  end
  local iIssue = self.vDailyIssue[self.curIssueIdx]
  if self.curIssue == iIssue then
    return
  end
  self.curIssue = iIssue
  self.m_UIFX_mask:SetActive(true)
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_UIFX_mask, "Room_mask")
  TimeService:SetTimer(aniLen, 1, function()
    self.m_UIFX_mask:SetActive(false)
    self:CheckKillTimer()
  end)
  self.m_UILockID = UILockIns:Lock(aniLen)
  TimeService:SetTimer(0.5, 1, function()
    self:FreshIssueInfo()
  end)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(187)
end

function Form_CastleMeetingrRoom:OnBtnstartnormalClicked()
  local full_hero_cfg = false
  for i, hero_id in ipairs(self.vHero) do
    local m_curShowHeroData = HeroManager:GetHeroDataByID(hero_id)
    local m_expList = AttractManager:GetExpList(m_curShowHeroData.characterCfg.m_AttractRankTemplate)
    local maxRank = #m_expList
    local m_oldRank = m_curShowHeroData.serverData.iAttractRank
    if maxRank <= m_oldRank then
      full_hero_cfg = m_curShowHeroData.characterCfg
      break
    end
  end
  
  local function is_full_attract()
    if full_hero_cfg then
      utils.popUpDirectionsUI({
        tipsID = 1192,
        fContentCB = function(content)
          return string.gsubnumberreplace(content, full_hero_cfg.m_mName)
        end,
        func1 = function()
          CouncilHallManager:RqsStartCouncil(function()
            self:StartDialogue()
          end)
        end
      })
    else
      CouncilHallManager:RqsStartCouncil(function()
        self:StartDialogue()
      end)
    end
  end
  
  if #self.vHero < MaxHeroCount then
    utils.popUpDirectionsUI({
      tipsID = 1191,
      func1 = function()
        is_full_attract()
      end
    })
  else
    is_full_attract()
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(186)
end

function Form_CastleMeetingrRoom:OnBtnstartgreyClicked()
  if self.iChosenIssue and self.iChosenIssue > 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(47002))
    return
  end
  if not self.vHero or 0 >= #self.vHero then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(47001))
    return
  end
end

function Form_CastleMeetingrRoom:OnBtnskipTipsClicked()
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
    self:PlayText(DialogueType.Start)
  end
end

function Form_CastleMeetingrRoom:OnBtndialogueClicked()
  self:RqsEndCouncil(MTTDProto.CouncilOpinionType_Agree)
end

function Form_CastleMeetingrRoom:OnBtndialogue02Clicked()
  self:RqsEndCouncil(MTTDProto.CouncilOpinionType_Neutral)
end

function Form_CastleMeetingrRoom:OnBtndialogue03Clicked()
  self:RqsEndCouncil(MTTDProto.CouncilOpinionType_Disagree)
end

function Form_CastleMeetingrRoom:OnBtnmessage1Clicked()
  self:ShowHeroSoloDialogue(1)
end

function Form_CastleMeetingrRoom:OnBtnmessage2Clicked()
  self:ShowHeroSoloDialogue(2)
end

function Form_CastleMeetingrRoom:OnBtnmessage3Clicked()
  self:ShowHeroSoloDialogue(3)
end

function Form_CastleMeetingrRoom:OnBtnmessage4Clicked()
  self:ShowHeroSoloDialogue(4)
end

function Form_CastleMeetingrRoom:OnBtnmessage5Clicked()
  self:ShowHeroSoloDialogue(5)
end

function Form_CastleMeetingrRoom:OnBtnMascot1Clicked()
  self:ShowMascotClickAction(1)
end

function Form_CastleMeetingrRoom:OnBtnMascot2Clicked()
  self:ShowMascotClickAction(2)
end

function Form_CastleMeetingrRoom:ShowMascotClickAction(idx)
  local mascotList = CouncilHallManager:GetMascotList()
  local curObj = mascotList[idx]
  UILuaHelper.PlayAnimatorByNameInChildren(curObj, "Show_click")
end

function Form_CastleMeetingrRoom:IsFullScreen()
  return true
end

function Form_CastleMeetingrRoom:GetDownloadResourceExtra()
  local heroList = CouncilHallManager:GetCouncilHero()
  local vPackage = {}
  for i, heroid in ipairs(heroList) do
    vPackage[#vPackage + 1] = {
      sName = tostring(heroid),
      eType = DownloadManager.ResourcePackageType.Level_Character
    }
  end
  return vPackage, nil
end

local fullscreen = true
ActiveLuaUI("Form_CastleMeetingrRoom", Form_CastleMeetingrRoom)
return Form_CastleMeetingrRoom
