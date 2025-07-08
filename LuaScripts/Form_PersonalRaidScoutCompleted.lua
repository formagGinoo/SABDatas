local Form_PersonalRaidScoutCompleted = class("Form_PersonalRaidScoutCompleted", require("UI/UIFrames/Form_PersonalRaidScoutCompletedUI"))

function Form_PersonalRaidScoutCompleted:SetInitParam(param)
end

function Form_PersonalRaidScoutCompleted:AfterInit()
  self.super.AfterInit(self)
end

function Form_PersonalRaidScoutCompleted:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_newStageCfg = tParam.newStageCfg
  self.m_rankData = tParam.rankData
  self.m_txt_damagenum_Text.text = ""
  if self.m_rankData then
    if self.m_rankData.iNewRank == self.m_rankData.iOldRank then
      self.m_pnl_ranking:SetActive(false)
    else
      self.m_pnl_ranking:SetActive(true)
      local num = PersonalRaidManager:GetRankNameByRankAndTotal(self.m_rankData.iNewRank, self.m_rankData.iRankSize)
      self.m_txt_rankingnum02_Text.text = num
      local num2 = PersonalRaidManager:GetRankNameByRankAndTotal(self.m_rankData.iOldRank, self.m_rankData.iRankSize)
      self.m_txt_rankingnum_Text.text = num2
    end
    if string.compare_numeric_strings(self.m_rankData.iDamage, GlobalConfig.__MAX_SAFE_INT_STR, false) then
      self.m_txt_damagenum_Text.text = tostring(self.m_rankData.iDamage)
    else
      TimeService:SetTimer(1, 1, function()
        self:SetDamageAnim(tonumber(self.m_rankData.iDamage))
      end)
    end
    if self.m_rankData.iRaidId then
      local cfg = PersonalRaidManager:GetSoloRaidLevelCfgById(self.m_rankData.iRaidId)
      if cfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard then
        self.m_txt_num_Text.text = ""
      else
        self.m_txt_num_Text.text = tostring(cfg.m_mName)
      end
      self.m_img_bossicon:SetActive(cfg.m_LevelMode == PersonalRaidManager.SoloRaidMode.SoloRaidMode_Hard)
    end
  else
    log.error("Form_PersonalRaidScoutCompleted is error self.m_rankData = nil")
  end
end

function Form_PersonalRaidScoutCompleted:OnInactive()
  self.super.OnInactive(self)
end

function Form_PersonalRaidScoutCompleted:SetDamageAnim(iDamage)
  local min = math.floor(iDamage / 10)
  local numTab = utils.generateUniqueRandomXNumOfRange(min, iDamage, 10)
  if not numTab then
    self.m_txt_damagenum_Text.text = iDamage
  else
    for i = 1, #numTab do
      local damage = numTab[i]
      if i == #numTab then
        damage = iDamage
      end
      self:OnCreateDamageAnim(damage, 0.08 * i)
    end
  end
end

function Form_PersonalRaidScoutCompleted:OnCreateDamageAnim(iDamage, delay)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(delay or 0.1)
  sequence:OnComplete(function()
    if self and not utils.isNull(self.m_txt_damagenum_Text) then
      self.m_txt_damagenum_Text.text = tostring(iDamage)
      if sequence then
        sequence:Kill()
        sequence = nil
      end
    end
  end)
  sequence:SetAutoKill(true)
end

function Form_PersonalRaidScoutCompleted:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PersonalRaidScoutCompleted:OnBtnCloseClicked()
  self:CloseForm()
  if self.m_newStageCfg then
    StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDNEWDIFFICULT, self.m_newStageCfg)
  end
end

function Form_PersonalRaidScoutCompleted:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidScoutCompleted", Form_PersonalRaidScoutCompleted)
return Form_PersonalRaidScoutCompleted
