local UIItemBase = require("UI/Common/UIItemBase")
local UIGuildInvitedItem = class("UIGuildInvitedItem", UIItemBase)

function UIGuildInvitedItem:OnInit()
  self.m_formatMember = ConfigManager:GetCommonTextById(20048)
  self.m_formatLv = ConfigManager:GetCommonTextById(20033)
  self.GuildInvitationExpired = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildInvitationExpired"))
  self.GuildJoinCD = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildJoinCD"))
  self.m_formatCD = ConfigManager:GetCommonTextById(100151)
  self.iInviteTime = 0
  self.m_iTimeDurationOneSecond = 1
  self.canAccept = false
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
    UILuaHelper.BindButtonClickManual(self, self.m_btn_true_Button, function()
      self.m_itemClkBackFun(self.m_itemIndex, true)
    end)
    UILuaHelper.BindButtonClickManual(self, self.m_btn_false_Button, function()
      self.m_itemClkBackFun(self.m_itemIndex, false)
    end)
    UILuaHelper.BindButtonClickManual(self, self.m_btn_truelock_Button, function()
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10272)
    end)
    UILuaHelper.BindButtonClickManual(self, self.m_btn_check_Button, function()
      GuildManager:ReqDetailAlliance(self.m_itemData.stBriefInfo.iAllianceId)
    end)
  end
end

function UIGuildInvitedItem:OnFreshData()
  local itemData = self.m_itemData
  self.canAccept = true
  self.iInviteTime = itemData.stInviteUser.iInviteTime
  local guildLvCfg = GuildManager:GetGuildLevelConfigByLv(itemData.stBriefInfo.iLevel) or {}
  self.m_txt_hc_Text.text = string.format(self.m_formatMember, itemData.stBriefInfo.iCurrMemberCount, guildLvCfg.m_Member)
  self.m_txt_leve_Text.text = string.format(self.m_formatLv, tostring(itemData.stBriefInfo.iLevel))
  self.m_txt_gn_Text.text = itemData.stBriefInfo.sName
  self.m_txt_acc_Text.text = itemData.stBriefInfo.iAllianceId
  self.m_txt_leve2_Text.text = string.format(self.m_formatLv, tostring(itemData.stBriefInfo.iJoinLevel))
end

function UIGuildInvitedItem:OnUpdate(dt)
  if not self.m_itemData then
    return
  end
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    local expiredTime = self.iInviteTime + self.GuildInvitationExpired - TimeUtil:GetServerTimeS()
    if 0 < expiredTime then
      self.m_pnl_time:SetActive(true)
      self.m_txt_cd_Text.text = string.CS_Format(self.m_formatCD, TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(expiredTime)))
    else
      self.m_pnl_time:SetActive(false)
      self.canAccept = false
    end
    local disTime = GuildManager.iLastLeaveAllianceTime + self.GuildJoinCD - TimeUtil:GetServerTimeS()
    if 0 < disTime then
      self.m_btn_truelock:SetActive(true)
    else
      self.m_btn_truelock:SetActive(false)
    end
  end
end

return UIGuildInvitedItem
