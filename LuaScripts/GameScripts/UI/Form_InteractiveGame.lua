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
local BtnEventLevel = {Normal = 0, Important = 1}

function Form_InteractiveGame:SetInitParam(param)
end

function Form_InteractiveGame:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
end

function Form_InteractiveGame:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
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
  self.parentTransform = self.m_storyBg.transform
  self.m_clearBtnItemPool = {}
  self.m_tempCacheBtn = {}
  self.m_curDialogType = DialogType.DialogStart
  self.m_isCanBtn = false
  self.m_curBtnClickedEventData = nil
  UILuaHelper.SetActive(self.m_btn_temp, false)
  UILuaHelper.SetActive(self.m_btn_Finish, false)
  self.cur_storyBtnData = {}
  self:OnRefreshUIData()
  self:OnRefreshUI()
  self:OnDialoguePlay()
end

function Form_InteractiveGame:OnRefreshUI()
  self:ClearBtnItemPool()
  self:OnRefreshBtn()
end

function Form_InteractiveGame:ClearBtnItemPool()
  for i, tempBtnItem in pairs(self.m_clearBtnItemPool) do
    tempBtnItem.transform.parent = self.parentTransform
    UILuaHelper.SetActive(tempBtnItem, false)
    table.insert(self.m_tempCacheBtn, tempBtnItem)
  end
  for i, tempBtnItem in pairs(self.m_tempCacheBtn) do
    local splashTips = tempBtnItem.transform:Find("splashTips")
    local alreadyTips = tempBtnItem.transform:Find("alreadyTips")
    UILuaHelper.SetActive(splashTips, false)
    UILuaHelper.SetActive(alreadyTips, false)
    UILuaHelper.SetActive(tempBtnItem, false)
  end
end

function Form_InteractiveGame:OnRefreshBtn()
  if #self.m_tempCacheBtn < #self.cur_storyBtnData then
    for index = #self.m_tempCacheBtn, #self.cur_storyBtnData - 1 do
      local tempItem = GameObject.Instantiate(self.m_btn_temp, self.parentTransform)
      if tempItem and not utils.isNull(tempItem) then
        UILuaHelper.SetActive(tempItem, false)
        table.insert(self.m_tempCacheBtn, tempItem)
      end
    end
  end
  for i, tempBtnItem in pairs(self.cur_storyBtnData) do
    local btnItem = self.m_tempCacheBtn[1]
    table.remove(self.m_tempCacheBtn, 1)
    table.insert(self.m_clearBtnItemPool, btnItem)
    if btnItem and not utils.isNull(btnItem) then
      UILuaHelper.SetActive(btnItem, true)
      local itemGroupParentName = self.cur_storyBtnData[i].btnParent
      local itemGroupParentTran = self.m_btnGroup.transform:Find(itemGroupParentName).transform
      btnItem.transform.parent = itemGroupParentTran
      UILuaHelper.SetLocalPosition(btnItem.transform, 0, 0, 0)
      local itemBtn = btnItem.transform:GetComponent(T_Button)
      local splashTips = btnItem.transform:Find("splashTips")
      local alreadyTips = btnItem.transform:Find("alreadyTips")
      UILuaHelper.SetActive(splashTips, false)
      UILuaHelper.SetActive(alreadyTips, false)
      if self.cur_storyBtnData[i].btnLevel == BtnEventLevel.Important then
      else
        UILuaHelper.SetActive(splashTips, false)
      end
      if self.cur_storyBtnData[i].state == DialogBtnState.Finish then
        UILuaHelper.SetActive(alreadyTips, true)
      end
      self.cur_storyBtnData[i].item = btnItem
      self.cur_storyBtnData[i].splashTips = splashTips
      self.cur_storyBtnData[i].alreadyTips = alreadyTips
      btnItem.transform.sizeDelta = Vector2.New(self.cur_storyBtnData[i].width, self.cur_storyBtnData[i].height)
      UILuaHelper.BindButtonClickManual(itemBtn, function()
        self:OnBindBtnEvent(self.cur_storyBtnData[i])
      end)
    end
  end
end

function Form_InteractiveGame:OnBindBtnEvent(dialogueData)
  self.m_curBtnClickedEventData = dialogueData
  if dialogueData.state == DialogBtnState.Doing then
    self.m_cur_TextList = dialogueData.textList
  else
    self.m_cur_TextList = self.m_already_TextList
  end
  self.m_curDialogType = DialogType.DialogBtn
  self:OnDialoguePlay()
end

function Form_InteractiveGame:OnRefreshUIData()
  if self.m_csui.m_param then
    self.m_dialogId = self.m_csui.m_param.dialogId or 1
    self.onCloseCallBack = self.m_csui.m_param.finishFc
    self.m_csui.m_param = nil
  end
  local cfg = InteractiveGameDialogIns:GetValue_ByID(self.m_dialogId)
  self.m_btnGroupName = cfg.m_ButtonGroupName
  self.m_btnGroup = self.parentTransform:Find(cfg.m_ButtonGroupName)
  if self.m_btnGroup and not utils.isNull(self.m_btnGroup) then
    UILuaHelper.SetActive(self.m_btnGroup, true)
  end
  self.m_start_TextList = utils.changeCSArrayToLuaTable(cfg.m_StartDialogue)
  if #self.m_start_TextList > 0 then
    self.m_isCanBtn = false
  end
  self.m_end_TextList = utils.changeCSArrayToLuaTable(cfg.m_EndDialogue)
  self.m_space_TextList = utils.changeCSArrayToLuaTable(cfg.m_SpaceDialogue)
  self.m_already_TextList = utils.changeCSArrayToLuaTable(cfg.m_FinishDialogue)
  self.m_cur_TextList = self.m_start_TextList
  self.m_btn_PosList = utils.changeCSArrayToLuaTable(cfg.m_Scale)
  self.m_btn_ClickDialogue = utils.changeCSArrayToLuaTable(cfg.m_PlayDialogue)
  for i = 1, #self.m_btn_PosList do
    local data = self.m_btn_PosList[i]
    local btnParentName = data[1]
    local btnWidth = tonumber(data[2])
    local btnHeight = tonumber(data[3])
    local detailData = self.m_btn_ClickDialogue[i]
    local btnLevel = tonumber(detailData[2])
    local tempTextList = {}
    local state = self:CheckBtnState(btnParentName)
    for i = 3, #detailData do
      table.insert(tempTextList, detailData[i])
    end
    local totalData = {
      btnParent = btnParentName,
      state = state,
      width = btnWidth,
      height = btnHeight,
      btnLevel = btnLevel,
      textList = tempTextList
    }
    table.insert(self.cur_storyBtnData, totalData)
  end
end

function Form_InteractiveGame:OnDialogueEndEvent()
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
    self:CheckCurStoryIsAllFinish()
  end
  if self.m_curDialogType == DialogType.DialogEnd then
    LocalDataManager:SetIntSimple(self.m_btnGroupName .. "FinDialogueText", DialogBtnState.Finish)
    UILuaHelper.SetActive(self.m_btn_Tips, false)
    UILuaHelper.SetActive(self.m_btn_Finish, true)
  end
end

function Form_InteractiveGame:RefreshBtnState()
  if self.m_curBtnClickedEventData and self.m_curBtnClickedEventData.alreadyTips and not utils.isNull(self.m_curBtnClickedEventData.alreadyTips) then
    UILuaHelper.SetActive(self.m_curBtnClickedEventData.alreadyTips, true)
  end
end

function Form_InteractiveGame:OnDialoguePlay(isEnd)
  self.message = {}
  self.message.vCineVoiceExpressionID = self.m_cur_TextList or {}
  self.message.iIndex = 0
  self.message.bAutoPlay = false
  self.message.bHideBtn = true
  self.dialogueEndHandler = EventCenter.AddListener(EventDefine.eGameEvent_DialogueShowEnd, handler(self, self.OnDialogueEndEvent))
  EventCenter.Broadcast(EventDefine.eGameEvent_DialogueShow, self.message)
end

function Form_InteractiveGame:OnInactive()
  self.super.OnInactive(self)
  if self.dialogueEndHandler then
    EventCenter.RemoveListener(EventDefine.eGameEvent_DialogueShowEnd, self.dialogueEndHandler)
    self.dialogueEndHandler = nil
  end
end

function Form_InteractiveGame:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_InteractiveGame:OnBtnTipsClicked()
  for i = 1, #self.cur_storyBtnData do
    if self.cur_storyBtnData[i].btnLevel == BtnEventLevel.Important and self.cur_storyBtnData[i].state == DialogBtnState.Doing then
      UILuaHelper.SetActive(self.cur_storyBtnData[i].splashTips, true)
      TimeService:SetTimer(2, 1, function()
        UILuaHelper.SetActive(self.cur_storyBtnData[i].splashTips, false)
      end)
    end
  end
end

function Form_InteractiveGame:OnBtnNormalClicked()
  self.m_cur_TextList = self.m_space_TextList
  self:OnDialoguePlay()
end

function Form_InteractiveGame:OnBtnFinishClicked()
  if self.onCloseCallBack then
    self.onCloseCallBack()
  end
  self:CloseForm()
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
    if DialogBtnState.Doing == self.cur_storyBtnData[i].state then
      isAllFinish = false
      break
    end
  end
  if isAllFinish then
    self.m_cur_TextList = {}
    self.m_cur_TextList = self.m_end_TextList
    self.m_curDialogType = DialogType.DialogEnd
    self:OnDialoguePlay(true)
  end
end

local fullscreen = true
ActiveLuaUI("Form_InteractiveGame", Form_InteractiveGame)
return Form_InteractiveGame
