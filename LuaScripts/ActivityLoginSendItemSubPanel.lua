local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivityLoginSendItemSubPanel = class("ActivityLoginSendItemSubPanel", UISubPanelBase)
local SignMaxNum = 14

function ActivityLoginSendItemSubPanel:OnInit()
  self:AddEventListeners()
end

function ActivityLoginSendItemSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_LoginSendItem", handler(self, self.OnEventUpdateSign))
end

function ActivityLoginSendItemSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function ActivityLoginSendItemSubPanel:OnFreshData()
  self.m_stActivity = self.m_panelData.activity
  self:RefreshUI()
end

function ActivityLoginSendItemSubPanel:RefreshUI()
  if not self.m_stActivity then
    return
  end
  self.sdpConfig = self.m_stActivity.m_stSdpConfig
  self.isCanReward = self.m_stActivity:checkShowRed()
  if self.isCanReward then
    UILuaHelper.SetActive(self.m_btn_reward, true)
    UILuaHelper.SetActive(self.m_pnl_received, false)
    if self.sdpConfig and self.sdpConfig.stCommonCfg then
      UILuaHelper.SetActive(self.m_num_txtLayout, true)
      self.m_itemNum_Text.text = self.sdpConfig.stCommonCfg.iItemNum
    else
      UILuaHelper.SetActive(self.m_num_txtLayout, false)
    end
  else
    UILuaHelper.SetActive(self.m_btn_reward, false)
    UILuaHelper.SetActive(self.m_pnl_received, true)
  end
  if self.sdpConfig and self.sdpConfig.stClientCfg then
    UILuaHelper.SetActive(self.m_btn_jump, true)
    self.m_jump_txt_Text.text = self.m_stActivity:getLangText(self.sdpConfig.stClientCfg.sJumpContent)
  else
    UILuaHelper.SetActive(self.m_btn_jump, false)
  end
end

function ActivityLoginSendItemSubPanel:OnEventUpdateSign(stParam)
  if self.m_parentLua then
    self.m_parentLua:RefreshTableButtonList()
  end
  if stParam == nil then
    return
  end
  if stParam.iActivityID ~= self.m_stActivity:getID() then
    return
  end
  utils.popUpRewardUI(stParam.vReward)
  self.m_stActivity = ActivityManager:GetActivityByID(stParam.iActivityID)
  self:RefreshUI()
end

function ActivityLoginSendItemSubPanel:OnBtnrewardClicked()
  if self.m_stActivity:checkShowRed() then
    self.m_stActivity:RequestLoginReward()
  end
end

function ActivityLoginSendItemSubPanel:OnBtnjumpClicked()
  if self.sdpConfig and self.sdpConfig.stClientCfg and self.sdpConfig.stClientCfg.iJumpType and self.sdpConfig.stClientCfg.sJumpParam then
    ActivityManager:DealJump(self.sdpConfig.stClientCfg.iJumpType, self.sdpConfig.stClientCfg.sJumpParam)
  end
end

return ActivityLoginSendItemSubPanel
