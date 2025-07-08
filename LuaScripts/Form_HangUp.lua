local Form_HangUp = class("Form_HangUp", require("UI/UIFrames/Form_HangUpUI"))
local AFKLevelConfigInstance = ConfigManager:GetConfigInsByName("AFKLevel")
local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local AFK_LEVEL_CNT = tonumber(GlobalManagerIns:GetValue_ByName("AFKLevelCnt").m_Value) or 5
local AFK_STORAGE = tonumber(GlobalManagerIns:GetValue_ByName("AFKStorage").m_Value) or 36000
local AFK_REQUEST_INTERVAL = tonumber(GlobalManagerIns:GetValue_ByName("AFKRequestInterval").m_Value) or 5
local AFK_SHOW_UNIT = GlobalManagerIns:GetValue_ByName("AFKUnit").m_Value or ""
local COMMON_REWARD_UNIT_M = CommonTextIns:GetValue_ById(100008).m_mMessage
local COMMON_REWARD_UNIT_H = CommonTextIns:GetValue_ById(100010).m_mMessage
local PROGRESS_UNIT = CommonTextIns:GetValue_ById(100009).m_mMessage
local PreHangUpStr = "xq_"
local HangUpManager = _ENV.HangUpManager

function Form_HangUp:SetInitParam(param)
end

function Form_HangUp:AfterInit()
  self.super.AfterInit(self)
  self.curLevel = HangUpManager.m_iAfkLevel
  self.m_hangUpRewardList = HangUpManager.m_Reward
  self.stageLv = HangUpManager.m_iAfkExp
  self.receivedTime = HangUpManager.m_iTakeRewardTime
  self.commonRewardList = {}
  self.m_iTimeDurationOneSecond = 0
  self.m_iTimeTick = TimeUtil:GetServerTimeS() - self.receivedTime
  if self.m_iTimeTick >= AFK_STORAGE then
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(AFK_STORAGE)
  else
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick))
  end
  local progress = math.min(self.m_iTimeTick / AFK_STORAGE, 1)
  self.m_img_slider_a_Image.fillAmount = progress
  local num = math.floor(progress * 100)
  self.m_txt_customize_07_Text.text = string.format(PROGRESS_UNIT, num)
  self.m_FX_HangUp_Bar100:SetActive(1 <= progress)
  self:ShowHangUpBoxAnim(num)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnLvUpRewardItemClk)
  }
  self.m_levelRewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_level_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_levelRewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnLvUpRewardItemClk))
  local initHangUpGridData = {
    itemClkBackFun = handler(self, self.OnHungUpRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_hang_reward_list_InfinityGrid, "UICommonItem", initHangUpGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnHungUpRewardItemClk))
  self.m_commonRewardIdList = {}
  self.m_hangUpRealRewardList = {}
  self:CheckRegisterRedDot()
end

function Form_HangUp:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_common_redpoint, RedDotDefine.ModuleType.HangUpMain)
end

function Form_HangUp:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  if self.m_csui.m_param then
    self.m_csui.m_param = nil
  end
  self:RefreshUI()
  self:broadcastEvent("eGameEvent_Castle_OpenForm", {placeID = 3})
end

function Form_HangUp:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function Form_HangUp:AddEventListeners()
  self:addEventListener("eGameEvent_HangUp_GetReward", handler(self, self.OnEventHangUpRefreshUI))
  self:addEventListener("eGameEvent_HangUp_LevelChanged", handler(self, self.OnEventHangUpRefreshUI))
  self:addEventListener("eGameEvent_HangUp_Unlock", handler(self, self.OnEventHangUpRefreshUI))
end

function Form_HangUp:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HangUp:OnUpdate(dt)
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick + dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond + dt
  if self.m_iTimeTick >= AFK_STORAGE then
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(AFK_STORAGE)
    self.m_txt_customize_07_Text.text = string.format(PROGRESS_UNIT, 100)
    self.m_FX_HangUp_Bar100:SetActive(true)
    self.m_img_slider_a_Image.fillAmount = 1
    self:ShowHangUpBoxAnim(100)
  elseif self.m_iTimeDurationOneSecond >= 1 then
    self.m_iTimeDurationOneSecond = 0
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(math.floor(self.m_iTimeTick))
    local progress = math.min(self.m_iTimeTick / AFK_STORAGE, 1)
    self.m_img_slider_a_Image.fillAmount = progress
    local num = math.floor(progress * 100)
    self.m_txt_customize_07_Text.text = string.format(PROGRESS_UNIT, num)
    self:ShowHangUpBoxAnim(num)
  end
end

function Form_HangUp:ShowHangUpBoxAnim(progressNum)
  if self.m_hangUpProgressNum == progressNum then
    return
  end
  local showProgressNum = 0
  if 0 <= progressNum and progressNum < 25 then
    showProgressNum = 0
  elseif 25 <= progressNum and progressNum < 50 then
    showProgressNum = 25
  elseif 50 <= progressNum and progressNum < 75 then
    showProgressNum = 50
  elseif 75 <= progressNum and progressNum < 100 then
    showProgressNum = 75
  elseif 100 <= progressNum then
    showProgressNum = 100
  end
  UILuaHelper.SetActive(self.m_FX_HangUp_Bar100, 100 <= progressNum)
  UILuaHelper.SpinePlayAnimWithBack(self.m_spine_global, 0, PreHangUpStr .. showProgressNum, true, false)
  self.m_hangUpProgressNum = progressNum
end

function Form_HangUp:RefreshUI()
  self.curLevel = HangUpManager.m_iAfkLevel
  self.m_hangUpRewardList = HangUpManager.m_Reward
  self.stageLv = HangUpManager.m_iAfkExp
  self.receivedTime = HangUpManager.m_iTakeRewardTime
  self.m_iTimeTick = TimeUtil:GetServerTimeS() - self.receivedTime
  self.m_hangUpRealRewardList = self.m_hangUpRewardList
  self.m_txt_custom_Text.text = self.curLevel
  self.m_txt_lv_custom_02_Text.text = self.curLevel + 1
  self:RefreshCommonReward()
  self:RefreshLvUpReward()
  self:RefreshHangUpReward()
end

function Form_HangUp:RefreshCommonReward()
  self.m_commonRewardIdList = {}
  local starEffectMap = StargazingManager:GetCastleStarTechEffectByType(StargazingManager.CastleStarEffectType.HangUp)
  local levelCfg = AFKLevelConfigInstance:GetValue_ByAFKLevel(self.curLevel)
  if levelCfg and levelCfg.m_Reward then
    self.commonRewardList = utils.changeCSArrayToLuaTable(levelCfg.m_Reward)
    local unitList = string.split(AFK_SHOW_UNIT, ",") or {}
    for i = 1, 4 do
      local itemData = self.commonRewardList[i]
      if itemData then
        self.m_commonRewardIdList[#self.m_commonRewardIdList + 1] = itemData[1]
        ResourceUtil:CreateItemIcon(self["m_icon_item0" .. i .. "_Image"], itemData[1])
      else
        log.error("AFKLevelConfig reward count error id = " .. self.curLevel .. "index = " .. i)
      end
      if self["m_txt_customize_0" .. i .. "_Text"] and self.commonRewardList[i][2] and self.commonRewardList[i][3] then
        local starEffect = ((starEffectMap[itemData[1]] or 0) + 100) / 100
        if unitList[i] == "2" then
          local count = self.commonRewardList[i][2] * (3600 / self.commonRewardList[i][3]) * starEffect
          self["m_txt_customize_0" .. i .. "_Text"].text = string.format(COMMON_REWARD_UNIT_H, math.floor(count))
        else
          local count = self.commonRewardList[i][2] * (60 / self.commonRewardList[i][3]) * starEffect
          self["m_txt_customize_0" .. i .. "_Text"].text = string.format(COMMON_REWARD_UNIT_M, math.floor(count))
        end
      end
    end
  else
    log.error("get AFKLevelConfig error id = " .. self.curLevel)
  end
end

function Form_HangUp:RefreshLvUpReward()
  local nextLevelCfg = AFKLevelConfigInstance:GetValue_ByAFKLevel(self.curLevel + 1)
  if nextLevelCfg:GetError() then
    self.m_pnl_level_prompt:SetActive(false)
    self.m_z_txt_max_lv:SetActive(true)
  else
    self.m_pnl_level_prompt:SetActive(true)
    self.m_z_txt_max_lv:SetActive(false)
    local levelRewardList = utils.changeCSArrayToLuaTable(nextLevelCfg.m_LevelReward)
    self.m_levelRewardList = {}
    for i, v in ipairs(levelRewardList) do
      self.m_levelRewardList[#self.m_levelRewardList + 1] = ResourceUtil:GetProcessRewardData(v)
    end
    self:RefreshLvUpRewardList()
  end
  for i = 1, 5 do
    if i <= AFK_LEVEL_CNT then
      if self["m_icon_level_yes_0" .. i] then
        self["m_icon_level_yes_0" .. i]:SetActive(i <= self.stageLv)
      end
    elseif self["m_icon_level_yes_0" .. i] then
      self["m_icon_level_yes_0" .. i]:SetActive(false)
    end
  end
  self.m_slider_img_Image.fillAmount = math.max(self.stageLv - 1, 0) / (AFK_LEVEL_CNT - 1)
end

function Form_HangUp:RefreshHangUpReward()
  if #self.m_hangUpRewardList == 0 then
    self.m_pnl_no_gain:SetActive(true)
    self.m_hang_reward_list:SetActive(false)
  else
    self.m_pnl_no_gain:SetActive(false)
    self.m_hang_reward_list:SetActive(true)
    self:RefreshHangUpRewardList()
  end
  UILuaHelper.SetActive(self.m_common_redpoint_01, #self.m_hangUpRewardList > 0)
end

function Form_HangUp:OnEventHangUpRefreshUI()
  self:RefreshUI()
end

function Form_HangUp:OnDestroy()
  self.super.OnDestroy(self)
  self:ClearData()
end

function Form_HangUp:ClearData()
  self.commonRewardList = {}
end

function Form_HangUp:OnLvUpRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_levelRewardList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function Form_HangUp:OnHungUpRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_hangUpRealRewardList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function Form_HangUp:RefreshLvUpRewardList()
  self.m_levelRewardListInfinityGrid:ShowItemList(self.m_levelRewardList)
end

function Form_HangUp:RefreshHangUpRewardList()
  local dataList = self:GeneratedListData()
  self.m_hangUpRealRewardList = dataList
  self.m_rewardListInfinityGrid:ShowItemList(dataList)
  if 0 < #dataList then
    self.m_rewardListInfinityGrid:LocateTo(0)
  end
end

function Form_HangUp:OnShowContent(flag)
end

function Form_HangUp:GeneratedListData()
  local dataList = {}
  for i, v in ipairs(self.m_hangUpRewardList) do
    local processData = table.deepcopy(ResourceUtil:GetProcessRewardData({
      iID = v[1],
      iNum = v[2]
    }))
    local isCommonItem = table.indexof(self.m_commonRewardIdList, v[1])
    if processData.data_type == ResourceUtil.RESOURCE_TYPE.EQUIPS then
      for m = 1, v[2] do
        processData.hungUpSort = 3
        dataList[#dataList + 1] = processData
      end
    else
      processData.hungUpSort = isCommonItem ~= false and 1 or 2
      dataList[#dataList + 1] = processData
    end
  end
  dataList = EquipManager:EquipmentStacked(dataList)
  
  local function sortFun(data1, data2)
    if data1.hungUpSort == data2.hungUpSort then
      if data1.quality == data2.quality then
        return data1.data_id < data2.data_id
      else
        return data1.quality > data2.quality
      end
    else
      return data1.hungUpSort < data2.hungUpSort
    end
  end
  
  table.sort(dataList, sortFun)
  return dataList
end

function Form_HangUp:OnBtnitem01Clicked()
  self:ShowItem(self.commonRewardList[1])
end

function Form_HangUp:OnBtnitem02Clicked()
  self:ShowItem(self.commonRewardList[2])
end

function Form_HangUp:OnBtnitem03Clicked()
  self:ShowItem(self.commonRewardList[3])
end

function Form_HangUp:OnBtnitem04Clicked()
  self:ShowItem(self.commonRewardList[4])
end

function Form_HangUp:ShowItem(chooseFJItemData)
  if not chooseFJItemData then
  end
  utils.openItemDetailPop({
    iID = chooseFJItemData[1],
    iNum = 1
  })
end

function Form_HangUp:OnBtnillustrateClicked()
  utils.popUpDirectionsUI({tipsID = 1100})
end

function Form_HangUp:OnBtninstantClicked()
  local openFlag3 = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK)
  if openFlag3 then
    StackFlow:Push(UIDefines.ID_FORM_HANGUPBATTLE)
  end
end

function Form_HangUp:OnBtnreceiveClicked()
  self:HangUpRewardTips()
  if TimeUtil:GetServerTimeS() - tonumber(HangUpManager.m_iTakeRewardTime) > AFK_REQUEST_INTERVAL then
    HangUpManager:ReqTakeReward()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20010)
  end
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("HangUpVoice1")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
end

function Form_HangUp:OnBtnCloseClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HANGUP)
  self:broadcastEvent("eGameEvent_Castle_CloseForm", {placeID = 3})
end

function Form_HangUp:HangUpRewardTips()
  if ChannelManager:IsWindows() then
    return
  end
  if LocalDataManager:GetIntSimple("HangUpRewardTips1", 0) == 0 then
    LocalDataManager:SetIntSimple("HangUpRewardTips1", 1)
    if not PushNotificationManager:CheckPermission() then
      utils.CheckAndPushCommonTips({
        tipsID = 1184,
        func1 = function()
          PushNotificationManager:RequestPermission()
          StackTop:RemoveUIFromStack(UIDefines.ID_FORM_COMMONTIPS)
        end,
        func2 = function()
          StackTop:RemoveUIFromStack(UIDefines.ID_FORM_COMMONTIPS)
        end
      })
    end
  end
end

local fullscreen = true
ActiveLuaUI("Form_HangUp", Form_HangUp)
return Form_HangUp
