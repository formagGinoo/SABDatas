local Form_GuildSign = class("Form_GuildSign", require("UI/UIFrames/Form_GuildSignUI"))

function Form_GuildSign:SetInitParam(param)
end

function Form_GuildSign:AfterInit()
  self.super.AfterInit(self)
  self.m_rewardList = {}
  for i = 1, 7 do
    self.m_rewardList[i] = {}
    local rootObj = self["m_pnl_item" .. i]
    self.m_rewardList[i].c_reward1 = rootObj.transform:Find("c_reward1").gameObject
    self.m_rewardList[i].c_reward2 = rootObj.transform:Find("c_reward2").gameObject
    self.m_rewardList[i].c_txt_day_Text = rootObj.transform:Find("c_txt_day1"):GetComponent(T_TextMeshProUGUI)
    self.m_rewardList[i].c_img_got = rootObj.transform:Find("c_img_got").gameObject
    self.m_rewardList[i].c_get_anim = rootObj.transform:Find("FX_ActivityLevel_get").gameObject
    self.m_rewardList[i].c_txt_unlock = rootObj.transform:Find("c_txt_unlock").gameObject
    local c_btn_touch = rootObj.transform:Find("c_btn_touch"):GetComponent(T_Button)
    c_btn_touch.onClick:RemoveAllListeners()
    c_btn_touch.onClick:AddListener(function()
      if self.OnSignUp then
        self:OnSignUp(i)
      end
    end)
  end
end

function Form_GuildSign:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
  self:AddEventListeners()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(210)
end

function Form_GuildSign:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildSign:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_Sign", handler(self, self.OnSignCB))
end

function Form_GuildSign:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildSign:OnSignCB(rewardList)
  if rewardList and next(rewardList) then
    utils.popUpRewardUI(rewardList)
  end
  self:RefreshUI()
end

function Form_GuildSign:RefreshUI()
  local cfgList = self:GetGuildSignCfg()
  for i = 1, 7 do
    local itemData = cfgList[i]
    local m_SignReward = itemData.m_SignReward
    local m_DailySignReward = itemData.m_DailySignReward
    if self.m_rewardList[i].dailySignReward == nil then
      self.m_rewardList[i].dailySignReward = self:createCommonItem(self.m_rewardList[i].c_reward1)
    end
    local processData = ResourceUtil:GetProcessRewardData({
      iID = tonumber(m_DailySignReward[0]),
      iNum = tonumber(m_DailySignReward[1])
    })
    self.m_rewardList[i].dailySignReward:SetItemInfo(processData)
    self.m_rewardList[i].dailySignReward:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnItemClick(itemID, itemNum, itemCom)
    end)
    if self.m_rewardList[i].signReward == nil then
      self.m_rewardList[i].signReward = self:createCommonItem(self.m_rewardList[i].c_reward2)
    end
    local processData2 = ResourceUtil:GetProcessRewardData({
      iID = tonumber(m_SignReward[0]),
      iNum = tonumber(m_SignReward[1])
    })
    self.m_rewardList[i].signReward:SetItemInfo(processData2)
    self.m_rewardList[i].signReward:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnItemClick(itemID, itemNum, itemCom)
    end)
    self.m_rewardList[i].c_txt_day_Text.text = itemData.m_SignName
    local day, time = GuildManager:GetGuildSignNum()
    local num = (day or 0) % 7
    if num and num < itemData.m_ID then
      self.m_rewardList[i].c_img_got:SetActive(false)
      local flag = TimeUtil:CheckTimeIsToDay(time)
      if not flag and num + 1 == i then
        self.m_rewardList[i].c_get_anim:SetActive(true)
        self.m_rewardList[i].c_txt_unlock:SetActive(false)
        self.m_rewardList[i].c_img_got:SetActive(false)
      elseif flag and num == 0 then
        self.m_rewardList[i].c_get_anim:SetActive(false)
        self.m_rewardList[i].c_img_got:SetActive(true)
        self.m_rewardList[i].c_txt_unlock:SetActive(false)
      else
        self.m_rewardList[i].c_txt_unlock:SetActive(true)
        self.m_rewardList[i].c_get_anim:SetActive(false)
        self.m_rewardList[i].c_img_got:SetActive(false)
      end
    else
      self.m_rewardList[i].c_img_got:SetActive(true)
      self.m_rewardList[i].c_get_anim:SetActive(false)
      self.m_rewardList[i].c_txt_unlock:SetActive(false)
    end
  end
end

function Form_GuildSign:OnItemClick(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function Form_GuildSign:GetGuildSignCfg()
  local cfgList = {}
  local GuildSignIns = ConfigManager:GetConfigInsByName("GuildSign")
  local cfgAll = GuildSignIns:GetAll()
  for i, v in pairs(cfgAll) do
    cfgList[#cfgList + 1] = v
  end
  return cfgList
end

function Form_GuildSign:OnSignUp(day)
  local signDay, time = GuildManager:GetGuildSignNum()
  local flag = TimeUtil:CheckTimeIsToDay(time)
  if not flag then
    GuildManager:ReqAllianceSignCS()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10241)
  end
end

function Form_GuildSign:IsOpenGuassianBlur()
  return true
end

function Form_GuildSign:OnBtnCloseClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDSIGN)
end

function Form_GuildSign:OnDestroy()
  self.super.OnDestroy(self)
  self.m_rewardList = nil
end

local fullscreen = true
ActiveLuaUI("Form_GuildSign", Form_GuildSign)
return Form_GuildSign
