local UIItemBase = require("UI/Common/UIItemBase")
local Minigame108EventItem = class("Minigame108EventItem", UIItemBase)
local EventType = {
  Normal = 1,
  Judgement = 2,
  Select = 3,
  Result = 4,
  JudgementSc = 5,
  JudgementFail = 6
}

function Minigame108EventItem:OnInit()
  self.m_panelData = {
    [EventType.Normal] = {
      panel = self.m_pnl_normal
    },
    [EventType.JudgementSc] = {
      panel = self.m_pnl_success
    },
    [EventType.JudgementFail] = {
      panel = self.m_pnl_fail
    },
    [EventType.Judgement] = {
      panel = self.m_pnl_judgement
    },
    [EventType.Select] = {
      panel = self.m_pnl_choose
    }
  }
  self.m_normalTxtMultColor = self.m_txt_normalnum:GetComponent("MultiColorChange")
  self.m_successTxtMultColor = self.m_txt_successnum:GetComponent("MultiColorChange")
  self.m_failTxtMultColor = self.m_txt_failnum:GetComponent("MultiColorChange")
end

function Minigame108EventItem:OnFreshData()
  self.m_pnl_normal:SetActive(false)
  self.m_pnl_success:SetActive(false)
  self.m_pnl_fail:SetActive(false)
  self.m_pnl_choose:SetActive(false)
  self.m_pnl_victory:SetActive(false)
  self.m_pnl_failed:SetActive(false)
  if self.m_itemData.ResultEvent then
    local isSc = self.m_itemData.Result == 1
    if isSc then
      GlobalManagerIns:TriggerWwiseBGMState(372)
    else
      GlobalManagerIns:TriggerWwiseBGMState(370)
    end
    self.m_pnl_victory:SetActive(isSc)
    self.m_pnl_failed:SetActive(not isSc)
    if isSc then
      self.m_txt_victorytime_Text.text = self.m_itemData.Cost
    end
    return
  end
  self.m_eventCfg = self.m_itemData.cfg
  self.m_JudgementResult = self.m_itemData.JudgementResult
  self:FreshUI()
end

function Minigame108EventItem:FreshUI()
  local type = self.m_eventCfg.m_EventType
  if type == EventType.Judgement then
    type = self.m_JudgementResult == 1 and EventType.JudgementSc or EventType.JudgementFail
  end
  self.m_panelData[type].panel:SetActive(true)
  if type == EventType.Select then
    self.m_txt_choose_Text.text = self.m_eventCfg.m_mResult1Desc
  end
  if type == EventType.Normal then
    self.m_txt_normal_Text.text = self.m_eventCfg.m_mResult1Desc
    self.m_txt_normaltime_Text.text = self.m_eventCfg.m_Result1Cost
    self.m_txt_normalnum_Text.text = self.m_eventCfg.m_Result1HP
    if self.m_normalTxtMultColor and isnumber(self.m_eventCfg.m_Result1HP) then
      local idx = self.m_eventCfg.m_Result1HP >= 0 and 0 or 1
      self.m_normalTxtMultColor:SetColorByIndex(idx)
    end
  end
  if type == EventType.JudgementSc then
    self.m_txt_success_Text.text = self.m_eventCfg.m_mResult1Desc
    self.m_txt_successtime_Text.text = self.m_eventCfg.m_Result1Cost
    self.m_txt_successnum_Text.text = self.m_eventCfg.m_Result1HP
    if self.m_successTxtMultColor and isnumber(self.m_eventCfg.m_Result1HP) then
      local idx = self.m_eventCfg.m_Result1HP >= 0 and 0 or 1
      self.m_successTxtMultColor:SetColorByIndex(idx)
    end
  end
  if type == EventType.JudgementFail then
    self.m_txt_fail_Text.text = self.m_eventCfg.m_mResult2Desc
    self.m_txt_failtime_Text.text = self.m_eventCfg.m_Result2Cost
    self.m_txt_failnum_Text.text = self.m_eventCfg.m_Result2HP
  end
  if self.m_failTxtMultColor and isnumber(self.m_eventCfg.m_Result2HP) then
    local idx = 0 <= self.m_eventCfg.m_Result2HP and 0 or 1
    self.m_failTxtMultColor:SetColorByIndex(idx)
  end
end

return Minigame108EventItem
