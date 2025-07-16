local UIItemBase = require("UI/Common/UIItemBase")
local CliveActivityTipsItem = class("CliveActivityTipsItem", UIItemBase)
local ItemType = {
  BigTip_BigClive = 1,
  BigTip_SmallClive = 2,
  SmallTip_BigClive = 3,
  SmallTip_SmallClive = 4
}

function CliveActivityTipsItem:CreateCliveActivityTipsItem(object, data)
  return CliveActivityTipsItem.new(nil, object, data)
end

function CliveActivityTipsItem:OnInit()
  self.allQuestFinish = false
  self.curQuestIndex = 0
  self:InitTipItemData()
end

function CliveActivityTipsItem:OnFreshData()
  self:FreshData()
end

function CliveActivityTipsItem:OnDestroy()
  CliveActivityTipsItem.super.OnDestroy(self)
end

function CliveActivityTipsItem:InitTipItemData()
  if self.m_itemInitData then
    self:CacheNodes()
    for _, node in pairs(self.nodes) do
      node:SetActive(false)
    end
    local activityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_LevelAward)
    self.activity = {}
    self.clientCfg = {}
    self.selfQuestList = {}
    local allQuestList = {}
    local selfQuestIDList = {}
    for _, v in ipairs(activityList) do
      if v:checkCondition(true) and v.m_clientCfg and v.m_clientCfg.iShowType == 3 then
        self.activity = v
        self.clientCfg = v:GetClientCfg()
        allQuestList = v:GetQuestList()
        break
      end
    end
    local tipType = self.m_itemInitData.tipType
    if self.clientCfg and self.clientCfg.vHeroConfig then
      for _, heroConfig in pairs(self.clientCfg.vHeroConfig) do
        if self.m_itemInitData.cliveType == heroConfig.iOrder then
          selfQuestIDList = string.split(heroConfig.vUseQuestId, ";")
          self:SetDesc(tipType, heroConfig)
          break
        end
      end
    end
    if allQuestList and 0 < #allQuestList and selfQuestIDList and 0 < #selfQuestIDList then
      for _, questMsg in pairs(allQuestList) do
        for _, questId in pairs(selfQuestIDList) do
          if questMsg.iId == tonumber(questId) then
            table.insert(self.selfQuestList, questMsg)
            break
          end
        end
      end
      if tipType == ItemType.BigTip_BigClive then
        self.nodes.m_pnl_Clive_big:SetActive(true)
        self.nodes.m_img_hero01:SetActive(true)
      elseif tipType == ItemType.BigTip_SmallClive then
        self.nodes.m_pnl_Clive_big:SetActive(true)
        self.nodes.m_img_hero02:SetActive(true)
      elseif tipType == ItemType.SmallTip_BigClive then
        self.nodes.m_pnl_Clive_small:SetActive(true)
        self.nodes.m_img_hero03:SetActive(true)
      elseif tipType == ItemType.SmallTip_SmallClive then
        self.nodes.m_pnl_Clive_small:SetActive(true)
        self.nodes.m_img_hero04:SetActive(true)
      end
    end
  end
end

function CliveActivityTipsItem:SetDesc(tipType, heroConfig)
  local text = ""
  self.configTextDesc = nil
  if tipType <= ItemType.BigTip_SmallClive then
    text = self.activity:getLangText(heroConfig.sInsideDesc)
    self.taskTexts.m_txt_task02_Text.text = text
    self.configTextDesc = heroConfig.sInsideDesc
  else
    text = self.activity:getLangText(heroConfig.sOutsideDesc)
    self.taskTexts.m_txt_task03_Text.text = text
    self.configTextDesc = heroConfig.sOutsideDesc
  end
end

function CliveActivityTipsItem:FreshData()
  if self.activity and self.activity.CheckActivityIsOpen then
    if self.activity:CheckActivityIsOpen() then
      self.m_itemRootObj:SetActive(true)
      local completedCount = 0
      self.nodes.m_img_bg_reward:SetActive(false)
      self.canGetReward = false
      for index, quest in pairs(self.selfQuestList) do
        self.taskTexts.m_txt_task01_Text.text = quest.sName
        local questState = self.activity:GetQuestState(quest.iId)
        if questState then
          if questState.iState == TaskManager.TaskState.Doing then
            break
          end
          if questState.iState == TaskManager.TaskState.Finish then
            self.curQuestIndex = index
            self.nodes.m_img_bg_reward:SetActive(true)
            self.canGetReward = true
            break
          elseif questState.iState == TaskManager.TaskState.Completed then
            completedCount = completedCount + 1
          end
        end
      end
      if string.IsNullOrEmpty(self.taskTexts.m_txt_task03_Text.text) then
        local text = self.activity:getLangText(self.configTextDesc)
        self.taskTexts.m_txt_task03_Text.text = text
      end
      if completedCount == #self.selfQuestList then
        self.m_itemRootObj:SetActive(false)
      end
    else
      self.m_itemRootObj:SetActive(false)
    end
  else
    self.m_itemRootObj:SetActive(false)
  end
end

function CliveActivityTipsItem:OnClick()
  if self.canGetReward then
    local curQuest = self.selfQuestList[self.curQuestIndex]
    self.activity:RequestGetReward(curQuest.iId, function(sc, msg)
      self.activity:OnRequestGetRewardSC(sc, nil)
      self:OnFreshData()
    end)
  else
    local activityId = self.activity:getID()
    local uiInfo = StackFlow:GetUIInstanceLua(UIDefines.ID_FORM_ACTIVITYMAIN)
    if uiInfo and uiInfo.m_csui and uiInfo:IsActive() then
      uiInfo:ChooseActivityByID(activityId)
      uiInfo:GetActivitySubPanel(activityId).subPanelLua:OnClickTab(self.m_itemInitData.cliveType)
    else
      StackFlow:Push(UIDefines.ID_FORM_ACTIVITYMAIN, {
        activityId = activityId,
        cliveType = self.m_itemInitData.cliveType
      })
    end
  end
end

function CliveActivityTipsItem:CacheNodes()
  self.nodes = {
    m_pnl_Clive_big = self.m_itemRootObj.transform:Find("m_pnl_Clive_big").gameObject,
    m_pnl_Clive_small = self.m_itemRootObj.transform:Find("m_pnl_Clive_small").gameObject,
    m_img_hero01 = self.m_itemRootObj.transform:Find("m_pnl_Clive_big/pnl_left/img_bg_headbox/img_herobg/m_img_hero01").gameObject,
    m_img_hero02 = self.m_itemRootObj.transform:Find("m_pnl_Clive_big/pnl_left/img_bg_headbox/img_herobg/m_img_hero02").gameObject,
    m_img_hero03 = self.m_itemRootObj.transform:Find("m_pnl_Clive_small/img_bg_headbox/img_herobg/m_img_hero03").gameObject,
    m_img_hero04 = self.m_itemRootObj.transform:Find("m_pnl_Clive_small/img_bg_headbox/img_herobg/m_img_hero04").gameObject,
    m_img_bg_reward = self.m_itemRootObj.transform:Find("m_pnl_Clive_big/m_img_bg_reward").gameObject
  }
  self.taskTexts = {
    m_txt_task01_Text = self.m_itemRootObj.transform:Find("m_pnl_Clive_big/pnl_left/img_txt_pnl/m_txt_task01"):GetComponent("TextMeshProUGUI"),
    m_txt_task02_Text = self.m_itemRootObj.transform:Find("m_pnl_Clive_big/pnl_left/img_txt_pnl/m_txt_task02"):GetComponent("TextMeshProUGUI"),
    m_txt_task03_Text = self.m_itemRootObj.transform:Find("m_pnl_Clive_small/img_txt_pnl/m_txt_task03"):GetComponent("TextMeshProUGUI")
  }
end

return CliveActivityTipsItem
