local Form_PvpRewardPop = class("Form_PvpRewardPop", require("UI/UIFrames/Form_PvpRewardPopUI"))

function Form_PvpRewardPop:SetInitParam(param)
end

function Form_PvpRewardPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_PvpRewardPop:OnActive()
  self.super.OnActive(self)
  self:GeneratedPvpReward()
  self:refreshLoopScroll()
  self:AddEventListeners()
end

function Form_PvpRewardPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_PvpRewardPop:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_PvpRewardPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpRewardPop:GeneratedPvpReward()
  local configInstance = ConfigManager:GetConfigInsByName("PVPNewRank")
  local pvpRankAll = configInstance:GetAll()
  local rewardList = {}
  for i, v in pairs(pvpRankAll) do
    local minStr = v.m_RankMin ~= 0 and v.m_RankMin or ""
    local maxStr = v.m_RankMax
    local rankName = string.format(ConfigManager:GetCommonTextById(100016), tostring(minStr), tostring(maxStr))
    if v.m_RankMin == 0 then
      rankName = tostring(maxStr)
    elseif v.m_RankMax > 999999 then
      rankName = string.format(ConfigManager:GetCommonTextById(100017), tostring(minStr))
    end
    rewardList[#rewardList + 1] = {
      ID = v.m_ID,
      rankName = rankName,
      dailyReward = v.m_DailyReward,
      seasonReward = v.m_SeasonReward
    }
  end
  
  local function sortFun(data1, data2)
    return data1.ID < data2.ID
  end
  
  table.sort(rewardList, sortFun)
  return rewardList
end

function Form_PvpRewardPop:refreshLoopScroll()
  local data = self:GeneratedPvpReward()
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scrollView
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
        local dailyClickIndex = 1
        if click_name == "m_item1" or click_name == "m_item2" or click_name == "m_item3" then
          local dailyReward = utils.changeCSArrayToLuaTable(cell_data.dailyReward)
          if click_name == "m_item1" then
            dailyClickIndex = 1
          end
          if click_name == "m_item2" then
            dailyClickIndex = 2
          end
          if click_name == "m_item3" then
            dailyClickIndex = 3
          end
          utils.openItemDetailPop({
            iID = dailyReward[dailyClickIndex][1],
            iNum = dailyReward[dailyClickIndex][2]
          })
        elseif click_name == "m_seasonitem1" or click_name == "m_seasonitem2" or click_name == "m_seasonitem3" then
          local seasonReward = utils.changeCSArrayToLuaTable(cell_data.seasonReward)
          if click_name == "m_seasonitem1" then
            dailyClickIndex = 1
          end
          if click_name == "m_seasonitem2" then
            dailyClickIndex = 2
          end
          if click_name == "m_seasonitem3" then
            dailyClickIndex = 3
          end
          utils.openItemDetailPop({
            iID = seasonReward[dailyClickIndex][1],
            iNum = seasonReward[dailyClickIndex][2]
          })
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_PvpRewardPop:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local dailyReward = utils.changeCSArrayToLuaTable(cell_data.dailyReward)
  local seasonReward = utils.changeCSArrayToLuaTable(cell_data.seasonReward)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank", cell_data.rankName)
  for i = 1, 3 do
    if dailyReward[i] then
      local m_icon_reward = UIUtil.findImage(transform, "pnl_item/m_item_dayreward/m_item" .. i .. "/m_txt_num" .. i .. "/m_icon_reward" .. i)
      ResourceUtil:CreatIconById(m_icon_reward, dailyReward[i][1])
      UIUtil.setTextMeshProText(transform, dailyReward[i][2], "pnl_item/m_item_dayreward/m_item" .. i .. "/m_txt_num" .. i)
    end
    UIUtil.setObjectVisible(transform, dailyReward[i] ~= nil, "pnl_item/m_item_dayreward/m_item" .. i)
    if seasonReward[i] then
      local m_icon_reward = UIUtil.findImage(transform, "pnl_item/m_item_seasonreward/m_seasonitem" .. i .. "/m_txt_seasonnum" .. i .. "/m_icon_seasonreward" .. i)
      ResourceUtil:CreatIconById(m_icon_reward, seasonReward[i][1])
      UIUtil.setTextMeshProText(transform, seasonReward[i][2], "pnl_item/m_item_seasonreward/m_seasonitem" .. i .. "/m_txt_seasonnum" .. i)
    end
    UIUtil.setObjectVisible(transform, seasonReward[i] ~= nil, "pnl_item/m_item_seasonreward/m_seasonitem" .. i)
  end
  local item_img_type = cell_data.ID % 2
  UIUtil.setObjectVisible(transform, item_img_type == 0, "pnl_item/m_img_type2")
  UIUtil.setObjectVisible(transform, 0 < item_img_type, "pnl_item/m_img_type1")
end

function Form_PvpRewardPop:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PVPREWARDPOP)
end

function Form_PvpRewardPop:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PVPREWARDPOP)
end

function Form_PvpRewardPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpRewardPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpRewardPop", Form_PvpRewardPop)
return Form_PvpRewardPop
