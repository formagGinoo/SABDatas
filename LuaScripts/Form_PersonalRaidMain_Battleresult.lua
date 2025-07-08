local Form_PersonalRaidMain_Battleresult = class("Form_PersonalRaidMain_Battleresult", require("UI/UIFrames/Form_PersonalRaidMain_BattleresultUI"))

function Form_PersonalRaidMain_Battleresult:SetInitParam(param)
end

function Form_PersonalRaidMain_Battleresult:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_reward_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
end

function Form_PersonalRaidMain_Battleresult:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_rewardData = {}
  self.m_levelID = tParam.levelID
  self.simFlag = tParam.simFlag
  local rewardDataList = tParam.rewardData or {}
  for i, v in ipairs(rewardDataList) do
    local rewardData = ResourceUtil:GetProcessRewardData(v)
    self.m_rewardData[#self.m_rewardData + 1] = rewardData
  end
  self.m_curStageCfg = PersonalRaidManager:GetSoloRaidLevelCfgById(self.m_levelID)
  self.m_fightingMonster = tParam.fightingMonster
  self.m_iScore = tParam.iScore or 0
  if not self.m_curStageCfg then
    log.error("PersonalRaidBoss curStageCfg == nil" .. tostring(self.m_levelID))
    return
  end
  self:RefreshUI()
end

function Form_PersonalRaidMain_Battleresult:OnInactive()
  self.super.OnInactive(self)
end

function Form_PersonalRaidMain_Battleresult:RefreshUI()
  local cfg = PersonalRaidManager:GetSoloRaidBossCfgById(self.m_curStageCfg.m_BOSSID)
  if cfg then
    self.m_txt_name_Text.text = tostring(cfg.m_mName)
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_img_role_Image, cfg.m_Background2)
  end
  local curHp, maxHp = PersonalRaidManager:GetBossHp(self.m_fightingMonster, self.m_levelID)
  local hpPercent = string.format("%.2f", curHp / maxHp)
  self.m_img_slider_Image.fillAmount = hpPercent
  self.m_txt_slidernum_Text.text = string.format(ConfigManager:GetCommonTextById(20048), curHp, maxHp)
  if curHp == 0 then
    self.m_pnl_slider:SetActive(false)
    self.m_pnl_reward:SetActive(true)
    self.m_pnl_clear:SetActive(true)
    self.m_btn_candle:SetActive(false)
    TimeService:SetTimer(1, 1, function()
      self.m_btn_complete:SetActive(true)
    end)
    self.m_rewardListInfinityGrid:ShowItemList(self.m_rewardData)
  else
    self.m_pnl_clear:SetActive(true)
    self.m_pnl_slider:SetActive(true)
    self.m_pnl_reward:SetActive(false)
    self.m_btn_complete:SetActive(false)
    self.m_btn_candle:SetActive(true)
  end
  if self.m_curStageCfg.m_LevelMode == 2 then
    self.m_pnl_slider:SetActive(false)
  end
  self.m_txt_damage_Text.text = ""
  self.m_z_txt_noreward:SetActive(self.simFlag)
  if string.compare_numeric_strings(self.m_iScore, GlobalConfig.__MAX_SAFE_INT_STR, false) then
    self.m_txt_damage_Text.text = tostring(self.m_iScore)
  else
    TimeService:SetTimer(0.25, 1, function()
      self:SetDamageAnim(tonumber(self.m_iScore))
    end)
  end
end

function Form_PersonalRaidMain_Battleresult:SetDamageAnim(iDamage)
  local min = math.floor(iDamage / 10)
  local numTab = utils.generateUniqueRandomXNumOfRange(min, iDamage, 10)
  if not numTab then
    self.m_txt_damage_Text.text = iDamage
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

function Form_PersonalRaidMain_Battleresult:OnCreateDamageAnim(iDamage, delay)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(delay or 0.1)
  sequence:OnComplete(function()
    if self and not utils.isNull(self.m_txt_damage_Text) then
      self.m_txt_damage_Text.text = tostring(iDamage)
      if sequence then
        sequence:Kill()
        sequence = nil
      end
    end
  end)
  sequence:SetAutoKill(true)
end

function Form_PersonalRaidMain_Battleresult:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_rewardData[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function Form_PersonalRaidMain_Battleresult:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PersonalRaidMain_Battleresult:IsFullScreen()
  return true
end

function Form_PersonalRaidMain_Battleresult:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_PersonalRaidMain_Battleresult:OnBtncontinueClicked()
  self:CloseForm()
  if self.m_isSweep ~= true then
    BattleFlowManager:ExitBattle()
  end
end

function Form_PersonalRaidMain_Battleresult:OnBtnteamClicked()
  local heroIDList = CS.BattleGameManager.Instance:GetLogicBattleSystem():GetLogicCharactersID()
  local temp = utils.changeCSArrayToLuaTable(heroIDList)
  local param = {
    list = temp,
    isLuaTable = true,
    isBattleResult = true
  }
  StackFlow:Push(UIDefines.ID_FORM_BATTLETEAM, param)
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidMain_Battleresult", Form_PersonalRaidMain_Battleresult)
return Form_PersonalRaidMain_Battleresult
