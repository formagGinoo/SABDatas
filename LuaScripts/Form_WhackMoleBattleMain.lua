local Form_WhackMoleBattleMain = class("Form_WhackMoleBattleMain", require("UI/UIFrames/Form_WhackMoleBattleMainUI"))
local MoleType = {Normal = 1, Boss = 2}
local ModeType = {
  TimeLimit = 1,
  Boss = 2,
  Infinity = 3
}
local bIsInit = false
local iTerrain = 1
local iMode = 1
local MaxMoleCount
local iLevelTimer = 0
local iLevelTime = 0
local iCurFreshTimer = 0
local iCurFreshtime, iCurFreshMonsterIDList
local totalWeight = 0
local iMoleDeadCount = 0
local iBossFreshCount = 0
local mCurBossData
local iBossID = 4
local iBossBornCount = 0
local iBossDeadCount = 0
local iCurScore = 0
local iTargetScore = 0
local AnimatorparamsEnum = {
  Attack = "Attack",
  Retreat = "Retreat",
  Take_a_hit = "Take_a_hit",
  HP = "HP",
  HitSHield = "Hit_ShieldBoss"
}

function Form_WhackMoleBattleMain:SetInitParam(param)
end

function Form_WhackMoleBattleMain:AfterInit()
  self.super.AfterInit(self)
  self.m_MoleCache = {}
  self.m_MoleTimer = {}
  self.m_MoleDeadTimer = {}
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
end

function Form_WhackMoleBattleMain:OnActive()
  self.super.OnActive(self)
  self.m_StunNode:SetActive(false)
  self.m_BlindNode:SetActive(false)
  bIsInit = false
  self:FreshData()
  bIsInit = true
end

function Form_WhackMoleBattleMain:OnInactive()
  self.super.OnInactive(self)
  self:ResetTimer()
end

function Form_WhackMoleBattleMain:OnUpdate(dt)
  if not bIsInit then
    return
  end
  iLevelTimer = iLevelTimer + dt
  iCurFreshTimer = iCurFreshTimer + dt
  if iLevelTimer >= iLevelTime then
    bIsInit = false
    self:OnLevelEnd()
    return
  end
  if iCurFreshTimer >= iCurFreshtime then
    self:FreshMonster()
    iCurFreshTimer = 0
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
  if mCurBossData and mCurBossData.bIsAlive and 0 >= mCurBossData.iShield then
    mCurBossData.iStunTime = mCurBossData.iStunTime - dt
    if 0 >= mCurBossData.iStunTime then
      mCurBossData.iShield = mCurBossData.cfg.m_Shield
      mCurBossData.iStunTime = mCurBossData.cfg.m_DizzinessTime / 1000
      self.m_FX_Shield:SetActive(true)
      self.m_bossShield_Text.text = "护盾:" .. tostring(mCurBossData.iShield)
    end
  end
end

function Form_WhackMoleBattleMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_MoleCache then
    for _, v in pairs(self.m_MoleCache) do
      GameObject.Destroy(v.obj)
    end
  end
  self.m_MoleCache = {}
  self:ResetTimer()
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
  if self.iStunTimer then
    TimeService:KillTimer(self.iStunTimer)
    self.iStunTimer = nil
  end
  if self.m_BattleEndTimer then
    TimeService:KillTimer(self.m_BattleEndTimer)
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
  self.m_mole_Boss:SetActive(false)
  self.m_mole_normal:SetActive(false)
  mCurBossData = nil
  iTerrain = self.mLevelCfg.m_Terrain
  iTargetScore = self.mLevelCfg.m_VictoryCondition
  self.iBornInterval = utils.changeCSArrayToLuaTable(self.mLevelCfg.m_MonsterRefreshTime)
  self.mRefreshNumberList = utils.changeCSArrayToLuaTable(self.mLevelCfg.m_MonsterRefreshNumber)
  self.mMonsterIDList = utils.changeCSArrayToLuaTable(self.mLevelCfg.m_MonsterID)
  iMode = self.mLevelCfg.m_Mode
  iBossFreshCount = self.mLevelCfg.m_BossRule
  iBossID = self.mLevelCfg.m_BossID
  iMoleDeadCount = 0
  totalWeight = 0
  for _, item in ipairs(self.mMonsterIDList) do
    totalWeight = totalWeight + item[2]
  end
  iLevelTimer = 0
  iLevelTime = self.mLevelCfg.m_Time / 1000
  local left_time = iLevelTime
  self.m_timer_Text.text = "倒计时：" .. left_time
  self.m_BattleEndTimer = TimeService:SetTimer(1, left_time, function()
    left_time = left_time - 1
    self.m_timer_Text.text = "倒计时：" .. left_time
  end)
  iCurFreshTimer = 0
  iCurScore = 0
  iBossDeadCount = 0
  iBossBornCount = 0
  self.m_score_Text.text = "分数：" .. iCurScore
  self.m_bossShield:SetActive(false)
  self.m_bossHP:SetActive(false)
  self:InitMoleData()
end

function Form_WhackMoleBattleMain:InitMoleData()
  self.m_monsterNode1:SetActive(iTerrain == 1)
  self.m_monsterNode2:SetActive(iTerrain == 2)
  self.m_monsterNode3:SetActive(iTerrain == 3)
  self.m_monsterNode4:SetActive(iTerrain == 4)
  local posParent = self["m_monsterNode" .. iTerrain].transform
  if iTerrain == 4 then
    posParent = self.m_Moles.transform
    local tempObj = self.m_mole_Boss
    mCurBossData = {
      obj = tempObj,
      ani = tempObj:GetComponent("Animation"),
      icon = tempObj.transform:Find("Icon"):GetComponent("Image")
    }
    mCurBossData.obj:SetActive(false)
    mCurBossData.bIsActive = false
    mCurBossData.bIsAlive = false
  end
  MaxMoleCount = posParent.childCount
  for i = 1, MaxMoleCount do
    local child = posParent:GetChild(i - 1)
    if not self.m_MoleCache[i] then
      local tempObj = GameObject.Instantiate(self.m_mole_normal, child).gameObject
      self.m_MoleCache[i] = {
        obj = tempObj,
        ani = tempObj:GetComponent("Animation"),
        btn = tempObj:GetComponent("Button"),
        icon = tempObj.transform:Find("Icon"):GetComponent("Image")
      }
    else
      self.m_MoleCache[i].obj.transform:SetParent(child)
    end
    self.m_MoleCache[i].btn.onClick:RemoveAllListeners()
    self.m_MoleCache[i].btn.onClick:AddListener(function()
      self:OnMoleClicked(i)
    end)
    self.m_MoleCache[i].obj:SetActive(false)
    self.m_MoleCache[i].bIsActive = false
    self.m_MoleCache[i].bIsAlive = false
  end
  self:GenerateRandomData()
end

function Form_WhackMoleBattleMain:GenerateRandomData()
  iCurFreshMonsterIDList = {}
  if self.iBornInterval[2] then
    iCurFreshtime = math.random(self.iBornInterval[1], self.iBornInterval[2]) / 1000
  else
    iCurFreshtime = self.iBornInterval[1] / 1000
  end
  local iCurFreshCount = 0
  if self.mRefreshNumberList[2] then
    iCurFreshCount = math.random(self.mRefreshNumberList[1], self.mRefreshNumberList[2])
  else
    iCurFreshCount = self.mRefreshNumberList[1]
  end
  iCurFreshCount = math.min(iCurFreshCount, MaxMoleCount)
  for i = 1, iCurFreshCount do
    local rand = math.random(totalWeight)
    local temp = 0
    for _, item in ipairs(self.mMonsterIDList) do
      temp = temp + item[2]
      if rand <= temp then
        iCurFreshMonsterIDList[i] = item[1]
        break
      end
    end
  end
end

function Form_WhackMoleBattleMain:FreshBoss()
  if iMode == ModeType.TimeLimit then
    return
  end
  if mCurBossData and mCurBossData.bIsAlive then
    return
  end
  if iMoleDeadCount >= iBossFreshCount then
    iMoleDeadCount = 0
    if iBossBornCount == 0 then
      bIsInit = false
      iTerrain = 4
      self:InitMoleData()
      bIsInit = true
    end
    iBossBornCount = iBossBornCount + 1
    local bossCfg = HeroActivityManager:GetWhackaMoleEnemyCfgByID(iBossID)
    UILuaHelper.SetAtlasSprite(mCurBossData.icon, bossCfg.m_Prefab)
    mCurBossData.iShield = bossCfg.m_Shield
    mCurBossData.iStunTime = bossCfg.m_DizzinessTime / 1000
    self:PlayBossAnim(mCurBossData.ani, "BossBorn", "BossIdle")
    mCurBossData.iHP = bossCfg.m_HP
    mCurBossData.bIsActive = true
    mCurBossData.bIsAlive = true
    mCurBossData.cfg = bossCfg
    mCurBossData.obj:SetActive(true)
    self.m_FX_Shield:SetActive(true)
    self.m_bossShield_Text.text = "护盾:" .. tostring(mCurBossData.iShield)
    self.m_bossHP_Text.text = "生命: " .. tostring(mCurBossData.iHP)
    self.m_bossShield:SetActive(true)
    self.m_bossHP:SetActive(true)
  end
end

function Form_WhackMoleBattleMain:FreshMonster()
  if mCurBossData and mCurBossData.bIsAlive and mCurBossData.iShield <= 0 then
    return
  end
  for i, v in ipairs(iCurFreshMonsterIDList) do
    local posIdx = math.random(1, MaxMoleCount)
    local bIsUsed = self.m_MoleCache[posIdx].bIsAlive
    if bIsUsed then
      posIdx = nil
      for _idx, moleData in ipairs(self.m_MoleCache) do
        if not moleData.bIsActive and _idx <= MaxMoleCount then
          posIdx = _idx
          break
        end
      end
    end
    if posIdx then
      self:ActiveMonster(posIdx, v)
    end
  end
end

function Form_WhackMoleBattleMain:ActiveMonster(posIdx, monsterID)
  local moleData = self.m_MoleCache[posIdx]
  moleData.bIsAlive = true
  moleData.bIsActive = true
  local monsterCfg = HeroActivityManager:GetWhackaMoleEnemyCfgByID(monsterID)
  if not monsterCfg then
    return
  end
  if self.m_MoleTimer[posIdx] then
    TimeService:KillTimer(self.m_MoleTimer[posIdx])
    self.m_MoleTimer[posIdx] = nil
  end
  if self.m_MoleDeadTimer[posIdx] then
    TimeService:KillTimer(self.m_MoleDeadTimer[posIdx])
    self.m_MoleDeadTimer[posIdx] = nil
  end
  UILuaHelper.SetAtlasSprite(moleData.icon, monsterCfg.m_Prefab)
  moleData.iAliveTime = monsterCfg.m_RetreatTime / 1000
  moleData.bIsRetreating = false
  moleData.iHP = monsterCfg.m_HP
  moleData.cfg = monsterCfg
  moleData.obj.transform.localPosition = Vector3.zero
  moleData.obj:SetActive(true)
  self:PlayMoleAnim(moleData.ani, posIdx, "MoleBorn", "MoleIdle")
end

function Form_WhackMoleBattleMain:OnMoleBossClicked()
  if not (mCurBossData and mCurBossData.bIsAlive) or not mCurBossData.bIsActive then
    return
  end
  local ani = mCurBossData.ani
  if mCurBossData.iShield > 0 then
    self:PlayBossAnim(mCurBossData.ani, "BossHit_Shield", "BossIdle")
    return
  end
  if self.m_bIsStun then
    return
  end
  local iHp = mCurBossData.iHP
  mCurBossData.iHP = iHp - 1
  if mCurBossData.iHP == 0 then
    iBossDeadCount = iBossDeadCount + 1
    mCurBossData.bIsAlive = false
    self:PlayBossAnim(mCurBossData.ani, "BossTake_a_hit", "BossDead")
    local animLength = UILuaHelper.GetAnimationLengthByName(ani, "BossTake_a_hit") + UILuaHelper.GetAnimationLengthByName(ani, "BossDead")
    if self.m_BossDeadTimer then
      TimeService:KillTimer(self.m_BossDeadTimer)
      self.m_BossDeadTimer = nil
    end
    self.m_BossDeadTimer = TimeService:SetTimer(animLength, 1, function()
      mCurBossData.obj:SetActive(false)
      mCurBossData.bIsActive = false
    end)
    iCurScore = iCurScore + mCurBossData.cfg.m_Score
    if iMode == ModeType.Boss then
      self:OnLevelEnd()
    end
    self.m_bossShield:SetActive(false)
    self.m_bossHP:SetActive(false)
  else
    self:PlayBossAnim(mCurBossData.ani, "BossTake_a_hit", "BossIdle")
  end
  self.m_bossHP_Text.text = "生命: " .. tostring(mCurBossData.iHP)
  self:IsBattleEnd()
end

function Form_WhackMoleBattleMain:OnMoleClicked(idx)
  local moleData = self.m_MoleCache[idx]
  if not (moleData and moleData.bIsAlive) or not moleData.bIsActive then
    return
  end
  if self.m_bIsStun then
    return
  end
  local ani = moleData.ani
  local iHp = moleData.iHP
  moleData.iHP = iHp - 1
  if moleData.iHP == 0 then
    self:PlayMoleAnim(ani, idx, "MoleTake_a_hit", "MoleDead")
    moleData.bIsAlive = false
    local animLength = UILuaHelper.GetAnimationLengthByName(ani, "MoleTake_a_hit") + UILuaHelper.GetAnimationLengthByName(ani, "MoleDead")
    if self.m_MoleDeadTimer[idx] then
      TimeService:KillTimer(self.m_MoleDeadTimer[idx])
      self.m_MoleDeadTimer[idx] = nil
    end
    self.m_MoleDeadTimer[idx] = TimeService:SetTimer(animLength, 1, function()
      moleData.bIsActive = false
      moleData.obj:SetActive(false)
    end)
    if (iMode == ModeType.Boss or iMode == ModeType.Infinity) and (not mCurBossData or not mCurBossData.bIsAlive) then
      iMoleDeadCount = iMoleDeadCount + 1
    end
    iCurScore = iCurScore + moleData.cfg.m_Score
    if mCurBossData and mCurBossData.bIsAlive and 0 < mCurBossData.iShield then
      mCurBossData.iShield = mCurBossData.iShield - 1
      self.m_bossShield_Text.text = "护盾:" .. tostring(mCurBossData.iShield)
      self:StunBoss()
    end
    if moleData.cfg.m_ID == 2 then
      self:StunPlayer()
    end
  else
    self:PlayMoleAnim(ani, idx, "MoleTake_a_hit", "MoleIdle")
  end
  self:FreshBoss()
  self:IsBattleEnd()
end

function Form_WhackMoleBattleMain:OnMoleRetreat(posIdx)
  local moleData = self.m_MoleCache[posIdx]
  if not moleData then
    return
  end
  local ani = moleData.ani
  local animLength = UILuaHelper.GetAnimationLengthByName(ani, "MoleRetreat") + UILuaHelper.GetAnimationLengthByName(ani, "MoleAttack")
  if self.m_MoleDeadTimer[posIdx] then
    TimeService:KillTimer(self.m_MoleDeadTimer[posIdx])
    self.m_MoleDeadTimer[posIdx] = nil
  end
  if moleData.cfg.m_ID == 3 then
    self:BlindPlayer()
    self:PlayMoleAnim(ani, posIdx, "MoleAttack", "MoleRetreat")
  else
    self:PlayMoleAnim(ani, posIdx, "MoleRetreat")
    animLength = UILuaHelper.GetAnimationLengthByName(ani, "MoleRetreat")
  end
  moleData.bIsRetreating = true
  self.m_MoleDeadTimer[posIdx] = TimeService:SetTimer(animLength, 1, function()
    moleData.bIsAlive = false
    moleData.bIsActive = false
    moleData.obj:SetActive(false)
  end)
end

function Form_WhackMoleBattleMain:StunPlayer()
  self.m_bIsStun = true
  self.m_StunNode:SetActive(true)
  if self.iStunTimer then
    TimeService:KillTimer(self.iStunTimer)
    self.iStunTimer = nil
  end
  self.iStunTimer = TimeService:SetTimer(2, 1, function()
    self.m_bIsStun = false
    self.m_StunNode:SetActive(false)
  end)
end

function Form_WhackMoleBattleMain:BlindPlayer()
  self.m_BlindNode:SetActive(true)
  if self.iBlindTimer then
    TimeService:KillTimer(self.iBlindTimer)
    self.iBlindTimer = nil
  end
  self.iBlindTimer = TimeService:SetTimer(2, 1, function()
    self.m_BlindNode:SetActive(false)
  end)
end

function Form_WhackMoleBattleMain:StunBoss()
  if mCurBossData and mCurBossData.iShield <= 0 then
    self.m_FX_Shield:SetActive(false)
  end
end

function Form_WhackMoleBattleMain:IsBattleEnd()
  self.m_score_Text.text = "分数：" .. iCurScore
  if iMode == ModeType.TimeLimit and iCurScore >= iTargetScore then
    self:OnLevelEnd()
  end
end

function Form_WhackMoleBattleMain:OnLevelEnd()
  self:CloseForm()
  bIsInit = false
  local bIsWin = false
  if iMode == ModeType.Boss then
    bIsWin = 0 < iBossDeadCount
  elseif iMode == ModeType.Infinity then
    bIsWin = true
  else
    bIsWin = iCurScore >= iTargetScore
  end
  local battleResult = {
    isWin = bIsWin,
    curScore = iCurScore,
    curLevelId = self.iLevelID,
    curSubActId = self.subActId,
    iActId = self.iActId
  }
  StackPopup:Push(UIDefines.ID_FORM_WHACKMOLEBATTLERESULT, battleResult)
end

function Form_WhackMoleBattleMain:OnBackClk()
  self:CloseForm()
end

function Form_WhackMoleBattleMain:PlayMoleAnim(anim, idx, aniName, aniName2)
  if self.m_MoleTimer[idx] then
    TimeService:KillTimer(self.m_MoleTimer[idx])
    self.m_MoleTimer[idx] = nil
  end
  UILuaHelper.PlayAnimationByName(anim, aniName)
  if aniName2 then
    local animLength = UILuaHelper.GetAnimationLengthByName(anim, aniName)
    self.m_MoleTimer[idx] = TimeService:SetTimer(animLength, 1, function()
      UILuaHelper.PlayAnimationByName(anim, aniName2)
    end)
  end
end

function Form_WhackMoleBattleMain:PlayBossAnim(anim, aniName, aniName2)
  UILuaHelper.PlayAnimationByName(anim, aniName)
  if aniName2 then
    local animLength = UILuaHelper.GetAnimationLengthByName(anim, aniName)
    if self.m_BossTimer then
      TimeService:KillTimer(self.m_BossTimer)
      self.m_BossTimer = nil
    end
    self.m_BossTimer = TimeService:SetTimer(animLength, 1, function()
      UILuaHelper.PlayAnimationByName(anim, aniName2)
    end)
  end
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleBattleMain", Form_WhackMoleBattleMain)
return Form_WhackMoleBattleMain
