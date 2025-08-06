local GachaSubPanel = require("UI/SubPanel/GachaSubPanel")
local GachaSubPanelAct101 = class("GachaSubPanelAct101", GachaSubPanel)

function GachaSubPanelAct101:OnUpdate(dt)
  GachaSubPanelAct101.super.OnUpdate(self)
  if utils.isNull(self.m_txt_time_Text) then
    return
  end
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick - dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond - dt
  if self.m_iTimeDurationOneSecond <= 0 then
    self.m_iTimeDurationOneSecond = 1
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(math.floor(self.m_iTimeTick))
  end
  if self.m_iTimeTick <= 0 then
    self.m_iTimeTick = nil
    self.m_txt_time_Text.text = ""
  end
end

function GachaSubPanelAct101:RefreshTime()
  GachaSubPanelAct101.super.RefreshTime(self)
  self.m_iTimeDurationOneSecond = 1
  if not utils.isNull(self.m_txt_time) and self.m_gachaConfig.m_EndTime ~= "" then
    local endTime = TimeUtil:TimeStringToTimeSec2(self.m_gachaConfig.m_EndTime)
    local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.gacha, {
      id = self.m_gachaConfig.m_ActId,
      gacha_id = self.m_gachaConfig.m_GachaID
    })
    if is_corved then
      endTime = t2
    end
    self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatCNStr(math.floor(self.m_iTimeTick))
  end
end

function GachaSubPanelAct101:RefreshUI()
  GachaSubPanelAct101.super.RefreshUI(self)
  if not utils.isNull(self.m_txt_time) then
    self.m_txt_time_Text.text = ""
  end
end

return GachaSubPanelAct101
