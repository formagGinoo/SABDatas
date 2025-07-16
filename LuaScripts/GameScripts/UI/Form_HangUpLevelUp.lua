local Form_HangUpLevelUp = class("Form_HangUpLevelUp", require("UI/UIFrames/Form_HangUpLevelUpUI"))
local AFKLevelConfigInstance = ConfigManager:GetConfigInsByName("AFKLevel")
local GlobalSettingsIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local AFK_SHOW_UNIT = GlobalSettingsIns:GetValue_ByName("AFKUnit").m_Value or ""
local COMMON_REWARD_UNIT_M = CommonTextIns:GetValue_ById(100008).m_mMessage
local COMMON_REWARD_UNIT_H = CommonTextIns:GetValue_ById(100010).m_mMessage
local OPEN_ANIM_NAME = "in"

function Form_HangUpLevelUp:SetInitParam(param)
end

function Form_HangUpLevelUp:AfterInit()
  self.super.AfterInit(self)
  self.m_rewardList = {}
  local initHangUpGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initHangUpGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
end

function Form_HangUpLevelUp:OnActive()
  local tParam = self.m_csui.m_param
  self.m_oldLv = tParam.oldLv
  self.m_newLv = tParam.newLv
  self.m_txt_old_lv_Text.text = self.m_oldLv
  self.m_txt_cur_lv_Text.text = self.m_newLv
  self.m_txt_award_num_Text.text = self.m_newLv
  self:RefreshListView()
  self:RefreshCommonReward()
  GlobalManagerIns:TriggerWwiseBGMState(25)
end

function Form_HangUpLevelUp:RefreshCommonReward()
  if self.m_oldLv == nil or self.m_oldLv == 0 then
    return
  end
  local oldLevelCfg = AFKLevelConfigInstance:GetValue_ByAFKLevel(self.m_oldLv)
  local newLevelCfg = AFKLevelConfigInstance:GetValue_ByAFKLevel(self.m_newLv)
  local starEffectMap = StargazingManager:GetCastleStarTechEffectByType(StargazingManager.CastleStarEffectType.HangUp)
  if newLevelCfg and newLevelCfg.m_Reward then
    local commonRewardList = utils.changeCSArrayToLuaTable(oldLevelCfg.m_Reward) or {}
    local newCommonRewardList = utils.changeCSArrayToLuaTable(newLevelCfg.m_Reward) or {}
    local unitList = string.split(AFK_SHOW_UNIT, ",") or {}
    for i = 1, 4 do
      local itemData = commonRewardList[i]
      local newItemData = newCommonRewardList[i]
      if itemData and newItemData then
        ResourceUtil:CreateItemIcon(self["m_icon" .. i .. "_Image"], itemData[1])
        local starEffect = ((starEffectMap[itemData[1]] or 0) + 100) / 100
        if self["m_txt_old_value" .. i .. "_Text"] and itemData[2] and itemData[3] then
          if unitList[i] == "2" then
            local count = itemData[2] * (3600 / itemData[3]) * starEffect
            self["m_txt_old_value" .. i .. "_Text"].text = string.format(COMMON_REWARD_UNIT_H, math.floor(count))
          else
            local count = itemData[2] * (60 / itemData[3]) * starEffect
            self["m_txt_old_value" .. i .. "_Text"].text = string.format(COMMON_REWARD_UNIT_M, math.floor(count))
          end
        end
        if self["m_txt_new_value" .. i .. "_Text"] and newItemData[2] and newItemData[3] then
          if unitList[i] == "2" then
            local count = newItemData[2] * (3600 / newItemData[3]) * starEffect
            self["m_txt_new_value" .. i .. "_Text"].text = string.format(COMMON_REWARD_UNIT_H, math.floor(count))
          else
            local count = newItemData[2] * (60 / newItemData[3]) * starEffect
            self["m_txt_new_value" .. i .. "_Text"].text = string.format(COMMON_REWARD_UNIT_M, math.floor(count))
          end
        end
      else
        log.error("AFKLevelConfig reward count error id = " .. tostring(self.m_newLv) .. "index = " .. i)
      end
    end
  else
    log.error("get AFKLevelConfig error id = " .. tostring(self.m_newLv))
  end
end

function Form_HangUpLevelUp:RefreshListView()
  local levelCfg = AFKLevelConfigInstance:GetValue_ByAFKLevel(self.m_newLv)
  if levelCfg then
    if levelCfg and levelCfg.m_LevelReward then
      self.m_reward_list:SetActive(true)
      self.m_rewardList = utils.changeCSArrayToLuaTable(levelCfg.m_LevelReward)
      local dataList = self:GeneratedListData()
      self.m_rewardListInfinityGrid:ShowItemList(dataList)
    else
      log.error("get AFKLevelConfig error id = " .. self.m_newLv)
    end
  else
    self.m_reward_list:SetActive(false)
  end
end

function Form_HangUpLevelUp:GeneratedListData()
  local dataList = {}
  for i, v in ipairs(self.m_rewardList) do
    local processData = ResourceUtil:GetProcessRewardData({
      iID = v[1],
      iNum = v[2]
    })
    if processData.data_type == ResourceUtil.RESOURCE_TYPE.EQUIPS then
      for m = 1, v[2] do
        dataList[#dataList + 1] = processData
      end
    else
      dataList[#dataList + 1] = processData
    end
  end
  return dataList
end

function Form_HangUpLevelUp:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_rewardList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData[1],
      iNum = chooseFJItemData[2]
    })
  end
end

function Form_HangUpLevelUp:ClearData()
  self.m_rewardList = {}
end

function Form_HangUpLevelUp:OnDestroy()
  self.super.OnDestroy(self)
  self:ClearData()
end

function Form_HangUpLevelUp:OnBtnCloseClicked()
  if UILuaHelper.IsAnimationPlaying(self.m_csui.m_uiGameObject) then
    UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, OPEN_ANIM_NAME, -1)
    return
  end
  self:CloseForm()
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_HangUpLevelUp:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_HangUpLevelUp", Form_HangUpLevelUp)
return Form_HangUpLevelUp
