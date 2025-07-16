local Form_PvpRankList = class("Form_PvpRankList", require("UI/UIFrames/Form_PvpRankListUI"))
local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local PVP_NEW_RANK_CNT = tonumber(GlobalManagerIns:GetValue_ByName("PVPNewRankcnt").m_Value) or 0
local PVP_NEW_RANK_PAGE_CNT = tonumber(GlobalManagerIns:GetValue_ByName("PVPNewRankPagecnt").m_Value) or 0
local TOP_COLOR = CS.UnityEngine.Color(0.9647058823529412, 0.9215686274509803, 0.7568627450980392, 1)
local NORMAL_COLOR = CS.UnityEngine.Color(0.8431372549019608, 0.8392156862745098, 0.8156862745098039, 1)

function Form_PvpRankList:SetInitParam(param)
end

function Form_PvpRankList:AfterInit()
  self.super.AfterInit(self)
  self.m_load_end = false
end

function Form_PvpRankList:OnActive()
  self.super.OnActive(self)
  self.m_load_end = false
  self.m_firstOpenFlag = true
  self.m_PlayerHeadCache = {}
  self.m_playerHeadCom = self:createPlayerHead(self.m_mine_head)
  self.m_playerHeadCom:SetStopClkStatus(true)
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_PvpRankList:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_load_end = false
  self.m_loop_scroll_view = nil
  self.m_PlayerHeadCache = {}
end

function Form_PvpRankList:RefreshUI()
  self:refreshLoopScroll()
  self:RefreshOwnerRankUI()
end

function Form_PvpRankList:PullRefreshUI()
  if self.m_firstOpenFlag then
    self.m_firstOpenFlag = false
    return
  end
  self.m_load_end = true
  self:RefreshUI()
end

function Form_PvpRankList:AddEventListeners()
  self:addEventListener("eGameEvent_UpDataRankList", handler(self, self.PullRefreshUI))
end

function Form_PvpRankList:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpRankList:refreshLoopScroll()
  local data = RankManager:GetRankDataListBySystemId(RankManager.RankType.Arena)
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scrollView
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end,
      pull_refresh = function()
        self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
        local count = PVP_NEW_RANK_PAGE_CNT
        if #data < PVP_NEW_RANK_CNT then
          count = math.min(PVP_NEW_RANK_CNT - #data, PVP_NEW_RANK_PAGE_CNT)
          RankManager:ReqArenaRankListCS(RankManager.RankType.Arena, #data + 1, #data + count)
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    self.m_loop_scroll_view:moveToCellIndex(1)
  else
    self.m_loop_scroll_view:reloadData(data)
    if self.m_load_end == true then
      self:PullRefreshListOffset()
    end
  end
end

function Form_PvpRankList:PullRefreshListOffset()
  if self.last_offsety then
    local now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    local position = (self.last_offsety - now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
    self.m_load_end = false
  end
end

function Form_PvpRankList:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local stRole = cell_data.stRole
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_rank1", cell_data.iRank == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_rank2", cell_data.iRank == 2)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_rank3", cell_data.iRank == 3)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_rank4", cell_data.iRank > 3)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank", cell_data.iRank)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_name", stRole.sName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_lv", stRole.iLevel)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_achievement", cell_data.iScore)
  local temp = stRole.sAlliance ~= "" and stRole.sAlliance or ConfigManager:GetCommonTextById(20111) or ""
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_guild_name", temp)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_power", stRole.mSimpleData[MTTDProto.CmdSimpleDataType_OriginalPvpDefend] or 0)
  local color = cell_data.iRank <= 3 and TOP_COLOR or NORMAL_COLOR
  LuaBehaviourUtil.setTextMeshProColor(luaBehaviour, "m_txt_rank", color)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_st1", cell_data.iRank == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_rd2", cell_data.iRank == 2)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_nd3", cell_data.iRank == 3)
  local rankBg1 = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bg_title")
  rankBg1.gameObject:SetActive(cell_data.iRank <= 3)
  if cell_data.iRank == 1 then
    LuaBehaviourUtil.setTextMeshProColor(luaBehaviour, "m_txt_rank", RankManager.ColorEnum.first)
    rankBg1.color = RankManager.ColorEnum.first
  elseif cell_data.iRank == 2 then
    LuaBehaviourUtil.setTextMeshProColor(luaBehaviour, "m_txt_rank", RankManager.ColorEnum.second)
    rankBg1.color = RankManager.ColorEnum.second
  elseif cell_data.iRank == 3 then
    LuaBehaviourUtil.setTextMeshProColor(luaBehaviour, "m_txt_rank", RankManager.ColorEnum.third)
    rankBg1.color = RankManager.ColorEnum.third
  else
    LuaBehaviourUtil.setTextMeshProColor(luaBehaviour, "m_txt_rank", RankManager.ColorEnum.normal)
  end
  local bg = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bg_rank")
  bg.color = cell_data.iRank <= 3 and RankManager.ColorEnum.firstbg or RankManager.ColorEnum.normalbg
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

function Form_PvpRankList:RefreshOwnerRankUI()
  local data = RankManager:GetOwnerRankDataListBySystemId(RankManager.RankType.Arena)
  if data and data.iMyRank ~= 0 then
    self.m_icon_rank1_mine:SetActive(data.iMyRank == 1)
    self.m_icon_rank2_mine:SetActive(data.iMyRank == 2)
    self.m_icon_rank3_mine:SetActive(data.iMyRank == 3)
    self.m_icon_rank4_mine:SetActive(data.iMyRank > 3)
    self.m_z_txt_rank_ownst1:SetActive(data.iMyRank == 1)
    self.m_z_txt_rank_ownnd2:SetActive(data.iMyRank == 2)
    self.m_z_txt_rank_ownrd3:SetActive(data.iMyRank == 3)
    if data.iMyRank == 1 then
      self.m_txt_rank_mine_Text.color = RankManager.ColorEnum.first
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.first
    elseif data.iMyRank == 2 then
      self.m_txt_rank_mine_Text.color = RankManager.ColorEnum.second
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.second
    elseif data.iMyRank == 3 then
      self.m_txt_rank_mine_Text.color = RankManager.ColorEnum.third
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.third
    else
      self.m_txt_rank_mine_Text.color = RankManager.ColorEnum.normal
    end
    self.m_img_bg_titelown:SetActive(data.iMyRank <= 4)
    self.m_txt_rank_mine_Text.text = data.iMyRank or ""
    self.m_txt_name_mine_Text.text = tostring(RoleManager:GetName())
    self.m_playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
    self.m_txt_guild_name_mine_Text.text = RoleManager:GetAllianceName()
    self.m_txt_power_mine_Text.text = data.iMyPower or 0
    self.m_txt_achievement_mine_Text.text = data.iMyScore or 0
    self.m_pnl_rankingmine:SetActive(true)
    self.m_z_txt_norank:SetActive(false)
  else
    self.m_pnl_rankingmine:SetActive(false)
    self.m_z_txt_norank:SetActive(true)
  end
end

function Form_PvpRankList:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PVPRANKLIST)
end

function Form_PvpRankList:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PVPRANKLIST)
end

function Form_PvpRankList:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpRankList:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpRankList", Form_PvpRankList)
return Form_PvpRankList
