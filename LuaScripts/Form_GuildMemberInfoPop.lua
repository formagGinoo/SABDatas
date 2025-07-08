local Form_GuildMemberInfoPop = class("Form_GuildMemberInfoPop", require("UI/UIFrames/Form_GuildMemberInfoPopUI"))

function Form_GuildMemberInfoPop:SetInitParam(param)
end

function Form_GuildMemberInfoPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuildMemberInfoPop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_memberInfo = tParam
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_GuildMemberInfoPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildMemberInfoPop:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_ChangePost", handler(self, self.OnChangePostCB))
  self:addEventListener("eGameEvent_Alliance_Transfer", handler(self, self.OnChangeTransferCB))
  self:addEventListener("eGameEvent_Alliance_Kick", handler(self, self.OnKickCB))
  self:addEventListener("eGameEvent_Alliance_CancelTransformGuild", handler(self, self.OnCancelTransformGuildFresh))
end

function Form_GuildMemberInfoPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildMemberInfoPop:OnChangeTransferCB()
end

function Form_GuildMemberInfoPop:OnChangePostCB()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10235)
  self.m_memberInfo = GuildManager:GetOwnerGuildMemberDataByUID(self.m_memberInfo.stRoleId.iUid)
  self:RefreshUI()
end

function Form_GuildMemberInfoPop:OnKickCB()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10240)
  self:OnBtnCloseClicked()
end

function Form_GuildMemberInfoPop:OnCancelTransformGuildFresh()
  self:RefreshUI()
  if self.m_calmDownTimer then
    TimeService:KillTimer(self.m_calmDownTimer)
    self.m_calmDownTimer = nil
  end
end

function Form_GuildMemberInfoPop:RefreshUI()
  self.m_num_member_activity1_Text.text = self.m_memberInfo.iTodayActive or 0
  self.m_num_member_activity7_Text.text = self.m_memberInfo.iTotalActive
  self.m_txt_player_name_Text.text = self.m_memberInfo.sRoleName
  self.m_txt_power_Text.text = self.m_memberInfo.iPower
  self.m_txt_timedes_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100062), TimeUtil:TimerToString2(self.m_memberInfo.iJoinTime))
  self.m_txt_change_Text.text = self.m_memberInfo.iPost == GuildManager.AlliancePost.Vice and ConfigManager:GetClientMessageTextById(10232) or ConfigManager:GetClientMessageTextById(10231)
  ResourceUtil:CreateGuildPostIconByPost(self.m_img_post_Image, self.m_memberInfo.iPost)
  self.m_txt_guild_uid_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100053), self.m_memberInfo.stRoleId.iUid)
  self:ShowBtn()
  local playerHeadCom = self:createPlayerHead(self.m_circle_head)
  playerHeadCom:SetPlayerHeadInfo(self.m_memberInfo)
end

function Form_GuildMemberInfoPop:ShowBtn()
  local memberData = GuildManager:GetOwnerGuildMemberDataByUID(RoleManager:GetUID())
  if self.m_memberInfo.stRoleId.iUid == RoleManager:GetUID() then
    self.m_btn_transfer:SetActive(false)
    self.m_btn_quilt:SetActive(false)
    self.m_btn_levelup:SetActive(false)
    self.m_btn_stopchange:SetActive(false)
  elseif memberData.iPost == GuildManager.AlliancePost.Master then
    self.m_btn_transfer:SetActive(true)
    self.m_btn_quilt:SetActive(true)
    self.m_btn_levelup:SetActive(true)
    self.m_btn_stopchange:SetActive(false)
    local transferEffectTime, NewTransferMasterUid = GuildManager:GetTransGuildInfo()
    if transferEffectTime and 0 < transferEffectTime and transferEffectTime > TimeUtil:GetServerTimeS() and NewTransferMasterUid then
      if self.m_memberInfo.stRoleId.iUid == tostring(NewTransferMasterUid) then
        self.m_btn_stopchange:SetActive(true)
        self.m_btn_transfer:SetActive(false)
        local endTime = transferEffectTime
        local lastTime = endTime - TimeUtil:GetServerTimeS()
        local timeCfgText = ConfigManager:GetCommonTextById(20212)
        self.m_txt_stopchangetips_Text.text = string.gsubnumberreplace(timeCfgText, TimeUtil:SecondsToFormatStrDHOrHMS(lastTime))
        if not self.m_calmDownTimer then
          self.m_calmDownTimer = TimeService:SetTimer(1, -1, function()
            lastTime = endTime - TimeUtil:GetServerTimeS()
            if lastTime <= 0 and self.m_calmDownTimer then
              TimeService:KillTimer(self.m_calmDownTimer)
              self.m_calmDownTimer = nil
              self:CloseForm()
              return
            end
            self.m_txt_stopchangetips_Text.text = string.gsubnumberreplace(timeCfgText, TimeUtil:SecondsToFormatStrDHOrHMS(lastTime))
          end)
        end
      else
        self.m_btn_stopchange:SetActive(false)
        self.m_btn_transfer:SetActive(false)
      end
    end
  elseif memberData.iPost == GuildManager.AlliancePost.Vice and self.m_memberInfo.iPost == GuildManager.AlliancePost.Member then
    self.m_btn_transfer:SetActive(false)
    self.m_btn_quilt:SetActive(true)
    self.m_btn_levelup:SetActive(false)
    self.m_btn_stopchange:SetActive(false)
  else
    self.m_btn_transfer:SetActive(false)
    self.m_btn_quilt:SetActive(false)
    self.m_btn_levelup:SetActive(false)
    self.m_btn_stopchange:SetActive(false)
  end
end

function Form_GuildMemberInfoPop:OnInactive()
  self.super.OnInactive(self)
  if self.m_calmDownTimer then
    TimeService:KillTimer(self.m_calmDownTimer)
    self.m_calmDownTimer = nil
  end
end

function Form_GuildMemberInfoPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildMemberInfoPop:OnBtntransferClicked()
  self:CloseForm()
  StackPopup:Push(UIDefines.ID_FORM_GUILDCALMDOWN, self.m_memberInfo)
end

function Form_GuildMemberInfoPop:OnBtnquiltClicked()
  local inTime = GuildManager:IsGuildBossTime()
  if inTime then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10209)
    return
  end
  utils.popUpDirectionsUI({
    tipsID = 1508,
    func1 = function()
      GuildManager:ReqAllianceKickCS(self.m_memberInfo.stRoleId.iUid, self.m_memberInfo.stRoleId.iZoneId)
    end
  })
end

function Form_GuildMemberInfoPop:OnBtnlevelupClicked()
  local uid = self.m_memberInfo.stRoleId.iUid
  local iPost = self.m_memberInfo.iPost
  local iZoneId = self.m_memberInfo.stRoleId.iZoneId
  if iPost == GuildManager.AlliancePost.Vice then
    iPost = GuildManager.AlliancePost.Member
  elseif iPost == GuildManager.AlliancePost.Member then
    iPost = GuildManager.AlliancePost.Vice
  end
  GuildManager:ReqAllianceChangePostCS(uid, iPost, iZoneId)
end

function Form_GuildMemberInfoPop:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_GuildMemberInfoPop:OnBtnCloseClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDMEMBERINFOPOP)
end

function Form_GuildMemberInfoPop:OnBtnstopchangeClicked()
  GuildManager:ReqCancelTranGuild()
end

function Form_GuildMemberInfoPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuildMemberInfoPop", Form_GuildMemberInfoPop)
return Form_GuildMemberInfoPop
