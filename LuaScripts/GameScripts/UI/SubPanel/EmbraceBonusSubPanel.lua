local UISubPanelBase = require("UI/Common/UISubPanelBase")
local EmbraceBonusSubPanel = class("EmbraceBonusSubPanel", UISubPanelBase)
local iMaxCount = 3
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")

function EmbraceBonusSubPanel:OnInit()
  self.mComponents = {}
  for i = 1, iMaxCount do
    local trans = self["m_btn_item_task" .. i].transform
    if not utils.isNull(trans) then
      self.mComponents[i] = {
        taskDesc = self["m_txt_task" .. i .. "_Text"],
        btn = self["m_btn_item_task" .. i .. "_Button"],
        rewardItem = trans:Find("c_common_item" .. i).gameObject,
        isGet = self["m_pnl_locktask" .. i],
        isFinish = self["m_pnl_available" .. i]
      }
    end
  end
  self.m_MaskConfig = {
    [20390] = {
      self.m_pnl_masknova,
      self.m_pnl_masknovabg
    },
    [20450] = {
      self.m_pnl_maskhati
    },
    [20220] = {
      self.m_pnl_maskseth
    },
    [20480] = {
      self.m_pnl_maskmia
    }
  }
  self.m_curChooseIndex = nil
  self.m_list_item_InfinityGrid:RegisterBindCallback(handler(self, self.OnHeroItemBind))
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
end

function EmbraceBonusSubPanel:OnHeroItemBind(templateCache, gameObject, index)
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

function EmbraceBonusSubPanel:OnHeroTabClick(index)
  self.m_curChooseIndex = index
  if self.m_curChooseIndex == self.m_lastIndex then
    return
  end
  self.m_lastIndex = self.m_curChooseIndex
  self.m_list_item_InfinityGrid:ReBindAll()
  self:FreshShowSpine()
end

function EmbraceBonusSubPanel:FreshShowSpine()
  local chooseFJItemData = self.m_heroCfgList[self.m_curChooseIndex]
  if chooseFJItemData then
    if chooseFJItemData.m_Spine then
      self:LoadHeroSpine(chooseFJItemData.m_Spine)
      for i, maskCfg in pairs(self.m_MaskConfig) do
        for i, mask in pairs(maskCfg) do
          if not utils.isNull(mask) then
            UILuaHelper.SetActive(mask, false)
          end
        end
      end
      for i, maskCfg in pairs(self.m_MaskConfig) do
        if i == chooseFJItemData.m_HeroID then
          for i, mask in pairs(maskCfg) do
            if not utils.isNull(mask) then
              UILuaHelper.SetActive(mask, true)
            end
          end
          break
        end
      end
    end
    self.m_txt_name_Text.text = chooseFJItemData.m_mName
  end
end

function EmbraceBonusSubPanel:OnFreshData()
  self:RefreshData()
  self:RefreshUI()
end

function EmbraceBonusSubPanel:RefreshData()
  self.m_questListData = {}
  if self.m_curChooseIndex == nil then
    self.m_curChooseIndex = 1
  end
  local activityId = self.m_panelData.activity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  if not self.m_stActivity then
    return
  end
  local quest = {}
  quest = self.m_stActivity.m_stSdpConfig.mQuest
  local firstQuestId = self.m_stActivity:GetRedQuestId()
  for i, v in pairs(quest) do
    if tonumber(v.iId) ~= firstQuestId then
      self.m_questListData[#self.m_questListData + 1] = v
    else
      self.m_firstTaskData = v
    end
  end
  if #self.m_questListData >= 1 then
    table.sort(self.m_questListData, function(a, b)
      return a.iId < b.iId
    end)
  end
end

function EmbraceBonusSubPanel:RefreshUI()
  for i, v in ipairs(self.m_questListData) do
    local item = self.mComponents[i]
    if item then
      self:RefreshRewardItem(item, v, i)
    end
  end
  self:RefreshFirstReward()
  self:FreshShowSpine()
end

function EmbraceBonusSubPanel:RefreshFirstReward()
  if self.m_firstTaskData then
    local questState = self.m_stActivity:GetQuestState(self.m_firstTaskData.iId)
    if questState then
      self.m_reward_ring:SetActive(questState.iState == TaskManager.TaskState.Finish)
      self.m_pnl_gotreward:SetActive(questState.iState == TaskManager.TaskState.Completed)
    end
    self.m_txt_rewardnum_Text.text = self.m_firstTaskData.vReward[1].iNum
    UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, ItemManager:GetItemIconPathByID(self.m_firstTaskData.vReward[1].iID))
  end
end

function EmbraceBonusSubPanel:RefreshRewardItem(item, questInfo, index)
  local itemIcon = self:createCommonItem(item.rewardItem)
  local itemData = ResourceUtil:GetProcessRewardData({
    iID = questInfo.vReward[1].iID,
    iNum = questInfo.vReward[1].iNum
  })
  itemIcon:SetItemInfo(itemData)
  itemIcon:SetItemIconClickCB(handler(self, function()
    utils.openItemDetailPop({
      iID = questInfo.vReward[1].iID,
      iNum = questInfo.vReward[1].iNum
    })
  end))
  local questState = self.m_stActivity:GetQuestState(questInfo.iId)
  if questState then
    local force = questState.vCondStep[1] or 0
    local multTaskDes = self.m_stActivity:getLangText(questInfo.sName)
    if questState.vCondStep[1] then
      item.taskDesc.text = multTaskDes .. "(" .. force .. "/" .. questInfo.iObjectiveCount .. ")"
    else
      item.taskDesc.text = multTaskDes
    end
    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(function()
      if questState.iState == TaskManager.TaskState.Finish then
        self.m_stActivity:RequestGetReward(questInfo.iId, function(sc, stParam)
          local vReward = sc.vReward
          utils.popUpRewardUI(vReward)
          self:RefreshData()
          local questData = self.m_questListData[index]
          self:RefreshRewardItem(item, questData, index)
          self.m_parentLua:RefreshTableButtonList()
        end)
      elseif questState.iState == TaskManager.TaskState.Doing then
      end
    end)
    if questState.iState == TaskManager.TaskState.Finish then
      item.isGet:SetActive(false)
      item.isFinish:SetActive(true)
    elseif questState.iState == TaskManager.TaskState.Doing then
      item.isGet:SetActive(false)
      item.isFinish:SetActive(false)
    elseif questState.iState == TaskManager.TaskState.Completed then
      item.isGet:SetActive(true)
      item.isFinish:SetActive(false)
    end
  end
  if index and index == iMaxCount then
    self.m_heroCfgList = {}
    local itemCfg = ItemManager:GetItemConfigById(questInfo.vReward[1].iID)
    local itemIdList = string.split(itemCfg.m_ItemUse, ";")
    for _, v in pairs(itemIdList) do
      local iId = string.split(v, ",")
      if tonumber(iId[1]) then
        local heroCfg = CharacterInfoIns:GetValue_ByHeroID(tonumber(iId[1]))
        if not heroCfg:GetError() then
          self.m_heroCfgList[#self.m_heroCfgList + 1] = heroCfg
        end
      end
    end
    self.m_jumpId = questInfo.iJump
    self:RefreshLastRewardData()
  end
end

function EmbraceBonusSubPanel:RefreshLastRewardData()
  if self.m_heroCfgList and #self.m_heroCfgList > 0 then
    self.m_list_item_InfinityGrid:Clear()
    self.m_list_item_InfinityGrid.TotalItemCount = #self.m_heroCfgList
  end
end

function EmbraceBonusSubPanel:AddEventListeners()
end

function EmbraceBonusSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function EmbraceBonusSubPanel:OnLevelAwardUpdate()
  self.m_parentLua:RefreshTableButtonList()
end

function EmbraceBonusSubPanel:OnBtnsearchClicked()
  local characterCfg = self.m_heroCfgList[self.m_curChooseIndex]
  StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
    heroID = characterCfg.m_HeroID
  })
end

function EmbraceBonusSubPanel:OnBtngoClicked()
  if self.m_jumpId then
    QuickOpenFuncUtil:OpenFunc(self.m_jumpId)
  end
end

function EmbraceBonusSubPanel:LoadHeroSpine(prefabName)
  if not prefabName then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.ActivityGacha
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(prefabName, typeStr, self.m_root_role, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    self:CheckShowSpineAnim()
  end)
end

function EmbraceBonusSubPanel:CheckShowSpineAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpineObj = self.m_curHeroSpineObj.spineObj
  if utils.isNull(heroSpineObj) then
    log.error("Form_HeroShow CheckShowSpineAnim is error ")
    return
  end
  if UILuaHelper.CheckIsHaveSpineAnim(heroSpineObj, "idle2") then
    UILuaHelper.SpinePlayAnim(heroSpineObj, 0, "idle2", true)
  else
    UILuaHelper.SpinePlayAnim(heroSpineObj, 0, "idle", true)
  end
end

function EmbraceBonusSubPanel:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function EmbraceBonusSubPanel:OnBtnrewardClicked()
  local questState = self.m_stActivity:GetQuestState(self.m_firstTaskData.iId)
  if questState and questState.iState == TaskManager.TaskState.Finish then
    self.m_stActivity:RequestGetReward(self.m_firstTaskData.iId, function(sc, stParam)
      local vReward = sc.vReward
      utils.popUpRewardUI(vReward)
      self:RefreshData()
      self:RefreshFirstReward()
      self.m_parentLua:RefreshTableButtonList()
    end)
  end
end

function EmbraceBonusSubPanel:GetDownloadResourceExtra(param)
  local vPackage = {}
  local vResourceExtra = {}
  local actCur
  local activityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_LevelAward)
  for i, act in pairs(activityList) do
    if act:getSubPanelName() == ActivityManager.ActivitySubPanelName.ActivitySPName_EmbraceBonusActivity then
      actCur = act
      break
    end
  end
  if not actCur then
    return
  end
  local quest = {}
  local m_questListData = {}
  quest = actCur.m_stSdpConfig.mQuest
  local firstQuestId = actCur:GetRedQuestId()
  for i, v in pairs(quest) do
    if tonumber(v.iId) ~= firstQuestId then
      m_questListData[#m_questListData + 1] = v
    end
  end
  if 1 <= #m_questListData then
    table.sort(m_questListData, function(a, b)
      return a.iId < b.iId
    end)
  end
  local curQuest = m_questListData[3]
  local heroCfgList = {}
  if curQuest then
    local itemCfg = ItemManager:GetItemConfigById(curQuest.vReward[1].iID)
    local itemIdList = string.split(itemCfg.m_ItemUse, ";")
    for _, v in pairs(itemIdList) do
      local iId = string.split(v, ",")
      if tonumber(iId[1]) then
        local heroCfg = CharacterInfoIns:GetValue_ByHeroID(tonumber(iId[1]))
        if not heroCfg:GetError() then
          heroCfgList[#heroCfgList + 1] = heroCfg
        end
      end
    end
  end
  for i, v in pairs(heroCfgList) do
    local spineStr = v.m_Spine
    if spineStr then
      vResourceExtra[#vResourceExtra + 1] = {
        sName = spineStr,
        eType = DownloadManager.ResourceType.UI
      }
    end
  end
  return vPackage, vResourceExtra
end

function EmbraceBonusSubPanel:OnInactive()
  self:CheckRecycleSpine(true)
end

return EmbraceBonusSubPanel
