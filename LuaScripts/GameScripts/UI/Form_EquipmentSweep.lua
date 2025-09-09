local Form_EquipmentSweep = class("Form_EquipmentSweep", require("UI/UIFrames/Form_EquipmentSweepUI"))

function Form_EquipmentSweep:SetInitParam(param)
end

function Form_EquipmentSweep:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnDungeonRewardItemClick)
  }
  self.m_stageRewardInfinityGrid = self:CreateInfinityGrid(self.m_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_stageRewardInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnDungeonRewardItemClick))
  self.m_dungeonStageRewardList = {}
  self.m_widgetNumStepper = self:createNumStepper(self.m_common_stepper)
end

function Form_EquipmentSweep:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curLevelID = tParam.levelID
  self.m_curStageIndex = tParam.stageIndex or 1
  self.m_curDungeonChapterCfg = tParam.curDungeonChapterCfg
  self.m_equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  self.m_curDungeonLevelPhaseCfgList = self.m_equipmentHelper:GetDungeonLevelPhaseCfgListByID(self.m_curLevelID)
  self.m_iNumCur = 0
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_EquipmentSweep:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_EquipmentSweep:AddEventListeners()
  self:addEventListener("eGameEvent_Level_MopUp", handler(self, self.OnLevelMopUp))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
  self:addEventListener("eGameEvent_Level_DailyReset", handler(self, self.OnBtnCloseClicked))
end

function Form_EquipmentSweep:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipmentSweep:OnLevelMopUp(param)
  local levelType = param.levelType
  local vMopReward = param.vMopReward
  if levelType == LevelManager.LevelType.Dungeon then
    StackPopup:Push(UIDefines.ID_FORM_EQUIPMENTSWEEPREWARD, {vMopReward = vMopReward})
  end
  self:OnBtnCloseClicked()
end

function Form_EquipmentSweep:RefreshUI()
  self:FreshStageInfoShow()
  self:FreshRewardList()
  local maxUseTimes = self.m_equipmentHelper:GetChallengeDailyNum()
  local curUseTimes = self.m_equipmentHelper:GetLevelDailyData()
  local leftTimes = maxUseTimes - curUseTimes
  local num = math.max(1, leftTimes)
  self.m_widgetNumStepper:SetNumShowMax(false)
  self.m_widgetNumStepper:SetNumMax(leftTimes)
  self.m_widgetNumStepper:SetNumCur(num)
  self.m_widgetNumStepper:SetNumChangeCB(handler(self, self.OnNumStepperChange))
  self.m_sweep_num_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(10010), leftTimes)
  self.m_iNumCur = num
end

function Form_EquipmentSweep:OnNumStepperChange(iNumCur, iNumChange, sTag)
  self.m_iNumCur = iNumCur
end

function Form_EquipmentSweep:FreshRewardList()
  if not self.m_curDungeonLevelPhaseCfgList then
    return
  end
  local maxPhaseCfg = self.m_curDungeonLevelPhaseCfgList[self.m_curStageIndex]
  if not maxPhaseCfg then
    return
  end
  local rewardList = utils.changeCSArrayToLuaTable(maxPhaseCfg.m_ClientMustDrop)
  local proRewardList = utils.changeCSArrayToLuaTable(maxPhaseCfg.m_ClientProDrop)
  local rewardTab = {}
  local customDataTab = {}
  for i, v in ipairs(proRewardList) do
    rewardTab[#rewardTab + 1] = {
      v[1],
      1
    }
    customDataTab[#customDataTab + 1] = {
      percentage = v[2]
    }
  end
  for i, v in ipairs(rewardList) do
    customDataTab[#customDataTab + 1] = {percentage = 100}
  end
  table.insertto(rewardTab, rewardList)
  local effectList = StargazingManager:GetCastleStarTechEffectByType(StargazingManager.CastleStarEffectType.Boss)
  if table.getn(effectList) > 0 and self.m_curDungeonChapterCfg then
    local randomPoolId = 0
    local starTechEffectTab = {}
    for i, v in ipairs(effectList) do
      for m, n in ipairs(v) do
        if n[1] == self.m_curDungeonChapterCfg.m_LevelSubType then
          randomPoolId = n[2]
        end
      end
    end
    if randomPoolId ~= 0 then
      local starTechEffect = ItemManager:GetItemRandomPoolContentById(randomPoolId)
      for i, v in ipairs(starTechEffect) do
        starTechEffectTab[#starTechEffectTab + 1] = {
          v.iID,
          v.iNum
        }
        customDataTab[#customDataTab + 1] = {
          percentage = math.floor(v.iWeight * 100),
          starTechEffect = true
        }
      end
      if table.getn(starTechEffectTab) > 0 then
        table.insertto(rewardTab, starTechEffectTab)
      end
    end
  end
  self.m_dungeonStageRewardList = rewardTab
  local dataList = {}
  for i, v in ipairs(rewardTab) do
    local processData = ResourceUtil:GetProcessRewardData({
      iID = v[1],
      iNum = v[2]
    }, customDataTab[i])
    dataList[#dataList + 1] = processData
  end
  self.m_stageRewardInfinityGrid:ShowItemList(dataList)
end

function Form_EquipmentSweep:FreshStageInfoShow()
  if not self.m_curDungeonLevelPhaseCfgList then
    return
  end
  if self.m_curStageIndex > 0 then
    local tempPhaseCfg = self.m_curDungeonLevelPhaseCfgList[self.m_curStageIndex]
    if tempPhaseCfg then
      self.m_txt_content_Text.text = UIUtil:ArabToRomaNum(tempPhaseCfg.m_Phase)
    end
  end
  for i = 1, self.m_uiVariables.MaxStageNum do
    local tempPhaseCfg = self.m_curDungeonLevelPhaseCfgList[i]
    UILuaHelper.SetActive(self["m_pnl_point" .. i], tempPhaseCfg ~= nil)
    if tempPhaseCfg then
      UILuaHelper.SetActive(self["m_point_finish" .. i], i < self.m_curStageIndex)
      UILuaHelper.SetActive(self["m_point_now" .. i], self.m_curStageIndex == i)
      if i < self.m_uiVariables.MaxStageNum then
        self["m_point_slider" .. i .. "_Image"].fillAmount = i < self.m_curStageIndex and 1 or 0
      end
    end
  end
end

function Form_EquipmentSweep:OnDungeonRewardItemClick(index, itemObj)
  local reward = self.m_dungeonStageRewardList[index + 1]
  if reward then
    utils.openItemDetailPop({
      iID = reward[1],
      iNum = ItemManager:GetItemNum(reward[1])
    })
  end
end

function Form_EquipmentSweep:OnBtnyesClicked()
  local maxUseTimes = self.m_equipmentHelper:GetChallengeDailyNum()
  local curUseTimes = self.m_equipmentHelper:GetLevelDailyData()
  local leftTimes = maxUseTimes - curUseTimes
  if leftTimes < self.m_iNumCur then
    return
  end
  LevelManager:ReqStageMopUp(LevelManager.LevelType.Dungeon, self.m_curLevelID, self.m_iNumCur)
end

function Form_EquipmentSweep:OnBtnnoClicked()
  self:CloseForm()
end

function Form_EquipmentSweep:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_EquipmentSweep:IsOpenGuassianBlur()
  return true
end

function Form_EquipmentSweep:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_EquipmentSweep", Form_EquipmentSweep)
return Form_EquipmentSweep
