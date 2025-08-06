local Form_PvpRecordList = class("Form_PvpRecordList", require("UI/UIFrames/Form_PvpRecordListUI"))

function Form_PvpRecordList:SetInitParam(param)
end

function Form_PvpRecordList:AfterInit()
  self.super.AfterInit(self)
end

function Form_PvpRecordList:OnActive()
  self.super.OnActive(self)
  self.m_recordList = self.m_csui.m_param.vRecord or {}
  self.m_PlayerHeadCache = {}
  self:refreshLoopScroll()
end

function Form_PvpRecordList:OnInactive()
  self.super.OnInactive(self)
  self.m_PlayerHeadCache = {}
end

function Form_PvpRecordList:refreshLoopScroll()
  local data = self.m_recordList
  self.m_scrollView:SetActive(0 < #data)
  self.m_img_empty:SetActive(#data == 0)
  if #data == 0 then
    return
  end
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scrollView
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_PvpRecordList:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local stRole = cell_data.stEnemy
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_offensive", cell_data.bIsAttacker == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_defensive", cell_data.bIsAttacker == 0)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_win", cell_data.bWin == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_lose", cell_data.bWin == 0)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank_num", cell_data.iMyNewRank)
  LuaBehaviourUtil.setText(luaBehaviour, "m_txt_name", stRole.sName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_lv", stRole.iLevel)
  LuaBehaviourUtil.setText(luaBehaviour, "m_txt_guild_name", "")
  local changeRank = cell_data.iMyOldRank - cell_data.iMyNewRank
  if changeRank == 0 then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_arrow01", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_arrow02", false)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_arrow01", 0 < changeRank)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_arrow02", changeRank < 0)
  end
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_power", stRole.mSimpleData[MTTDProto.CmdSimpleDataType_OriginalPvpDefend] or 0)
  local rank = cell_data.iMyOldRank - cell_data.iMyNewRank
  if rank == 0 then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_rank_numup", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_rank_numdown", false)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_rank_numup", 0 < rank)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_rank_numdown", rank < 0)
    if 0 < rank then
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank_numup", math.abs(rank))
    elseif rank < 0 then
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank_numdown", math.abs(rank))
    end
  end
  local iTime = math.max(TimeUtil:GetServerTimeS() - cell_data.iTime, 0)
  local timeStr = TimeUtil:SecondsToFormatStrPvp(iTime)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_battle_time", timeStr)
  local changeScore = cell_data.iMyNewScore - cell_data.iMyOldScore
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_score_num", cell_data.iMyNewScore)
  if changeScore == 0 then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_arrow03", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_arrow04", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_score_numup", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_score_numdown", false)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_arrow03", 0 < changeScore)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_arrow04", changeScore < 0)
    local txtShowScore = 0 < changeScore and "m_txt_score_numup" or "m_txt_score_numdown"
    local txtHideScore = changeScore < 0 and "m_txt_score_numup" or "m_txt_score_numdown"
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, txtShowScore, true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, txtHideScore, false)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, txtShowScore, math.abs(changeScore))
  end
  local c_circle_headTrans = transform:Find("m_img_rank_item/c_circle_head")
  if c_circle_headTrans then
    local headObj = c_circle_headTrans.gameObject
    local gameObjectHashCode = headObj:GetHashCode()
    local tempPlayerHeadCom = self.m_PlayerHeadCache[gameObjectHashCode]
    if not tempPlayerHeadCom then
      tempPlayerHeadCom = self:createPlayerHead(headObj)
      tempPlayerHeadCom:SetStopClkStatus(true)
      self.m_PlayerHeadCache[gameObjectHashCode] = tempPlayerHeadCom
    end
    tempPlayerHeadCom:SetPlayerHeadInfo(stRole)
  end
end

function Form_PvpRecordList:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PVPRECORDLIST)
end

function Form_PvpRecordList:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PVPRECORDLIST)
end

function Form_PvpRecordList:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpRecordList:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpRecordList", Form_PvpRecordList)
return Form_PvpRecordList
