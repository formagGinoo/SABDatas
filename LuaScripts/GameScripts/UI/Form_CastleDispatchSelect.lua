local Form_CastleDispatchSelect = class("Form_CastleDispatchSelect", require("UI/UIFrames/Form_CastleDispatchSelectUI"))

function Form_CastleDispatchSelect:SetInitParam(param)
end

function Form_CastleDispatchSelect:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1174)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_heroListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_hero_list_InfinityGrid, "UIHeroListCommonItem", initGridData)
  self.m_heroListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnItemClk))
  local initHangUpGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initHangUpGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
  self.m_hero_item:SetActive(false)
end

function Form_CastleDispatchSelect:OnActive()
  self.super.OnActive(self)
  local data = self.m_csui.m_param
  self.m_dispatchEvent = data.event
  self.m_dispatchLocation = data.id
  if not self.m_dispatchEvent then
    log.error("Form_CastleDispatchSelect is error serverData is nil")
    return
  end
  self.m_selItemIndex = 1
  self.m_rewardList = {}
  self.m_chooseHeroList = {}
  self.m_obj_list = {}
  self.m_heroConditionTab = {}
  self:DestroyItem()
  self:RefreshConditionItems()
  self:RefreshUI()
  self:AddEventListeners()
  self.playingVoice = ""
  CS.GlobalManager.Instance:TriggerWwiseBGMState(201)
end

function Form_CastleDispatchSelect:OnInactive()
  self.super.OnInactive(self)
  for i, v in pairs(self.m_chooseHeroList) do
    if self.m_chooseHeroList[i] then
      local oldIndex = self.m_chooseHeroList[i].index
      self.m_heroListInfinityGrid:OnChooseItem(oldIndex, false)
    end
  end
  self.m_selItemIndex = 1
  self.m_chooseHeroList = {}
  self.m_heroConditionTab = {}
  self:DestroyItem()
  self:RemoveAllEventListeners()
  if self.playingVoice then
    CS.UI.UILuaHelper.StopPlaySFX(self.playingVoice)
  end
end

function Form_CastleDispatchSelect:AddEventListeners()
  self:addEventListener("eGameEvent_CastleDoDispatch", handler(self, self.OnBackClk))
  self:addEventListener("eGameEvent_CastleDispatchRefresh", handler(self, self.OnBackClk))
end

function Form_CastleDispatchSelect:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CastleDispatchSelect:DestroyItem()
  if self.m_obj_list and table.getn(self.m_obj_list) > 0 then
    for i = table.getn(self.m_obj_list), 1, -1 do
      if self.m_obj_list[i] then
        CS.UnityEngine.GameObject.Destroy(self.m_obj_list[i])
        self.m_obj_list[i] = nil
      end
    end
  end
  self.m_obj_list = {}
end

function Form_CastleDispatchSelect:GuideSortHero(heroID)
  for i, v in ipairs(self.m_heroList) do
    if v.serverData.iHeroId == heroID then
      self.m_heroList[i] = self.m_heroList[1]
      self.m_heroList[1] = v
      break
    end
  end
  self.m_heroListInfinityGrid:ShowItemList(self.m_heroList)
  UILuaHelper.SetActive(self.m_list_empty, table.getn(self.m_heroList) == 0)
end

function Form_CastleDispatchSelect:RefreshUI()
  local eventCfg = CastleDispatchManager:GetCastleDispatchEventCfg(self.m_dispatchEvent.iGroupId, self.m_dispatchEvent.iEventId)
  if eventCfg then
    local rewardList = utils.changeCSArrayToLuaTable(eventCfg.m_Reward)
    for i, v in ipairs(rewardList) do
      local reward = ResourceUtil:GetProcessRewardData(v)
      self.m_rewardList[#self.m_rewardList + 1] = reward
    end
    self.m_rewardListInfinityGrid:ShowItemList(self.m_rewardList)
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(eventCfg.m_TimeMin * 60)
    for i = 1, 5 do
      self["m_star" .. i]:SetActive(i <= eventCfg.m_Grade)
    end
  end
  local locationCfg = CastleDispatchManager:GetCastleDispatchLocationCfg(self.m_dispatchLocation)
  if locationCfg then
    self.m_txt_name_Text.text = locationCfg.m_mDispatchLocation
    self.m_txt_des_Text.text = locationCfg.m_mLocationDes
    self.m_scroll_view:GetComponent("ScrollRect").normalizedPosition = CS.UnityEngine.Vector2(0, 1)
  end
  local auto = CastleDispatchManager:CheckAutoDispatchIsUnlock()
  self.m_btn_auto_gray:SetActive(not auto)
  self.m_btn_auto:SetActive(auto)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_txt_des)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_scroll_view)
end

function Form_CastleDispatchSelect:RefreshConditionItems()
  self.m_heroConditionTab = self:GenerateCardCondition()
  local excludeHero = self:GetExcludeHeroList(self.m_selItemIndex)
  self.m_heroList = CastleDispatchManager:FilterHeroByCondition(self.m_heroConditionTab[self.m_selItemIndex], excludeHero)
  self:CreatCardConditionItem(self.m_heroConditionTab)
  self:RefreshConditionItem()
  self.m_heroListInfinityGrid:ShowItemList(self.m_heroList)
  UILuaHelper.SetActive(self.m_list_empty, table.getn(self.m_heroList) == 0)
  if table.getn(self.m_heroList) > 0 then
    self.m_heroListInfinityGrid:LocateTo(0)
  end
  self:GenerateChooseHero()
  for i, v in pairs(self.m_chooseHeroList) do
    if self.m_chooseHeroList[i] then
      self.m_heroListInfinityGrid:OnChooseItem(self.m_chooseHeroList[i].index, true)
    end
  end
  self.m_btn_confirm:SetActive(self:isConcludeCondition())
  self.m_btn_confirm_gray:SetActive(not self:isConcludeCondition())
end

function Form_CastleDispatchSelect:RefreshAutoUI()
  if self.m_chooseHeroList[self.m_selItemIndex] then
    local excludeHero = self:GetExcludeHeroList(self.m_selItemIndex)
    self.m_heroList = CastleDispatchManager:FilterHeroByCondition(self.m_heroConditionTab[self.m_selItemIndex], excludeHero)
    self.m_heroListInfinityGrid:ShowItemList(self.m_heroList)
    UILuaHelper.SetActive(self.m_list_empty, table.getn(self.m_heroList) == 0)
    self.m_heroListInfinityGrid:OnChooseItem(self.m_chooseHeroList[self.m_selItemIndex].index, true)
    if self.m_chooseHeroList[1] then
      local heroData = self.m_heroList[self.m_chooseHeroList[1].index]
      self:PlayHeroSelectVoice(self.m_chooseHeroList[1].heroID, heroData.serverData.iFashion)
    end
  end
  self:RefreshConditionItem()
end

function Form_CastleDispatchSelect:GenerateChooseHero()
  local heroList = self.m_dispatchEvent.vHero
  for i, id in pairs(heroList) do
    for m, n in ipairs(self.m_heroList) do
      if id == n.serverData.iHeroId then
        self.m_chooseHeroList[i] = {index = i, heroID = id}
      end
    end
  end
end

function Form_CastleDispatchSelect:RefreshConditionItem()
  for i, v in ipairs(self.m_obj_list) do
    local campImgObj = v.transform:Find("c_camp_icon").gameObject
    if self.m_heroConditionTab[i] then
      local gradeImg = v.transform:Find("c_icon_hero_item_grade"):GetComponent(T_Image)
      local campImg = campImgObj.transform:GetComponent(T_Image)
      ResourceUtil:CreateQualityImg(gradeImg, self.m_heroConditionTab[i].quality)
      ResourceUtil:CreateCampImg(campImg, self.m_heroConditionTab[i].camp, "HeroHeartIcon")
    end
    local headIconObj = v.transform:Find("c_head_icon").gameObject
    if self.m_chooseHeroList[i] and self.m_chooseHeroList[i].heroID ~= nil then
      local imageItem = headIconObj.transform:GetComponent(T_Image)
      local heroData = self.m_heroList[self.m_chooseHeroList[i].index]
      if heroData then
        local heroID = self.m_chooseHeroList[i].heroID
        local fashionID = heroData.serverData.iFashion
        local fashionInfo = HeroManager:GetHeroFashion():GetFashionInfoByHeroIDAndFashionID(heroID, fashionID)
        if fashionInfo then
          UILuaHelper.SetAtlasSprite(imageItem, fashionInfo.m_FashionItemPic)
        end
      end
      headIconObj:SetActive(true)
      campImgObj:SetActive(false)
    else
      headIconObj:SetActive(false)
      campImgObj:SetActive(true)
    end
    local selObj = v.transform:Find("c_img_select").gameObject
    selObj:SetActive(self.m_selItemIndex == i)
  end
  self.m_btn_confirm:SetActive(self:isConcludeCondition())
  self.m_btn_confirm_gray:SetActive(not self:isConcludeCondition())
end

function Form_CastleDispatchSelect:GenerateCardCondition()
  local conditionTab = {}
  local eventCfg = CastleDispatchManager:GetCastleDispatchEventCfg(self.m_dispatchEvent.iGroupId, self.m_dispatchEvent.iEventId)
  if eventCfg then
    local slot = utils.changeCSArrayToLuaTable(eventCfg.m_Slot)
    for i, v in ipairs(slot) do
      conditionTab[i] = {
        camp = v[1],
        quality = v[2]
      }
    end
  end
  return conditionTab
end

function Form_CastleDispatchSelect:CreatCardConditionItem(conditionTab)
  for i, v in ipairs(conditionTab) do
    local cloneObj = GameObject.Instantiate(self.m_hero_item, self.m_hero_root.transform).gameObject
    UILuaHelper.SetActive(cloneObj, true)
    local campBtn = cloneObj.transform:Find("c_btnClick"):GetComponent(T_Button)
    campBtn.onClick:RemoveAllListeners()
    UILuaHelper.BindButtonClickManual(self, campBtn, function()
      self:OnClickConditionItem(i)
    end)
    self.m_obj_list[i] = cloneObj
  end
end

function Form_CastleDispatchSelect:OnClickConditionItem(index)
  self.m_selItemIndex = index
  for i, v in ipairs(self.m_obj_list) do
    local selObj = v.transform:Find("c_img_select").gameObject
    selObj:SetActive(self.m_selItemIndex == i)
  end
  local excludeHero = self:GetExcludeHeroList(self.m_selItemIndex)
  self.m_heroList = CastleDispatchManager:FilterHeroByCondition(self.m_heroConditionTab[self.m_selItemIndex], excludeHero)
  self.m_heroListInfinityGrid:ShowItemList(self.m_heroList)
  UILuaHelper.SetActive(self.m_list_empty, table.getn(self.m_heroList) == 0)
  if table.getn(self.m_heroList) > 0 then
    self.m_heroListInfinityGrid:LocateTo(0)
  end
  if self.m_chooseHeroList[self.m_selItemIndex] then
    self.m_heroListInfinityGrid:OnChooseItem(self.m_chooseHeroList[self.m_selItemIndex].index, true)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(189)
end

function Form_CastleDispatchSelect:GetOneEmptyConditionIndex()
  for i, v in ipairs(self.m_obj_list) do
    if self.m_chooseHeroList[i] == nil then
      return i
    end
  end
  return nil
end

function Form_CastleDispatchSelect:OnItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local addFlag = self:ChooseOneItem(fjItemIndex)
  self:RefreshConditionItem()
  if addFlag then
    if self.m_heroList[fjItemIndex] and self.m_heroList[fjItemIndex].characterCfg then
      local HeroId = self.m_heroList[fjItemIndex].characterCfg.m_HeroID
      local fashionID = self.m_heroList[fjItemIndex].serverData.iFashion
      self:PlayHeroSelectVoice(HeroId, fashionID)
    end
    local nextIndex = self:GetOneEmptyConditionIndex()
    if nextIndex then
      self:OnClickConditionItem(nextIndex)
    end
  end
end

function Form_CastleDispatchSelect:ChooseOneItem(fjItemIndex)
  local addFlag = false
  local chooseHeroData = self.m_heroList[fjItemIndex]
  if not chooseHeroData or not chooseHeroData.serverData then
    return
  end
  local curChooseHeroID = chooseHeroData.serverData.iHeroId
  if not self.m_chooseHeroList[self.m_selItemIndex] then
    self.m_chooseHeroList[self.m_selItemIndex] = {}
  end
  local oldIndex = self.m_chooseHeroList[self.m_selItemIndex].index
  self.m_heroListInfinityGrid:OnChooseItem(oldIndex, false)
  if curChooseHeroID == self.m_chooseHeroList[self.m_selItemIndex].heroID then
    self.m_chooseHeroList[self.m_selItemIndex] = nil
  else
    self.m_heroListInfinityGrid:OnChooseItem(fjItemIndex, true)
    self.m_chooseHeroList[self.m_selItemIndex] = {index = fjItemIndex, heroID = curChooseHeroID}
    addFlag = true
  end
  return addFlag
end

function Form_CastleDispatchSelect:OnRewardItemClk(index, go)
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

function Form_CastleDispatchSelect:isConcludeCondition()
  return table.getn(self.m_chooseHeroList) == table.getn(self.m_obj_list)
end

function Form_CastleDispatchSelect:GetChooseHeroList()
  local hero = {}
  local heroMap = {}
  for i, v in pairs(self.m_chooseHeroList) do
    hero[#hero + 1] = v.heroID
  end
  heroMap[self.m_dispatchLocation] = hero
  return heroMap
end

function Form_CastleDispatchSelect:GetExcludeHeroList(index)
  local hero = {}
  for i, v in pairs(self.m_chooseHeroList) do
    if i ~= index then
      hero[#hero + 1] = v.heroID
    end
  end
  return hero
end

function Form_CastleDispatchSelect:OnBtnconfirmClicked()
  if not self.m_chooseHeroList or not self:isConcludeCondition() then
    return
  end
  local hero = self:GetChooseHeroList()
  CastleDispatchManager:ReqCastleDoDispatch(hero)
end

function Form_CastleDispatchSelect:OnBtnconfirgrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45008)
end

function Form_CastleDispatchSelect:OnBtnautograyClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45006)
end

function Form_CastleDispatchSelect:OnBtnautoClicked()
  local heroList = {}
  for i, condition in pairs(self.m_heroConditionTab) do
    local heroTab = CastleDispatchManager:FilterHeroByCondition(condition, heroList)
    if heroTab and heroTab[1] then
      heroList[#heroList + 1] = heroTab[1].serverData.iHeroId
      self.m_chooseHeroList[i] = {
        index = 1,
        heroID = heroTab[1].serverData.iHeroId
      }
    end
  end
  if 0 < #heroList then
    self:RefreshAutoUI()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 45007)
  end
end

function Form_CastleDispatchSelect:OnBackClk()
  self:CloseForm()
end

function Form_CastleDispatchSelect:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_CastleDispatchSelect:IsOpenGuassianBlur()
  return true
end

function Form_CastleDispatchSelect:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleDispatchSelect:PlayHeroSelectVoice(heroID, fashionID)
  local voice = HeroManager:GetHeroVoice():GetHeroDisPatchVoice(heroID, fashionID)
  CS.UI.UILuaHelper.StopPlaySFX(self.playingVoice)
  if voice and voice ~= "" then
    CS.UI.UILuaHelper.StartPlaySFX(voice)
    self.playingVoice = voice
  end
end

local fullscreen = true
ActiveLuaUI("Form_CastleDispatchSelect", Form_CastleDispatchSelect)
return Form_CastleDispatchSelect
