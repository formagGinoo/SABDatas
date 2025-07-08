local Form_GuildRaidBossRoundTips = class("Form_GuildRaidBossRoundTips", require("UI/UIFrames/Form_GuildRaidBossRoundTipsUI"))

function Form_GuildRaidBossRoundTips:SetInitParam(param)
end

function Form_GuildRaidBossRoundTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuildRaidBossRoundTips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_Btn_Close:SetActive(false)
  local animStr = "Guild_bossroundtip_in2"
  local level = LocalDataManager:GetIntSimple("Form_GuildRaidBossRoundTips" .. tostring(tParam.activityId), 0)
  if level == 0 then
    local bossIds = GuildManager:GetGuildBossIds() or {}
    if 0 < table.getn(bossIds) then
      local levelCfg = GuildManager:GetGuildBossLevelInfoByBossId(bossIds[1], 1)
      if levelCfg then
        level = levelCfg.m_BossLevel or 0
      end
    end
  end
  if level < tParam.level then
    LocalDataManager:SetIntSimple("Form_GuildRaidBossRoundTips" .. tostring(tParam.activityId), tParam.level)
    animStr = "Guild_bossroundtip_in"
  end
  self.m_txt_title_upgradenum_Text.text = tostring(tParam.level)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, animStr)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(1)
  sequence:OnComplete(function()
    if self and not utils.isNull(self.m_Btn_Close) then
      self.m_Btn_Close:SetActive(true)
    end
  end)
  sequence:SetAutoKill(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(28)
end

function Form_GuildRaidBossRoundTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_GuildRaidBossRoundTips:IsOpenGuassianBlur()
  return true
end

function Form_GuildRaidBossRoundTips:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidBossRoundTips", Form_GuildRaidBossRoundTips)
return Form_GuildRaidBossRoundTips
