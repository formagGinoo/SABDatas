local Form_GuildinvitationPop = class("Form_GuildinvitationPop", require("UI/UIFrames/Form_GuildinvitationPopUI"))

function Form_GuildinvitationPop:SetInitParam(param)
end

function Form_GuildinvitationPop:AfterInit()
  self.super.AfterInit(self)
  self.GuildJoinCD = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildJoinCD"))
  self.m_formatCD = ConfigManager:GetCommonTextById(100153)
  self.m_iTimeDurationOneSecond = 1
end

function Form_GuildinvitationPop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_GuildinvitationPop:RefreshUI()
  local initItemData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_invitedLoopScrollView = self:CreateLoopScrollView(self.m_scrollView:GetComponent(T_LoopScrollView), "Guild/UIGuildInvitedItem", initItemData)
  self.inviteList = GuildManager:GetSortAllianceInvite()
  if self.inviteList and #self.inviteList > 0 then
    self.m_invitedLoopScrollView:ShowItemList(self.inviteList, true)
    self.m_scrollView:SetActive(true)
    self.m_img_bg1:SetActive(false)
  else
    self.m_scrollView:SetActive(false)
    self.m_img_bg1:SetActive(true)
  end
end

function Form_GuildinvitationPop:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_Detail", handler(self, self.OnEventAllianceDetail))
  self:addEventListener("eGameEvent_Alliance_ReplyInvite", handler(self, self.OnGuildReplyInvite))
  self:addEventListener("eGameEvent_Alliance_Refresh_Invitations", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Alliance_Get_Invitations", handler(self, self.RefreshUI))
end

function Form_GuildinvitationPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildinvitationPop:OnGuildRefreshInvitations()
  local num = table.getn(GuildManager:GetAllianceInviteList())
  self.m_txt_num_Text.text = num
  self.m_common_redpoint:SetActive(0 < num)
end

function Form_GuildinvitationPop:OnGuildReplyInvite(data)
  if not data.bAccept then
    GuildManager:ReqAllianceGetInviteListCS()
  end
end

function Form_GuildinvitationPop:OnEventAllianceDetail(stData)
  self.m_selGuildId = stData.stBriefData.iAllianceId
  StackPopup:Push(UIDefines.ID_FORM_GUILDDETAILPOP, {
    guildData = stData,
    hideJoinBtn = false,
    isInvited = true
  })
end

function Form_GuildinvitationPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildinvitationPop:OnItemClk(index, isAccept)
  local inviteData = self.inviteList[index]
  if inviteData then
    if isAccept then
      utils.CheckAndPushCommonTips({
        tipsID = 1504,
        bUseSystemWord = true,
        fContentCB = function(content)
          return string.gsubnumberreplace(content, inviteData.stInviteUser.sRoleName, inviteData.stBriefInfo.sName, inviteData.stBriefInfo.iAllianceId)
        end,
        func1 = function()
          if inviteData.stBriefInfo.iJoinLevel > RoleManager:GetLevel() then
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10273)
          else
            local guildLvCfg = GuildManager:GetGuildLevelConfigByLv(inviteData.stBriefInfo.iLevel) or {}
            if inviteData.stBriefInfo.iCurrMemberCount < guildLvCfg.m_Member then
              GuildManager:ReqAllianceReplyInviteCS(inviteData.stBriefInfo.iAllianceId, true)
              self:OnBackClk()
            else
              StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10213)
            end
          end
        end
      })
    else
      GuildManager:ReqAllianceReplyInviteCS(inviteData.stBriefInfo.iAllianceId, false)
    end
  end
end

function Form_GuildinvitationPop:OnUpdate(dt)
  self.m_invitedLoopScrollView:OnUpdate(dt)
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    local disTime = GuildManager.iLastLeaveAllianceTime + self.GuildJoinCD - TimeUtil:GetServerTimeS()
    if 0 < disTime then
      self.m_pnl_cd:SetActive(true)
      self.m_txt_time_Text.text = string.CS_Format(self.m_formatCD, TimeUtil:SecondsToFormatCNStr4(math.floor(disTime)))
    else
      self.m_pnl_cd:SetActive(false)
    end
  end
end

function Form_GuildinvitationPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildinvitationPop:IsOpenGuassianBlur()
  return true
end

function Form_GuildinvitationPop:OnBackClk()
  StackFlow:DestroyUI(UIDefines.ID_FORM_GUILDINVITATIONPOP)
end

function Form_GuildinvitationPop:OnBtnReturnClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GUILDINVITATIONPOP)
end

local fullscreen = true
ActiveLuaUI("Form_GuildinvitationPop", Form_GuildinvitationPop)
return Form_GuildinvitationPop
