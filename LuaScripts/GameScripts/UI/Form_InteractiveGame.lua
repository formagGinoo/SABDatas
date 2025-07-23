local Form_InteractiveGame = class("Form_InteractiveGame", require("UI/UIFrames/Form_InteractiveGameUI"))
local InteractiveGameDialogIns = ConfigManager:GetConfigInsByName("InteractiveGameDialog")
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local DialogType = {
  DialogStart = 1,
  DialogBtn = 2,
  DialogEnd = 3
}
local DialogBtnState = {Doing = 1, Finish = 2}
local BtnEventLevel = {Important = 0, Normal = 1}

function Form_InteractiveGame:SetInitParam(param)
end

function Form_InteractiveGame:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_isRealShowEnd = false
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
end

function Form_InteractiveGame:OnActive()
  self.super.OnActive(self)
  self.m_btnGroup = nil
  self.m_cur_TextList = {}
  self.m_start_TextList = {}
  self.m_end_TextList = {}
  self.m_space_TextList = {}
  self.m_already_TextList = {}
  self.m_btn_PosList = {}
  self.m_btn_ClickDialogue = {}
  self.m_curInteractiveGame = 0
  self.m_curDialogType = DialogType.DialogStart
  self.m_isCanBtn = false
  self.m_curBtnClickedEventData = nil
  UILuaHelper.SetActive(self.m_btn_temp, false)
  UILuaHelper.SetActive(self.m_btn_Finish, false)
  self.m_isCanClickNormal = true
  self.cur_storyBtnData = {}
  self.m_canClick = true
  CS.GlobalManager.Instance:TriggerWwiseBGMState(315)
  self.dialogueEndHandler = EventCenter.AddListener(EventDefine.eGameEvent_DialogueShowEnd, handler(self, self.OnDialogueEndEvent))
  self:OnRefreshUIData()
  self:OnRefreshUI()
  self:OnDialoguePlay()
  self:BindNormalClick()
end

function Form_InteractiveGame:BindNormalClick()
  local btnExtension = self.m_btn_Normal:GetComponent("ButtonExtensions")
  if btnExtension then
    function btnExtension.Clicked(eventData)
      if not self.m_isCanClickNormal then
        return
      end
      self.m_cur_TextList = self.m_space_TextList
      self:OnDialoguePlay()
      self.m_btn_temp:SetActive(true)
      if not eventData then
        return
      end
      local localPosX, localPosY = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_content_node, eventData.position.x, eventData.position.y, self.m_groupCam)
      if not self.m_btn_temp then
        return
      end
      UILuaHelper.SetLocalPosition(self.m_btn_temp, localPosX, localPosY, 0)
    end
  end
end

function Form_InteractiveGame:OnRefreshUI()
  self:OnRefreshBtn()
end

function Form_InteractiveGame:OnRefreshBtn()
  if not self.parentTransform then
    return
  end
  for i, tempBtnItem in pairs(self.cur_storyBtnData) do
    local itemGroupParentName = self.cur_storyBtnData[i].btnParent
    local btnItem = self.parentTransform:Find(itemGroupParentName)
    if btnItem and not utils.isNull(btnItem) then
      UILuaHelper.SetActive(btnItem, true)
      local itemBtn = btnItem.transform:GetComponent(T_Button)
      local splashTips = btnItem.transform:Find("splashTips")
      UILuaHelper.SetActive(splashTips, false)
      if self.cur_storyBtnData[i].btnLevel == BtnEventLevel.Important then
      else
        UILuaHelper.SetActive(splashTips, false)
      end
      if self.cur_storyBtnData[i].state == DialogBtnState.Finish then
      end
      self.cur_storyBtnData[i].item = btnItem
      self.cur_storyBtnData[i].splashTips = splashTips
      local btnExtension = btnItem:GetComponent("ButtonExtensions")
      if btnExtension then
        function btnExtension.Clicked(eventData)
          self.m_curBtnClickedEventData = self.cur_storyBtnData[i]
          
          local dialogueData = self.m_curBtnClickedEventData
          if dialogueData.state == DialogBtnState.Doing then
            self.m_cur_TextList = dialogueData.textList
          else
            self.m_cur_TextList = self.m_already_TextList
          end
          self.m_curDialogType = DialogType.DialogBtn
          self:OnDialoguePlay()
          self.m_btn_temp:SetActive(true)
          self.m_btn_temp:SetActive(true)
          if not eventData then
            return
          end
          local localPosX, localPosY = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_content_node, eventData.position.x, eventData.position.y, self.m_groupCam)
          if not self.m_btn_temp then
            return
          end
          UILuaHelper.SetLocalPosition(self.m_btn_temp, localPosX, localPosY, 0)
        end
      end
    end
  end
end

function Form_InteractiveGame:OnRefreshUIData()
  if self.m_csui.m_param then
    self.m_dialogId = self.m_csui.m_param.dialogId or 1
    self.onCloseCallBack = self.m_csui.m_param.finishFc
    self.m_csui.m_param = nil
  end
  local cfg = InteractiveGameDialogIns:GetValue_ByID(self.m_dialogId)
  local childCount = self.m_contenBg.transform.childCount
  for i = 0, childCount - 1 do
    local child = self.m_contenBg.transform:GetChild(i)
    child.gameObject:SetActive(false)
  end
  self.m_btnGroupName = cfg.m_ButtonGroupName
  self.m_btnGroup = self.m_contenBg.transform:Find(cfg.m_ButtonGroupName)
  if self.m_btnGroup and not utils.isNull(self.m_btnGroup) then
    self.parentTransform = self.m_btnGroup
    UILuaHelper.SetActive(self.m_btnGroup, true)
  end
  self.m_start_TextList = utils.changeCSArrayToLuaTable(cfg.m_StartDialogue)
  if 0 < #self.m_start_TextList then
    self.m_isCanBtn = false
  end
  self.m_end_TextList = utils.changeCSArrayToLuaTable(cfg.m_EndDialogue)
  self.m_isRealShowEnd = 0 < table.getn(self.m_end_TextList)
  self.m_space_TextList = utils.changeCSArrayToLuaTable(cfg.m_SpaceDialogue)
  self.m_already_TextList = utils.changeCSArrayToLuaTable(cfg.m_FinishDialogue)
  self.m_cur_TextList = self.m_start_TextList
  self.m_btn_ClickDialogue = utils.changeCSArrayToLuaTable(cfg.m_PlayDialogue)
  for i = 1, #self.m_btn_ClickDialogue do
    local detailData = self.m_btn_ClickDialogue[i]
    local btnParentName = detailData[1]
    LocalDataManager:SetIntSimple(self.m_btnGroupName .. "FinDialogueText", DialogBtnState.Doing)
    self:SetBtnState(btnParentName, DialogBtnState.Doing)
  end
  for i = 1, #self.m_btn_ClickDialogue do
    local detailData = self.m_btn_ClickDialogue[i]
    local btnLevel = tonumber(detailData[2])
    local btnParentName = detailData[1]
    local tempTextList = {}
    local state = self:CheckBtnState(btnParentName)
    for i = 3, #detailData do
      table.insert(tempTextList, detailData[i])
    end
    local totalData = {
      btnParent = btnParentName,
      state = state,
      btnLevel = btnLevel,
      textList = tempTextList
    }
    table.insert(self.cur_storyBtnData, totalData)
  end
end

function Form_InteractiveGame:OnDialogueEndEvent()
  self.m_btn_temp:SetActive(false)
  if self.message then
    if self.dialogueEndHandler then
      self.m_cur_TextList = {}
    end
    self.message = nil
  end
  if self.m_curDialogType == DialogType.DialogStart then
    UILuaHelper.SetActive(self.m_btn_Tips, true)
    self.m_isCanBtn = true
  end
  if self.m_curDialogType == DialogType.DialogBtn then
    self.m_curBtnClickedEventData.state = DialogBtnState.Finish
    self:SetBtnState(self.m_curBtnClickedEventData.btnParent, DialogBtnState.Finish)
    self:RefreshBtnState()
    if self.m_isRealShowEnd then
      self:CheckCurStoryIsAllFinish()
      return
    else
      self:CheckCurStoryIsAllFinish()
    end
  end
  if self.m_curDialogType == DialogType.DialogEnd then
    LocalDataManager:SetIntSimple(self.m_btnGroupName .. "FinDialogueText", DialogBtnState.Finish)
    if self.m_btn_Tips then
      UILuaHelper.SetActive(self.m_btn_Tips, false)
    end
    if self.m_btn_Finish then
      UILuaHelper.SetActive(self.m_btn_Finish, true)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(313)
    end
    self.m_isCanClickNormal = false
    if self.closeTimer then
      TimeService:KillTimer(self.closeTimer)
      self.closeTimer = nil
    end
    if self.m_csui and not self.m_isRealShowEnd then
      self.closeTimer = TimeService:SetTimer(1, 1, function()
        UILuaHelper.PlayAnimationByName(self.m_rootTrans, "Activity103_InteractiveGame_out")
        self.timer = TimeService:SetTimer(0.2, 1, function()
          if self.timer then
            TimeService:KillTimer(self.timer)
            self.timer = nil
          end
          self:CloseForm()
          if self.onCloseCallBack then
            self.onCloseCallBack()
          end
          return
        end)
      end)
    end
  end
end

function Form_InteractiveGame:RefreshBtnState()
  if self.m_curBtnClickedEventData and self.m_curBtnClickedEventData.alreadyTips and not utils.isNull(self.m_curBtnClickedEventData.alreadyTips) then
    UILuaHelper.SetActive(self.m_curBtnClickedEventData.alreadyTips, true)
  end
end

function Form_InteractiveGame:OnDialoguePlay(isEnd)
  if isEnd then
    self.m_curDialogType = DialogType.DialogEnd
    self.m_isShowEnd = true
  end
  self.message = {}
  self.message.vCineVoiceExpressionID = self.m_cur_TextList or {}
  self.message.iIndex = 0
  self.message.bAutoPlay = false
  self.message.bHideBtn = true
  EventCenter.Broadcast(EventDefine.eGameEvent_DialogueShow, self.message)
  local obj = CS.UnityEngine.GameObject.Find("Form_Dialogue")
  if obj then
    local canvas = obj:GetComponent("Canvas")
    if canvas and canvas.sortingOrder and self.m_csui.SortingOrder and canvas.sortingOrder < self.m_csui.SortingOrder then
      self.m_csui.SortingOrder = canvas.sortingOrder - 1
    end
  end
end

function Form_InteractiveGame:OnInactive()
  self.super.OnInactive(self)
  self:ClearTimer()
  if self.dialogueEndHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_DialogueShowEnd, self.dialogueEndHandler)
    self.dialogueEndHandler = nil
  end
end

function Form_InteractiveGame:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_InteractiveGame:OnBtnTipsClicked()
  if not self.m_canClick then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(314)
  self.m_canClick = false
  if self.clickTimerLock then
    TimeService:KillTimer(self.clickTimerLock)
    self.clickTimerLock = nil
  end
  self.clickTimerLock = TimeService:SetTimer(1.5, 1, function()
    self.m_canClick = true
    if self.clickTimerLock then
      TimeService:KillTimer(self.clickTimerLock)
      self.clickTimerLock = nil
    end
  end)
  for i = 1, #self.cur_storyBtnData do
    if self["TipsTimer" .. i] then
      TimeService:KillTimer(self["TipsTimer" .. i])
      self["TipsTimer" .. i] = nil
    end
    if self.cur_storyBtnData[i].btnLevel == BtnEventLevel.Important and self.cur_storyBtnData[i].state == DialogBtnState.Doing then
      UILuaHelper.SetActive(self.cur_storyBtnData[i].splashTips, true)
      self["TipsTimer" .. i] = TimeService:SetTimer(2, 1, function()
        UILuaHelper.SetActive(self.cur_storyBtnData[i].splashTips, false)
        if self["TipsTimer" .. i] then
          TimeService:KillTimer(self["TipsTimer" .. i])
          self["TipsTimer" .. i] = nil
        end
      end)
    end
  end
end

function Form_InteractiveGame:ClearTimer()
  if self.TipsTimer then
    TimeService:KillTimer(self.TipsTimer)
    self.TipsTimer = nil
  end
  if self.closeTimer then
    TimeService:KillTimer(self.closeTimer)
    self.closeTimer = nil
  end
  if self.clickTimerLock then
    TimeService:KillTimer(self.clickTimerLock)
    self.clickTimerLock = nil
  end
  for i = 1, #self.cur_storyBtnData do
    if self["TipsTimer" .. i] then
      TimeService:KillTimer(self["TipsTimer" .. i])
      self["TipsTimer" .. i] = nil
    end
  end
  if self.timer then
    TimeService:KillTimer(self.timer)
    self.timer = nil
  end
end

function Form_InteractiveGame:OnEnterClearLocalData()
  for i = 1, #self.cur_storyBtnData do
    self.cur_storyBtnData[i].state = DialogBtnState.Doing
  end
end

function Form_InteractiveGame:OnBtnNormalClicked()
end

function Form_InteractiveGame:CheckBtnState(btnName)
  local btnState = DialogBtnState.Doing
  btnState = LocalDataManager:GetIntSimple(self.m_btnGroupName .. btnName, DialogBtnState.Doing)
  return btnState
end

function Form_InteractiveGame:SetBtnState(btnName, state)
  LocalDataManager:SetIntSimple(self.m_btnGroupName .. btnName, state)
end

function Form_InteractiveGame:CheckCurStoryIsAllFinish()
  local finTextState = LocalDataManager:GetIntSimple(self.m_btnGroupName .. "FinDialogueText", DialogBtnState.Doing)
  if finTextState == DialogBtnState.Finish then
    return
  end
  local isAllFinish = true
  for i = 1, #self.cur_storyBtnData do
    if self.cur_storyBtnData[i].btnLevel == BtnEventLevel.Important and DialogBtnState.Doing == self.cur_storyBtnData[i].state then
      isAllFinish = false
      break
    end
  end
  if isAllFinish and self.m_isRealShowEnd then
    self.m_cur_TextList = {}
    if table.getn(self.m_end_TextList) > 0 then
      self.m_isRealShowEnd = false
      self.m_cur_TextList = self.m_end_TextList
      self:OnDialoguePlay(true)
      return
    end
  end
  if isAllFinish then
    self.m_curDialogType = DialogType.DialogEnd
  end
end

local fullscreen = true
ActiveLuaUI("Form_InteractiveGame", Form_InteractiveGame)
return Form_InteractiveGame
