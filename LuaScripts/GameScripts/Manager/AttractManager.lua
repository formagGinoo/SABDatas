local BaseLevelManager = require("Manager/Base/BaseLevelManager")
local AttractManager = class("AttractManager", BaseLevelManager)
AttractManager.ArchiveType = {
  File = 1,
  Story = 2,
  Letter = 3
}
AttractManager.ArchiveSubType = {
  NormalStory = 201,
  SpecialStory = 202,
  SpecialStory2 = 203,
  SpecialStory3 = 204,
  NormalLetter = 301,
  SpecialLetter = 302
}
local AnimatorPrefixStr = "Ani_"
local AnimatorsuffixStr = "_study"
local MaxLoadedNum = 20

function AttractManager:OnCreate()
  self.m_allExpList = {}
  self.mLoadedHeroList = {}
  self.mHeroObjList = {}
  self.mSerializationCfgList = {}
  self.mShowLetterList = {}
end

function AttractManager:CheckHeroRedDotOut(heroID)
  return self:CheckHeroRedDot(heroID, false, true)
end

function AttractManager:OnInitNetwork()
  AttractManager.FightType_Attract = MTTDProto.FightType_Letter
  RPCS():Listen_Push_HeroAttract(handler(self, self.OnPushHeroAttract), "AttractManager")
  RPCS():Listen_Push_Letter_Quest(handler(self, self.OnPushLetterQuest), "AttractManager")
end

function AttractManager:OnAfterFreshData()
end

function AttractManager:OnAfterInitConfig()
  self.m_attractStoryCfgIns = ConfigManager:GetConfigInsByName("AttractStory")
  self.m_attractRankCfgIns = ConfigManager:GetConfigInsByName("AttractRank")
  self.m_attractTouchCfgIns = ConfigManager:GetConfigInsByName("AttractTouch")
  self.m_attractVoiceInfoIns = ConfigManager:GetConfigInsByName("AttractVoiceInfo")
  self.m_attractVoiceTextCfgIns = ConfigManager:GetConfigInsByName("AttractVoiceText")
end

function AttractManager:OnDailyReset()
  self:ReqGetAttract()
end

function AttractManager:OnUpdate(dt)
end

function AttractManager:GetExpList(iAttractRankTemplate)
  if self.m_allExpList[iAttractRankTemplate] == nil then
    local vExp = self.m_attractRankCfgIns:GetValue_ByRankTemplateID(iAttractRankTemplate)
    local temp = {}
    for k, v in pairs(vExp) do
      temp[#temp + 1] = {
        exp = v.m_RankExp,
        breakCondition = v.m_BreakCondition
      }
    end
    table.sort(temp, function(a, b)
      return a.exp < b.exp
    end)
    local needBreak = 0
    local temp2 = {}
    for k, v in ipairs(temp) do
      temp2[k] = {
        exp = v.exp,
        breakCondition = needBreak
      }
      if needBreak < v.breakCondition then
        needBreak = v.breakCondition
      end
    end
    self.m_allExpList[iAttractRankTemplate] = temp2
  end
  return self.m_allExpList[iAttractRankTemplate]
end

function AttractManager:GetBaseAttr(iPropertyID)
  if iPropertyID == 0 then
    return {}, {}
  end
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local PropertyIns = ConfigManager:GetConfigInsByName("Property")
  local attrInfoList = {}
  local attrList = {}
  local basePropertyCfg = PropertyIns:GetValue_ByPropertyID(iPropertyID)
  local propertyIndexCfg = PropertyIndexIns:GetAll()
  for attrId, v in pairs(propertyIndexCfg) do
    if v.m_Compute == 1 then
      local propertyNum = basePropertyCfg["m_" .. v.m_ENName]
      if v.m_ENName and propertyNum and 0 < propertyNum then
        attrInfoList[#attrInfoList + 1] = {
          cfg = v,
          num = propertyNum,
          id = attrId
        }
        attrList[#attrList + 1] = {attrId, propertyNum}
      end
    end
  end
  return attrInfoList, attrList
end

function AttractManager:CheckVoiceUnlockCondition(stHero, iUnlockType, iUnlockData)
  if iUnlockType == 1 then
    return true
  elseif iUnlockType == 2 then
    return iUnlockData <= stHero.serverData.iLevel
  elseif iUnlockType == 3 then
    return iUnlockData <= stHero.serverData.iBreak
  elseif iUnlockType == 4 then
    return iUnlockData <= stHero.serverData.iAttractRank
  elseif iUnlockType == 5 then
    local stAttractInfo = self:GetHeroAttractById(stHero.serverData.iHeroId)
    return stAttractInfo and stAttractInfo.vSendGift and #stAttractInfo.vSendGift > 0
  end
  return false
end

function AttractManager:GetTouchVoice(stHero, iHeroId, touchstr)
  local mTouchBox = self.m_attractTouchCfgIns:GetValue_ByHeroID(iHeroId)
  local vTouch = string.split(touchstr, ",")
  local mTouch = {}
  for k, v in ipairs(vTouch) do
    mTouch[v] = true
  end
  local touch
  if mTouch.touchsp then
    touch = "touchsp"
  elseif mTouch.touchhead then
    touch = "touchhead"
  elseif mTouch.touchnormal then
    touch = "touchnormal"
  elseif mTouch.background then
    touch = "background"
  end
  if touch then
    local vVoiceList
    for k, v in pairs(mTouchBox) do
      if v.m_BoundingBox == touch then
        vVoiceList = v.m_VoiceId
        break
      end
    end
    if vVoiceList == nil then
      return nil
    end
    local unlockList = {}
    local vVoiceListLua = utils.changeCSArrayToLuaTable(vVoiceList)
    for k, v in ipairs(vVoiceListLua) do
      local voiceCfg = self.m_attractVoiceInfoIns:GetValue_ByHeroIDAndVoiceId(iHeroId, v)
      if not voiceCfg:GetError() and self:CheckVoiceUnlockCondition(stHero, voiceCfg.m_UnlockType, voiceCfg.m_UnlockData) then
        unlockList[#unlockList + 1] = v
      end
    end
    if 0 < #unlockList then
      local randomIndex = math.random(1, #unlockList)
      local iVoiceId = unlockList[randomIndex]
      local vVoiceTextList = self.m_attractVoiceTextCfgIns:GetValue_ByVoiceId(iVoiceId)
      local vVoiceTextListLua = {}
      for k2, v2 in pairs(vVoiceTextList) do
        vVoiceTextListLua[k2] = v2
      end
      local vTextList = {}
      local firstId = 1
      local firstText = vVoiceTextListLua[firstId]
      while firstText do
        vTextList[#vTextList + 1] = {
          voice = firstText.m_voice,
          subtitle = firstText.m_mText
        }
        firstText = vVoiceTextListLua[firstText.m_NextId]
      end
      return vTextList
    end
  end
  return nil
end

function AttractManager:ReqGetAttract()
  local msg = MTTDProto.Cmd_Attract_GetAttract_CS()
  
  local function OnAttractGetAttractSC(sc, msg)
    self:OnGetAttractInitSC(sc)
  end
  
  RPCS():Attract_GetAttract(msg, OnAttractGetAttractSC)
end

function AttractManager:ReqSendGift(iHeroId, vGift, cb)
  local msg = MTTDProto.Cmd_Attract_SendGift_CS()
  msg.iHeroId = iHeroId
  msg.vGift = vGift
  
  local function OnAttractSendGiftSC(sc, msg)
    if sc.bRankChange then
      self:CheckHeroRedDot(sc.iHeroId, true)
    end
    if cb then
      cb(sc.bRankChange, sc.iAddExp)
    end
  end
  
  RPCS():Attract_SendGift(msg, OnAttractSendGiftSC)
end

function AttractManager:UpdateHeroAttractExpFromCouncilHall(vHeroResult)
  if not vHeroResult then
    return
  end
  local count = #vHeroResult
  for i, v in ipairs(vHeroResult) do
    self.m_stAttract.mHeroAttract[v.iHeroId].iAttractExp = v.iAttractExp
    self:CheckHeroRedDot(v.iHeroId, true, nil, i ~= count)
  end
end

function AttractManager:OnGetAttractInitSC(sc)
  self.m_stAttract = sc.stAttract
  self.m_iTouchTimes = sc.iTotalTimes
end

function AttractManager:OnPushHeroAttract(sc)
  local stHeroAttract = sc.stHeroAttract
  self.m_stAttract.mHeroAttract[stHeroAttract.iHeroId] = stHeroAttract
end

function AttractManager:OnPushLetterQuest(sc)
  local vQuest = sc.vQuest
  for _, v in ipairs(vQuest) do
    if v.vUniqData and v.vUniqData[1] and v.vUniqData[2] then
      local heroData = self.m_stAttract.mHeroAttract[v.vUniqData[1]]
      if heroData and heroData.mLetter then
        local letterData = heroData.mLetter[v.vUniqData[2]]
        if letterData then
          letterData.stQuest = v
        end
      end
    end
  end
end

function AttractManager:ReqSetLetter(iHeroId, iLetterId, iCurStep, vNewReply, callback)
  local letterData = self.m_stAttract.mHeroAttract[iHeroId].mLetter[iLetterId]
  if not letterData then
    return
  end
  if iCurStep <= letterData.iCurStep then
    return
  end
  local msg = MTTDProto.Cmd_Attract_SetLetter_CS()
  msg.iHeroId = iHeroId
  msg.iLetterId = iLetterId
  msg.iCurStep = iCurStep
  msg.vNewReply = vNewReply
  
  local function OnAttractSetLetterSC(sc, msg)
    local vReward = sc.vReward
    if vReward and next(vReward) then
      utils.popUpRewardUI(vReward)
    end
    local letterData = self.m_stAttract.mHeroAttract[iHeroId].mLetter[iLetterId]
    letterData.iCurStep = sc.stLetter.iCurStep
    letterData.vReply = sc.stLetter.vReply
    letterData.vRewardStep = sc.stLetter.vRewardStep
    letterData.stQuest = sc.stLetter.stQuest
    if callback then
      callback()
    end
  end
  
  RPCS():Attract_SetLetter(msg, OnAttractSetLetterSC)
end

function AttractManager:ReqTakeArchiveReward(iHeroId, iArchiveId, callback)
  local msg = MTTDProto.Cmd_Attract_TakeStoryReward_CS()
  msg.iHeroId = iHeroId
  msg.iStoryId = iArchiveId
  
  local function OnAttractTakeStoryRewardSC(sc, msg)
    local stHeroAttract = self:GetHeroAttractById(sc.iHeroId)
    if stHeroAttract == nil then
      stHeroAttract = {}
    end
    if stHeroAttract.vRewardStory == nil then
      stHeroAttract.vRewardStory = {}
    end
    stHeroAttract.vRewardStory[#stHeroAttract.vRewardStory + 1] = sc.iStoryId
    self.m_stAttract.mHeroAttract[sc.iHeroId] = stHeroAttract
    local vReward = sc.vReward
    if vReward and next(vReward) then
      utils.popUpRewardUI(vReward)
    end
    if callback then
      callback()
    end
    self:broadcastEvent("eGameEvent_Hero_AttractRedCheck")
  end
  
  RPCS():Attract_TakeStoryReward(msg, OnAttractTakeStoryRewardSC)
end

function AttractManager:ReqLetterSubmitItem(iHeroId, iLetterId, iQuestId, callback)
  local msg = MTTDProto.Cmd_Attract_LetterSubmitItem_CS()
  msg.iHeroId = iHeroId
  msg.iLetterId = iLetterId
  msg.iQuestId = iQuestId
  RPCS():Attract_LetterSubmitItem(msg, function(sc, msg)
    local heroData = self.m_stAttract.mHeroAttract[sc.iHeroId]
    if heroData and heroData.mLetter then
      local letterData = heroData.mLetter[sc.iLetterId]
      if letterData then
        letterData.stQuest.iState = TaskManager.TaskState.Completed
      end
    end
    if callback then
      callback()
    end
  end)
end

function AttractManager:GetAttractHeroList()
  local heroList = HeroManager:GetHeroList()
  local list = {}
  for k, v in ipairs(heroList) do
    local cfg = v.characterCfg
    if cfg.m_AttractRankTemplate and cfg.m_AttractRankTemplate > 0 then
      list[#list + 1] = v
    end
  end
  table.sort(list, function(a, b)
    if a.serverData.iAttractRank ~= b.serverData.iAttractRank then
      return a.serverData.iAttractRank > b.serverData.iAttractRank
    end
    if a.characterCfg.m_Quality ~= b.characterCfg.m_Quality then
      return a.characterCfg.m_Quality > b.characterCfg.m_Quality
    end
    return a.serverData.iHeroId < b.serverData.iHeroId
  end)
  return list
end

function AttractManager:GetLetterHeroList()
  self.mShowLetterList = {}
  for heroId, v in pairs(self.m_stAttract.mHeroAttract) do
    if v.mLetter and next(v.mLetter) then
      local data
      for letterId, letterData in pairs(v.mLetter) do
        if letterData.iCurStep == 0 then
          if not data then
            data = letterData
          elseif data.iArchiveId > letterData.iArchiveId then
            data = letterData
          end
        else
          local step = letterData.iCurStep
          local letterCfg = self:GetAttractLetterCfgByIDAndStep(letterId, step)
          if letterCfg then
            local stepList = utils.changeCSArrayToLuaTable(letterCfg.m_NextStep)
            if stepList[1] and 0 < stepList[1] then
              if not data then
                data = letterData
              elseif data.iArchiveId > letterData.iArchiveId then
                data = letterData
              end
            end
          end
        end
      end
      if data then
        local heroData = HeroManager:GetHeroDataByID(heroId)
        if heroData then
          if self:IsArchiveUnlock(heroId, data.iArchiveId) then
            table.insert(self.mShowLetterList, {letterData = data, heroData = heroData})
          end
        else
          log.error("AttractManager:GetLetterHeroList() 英雄数据异常，heroId = " .. heroId)
        end
      end
    end
  end
  table.sort(self.mShowLetterList, function(a, b)
    return a.letterData.iStartTime > b.letterData.iStartTime
  end)
  return self.mShowLetterList
end

function AttractManager:GetAttractArchiveCfgByHeroID(iHeroID)
  local CfgIns = ConfigManager:GetConfigInsByName("AttractArchive")
  local cfgs = CfgIns:GetValue_ByHeroID(iHeroID)
  return cfgs
end

function AttractManager:GetAttractArchiveCfgByHeroIDAndArchiveID(iHeroID, iArchiveID)
  local CfgIns = ConfigManager:GetConfigInsByName("AttractArchive")
  local cfg = CfgIns:GetValue_ByHeroIDAndArchiveId(iHeroID, iArchiveID)
  if cfg:GetError() then
    log.error("AttractManager:GetAttractArchiveCfgByHeroIDAndArchiveID error, iHeroID = " .. iHeroID .. ", iArchiveID = " .. iArchiveID)
    return
  end
  return cfg
end

function AttractManager:GetAttractArchiveSerializationCfgByHeroID(iHeroID)
  local cfg = self:GetAttractArchiveCfgByHeroID(iHeroID)
  if not cfg then
    return
  end
  if self.mSerializationCfgList[iHeroID] then
    return self.mSerializationCfgList[iHeroID]
  end
  local list = {}
  for k, v in pairs(cfg) do
    if v.m_ArchiveId and v.m_ArchiveId > 1 then
      list[v.m_ArchiveId] = v
    end
  end
  local t = {}
  
  local function SerializeCfg(iArchiveId)
    if list[iArchiveId] then
      local page = math.ceil((iArchiveId - 1) / 2)
      if not t[page] then
        t[page] = {}
      end
      table.insert(t[page], list[iArchiveId])
      iArchiveId = iArchiveId + 1
      SerializeCfg(iArchiveId)
    end
  end
  
  local iArchiveId = 2
  SerializeCfg(iArchiveId)
  self.mSerializationCfgList[iHeroID] = t
  return t
end

function AttractManager:GetAttractLetterCfgByID(iLetterID)
  local cfgs = ConfigManager:GetConfigInsByName("AttractLetter"):GetValue_ByLetterId(iLetterID)
  if not cfgs then
    return
  end
  return cfgs
end

function AttractManager:GetAttractLetterCfgByIDAndStep(iLetterID, iStep)
  local cfg = ConfigManager:GetConfigInsByName("AttractLetter"):GetValue_ByLetterIdAndStep(iLetterID, iStep)
  if cfg:GetError() then
    log.error("AttractManager:GetAttractLetterCfgByIDAndStep error, iLetterID = " .. iLetterID .. ", iStep = " .. iStep)
    return
  end
  return cfg
end

function AttractManager:GetAttractTaskCfgByID(iTaskID)
  local cfg = ConfigManager:GetConfigInsByName("AttractTask"):GetValue_ByUID(iTaskID)
  if cfg:GetError() then
    log.error("AttractManager:GetAttractTaskCfgByID error, iTaskID = " .. iTaskID)
    return
  end
  return cfg
end

function AttractManager:GetAttractStudyRoleSize(iHeroId, iFasionId)
  iFasionId = iFasionId or 0
  local cfg = ConfigManager:GetConfigInsByName("AttractStudyRoleSize"):GetValue_ByIDAndFashionID(iHeroId, iFasionId)
  if cfg:GetError() then
    log.error("AttractManager:GetAttractStudyRoleSize error, iHeroId = " .. iHeroId)
    return
  end
  return cfg
end

function AttractManager:GetTheNewestPage(iHeroId)
  local mAttractBookCfg = self:GetAttractArchiveSerializationCfgByHeroID(iHeroId)
  if not mAttractBookCfg then
    return 0
  end
  for i = 1, table.getn(mAttractBookCfg), 2 do
    local t = mAttractBookCfg[i]
    if t then
      for _, v in ipairs(t) do
        local bIsRewardRecived = self:IsArchiveRewardRecived(iHeroId, v.m_ArchiveId)
        if not bIsRewardRecived then
          return i - 1, v.m_ArchiveId
        end
      end
    end
    local t2 = mAttractBookCfg[i + 1]
    if t2 then
      for _, v in ipairs(t2) do
        local bIsRewardRecived = self:IsArchiveRewardRecived(iHeroId, v.m_ArchiveId)
        if not bIsRewardRecived then
          return i - 1, v.m_ArchiveId
        end
      end
    end
  end
  return 0
end

function AttractManager:GetHeroAttractById(iHeroId)
  return self.m_stAttract.mHeroAttract[iHeroId]
end

function AttractManager:IsMailSaw(iHeroId, iArchiveId)
  local stHeroAttract = self:GetHeroAttractById(iHeroId)
  if not stHeroAttract then
    return false
  end
  if stHeroAttract.mLetter == nil then
    return false
  end
  local cfg = self:GetAttractArchiveCfgByHeroIDAndArchiveID(iHeroId, iArchiveId)
  if not cfg then
    return false
  end
  if not stHeroAttract.mLetter[cfg.m_LetterId] then
    return false
  end
  local letterData = stHeroAttract.mLetter[cfg.m_LetterId]
  if letterData.iCurStep == 0 then
    return false
  end
  local letterCfg = self:GetAttractLetterCfgByIDAndStep(cfg.m_LetterId, letterData.iCurStep)
  if not letterCfg then
    return false
  end
  local stepList = utils.changeCSArrayToLuaTable(letterCfg.m_NextStep)
  if stepList[1] and 0 < stepList[1] then
    return false
  end
  return true
end

function AttractManager:IsArchiveRewardRecived(iHeroId, iArchiveId)
  if iArchiveId == 0 then
    return true
  end
  local stHeroAttract = self:GetHeroAttractById(iHeroId)
  if not stHeroAttract then
    return false
  end
  if stHeroAttract.vRewardStory == nil then
    return false
  end
  for k, v in pairs(stHeroAttract.vRewardStory) do
    if v == iArchiveId then
      return true
    end
  end
  return false
end

function AttractManager:IsArchiveUnlock(iHeroId, iArchiveId)
  local cfg = self:GetAttractArchiveCfgByHeroIDAndArchiveID(iHeroId, iArchiveId)
  if not cfg then
    return false
  end
  local data = HeroManager:GetHeroDataByID(iHeroId)
  if cfg.m_UnlockAttractRank > data.serverData.iAttractRank then
    return false, cfg.m_UnlockAttractRank
  end
  if not self:IsArchiveRewardRecived(iHeroId, cfg.m_PreArchiveId) then
    return false
  end
  return true
end

function AttractManager:IsStepChoosed(letterData, iStep)
  if letterData.vReply == nil then
    return false
  end
  for _, v in ipairs(letterData.vReply) do
    if v == iStep then
      return true
    end
  end
  return false
end

function AttractManager:IsHaveRewardCanTake(iHeroId)
  local cfgs = self:GetAttractArchiveSerializationCfgByHeroID(iHeroId)
  if not cfgs then
    return false
  end
  local heroData = HeroManager:GetHeroDataByID(iHeroId)
  if not heroData then
    return false
  end
  if heroData.characterCfg.m_AttractArchiveIsOpen ~= 1 then
    return false
  end
  local tempRedPage
  for pageNum, pageInfo in ipairs(cfgs) do
    for i, archiveInfo in ipairs(pageInfo) do
      local bIsUnlock = self:IsArchiveUnlock(iHeroId, archiveInfo.m_ArchiveId)
      local bIsRewardRecived = self:IsArchiveRewardRecived(iHeroId, archiveInfo.m_ArchiveId)
      if bIsUnlock and not bIsRewardRecived then
        tempRedPage = pageNum
        break
      end
    end
    if tempRedPage then
      break
    end
  end
  return tempRedPage
end

function AttractManager:LoadFavorabilityScene(callback, params)
  local sceneID = GameSceneManager.SceneID.Favorability
  StackTop:Push(UIDefines.ID_FORM_GAMESCENELOADING, {iSceneID = sceneID})
  local cGameScene = GameSceneManager:GetGameScene(sceneID)
  cGameScene:SetEnterSceneUIActiveParam(params)
  GameSceneManager:ChangeGameScene(sceneID, function(isSuc)
    if isSuc then
      if params and params.hero_id then
        self:LoadFavorabilityHero(params.hero_id, params, handler(self, self.CheckIsPlayEntryShow))
      else
        self:CheckIsPlayEntryShow(params)
      end
    end
  end, true, function()
    StackTop:DestroyUI(UIDefines.ID_FORM_GAMESCENELOADING)
  end)
end

function AttractManager:CheckIsPlayEntryShow(params)
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTMAIN2, params)
end

function AttractManager:SetFavorabilitySeatPosAndCamera(mSeatPosTransform, mCamera, cameraInit, cameraFocus, manager)
  self.mSeatPosTransform = mSeatPosTransform
  self.m_camera = mCamera
  self.cameraInit = cameraInit
  self.cameraFocus = cameraFocus
  self:SetFavorabilityCameraInit(true)
  self.attractRoomManager = manager
end

function AttractManager:ResetCamera()
  if utils.isNull(self.m_camera) then
    return
  end
  self.m_camera.enabled = true
  utils.AdaptCamera(self.m_camera)
end

function AttractManager:SetFavorabilityModel(chairModel, OtherModel)
  self.chairModel = chairModel
  self.OtherModel = OtherModel
end

function AttractManager:SetChairModelActive(bIsActive)
  if utils.isNull(self.chairModel) then
    return
  end
  self.chairModel:SetActive(bIsActive)
end

function AttractManager:SetOtherModelActive(bIsActive)
  if utils.isNull(self.OtherModel) then
    return
  end
  self.OtherModel:SetActive(bIsActive)
end

function AttractManager:GetAttractRoomManager()
  return self.attractRoomManager
end

function AttractManager:SetRaycastOn(bIsOn)
  if utils.isNull(self.attractRoomManager) then
    return
  end
  self.attractRoomManager:SetRaycastOn(bIsOn)
end

function AttractManager:SetCurLightSettings(prefabName)
  if utils.isNull(self.attractRoomManager) then
    return
  end
  if utils.isNull(self.attractRoomManager.goDetailRoot) then
    return
  end
  if not self.attractRoomManager.goDetailRoot.activeSelf then
    return
  end
  self.attractRoomManager:SetCurLightSettings(prefabName)
end

function AttractManager:SetFavorabilityCameraInit(bIsInit)
  self.cameraInit:SetActive(bIsInit)
  self.cameraFocus:SetActive(not bIsInit)
end

function AttractManager:GetAttractFasionID(iHeroID)
  local heroData = HeroManager:GetHeroDataByID(iHeroID)
  if not heroData then
    return
  end
  local cfgs = self:GetAttractArchiveCfgByHeroID(iHeroID)
  if not cfgs then
    return
  end
  local iAttractRank = heroData.serverData.iAttractRank
  local iFasionId
  for k, v in pairs(cfgs) do
    if v.m_UnlockAttractRank == iAttractRank and v.m_Prefab and v.m_Prefab ~= "" then
      iFasionId = tonumber(v.m_Prefab)
      break
    end
  end
  return iFasionId
end

function AttractManager:LoadFavorabilityHero(hero_id, params, callback, cancelCallback)
  self.curShowHeroObj = nil
  
  local function OnLoadFavorabilityHeroEnd()
    for i, v in pairs(self.mHeroObjList) do
      if not utils.isNull(v) then
        UILuaHelper.SetActive(v, false)
      end
    end
    if callback then
      callback(params)
    end
  end
  
  local iFasionId = self:GetAttractFasionID(hero_id) or HeroManager:GetCurUseFashionID(hero_id) or 0
  local m_PerformanceID
  local fashionCfg = HeroManager:GetHeroFashion():GetFashionInfoByHeroIDAndFashionID(hero_id, iFasionId)
  if not fashionCfg then
    log.error("can not find fashion cfg in HeroFashion config  id==" .. tostring(iFasionId))
    OnLoadFavorabilityHeroEnd()
    return
  end
  m_PerformanceID = fashionCfg.m_PerformanceID[0]
  local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
  local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
  local role_name = presentationData.m_Prefab
  if not role_name then
    log.error("can not find cfg in Presentation config  id==" .. tostring(m_PerformanceID))
    OnLoadFavorabilityHeroEnd()
    return
  end
  local studyRoleSizeCfg = self:GetAttractStudyRoleSize(hero_id, iFasionId)
  if self:IsLoaded(role_name) then
    self.mHeroObjList[role_name].transform:SetParent(self.mSeatPosTransform, true)
    if studyRoleSizeCfg then
      local posOffset = utils.changeCSArrayToLuaTable(studyRoleSizeCfg.m_RoleOffset)
      if posOffset and 0 < #posOffset then
        self.mHeroObjList[role_name].transform.localPosition = Vector3(posOffset[1], posOffset[2], posOffset[3])
      else
        self.mHeroObjList[role_name].transform.localPosition = Vector3.zero
      end
      self.mHeroObjList[role_name].transform.localEulerAngles = Vector3.up * studyRoleSizeCfg.m_RoleRotaion
      self.mHeroObjList[role_name].transform.localScale = Vector3.one * studyRoleSizeCfg.m_RoleScake
      self:SetChairModelActive(studyRoleSizeCfg.m_IsShowChar == 1)
    else
      self.mHeroObjList[role_name].transform.localPosition = Vector3.zero
      self.mHeroObjList[role_name].transform.localScale = Vector3.one
      self:SetChairModelActive(true)
    end
    UILuaHelper.PlayAnimatorByNameInChildren(self.mHeroObjList[role_name], "study_idle")
    self.curShowHeroObj = self.mHeroObjList[role_name]
    OnLoadFavorabilityHeroEnd()
    self.mHeroObjList[role_name]:SetActive(true)
    self:SetCurLightSettings(role_name .. "_SR_Light")
  else
    local aniName = AnimatorPrefixStr .. role_name .. AnimatorsuffixStr
    local vPackage = {}
    vPackage[#vPackage + 1] = {
      sName = tostring(hero_id),
      eType = DownloadManager.ResourcePackageType.Level_Character
    }
    DownloadManager:DownloadResourceWithUI(vPackage, nil, "AttractManager:LoadFavorabilityHero" .. tostring(hero_id), nil, nil, function()
      Role3DManager:LoadRoleAsync(role_name, aniName, function(name, result)
        self.mLoadedHeroList[#self.mLoadedHeroList + 1] = {role_name = role_name, aniName = aniName}
        self.mHeroObjList[role_name] = result
        result.transform:SetParent(self.mSeatPosTransform, true)
        if studyRoleSizeCfg then
          result.transform.localEulerAngles = Vector3.up * studyRoleSizeCfg.m_RoleRotaion
          result.transform.localScale = Vector3.one * studyRoleSizeCfg.m_RoleScake
          local posOffset = utils.changeCSArrayToLuaTable(studyRoleSizeCfg.m_RoleOffset)
          if posOffset and 0 < #posOffset then
            result.transform.localPosition = Vector3(posOffset[1], posOffset[2], posOffset[3])
          else
            result.transform.localPosition = Vector3.zero
          end
          self:SetChairModelActive(studyRoleSizeCfg.m_IsShowChar == 1)
        else
          result.transform.localScale = Vector3.one
          result.transform.localPosition = Vector3.zero
          self:SetChairModelActive(true)
        end
        self.curShowHeroObj = result
        UILuaHelper.PlayAnimatorByNameInChildren(result, "study_idle")
        self:CheckResCacheOut()
        OnLoadFavorabilityHeroEnd()
        result:SetActive(true)
        self:SetCurLightSettings(role_name .. "_SR_Light")
      end, function()
        OnLoadFavorabilityHeroEnd()
      end)
    end, nil, nil, nil, nil, cancelCallback)
  end
end

function AttractManager:CheckResCacheOut()
  if #self.mLoadedHeroList > MaxLoadedNum then
    for i = 1, #self.mLoadedHeroList - MaxLoadedNum do
      local name = self.mLoadedHeroList[1].role_name
      local aniName = self.mLoadedHeroList[1].aniName
      for k, v in pairs(self.mHeroObjList) do
        if k == name then
          Role3DManager:DestroyRoleObj(v, name, aniName)
          self.mHeroObjList[k] = nil
        end
      end
    end
    table.remove(self.mLoadedHeroList, 1)
  end
end

function AttractManager:IsLoaded(role_name)
  for i, v in ipairs(self.mLoadedHeroList) do
    if v.role_name == role_name then
      return i
    end
  end
end

function AttractManager:UnloadAssets()
  for i = table.getn(self.mLoadedHeroList), 1, -1 do
    local info = self.mLoadedHeroList[i]
    if not utils.isNull(self.mHeroObjList[info.role_name]) then
      Role3DManager:DestroyRoleObj(self.mHeroObjList[info.role_name], info.role_name, info.aniName)
      self.mLoadedHeroList[i] = nil
      self.mHeroObjList[info.role_name] = nil
    end
  end
  if self.mHeroObjList and table.getn(self.mHeroObjList) > 0 then
    for i, v in pairs(self.mHeroObjList) do
      if not utils.isNull(v) then
        GameObject.Destroy(v)
      end
    end
  end
  self.mHeroObjList = {}
end

function AttractManager:IsAttractBiographyHaveRedDot(iHeroId)
  if UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.Attract) == false then
    return 0
  end
  if self:IsHaveRewardCanTake(iHeroId) then
    return 1
  end
  return 0
end

function AttractManager:CheckHeroRedDot(iHeroId, bForce, isOut, ignoreNotify)
  if UnlockManager:IsSystemOpen(GlobalConfig.SYSTEM_ID.Attract) == false then
    return 0
  end
  if self:IsHaveRewardCanTake(iHeroId) then
    return 1
  end
  return 0
end

function AttractManager:StartEnterBattle(levelType, iMapId, iTaskId, bIsInAttract, iCurHeroId, iLetterId)
  if not levelType then
    return
  end
  if levelType ~= AttractManager.FightType_Attract then
    return
  end
  self.m_curBattleType = levelType
  self.iCurTaskId = iTaskId
  self.bIsInAttract = bIsInAttract
  self.iCurHeroId = iCurHeroId
  self.iCurLetterId = iLetterId
  self:BeforeEnterBattle(levelType, iLetterId, iCurHeroId, iTaskId)
  self:EnterPVEBattle(iMapId)
end

function AttractManager:BeforeEnterBattle(levelType, iLetterId, iCurHeroId, iTaskId)
  AttractManager.super.BeforeEnterBattle(self)
  local inputLevelData = {
    levelType = levelType or 0,
    levelID = iLetterId or 0,
    heroList = HeroManager:GetHeroServerList(),
    iCurHeroId = iCurHeroId,
    iTaskId = iTaskId
  }
  CS.BattleGlobalManager.Instance:SetLevelData(inputLevelData)
end

function AttractManager:GetLevelMapID(levelType, id)
  if levelType ~= AttractManager.FightType_Attract then
    return
  end
  return id
end

function AttractManager:OnBattleEnd(isSuc, stageFinishChallengeSc, finishErrorCode, randomShowHeroID)
  log.info("AttractManager OnBattleEnd isSuc: ", tostring(isSuc))
  if finishErrorCode ~= nil and finishErrorCode ~= 0 then
    local msg = {rspcode = finishErrorCode}
    NetworkManager:OnRpcCallbackFail(msg, function()
      BattleFlowManager:ExitBattle()
    end)
  else
    local result = isSuc
    local levelType = self.m_curBattleType
    if result then
      local rewardData, extraReward
      if stageFinishChallengeSc and stageFinishChallengeSc.stFinishChallengeInfoSC then
        local stFinishChallengeInfoSC = stageFinishChallengeSc.stFinishChallengeInfoSC
        rewardData = stFinishChallengeInfoSC.vReward
        extraReward = stFinishChallengeInfoSC.vExtraReward
      end
      StackFlow:Push(UIDefines.ID_FORM_BATTLEVICTORY, {
        levelType = levelType,
        levelID = levelID,
        rewardData = rewardData,
        extraReward = extraReward,
        showHeroID = randomShowHeroID
      })
    else
      StackFlow:Push(UIDefines.ID_FORM_BATTLEDEFEAT, {
        levelType = levelType,
        levelID = self.m_curBattleLevelID,
        finishErrorCode = finishErrorCode
      })
    end
  end
end

function AttractManager:EnterNextBattle(levelType, ...)
end

function AttractManager:OnBackLobby(fCB)
  local formStr = "Form_AttractLetter"
  if self.bIsInAttract then
    local sceneID = GameSceneManager.SceneID.Favorability
    GameSceneManager:ChangeGameScene(sceneID, function(isSuc)
      if isSuc then
        self:LoadFavorabilityHero(self.iCurHeroId, {
          hero_id = self.iCurHeroId
        }, function(params)
          StackFlow:Push(UIDefines.ID_FORM_ATTRACTMAIN2, params)
          StackFlow:Push(UIDefines.ID_FORM_ATTRACTBOOK2, {
            hero_id = self.iCurHeroId,
            bIsFromBattle = true,
            callback = fCB
          })
        end)
      end
    end, true)
  else
    GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity, function(isSuc)
      if isSuc then
        StackFlow:Push(UIDefines.ID_FORM_ATTRACTLETTER, {
          bIsInAttract = false,
          isReading = true,
          hero_id = self.iCurHeroId
        })
        if fCB then
          fCB(formStr)
        end
        self:ClearCurBattleInfo()
      end
    end, true)
  end
end

function AttractManager:ClearCurBattleInfo()
  self.m_curBattleType = nil
  self.iCurHeroId = nil
  self.bIsInAttract = nil
  self.iCurTaskId = nil
end

function AttractManager:FromBattleToHall()
  self:ClearCurBattleInfo()
  self:ExitBattle()
end

return AttractManager
