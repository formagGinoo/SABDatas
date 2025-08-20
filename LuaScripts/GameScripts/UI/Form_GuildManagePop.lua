local Form_GuildManagePop = class("Form_GuildManagePop", require("UI/UIFrames/Form_GuildManagePopUI"))

function Form_GuildManagePop:SetInitParam(param)
end

function Form_GuildManagePop:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuildManagePop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_PlayerHeadCache = {}
  self.m_vApplyList = tParam.vApplyList
  self.m_callFun = tParam.callFun
  self.m_selMemberUid = nil
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_GuildManagePop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_PlayerHeadCache = {}
end

function Form_GuildManagePop:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_OperateApply", handler(self, self.OnOperateApplyCB))
  self:addEventListener("eGameEvent_Alliance_RefuseAll", handler(self, self.OnOperateRefuseAllCB))
  self:addEventListener("eGameEvent_Alliance_ReGetApplyList", handler(self, self.RefreshApplyList))
end

function Form_GuildManagePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildManagePop:RefreshApplyList(data)
  self.m_vApplyList = data.vApplyList
  self:RefreshUI()
end

function Form_GuildManagePop:RefreshUI()
  local guildData = GuildManager:GetOwnerGuildDetail()
  if guildData then
    local guildLvCfg = GuildManager:GetGuildLevelConfigByLv(guildData.stBriefData.iLevel) or {}
    local member = guildLvCfg.m_Member
    self.m_txt_invitenum_Text.text = string.format(ConfigManager:GetCommonTextById(20048), table.getn(guildData.vMember), member)
  else
    self.m_txt_invitenum_Text.text = ""
  end
  self:refreshLoopScroll()
  if self.m_z_txt_nothing then
    self.m_z_txt_nothing:SetActive(table.getn(self.m_vApplyList) == 0)
  end
end

function Form_GuildManagePop:OnOperateApplyCB()
  if self.m_selMemberUid then
    for i, v in ipairs(self.m_vApplyList) do
      if v.stRoleId.iUid == self.m_selMemberUid then
        table.remove(self.m_vApplyList, i)
        break
      end
    end
  end
  self.m_selMemberUid = nil
  self:RefreshUI()
end

function Form_GuildManagePop:OnOperateRefuseAllCB()
  self.m_vApplyList = {}
  self:RefreshUI()
end

function Form_GuildManagePop:refreshLoopScroll()
  local data = self.m_vApplyList
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
        if click_name == "c_btn_reject" then
          GuildManager:ReqAllianceOperateApplyCS(cell_data.stRoleId.iUid, false, cell_data.stRoleId.iZoneId)
        elseif click_name == "c_btn_accept" then
          GuildManager:ReqAllianceOperateApplyCS(cell_data.stRoleId.iUid, true, cell_data.stRoleId.iZoneId)
        end
        self.m_selMemberUid = cell_data.stRoleId.iUid
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_GuildManagePop:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local c_circle_head = luaBehaviour:FindGameObject("c_circle_head")
  LuaBehaviourUtil.setText(luaBehaviour, "c_txt_player_name", cell_data.sRoleName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_power", tostring(cell_data.iPower))
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

function Form_GuildManagePop:OnBtninviteClicked()
  StackPopup:Push(UIDefines.ID_FORM_GUILDINVITEMEMBER)
end

function Form_GuildManagePop:OnBtnrejectClicked()
  GuildManager:ReqAllianceRefuseAllCS()
end

function Form_GuildManagePop:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_GuildManagePop:OnBtnCloseClicked()
  if self.m_callFun then
    self.m_callFun()
  end
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDMANAGEPOP)
end

function Form_GuildManagePop:IsOpenGuassianBlur()
  return true
end

function Form_GuildManagePop:OnDestroy()
  self.super.OnDestroy(self)
  self.m_PlayerHeadCache = nil
end

local fullscreen = true
ActiveLuaUI("Form_GuildManagePop", Form_GuildManagePop)
return Form_GuildManagePop
