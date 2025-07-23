local Form_Dialogue_Popo = class("Form_Dialogue_Popo", require("UI/UIFrames/Form_Dialogue_PopoUI"))
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local iPanelPopIndexMax = 3
local ePanelPopStatus = {
  None = 0,
  Appear = 1,
  Idle_Current = 2,
  Move = 3,
  Disappear_Current = 4,
  Idle_Previous = 5,
  Disappear_Previous = 6
}

function Form_Dialogue_Popo:GetRootTransformType()
  return UIRootTransformType.Battle
end

function Form_Dialogue_Popo:AfterInit()
  self.m_vPanelInfo = {}
  for i = 1, iPanelPopIndexMax do
    self.m_vPanelInfo[i] = {
      panelPop = self["m_panel_popo" .. i],
      eStatus = ePanelPopStatus.None,
      stSubCineStepData = nil,
      fTime = -1,
      fMoveTime = -1
    }
    self.m_vPanelInfo[i].panelPop:SetActive(false)
  end
  self.m_iAnimationMoveLength = 0.3
  self:RemoveEventListener()
  self.m_iHandlerIDAddDialoguePop = EventCenter.AddListener(EventDefine.eGameEvent_CineVoiceInBattle_AddDialoguePop, handler(self, self.OnEventAddDialoguePop))
end

function Form_Dialogue_Popo:OnActive()
  self.m_iPanelIndex = 3
  for i = 1, iPanelPopIndexMax do
    self.m_vPanelInfo[i].eStatus = ePanelPopStatus.None
    self.m_vPanelInfo[i].stSubCineStepData = nil
    self.m_vPanelInfo[i].panelPop:SetActive(false)
  end
  self.m_stSubCineStepInfoNext = nil
  self.m_vSubCineStepInfoStack = {}
  self.m_csui.SortingOrder = self:OwnerStack().Prio + 5
  local param = self.m_csui.m_param
  if param ~= nil then
    self:OnEventAddDialoguePop(param)
    self.m_csui.m_param = nil
  end
end

function Form_Dialogue_Popo:GetPanelInfoCurrent()
  return self.m_vPanelInfo[self.m_iPanelIndex]
end

function Form_Dialogue_Popo:GetPanelInfoPrevious()
  local iPanelIndexPrevious = self.m_iPanelIndex - 1
  if iPanelIndexPrevious <= 0 then
    iPanelIndexPrevious = iPanelPopIndexMax
  end
  return self.m_vPanelInfo[iPanelIndexPrevious]
end

function Form_Dialogue_Popo:GetPanelInfoNext()
  local iPanelIndexNext = self.m_iPanelIndex + 1
  if iPanelIndexNext > iPanelPopIndexMax then
    iPanelIndexNext = 1
  end
  return self.m_vPanelInfo[iPanelIndexNext]
end

function Form_Dialogue_Popo:OnEventAddDialoguePop(stEventParam)
  local iSubCineStepID = stEventParam.iSubCineStepID
  if iSubCineStepID == nil or iSubCineStepID <= 0 then
    return
  end
  local stCineSubStepData = CS.CData_BattleCineSubStep.GetInstance():GetValue_ByID(iSubCineStepID)
  if stCineSubStepData == nil or stCineSubStepData:GetError() then
    log.error("InBattleCineSubStep ERROR: " .. iSubCineStepID)
    return
  end
  if self.m_stSubCineStepInfoNext == nil then
    self.m_stSubCineStepInfoNext = {
      iCineStepID = stEventParam.iCineStepID,
      stCineSubStepData = stCineSubStepData,
      fDelayTime = 0
    }
  else
    self.m_vSubCineStepInfoStack[#self.m_vSubCineStepInfoStack + 1] = {
      iCineStepID = stEventParam.iCineStepID,
      stCineSubStepData = stCineSubStepData,
      fWaitTime = 0,
      fWaitTimeMax = stEventParam.fWaitTimeMax
    }
  end
  if self.content_node == nil then
    self.content_node = self.m_csui.m_uiGameObject.transform:Find("content_node")
  end
  local bottomOffset = stEventParam.bottomOffset or 0
  local v = self.content_node.offsetMin
  v.y = bottomOffset
  self.content_node.offsetMin = v
end

function Form_Dialogue_Popo:SetPanelPopByCineSubStepData(panelPop, stCineSubStepData)
  local imageHead = panelPop.transform:Find("pnl_mask/m_img_head")
  CS.UI.UILuaHelper.SetAtlasSprite(imageHead:GetComponent("Image"), stCineSubStepData.m_Expression)
  local textDialogue = panelPop.transform:Find("m_bg_popo_txt/m_txt_popo")
  textDialogue:GetComponent(T_TextMeshProUGUI).text = CS.MultiLanguageManager.Instance:GetPlotText(stCineSubStepData.m_DialogueContent)
end

function Form_Dialogue_Popo:ShowDialoguePop(iCineStepID, stCineSubStepData)
  local panelInfoPrevious = self:GetPanelInfoPrevious()
  if panelInfoPrevious.eStatus == ePanelPopStatus.Idle_Previous then
    panelInfoPrevious.eStatus = ePanelPopStatus.Disappear_Previous
    panelInfoPrevious.fTime = -1
    panelInfoPrevious.fMoveTime = 0
    panelInfoPrevious.panelPop:GetComponent("Animation"):Play("Form_Dialogue_Popo_Disappear_Previous")
  end
  local panelInfoCurrent = self:GetPanelInfoCurrent()
  if panelInfoCurrent.eStatus == ePanelPopStatus.Idle_Current then
    panelInfoCurrent.eStatus = ePanelPopStatus.Move
    panelInfoCurrent.fMoveTime = 0
    panelInfoCurrent.panelPop:GetComponent("Animation"):Play("Form_Dialogue_Popo_Move")
  end
  local panelInfoNext = self:GetPanelInfoNext()
  panelInfoNext.panelPop:SetActive(true)
  panelInfoNext.eStatus = ePanelPopStatus.Appear
  panelInfoNext.stSubCineStepData = stCineSubStepData
  panelInfoNext.fTime = 0
  panelInfoNext.fMoveTime = 0
  panelInfoNext.panelPop:GetComponent("Animation"):Play("Form_Dialogue_Popo_Appear")
  self:SetPanelPopByCineSubStepData(panelInfoNext.panelPop, stCineSubStepData)
  local stCineSubStepDataNext = CS.CData_BattleCineSubStep.GetInstance():GetValue_ByID(stCineSubStepData.m_NextInBattleCineSubStepID)
  if stCineSubStepDataNext == nil or stCineSubStepDataNext:GetError() then
    local stEventParam = CS.CineVoiceInBattleHelper.InBattleCineStepEventData_InBattleCineStepFinish()
    stEventParam.iInBattleCineStepID = iCineStepID
    EventCenter.Broadcast(EventDefine.eGameEvent_CineVoiceInBattleShow, stEventParam)
    if 0 < #self.m_vSubCineStepInfoStack then
      iCineStepID = self.m_vSubCineStepInfoStack[1].iCineStepID
      stCineSubStepDataNext = self.m_vSubCineStepInfoStack[1].stCineSubStepData
      table.remove(self.m_vSubCineStepInfoStack, 1)
    end
  end
  if stCineSubStepDataNext == nil or stCineSubStepDataNext:GetError() then
    self.m_stSubCineStepInfoNext = nil
  else
    self.m_stSubCineStepInfoNext = {
      iCineStepID = iCineStepID,
      stCineSubStepData = stCineSubStepDataNext,
      fDelayTime = 0
    }
  end
  self.m_iPanelIndex = self.m_iPanelIndex + 1
  if self.m_iPanelIndex > iPanelPopIndexMax then
    self.m_iPanelIndex = 1
  end
end

function Form_Dialogue_Popo:RemoveEventListener()
  if self.m_iHandlerIDAddDialoguePop then
    EventCenter.RemoveListener(EventDefine.eGameEvent_CineVoiceInBattle_AddDialoguePop, self.m_iHandlerIDAddDialoguePop)
    self.m_iHandlerIDAddDialoguePop = nil
  end
end

function Form_Dialogue_Popo:OnInactive()
  self:RemoveEventListener()
end

function Form_Dialogue_Popo:OnUpdate(dt)
  local timeScale = CS.UI.UILuaHelper.GetBattleSpeed2()
  dt = dt * timeScale
  for i = 1, iPanelPopIndexMax do
    local panelInfo = self.m_vPanelInfo[i]
    if panelInfo.eStatus == ePanelPopStatus.Appear then
      panelInfo.fMoveTime = panelInfo.fMoveTime + dt
      if panelInfo.fMoveTime >= self.m_iAnimationMoveLength then
        panelInfo.fMoveTime = -1
        panelInfo.eStatus = ePanelPopStatus.Idle_Current
        panelInfo.panelPop:GetComponent("Animation"):Play("Form_Dialogue_Popo_Idle_Current")
      end
    elseif panelInfo.eStatus == ePanelPopStatus.Move then
      panelInfo.fMoveTime = panelInfo.fMoveTime + dt
      if panelInfo.fMoveTime >= self.m_iAnimationMoveLength then
        panelInfo.fMoveTime = -1
        panelInfo.eStatus = ePanelPopStatus.Idle_Previous
        panelInfo.panelPop:GetComponent("Animation"):Play("Form_Dialogue_Popo_Idle_Previous")
      end
    elseif panelInfo.eStatus == ePanelPopStatus.Disappear_Previous or panelInfo.eStatus == ePanelPopStatus.Disappear_Current then
      panelInfo.fMoveTime = panelInfo.fMoveTime + dt
      if panelInfo.fMoveTime >= self.m_iAnimationMoveLength then
        panelInfo.fMoveTime = -1
        panelInfo.eStatus = ePanelPopStatus.None
        panelInfo.panelPop:SetActive(false)
        panelInfo.stSubCineStepData = nil
      end
    elseif panelInfo.eStatus == ePanelPopStatus.Idle_Current then
      panelInfo.fTime = panelInfo.fTime + dt
      if panelInfo.fTime >= panelInfo.stSubCineStepData.m_Duration then
        panelInfo.fTime = -1
        panelInfo.eStatus = ePanelPopStatus.Disappear_Current
        panelInfo.fMoveTime = 0
        panelInfo.panelPop:GetComponent("Animation"):Play("Form_Dialogue_Popo_Disappear_Current")
      end
    elseif panelInfo.eStatus == ePanelPopStatus.Idle_Previous then
      panelInfo.fTime = panelInfo.fTime + dt
      if panelInfo.fTime >= panelInfo.stSubCineStepData.m_Duration then
        panelInfo.fTime = -1
        panelInfo.eStatus = ePanelPopStatus.Disappear_Previous
        panelInfo.fMoveTime = 0
        panelInfo.panelPop:GetComponent("Animation"):Play("Form_Dialogue_Popo_Disappear_Previous")
      end
    end
  end
  if self.m_stSubCineStepInfoNext ~= nil then
    self.m_stSubCineStepInfoNext.fDelayTime = self.m_stSubCineStepInfoNext.fDelayTime + dt
    if self.m_stSubCineStepInfoNext.fDelayTime >= self.m_stSubCineStepInfoNext.stCineSubStepData.m_Delay then
      local panelInfoCurrent = self:GetPanelInfoCurrent()
      if panelInfoCurrent.eStatus == ePanelPopStatus.None or panelInfoCurrent.eStatus == ePanelPopStatus.Idle_Current then
        self:ShowDialoguePop(self.m_stSubCineStepInfoNext.iCineStepID, self.m_stSubCineStepInfoNext.stCineSubStepData)
      end
    end
  end
  for i = #self.m_vSubCineStepInfoStack, 1, -1 do
    local stSubCineStepInfo = self.m_vSubCineStepInfoStack[i]
    stSubCineStepInfo.fWaitTime = stSubCineStepInfo.fWaitTime + dt
    if stSubCineStepInfo.fWaitTime >= stSubCineStepInfo.fWaitTimeMax then
      table.remove(self.m_vSubCineStepInfoStack, i)
      break
    end
  end
end

ActiveLuaUI("Form_Dialogue_Popo", Form_Dialogue_Popo)
return Form_Dialogue_Popo
