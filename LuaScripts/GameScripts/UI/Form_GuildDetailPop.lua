local Form_GuildDetailPop = class("Form_GuildDetailPop", require("UI/UIFrames/Form_GuildDetailPopUI"))
local TAB_TYPE = {Detail = 1, Member = 2}

function Form_GuildDetailPop:SetInitParam(param)
end

function Form_GuildDetailPop:AfterInit()
  self.super.AfterInit(self)
  self.m_formatStr = ConfigManager:GetCommonTextById(20048)
end

function Form_GuildDetailPop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_PlayerHeadCache = {}
  self.m_selectTab = TAB_TYPE.Detail
  self.m_guildData = tParam.guildData
  self.m_hideJoinBtn = tParam.hideJoinBtn
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_GuildDetailPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_PlayerHeadCache = {}
end

function Form_GuildDetailPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildDetailPop:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_Apply", handler(self, self.OnGuildApply))
  self:addEventListener("eGameEvent_Alliance_RemoveGuildData", handler(self, self.OnGuildRemoveGuildData))
end

function Form_GuildDetailPop:OnGuildApply()
  self:OnBtnReturnClicked()
end

function Form_GuildDetailPop:OnGuildRemoveGuildData()
  self:OnBtnReturnClicked()
end

function Form_GuildDetailPop:RefreshUI()
  self.m_pnl_rank:SetActive(false)
  local stBriefData = self.m_guildData.stBriefData
  local guildLvCfg = GuildManager:GetGuildLevelConfigByLv(stBriefData.iLevel) or {}
  self.m_txt_lv_Text.text = string.format(ConfigManager:GetCommonTextById(20033), tostring(stBriefData.iLevel))
  self.m_txt_guild_name_Text.text = stBriefData.sName
  self.m_txt_mb_Text.text = string.format(self.m_formatStr, stBriefData.iCurrMemberCount, guildLvCfg.m_Member)
  self.m_btn_join:SetActive(self.m_guildData.stBriefData.iJoinType ~= GuildManager.AllianceJoinType.AllianceJoinType_None)
  self.m_txt_activitynum_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20065), tostring(stBriefData.iSevenActive or 0))
  self.m_txt_guild_uid_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100053), stBriefData.iAllianceId)
  ResourceUtil:CreateGuildIconById(self.m_img_logo_Image, stBriefData.iBadgeId)
  self:RefreshContent()
  self.m_btn_join:SetActive(not self.m_hideJoinBtn)
  self:RefreshGuildGrade()
end

function Form_GuildDetailPop:RefreshGuildGrade()
  local stBriefData = self.m_guildData.stBriefData or {}
  local isRankActive = GuildManager:IsGuildRankDataActive(stBriefData)
  self.m_bg_guild_rank:SetActive(isRankActive)
  if isRankActive then
    local grade = GuildManager:GetGuildBossGradeByRank(stBriefData.iLastBattleRank, stBriefData.iLastBattleRankCount)
    ResourceUtil:CreateGuildGradeIconById(self.m_icon_rank_Image, grade)
    local gradeCfg = GuildManager:GetGuildBattleGradeCfgByID(grade)
    self.m_txt_rank_Text.text = gradeCfg.m_mGradeName
  end
end

function Form_GuildDetailPop:RefreshContent()
  self.m_select2:SetActive(self.m_selectTab == TAB_TYPE.Member)
  self.m_select1:SetActive(self.m_selectTab == TAB_TYPE.Detail)
  self.m_pnl_content_tab1:SetActive(self.m_selectTab == TAB_TYPE.Detail)
  self.m_pnl_content_tab2:SetActive(self.m_selectTab == TAB_TYPE.Member)
  if self.m_selectTab == TAB_TYPE.Detail then
    self:RefreshDetail()
  else
    self:refreshLoopScroll()
  end
end

function Form_GuildDetailPop:RefreshDetail()
  local stBriefData = self.m_guildData.stBriefData
  self.m_txt_infor1_level_Text.text = stBriefData.iJoinLevel
  if GuildManager.GuildJoinType[stBriefData.iJoinType + 1] then
    local joinType = GuildManager.GuildJoinType[stBriefData.iJoinType + 1].sTitle
    self.m_txt_infor2_type_Text.text = ConfigManager:GetCommonTextById(joinType)
  end
  self.m_txt_info_des_Text.text = self.m_guildData.stBriefData.sRecruit
end

function Form_GuildDetailPop:refreshLoopScroll()
  local data = self.m_guildData.vMember
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_scrollView
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_GuildDetailPop:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local c_circle_head = luaBehaviour:FindGameObject("c_circle_head")
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_power", cell_data.iPower)
  LuaBehaviourUtil.setText(luaBehaviour, "c_txt_name", cell_data.sRoleName)
  local timeDes = cell_data.bOnline and ConfigManager:GetCommonTextById(100061) or TimeUtil:GetOfflineTimeText(cell_data.iLastLogoutTime, true)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_timedes", timeDes)
  local c_img_persontag = UIUtil.findImage(transform, "offset/c_txt_name/c_img_persontag")
  ResourceUtil:CreateGuildPostIconByPost(c_img_persontag, cell_data.iPost)
  if c_circle_head then
    if not self.m_PlayerHeadCache then
      self.m_PlayerHeadCache = {}
    end
    local gameObjectHashCode = c_circle_head:GetHashCode()
    local tempPlayerHeadCom = self.m_PlayerHeadCache[gameObjectHashCode]
    if not tempPlayerHeadCom then
      tempPlayerHeadCom = self:createPlayerHead(c_circle_head)
      self.m_PlayerHeadCache[gameObjectHashCode] = tempPlayerHeadCom
    end
    tempPlayerHeadCom:SetPlayerHeadInfo(cell_data)
  end
end

function Form_GuildDetailPop:OnPlayerHeadClk(stRoleId)
  if not stRoleId then
    return
  end
  local tempStRoleID = stRoleId
  StackPopup:Push(UIDefines.ID_FORM_PERSONALCARD, {
    zoneID = tempStRoleID.iZoneId,
    otherRoleID = tempStRoleID.iUid
  })
end

function Form_GuildDetailPop:ChangeTab(index)
  if self.m_selectTab ~= index then
    self.m_selectTab = index
    self:RefreshContent()
  end
end

function Form_GuildDetailPop:OnBtnjoinClicked()
  GuildManager:OnReqAllianceApplyCS(self.m_guildData.stBriefData.iAllianceId)
end

function Form_GuildDetailPop:OnNormal2Clicked()
  self:ChangeTab(TAB_TYPE.Member)
end

function Form_GuildDetailPop:OnNormal1Clicked()
  self:ChangeTab(TAB_TYPE.Detail)
end

function Form_GuildDetailPop:OnBtnemptyClicked()
  self:OnBtnReturnClicked()
end

function Form_GuildDetailPop:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDDETAILPOP)
end

function Form_GuildDetailPop:IsOpenGuassianBlur()
  return true
end

function Form_GuildDetailPop:OnDestroy()
  self.super.OnDestroy(self)
  self.m_PlayerHeadCache = nil
end

local fullscreen = true
ActiveLuaUI("Form_GuildDetailPop", Form_GuildDetailPop)
return Form_GuildDetailPop
