local UIItemBase = require("UI/Common/UIItemBase")
local ActEmbracebonusTaskItem = class("ActEmbracebonusTaskItem", UIItemBase)
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function ActEmbracebonusTaskItem:OnInit()
  self.m_itemWidgets = {}
  for i = 1, 5 do
    local commonItem = self["m_common_item" .. i]
    if commonItem then
      local itemWidget = self:createCommonItem(commonItem)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      self.m_itemWidgets[i] = itemWidget
    end
  end
  self.m_itemDataByUIType = {
    [1] = {
      taskDes = self.m_txt_task1_Text,
      itemObj = self.m_btn_item_task1,
      availableObj = self.m_pnl_available1,
      lockObj = self.m_pnl_locktask1,
      itemWidget01 = self.m_itemWidgets[1],
      itemWidget02 = self.m_itemWidgets[2],
      commonItem01 = self.m_common_item1,
      commonItem02 = self.m_common_item2,
      SSR01 = self.m_img_SSR1,
      SSR02 = self.m_img_SSR2,
      haveMask01 = self.m_img_mask_have1,
      haveMask02 = self.m_img_mask_have2,
      haveRewardFx01 = self.m_pnl_lght1,
      haveRewardFx02 = self.m_pnl_lght2
    },
    [2] = {
      taskDes = self.m_txt_task2_Text,
      itemObj = self.m_btn_item_task2,
      availableObj = self.m_pnl_available2,
      lockObj = self.m_pnl_locktask2,
      itemWidget01 = self.m_itemWidgets[3],
      itemWidget02 = self.m_itemWidgets[4],
      commonItem01 = self.m_common_item3,
      commonItem02 = self.m_common_item4,
      SSR01 = self.m_img_SSR3,
      SSR02 = self.m_img_SSR4,
      haveMask01 = self.m_img_mask_have3,
      haveMask02 = self.m_img_mask_have4,
      haveRewardFx01 = self.m_pnl_lght3,
      haveRewardFx02 = self.m_pnl_lght4
    },
    [3] = {
      taskDes = self.m_txt_task3_Text,
      itemObj = self.m_btn_item_task3,
      availableObj = self.m_pnl_available3,
      lockObj = self.m_pnl_locktask3,
      itemWidget01 = self.m_itemWidgets[5],
      itemWidget02 = self.m_itemWidgets[6],
      commonItem01 = self.m_common_item5,
      commonItem02 = self.m_common_item5,
      SSR01 = self.m_img_SSR5,
      SSR02 = self.m_img_SSR6,
      haveMask01 = self.m_img_mask_have5,
      haveMask02 = self.m_img_mask_have6,
      haveRewardFx01 = self.m_pnl_lght5,
      haveRewardFx02 = self.m_pnl_lght5
    }
  }
  self.m_list_item_InfinityGrid:RegisterBindCallback(handler(self, self.OnHeroItemBind))
end

function ActEmbracebonusTaskItem:OnFreshData()
  self.m_itemTaskData = self.m_itemData.questData
  self.m_stActivity = self.m_itemData.activity
  self.m_curQuestState = self.m_stActivity:GetQuestState(self.m_itemTaskData.iId)
  if not self.m_curQuestState then
    return
  end
  self.m_taskDes = self:GetTaskDescription()
  self.m_curUIType = self.m_itemTaskData.iUIType == 0 and 1 or self.m_itemTaskData.iUIType
  for type, item in pairs(self.m_itemDataByUIType) do
    UILuaHelper.SetActive(item.itemObj, self.m_curUIType == type)
  end
  self.m_rewardList = self.m_itemTaskData.vReward
  self.m_curItem = self.m_itemDataByUIType[self.m_curUIType]
  self.m_heroCfgList = {}
  self:FreshUIType()
end

function ActEmbracebonusTaskItem:FreshUIType()
  local questState = self.m_curQuestState.iState
  UILuaHelper.SetActive(self.m_curItem.availableObj, questState == TaskManager.TaskState.Finish)
  UILuaHelper.SetActive(self.m_curItem.lockObj, questState == TaskManager.TaskState.Completed)
  self.m_curItem.taskDes.text = self.m_taskDes
  self:FreshRewardItems()
  if self.m_curUIType == 3 then
    self:FreshTypeThree()
  end
end

function ActEmbracebonusTaskItem:GetTaskDescription()
  if not self.m_curQuestState then
    return ""
  end
  local force = self.m_curQuestState.vCondStep[1] or 0
  local multTaskDes = self.m_stActivity:getLangText(self.m_itemTaskData.sName)
  if self.m_curQuestState.vCondStep[1] then
    return string.format("%s(%d/%d)", multTaskDes, force, self.m_itemTaskData.iObjectiveCount)
  end
  return multTaskDes
end

function ActEmbracebonusTaskItem:FreshTypeThree()
  self:FreshHeroData()
  self:FreshHeroHead()
  self:FreshSubPanelSpine()
end

function ActEmbracebonusTaskItem:FreshSubPanelSpine()
  local chooseFJItemData = self.m_heroCfgList[self.m_curChooseIndex]
  if chooseFJItemData and self.m_itemInitData and self.m_itemInitData.heroHeadClicked then
    self.m_itemInitData.heroHeadClicked(chooseFJItemData.m_HeroID)
  end
end

function ActEmbracebonusTaskItem:FreshHeroData()
  local itemCfg = ItemManager:GetItemConfigById(self.m_rewardList[1].iID)
  local itemIdList = string.split(itemCfg.m_ItemUse, ";")
  self.m_heroCfgList = {}
  for _, v in pairs(itemIdList) do
    local heroId = tonumber(string.split(v, ",")[1])
    if heroId then
      local heroCfg = CharacterInfoIns:GetValue_ByHeroID(heroId)
      if not heroCfg:GetError() then
        table.insert(self.m_heroCfgList, heroCfg)
      end
    end
  end
end

function ActEmbracebonusTaskItem:FreshHeroHead()
  if self.m_heroCfgList and #self.m_heroCfgList > 0 then
    self.m_list_item_InfinityGrid:Clear()
    self.m_list_item_InfinityGrid.TotalItemCount = #self.m_heroCfgList
  end
end

function ActEmbracebonusTaskItem:FreshUIType()
  UILuaHelper.SetActive(self.m_curItem.availableObj, self.m_curQuestState.iState == TaskManager.TaskState.Finish)
  UILuaHelper.SetActive(self.m_curItem.lockObj, self.m_curQuestState.iState == TaskManager.TaskState.Completed)
  self.m_curItem.taskDes.text = self.m_taskDes
  self:FreshRewardItems()
  if self.m_curUIType == 3 then
    self:FreshTypeThree()
  end
  if self.m_curQuestState.iState == TaskManager.TaskState.Finish then
    local btn = self.m_curItem.itemObj:GetComponent(T_Button)
    UILuaHelper.BindButtonClickManual(btn, function()
      self.m_stActivity:RequestGetReward(self.m_itemTaskData.iId)
    end)
  end
end

function ActEmbracebonusTaskItem:FreshRewardItems()
  for i = 1, 2 do
    local commonItem = self.m_curItem["commonItem0" .. i]
    local itemWidget = self.m_curItem["itemWidget0" .. i]
    local ssr = self.m_curItem["SSR0" .. i]
    local haveMask = self.m_curItem["haveMask0" .. i]
    local reward = self.m_rewardList and self.m_rewardList[i]
    local haveRewardFx = self.m_curItem["haveRewardFx0" .. i]
    if not utils.isNull(commonItem) and not utils.isNull(itemWidget) then
      if reward then
        self:UpdateRewardDisplay(commonItem, itemWidget, ssr, reward, haveMask, self.m_curUIType, haveRewardFx)
      else
        UILuaHelper.SetActive(commonItem, false)
        UILuaHelper.SetActive(haveMask, false)
        UILuaHelper.SetActive(haveRewardFx, false)
        UILuaHelper.SetActive(ssr, false)
      end
    end
  end
end

function ActEmbracebonusTaskItem:UpdateRewardDisplay(commonItem, itemWidget, ssr, reward, haveMask, uiType, rewardFx)
  UILuaHelper.SetActive(commonItem, true)
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = tonumber(reward.iID),
    iNum = tonumber(reward.iNum)
  })
  itemWidget:SetItemInfo(processItemData)
  itemWidget:SetActive(true)
  UILuaHelper.SetActive(ssr, uiType ~= 1)
  UILuaHelper.SetActive(haveMask, self.m_curQuestState.iState == TaskManager.TaskState.Completed)
  UILuaHelper.SetActive(rewardFx, self.m_curQuestState.iState == TaskManager.TaskState.Finish)
end

function ActEmbracebonusTaskItem:OnHeroItemBind(templateCache, gameObject, index)
  local itemIndex = index + 1
  gameObject.name = itemIndex
  if not itemIndex then
    return
  end
  if not self.m_curChooseIndex then
    self.m_curChooseIndex = 1
  end
  local isSelect = itemIndex == self.m_curChooseIndex
  templateCache:GameObject("c_img_head_sel"):SetActive(isSelect)
  local chooseFJItemData = self.m_heroCfgList[itemIndex]
  if chooseFJItemData then
    local img_head = templateCache:GameObject("c_img_head")
    local mIcon = ResourceUtil:GetHeroIconPath(chooseFJItemData.m_HeroID, chooseFJItemData)
    local headImage = img_head:GetComponent("CircleImage")
    UILuaHelper.SetBaseImageAtlasSprite(headImage, mIcon)
    local btnEx = templateCache:GetComponent("ButtonExtensions")
    if btnEx then
      function btnEx.Clicked()
        self:OnHeroTabClick(itemIndex)
      end
    end
  end
end

function ActEmbracebonusTaskItem:OnHeroTabClick(index)
  if self.m_curChooseIndex == index then
    return
  end
  self.m_lastIndex = self.m_curChooseIndex
  self.m_curChooseIndex = index
  self.m_list_item_InfinityGrid:ReBindAll()
  self:FreshSubPanelSpine()
end

function ActEmbracebonusTaskItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return ActEmbracebonusTaskItem
