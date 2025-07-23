local Form_WhackMoleBattleMain = class("Form_WhackMoleBattleMain", require("UI/UIFrames/Form_WhackMoleBattleMainUI"))
local MoleType = {Normal = 1, Boss = 2}
local ModeType = {
  TimeLimit = 1,
  Boss = 2,
  Infinity = 3
}

function Form_WhackMoleBattleMain:SetInitParam(param)
end

function Form_WhackMoleBattleMain:AfterInit()
  self.super.AfterInit(self)
  self.BossAniEnum = {
    Born = "KrakenBig_Born",
    ShieldBreak = "KrakenBig_BreakH",
    Dead = "KrakenBig_Death",
    IdleShield = "KrakenBig_IdleShieldH",
    ShieldRestore = "KrakenBig_ShieldRestore",
    TakeAHit = "KrakenBig_HitH",
    HitShield = "KrakenBig_HitShieldH",
    Stun = "KrakenBig_IdleH"
  }
  self.MoleAniEnum = {
    Born = "Born",
    Idle = "Idle",
    TakeAHit = "TakeAHit",
    Dead = "Dead",
    Retreat = "Retreat",
    Attack = "Attack"
  }
  self.HammerHitAni = "HammerHit"
  self.m_btn_home:SetActive(false)
  self.m_MoleCache = {}
  self.m_MoleTimer = {}
  self.m_MoleDeadTimer = {}
  self.m_HammerTimer = {}
  self.m_AttackTimer = {}
  self.mCanvas = self.m_csui.m_uiGameObject:GetComponent("Canvas")
  self.mLoadedMoleAssets = {}
  self.vHitBossFx = {}
  self.m_BlindNode_CG = self.m_BlindNode:GetComponent("CanvasGroup")
end

function Form_WhackMoleBattleMain:OnActive()
  self.super.OnActive(self)
  self:ResetUIState()
  self.bIsAniEnd = false
  self.bIsLoadFinished = false
  self:FreshData()
  self:LoadMoleAssets()
  self.m_ui_hammer.transform:Find("Sprite"):GetComponent("SpriteRenderer").sortingOrder = self.mCanvas.sortingOrder + 2
  for i = 1, self.m_StunNode.transform.childCount do
    self.m_StunNode.transform:GetChild(i - 1):Find("Sprite"):GetComponent("SpriteRenderer").sortingOrder = self.mCanvas.sortingOrder + 2
  end
  self:PlayStartAni()
end

function Form_WhackMoleBattleMain:PlayStartAni()
  self:CheckBossTips(function()
    self.m_pnl_lefttime:SetActive(true)
    UILuaHelper.PlayAnimationByName(self.m_pnl_lefttime, "pnl_lefttime_num_in")
    local aniLength = UILuaHelper.GetAnimationLengthByName(self.m_pnl_lefttime, "pnl_lefttime_num_in")
    CS.GlobalManager.Instance:TriggerWwiseBGMState(308)
    TimeService:SetTimer(0.7, 2, function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(308)
    end)
    TimeService:SetTimer(2, 1, function()
      CS.GlobalManager.Instance:TriggerWwiseBGMState(310)
    end)
    TimeService:SetTimer(aniLength, 1, function()
      self.bIsAniEnd = true
      if utils.isNull(self.m_pnl_lefttime) then
        return
      end
      self.m_pnl_lefttime:SetActive(false)
      if self.bIsLoadFinished and not self.bIsInit then
        local left_time = self.iLevelTime > 0 and self.iLevelTime or self.mLevelCfg and self.mLevelCfg.m_Time / 1000 or -1
        self.m_BattleEndTimer = TimeService:SetTimer(1, left_time, function()
          left_time = left_time - 1
          if utils.isNull(self.m_timer_Text) then
            return
          end
          if 0 < left_time then
            self.m_timer_Text.text = os.date("%M:%S", left_time)
          else
            self.m_timer_Text.text = "--:--"
          end
        end)
        self:InitMoleData()
      end
    end)
  end)
end

function Form_WhackMoleBattleMain:CheckBossTips(func)
  if self.mLevelCfg then
    local bossId = tonumber(self.mLevelCfg.m_Tutorial)
    if bossId and bossId ~= 0 then
      StackPopup:Push(UIDefines.ID_FORM_WHACKMOLETIPS, {
        type = 2,
        bossConfig = HeroActivityManager:GetWhackaMoleEnemyCfgByID(bossId),
        backFun_Sure = func
      })
      return
    end
  end
  func()
end

function Form_WhackMoleBattleMain:ResetUIState()
  self.m_StunNode:SetActive(false)
  self.m_BlindNode:SetActive(false)
  self.m_pnl_boss:SetActive(false)
  self.m_bIsStun = false
  self.bIsBattleEnd = false
  self.bIsInit = false
  self.bIsPause = false
  self.iTerrain = 1
  self.iMode = 1
  self.MaxMoleCount = 0
  self.iLevelTimer = 0
  self.iLevelTime = 0
  self.iCurFreshTimer = 0
  self.iCurFreshtime = 0
  self.iCurFreshMonsterIDList = {}
  self.totalWeight = 0
  self.iMoleDeadCount = 0
  self.iBossFreshCount = 0
  self.mCurBossData = nil
  self.iBossID = 4
  self.iBossBornCount = 0
  self.iBossDeadCount = 0
  self.iCurScore = 0
  self.iTargetScore = 0
  for i = 1, self.m_HitBoss.transform.childCount do
    self.m_HitBoss.transform:GetChild(i - 1).gameObject:SetActive(false)
    self.vHitBossFx[i] = {
      obj = self.m_HitBoss.transform:GetChild(i - 1).gameObject,
      isPlaying = false
    }
  end
  self.m_HitBoss:SetActive(true)
end

function Form_WhackMoleBattleMain:OnInactive()
  self.super.OnInactive(self)
  self:ResetTimer()
  for key, v in pairs(self.m_MoleCache) do
    if v.moletrans then
      v.bIsActive = false
      v.bIsAlive = false
      v.moletrans:SetParent(self.m_cacheNode.transform)
    end
  end
  local mCurBossData = self.mCurBossData
  if mCurBossData then
    mCurBossData.obj:SetActive(false)
    mCurBossData = nil
    self.mCurBossData = nil
  end
  if self.m_BossTimer then
    TimeService:KillTimer(self.m_BossTimer)
    self.m_BossTimer = nil
  end
  if self.sequence then
    self.sequence:Kill()
    self.sequence = nil
  end
  self:ResetUIState()
end

function Form_WhackMoleBattleMain:OnUpdate(dt)
  if not (self.bIsInit and self.bIsAniEnd) or self.bIsPause then
    return
  end
  self.iLevelTimer = self.iLevelTimer + dt
  self.iCurFreshTimer = self.iCurFreshTimer + dt
  if self.iLevelTimer >= self.iLevelTime then
    self.bIsInit = false
    self.bIsBattleEnd = true
    self:OnLevelEnd()
    return
  end
  if self.iCurFreshTimer >= self.iCurFreshtime then
    self:FreshMonster()
    self.iCurFreshTimer = 0
    self:GenerateRandomData()
  end
  for i, v in ipairs(self.m_MoleCache) do
    if v.bIsAlive and not v.bIsRetreating and v.cfg.m_Type == MoleType.Normal then
      v.iAliveTime = v.iAliveTime - dt
      if 0 >= v.iAliveTime then
        self:OnMoleRetreat(i)
      end
    end
  end
  local mCurBossData = self.mCurBossData
  if mCurBossData and mCurBossData.bIsAlive and 0 >= mCurBossData.iShield then
    mCurBossData.iStunTime = mCurBossData.iStunTime - dt
    if 0 >= mCurBossData.iStunTime then
      mCurBossData.iShield = mCurBossData.cfg.m_Shield
      mCurBossData.iStunTime = mCurBossData.cfg.m_DizzinessTime / 1000
      if self.m_BossTimer then
        TimeService:KillTimer(self.m_BossTimer)
        self.m_BossTimer = nil
      end
      if self.curhammerData then
        self.curhammerData.obj.gameObject:SetActive(false)
        self.curhammerData.obj:SetParent(self.m_cacheNode.transform)
        self.curhammerData = nil
      end
      if self.m_pnl_scoredot then
        UILuaHelper.PlayAnimationByName(self.m_pnl_scoredot, "pnl_scoredot_in")
      end
      self:PlayBossAnim(mCurBossData.obj, self.BossAniEnum.ShieldRestore, self.BossAniEnum.IdleShield)
      self.m_bossShield_Text.text = tostring(mCurBossData.iShield)
      self.m_img_slider:SetActive(true)
      self.m_img_slider_boss:SetActive(false)
      self.m_img_slider_Image.fillAmount = mCurBossData.iShield / mCurBossData.cfg.m_Shield
    end
  end
  self.mCurBossData = mCurBossData
end

function Form_WhackMoleBattleMain:OnDestroy()
  self.super.OnDestroy(self)
  self.m_MoleCache = {}
  for k, v in pairs(self.mLoadedMoleAssets) do
    if not utils.isNull(v.go) then
      GameObject.Destroy(v.go)
      ResourceUtil:UnLoadPrefabAsync(v.prefabName)
    end
  end
  self.mLoadedMoleAssets = {}
  self:ResetTimer()
end

function Form_WhackMoleBattleMain:LoadMoleAssets()
  local bIsLoadMonsterFinished = false
  local bIsLoadBossFinished = false
  local count = 0
  for k, v in pairs(self.mMonsterIDList) do
    if not self.mLoadedMoleAssets[v[1]] then
      self.mLoadedMoleAssets[v[1]] = {}
      local moleCfg = HeroActivityManager:GetWhackaMoleEnemyCfgByID(v[1])
      if moleCfg.m_Type == MoleType.Normal then
        ResourceUtil:LoadPrefabAsync(moleCfg.m_Prefab, function(prefab)
          local gameObject = GameObject.Instantiate(prefab, self.m_loaded.transform)
          gameObject.transform:SetParent(self.m_loaded.transform)
          gameObject.transform.localPosition = Vector3.zero
          gameObject.transform:Find("Sprite"):GetComponent("SpriteRenderer").sortingOrder = self.mCanvas.sortingOrder + 1
          self.mLoadedMoleAssets[v[1]] = {
            go = gameObject,
            prefabName = moleCfg.m_Prefab
          }
          count = count + 1
          if count == #self.mMonsterIDList then
            bIsLoadMonsterFinished = true
            if bIsLoadBossFinished then
              self.bIsLoadFinished = true
            end
            if bIsLoadBossFinished and self.bIsAniEnd then
              self:InitMoleData()
            end
          end
        end)
      end
    else
      count = count + 1
      if count == #self.mMonsterIDList then
        bIsLoadMonsterFinished = true
        if bIsLoadBossFinished then
          self.bIsLoadFinished = true
        end
        if bIsLoadBossFinished and self.bIsAniEnd then
          self:InitMoleData()
        end
      end
    end
  end
  if self.iBossID and 0 < self.iBossID then
    if not self.mLoadedMoleAssets[self.iBossID] then
      local moleCfg = HeroActivityManager:GetWhackaMoleEnemyCfgByID(self.iBossID)
      ResourceUtil:LoadPrefabAsync(moleCfg.m_Prefab, function(prefab)
        local gameObject = GameObject.Instantiate(prefab, self.m_Boss.transform)
        gameObject.transform:SetParent(self.m_Boss.transform)
        gameObject.transform.localPosition = Vector3.zero
        gameObject.transform.localScale = Vector3.one * moleCfg.m_Scale[0]
        gameObject.transform:Find("Sprite"):GetComponent("SpriteRenderer").sortingOrder = self.mCanvas.sortingOrder + 1
        gameObject:SetActive(false)
        self.mLoadedMoleAssets[self.iBossID] = {
          go = gameObject,
          prefabName = moleCfg.m_Prefab
        }
        bIsLoadBossFinished = true
        if bIsLoadMonsterFinished then
          self.bIsLoadFinished = true
        end
        if bIsLoadMonsterFinished and self.bIsAniEnd then
          self:InitMoleData()
        end
      end)
    else
      self.mLoadedMoleAssets[self.iBossID].go:SetActive(false)
      bIsLoadBossFinished = true
      if bIsLoadMonsterFinished then
        self.bIsLoadFinished = true
      end
      if bIsLoadMonsterFinished and self.bIsAniEnd then
        self:InitMoleData()
      end
    end
  else
    bIsLoadBossFinished = true
    if bIsLoadMonsterFinished then
      self.bIsLoadFinished = true
    end
    if bIsLoadMonsterFinished and self.bIsAniEnd then
      self:InitMoleData()
    end
  end
end

function Form_WhackMoleBattleMain:ResetTimer()
  if self.m_MoleTimer then
    for _, v in pairs(self.m_MoleTimer) do
      TimeService:KillTimer(v)
    end
    self.m_MoleTimer = {}
  end
  if self.iBlindTimer then
    TimeService:KillTimer(self.iBlindTimer)
    self.iBlindTimer = nil
  end
  if self.m_BossDeadTimer then
    TimeService:KillTimer(self.m_BossDeadTimer)
    self.m_BossDeadTimer = nil
  end
  if self.m_MoleDeadTimer then
    for _, v in pairs(self.m_MoleDeadTimer) do
      TimeService:KillTimer(v)
    end
    self.m_MoleDeadTimer = {}
  end
  if self.m_AttackTimer then
    for _, v in pairs(self.m_AttackTimer) do
      TimeService:KillTimer(v)
    end
    self.m_AttackTimer = {}
  end
  if self.iStunTimer then
    TimeService:KillTimer(self.iStunTimer)
    self.iStunTimer = nil
  end
  if self.m_BattleEndTimer then
    TimeService:KillTimer(self.m_BattleEndTimer)
    self.m_BattleEndTimer = nil
  end
  if self.m_HammerTimer then
    for _, v in pairs(self.m_HammerTimer) do
      TimeService:KillTimer(v.timer)
      v.hammerData.obj.gameObject:SetActive(false)
      v.hammerData.obj:SetParent(self.m_cacheNode.transform)
    end
    self.m_HammerTimer = {}
  end
end

function Form_WhackMoleBattleMain:FreshData()
  self.subActId = self.m_csui.m_param.iSubActId
  self.iLevelID = self.m_csui.m_param.iLevelID
  self.iActId = self.m_csui.m_param.iActId
  self.mLevelCfg = HeroActivityManager:GetActWhackMoleInfoCfgByIDAndLevelId(self.subActId, self.iLevelID)
  if not self.mLevelCfg then
    return
  end
  self.mCurBossData = nil
  self.iTerrain = self.mLevelCfg.m_Terrain
  self.iTargetScore = self.mLevelCfg.m_VictoryCondition
  self.iBornInterval = utils.changeCSArrayToLuaTable(self.mLevelCfg.m_MonsterRefreshTime)
  self.mRefreshNumberList = utils.changeCSArrayToLuaTable(self.mLevelCfg.m_MonsterRefreshNumber)
  self.mMonsterIDList = utils.changeCSArrayToLuaTable(self.mLevelCfg.m_MonsterID)
  self.iMode = self.mLevelCfg.m_Mode
  self.iBossFreshCount = self.mLevelCfg.m_BossRule
  self.iBossID = self.mLevelCfg.m_BossID
  self.iMoleDeadCount = self.iBossFreshCount
  self.totalWeight = 0
  for _, item in ipairs(self.mMonsterIDList) do
    self.totalWeight = self.totalWeight + item[2]
  end
  self.iLevelTimer = 0
  self.iLevelTime = self.mLevelCfg.m_Time / 1000
  self.m_timer_Text.text = os.date("%M:%S", self.iLevelTime)
  self.iCurFreshTimer = 0
  self.iCurScore = 0
  self.iBossDeadCount = 0
  self.iBossBornCount = 0
  self.m_score_Text.text = self.iCurScore
  self.m_txt_scorefull_Text.text = self.iTargetScore > 0 and "/" .. self.iTargetScore or ""
  self.m_img_slider:SetActive(false)
  self.m_img_slider_boss:SetActive(true)
  self.m_bossHP:SetActive(true)
  self.m_monsterNode1:SetActive(self.iTerrain == 1)
  self.m_monsterNode2:SetActive(self.iTerrain == 2)
  self.m_monsterNode3:SetActive(self.iTerrain == 3)
  self.m_monsterNode4:SetActive(self.iTerrain == 4)
  self.m_Hole1:SetActive(self.iTerrain == 1)
  self.m_Hole2:SetActive(self.iTerrain == 2)
  self.m_Hole3:SetActive(self.iTerrain == 3)
  self.m_Hole4:SetActive(self.iTerrain == 4)
end

function Form_WhackMoleBattleMain:InitMoleData()
  if self.bIsInit then
    return
  end
  local posParent = self["m_monsterNode" .. self.iTerrain].transform
  if self.iBossID and self.iBossID > 0 then
    local mCurBossData = self.mCurBossData
    posParent = self.m_Moles.transform
    mCurBossData = {
      obj = self.mLoadedMoleAssets[self.iBossID].go
    }
    local btn = self.m_Boss:GetComponent("ButtonExtensions")
    
    function btn.Clicked()
      self:OnMoleBossClicked()
    end
    
    mCurBossData.obj:SetActive(false)
    mCurBossData.bIsActive = false
    mCurBossData.bIsAlive = false
    self.mCurBossData = mCurBossData
  end
  self.MaxMoleCount = posParent.childCount
  for i = 1, self.MaxMoleCount do
    local child = posParent:GetChild(i - 1)
    local btn = child:GetComponent("ButtonExtensions")
    
    function btn.Clicked()
      self:OnMoleClicked(i)
    end
    
    self.m_MoleCache[i] = {}
    self.m_MoleCache[i].obj = child.gameObject
    self.m_MoleCache[i].obj:SetActive(false)
    self.m_MoleCache[i].bIsActive = false
    self.m_MoleCache[i].bIsAlive = false
  end
  self:GenerateRandomData()
  self:FreshBoss()
  self.bIsInit = true
  self:FreshMonster()
end

function Form_WhackMoleBattleMain:GenerateRandomData()
  self.iCurFreshMonsterIDList = {}
  if self.iBornInterval[2] then
    self.iCurFreshtime = math.random(self.iBornInterval[1], self.iBornInterval[2]) / 1000
  else
    self.iCurFreshtime = self.iBornInterval[1] / 1000
  end
  local iCurFreshCount = 0
  if self.mRefreshNumberList[2] then
    iCurFreshCount = math.random(self.mRefreshNumberList[1], self.mRefreshNumberList[2])
  else
    iCurFreshCount = self.mRefreshNumberList[1]
  end
  iCurFreshCount = math.min(iCurFreshCount, self.MaxMoleCount)
  for i = 1, iCurFreshCount do
    local rand = math.random(self.totalWeight)
    local temp = 0
    for _, item in ipairs(self.mMonsterIDList) do
      temp = temp + item[2]
      if rand <= temp then
        self.iCurFreshMonsterIDList[i] = item[1]
        break
      end
    end
  end
end

function Form_WhackMoleBattleMain:FreshBoss()
  if self.iMode == ModeType.TimeLimit then
    return
  end
  local mCurBossData = self.mCurBossData
  if mCurBossData and mCurBossData.bIsAlive then
    return
  end
  if not self.iBossID or self.iBossID <= 0 then
    return
  end
  if self.iMoleDeadCount >= self.iBossFreshCount then
    self.iMoleDeadCount = 0
    self.iBossBornCount = self.iBossBornCount + 1
    local bossCfg = HeroActivityManager:GetWhackaMoleEnemyCfgByID(self.iBossID)
    mCurBossData.obj:SetActive(true)
    mCurBossData.iShield = bossCfg.m_Shield
    mCurBossData.iStunTime = bossCfg.m_DizzinessTime / 1000
    self:PlayBossAnim(mCurBossData.obj, self.BossAniEnum.Born, self.BossAniEnum.ShieldRestore, nil, function()
      if not mCurBossData then
        return
      end
      if self.m_pnl_scoredot then
        UILuaHelper.PlayAnimationByName(self.m_pnl_scoredot, "pnl_scoredot_in")
      end
      local animLength = UILuaHelper.GetAnimatorLengthByNameInChildren(mCurBossData.obj, self.BossAniEnum.ShieldRestore)
      self.m_BossTimer = TimeService:SetTimer(animLength, 1, function()
        self.m_BossTimer = nil
        if utils.isNull(mCurBossData) then
          return
        end
        self:PlayBossAnim(mCurBossData.obj, self.BossAniEnum.IdleShield)
      end)
    end)
    mCurBossData.iHP = bossCfg.m_HP
    mCurBossData.bIsActive = true
    mCurBossData.bIsAlive = true
    mCurBossData.cfg = bossCfg
    self.m_bossName_Text.text = bossCfg.m_mName
    self.m_bossShield_Text.text = tostring(mCurBossData.iShield)
    self.m_img_slider_Image.fillAmount = mCurBossData.iShield / mCurBossData.cfg.m_Shield
    self.m_bossHP_Text.text = tostring(mCurBossData.iHP) .. "/" .. mCurBossData.cfg.m_HP
    self.m_img_slider_boss_Image.fillAmount = mCurBossData.iHP / mCurBossData.cfg.m_HP
    self.m_img_slider:SetActive(true)
    self.m_img_slider_boss:SetActive(false)
    self.m_bossHP:SetActive(true)
    self.m_pnl_boss:SetActive(true)
  end
  self.mCurBossData = mCurBossData
end

function Form_WhackMoleBattleMain:FreshMonster()
  local mCurBossData = self.mCurBossData
  if mCurBossData and mCurBossData.bIsAlive and mCurBossData.iShield <= 0 then
    return
  end
  for i, v in ipairs(self.iCurFreshMonsterIDList) do
    local posIdx = math.random(1, self.MaxMoleCount)
    local bIsUsed = self.m_MoleCache[posIdx].bIsActive
    if bIsUsed then
      posIdx = nil
      for _idx, moleData in ipairs(self.m_MoleCache) do
        if not moleData.bIsActive and _idx <= self.MaxMoleCount then
          posIdx = _idx
          break
        end
      end
    end
    if posIdx then
      self:ActiveMonster(posIdx, v)
    end
  end
  self.mCurBossData = mCurBossData
end

function Form_WhackMoleBattleMain:ActiveMonster(posIdx, monsterID)
  if not self.bIsInit or self.bIsBattleEnd then
    return
  end
  local moleData = self.m_MoleCache[posIdx]
  local monsterCfg = HeroActivityManager:GetWhackaMoleEnemyCfgByID(monsterID)
  if not monsterCfg then
    return
  end
  moleData.bIsAlive = true
  moleData.bIsActive = true
  if self.m_MoleTimer[posIdx] then
    TimeService:KillTimer(self.m_MoleTimer[posIdx])
    self.m_MoleTimer[posIdx] = nil
  end
  if self.m_MoleDeadTimer[posIdx] then
    TimeService:KillTimer(self.m_MoleDeadTimer[posIdx])
    self.m_MoleDeadTimer[posIdx] = nil
  end
  if self.m_AttackTimer[posIdx] then
    TimeService:KillTimer(self.m_AttackTimer[posIdx])
    self.m_AttackTimer[posIdx] = nil
  end
  local moletrans = self.m_cacheNode.transform:Find(monsterCfg.m_ID)
  if moletrans then
    moletrans:SetParent(moleData.obj.transform)
    moleData.moletrans = moletrans
    moletrans.localPosition = Vector3.zero
    moletrans.gameObject:SetActive(true)
  else
    moletrans = GameObject.Instantiate(self.mLoadedMoleAssets[monsterCfg.m_ID].go).transform
    moletrans.gameObject.name = monsterCfg.m_ID
    moletrans:SetParent(moleData.obj.transform)
    moletrans.localPosition = Vector3.zero
    moletrans.gameObject:SetActive(true)
    moleData.moletrans = moletrans
  end
  moletrans.localScale = Vector3.one * monsterCfg.m_Scale[0]
  moleData.iAliveTime = monsterCfg.m_RetreatTime / 1000
  moleData.bIsRetreating = false
  moleData.iHP = monsterCfg.m_HP
  moleData.cfg = monsterCfg
  moleData.obj:SetActive(true)
  self:PlayMoleAnim(moleData.moletrans, posIdx, self.MoleAniEnum.Born, self.MoleAniEnum.Idle)
end

function Form_WhackMoleBattleMain:OnMoleBossClicked()
  if not self.bIsInit or self.bIsBattleEnd then
    return
  end
  local mCurBossData = self.mCurBossData
  if not (mCurBossData and mCurBossData.bIsAlive) or not mCurBossData.bIsActive then
    return
  end
  if self.m_BossTimer then
    return
  end
  if self.m_bIsStun then
    return
  end
  if mCurBossData.iShield > 0 then
    self:PlayBossAnim(mCurBossData.obj, self.BossAniEnum.HitShield, self.BossAniEnum.IdleShield, mCurBossData.cfg)
    return
  end
  local iHp = mCurBossData.iHP
  mCurBossData.iHP = iHp - 1
  if mCurBossData.iHP == 0 then
    self.iBossDeadCount = self.iBossDeadCount + 1
    mCurBossData.bIsAlive = false
    self:PlayBossAnim(mCurBossData.obj, self.BossAniEnum.TakeAHit, self.BossAniEnum.Dead)
    local animLength = UILuaHelper.GetAnimatorLengthByNameInChildren(mCurBossData.obj, self.BossAniEnum.TakeAHit) + UILuaHelper.GetAnimatorLengthByNameInChildren(mCurBossData.obj, self.BossAniEnum.Dead)
    if self.m_BossDeadTimer then
      TimeService:KillTimer(self.m_BossDeadTimer)
      self.m_BossDeadTimer = nil
    end
    self.m_BossDeadTimer = TimeService:SetTimer(animLength, 1, function()
      if utils.isNull(mCurBossData) then
        return
      end
      mCurBossData.obj:SetActive(false)
      mCurBossData.bIsActive = false
      if self.bIsBattleEnd then
        self:OnLevelEnd()
      end
    end)
    self.iCurScore = self.iCurScore + mCurBossData.cfg.m_Score
    if self.iMode == ModeType.Boss then
      self.bIsBattleEnd = true
      self:IsBattleEnd()
    end
    self.m_img_slider:SetActive(false)
    self.m_img_slider_boss:SetActive(false)
    self.m_bossHP:SetActive(false)
  else
    self:PlayBossAnim(mCurBossData.obj, self.BossAniEnum.TakeAHit, self.BossAniEnum.Stun, mCurBossData.cfg)
  end
  self.m_bossHP_Text.text = tostring(mCurBossData.iHP) .. "/" .. mCurBossData.cfg.m_HP
  self.m_img_slider_boss_Image.fillAmount = mCurBossData.iHP / mCurBossData.cfg.m_HP
  self:IsBattleEnd()
  self.mCurBossData = mCurBossData
end

function Form_WhackMoleBattleMain:OnMoleClicked(idx)
  if not self.bIsInit then
    return
  end
  local moleData = self.m_MoleCache[idx]
  if not (moleData and moleData.bIsAlive) or not moleData.bIsActive then
    return
  end
  if self.m_bIsStun then
    return
  end
  local iHp = moleData.iHP
  moleData.iHP = iHp - 1
  if moleData.iHP == 0 then
    self:PlayMoleAnim(moleData.moletrans, idx, self.MoleAniEnum.TakeAHit, self.MoleAniEnum.Dead, moleData.cfg)
    moleData.bIsAlive = false
    local animLength = UILuaHelper.GetAnimatorLengthByNameInChildren(moleData.obj, self.MoleAniEnum.TakeAHit) + UILuaHelper.GetAnimatorLengthByNameInChildren(moleData.obj, self.MoleAniEnum.Dead)
    if self.m_MoleDeadTimer[idx] then
      TimeService:KillTimer(self.m_MoleDeadTimer[idx])
      self.m_MoleDeadTimer[idx] = nil
    end
    if self.m_AttackTimer[idx] then
      TimeService:KillTimer(self.m_AttackTimer[idx])
      self.m_AttackTimer[idx] = nil
    end
    self.m_MoleDeadTimer[idx] = TimeService:SetTimer(animLength, 1, function()
      if utils.isNull(moleData) then
        return
      end
      moleData.bIsActive = false
      moleData.obj:SetActive(false)
      moleData.moletrans:SetParent(self.m_cacheNode.transform)
      if self.bIsBattleEnd then
        self:OnLevelEnd()
      end
    end)
    local mCurBossData = self.mCurBossData
    if (self.iMode == ModeType.Boss or self.iMode == ModeType.Infinity) and (not mCurBossData or not mCurBossData.bIsAlive) then
      self.iMoleDeadCount = self.iMoleDeadCount + 1
    end
    self.iCurScore = self.iCurScore + moleData.cfg.m_Score
    if mCurBossData and mCurBossData.bIsAlive and 0 < mCurBossData.iShield then
      mCurBossData.iShield = mCurBossData.iShield - 1
      self.m_bossShield_Text.text = tostring(mCurBossData.iShield)
      self.m_img_slider_Image.fillAmount = mCurBossData.iShield / mCurBossData.cfg.m_Shield
      self:StunBoss()
    end
    if moleData.cfg.m_ID == 2 then
      self:StunPlayer(moleData.cfg)
    end
    self.mCurBossData = mCurBossData
  else
    self:PlayMoleAnim(moleData.moletrans, idx, self.MoleAniEnum.TakeAHit, self.MoleAniEnum.Idle)
  end
  self:FreshBoss()
  self:IsBattleEnd()
end

function Form_WhackMoleBattleMain:OnMoleRetreat(posIdx)
  local moleData = self.m_MoleCache[posIdx]
  if not moleData then
    return
  end
  local animLength = UILuaHelper.GetAnimatorLengthByNameInChildren(moleData.obj, self.MoleAniEnum.Retreat) + UILuaHelper.GetAnimatorLengthByNameInChildren(moleData.obj, self.MoleAniEnum.Attack)
  if self.m_MoleDeadTimer[posIdx] then
    TimeService:KillTimer(self.m_MoleDeadTimer[posIdx])
    self.m_MoleDeadTimer[posIdx] = nil
  end
  if self.m_AttackTimer[posIdx] then
    TimeService:KillTimer(self.m_AttackTimer[posIdx])
    self.m_AttackTimer[posIdx] = nil
  end
  if moleData.cfg.m_ID == 3 then
    self:PlayMoleAnim(moleData.moletrans, posIdx, self.MoleAniEnum.Attack, self.MoleAniEnum.Retreat)
    self.m_AttackTimer[posIdx] = TimeService:SetTimer(0.5, 1, function()
      if utils.isNull(moleData) then
        return
      end
      self:BlindPlayer(moleData.cfg)
    end)
  else
    self:PlayMoleAnim(moleData.moletrans, posIdx, self.MoleAniEnum.Retreat)
    animLength = UILuaHelper.GetAnimatorLengthByNameInChildren(moleData.obj, self.MoleAniEnum.Retreat)
  end
  moleData.bIsRetreating = true
  self.m_MoleDeadTimer[posIdx] = TimeService:SetTimer(animLength, 1, function()
    if utils.isNull(moleData) then
      return
    end
    moleData.bIsAlive = false
    moleData.bIsActive = false
    moleData.obj:SetActive(false)
    moleData.moletrans:SetParent(self.m_cacheNode.transform)
  end)
end

function Form_WhackMoleBattleMain:StunPlayer(cfg)
  if not self.bIsInit or self.bIsBattleEnd then
    return
  end
  self.m_bIsStun = true
  self.m_StunNode:SetActive(true)
  if self.iStunTimer then
    TimeService:KillTimer(self.iStunTimer)
    self.iStunTimer = nil
  end
  self.iStunTimer = TimeService:SetTimer(cfg.m_SkillTime / 1000, 1, function()
    self.m_bIsStun = false
    if utils.isNull(self.m_StunNode) then
      return
    end
    self.m_StunNode:SetActive(false)
    UILuaHelper.StartPlaySFX("Stop_UI_WhackMole_Electric")
  end)
  UILuaHelper.StartPlaySFX("Play_UI_WhackMole_Electric")
end

function Form_WhackMoleBattleMain:BlindPlayer(cfg)
  if not self.bIsInit or self.bIsBattleEnd then
    return
  end
  self.m_BlindNode:SetActive(true)
  self.m_BlindNode_CG.alpha = 1
  if self.sequence then
    self.sequence:Kill()
    self.sequence = nil
  end
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(cfg.m_SkillTime / 1000)
  sequence:Append(DOTweenModuleUI.DOFade(self.m_BlindNode_CG, 0, 1))
  sequence:OnComplete(function()
    self.m_BlindNode:SetActive(false)
  end)
  sequence:SetAutoKill(true)
  self.sequence = sequence
  UILuaHelper.StartPlaySFX("Play_UI_WhackMole_Ink")
end

function Form_WhackMoleBattleMain:StunBoss()
  local mCurBossData = self.mCurBossData
  if mCurBossData and mCurBossData.iShield <= 0 then
    self.m_bossShield_Text.text = ""
    if self.m_pnl_scoredot then
      UILuaHelper.PlayAnimationByName(self.m_pnl_scoredot, "pnl_scoredot_break")
    end
    self:PlayBossAnim(mCurBossData.obj, self.BossAniEnum.ShieldBreak, self.BossAniEnum.Stun)
    self.m_img_slider:SetActive(false)
    self.m_img_slider_boss:SetActive(true)
  end
  self.mCurBossData = mCurBossData
end

function Form_WhackMoleBattleMain:IsBattleEnd()
  self.m_score_Text.text = self.iCurScore
  if self.iMode == ModeType.TimeLimit then
    if self.iCurScore >= self.iTargetScore then
      self.bIsInit = false
      self.bIsBattleEnd = true
    end
  elseif self.iMode == ModeType.Boss and self.iBossDeadCount > 0 then
    self.bIsInit = false
    self.bIsBattleEnd = true
  end
end

function Form_WhackMoleBattleMain:OnLevelEnd()
  self.bIsInit = false
  local bIsWin = false
  if self.iMode == ModeType.Boss then
    bIsWin = self.iBossDeadCount > 0
  elseif self.iMode == ModeType.Infinity then
    bIsWin = true
  else
    bIsWin = self.iCurScore >= self.iTargetScore
  end
  local battleResult = {
    isWin = bIsWin,
    curScore = self.iCurScore,
    curLevelId = self.iLevelID,
    curSubActId = self.subActId,
    iActId = self.iActId,
    callback = function()
      self:CloseForm()
    end
  }
  StackPopup:Push(UIDefines.ID_FORM_WHACKMOLEBATTLERESULT, battleResult)
end

function Form_WhackMoleBattleMain:OnBtnbackClicked()
  if self.bIsInit then
    self.bIsPause = true
    local time = self:GetCurLeftTime()
    if self.m_BattleEndTimer then
      TimeService:KillTimer(self.m_BattleEndTimer)
      self.m_BattleEndTimer = nil
    end
    StackPopup:Push(UIDefines.ID_FORM_WHACKMOLETIPS, {
      type = 1,
      backFun_Yes = function()
        self:CloseForm()
      end,
      backFun_No = function()
        self.bIsPause = false
        self.m_BattleEndTimer = TimeService:SetTimer(1, time, function()
          if utils.isNull(self.m_timer_Text) then
            return
          end
          time = time - 1
          self.m_timer_Text.text = os.date("%M:%S", time)
        end)
      end
    })
  end
end

function Form_WhackMoleBattleMain:GetAHammerObj()
  local hammerData = {}
  local hammerObj = self.m_cacheNode.transform:Find("ui_hammer")
  if hammerObj then
  else
    hammerObj = GameObject.Instantiate(self.m_ui_hammer).transform
    hammerObj.gameObject.name = "ui_hammer"
  end
  hammerData.obj = hammerObj
  hammerData.obj:GetChild(0):GetComponent("SpriteRenderer").sprite = nil
  return hammerData
end

function Form_WhackMoleBattleMain:PlayMoleAnim(moletrans, idx, sAniName1, sAniName2, moleCfg)
  if self.m_MoleTimer[idx] then
    TimeService:KillTimer(self.m_MoleTimer[idx])
    self.m_MoleTimer[idx] = nil
  end
  UILuaHelper.PlayAnimatorByNameInChildren(moletrans, sAniName1)
  self:PlayMoleActionVoice(sAniName1)
  local hammerData
  local animLength = UILuaHelper.GetAnimatorLengthByNameInChildren(moletrans, sAniName1)
  if sAniName2 then
    if sAniName1 == self.MoleAniEnum.TakeAHit then
      hammerData = self:GetAHammerObj()
      hammerData.obj:SetParent(moletrans.transform)
      if moleCfg then
        local pos = utils.changeCSArrayToLuaTable(moleCfg.m_HammerPos)
        if pos then
          hammerData.obj.localPosition = Vector3.New(pos[1] / 1000, pos[2] / 1000, 0)
        else
          hammerData.obj.localPosition = Vector3.zero
        end
        hammerData.obj.localScale = Vector3.one * (100 / moleCfg.m_Scale[0])
      else
        hammerData.obj.localPosition = Vector3.zero
      end
      hammerData.obj.gameObject:SetActive(true)
      UILuaHelper.PlayAnimatorByNameInChildren(hammerData.obj.gameObject, self.HammerHitAni)
      local t = TimeService:SetTimer(0.16, 1, function()
        if hammerData then
          hammerData.obj.gameObject:SetActive(false)
          hammerData.obj:SetParent(self.m_cacheNode.transform)
        end
        if self.m_HammerTimer[1] then
          TimeService:KillTimer(self.m_HammerTimer[1].timer)
          table.remove(self.m_HammerTimer, 1)
        end
      end)
      table.insert(self.m_HammerTimer, {timer = t, hammerData = hammerData})
    end
    self.m_MoleTimer[idx] = TimeService:SetTimer(animLength, 1, function()
      if utils.isNull(moletrans) then
        return
      end
      UILuaHelper.PlayAnimatorByNameInChildren(moletrans, sAniName2)
      self:PlayMoleActionVoice(sAniName2)
    end)
  end
end

function Form_WhackMoleBattleMain:PlayHitBossFx()
  local randomIdx = math.random(1, #self.vHitBossFx)
  if self.vHitBossFx[randomIdx].isPlaying then
    for i, v in ipairs(self.vHitBossFx) do
      if not v.isPlaying then
        randomIdx = i
        break
      end
    end
  end
  randomIdx = randomIdx or 1
  self.vHitBossFx[randomIdx].isPlaying = true
  self.vHitBossFx[randomIdx].obj:SetActive(false)
  self.vHitBossFx[randomIdx].obj:SetActive(true)
  local time = UILuaHelper.GetAnimationLengthByName(self.vHitBossFx[randomIdx].obj, "pnl_bingo_in")
  TimeService:SetTimer(time, 1, function()
    if utils.isNull(self.vHitBossFx[randomIdx]) then
      return
    end
    self.vHitBossFx[randomIdx].isPlaying = false
    if utils.isNull(self.vHitBossFx[randomIdx].obj) then
      return
    end
    self.vHitBossFx[randomIdx].obj:SetActive(false)
  end)
end

function Form_WhackMoleBattleMain:PlayBossAnim(go, sAniName1, sAniName2, moleCfg, cb)
  if self.m_BossTimer then
    return
  end
  self.m_BossTimer = true
  local hammerData
  local animLength = UILuaHelper.GetAnimatorLengthByNameInChildren(go, sAniName1)
  if sAniName2 then
    if sAniName1 == self.BossAniEnum.TakeAHit or sAniName1 == self.BossAniEnum.HitShield then
      hammerData = self:GetAHammerObj()
      hammerData.obj:SetParent(go.transform)
      if moleCfg then
        local pos = utils.changeCSArrayToLuaTable(moleCfg.m_HammerPos)
        if pos then
          hammerData.obj.localPosition = Vector3.New(pos[1] / 1000, pos[2] / 1000, 0)
        else
          hammerData.obj.localPosition = Vector3.zero
        end
        hammerData.obj.localScale = Vector3.one * (100 / moleCfg.m_Scale[0])
      else
        hammerData.obj.localPosition = Vector3.zero
      end
      if sAniName1 == self.BossAniEnum.TakeAHit then
        self:PlayHitBossFx(animLength)
      end
      hammerData.obj.gameObject:SetActive(true)
      UILuaHelper.PlayAnimatorByNameInChildren(hammerData.obj.gameObject, self.HammerHitAni)
      local t = TimeService:SetTimer(0.18, 1, function()
        if hammerData then
          hammerData.obj.gameObject:SetActive(false)
          hammerData.obj:SetParent(self.m_cacheNode.transform)
        end
        if self.m_HammerTimer[1] then
          TimeService:KillTimer(self.m_HammerTimer[1].timer)
          table.remove(self.m_HammerTimer, 1)
        end
      end)
      table.insert(self.m_HammerTimer, {timer = t, hammerData = hammerData})
      self.curhammerData = hammerData
    end
    
    local function PlayAnim()
      if utils.isNull(go) then
        return
      end
      UILuaHelper.PlayAnimatorByNameInChildren(go, sAniName1)
      self:PlayBossActionVoice(sAniName1)
      self.m_BossTimer = TimeService:SetTimer(animLength + 0.01, 1, function()
        if utils.isNull(go) then
          return
        end
        if (sAniName1 == self.BossAniEnum.TakeAHit or sAniName1 == self.BossAniEnum.HitShield) and hammerData then
          hammerData.obj.gameObject:SetActive(false)
          hammerData.obj:SetParent(self.m_cacheNode.transform)
          self.curhammerData = nil
        end
        UILuaHelper.PlayAnimatorByNameInChildren(go, sAniName2)
        self:PlayBossActionVoice(sAniName2)
        self.m_BossTimer = nil
        if cb then
          cb()
        end
      end)
    end
    
    if hammerData then
      TimeService:SetTimer(0.025, 1, function()
        PlayAnim()
      end)
    else
      PlayAnim()
    end
  else
    UILuaHelper.PlayAnimatorByNameInChildren(go, sAniName1)
    self:PlayBossActionVoice(sAniName1)
    self.m_BossTimer = TimeService:SetTimer(animLength, 1, function()
      if utils.isNull(go) then
        return
      end
      self.m_BossTimer = nil
      if cb then
        cb()
      end
    end)
  end
end

function Form_WhackMoleBattleMain:GetCurLeftTime()
  local time = math.ceil(self.iLevelTime - self.iLevelTimer)
  if time <= 0 then
    time = 0
  end
  return time
end

function Form_WhackMoleBattleMain:PlayMoleActionVoice(sAniName1)
  if sAniName1 == self.MoleAniEnum.Born then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_MonsterBorn")
  elseif sAniName1 == self.MoleAniEnum.Dead then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_MonsterDie")
  elseif sAniName1 == self.MoleAniEnum.TakeAHit then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_HitMonster")
  end
end

function Form_WhackMoleBattleMain:PlayBossActionVoice(sAniName1)
  if sAniName1 == self.BossAniEnum.TakeAHit then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_HitBoss")
  elseif sAniName1 == self.BossAniEnum.HitShield then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_HitShiled")
  elseif sAniName1 == self.BossAniEnum.ShieldBreak then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_BreakShiled")
  elseif sAniName1 == self.BossAniEnum.ShieldRestore then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_CreatShiled")
  elseif sAniName1 == self.BossAniEnum.Born then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_MonsterBorn")
  elseif sAniName1 == self.BossAniEnum.Dead then
    UILuaHelper.StartPlaySFX("Play_UI_WhackMole_MonsterDie")
  end
end

function Form_WhackMoleBattleMain:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "ui_hammer",
    eType = DownloadManager.ResourceType.Prefab
  }
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "ui_mole_ElectricEel",
    eType = DownloadManager.ResourceType.Prefab
  }
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "ui_mole_Kraken",
    eType = DownloadManager.ResourceType.Prefab
  }
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "ui_mole_KrakenBig",
    eType = DownloadManager.ResourceType.Prefab
  }
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "ui_mole_SquidH",
    eType = DownloadManager.ResourceType.Prefab
  }
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleBattleMain", Form_WhackMoleBattleMain)
return Form_WhackMoleBattleMain
