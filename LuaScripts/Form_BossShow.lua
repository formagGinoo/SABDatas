local Form_BossShow = class("Form_BossShow", require("UI/UIFrames/Form_BossShowUI"))

function Form_BossShow:SetInitParam(param)
end

function Form_BossShow:AfterInit()
  self.super.AfterInit(self)
  self.m_dungeonChapterCfg = nil
end

function Form_BossShow:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_BossShow:OnInactive()
  self.super.OnInactive(self)
  if self.m_enterTimer then
    TimeService:KillTimer(self.m_enterTimer)
    self.m_enterTimer = nil
  end
end

function Form_BossShow:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BossShow:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_dungeonChapterCfg = tParam.dungeonChapterCfg
  self.m_backFun = tParam.backFun
end

function Form_BossShow:FreshUI()
  if self.m_dungeonChapterCfg then
    self.m_txt_boss_name_Text.text = self.m_dungeonChapterCfg.m_mName
    self.m_txt_boss_infor_Text.text = self.m_dungeonChapterCfg.m_mBossName
  end
  if self.m_waitShowBossTimer then
    TimeService:KillTimer(self.m_waitShowBossTimer)
    self.m_waitShowBossTimer = nil
  end
  self.m_waitShowBossTimer = TimeService:SetTimer(self.m_uiVariables.DelayHideTime, 1, function()
    self.m_waitShowBossTimer = nil
    self:CloseForm()
    if self.m_backFun then
      self.m_backFun()
    end
  end)
end

local fullscreen = true
ActiveLuaUI("Form_BossShow", Form_BossShow)
return Form_BossShow
