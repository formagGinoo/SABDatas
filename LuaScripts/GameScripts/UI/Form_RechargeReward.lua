local Form_RechargeReward = class("Form_RechargeReward", require("UI/UIFrames/Form_RechargeRewardUI"))
local SwitchRechargeRewardAnim = "m_Form_RechargeReward_switch"
local FormEnterAnimStr = "Form_RechargeReward_in"

function Form_RechargeReward:SetInitParam(param)
end

function Form_RechargeReward:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.goBackBtnRoot = self.m_rootTrans:Find("content_node/pnl_left/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(self.goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), nil)
  self.m_activity = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_firstRewardList = {}
  self.m_pointRewardList = {}
  self.m_curPointNum = nil
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnFirstRewardItemClk(itemIndex)
    end
  }
  self.m_luaFirstRewardListInfinityGrid1 = self:CreateInfinityGrid(self.m_first_reward_list1_InfinityGrid, "RechargeReward/UIFirstRechargeRewardItem", initGridData)
  self.m_luaFirstRewardListInfinityGrid2 = self:CreateInfinityGrid(self.m_first_reward_list2_InfinityGrid, "RechargeReward/UIFirstRechargeRewardItem", initGridData)
  local initGridAddData = {
    itemClkBackFun = function(itemIndex)
      self:OnAddRewardItemClk(itemIndex)
    end
  }
  self.m_luaAddRewardListMulItemList = self:CreateCloneMulItemList(self.m_stage_reward_root, self.m_item_reward, "RechargeReward/UIRechargeAddRewardItem", initGridAddData)
  self.m_skin_img_head = self.m_img_hero_head:GetComponent("CircleImage")
end

function Form_RechargeReward:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_RechargeReward:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine()
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_RechargeReward:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine()
end

function Form_RechargeReward:FreshData()
  self.m_isPop = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_isPop = tParam.isPop
    self.m_csui.m_param = nil
  end
  if self.m_isPop then
    LocalDataManager:SetIntSimple("CountConsumeActivity_Have_Pop", 1)
    self.m_btn_reward:SetActive(false)
  else
    self.m_btn_reward:SetActive(true)
  end
  self:FreshActivityData()
end

function Form_RechargeReward:FreshActivityData()
  self.m_activity = ActivityManager:GetActivityByType(MTTD.ActivityType_CountConsume)
  if not self.m_activity then
    self:CloseForm()
    return
  end
  if self.m_activity:isInActivityTime() ~= true then
    self:CloseForm()
    return
  end
  self.m_firstRewardList = self.m_activity:GetFirstRewardList()
  self.m_pointRewardList = self.m_activity:GetPointRewardList()
  self.m_curPointNum = self.m_activity:GetCurPoint()
end

function Form_RechargeReward:ClearCacheData()
end

function Form_RechargeReward:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_CountConsume_RedPointReward", handler(self, self.OnRedPointReward))
  self:addEventListener("eGameEvent_Activity_CountConsume_TakeReward", handler(self, self.OnTakeReward))
  self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
  self:addEventListener("eGameEvent_Activity_TimeEnd", handler(self, self.OnEventActivityTimeEnd))
end

function Form_RechargeReward:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_RechargeReward:OnRedPointReward()
  self:FreshRedPointRewardStatus()
end

function Form_RechargeReward:OnTakeReward()
  self:FreshActivityData()
  self:FreshUI()
end

function Form_RechargeReward:OnEventActivityReload()
  self:FreshActivityData()
  self:FreshUI()
end

function Form_RechargeReward:OnEventActivityTimeEnd(activityID)
  if not self.m_activity then
    return
  end
  if self.m_activity:getID() ~= activityID then
    return
  end
  self:CloseForm()
end

function Form_RechargeReward:FreshUI()
  self:FreshStatusShow()
  self:FreshShowSkinInfo()
  self:FreshRedPointRewardStatus()
  self:FreshPopStatusShow()
  self:CheckShowSwitchAnim()
end

function Form_RechargeReward:FreshStatusShow()
  if not self.m_activity then
    return
  end
  local curPointNum = self.m_activity:GetCurPoint()
  UILuaHelper.SetActive(self.m_node_status1, curPointNum <= 0)
  UILuaHelper.SetActive(self.m_node_status2, 0 < curPointNum)
  if curPointNum <= 0 then
    self:FreshStatusShow1()
  else
    self:FreshStatusShow2()
  end
end

function Form_RechargeReward:CheckShowSwitchAnim()
  if not self.m_activity then
    return
  end
  local isShowEnter = false
  local curPointNum = self.m_activity:GetCurPoint()
  local isShowAnim = LocalDataManager:GetIntSimple("CountConsumeActivity_Have_Show_Switch_Anim", 0) == 1
  if curPointNum <= 0 or isShowAnim then
    isShowEnter = true
  end
  if isShowEnter then
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, FormEnterAnimStr)
  else
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, SwitchRechargeRewardAnim)
    LocalDataManager:SetIntSimple("CountConsumeActivity_Have_Show_Switch_Anim", 1)
    UILuaHelper.SetActive(self.m_node_status1, true)
    self:FreshStatusShow1()
    UILuaHelper.SetActive(self.m_node_status2, true)
  end
end

function Form_RechargeReward:FreshStatusShow1()
  if not self.m_activity then
    return
  end
  if not self.m_firstRewardList then
    return
  end
  if not next(self.m_firstRewardList) then
    return
  end
  local totalLoginDays = RoleManager:GetTotalLoginDays()
  local maxLimitDayNum = self.m_firstRewardList[#self.m_firstRewardList].iNeedLoginDays
  local isAllGet = totalLoginDays >= maxLimitDayNum
  UILuaHelper.SetActive(self.m_z_txt_rewardany1, not isAllGet)
  UILuaHelper.SetActive(self.m_pnl_titletips, isAllGet)
  self.m_luaFirstRewardListInfinityGrid1:ShowItemList(self.m_firstRewardList)
  self.m_luaFirstRewardListInfinityGrid1:LocateTo()
end

function Form_RechargeReward:FreshStatusShow2()
  if not self.m_activity then
    return
  end
  if self.m_firstRewardList and next(self.m_firstRewardList) then
    self.m_luaFirstRewardListInfinityGrid2:ShowItemList(self.m_firstRewardList)
    self.m_luaFirstRewardListInfinityGrid2:LocateTo()
  end
  if self.m_pointRewardList then
    self.m_luaAddRewardListMulItemList:ShowItemList(self.m_pointRewardList)
    local allShowItemList = self.m_luaAddRewardListMulItemList:GetAllShownItemList()
    local maxNum = #allShowItemList
    local maxMatchIndex = 0
    for i, v in ipairs(allShowItemList) do
      local isShow = false
      if i < maxNum then
        local nextReward = self.m_pointRewardList[i + 1]
        if nextReward then
          isShow = self.m_curPointNum >= nextReward.iNeedPoint
        end
      end
      local tempReward = self.m_pointRewardList[i]
      if self.m_curPointNum > tempReward.iNeedPoint and i > maxMatchIndex then
        maxMatchIndex = i
      end
      v:FreshLineStatus(isShow, i == maxNum)
    end
    if 0 < maxMatchIndex and allShowItemList[maxMatchIndex] then
      allShowItemList[maxMatchIndex]:ShowRechargeRewardEffect()
    end
    if maxMatchIndex >= #self.m_pointRewardList then
      self.m_txt_slidernum1_Text.text = ConfigManager:GetCommonTextById(240017)
    else
      self.m_txt_slidernum1_Text.text = self.m_curPointNum or 0
    end
  end
  local pointRewardOne = self.m_pointRewardList and self.m_pointRewardList[1]
  if pointRewardOne then
    if self.m_curPointNum >= pointRewardOne.iNeedPoint then
      UILuaHelper.SetActive(self.m_img_first_stage_get, true)
    else
      UILuaHelper.SetActive(self.m_img_first_stage_get, false)
    end
  end
end

function Form_RechargeReward:FreshPopStatusShow()
  UILuaHelper.SetActive(self.m_common_click, self.m_isPop == true)
  UILuaHelper.SetActive(self.goBackBtnRoot, self.m_isPop ~= true)
  UILuaHelper.SetActive(self.m_btn_go, self.m_isPop ~= true)
end

function Form_RechargeReward:FreshShowSkinInfo()
  if not self.m_activity then
    return
  end
  local spineAssetStr = self.m_activity:GetSpineAssetStr()
  self:ShowHeroSpine(spineAssetStr)
  self:FreshSkinBaseInfo()
end

function Form_RechargeReward:FreshSkinBaseInfo()
  if not self.m_activity then
    return
  end
  local skinID = self.m_activity:GetSkinId()
  if not skinID then
    return
  end
  local heroFashion = HeroManager:GetHeroFashion()
  if not heroFashion then
    return
  end
  local fashionInfoCfg = heroFashion:GetFashionInfoByID(skinID)
  if not fashionInfoCfg then
    return
  end
  local szIcon = ResourceUtil:GetHeroSkinIconPath(fashionInfoCfg.m_FashionID, fashionInfoCfg)
  if szIcon and self.m_skin_img_head then
    UILuaHelper.SetBaseImageAtlasSprite(self.m_skin_img_head, szIcon)
  end
  self.m_skin_name_Text.text = fashionInfoCfg.m_mFashionName
  local heroCfg = HeroManager:GetHeroConfigByID(fashionInfoCfg.m_CharacterId)
  if heroCfg then
    self.m_txt_name_Text.text = heroCfg.m_mShortname
  end
  self.m_skin_name_Text.text = fashionInfoCfg.m_mFashionName or ""
end

function Form_RechargeReward:ShowHeroSpine(heroSpinePathStr)
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  self:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader then
    local typeStr = SpinePlaceCfg.HeroDetail
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_role, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spinePlaceObj, true)
    end)
  end
end

function Form_RechargeReward:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_RechargeReward:FreshRedPointRewardStatus()
  if not self.m_activity then
    return
  end
  local redPointRewardList = self.m_activity:GetRedPointRewardList()
  if not redPointRewardList then
    return
  end
  local oneRewardData = redPointRewardList[1]
  if not oneRewardData then
    return
  end
  ResourceUtil:CreateItemIcon(self.m_icon_item_Image, oneRewardData.iID)
  self.m_txt_rewardnum_Text.text = oneRewardData.iNum
  local isGetRedPointReward = self.m_activity:GetIsRedPointRewardGet()
  UILuaHelper.SetActive(self.m_pnl_gotreward, isGetRedPointReward == true)
  UILuaHelper.SetActive(self.m_reward_can_get, isGetRedPointReward ~= true)
end

function Form_RechargeReward:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
  if self.m_isPop then
    PushFaceManager:CheckShowNextPopPanel()
  end
end

function Form_RechargeReward:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
    GameSceneManager:CheckChangeSceneToMainCity(nil, true)
  end
  if self.m_isPop then
    PushFaceManager:CheckShowNextPopPanel()
  end
end

function Form_RechargeReward:OnFirstRewardItemClk(itemIndex)
  if not self.m_activity then
    return
  end
  if not itemIndex then
    return
  end
  local itemData = self.m_firstRewardList[itemIndex]
  if not itemData then
    return
  end
  self.m_activity:RequestRewardCS()
end

function Form_RechargeReward:OnAddRewardItemClk(itemIndex)
  if not self.m_activity then
    return
  end
  if not itemIndex then
    return
  end
  local itemData = self.m_pointRewardList[itemIndex]
  if not itemData then
    return
  end
  self.m_activity:RequestRewardCS()
end

function Form_RechargeReward:OnBtnrewardClicked()
  if not self.m_activity then
    return
  end
  local isGetRedPointReward = self.m_activity:GetIsRedPointRewardGet()
  if isGetRedPointReward then
    return
  end
  self.m_activity:ReqTakeRedPointReward()
end

function Form_RechargeReward:OnBtnruleClicked()
  utils.popUpDirectionsUI({tipsID = 1271})
end

function Form_RechargeReward:OnBtnrulefirstClicked()
  utils.popUpDirectionsUI({tipsID = 1271})
end

function Form_RechargeReward:OnBtnruleaddClicked()
  utils.popUpDirectionsUI({tipsID = 1272})
end

function Form_RechargeReward:OnBtnBgCloseClicked()
  self:CloseForm()
  if self.m_isPop then
    PushFaceManager:CheckShowNextPopPanel()
  end
end

function Form_RechargeReward:OnBtngoClicked()
  if not self.m_activity then
    return
  end
  QuickOpenFuncUtil:OpenFunc(40001)
end

function Form_RechargeReward:OnBtnturnClicked()
  if not self.m_activity then
    return
  end
  local skinID = self.m_activity:GetSkinId()
  if not skinID then
    return
  end
  local heroFashion = HeroManager:GetHeroFashion()
  if not heroFashion then
    return
  end
  local fashionInfoCfg = heroFashion:GetFashionInfoByID(skinID)
  if not fashionInfoCfg then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_FASHION, {
    heroID = fashionInfoCfg.m_CharacterId,
    fashionID = skinID
  })
end

local fullscreen = true
ActiveLuaUI("Form_RechargeReward", Form_RechargeReward)
return Form_RechargeReward
