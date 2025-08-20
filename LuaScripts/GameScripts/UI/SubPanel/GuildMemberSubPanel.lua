local UISubPanelBase = require("UI/Common/UISubPanelBase")
local GuildMemberSubPanel = class("GuildMemberSubPanel", UISubPanelBase)
local ADD_BG_NUM = 4

function GuildMemberSubPanel:OnInit()
  self.m_guildData = nil
  self.m_widgetBtnFilter = self:createFilterButton(self.m_common_filter)
  self.m_curFilterIndex = 1
  self.m_bFilterDown = false
  self.m_grayImgMaterial = self.m_img_gray_Image.material
  self.m_PlayerHeadCache = {}
end

function GuildMemberSubPanel:OnFreshData()
  self.m_guildData = GuildManager:GetOwnerGuildDetail()
  self.m_memberList = self.m_guildData.vMember or {}
  self.m_widgetBtnFilter:RefreshTabConfig(GuildManager.GuildMemberFilter, self.m_curFilterIndex, self.m_bFilterDown, handler(self, self.OnFilterChanged))
  local guildLvCfg = GuildManager:GetGuildLevelConfigByLv(self.m_guildData.stBriefData.iLevel) or {}
  local member = guildLvCfg.m_Member
  self.m_num_menber_Text.text = string.format(ConfigManager:GetCommonTextById(20048), table.getn(self.m_memberList), member)
  self.m_memberList = GuildManager:SortMemberData(self.m_memberList, self.m_curFilterIndex, self.m_bFilterDown)
  self:refreshLoopScroll()
end

function GuildMemberSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_ChangePost", handler(self, self.OnFreshData))
  self:addEventListener("eGameEvent_Alliance_Transfer", handler(self, self.OnFreshData))
  self:addEventListener("eGameEvent_Alliance_Kick", handler(self, self.OnFreshData))
  self:addEventListener("eGameEvent_Alliance_OperateApply", handler(self, self.OnFreshData))
  self:addEventListener("eGameEvent_Alliance_Like", handler(self, self.OnLikeCB))
  self:addEventListener("eGameEvent_Alliance_Join", handler(self, self.OnFreshData))
  self:addEventListener("eGameEvent_Alliance_RefreshTransformGuild", handler(self, self.OnFreshData))
end

function GuildMemberSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function GuildMemberSubPanel:OnLikeCB(rewardList)
  if rewardList and next(rewardList) then
    utils.popUpRewardUI(rewardList)
  end
  self:OnFreshData()
end

function GuildMemberSubPanel:OnFilterChanged(iIndex, bDown)
  self.m_curFilterIndex = iIndex
  self.m_bFilterDown = bDown
  self.m_memberList = GuildManager:SortMemberData(self.m_memberList, self.m_curFilterIndex, self.m_bFilterDown)
  self:refreshLoopScroll()
end

function GuildMemberSubPanel:refreshLoopScroll()
  local data = table.deepcopy(self.m_memberList)
  if #self.m_memberList < ADD_BG_NUM then
    for i = 1, ADD_BG_NUM do
      if data[i] == nil then
        data[i] = 1
      end
    end
  end
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_member_list
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "c_btn_like" then
          CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
          local _, likeNum = GuildManager:GetAllianceDailyLikedInfo()
          if 0 < likeNum then
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10238)
          elseif cell_data then
            GuildManager:ReqAllianceLikeCS(cell_data.stRoleId)
          end
        elseif click_name == "c_btn_bg" then
          StackPopup:Push(UIDefines.ID_FORM_GUILDMEMBERINFOPOP, cell_data)
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function GuildMemberSubPanel:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local c_circle_head = luaBehaviour:FindGameObject("c_circle_head")
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_bg_node", cell_data == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_root_node", cell_data ~= 1)
  if cell_data == 1 then
    return
  end
  if cell_data.bOnline then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_afktime", ConfigManager:GetCommonTextById(100045))
  else
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_afktime", TimeUtil:GetOfflineTimeText(cell_data.iLastLogoutTime))
  end
  local active = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100041), tostring(cell_data.iTodayActive or 0))
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_num_member_activity", active)
  LuaBehaviourUtil.setText(luaBehaviour, "c_txt_name", cell_data.sRoleName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_power", cell_data.iPower)
  local img_careericon = UIUtil.findImage(transform, "c_root_node/c_txt_name/c_img_careericon")
  ResourceUtil:CreateGuildPostIconByPost(img_careericon, cell_data.iPost)
  local likeFlag = GuildManager:CheckIsLikedByMemberId(cell_data.stRoleId.iUid, cell_data.stRoleId.iZoneId)
  local _, likeNum = GuildManager:GetAllianceDailyLikedInfo()
  local banNum = 0
  local banEndTime = cell_data.iBanEndTime
  if banEndTime ~= nil and banEndTime ~= nil and tonumber(banEndTime) > TimeUtil:GetServerTimeS() then
    banNum = cell_data.iBanShowType or 0
  end
  local isBan = banNum ~= RoleManager.BanType.None
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_like", not isBan and not likeFlag)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_btn_liked", not isBan and likeFlag)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_ban", banNum == RoleManager.BanType.NormalBan)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_txt_ban_red", banNum == RoleManager.BanType.CheatBan)
  local c_btn_like = UIUtil.findImage(transform, "c_root_node/c_btn_like")
  if 0 < likeNum and likeFlag == false then
    c_btn_like.material = self.m_grayImgMaterial
  else
    c_btn_like.material = nil
  end
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

function GuildMemberSubPanel:OnPlayerHeadClk(stRoleId)
  if not stRoleId then
    return
  end
  local tempStRoleID = stRoleId
  StackPopup:Push(UIDefines.ID_FORM_PERSONALCARD, {
    zoneID = tempStRoleID.iZoneId,
    otherRoleID = tempStRoleID.iUid
  })
end

function GuildMemberSubPanel:dispose()
  GuildMemberSubPanel.super.dispose(self)
  self.m_PlayerHeadCache = {}
end

return GuildMemberSubPanel
