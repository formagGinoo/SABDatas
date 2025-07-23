local Form_HangUpBattle = class("Form_HangUpBattle", require("UI/UIFrames/Form_HangUpBattleUI"))
local AFKLevelConfigInstance = ConfigManager:GetConfigInsByName("AFKLevel")
local AFKInstantRewardConfigInstance = ConfigManager:GetConfigInsByName("AFKInstantReward")
local LongDownTriggerTime = 1
local HangUpManager = _ENV.HangUpManager

function Form_HangUpBattle:SetInitParam(param)
end

function Form_HangUpBattle:AfterInit()
  self.super.AfterInit(self)
  self.m_grayImgMaterial = self.m_img_gray_Image.material
  self.m_max_times = AFKInstantRewardConfigInstance:GetCount()
  self.m_rewardList = {}
  self.m_downTimer = nil
  self.m_cutDownTime = 0
  self.m_bIsInit = nil
  local initHangUpGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initHangUpGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
  self:createResourceBar(self.m_top_resource)
  self:CheckRegisterRedDot()
end

function Form_HangUpBattle:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_common_redpoint, RedDotDefine.ModuleType.HangUpBattle)
end

function Form_HangUpBattle:OnActive()
  self:AddEventListeners()
  self:RefreshUI()
  self:RefreshTime()
end

function Form_HangUpBattle:AddEventListeners()
  self:addEventListener("eGameEvent_HangUp_GetInstantRewards", handler(self, self.OnEventHangUpGetInstantRewards))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_HangUpBattle:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
  self:ClearData()
end

function Form_HangUpBattle:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HangUpBattle:RefreshTime()
  local resetTime = math.floor(TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()))
  self.m_cutDownTime = resetTime - TimeUtil:GetServerTimeS()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self:SetCutDownTxt()
  self.m_downTimer = TimeService:SetTimer(LongDownTriggerTime, -1, function()
    self.m_cutDownTime = self.m_cutDownTime - 1
    if self.m_cutDownTime < 0 then
      self:RefreshTime()
      return
    end
    self:SetCutDownTxt()
  end)
end

function Form_HangUpBattle:RefreshUI()
  self.m_iInstantTimes = HangUpManager.m_iInstantTimes + 1
  self.m_iAfkLevel = HangUpManager.m_iAfkLevel
  self.m_txt_countdown_03_Text.text = self.m_max_times - HangUpManager.m_iInstantTimes
  local instantRewardCfg = AFKInstantRewardConfigInstance:GetValue_ByTimes(self.m_iInstantTimes)
  self:RefreshListView()
  if not instantRewardCfg or self.m_max_times == HangUpManager.m_iInstantTimes then
    self.m_btn_fighting_02:SetActive(false)
    self.m_z_txt_received_max:SetActive(true)
    self.m_btn_fighting:SetActive(true)
    return
  end
  self.m_reward_list:SetActive(true)
  self.m_z_txt_received_max:SetActive(false)
  self.m_consumptionCfg = utils.changeCSArrayToLuaTable(instantRewardCfg.m_Consumption)
  if self.m_consumptionCfg and self.m_consumptionCfg[1] then
    local consumption = self.m_consumptionCfg[1][2]
    local curHaveNum = ItemManager:GetItemNum(self.m_consumptionCfg[1][1], true)
    if consumption == 0 then
      self.m_btn_fighting:SetActive(true)
      self.m_btn_fighting_02:SetActive(false)
    else
      self.m_btn_fighting:SetActive(false)
      self.m_btn_fighting_02:SetActive(true)
      self.m_txt_customize_02_Text.text = tostring(consumption)
      if consumption > curHaveNum then
        UILuaHelper.SetColor(self.m_txt_customize_02_Text, table.unpack(GlobalConfig.COMMON_COLOR.Red))
        self.m_btn_fighting_02_Image.material = self.m_grayImgMaterial
      else
        UILuaHelper.SetColor(self.m_txt_customize_02_Text, 84, 78, 71, 1)
        self.m_btn_fighting_02_Image.material = nil
      end
      ResourceUtil:CreateItemIcon(self.m_icon_power_resource_Image, self.m_consumptionCfg[1][1])
    end
  end
end

function Form_HangUpBattle:RefreshListView()
  self.m_rewardList = {}
  local levelCfg = AFKLevelConfigInstance:GetValue_ByAFKLevel(self.m_iAfkLevel)
  local instantRewardCfg = AFKInstantRewardConfigInstance:GetValue_ByTimes(self.m_iInstantTimes)
  local noCount = false
  if not instantRewardCfg then
    instantRewardCfg = AFKInstantRewardConfigInstance:GetValue_ByTimes(self.m_iInstantTimes - 1)
    noCount = true
  end
  if instantRewardCfg then
    if levelCfg and levelCfg.m_Reward then
      self.m_reward_list:SetActive(true)
      local time = instantRewardCfg.m_Reward
      local rewardCfg = utils.changeCSArrayToLuaTable(levelCfg.m_Reward)
      local starEffectMap = StargazingManager:GetCastleStarTechEffectByType(StargazingManager.CastleStarEffectType.HangUp)
      for i = 1, 4 do
        local starEffect = ((starEffectMap[rewardCfg[i][1]] or 0) + 100) / 100
        local count = noCount and 0 or math.floor(math.floor(rewardCfg[i][2] * starEffect) * (time / rewardCfg[i][3]))
        self.m_rewardList[#self.m_rewardList + 1] = ResourceUtil:GetProcessRewardData({
          rewardCfg[i][1],
          count
        })
      end
      self.m_rewardListInfinityGrid:ShowItemList(self.m_rewardList, true)
    else
      log.error("get AFKLevelConfig error id = " .. tostring(self.m_iAfkLevel))
    end
  else
    self.m_reward_list:SetActive(false)
  end
end

function Form_HangUpBattle:SetCutDownTxt()
  local day, hour, min, sec = utils.getTimeLayoutBySecond(self.m_cutDownTime)
  self.m_txt_time_Text.text = TimeUtil:TimeTableToFormatStrDHOrHMS({
    day = day,
    hour = hour,
    min = min,
    sec = sec
  })
end

function Form_HangUpBattle:OnEventHangUpGetInstantRewards()
  self:RefreshUI()
end

function Form_HangUpBattle:ClearData()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  self.m_rewardList = {}
  self.m_cutDownTime = 0
end

function Form_HangUpBattle:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_rewardList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function Form_HangUpBattle:OnBtnfightingClicked()
  if self.m_max_times == HangUpManager.m_iInstantTimes then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20009)
    return
  end
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("HangUpVoice2")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
  HangUpManager:ReqTakeInstant()
end

function Form_HangUpBattle:OnBtnfighting03Clicked()
  if self.m_max_times == HangUpManager.m_iInstantTimes then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20009)
    return
  end
  if self.m_consumptionCfg and self.m_consumptionCfg[1] then
    local consumption = self.m_consumptionCfg[1][2]
    local curHaveNum = ItemManager:GetItemNum(self.m_consumptionCfg[1][1], true)
    if consumption > curHaveNum then
      utils.CheckAndPushCommonTips({
        tipsID = 1222,
        func1 = function()
          QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
          StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HANGUPBATTLE)
        end
      })
      return
    end
  end
  utils.CheckAndPushCommonTips({
    tipsID = 1210,
    func1 = function()
      HangUpManager:ReqTakeInstant()
    end
  })
end

function Form_HangUpBattle:OnBtnCloseClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HANGUPBATTLE)
end

function Form_HangUpBattle:OnBtncancelClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HANGUPBATTLE)
end

function Form_HangUpBattle:OnBtnReturnClicked()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_HANGUPBATTLE)
end

function Form_HangUpBattle:OnDestroy()
  self.super.OnDestroy(self)
  self:ClearData()
end

function Form_HangUpBattle:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_HangUpBattle", Form_HangUpBattle)
return Form_HangUpBattle
