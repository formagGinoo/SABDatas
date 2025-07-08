local Form_RogueReward = class("Form_RogueReward", require("UI/UIFrames/Form_RogueRewardUI"))

function Form_RogueReward:SetInitParam(param)
end

function Form_RogueReward:AfterInit()
  self.super.AfterInit(self)
  self.m_levelID = nil
  self.m_curRewardCfgList = nil
  self.m_rogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_luaStageRewardInfinityGrid = self:CreateInfinityGrid(self.m_scrollView_InfinityGrid, "Rogue/UIRogueRewardItem")
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_rewardListInfinityGrid = self:CreateInfinityGrid(self.m_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self:RegisterRedDot()
end

function Form_RogueReward:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(35)
  self:AddEventListeners()
  self:ShowItemEnterAnim()
end

function Form_RogueReward:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_RogueReward:ShowItemEnterAnim()
  if self.m_luaStageRewardInfinityGrid then
    local list = self.m_luaStageRewardInfinityGrid:GetAllShownItemList()
    local index = 1
    for k, v in ipairs(list) do
      v:PlayEnterAnim(index)
      index = index + 1
    end
  end
end

function Form_RogueReward:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_btn_fx, RedDotDefine.ModuleType.RogueRewardBtnRedDot)
end

function Form_RogueReward:AddEventListeners()
  self:addEventListener("eGameEvent_RogueStage_TakeReward", handler(self, self.FreshUI))
end

function Form_RogueReward:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_RogueReward:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RogueReward:FreshData()
  self.m_curRewardCfgList = self.m_rogueStageHelper:GetRogueStageRewardCfgList() or {}
end

function Form_RogueReward:FreshUI()
  if not self.m_luaStageRewardInfinityGrid then
    return
  end
  local dataList = self:GenerateData()
  self.m_luaStageRewardInfinityGrid:ShowItemList(dataList)
  local curLevel = self.m_rogueStageHelper:GetDailyRewardLevel()
  self.m_luaStageRewardInfinityGrid:LocateTo(curLevel)
  self.m_key_num_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100074), curLevel)
  local curRewardCfg = self.m_rogueStageHelper:GetRogueStageRewardGroupCfgListByLv(curLevel)
  if curRewardCfg then
    UILuaHelper.SetAtlasSprite(self.m_img_key_icon_Image, curRewardCfg.m_KeyPic, function()
      if self and not utils.isNull(self.m_img_key_icon_Image) then
        self.m_img_key_icon_Image:SetNativeSize()
      end
    end)
  end
  local rewardList = self.m_rogueStageHelper:GetCurRogueStageRewards()
  local rewards = {}
  for i, v in ipairs(rewardList) do
    rewards[#rewards + 1] = ResourceUtil:GetProcessRewardData(v)
  end
  self.m_rewardListInfinityGrid:ShowItemList(rewards)
  self.m_btn_get:SetActive(table.getn(rewardList) > 0)
  self.m_btn_get_gary:SetActive(table.getn(rewardList) == 0)
  self.m_pnl_reward:SetActive(table.getn(rewardList) > 0)
  self.m_z_txt_noreward:SetActive(table.getn(rewardList) == 0)
end

function Form_RogueReward:GenerateData()
  local dataList = {}
  local taskLv = self.m_rogueStageHelper:GetTakenRewardLevel()
  local curLevel = self.m_rogueStageHelper:GetDailyRewardLevel()
  for i, v in ipairs(self.m_curRewardCfgList) do
    local state = 0
    if taskLv >= v.m_KeyLevel then
      state = 1
    elseif taskLv < v.m_KeyLevel and curLevel >= v.m_KeyLevel then
      state = 2
    else
      local stageId = self.m_rogueStageHelper:GetStageIdAndGearByKeyLevel(v.m_KeyLevel)
      if stageId then
        local flag = self.m_rogueStageHelper:IsLevelUnLock(stageId)
        state = flag and 3 or 4
      else
        state = 4
      end
    end
    dataList[#dataList + 1] = {
      cfg = v,
      state = state,
      curLevel = curLevel
    }
  end
  return dataList
end

function Form_RogueReward:OnItemClk(itemIndex, itemRootObj, itemIcon)
  utils.openItemDetailPop({
    iID = itemIcon.m_iItemID,
    iNum = 1
  })
end

function Form_RogueReward:OnBtngetClicked()
  RogueStageManager:ReqRogueTakeRewardCS()
end

function Form_RogueReward:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_RogueReward:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_RogueReward:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RogueReward", Form_RogueReward)
return Form_RogueReward
