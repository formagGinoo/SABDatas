local BaseManager = require("Manager/Base/BaseManager")
local CouncilHallManager = class("CouncilHallManager", BaseManager)
local MaxLoadedNum = 20
local AnimatorPrefixStr = "Ani_"
local AnimatorsuffixStr = "_councilhall"
local DelayShowTimer = 1.6

function CouncilHallManager:OnCreate()
  self.mLoadedHeroList = {}
  self.mHeroObjList = {}
  self.curShowHeroObjList = {}
  self.ChairList = nil
  self.stCouncil = nil
  self.IsDelayShowTimer = false
end

function CouncilHallManager:OnInitNetwork()
  self:ReqGetAttract()
  self:addEventListener("eGameEvent_LoadCouncilHallRoleFinish", handler(self, self.OnLoadCouncilHallHeroEnd))
end

function CouncilHallManager:OnUpdate(dt)
  if self.IsDelayShowTimer then
    self.IsDelayShowTimer = self.IsDelayShowTimer + dt
    if self.IsDelayShowTimer >= DelayShowTimer then
      self.IsDelayShowTimer = false
      StackFlow:PopAllAndReplace(UIDefines.ID_FORM_CASTLEMEETINGRROOM)
    end
  end
end

function CouncilHallManager:OnDailyReset()
  self:ReqGetAttract()
end

function CouncilHallManager:ReqGetAttract()
  local msg = MTTDProto.Cmd_Attract_GetAttract_CS()
  
  local function OnAttractGetAttractSC(sc)
    self:OnGetAttractInitSC(sc)
  end
  
  RPCS():Attract_GetAttract(msg, OnAttractGetAttractSC)
end

function CouncilHallManager:OnGetAttractInitSC(sc)
  local stAttract = sc.stAttract
  self.stCouncil = stAttract.stCouncil
  self:broadcastEvent("eGameEvent_OnAttract_GetAttract")
  self:FreshCouncilEntryRedDot()
end

function CouncilHallManager:RqsSetCouncilHero(vHeroId, callback)
  local msg = MTTDProto.Cmd_Attract_SetCouncilHero_CS()
  msg.vHeroId = vHeroId
  RPCS():Attract_SetCouncilHero(msg, function(sc)
    self.stCouncil.vHero = sc.vHeroId
    if callback then
      callback()
    end
    self:LoadCouncilHallHero(self.stCouncil.vHero)
  end)
end

function CouncilHallManager:RqsStartCouncil(callback)
  local msg = MTTDProto.Cmd_Attract_StartCouncil_CS()
  RPCS():Attract_StartCouncil(msg, function(sc)
    if callback then
      callback()
    end
  end)
end

function CouncilHallManager:RqsEndCouncil(iIssue, iOpinion, callback)
  local msg = MTTDProto.Cmd_Attract_EndCouncil_CS()
  msg.iIssue = iIssue
  msg.iOpinion = iOpinion
  RPCS():Attract_EndCouncil(msg, function(sc)
    self.stCouncil.iChosenIssue = iIssue
    if callback then
      callback(sc.vHeroResult)
    end
    AttractManager:UpdateHeroAttractExpFromCouncilHall(sc.vHeroResult)
    self:FreshCouncilEntryRedDot()
  end)
end

function CouncilHallManager:GetCouncilData()
  return self.stCouncil
end

function CouncilHallManager:GetCouncilHero()
  return self.stCouncil.vHero or {}
end

function CouncilHallManager:GetCouncilHallIssueCfgByID(iIssue)
  local config = ConfigManager:GetConfigInsByName("CouncilHallIssue"):GetValue_ByID(iIssue)
  if config:GetError() then
    log.error("CouncilHallManager:GetCouncilHallIssueCfgByID error Wrong ID: " .. tostring(iIssue))
    return
  end
  return config
end

function CouncilHallManager:GetCouncilHallPositionByCount(count)
  local config = ConfigManager:GetConfigInsByName("CouncilHallPosition"):GetValue_ByID(count)
  if config:GetError() then
    log.error("CouncilHallManager:GetCouncilHallPositionByCount error Wrong ID: " .. tostring(count))
    return
  end
  return config
end

function CouncilHallManager:GetShowHeroList()
  return self.curShowHeroObjList or {}
end

function CouncilHallManager:GetMascotList()
  return self.mascotObjList or {}
end

function CouncilHallManager:GetCouncilCamera()
  return self.m_camera
end

function CouncilHallManager:GetCouncilHallTextByID(heroID)
  local config = ConfigManager:GetConfigInsByName("CouncilHallText"):GetValue_ByID(heroID)
  if config:GetError() then
    log.error("CouncilHallManager:GetCouncilHallTextByID error Wrong ID: " .. tostring(heroID))
    return
  end
  return config
end

function CouncilHallManager:GetCouncilHallRoleSize(iHeroId, iFasionId)
  iFasionId = iFasionId or 0
  local cfg = ConfigManager:GetConfigInsByName("CouncilHallRoleSize"):GetValue_ByIDAndFashionID(iHeroId, iFasionId)
  if cfg:GetError() then
    log.error("CouncilHallManager:GetCouncilHallRoleSize error, iHeroId = " .. iHeroId)
    return
  end
  return cfg
end

function CouncilHallManager:GetCouncilHallHeroList()
  local configIns = ConfigManager:GetConfigInsByName("CouncilHallText")
  local allCfg = configIns:GetAll()
  local tempList = {}
  for i, v in pairs(allCfg) do
    if v.m_ID and v.m_ID > 0 then
      local data = HeroManager:GetHeroDataByID(v.m_ID)
      if data then
        tempList[#tempList + 1] = data
      end
    end
  end
  return tempList
end

function CouncilHallManager:GetCurIssueStartText(iIssue)
  local curHeroText = {}
  local mHeroId2TextList = {}
  local TextList = {}
  local issueCfg = self:GetCouncilHallIssueCfgByID(iIssue)
  local openLines = issueCfg.m_OpenLines
  local starttexts = string.split(openLines, ";")
  if starttexts then
    for _, v in ipairs(starttexts) do
      local temp = string.split(v, "/")
      if temp then
        table.insert(TextList, temp[2])
        curHeroText[temp[2]] = tonumber(temp[1])
      end
    end
  end
  local continuationLines = issueCfg.m_ContinuationLines
  local continueTexts = string.split(continuationLines, ";")
  local continueText1 = string.split(continueTexts[1], "/")
  local continueText2 = string.split(continueTexts[2], "/")
  local agreeRoleList, NeutralRoleList, DisagreeRoleList = self:GetCurIssueDifPerspectivesRoleList(iIssue)
  if 0 < #agreeRoleList then
    for _, heroid in ipairs(agreeRoleList) do
      local cfg = self:GetCouncilHallTextByID(heroid)
      local text = self:FormatHeroText(cfg.m_AgreeText, iIssue)
      if text then
        for _, v in ipairs(text) do
          table.insert(TextList, v)
          curHeroText[v] = heroid
        end
        mHeroId2TextList[heroid] = text
      end
    end
  end
  if 0 < #agreeRoleList and (0 < #NeutralRoleList or 0 < #DisagreeRoleList) and continueText1 then
    for _, v in ipairs(continueText1) do
      table.insert(TextList, v)
    end
  end
  if 0 < #NeutralRoleList then
    for _, heroid in ipairs(NeutralRoleList) do
      local cfg = self:GetCouncilHallTextByID(heroid)
      local text = self:FormatHeroText(cfg.m_NeutralText, iIssue)
      if text then
        for _, v in ipairs(text) do
          table.insert(TextList, v)
          curHeroText[v] = heroid
        end
        mHeroId2TextList[heroid] = text
      end
    end
  end
  if 0 < #agreeRoleList and 0 < #NeutralRoleList and 0 < #DisagreeRoleList and continueText2 then
    for _, v in ipairs(continueText2) do
      table.insert(TextList, v)
    end
  end
  if 0 < #DisagreeRoleList then
    for _, heroid in ipairs(DisagreeRoleList) do
      local cfg = self:GetCouncilHallTextByID(heroid)
      local text = self:FormatHeroText(cfg.m_DisgreeText, iIssue)
      if text then
        for _, v in ipairs(text) do
          table.insert(TextList, v)
          curHeroText[v] = heroid
        end
        mHeroId2TextList[heroid] = text
      end
    end
  end
  return TextList, curHeroText, mHeroId2TextList
end

function CouncilHallManager:GetCurIssueEndRoleAndText(iIssue, vHeroResult)
  local curHeroText = {}
  local TextList = {}
  local mSameOptionRoleList = {}
  local mDiffOptionRoleList = {}
  local mCritOptionRoleList = {}
  for i, v in ipairs(vHeroResult) do
    if v.iResultType == MTTDProto.CouncilHeroResultType_Same then
      mSameOptionRoleList[#mSameOptionRoleList + 1] = v
    elseif v.iResultType == MTTDProto.CouncilHeroResultType_NotSame or v.iResultType == MTTDProto.CouncilHeroResultType_None then
      mDiffOptionRoleList[#mDiffOptionRoleList + 1] = v
    else
      mCritOptionRoleList[#mCritOptionRoleList + 1] = v
    end
  end
  if 0 < #mSameOptionRoleList then
    for idx, role in ipairs(mSameOptionRoleList) do
      local cfg = self:GetCouncilHallTextByID(role.iHeroId)
      local text = self:FormatHeroText(cfg.m_AcceptedText, iIssue)
      if text then
        for _, v in ipairs(text) do
          table.insert(TextList, v)
        end
        curHeroText[text[1]] = {
          ResultType = MTTDProto.CouncilHeroResultType_Same,
          heroData = role
        }
      end
    end
  end
  if 0 < #mDiffOptionRoleList then
    for index, role in ipairs(mDiffOptionRoleList) do
      local cfg = self:GetCouncilHallTextByID(role.iHeroId)
      local text = self:FormatHeroText(cfg.m_DisapprovedText, iIssue)
      if text then
        for _, v in ipairs(text) do
          table.insert(TextList, v)
        end
        curHeroText[text[1]] = {
          ResultType = MTTDProto.CouncilHeroResultType_NotSame,
          heroData = role
        }
      end
    end
  end
  if 0 < #mCritOptionRoleList then
    for index, role in ipairs(mCritOptionRoleList) do
      local cfg = self:GetCouncilHallTextByID(role.iHeroId)
      local text = self:FormatHeroText(cfg.m_ChangeText, iIssue)
      if text then
        for _, v in ipairs(text) do
          table.insert(TextList, v)
        end
        curHeroText[text[1]] = {
          ResultType = MTTDProto.CouncilHeroResultType_Critical,
          heroData = role
        }
      end
    end
  end
  return TextList, curHeroText
end

function CouncilHallManager:GetCurIssueDifPerspectivesRoleList(iIssue)
  local issueCfg = self:GetCouncilHallIssueCfgByID(iIssue)
  local heroList = self:GetCouncilHero()
  local mAgreeRole = utils.changeCSArrayToLuaTable(issueCfg.m_AgreeRole)
  local mDisagreeRole = utils.changeCSArrayToLuaTable(issueCfg.m_DisagreeRole)
  local agreeRoleList = {}
  local NeutralRoleList = {}
  local DisagreeRoleList = {}
  for i, heroid in ipairs(heroList) do
    local inserted = false
    for _, v in ipairs(mAgreeRole) do
      if heroid == v then
        agreeRoleList[#agreeRoleList + 1] = heroid
        inserted = true
        break
      end
    end
    for _, v in ipairs(mDisagreeRole) do
      if heroid == v then
        DisagreeRoleList[#DisagreeRoleList + 1] = heroid
        inserted = true
        break
      end
    end
    if not inserted then
      NeutralRoleList[#NeutralRoleList + 1] = heroid
    end
  end
  return agreeRoleList, NeutralRoleList, DisagreeRoleList
end

function CouncilHallManager:FormatHeroText(text, iIssue)
  local tempList = {}
  local strList01 = string.split(text, ";")
  for i, v in ipairs(strList01) do
    local strList02 = string.split(v, "/")
    local issueList = strList02[1]
    local issueIds = string.split(issueList, ",")
    if tonumber(issueIds[1]) == 0 then
      tempList = string.split(strList02[2], ",")
    else
      for _, id in ipairs(issueIds) do
        if tonumber(id) == iIssue then
          local resultText = string.split(strList02[2], ",")
          return resultText
        end
      end
    end
  end
  return tempList
end

function CouncilHallManager:OnLoadCouncilHallHeroEnd()
  self:CheckIsPlayEntryShow()
end

function CouncilHallManager:LoadCouncilHallScene(cancelcallback)
  local sceneID = GameSceneManager.SceneID.CouncilHall_1
  StackTop:Push(UIDefines.ID_FORM_GAMESCENELOADING, {iSceneID = sceneID})
  GameSceneManager:ChangeGameScene(sceneID, function(isSuc)
    if isSuc then
      local heroList = self:GetCouncilHero()
      if (not self.stCouncil.iChosenIssue or self.stCouncil.iChosenIssue == 0) and 0 < #heroList then
        self:LoadCouncilHallHero(self.stCouncil.vHero)
      else
        self:CheckIsPlayEntryShow()
      end
    end
  end, true, function()
    StackTop:DestroyUI(UIDefines.ID_FORM_GAMESCENELOADING)
    if cancelcallback then
      cancelcallback()
    end
  end)
end

function CouncilHallManager:SetCouncilHallChairListAndCamera(ChairList, m_camera, mascotObjList)
  self.ChairList = ChairList
  self.m_camera = m_camera
  self.cameraObj = m_camera.gameObject
  self.mascotObjList = mascotObjList
end

function CouncilHallManager:CheckResCacheOut()
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

function CouncilHallManager:LoadCouncilHallHero(heroList)
  self.curShowHeroObjList = {}
  if #heroList == 0 then
    self:broadcastEvent("eGameEvent_LoadCouncilHallRoleFinish")
    return
  end
  local poscfg = self:GetCouncilHallPositionByCount(#heroList)
  local positionList = utils.changeCSArrayToLuaTable(poscfg.m_PositionList)
  local count = 0
  for i, v in pairs(self.mHeroObjList) do
    if not utils.isNull(v) then
      v:SetActive(false)
    end
  end
  for i, hero_id in ipairs(heroList) do
    local m_PerformanceID
    local iFasionId = HeroManager:GetCurUseFashionID(hero_id) or 0
    local fashionCfg = HeroManager:GetHeroFashion():GetFashionInfoByHeroIDAndFashionID(hero_id, iFasionId)
    if not fashionCfg then
      return
    end
    m_PerformanceID = fashionCfg.m_PerformanceID[0]
    local roleSizeCfg = self:GetCouncilHallRoleSize(hero_id, iFasionId)
    local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
    local presentationData = PresentationIns:GetValue_ByPerformanceID(m_PerformanceID)
    local role_name = presentationData.m_Prefab
    if not role_name then
      log.error("can not find cfg in Presentation config  id==" .. tostring(m_PerformanceID))
      self:broadcastEvent("eGameEvent_LoadCouncilHallRoleFinish")
      return
    end
    if self:IsLoaded(role_name) then
      self.mHeroObjList[role_name]:SetActive(true)
      self.mHeroObjList[role_name].transform:SetParent(self.ChairList[positionList[i]], true)
      if roleSizeCfg then
        local posOffset = utils.changeCSArrayToLuaTable(roleSizeCfg.m_RoleOffset)
        if posOffset and 0 < #posOffset then
          self.mHeroObjList[role_name].transform.localPosition = Vector3(posOffset[1], posOffset[2], posOffset[3])
        else
          self.mHeroObjList[role_name].transform.localPosition = Vector3.zero
        end
        self.mHeroObjList[role_name].transform.localScale = Vector3.one * roleSizeCfg.m_RoleScake
      else
        self.mHeroObjList[role_name].transform.localPosition = Vector3.zero
        self.mHeroObjList[role_name].transform.localScale = Vector3.one
      end
      self.mHeroObjList[role_name].transform.localRotation = Vector3.zero
      UILuaHelper.PlayAnimatorByNameInChildren(self.mHeroObjList[role_name], "show_idle")
      self.curShowHeroObjList[i] = self.mHeroObjList[role_name]
      count = count + 1
      if count >= #heroList then
        self:broadcastEvent("eGameEvent_LoadCouncilHallRoleFinish")
      end
    else
      self:broadcastEvent("eGameEvent_LoadCouncilHallRoleStart")
      do
        local aniName = AnimatorPrefixStr .. role_name .. AnimatorsuffixStr
        local vPackage = {}
        vPackage[#vPackage + 1] = {
          sName = tostring(hero_id),
          eType = DownloadManager.ResourcePackageType.Level_Character
        }
        local vResourceExtra = {
          {
            sName = aniName,
            eType = DownloadManager.ResourceType.Animation
          }
        }
        DownloadManager:DownloadResourceWithUI(vPackage, nil, "CouncilHallManager:LoadCouncilHallHero" .. tostring(hero_id), nil, nil, function()
          Role3DManager:LoadRoleAsync(role_name, aniName, function(name, result)
            self.mLoadedHeroList[#self.mLoadedHeroList + 1] = {role_name = role_name, aniName = aniName}
            self.mHeroObjList[role_name] = result
            result.transform:SetParent(self.ChairList[positionList[i]], true)
            result.transform.localRotation = Vector3.zero
            if roleSizeCfg then
              local posOffset = utils.changeCSArrayToLuaTable(roleSizeCfg.m_RoleOffset)
              if posOffset and 0 < #posOffset then
                result.transform.localPosition = Vector3(posOffset[1], posOffset[2], posOffset[3])
              else
                result.transform.localPosition = Vector3.zero
              end
              result.transform.localScale = Vector3.one * roleSizeCfg.m_RoleScake
            else
              result.transform.localPosition = Vector3.zero
              result.transform.localScale = Vector3.one
            end
            self.curShowHeroObjList[i] = result
            count = count + 1
            UILuaHelper.PlayAnimatorByNameInChildren(result, "show_idle")
            self:CheckResCacheOut()
            if count >= #heroList then
              self:broadcastEvent("eGameEvent_LoadCouncilHallRoleFinish")
            end
          end, function()
            count = count + 1
            if count >= #heroList then
              self:broadcastEvent("eGameEvent_LoadCouncilHallRoleFinish")
            end
          end)
        end)
      end
    end
  end
end

function CouncilHallManager:IsLoaded(role_name)
  for i, v in ipairs(self.mLoadedHeroList) do
    if v.role_name == role_name then
      return i
    end
  end
end

function CouncilHallManager:UnloadAssets()
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
end

function CouncilHallManager:CheckIsPlayEntryShow()
  StackTop:DestroyUI(UIDefines.ID_FORM_GAMESCENELOADING)
  if self:IsDailyEntryCouncil() then
    UILuaHelper.PlayAnimatorByNameInChildren(self.cameraObj, "CouncilHall_Camera_show")
    self.IsDelayShowTimer = 0
    LocalDataManager:SetIntSimple("CouncilHall_Entry_Red_Point", TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()), true)
    self:FreshCouncilEntryRedDot()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_CASTLEMEETINGRROOM)
  end
end

function CouncilHallManager:FreshCouncilEntryRedDot()
  local redDotNum = self:IsDailyEntryCouncil() and 1 or 0
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.CastleCouncilEntry,
    count = redDotNum
  })
end

function CouncilHallManager:IsDailyEntryCouncil()
  local nextDayResetTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
  local todayFinished = self.stCouncil.iChosenIssue and self.stCouncil.iChosenIssue ~= 0
  if todayFinished then
    return
  end
  return nextDayResetTime - 1000 > LocalDataManager:GetIntSimple("CouncilHall_Entry_Red_Point", 0)
end

return CouncilHallManager
