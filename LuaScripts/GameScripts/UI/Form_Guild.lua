local Form_Guild = class("Form_Guild", require("UI/UIFrames/Form_GuildUI"))
local GuildPanelTab = {
  Active = 1,
  Member = 2,
  News = 3
}

function Form_Guild:SetInitParam(param)
end

function Form_Guild:AfterInit()
  self.super.AfterInit(self)
  self.m_subPanelData = {
    [GuildPanelTab.Active] = {
      panelRoot = self.m_pnl_active,
      imgTab = self.m_btn_event_Image,
      txtTab = self.m_z_txt_event_Text,
      subPanelName = "GuildActiveSubPanel",
      selImg = self.m_btn_bg01,
      redDot = self.m_icon_redpoint01,
      backFun = function()
      end
    },
    [GuildPanelTab.Member] = {
      panelRoot = self.m_pnl_member,
      imgTab = self.m_btn_member_Image,
      txtTab = self.m_z_txt_member_Text,
      subPanelName = "GuildMemberSubPanel",
      selImg = self.m_btn_bg02,
      redDot = self.m_icon_redpoint02,
      backFun = nil
    },
    [GuildPanelTab.News] = {
      panelRoot = self.m_pnl_news,
      imgTab = self.m_btn_news_Image,
      txtTab = self.m_z_txt_news_Text,
      subPanelName = "GuildNewsSubPanel",
      selImg = self.m_btn_bg03,
      redDot = self.m_icon_redpoint03,
      backFun = nil
    }
  }
  self.m_widgetResourceBar = self:createResourceBar(self.m_common_top_resource)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1113)
end

function Form_Guild:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_curChooseTab = GuildPanelTab.Active
  self:RefreshUI()
  self:RefreshGuildGrade()
  self:DealCalmDownTranGuild()
  self:ChangeGuildTab(self.m_curChooseTab)
  GuildManager:OnReqAllianceLikedHistoryCS()
  GlobalManagerIns:TriggerWwiseBGMState(13)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(209)
end

function Form_Guild:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if self.m_tips_sequence then
    self.m_tips_sequence:Kill()
    self.m_tips_sequence = nil
  end
  if self.m_subPanelData then
    for i, panelData in pairs(self.m_subPanelData) do
      if panelData.subPanelLua and panelData.subPanelLua.RemoveAllEventListeners then
        panelData.subPanelLua:RemoveAllEventListeners()
      end
      if panelData.subPanelLua and panelData.subPanelLua.dispose then
        panelData.subPanelLua:dispose()
        panelData.subPanelLua = nil
      end
    end
  end
  self:OnCancelTransformGuild()
end

function Form_Guild:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_Leave", handler(self, self.OnEventLeaveAlliance))
  self:addEventListener("eGameEvent_Alliance_History", handler(self, self.OnEventHistoryAlliance))
  self:addEventListener("eGameEvent_Alliance_ChangeBulletin", handler(self, self.RefreshGuildInfo))
  self:addEventListener("eGameEvent_Alliance_GetApplyList", handler(self, self.OnEventGetApplyList))
  self:addEventListener("eGameEvent_Alliance_Destroy", handler(self, self.OnEventLeaveAlliance))
  self:addEventListener("eGameEvent_Alliance_ChangePost", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Alliance_Transfer", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Alliance_Like_History", handler(self, self.PushBLikeUI))
  self:addEventListener("eGameEvent_Alliance_ChangeSetting", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Alliance_ChangeName", handler(self, self.RefreshGuildInfo))
  self:addEventListener("eGameEvent_Alliance_GetApplyList_RedPoint", handler(self, self.OnCheckApplyListRedPoint))
  self:addEventListener("eGameEvent_Alliance_GetBossData", handler(self, self.OnEventGetBossData))
  self:addEventListener("eGameEvent_Alliance_RefreshTransformGuild", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Alliance_StartTransformGuild", handler(self, self.DealCalmDownTranGuild))
  self:addEventListener("eGameEvent_Alliance_CancelTransformGuild", handler(self, self.OnCancelTransformGuild))
end

function Form_Guild:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Guild:OnCheckApplyListRedPoint()
  local list = GuildManager:GetGuildApplyList()
  if list and table.getn(list) > 0 then
    self.m_member_redpoint:SetActive(true)
  else
    self.m_member_redpoint:SetActive(false)
  end
end

function Form_Guild:RefreshGuildInfo()
  local briefData = GuildManager:GetOwnerGuildDetail()
  local stBriefData = briefData.stBriefData or {}
  ResourceUtil:CreateGuildIconById(self.m_img_guild_icon_Image, stBriefData.iBadgeId)
  self.m_txt_guild_name_Text.text = tostring(stBriefData.sName)
  self.m_txt_notice_desc_Text.text = self.m_allianceBriefData.sBulletin
end

function Form_Guild:RefreshUI()
  self.m_allianceBriefData = GuildManager:GetOwnerGuildDetail()
  local stBriefData = self.m_allianceBriefData.stBriefData or {}
  ResourceUtil:CreateGuildIconById(self.m_img_guild_icon_Image, stBriefData.iBadgeId)
  self.m_txt_guild_name_Text.text = tostring(stBriefData.sName)
  self.m_txt_guild_level_Text.text = string.format(ConfigManager:GetCommonTextById(20033), tostring(stBriefData.iLevel))
  self.m_txt_notice_desc_Text.text = self.m_allianceBriefData.sBulletin
  self.m_num_activity_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20065), tostring(stBriefData.iSevenActive))
  local cfg = GuildManager:GetGuildLevelConfigByLv(stBriefData.iLevel)
  self.m_num_exp_Text.text = string.format(ConfigManager:GetCommonTextById(20048), tostring(self.m_allianceBriefData.iCurrDevelopment), cfg.m_NeedExp)
  self.m_line_progress_Image.fillAmount = math.min(self.m_allianceBriefData.iCurrDevelopment / cfg.m_NeedExp, 1)
  self.m_icon_redpoint01:SetActive(false)
  self.m_icon_redpoint02:SetActive(false)
  self.m_icon_redpoint03:SetActive(false)
  local memberData = GuildManager:GetOwnerGuildMemberDataByUID(RoleManager:GetUID())
  if memberData then
    self.m_btn_edit:SetActive(memberData.iPost ~= GuildManager.AlliancePost.Member)
    self.m_btn_set:SetActive(memberData.iPost ~= GuildManager.AlliancePost.Member)
    self.m_btn_member_set:SetActive(memberData.iPost ~= GuildManager.AlliancePost.Member)
  else
    self.m_btn_edit:SetActive(false)
    self.m_btn_set:SetActive(false)
    self.m_btn_member_set:SetActive(false)
  end
  self.m_txt_guild_uid_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100053), stBriefData.iAllianceId)
  self:PushBLikeUI()
  if memberData.iPost == GuildManager.AlliancePost.Master then
    GuildManager:ReqOpenAllianceGetApplyListCS()
  end
end

function Form_Guild:RefreshGuildGrade()
  local stBriefData = self.m_allianceBriefData.stBriefData or {}
  local isRankActive = GuildManager:IsGuildRankDataActive(stBriefData)
  self.m_bg_guild_rank:SetActive(isRankActive)
  if isRankActive then
    local grade = GuildManager:GetGuildBossGradeByRank(stBriefData.iLastBattleRank, stBriefData.iLastBattleRankCount)
    local gradeCfg = GuildManager:GetGuildBattleGradeCfgByID(grade)
    ResourceUtil:CreateGuildGradeIconById(self.m_icon_rank_Image, grade)
    self.m_txt_rank_Text.text = gradeCfg.m_mGradeName
  end
end

function Form_Guild:PushBLikeUI()
  local bLikeList = GuildManager:GetBLikeHistoryList()
  local tempTab = {}
  if bLikeList and 0 < #bLikeList then
    local function sortFun(data1, data2)
      return data1.iTime < data2.iTime
    end
    
    table.sort(bLikeList, sortFun)
    local iTime = CS.UnityEngine.PlayerPrefs.GetInt("__GuildBLikeTime", 0)
    for i, v in ipairs(bLikeList) do
      if iTime < v.iTime then
        tempTab[#tempTab + 1] = v
      end
    end
    CS.UnityEngine.PlayerPrefs.SetInt("__GuildBLikeTime", bLikeList[#bLikeList].iTime)
  end
  if 0 < #tempTab then
    UILuaHelper.SetLocalPosition(self.m_pnl_guild_received_tips, 0, 0, 0)
    self.m_txt_received_tips_Text.text = string.gsubnumberreplace(ConfigManager:GetClientMessageTextById(10239), #tempTab)
    self.m_pnl_guild_received_tips:SetActive(true)
    local tipsObj = self.m_pnl_guild_received_tips
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(self.m_pnl_guild_received_tips.transform:DOLocalMoveY(180, 2))
    sequence:OnComplete(function()
      if not utils.isNull(tipsObj) then
        tipsObj:SetActive(false)
      end
    end)
    sequence:SetAutoKill(true)
    self.m_tips_sequence = sequence
  else
    self.m_pnl_guild_received_tips:SetActive(false)
  end
end

function Form_Guild:OnEventLeaveAlliance()
  self:OnBackHome()
end

function Form_Guild:OnEventHistoryAlliance()
  self:ChangeGuildTab(GuildPanelTab.News)
end

function Form_Guild:OnEventGetApplyList(data)
  StackPopup:Push(UIDefines.ID_FORM_GUILDMANAGEPOP, {
    vApplyList = data.vApplyList,
    callFun = function()
      if self.OnCheckApplyListRedPoint then
        self:broadcastEvent("eGameEvent_Alliance_GetApplyList_RedPoint")
      end
    end
  })
end

function Form_Guild:OnEventGetBossData()
  StackFlow:Push(UIDefines.ID_FORM_GUILDRAIDMAIN)
end

function Form_Guild:ChangeGuildTab(index)
  if index then
    self.m_curChooseTab = index
    self:ChangeTabStyle(index)
    local curSubPanelData = self.m_subPanelData[index]
    if curSubPanelData then
      if curSubPanelData.subPanelLua == nil then
        local initData = curSubPanelData.backFun and {
          backFun = curSubPanelData.backFun
        } or nil
        
        local function loadCallBack(subPanelLua)
          if subPanelLua then
            curSubPanelData.subPanelLua = subPanelLua
            if subPanelLua.AddEventListeners then
              subPanelLua:AddEventListeners()
            end
          end
        end
        
        SubPanelManager:LoadSubPanel(curSubPanelData.subPanelName, curSubPanelData.panelRoot, self, initData, {initData = initData}, loadCallBack)
      else
        self:RefreshCurTabSubPanelInfo()
      end
    end
  end
end

function Form_Guild:RefreshCurTabSubPanelInfo()
  if not self.m_curChooseTab then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curChooseTab]
  local subPanelLua = curSubPanelData.subPanelLua
  if subPanelLua then
    subPanelLua:SetActive(true)
    subPanelLua:OnFreshData()
  end
end

function Form_Guild:ChangeTabStyle(index)
  for i, v in ipairs(self.m_subPanelData) do
    if i == index then
      v.selImg:SetActive(true)
      UILuaHelper.SetColor(v.txtTab, 231, 231, 231, 255)
    else
      if v.subPanelLua then
        v.subPanelLua:SetActive(false)
      end
      v.selImg:SetActive(false)
      UILuaHelper.SetColor(v.txtTab, 136, 136, 136, 255)
    end
  end
end

function Form_Guild:OnTabClk(index)
  if not index then
    return
  end
  if index == self.m_curChooseTab then
    return
  end
  if index == GuildPanelTab.News then
    GuildManager:OnReqAllianceHistoryCS()
  else
    self:ChangeGuildTab(index)
  end
end

function Form_Guild:OnBtneventClicked()
  self:OnTabClk(GuildPanelTab.Active)
end

function Form_Guild:OnBtnmemberClicked()
  self:OnTabClk(GuildPanelTab.Member)
end

function Form_Guild:OnBtnnewsClicked()
  self:OnTabClk(GuildPanelTab.News)
end

function Form_Guild:OnBtnexitClicked()
  local inTime = GuildManager:IsGuildBossTime()
  if inTime then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10208)
    return
  end
  if self.m_allianceBriefData then
    local member = self.m_allianceBriefData.vMember
    if table.getn(member) == 1 then
      utils.popUpDirectionsUI({
        tipsID = 1506,
        func1 = function()
          GuildManager:ReqAllianceDestroy()
        end
      })
    else
      local memberData = GuildManager:GetOwnerGuildMemberDataByUID(RoleManager:GetUID())
      if memberData and memberData.iPost == GuildManager.AlliancePost.Master then
        StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10217)
      else
        utils.popUpDirectionsUI({
          tipsID = 1505,
          func1 = function()
            GuildManager:ReqLeaveAlliance()
          end
        })
      end
    end
  else
    self:OnBackClk()
  end
end

function Form_Guild:OnBtneditClicked()
  local isInLimitTime, limitStr = ActivityManager:IsInForbidCustomLimitTime()
  if isInLimitTime == true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST_SPE, limitStr)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_GUILDNOTICECHANGE, {openType = 1})
end

function Form_Guild:OnBtnsetClicked()
  StackPopup:Push(UIDefines.ID_FORM_GUILDEDITOR)
end

function Form_Guild:OnBtnmembersetClicked()
  GuildManager:ReqAllianceGetApplyListCS()
end

function Form_Guild:OnBtniconcopyClicked()
  UILuaHelper.CopyTextToClipboard(tostring(self.m_allianceBriefData.stBriefData.iAllianceId))
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20025)
end

function Form_Guild:OnBackClk()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_GUILD)
end

function Form_Guild:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackPopup:PopAll()
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_Guild:OnCancelTransformGuild()
  if self.m_calmDownTimer then
    TimeService:KillTimer(self.m_calmDownTimer)
    self.m_calmDownTimer = nil
  end
end

function Form_Guild:DealCalmDownTranGuild()
  local allianceData = GuildManager:GetOwnerGuildDetail()
  local transferEffectTime, NewTransferMasterUid = GuildManager:GetTransGuildInfo()
  local isEffect = false
  if transferEffectTime and 0 < transferEffectTime then
    for _, memberData in pairs(allianceData.vMember) do
      if memberData.iPost == GuildManager.AlliancePost.Master and memberData.stRoleId.iUid == RoleManager:GetUID() then
        isEffect = true
        break
      end
      if allianceData.stNewTransferMaster.iUid == RoleManager:GetUID() then
        isEffect = true
      end
    end
  end
  if isEffect then
    local endTime = allianceData.iTransferEffectTime
    local lastTime = endTime - TimeUtil:GetServerTimeS()
    if not self.m_calmDownTimer then
      self.m_calmDownTimer = TimeService:SetTimer(lastTime, 1, function()
        TimeService:KillTimer(self.m_calmDownTimer)
        self.m_calmDownTimer = nil
        local allianceId = RoleManager:GetRoleAllianceInfo()
        GuildManager:ReqGetOwnerAllianceDetailOnTransformGuide(allianceId)
      end)
    end
  end
end

function Form_Guild:IsFullScreen()
  return true
end

function Form_Guild:OnDestroy()
  self.super.OnDestroy(self)
  self:RemoveAllEventListeners()
  if self.m_subPanelData then
    for i, panelData in pairs(self.m_subPanelData) do
      if panelData.subPanelLua and panelData.subPanelLua.RemoveAllEventListeners then
        panelData.subPanelLua:RemoveAllEventListeners()
      end
      if panelData.subPanelLua and panelData.subPanelLua.dispose then
        panelData.subPanelLua:dispose()
        panelData.subPanelLua = nil
      end
    end
  end
  if self.m_tips_sequence then
    self.m_tips_sequence:Kill()
    self.m_tips_sequence = nil
  end
end

function Form_Guild:GetDownloadResourceExtra(tParam)
  local vSubPanelName = {
    "GuildActiveSubPanel",
    "GuildMemberSubPanel",
    "GuildNewsSubPanel"
  }
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(vSubPanelName) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
    if vPackageSub ~= nil then
      for i = 1, #vPackageSub do
        vPackage[#vPackage + 1] = vPackageSub[i]
      end
    end
    if vResourceExtraSub ~= nil then
      for i = 1, #vResourceExtraSub do
        vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
      end
    end
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Guild", Form_Guild)
return Form_Guild
