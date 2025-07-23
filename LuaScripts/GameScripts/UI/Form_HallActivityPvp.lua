local Form_HallActivityPvp = class("Form_HallActivityPvp", require("UI/UIFrames/Form_HallActivityPvpUI"))
local CliveActivityTipsItem = require("UI/Item/HeroActivity/CliveActivityTipsItem")

function Form_HallActivityPvp:SetInitParam(param)
end

function Form_HallActivityPvp:AfterInit()
  self.super.AfterInit(self)
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome))
  self.m_PvPEnterSubPanelCom = nil
  self.m_PvpReplaceSubPanelCom = nil
  self.cliveActivityTip = CliveActivityTipsItem:CreateCliveActivityTipsItem(self.m_panel_tips, {tipType = 3, cliveType = 2})
end

function Form_HallActivityPvp:OnActive()
  self.super.OnActive(self)
  local param = self.m_csui.m_param or {}
  local isNeedReqArena = param.isNeedReqArena
  self.m_csui.m_param = nil
  if isNeedReqArena then
    self:ClearArenaReqStatus()
  end
  self:AddEventListeners()
  self:RefreshUI()
  if self.cliveActivityTip and self.cliveActivityTip.OnFreshData then
    self.cliveActivityTip:OnFreshData()
  end
end

function Form_HallActivityPvp:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_HallActivityPvp:OnUpdate(dt)
  if self.m_PvPEnterSubPanelCom then
    self.m_PvPEnterSubPanelCom:Update()
  end
  if self.m_PvpReplaceSubPanelCom then
    self.m_PvpReplaceSubPanelCom:Update()
  end
end

function Form_HallActivityPvp:AddEventListeners()
end

function Form_HallActivityPvp:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HallActivityPvp:RefreshUI()
  if self.m_PvPEnterSubPanelCom == nil then
    self.m_PvPEnterSubPanelCom = self:CreateSubPanel("PvPEnterSubPanel", self.m_Btn_Card_PvP, self, nil, nil, nil)
  end
  if self.m_PvpReplaceSubPanelCom == nil then
    self.m_PvpReplaceSubPanelCom = self:CreateSubPanel("PvPReplaceSubPanel", self.m_PvP_Replace_Node, self, nil, nil, nil)
  end
  self:CheckReqArenaSeason()
end

function Form_HallActivityPvp:ClearArenaReqStatus()
  if self.m_PvPEnterSubPanelCom then
    self.m_PvPEnterSubPanelCom:ClearArenaReqStatus()
  end
  if self.m_PvpReplaceSubPanelCom then
    self.m_PvpReplaceSubPanelCom:ClearFreshStatus()
  end
end

function Form_HallActivityPvp:CheckReqArenaSeason()
  if self.m_PvPEnterSubPanelCom then
    self.m_PvPEnterSubPanelCom:CheckReqArenaSeason()
  end
  if self.m_PvpReplaceSubPanelCom then
    self.m_PvpReplaceSubPanelCom:CheckFreshArena()
  end
end

function Form_HallActivityPvp:OnBackHome()
  ArenaManager:ClearCacheMineSeasonInfo()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
end

function Form_HallActivityPvp:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  ArenaManager:ClearCacheMineSeasonInfo()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HALLACTIVITYPVP)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
end

function Form_HallActivityPvp:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HallActivityPvp:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HallActivityPvp", Form_HallActivityPvp)
return Form_HallActivityPvp
