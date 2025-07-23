local Form_GuildList = class("Form_GuildList", require("UI/UIFrames/Form_GuildListUI"))
local GUILD_REFRESH_CD = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildRefreshCD"))

function Form_GuildList:SetInitParam(param)
end

function Form_GuildList:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_TMP_InputField.onEndEdit:AddListener(function()
    self:CheckStrIsCorrect()
  end)
  self.m_inputfield_TMP_InputField.onValueChanged:AddListener(function()
    self:CheckStrIsCorrect()
  end)
  self.m_widgetResourceBar = self:createResourceBar(self.m_common_top_resource)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1113)
  local guildGridData = {
    itemClkBackFun = handler(self, self.OnGuildItemClk)
  }
  self.m_guildListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_guild_list_InfinityGrid, "Guild/UIGuildListItem", guildGridData)
  self.m_guildListInfinityGrid:RegisterButtonCallback("c_btn_item", handler(self, self.OnGuildItemClk))
end

function Form_GuildList:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self:AddEventListeners()
  self.m_inputfield_TMP_InputField.text = ""
  self.m_guildList = tParam
  self.m_selGuildId = 0
  self:RefreshUI()
end

function Form_GuildList:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildList:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_Detail", handler(self, self.OnEventAllianceDetail))
  self:addEventListener("eGameEvent_Alliance_RefreshRecommendList", handler(self, self.OnEventRefreshAllianceList))
  self:addEventListener("eGameEvent_Alliance_Create_Detail", handler(self, self.OnEventOpenAlliance))
  self:addEventListener("eGameEvent_Alliance_Apply", handler(self, self.OnGuildApply))
  self:addEventListener("eGameEvent_Alliance_Join", handler(self, self.OnGuildJoin))
  self:addEventListener("eGameEvent_Alliance_ReplyInvite", handler(self, self.OnGuildReplyInvite))
  self:addEventListener("eGameEvent_Alliance_RemoveGuildData", handler(self, self.OnGuildRemoveGuildData))
  self:addEventListener("eGameEvent_Alliance_Refresh_Invitations", handler(self, self.OnGuildRefreshInvitations))
end

function Form_GuildList:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildList:OnGuildRemoveGuildData()
  if self.m_selGuildId and self.m_selGuildId ~= 0 then
    local index = 0
    for i, v in pairs(self.m_guildList) do
      if v.iAllianceId == self.m_selGuildId then
        index = i
        break
      end
    end
    if index ~= 0 then
      table.remove(self.m_guildList, index)
    end
    self.m_selGuildId = 0
  end
  self:RefreshUI()
end

function Form_GuildList:OnGuildApply(data)
  if data.iJoinType == GuildManager.AllianceJoinType.AllianceJoinType_Review then
    self:RefreshUI()
  end
end

function Form_GuildList:OnGuildJoin()
  local m_iAllianceId = RoleManager:GetRoleAllianceInfo()
  GuildManager:ReqGetOwnerAllianceDetail(m_iAllianceId)
  self:OnBackClk()
end

function Form_GuildList:OnGuildReplyInvite(data)
  if data.bAccept then
    local m_iAllianceId = RoleManager:GetRoleAllianceInfo()
    GuildManager:ReqGetOwnerAllianceDetail(m_iAllianceId)
    self:OnBackClk()
  else
    self:RefreshUI()
  end
end

function Form_GuildList:OnGuildRefreshInvitations()
  local num = table.getn(GuildManager:GetAllianceInviteList())
  self.m_txt_num_Text.text = num
  self.m_common_redpoint:SetActive(0 < num)
end

function Form_GuildList:RefreshUI()
  self.m_guild_list:SetActive(#self.m_guildList > 0)
  self.m_guildListInfinityGrid:ShowItemList(self.m_guildList, true)
  self.m_pnl_empty:SetActive(#self.m_guildList == 0)
  local num = table.getn(GuildManager:GetAllianceInviteList())
  self.m_txt_num_Text.text = num
  self.m_common_redpoint:SetActive(0 < num)
end

function Form_GuildList:CheckStrIsCorrect()
  local text = self.m_inputfield_TMP_InputField.text
  if text ~= "" then
    local str = string.GetTextualNorms(text)
    self.m_inputfield_TMP_InputField.text = str
  end
end

function Form_GuildList:OnGuildItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_guildList[fjItemIndex]
  if chooseFJItemData then
    GuildManager:ReqDetailAlliance(chooseFJItemData.iAllianceId)
  end
end

function Form_GuildList:OnEventRefreshAllianceList(data)
  self.m_guildList = data
  self:RefreshUI()
end

function Form_GuildList:OnEventOpenAlliance(stData)
  self:OnBackClk()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10233)
  StackFlow:Push(UIDefines.ID_FORM_GUILD, stData)
end

function Form_GuildList:OnEventAllianceDetail(stData)
  self.m_selGuildId = stData.stBriefData.iAllianceId
  StackPopup:Push(UIDefines.ID_FORM_GUILDDETAILPOP, {guildData = stData})
end

function Form_GuildList:OnBtnfindClicked()
  local guildId = self.m_inputfield_TMP_InputField.text
  if guildId ~= "" then
    local spacing = string.checkFirstCharIsSpacing(guildId)
    if spacing then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30020)
      return
    end
    GuildManager:ReqAllianceSearchCS(guildId)
  end
end

function Form_GuildList:OnBtnrefreshClicked()
  local time = GuildManager:GetRecommendGuildTimer()
  if GUILD_REFRESH_CD and TimeUtil:GetServerTimeS() - time > GUILD_REFRESH_CD then
    GuildManager:ReqRefreshRecommendList()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10207)
  end
end

function Form_GuildList:OnBtncreateClicked()
  StackPopup:Push(UIDefines.ID_FORM_GUILDCREATE)
end

function Form_GuildList:OnBtninvitationsClicked()
  local inviteData = GuildManager:GetLastAllianceInvite()
  if inviteData then
    utils.CheckAndPushCommonTips({
      tipsID = 1504,
      fContentCB = function(content)
        return string.gsubnumberreplace(content, inviteData.stInviteUser.sRoleName, inviteData.stBriefInfo.sName, inviteData.stBriefInfo.iAllianceId)
      end,
      func1 = function()
        GuildManager:ReqAllianceReplyInviteCS(inviteData.stBriefInfo.iAllianceId, true)
      end,
      func2 = function()
        GuildManager:ReqAllianceReplyInviteCS(inviteData.stBriefInfo.iAllianceId, false)
      end
    })
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10242)
  end
end

function Form_GuildList:OnBackClk()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GUILDLIST)
end

function Form_GuildList:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_GuildList:IsFullScreen()
  return true
end

function Form_GuildList:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildList", Form_GuildList)
return Form_GuildList
