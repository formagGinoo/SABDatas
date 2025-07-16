local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HallBattlePassSubPanel = class("HallBattlePassSubPanel", UISubPanelBase)

function HallBattlePassSubPanel:OnInit()
  self.configBpBtn = {
    [ActivityManager.BattlePassType.StartBp] = {
      btnObj = self.m_btn_store_bp,
      txtTitle = self.m_txt_shop_bp_Text,
      txtDefault = self.m_btn_store_bp.transform:Find("txt_shop_bp"),
      redDot = self.m_bp_red_dot
    },
    [ActivityManager.BattlePassType.MonthBp] = {
      btnObj = self.m_btn_store_month,
      txtTitle = self.m_txt_shop_month_Text,
      txtDefault = self.m_btn_store_month.transform:Find("txt_shop_month"),
      redDot = self.m_month_red_dot
    },
    [ActivityManager.BattlePassType.ActivityUpBp] = {
      btnObj = self.m_btn_store_bp_up,
      txtTitle = self.m_txt_bp_up_Text,
      txtDefault = self.m_btn_store_bp_up.transform:Find("txt_bp_up"),
      redDot = self.m_bp_up_red_dot
    }
  }
end

function HallBattlePassSubPanel:OnActive()
  self:OnRefreshUI()
end

function HallBattlePassSubPanel:OnInActive()
end

function HallBattlePassSubPanel:OnRefreshUI()
  self:OnRefreshStoreBpEnterState()
end

function HallBattlePassSubPanel:OnRefreshStoreBpEnterState()
  for _, config in pairs(self.configBpBtn) do
    config.btnObj:SetActive(false)
  end
  local openBPList = ActivityManager:GetActivityListByType(MTTD.ActivityType_BattlePass)
  for i, stActivity in pairs(openBPList) do
    if stActivity and stActivity:checkCondition() then
      self:ProcessBattlePassActivity(stActivity)
    end
  end
end

function HallBattlePassSubPanel:ProcessBattlePassActivity(activity)
  local uiType = activity:GetUiType()
  if not uiType then
    return
  end
  local btnConfig = self.configBpBtn[uiType]
  if not btnConfig then
    return
  end
  self:UpdateButtonDisplay(btnConfig, activity)
  self:RegisterRedDot(btnConfig, activity)
  self:BindButtonAction(btnConfig, activity)
end

function HallBattlePassSubPanel:UpdateButtonDisplay(config, activity)
  if not config.btnObj or utils.isNull(config.btnObj) then
    return
  end
  config.btnObj:SetActive(true)
  local title = activity:GetTitleAndEnterName() or ""
  local showCustomTitle = title ~= ""
  if not utils.isNull(config.txtTitle) then
    config.txtTitle.gameObject:SetActive(showCustomTitle)
    if showCustomTitle then
      config.txtTitle.text = title
    end
  end
  if not utils.isNull(config.txtDefault) then
    config.txtDefault.gameObject:SetActive(not showCustomTitle)
  end
end

function HallBattlePassSubPanel:RegisterRedDot(config, activity)
  if config.redDot then
    self:RegisterOrUpdateRedDotItem(config.redDot, RedDotDefine.ModuleType.BattlePass, activity:getID())
  end
end

function HallBattlePassSubPanel:BindButtonAction(config, activity)
  local button = config.btnObj:GetComponent(T_Button)
  local formUid = activity:GetBattlePassMainPrefab()
  UILuaHelper.BindButtonClickManual(self, button, function()
    local function requestHandler()
      StackFlow:Push(formUid, {stActivity = activity})
    end
    
    if activity:GetCurLevel() > 0 then
      activity:RequestQuests(false, requestHandler)
    else
      activity:RequestActData(requestHandler)
    end
  end)
end

function HallBattlePassSubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return HallBattlePassSubPanel
