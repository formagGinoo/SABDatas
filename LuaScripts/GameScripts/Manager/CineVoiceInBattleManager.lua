local BaseManager = require("Manager/Base/BaseManager")
local CineVoiceInBattleManager = class("CineVoiceInBattleManager", BaseManager)

function CineVoiceInBattleManager:OnCreate()
  self:addEventListener("eGameEvent_CineVoiceInBattleShow", handler(self, self.OnEventCineVoiceInBattleShow))
end

function CineVoiceInBattleManager:InitTableData()
  self.m_mInBattleCineStepInfo = {}
  local vInBattleCineStep = CS.CData_BattleCineStep.GetInstance():GetAll()
  for _, stInBattleCineStepData in pairs(vInBattleCineStep) do
    local vLevelID = stInBattleCineStepData.m_InBattleLevelID
    for i = 0, vLevelID.Length - 1 do
      local iLevelID = vLevelID[i]
      local vAreaID = stInBattleCineStepData.m_InBattleAreaID[i]
      if iLevelID ~= nil and iLevelID ~= "" and vAreaID ~= nil then
        if self.m_mInBattleCineStepInfo[iLevelID] == null then
          self.m_mInBattleCineStepInfo[iLevelID] = {}
        end
        for j = 0, vAreaID.Length - 1 do
          local iAreaID = vAreaID[j]
          if iAreaID ~= nil and iAreaID ~= "" then
            if self.m_mInBattleCineStepInfo[iLevelID][iAreaID] == null then
              self.m_mInBattleCineStepInfo[iLevelID][iAreaID] = {}
            end
            local iEventType = stInBattleCineStepData.m_EventType
            if self.m_mInBattleCineStepInfo[iLevelID][iAreaID][iEventType] == null then
              self.m_mInBattleCineStepInfo[iLevelID][iAreaID][iEventType] = {}
            end
            table.insert(self.m_mInBattleCineStepInfo[iLevelID][iAreaID][iEventType], {
              stInBattleCineStepData = stInBattleCineStepData,
              bRepeat = stInBattleCineStepData.m_Repeat[i][j]
            })
          end
        end
      end
    end
  end
end

function CineVoiceInBattleManager:OnUpdate(dt)
end

function CineVoiceInBattleManager:OnEventCineVoiceInBattleShow(stEventData)
  local iLevelID = stEventData.iLevelID
  if iLevelID == nil or self.m_mInBattleCineStepInfo[iLevelID] == nil then
    return
  end
  local iAreaID = stEventData.iAreaID
  if iAreaID == nil or self.m_mInBattleCineStepInfo[iLevelID][iAreaID] == nil then
    return
  end
  local eType = stEventData.eType
  local vInBattleCineStepInfo = self.m_mInBattleCineStepInfo[iLevelID][iAreaID][eType.value__]
  if vInBattleCineStepInfo == nil then
    return
  end
  local stInBattleCineStepInfoShow
  if eType == CS.CineVoiceInBattleHelper.eEventType.InBattleCineStepFinish then
    local iFinishID = stEventData.iInBattleCineStepID
    for _, stInBattleCineStepInfo in ipairs(vInBattleCineStepInfo) do
      local stInBattleCineStepData = stInBattleCineStepInfo.stInBattleCineStepData
      if tonumber(stInBattleCineStepData.m_EventData) == iFinishID then
        stInBattleCineStepInfoShow = stInBattleCineStepInfo
        break
      end
    end
  elseif eType == CS.CineVoiceInBattleHelper.eEventType.CharacterHPDown then
    local iCharacterID = stEventData.iCharacterID
    local fHPPercentPre = stEventData.fHPPercentPre
    local fHPPercentCur = stEventData.fHPPercentCur
    for _, stInBattleCineStepInfo in ipairs(vInBattleCineStepInfo) do
      local stInBattleCineStepData = stInBattleCineStepInfo.stInBattleCineStepData
      local vInfo = string.split(stInBattleCineStepData.m_EventData, ",")
      local iCharacterIDTmp = tonumber(vInfo[1])
      local fHPPercentTmp = tonumber(vInfo[2])
      if iCharacterIDTmp == iCharacterID and fHPPercentPre > fHPPercentTmp and fHPPercentCur <= fHPPercentTmp then
        stInBattleCineStepInfoShow = stInBattleCineStepInfo
        break
      end
    end
  elseif eType == CS.CineVoiceInBattleHelper.eEventType.TaskFinish then
    local iTaskID = stEventData.iTaskID
    for _, stInBattleCineStepInfo in ipairs(vInBattleCineStepInfo) do
      local stInBattleCineStepData = stInBattleCineStepInfo.stInBattleCineStepData
      if tonumber(stInBattleCineStepData.m_EventData) == iTaskID then
        stInBattleCineStepInfoShow = stInBattleCineStepInfo
        break
      end
    end
  elseif eType == CS.CineVoiceInBattleHelper.eEventType.StartBattle then
    local itriggerID = stEventData.itriggerID
    for _, stInBattleCineStepInfo in ipairs(vInBattleCineStepInfo) do
      local stInBattleCineStepData = stInBattleCineStepInfo.stInBattleCineStepData
      if stInBattleCineStepData.m_TriggerID == itriggerID then
        stInBattleCineStepInfoShow = stInBattleCineStepInfo
        break
      end
    end
  elseif eType == CS.CineVoiceInBattleHelper.eEventType.CharacterCastMaxSkill then
    local iCharacterID = stEventData.iCharacterID
    for _, stInBattleCineStepInfo in ipairs(vInBattleCineStepInfo) do
      local stInBattleCineStepData = stInBattleCineStepInfo.stInBattleCineStepData
      if tonumber(stInBattleCineStepData.m_EventData) == iCharacterID then
        stInBattleCineStepInfoShow = stInBattleCineStepInfo
        break
      end
    end
  elseif eType == CS.CineVoiceInBattleHelper.eEventType.CharacterEnergyPercent then
    local iCharacterID = stEventData.iCharacterID
    local fEnergyPercentPre = stEventData.fEnergyPercentPre
    local fEnergyPercentCur = stEventData.fEnergyPercentCur
    for _, stInBattleCineStepInfo in ipairs(vInBattleCineStepInfo) do
      local stInBattleCineStepData = stInBattleCineStepInfo.stInBattleCineStepData
      local vInfo = string.split(stInBattleCineStepData.m_EventData, ",")
      local iCharacterIDTmp = tonumber(vInfo[1])
      local fEnergyPercentTmp = tonumber(vInfo[2])
      if iCharacterIDTmp == iCharacterID and fEnergyPercentPre < fEnergyPercentTmp and fEnergyPercentCur >= fEnergyPercentTmp then
        stInBattleCineStepInfoShow = stInBattleCineStepInfo
        break
      end
    end
  end
  if stInBattleCineStepInfoShow == nil then
    return
  end
  local stInBattleCineStepDataShow = stInBattleCineStepInfoShow.stInBattleCineStepData
  if stInBattleCineStepDataShow.m_Available == 0 then
    return
  end
  local iCineStepID = stInBattleCineStepDataShow.m_InBattleCineStepID
  if stInBattleCineStepInfoShow.bRepeat == 0 and CS.CineVoiceInBattleHelper.GetCineStepTriggerInfo(iCineStepID, iAreaID) then
    return
  end
  local stEventParam = {
    iCineStepID = iCineStepID,
    iSubCineStepID = stInBattleCineStepDataShow.m_InBattleCineSubStepID,
    fWaitTimeMax = stInBattleCineStepDataShow.m_WaitMax
  }
  self:broadcastEvent("eGameEvent_CineVoiceInBattle_AddDialoguePop", stEventParam)
  CS.CineVoiceInBattleHelper.SetCineStepTriggerInfo(iCineStepID, iAreaID)
end

return CineVoiceInBattleManager
