local Form_GuildRaidRanKChangeTips = class("Form_GuildRaidRanKChangeTips", require("UI/UIFrames/Form_GuildRaidRanKChangeTipsUI"))

function Form_GuildRaidRanKChangeTips:SetInitParam(param)
end

function Form_GuildRaidRanKChangeTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuildRaidRanKChangeTips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_Btn_Close:SetActive(false)
  self.m_txt_rank_changenum_Text.text = tostring(tParam.oldLevel)
  self.m_txt_upgrade_nun_Text.text = tostring(tParam.newLevel)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(1)
  sequence:OnComplete(function()
    if self and not utils.isNull(self.m_Btn_Close) then
      self.m_Btn_Close:SetActive(true)
    end
  end)
  sequence:SetAutoKill(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(25)
end

function Form_GuildRaidRanKChangeTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_GuildRaidRanKChangeTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildRaidRanKChangeTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidRanKChangeTips", Form_GuildRaidRanKChangeTips)
return Form_GuildRaidRanKChangeTips
