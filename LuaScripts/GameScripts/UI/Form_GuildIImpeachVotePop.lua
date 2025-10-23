local Form_GuildIImpeachVotePop = class("Form_GuildIImpeachVotePop", require("UI/UIFrames/Form_GuildIImpeachVotePopUI"))

function Form_GuildIImpeachVotePop:SetInitParam(param)
end

function Form_GuildIImpeachVotePop:AfterInit()
  self.super.AfterInit(self)
  self.m_iTimeDurationOneSecond = 1
  self.iImpeachStartTime = 0
  self.ImpeachmentCD = tonumber(ConfigManager:GetGlobalSettingsByKey("ImpeachmentDuration"))
  self.m_formatCD = ConfigManager:GetCommonTextById(100153)
  self.m_formatName = ConfigManager:GetCommonTextById(100162)
  self.playerHeadComL = self:createPlayerHead(self.m_circle_headL)
  self.playerHeadComR = self:createPlayerHead(self.m_circle_headR)
end

function Form_GuildIImpeachVotePop:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:RefreshUI()
end

function Form_GuildIImpeachVotePop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildIImpeachVotePop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildIImpeachVotePop:AddEventListeners()
  self:addEventListener("eGameEvent_Guild_Impeach", handler(self, self.RefreshImpeach))
end

function Form_GuildIImpeachVotePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildIImpeachVotePop:RefreshImpeach()
  local impeachData = GuildManager:GetAllianceImpeachInfo()
  self.iImpeachStartTime = impeachData.iStartTime or 0
  if self.iImpeachStartTime > 0 then
    self:RefreshUI()
    local ret, hasVoted = GuildManager:HasVoted()
    if ret then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10282)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10283)
    end
  end
end

function Form_GuildIImpeachVotePop:RefreshUI()
  local impeachData = GuildManager:GetAllianceImpeachInfo()
  self.iImpeachStartTime = impeachData.iStartTime or 0
  local numberLeft = impeachData.vAgree and table.getn(impeachData.vAgree) or 0
  local numberRight = impeachData.vDisagree and table.getn(impeachData.vDisagree) or 0
  local ratioL = numberLeft / (numberLeft + numberRight)
  local stImpeacher = GuildManager:GetOwnerGuildMemberDataByUID(impeachData.stImpeacher.iUid)
  local oldMaster = GuildManager:GetGuildLeader()
  local newMaster = GuildManager:GetOwnerGuildMemberDataByUID(impeachData.stNewMaster.iUid)
  self.m_txt_rolename_Text.text = stImpeacher and stImpeacher.sRoleName or ""
  self.m_txt_rolenameL_Text.text = oldMaster and oldMaster.sRoleName or ""
  self.m_txt_rolenameR_Text.text = newMaster and newMaster.sRoleName or ""
  self.m_progress_support_Image.fillAmount = ratioL
  self.m_progress_opposition_Image.fillAmount = 1 - ratioL
  self.m_guildData = GuildManager:GetOwnerGuildDetail()
  self.m_memberList = self.m_guildData.vMember or {}
  self.playerHeadComL:SetPlayerHeadInfo(oldMaster)
  self.playerHeadComR:SetPlayerHeadInfo(newMaster)
  self.m_formatLv = ConfigManager:GetCommonTextById(20033)
  self.m_txt_supportnum_Text.text = string.CS_Format(self.m_formatName, tostring(numberLeft))
  self.m_txt_oppositionnum_Text.text = string.CS_Format(self.m_formatName, tostring(numberRight))
  local ret, hasVoted = GuildManager:HasVoted()
  self.m_pnl_confirm:SetActive(hasVoted)
  self.m_pnl_btn:SetActive(not hasVoted)
  self.m_txt_result_Text.text = ret and ConfigManager:GetCommonTextById(100167) or ConfigManager:GetCommonTextById(100168)
end

function Form_GuildIImpeachVotePop:OnUpdate(dt)
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    local disOutTime = self.iImpeachStartTime + self.ImpeachmentCD - TimeUtil:GetServerTimeS()
    if 0 < disOutTime then
      self.m_txt_endtime_Text.text = TimeUtil:SecondsToFormatCNStr4(math.floor(disOutTime))
    else
      self:CloseForm()
    end
  end
end

function Form_GuildIImpeachVotePop:OnBtnsymbolClicked()
  utils.popUpDirectionsUI({
    tipsID = 1268,
    func1 = function()
    end
  })
end

function Form_GuildIImpeachVotePop:OnBtnsupportClicked()
  utils.CheckAndPushCommonTips({
    tipsID = 1257,
    bUseSystemWord = false,
    func1 = function()
      GuildManager:ReqAllianceImpeachVoteCS(true)
    end
  })
end

function Form_GuildIImpeachVotePop:OnBtnoppositionClicked()
  utils.CheckAndPushCommonTips({
    tipsID = 1258,
    bUseSystemWord = false,
    func1 = function()
      GuildManager:ReqAllianceImpeachVoteCS(false)
    end
  })
end

local fullscreen = true
ActiveLuaUI("Form_GuildIImpeachVotePop", Form_GuildIImpeachVotePop)
return Form_GuildIImpeachVotePop
