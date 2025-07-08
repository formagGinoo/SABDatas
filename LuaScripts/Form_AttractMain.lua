local Form_AttractMain = class("Form_AttractMain", require("UI/UIFrames/Form_AttractMainUI"))
local DragLimitNum = 200
local DragLeftPosNum = -1000
local DragRightPosNum = 1000
local DragTweenTime = 0.12
local DragTweenBackTime = 0.12
local MaxDragDeltaNum = 800
local HeroTagCfg = {Attract = 1}
local ShowTabHeroPos = {
  [HeroTagCfg.Attract] = {
    isMaskAndGray = false,
    position = {
      -511,
      -14,
      0
    },
    scale = {
      1,
      1,
      1
    },
    posTime = 0.01,
    scaleTime = 0.1,
    posTween = nil,
    scaleTween = nil
  }
}
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")
local GlobalCfgIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local AttractRankCfgIns = ConfigManager:GetConfigInsByName("AttractRank")
local AttractAddCfgIns = ConfigManager:GetConfigInsByName("AttractAdd")
local ItemCfgIns = ConfigManager:GetConfigInsByName("Item")

function Form_AttractMain:SetInitParam(param)
end

function Form_AttractMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1121)
  self.m_pnl_attract_touch_exp:SetActive(false)
  self.m_iAttractTouchReward = tonumber(GlobalCfgIns:GetValue_ByName("AttractTouchReward").m_Value)
  self.m_iAttractTouchSingleLimit = tonumber(GlobalCfgIns:GetValue_ByName("AttractTouchSingleLimit").m_Value)
  self.m_totalTouchCount = 0
  self.m_totalExp = 0
  self.m_spineClick = self.m_root_hero:GetComponent("SpineClick")
  if self.m_spineClick then
    function self.m_spineClick.Touched(name, localpos)
      if self.m_isDrag or not self.m_bMain then
        log.info("cancel spineClick")
        
        self.m_isDrag = false
        return
      end
      log.info("spineClick:" .. tostring(name))
      local vVoiceText = AttractManager:GetTouchVoice(self.m_curShowHeroData, self.m_curShowHeroData.characterCfg.m_HeroID, name)
      if vVoiceText then
        self:StopCurPlayingVoice()
        self.m_vVoiceText = vVoiceText
        self:PlayVoice(self.m_vVoiceText[self.m_playSubIndex])
      else
        return
      end
      self:PlayTouchDisappearAnimation()
    end
  end
  self.m_root_hero_BtnEx = self.m_root_hero:GetComponent("ButtonExtensions")
  if self.m_root_hero_BtnEx then
    self.m_root_hero_BtnEx.BeginDrag = handler(self, self.OnImgBeginDrag)
    self.m_root_hero_BtnEx.Drag = handler(self, self.OnImgDrag)
    self.m_root_hero_BtnEx.EndDrag = handler(self, self.OnImgEndBDrag)
  end
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  local initGiftGridData = {
    itemClkBackFun = handler(self, self.OnGiftItemClk),
    itemDelClkBackFun = handler(self, self.OnItemDeleteClk),
    itemLongClkBackFun = handler(self, self.OnItemLongClk)
  }
  self.m_giftInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_item_list_InfinityGrid, "Attract/UIAttractGiftItem", initGiftGridData)
  self.m_abilityInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_ScrollView_ability_InfinityGrid, "Attract/UIAttractAbilityItem")
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_AttractMain:PlayTouchDisappearAnimation()
  if self.m_prevTouchExp then
    GameObject.Destroy(self.m_prevTouchExp)
    self.m_prevTouchExp = nil
  end
end

function Form_AttractMain:CheckHeroTouch()
  if self.m_nextRankExp == nil then
    return false
  end
  if (self.m_attractInfo.iTouchTimes or 0) + self.m_totalTouchCount + 1 > self.m_iAttractTouchSingleLimit then
    return false
  end
  if AttractManager:GetTouchTimes() + self.m_totalTouchCount + 1 > self.m_iAttractTouchLimit then
    return false
  end
  self.m_totalTouchCount = self.m_totalTouchCount + 1
  self.m_totalExp = self.m_totalExp + self.m_iAttractTouchReward
  if self.m_curRankExp + self.m_totalExp >= self.m_nextRankExp then
    return false
  else
    self:FreshExp(self.m_curRankExp + self.m_totalExp, self.m_nextRankExp, self.m_baseRankExp)
  end
  return true
end

function Form_AttractMain:ShowAttractLevelUp()
  local newRank = self.m_curShowHeroData.serverData.iAttractRank
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTLEVELUP, {
    curShowHeroData = self.m_curShowHeroData,
    iOldRank = self.m_oldRank,
    iNewRank = newRank
  })
  self.m_oldRank = self.m_curShowHeroData.serverData.iAttractRank
end

function Form_AttractMain:ShowAttractTips(totalAddExp)
  self.m_pnl_attract_tips:SetActive(true)
  local performanceID = self.m_curShowHeroData.characterCfg.m_PerformanceID[0]
  local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
  local szIcon = presentationData.m_UIkeyword .. "003"
  UILuaHelper.SetAtlasSprite(self.m_img_hero_head_levelup_Image, szIcon)
  self.m_txt_attract_tips_num_Text.text = self.m_oldRank
  self.m_txt_hero_name_attract_tips_Text.text = self.m_curShowHeroData.characterCfg.m_mName
  self.m_txt_attract_tips_exp_num_Text.text = "+" .. totalAddExp
  TimeService:SetTimer(2.0, 1, function()
    self.m_pnl_attract_tips:SetActive(false)
  end)
end

function Form_AttractMain:OnActive()
  self.super.OnActive(self)
  self:addEventListener("eGameEvent_Hero_SetLove", handler(self, self.FreshFavourite))
  if self.m_spineClick == nil then
    self.m_spineClick = self.m_root_hero:GetComponent("SpineClick")
  end
  self:InitView()
  GlobalManagerIns:TriggerWwiseBGMState(63)
end

function Form_AttractMain:OnInactive()
  self.super.OnInactive(self)
  self:StopCurPlayingVoice()
  self:clearEventListener()
  self:PlayTouchDisappearAnimation()
  if self.m_spineClick then
    self.m_spineClick:DestroyFollowerList()
    self.m_spineClick = nil
  end
  self:CheckRecycleCurSpine()
end

function Form_AttractMain:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleCurSpine()
end

function Form_AttractMain:CheckFreshRedDot()
  if not self.m_curShowHeroData then
    return
  end
  local iHeroId = self.m_curShowHeroData.serverData.iHeroId
  self:RegisterOrUpdateRedDotItem(self.m_btn_canon.transform:Find("txt_canon/ui_common_redpoint").gameObject, RedDotDefine.ModuleType.HeroAttractEntry, iHeroId)
end

function Form_AttractMain:PlayVoice(voiceInfo)
  CS.UI.UILuaHelper.StartPlaySFX(voiceInfo.voice, nil, function(playingId)
    self.m_playingId = playingId
    self.m_bg_lines:SetActive(true)
    self.m_txt_lines_Text.text = voiceInfo.subtitle
  end, function()
    self.m_playSubIndex = self.m_playSubIndex + 1
    local nextVoice = self.m_vVoiceText[self.m_playSubIndex]
    if nextVoice ~= nil then
      self:PlayVoice(nextVoice)
    else
      self.m_bg_lines:SetActive(false)
      self.m_playingId = nil
    end
  end)
end

function Form_AttractMain:StopCurPlayingVoice()
  self.m_playSubIndex = 1
  self.m_bg_lines:SetActive(false)
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function Form_AttractMain:InitView()
  local tParam = self.m_csui.m_param
  self.m_allHeroList = tParam.heroDataList
  self.m_curShowHeroData = tParam.curShowHeroData
  self.m_curChooseHeroIndex = tParam.chooseHeroIndex
  self.m_pnl_attract_tips:SetActive(false)
  self.m_closeBackFun = tParam.closeBackFun
  self.m_UIFX_AttracMain1:SetActive(false)
  self.m_iAttractTouchLimit = AttractManager:GetTouchLimitedTimes()
  self:ResetInfo()
  self:OnRefreshHeroSpine()
  self:FreshHeroInfo()
  self:FreshAttractMain()
  self:FreshGiftMain()
  self:SwitchUI(self.m_bMain or true)
end

function Form_AttractMain:OnUncoverd()
  self:OnRefreshHeroSpine()
end

function Form_AttractMain:ResetInfo()
  self.m_attractInfo = AttractManager:GetHeroAttractById(self.m_curShowHeroData.serverData.iHeroId) or {}
  self.m_expList = AttractManager:GetExpList(self.m_curShowHeroData.characterCfg.m_AttractRankTemplate)
  self.m_oldRank = self.m_curShowHeroData.serverData.iAttractRank
  self.m_maxBreakNum = HeroManager:GetHeroMaxBreakNum(self.m_curShowHeroData.serverData.iHeroId)
  self:CheckFreshRedDot()
end

function Form_AttractMain:FreshHeroInfo()
  local serverData = self.m_curShowHeroData.serverData
  local heroCfg = self.m_curShowHeroData.characterCfg
  self:FreshFavourite(serverData.bLove, true)
  self:FreshCamp(heroCfg.m_Camp)
  self:FreshHeroName(heroCfg.m_mName)
end

function Form_AttractMain:FreshCamp(heroCamp)
  if not heroCamp then
    return
  end
  local campCfg = CampCfgIns:GetValue_ByCampID(heroCamp)
  if campCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_camp_Image, campCfg.m_CampIcon)
end

function Form_AttractMain:FreshFavourite(bLove, bFirst)
  self.m_img_mark_active:SetActive(bLove)
  self.m_UIFX_attract:SetActive(bLove)
  if bLove and not bFirst then
    self.m_UIFX_attract:GetComponent("ParticleSystem"):Play()
  end
end

function Form_AttractMain:FreshHeroName(name, shortName)
  if name then
    self.m_txt_hero_name_Text.text = name
  end
  if shortName then
    self.m_txt_hero_nike_name_Text.text = shortName
  end
end

function Form_AttractMain:FreshAttractMain()
  self:FreshRankInfo()
  self:FreshAttractAttr()
end

function Form_AttractMain:FreshRankInfo()
  local serverData = self.m_curShowHeroData.serverData
  self.m_txt_rank_Text.text = serverData.iAttractRank
  local baseExpInfo = self.m_expList[serverData.iAttractRank]
  local baseExp = baseExpInfo.exp
  self.m_baseRankExp = baseExp
  local curExp = self.m_attractInfo.iAttractExp or 0
  self.m_curRankExp = curExp
  local nextExpInfo = self.m_expList[serverData.iAttractRank + 1]
  self.m_maxLevelRank = false
  self.m_needBreakLevelRank = false
  if nextExpInfo == nil or 0 < nextExpInfo.breakCondition and serverData.iBreak < nextExpInfo.breakCondition then
    self.m_nextRankExp = nil
    self.m_z_pnl_rank_bar_max:SetActive(true)
    self.m_pnl_rank_bar:SetActive(false)
    if nextExpInfo == nil then
      self.m_maxLevelRank = true
      self.m_z_txt_rank_max_des2:SetActive(true)
      self.m_z_txt_rank_max_des:SetActive(false)
    elseif self.m_curShowHeroData.serverData.iBreak < nextExpInfo.breakCondition and self.m_curShowHeroData.serverData.iBreak < self.m_maxBreakNum then
      self.m_needBreakLevelRank = true
      self.m_z_txt_rank_max_des2:SetActive(false)
      self.m_z_txt_rank_max_des:SetActive(true)
    else
      self.m_maxLevelRank = true
      self.m_z_txt_rank_max_des2:SetActive(true)
      self.m_z_txt_rank_max_des:SetActive(false)
    end
    return
  end
  self.m_pnl_rank_bar:SetActive(true)
  self.m_z_pnl_rank_bar_max:SetActive(false)
  local nextExp = nextExpInfo.exp
  self.m_nextRankExp = nextExp
  self:FreshExp(curExp, nextExp, baseExp)
end

function Form_AttractMain:FreshExp(curExp, nextExp, baseExp)
  self.m_curExp = curExp
  if nextExp <= curExp then
    self.m_img_rank_bar_Image.fillAmount = 1
  else
    self.m_img_rank_bar_Image.fillAmount = (curExp - baseExp) / (nextExp - baseExp)
  end
  self.m_txt_rank_num_Text.text = curExp - baseExp .. "/" .. nextExp - baseExp
end

function Form_AttractMain:FreshAttractAttr()
  local serverData = self.m_curShowHeroData.serverData
  local iAttractAddTemplate = self.m_curShowHeroData.characterCfg.m_AttractAddTemplate
  self.m_txt_rank_Text.text = serverData.iAttractRank
  local iPropertyID = AttractAddCfgIns:GetValue_ByAttractAddTemplateIDAndRankID(iAttractAddTemplate, serverData.iAttractRank).m_PropertyID
  local attractAttrInfoList = AttractManager:GetBaseAttr(iPropertyID)
  if #attractAttrInfoList == 0 then
    self.m_z_txt_ablity_none:SetActive(true)
  else
    self.m_z_txt_ablity_none:SetActive(false)
  end
  self.m_abilityInfinityGrid:ShowItemList(attractAttrInfoList)
end

function Form_AttractMain:FreshGiftMain()
  self:FreshRankGift()
  self:FreshGiftList()
  self:UpdateSendButtonStatus()
end

function Form_AttractMain:FreshRankGift()
  self.m_txt_rank_before_num_Text.text = self.m_curShowHeroData.serverData.iAttractRank
  self.m_startAttractRank = self.m_curShowHeroData.serverData.iAttractRank
  self.m_startExp = self.m_attractInfo.iAttractExp or 0
  self:FreshExpProgressGift(self.m_startAttractRank)
end

function Form_AttractMain:GetRankLevelByExp(curExp)
  for k, v in ipairs(self.m_expList) do
    if curExp < v.exp then
      return k - 1
    end
    if self.m_curShowHeroData.serverData.iBreak < v.breakCondition then
      return k - 1
    end
  end
  return #self.m_expList
end

function Form_AttractMain:ChangeExp(changeValue)
  self.m_curExpGift = self.m_curExpGift + changeValue
  if 0 < changeValue then
    if self.m_curExpGift >= self.m_nextExpGift then
      self:FreshExpProgressGift(self:GetRankLevelByExp(self.m_curExpGift), self.m_curExpGift)
      return
    end
  elseif self.m_curExpGift < self.m_baseExpGift or self.m_needBreakLevel or self.m_maxLevel then
    self:FreshExpProgressGift(self:GetRankLevelByExp(self.m_curExpGift), self.m_curExpGift)
    return
  end
  self:FreshExpGift(self.m_curExpGift, self.m_nextExpGift, self.m_baseExpGift)
end

function Form_AttractMain:FreshExpProgressGift(iAttractRank, iCurExp)
  self.m_iAttractRankGift = iAttractRank
  self.m_txt_rank_after_num_Text.text = iAttractRank
  local baseExpInfo = self.m_expList[iAttractRank]
  local baseExp = baseExpInfo.exp
  local curExp = iCurExp and iCurExp or self.m_attractInfo.iAttractExp or 0
  local nextExpInfo = self.m_expList[iAttractRank + 1]
  self.m_maxLevel = false
  self.m_needBreakLevel = false
  if nextExpInfo == nil or 0 < nextExpInfo.breakCondition and self.m_curShowHeroData.serverData.iBreak < nextExpInfo.breakCondition then
    if nextExpInfo == nil then
      self.m_maxLevel = true
    elseif self.m_curShowHeroData.serverData.iBreak < nextExpInfo.breakCondition and self.m_curShowHeroData.serverData.iBreak < self.m_maxBreakNum then
      self.m_needBreakLevel = true
    else
      self.m_maxLevel = true
    end
    local prevExpInfo = self.m_expList[iAttractRank - 1]
    self:FreshExpGift(curExp, baseExp, prevExpInfo.exp, true)
    return
  end
  self.m_baseExpGift = baseExp
  self.m_pnl_rank_bar:SetActive(true)
  self.m_z_pnl_rank_bar_max:SetActive(false)
  local nextExp = nextExpInfo.exp
  self.m_nextExpGift = nextExp
  self:FreshExpGift(curExp, nextExp, baseExp)
end

function Form_AttractMain:FreshExpGift(curExp, nextExp, baseExp, bFull)
  if bFull then
    self.m_img_rank_precent_bar_Image.fillAmount = 1
    self.m_img_rank_precent_bar_exp_Image.fillAmount = 1
    self.m_txt_rank_precent_num_Text.text = nextExp - baseExp .. "/" .. nextExp - baseExp .. "<color=#b2452b>(MAX)</color>"
    return
  end
  self.m_curExpGift = curExp
  if self.m_startAttractRank == self.m_iAttractRankGift then
    if nextExp <= curExp then
      self.m_img_rank_precent_bar_Image.fillAmount = 1
      self.m_img_rank_precent_bar_exp_Image.fillAmount = 0
    else
      self.m_img_rank_precent_bar_Image.fillAmount = (self.m_startExp - baseExp) / (nextExp - baseExp)
      self.m_img_rank_precent_bar_exp_Image.fillAmount = (curExp - baseExp) / (nextExp - baseExp)
    end
  elseif nextExp <= curExp then
    self.m_img_rank_precent_bar_Image.fillAmount = 0
    self.m_img_rank_precent_bar_exp_Image.fillAmount = 1
  else
    self.m_img_rank_precent_bar_Image.fillAmount = 0
    self.m_img_rank_precent_bar_exp_Image.fillAmount = (curExp - baseExp) / (nextExp - baseExp)
  end
  self.m_txt_rank_precent_num_Text.text = curExp - baseExp .. "/" .. nextExp - baseExp
end

function Form_AttractMain:FreshGiftList()
  local vGiftList = ItemManager:GetItemListByType(ItemManager.ItemType.AttractGift)
  local iCharCamp = self.m_curShowHeroData.characterCfg.m_Camp
  local vSendGift = self.m_attractInfo.vSendGift or {}
  local mSendGift = {}
  for k, v in ipairs(vSendGift) do
    mSendGift[v] = true
  end
  self.m_mSendGift = mSendGift
  local vFavouriteGift = {}
  local vCampGift = {}
  local vNormalGift = {}
  local vOtherCampGift = {}
  local itemInfo, vUse
  for k, v in ipairs(vGiftList) do
    itemInfo = ItemCfgIns:GetValue_ByItemID(v.iID)
    vUse = string.split(itemInfo.m_ItemUse, ";")
    local iCamp = tonumber(vUse[1])
    local itemData = ResourceUtil:GetProcessRewardData({
      iID = v.iID,
      iNum = v.iNum
    })
    itemData.iFavAdd = tonumber(vUse[3])
    itemData.iNormalAdd = tonumber(vUse[2])
    itemData.in_bag = false
    if mSendGift[v.iID] then
      itemData.bFavourite = true
      vFavouriteGift[#vFavouriteGift + 1] = itemData
    elseif 0 < iCamp and iCamp ~= 6 then
      itemData.iCamp = iCamp
      if iCamp == iCharCamp then
        itemData.isSameCamp = true
        vCampGift[#vCampGift + 1] = itemData
      else
        itemData.isOtherCamp = true
        vOtherCampGift[#vOtherCampGift + 1] = itemData
      end
    else
      vNormalGift[#vNormalGift + 1] = itemData
    end
  end
  
  local function sortFunc(a, b)
    if a.quality == b.quality then
      return a.data_id < b.data_id
    end
    return a.quality > b.quality
  end
  
  if 1 < #vNormalGift then
    table.sort(vNormalGift, sortFunc)
  end
  if 1 < #vCampGift then
    table.sort(vCampGift, sortFunc)
  end
  if 1 < #vFavouriteGift then
    table.sort(vFavouriteGift, sortFunc)
  end
  if 1 < #vOtherCampGift then
    table.sort(vOtherCampGift, sortFunc)
  end
  self.m_vGiftList = {}
  table.insertto(self.m_vGiftList, vFavouriteGift)
  table.insertto(self.m_vGiftList, vCampGift)
  table.insertto(self.m_vGiftList, vNormalGift)
  table.insertto(self.m_vGiftList, vOtherCampGift)
  self.m_mSelectCount = {}
  for k, v in ipairs(self.m_vGiftList) do
    self.m_mSelectCount[k] = {
      cur = 0,
      max = v.data_num,
      id = v.data_id,
      iCamp = v.iCamp,
      isSameCamp = v.isSameCamp,
      isOtherCamp = v.isOtherCamp
    }
  end
  self.m_giftInfinityGrid:ShowItemList(self.m_vGiftList)
  if 0 < #self.m_vGiftList then
    self.m_img_bg_empty:SetActive(false)
  else
    self.m_img_bg_empty:SetActive(true)
  end
end

function Form_AttractMain:SwitchUI(bMain)
  self.m_bMain = bMain
  if bMain then
    self.m_pnl_attract:SetActive(true)
    self.m_pnl_precent:SetActive(false)
  else
    self:FreshRankGift()
    self.m_pnl_attract:SetActive(false)
    self.m_pnl_precent:SetActive(true)
    GlobalManagerIns:TriggerWwiseBGMState(68)
  end
end

function Form_AttractMain:OnBtnmarkClicked()
  local serverData = self.m_curShowHeroData.serverData
  if serverData.bLove == false then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40050)
  end
  HeroManager:ReqHeroSetLove(serverData.iHeroId, not serverData.bLove)
end

function Form_AttractMain:OnBtncanonClicked()
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTBOOK, {
    curShowHeroData = self.m_curShowHeroData
  })
end

function Form_AttractMain:OnBtnprecentClicked()
  if self.m_maxLevelRank then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40033)
    return
  end
  if self.m_needBreakLevelRank then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40032)
    return
  end
  self:SwitchUI(false)
end

function Form_AttractMain:CheckRecycleCurSpine()
  if not self.m_curHeroSpineObj then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
  self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
  self.m_curHeroSpineObj = nil
end

function Form_AttractMain:OnBackClk()
  if self.m_pnl_precent.activeSelf then
    self:ClearSelect()
    self:FreshRankGift()
    self:UpdateSendButtonStatus()
    self.m_giftInfinityGrid:LocateTo(1)
    self:SwitchUI(true)
  else
    if self.m_closeBackFun then
      local heroID = self.m_curShowHeroData.serverData.iHeroId
      self.m_closeBackFun(heroID)
    end
    self:CheckRecycleCurSpine()
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ATTRACTMAIN)
  end
end

function Form_AttractMain:UpdateSendButtonStatus()
  local bCanSend = false
  for k, v in pairs(self.m_mSelectCount) do
    if v.cur > 0 then
      bCanSend = true
      break
    end
  end
  self.m_btn_send:SetActive(not bCanSend)
  self.m_btn_send_light:SetActive(bCanSend)
  if bCanSend then
    self.m_img_arrow:SetActive(true)
    self.m_txt_rank_after_num:SetActive(true)
    self.m_btn_reset_gray:SetActive(false)
    self.m_btn_reset:SetActive(true)
  else
    self.m_img_arrow:SetActive(false)
    self.m_txt_rank_after_num:SetActive(false)
    self.m_btn_reset_gray:SetActive(true)
    self.m_btn_reset:SetActive(false)
  end
end

function Form_AttractMain:OnItemLongClk(itemId)
  utils.openItemDetailPop({iID = itemId, iNum = 1})
end

function Form_AttractMain:OnGiftItemClk(index, curGiftItem, itemIcon)
  local selectInfo = self.m_mSelectCount[index + 1]
  local oldCount = selectInfo.cur
  if oldCount >= selectInfo.max then
    return
  end
  if self.m_maxLevel then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40033)
    return
  end
  if self.m_needBreakLevel then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40032)
    return
  end
  self:SetUpGradeNum(itemIcon, index + 1, oldCount + 1)
  self.m_mSelectCount[index + 1].cur = oldCount + 1
  if self:IsFavoriteGift(selectInfo.id, index + 1) then
    self:ChangeExp(self.m_vGiftList[index + 1].iFavAdd)
  else
    self:ChangeExp(self.m_vGiftList[index + 1].iNormalAdd)
  end
  self:UpdateSendButtonStatus()
end

function Form_AttractMain:OnItemDeleteClk(index, curGiftItem, itemIcon)
  local selectInfo = self.m_mSelectCount[index + 1]
  local oldCount = selectInfo.cur
  if oldCount <= 0 then
    return
  end
  self:SetUpGradeNum(itemIcon, index + 1, oldCount - 1)
  self.m_mSelectCount[index + 1].cur = oldCount - 1
  if self:IsFavoriteGift(selectInfo.id, index + 1) then
    self:ChangeExp(-self.m_vGiftList[index + 1].iFavAdd)
  else
    self:ChangeExp(-self.m_vGiftList[index + 1].iNormalAdd)
  end
  self:UpdateSendButtonStatus()
end

function Form_AttractMain:IsFavoriteGift(giftID, index)
  return self.m_mSendGift[giftID] or self.m_mSelectCount[index].isSameCamp == true
end

function Form_AttractMain:OnBackHome()
  self:CheckRecycleCurSpine()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_AttractMain:OnRefreshHeroSpine()
  if not self.m_curShowHeroData then
    return
  end
  local heroCfg = self.m_curShowHeroData.characterCfg
  if heroCfg.m_HeroID == 0 then
    return
  end
  self:ShowHeroSpine(heroCfg.m_Spine)
end

function Form_AttractMain:SetUpGradeNum(itemIcon, index, num)
  self.m_vGiftList[index].select_num = num
  if itemIcon then
    itemIcon:SetUpGradeNum(num)
  end
end

function Form_AttractMain:ClearSelect()
  for k, v in pairs(self.m_mSelectCount) do
    if v.cur > 0 then
      local itemIcon = self.m_giftInfinityGrid:GetShowItemByIndex(k)
      if itemIcon then
        self:SetUpGradeNum(itemIcon.m_itemIcon, k, 0)
      else
        self:SetUpGradeNum(nil, k, 0)
      end
    end
    self.m_mSelectCount[k].cur = 0
  end
end

function Form_AttractMain:OnBtnresetClicked()
  self:ClearSelect()
  self:FreshRankGift()
  self:UpdateSendButtonStatus()
end

function Form_AttractMain:OnBtnautoselectClicked()
  if self.m_maxLevel then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40033)
    return
  end
  if self.m_needBreakLevel then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40032)
    return
  end
  local offset = self.m_nextExpGift - self.m_curExpGift
  if offset <= 0 then
    return
  end
  local autoSelect = {}
  local totalChangeExp = 0
  for k, v in ipairs(self.m_mSelectCount) do
    if offset < 0 then
      break
    end
    while v.cur < v.max and 0 < offset do
      autoSelect[k] = (autoSelect[k] or 0) + 1
      if self:IsFavoriteGift(v.id, k) then
        totalChangeExp = totalChangeExp + self.m_vGiftList[k].iFavAdd
        offset = offset - self.m_vGiftList[k].iFavAdd
      else
        totalChangeExp = totalChangeExp + self.m_vGiftList[k].iNormalAdd
        offset = offset - self.m_vGiftList[k].iNormalAdd
      end
      v.cur = v.cur + 1
    end
  end
  for k, v in pairs(autoSelect) do
    local itemIcon = self.m_giftInfinityGrid:GetShowItemByIndex(k)
    if itemIcon then
      self:SetUpGradeNum(itemIcon.m_itemIcon, k, self.m_mSelectCount[k].cur)
    else
      self:SetUpGradeNum(nil, k, self.m_mSelectCount[k].cur)
    end
  end
  self:ChangeExp(totalChangeExp)
  self:UpdateSendButtonStatus()
end

function Form_AttractMain:OnBtnsendClicked()
end

function Form_AttractMain:OnBtnsendlightClicked()
  local vGift = {}
  local totalAddExp = 0
  local hasFavGift = false
  local hasCampGift = false
  local favList = utils.changeCSArrayToLuaTable(self.m_curShowHeroData.characterCfg.m_GiftID)
  local favDict = {}
  for k, v in ipairs(favList) do
    favDict[v] = true
  end
  local hasOtherCamp = false
  for k, v in pairs(self.m_mSelectCount) do
    if 0 < v.cur then
      vGift[#vGift + 1] = {
        iID = v.id,
        iNum = v.cur
      }
      if favDict[v.id] then
        hasFavGift = true
      elseif v.isSameCamp == true then
        hasCampGift = true
      else
        if v.isOtherCamp == true then
          hasOtherCamp = true
        else
        end
      end
    end
  end
  if #vGift == 0 then
    return
  end
  
  local function _sendGift()
    AttractManager:ReqSendGift(self.m_curShowHeroData.serverData.iHeroId, vGift, function(bRankChange, iAddExp)
      if bRankChange then
        local m_voice = ""
        local m_FavorText = ""
        local serverData = self.m_curShowHeroData.serverData
        local nextExpInfo = self.m_expList[serverData.iAttractRank + 1]
        if nextExpInfo == nil or nextExpInfo.breakCondition > 0 and serverData.iBreak < nextExpInfo.breakCondition then
          m_voice, m_FavorText = HeroManager:GetHeroFavorLeveuUpMaxVoice(self.m_curShowHeroData.serverData.iHeroId)
        else
          m_voice, m_FavorText = HeroManager:GetHeroFavorLeveuUpVoice(self.m_curShowHeroData.serverData.iHeroId)
        end
        self:StopCurPlayingVoice()
        self.m_vVoiceText = {
          {voice = m_voice, subtitle = m_FavorText}
        }
        self:PlayVoice(self.m_vVoiceText[self.m_playSubIndex])
      end
      if hasFavGift then
        if not bRankChange then
          self:StopCurPlayingVoice()
          self.m_vVoiceText = {
            {
              voice = self.m_curShowHeroData.characterCfg.m_FavorVoice,
              subtitle = self.m_curShowHeroData.characterCfg.m_mFavorText
            }
          }
          self:PlayVoice(self.m_vVoiceText[self.m_playSubIndex])
        end
        self:PlayFavouriteEffect()
      elseif hasCampGift then
        if not bRankChange then
          self:StopCurPlayingVoice()
          self.m_vVoiceText = {
            {
              voice = self.m_curShowHeroData.characterCfg.m_CampVoice,
              subtitle = self.m_curShowHeroData.characterCfg.m_mCampText
            }
          }
          self:PlayVoice(self.m_vVoiceText[self.m_playSubIndex])
        end
        self:PlayFavouriteEffect()
      end
      self.m_attractInfo = AttractManager:GetHeroAttractById(self.m_curShowHeroData.serverData.iHeroId) or {}
      if bRankChange then
        self:ShowAttractLevelUp()
        self:FreshAttractMain()
      else
        self:ShowAttractTips(iAddExp)
        self:FreshRankInfo()
      end
      self:FreshGiftMain()
    end)
  end
  
  if hasOtherCamp then
    utils.CheckAndPushCommonTips({
      tipsID = 1224,
      func1 = function()
        _sendGift()
      end
    })
  else
    _sendGift()
  end
end

function Form_AttractMain:PlayFavouriteEffect()
  self.m_UIFX_AttracMain1:SetActive(false)
  self.m_UIFX_AttracMain1:SetActive(true)
  GlobalManagerIns:TriggerWwiseBGMState(69)
end

function Form_AttractMain:ShowHeroSpine(heroSpinePathStr, isEnterFresh)
  self:CheckRecycleCurSpine()
  local typeStr = SpinePlaceCfg.HeroDetail
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
    self:CheckRecycleCurSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack(isEnterFresh)
    local spineStr = self.m_curHeroSpineObj.spineStr
    TimeService:SetTimer(0.1, 1, function()
      if self.m_spineClick then
        self.m_spineClick:BindingSpine("hero_place_" .. spineStr .. "," .. typeStr .. "," .. spineStr)
      end
    end)
  end)
end

function Form_AttractMain:OnLoadSpineBack(isEnterFresh)
  if not self.m_curHeroSpineObj then
    return
  end
  local spineObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spineObj, true)
  local spineRootTrans = self.m_curHeroSpineObj.spineTrans
  self.m_spineDitherExtension = spineRootTrans:GetComponent("SpineDitherExtension")
  if self.m_dragEndTimer then
    local leftTime = TimeService:GetTimerLeftTime(self.m_dragEndTimer)
    if leftTime and 0 < leftTime then
      self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
      self.m_spineDitherExtension:SetToDither(1.0, 0.0, leftTime)
      if self.m_dragEndTimer then
        TimeService:KillTimer(self.m_dragEndTimer)
        self.m_dragEndTimer = nil
      end
      self.m_dragEndTimer = TimeService:SetTimer(leftTime, 1, function()
        self:CheckKillDragDoTween()
        self.m_dragEndTimer = nil
      end)
    else
      self.m_spineDitherExtension:StopToDither(true)
      self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
    end
  else
    self.m_spineDitherExtension:StopToDither(true)
    self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
  end
  self:CheckShowSpineEnterAnim(isEnterFresh)
  self:FreshShowSpineMaskAndGray()
end

function Form_AttractMain:CheckShowSpineEnterAnim(isEnterFresh)
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpineTrans = self.m_curHeroSpineObj.spineTrans
  if not heroSpineTrans then
    return
  end
  UILuaHelper.SpineResetInit(heroSpineTrans)
  if heroSpineTrans:GetComponent("SpineSkeletonPosControl") then
    heroSpineTrans:GetComponent("SpineSkeletonPosControl"):OnResetInit()
  end
  if isEnterFresh then
    UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, "chuchang2", false, false, function()
      self:SpinePlayRandomAnim()
    end)
  else
    self:SpinePlayRandomAnim()
  end
end

function Form_AttractMain:SpinePlayRandomAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpine = self.m_curHeroSpineObj.spineObj
  if not heroSpine or UILuaHelper.IsNull(heroSpine) then
    return
  end
  local actions = {"idle", "touch"}
  local action = actions[math.random(1, 2)]
  UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, "idle", false, false, function()
    if UILuaHelper.IsNull(heroSpine) then
      return
    end
    UILuaHelper.SpinePlayAnimWithBack(heroSpine, 0, action, false, false, function()
      self:SpinePlayRandomAnim()
    end)
  end)
end

function Form_AttractMain:FreshShowSpineMaskAndGray()
  local tempTabSpinCfg = ShowTabHeroPos[HeroTagCfg.Attract]
  if not tempTabSpinCfg then
    return
  end
  local isMaskAndGray = tempTabSpinCfg.isMaskAndGray
  if self.m_spineDitherExtension and not UILuaHelper.IsNull(self.m_spineDitherExtension) and isMaskAndGray ~= nil then
    self.m_spineDitherExtension:SetSpineMaskAndGray(isMaskAndGray)
    if self.m_curHeroSpineObj then
      local spineObj = self.m_curHeroSpineObj.spineObj
      if spineObj then
        if isMaskAndGray then
          UILuaHelper.SetSpineTimeScale(spineObj, 0)
        else
          UILuaHelper.SetSpineTimeScale(spineObj, 1)
        end
      end
    end
  end
end

function Form_AttractMain:CheckShowPrevHero()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(false, function()
    local toHeroIndex
    local curChooseHeroIndex = self.m_curChooseHeroIndex
    while true do
      toHeroIndex = curChooseHeroIndex - 1
      if toHeroIndex <= 0 then
        toHeroIndex = #self.m_allHeroList
      end
      local curShowHeroData = self.m_allHeroList[toHeroIndex]
      if curShowHeroData == nil then
        return
      end
      if 0 < curShowHeroData.characterCfg.m_AttractAddTemplate then
        break
      end
      curChooseHeroIndex = toHeroIndex
    end
    self:TryChangeCurHero(toHeroIndex)
  end)
end

function Form_AttractMain:CheckShowNextHero()
  self:CheckKillDragDoTween(true)
  self:CheckShowDragTween(true, function()
    local toHeroIndex
    local curChooseHeroIndex = self.m_curChooseHeroIndex
    while true do
      toHeroIndex = curChooseHeroIndex + 1
      if toHeroIndex > #self.m_allHeroList then
        toHeroIndex = 1
      end
      local curShowHeroData = self.m_allHeroList[toHeroIndex]
      if curShowHeroData == nil then
        return
      end
      if curShowHeroData.characterCfg.m_AttractAddTemplate > 0 then
        break
      end
      curChooseHeroIndex = toHeroIndex
    end
    self:TryChangeCurHero(toHeroIndex)
  end)
end

function Form_AttractMain:CheckKillDragDoTween(isJustKillTween)
  if self.m_dragTween and self.m_dragTween:IsPlaying() then
    self.m_dragTween:Kill()
  end
  self.m_dragTween = nil
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
  self.m_UILockID = nil
  if not isJustKillTween then
    local typePos = self:GetCurrentTypePos()
    UILuaHelper.SetLocalPosition(self.m_root_hero, typePos[1], typePos[2], typePos[3])
    if self.m_spineDitherExtension then
      self.m_spineDitherExtension.DitherNum = 0
      self.m_spineDitherExtension:SetUseAlphaClipToggle(false)
    end
  end
end

function Form_AttractMain:GetCurrentTypePos()
  local heroPosTab = ShowTabHeroPos[HeroTagCfg.Attract]
  if not heroPosTab then
    return
  end
  return heroPosTab.position
end

function Form_AttractMain:CheckShowDragTween(isLeft, midBackFun)
  local dragPosX = isLeft and DragLeftPosNum or DragRightPosNum
  local typePos = self:GetCurrentTypePos()
  local changePos = {
    x = dragPosX,
    y = typePos[2],
    z = 0
  }
  local toTween = self.m_root_hero.transform:DOLocalMove(changePos, DragTweenTime)
  local backPos = {
    x = typePos[1],
    y = typePos[2],
    z = typePos[3]
  }
  local backTween = self.m_root_hero.transform:DOLocalMove(backPos, DragTweenBackTime)
  self.m_dragTween = CS.DG.Tweening.DOTween.Sequence()
  self.m_dragTween:Append(toTween)
  self.m_dragTween:Append(backTween)
  self.m_dragTween:PlayForward()
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
    self.m_spineDitherExtension:SetToDither(self.m_spineDitherExtension.DitherNum, 1, DragTweenTime)
  end
  self.m_dragTween:PlayForward()
  if self.m_dragTimer then
    TimeService:KillTimer(self.m_dragTimer)
    self.m_dragTimer = nil
  end
  self.m_UILockID = UILockIns:Lock(DragTweenTime + DragTweenBackTime)
  self.m_dragTimer = TimeService:SetTimer(DragTweenTime, 1, function()
    self.m_dragTimer = nil
    if midBackFun then
      midBackFun()
    end
  end)
  if self.m_dragEndTimer then
    TimeService:KillTimer(self.m_dragEndTimer)
    self.m_dragEndTimer = nil
  end
  self.m_dragEndTimer = TimeService:SetTimer(DragTweenTime + DragTweenBackTime, 1, function()
    self:CheckKillDragDoTween()
    self.m_dragEndTimer = nil
  end)
end

function Form_AttractMain:CheckShowDragBackTween()
  if self.m_dragTimer then
    TimeService:KillTimer(self.m_dragTimer)
    self.m_dragTimer = nil
  end
  self.m_UILockID = UILockIns:Lock(DragTweenTime)
  local typePos = self:GetCurrentTypePos()
  local backPos = {
    x = typePos[1],
    y = typePos[2],
    z = typePos[3]
  }
  self.m_dragTween = self.m_root_hero.transform:DOLocalMove(backPos, DragTweenBackTime)
  self.m_dragTween:PlayForward()
  self.m_dragTimer = TimeService:SetTimer(DragTweenTime, 1, function()
    self.m_dragTimer = nil
    self:CheckKillDragDoTween()
  end)
end

function Form_AttractMain:OnImgBeginDrag(pointerEventData)
  if not pointerEventData or not self.m_bMain then
    return
  end
  self.m_isDrag = true
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
  self.m_startDragUIPosX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, startPos.x, startPos.y, self.m_groupCam)
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension:SetUseAlphaClipToggle(true)
  end
end

function Form_AttractMain:OnImgEndBDrag(pointerEventData)
  self.m_isDrag = false
  if not pointerEventData or not self.m_bMain then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_startDragPos.x
  local absDeltaNum = math.abs(deltaNum)
  if absDeltaNum < DragLimitNum then
    self:CheckShowDragBackTween()
    return
  end
  if 0 < deltaNum then
    self:CheckShowPrevHero()
  else
    self:CheckShowNextHero()
  end
  self.m_startDragPos = nil
  self.m_startDragUIPosX = nil
end

function Form_AttractMain:OnImgDrag(pointerEventData)
  if not pointerEventData or not self.m_bMain then
    return
  end
  if not self.m_startDragUIPosX then
    return
  end
  local dragPos = pointerEventData.position
  local curTypePos = self:GetCurrentTypePos()
  local startDragUIPosX = self.m_startDragUIPosX
  local localX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, dragPos.x, dragPos.y, self.m_groupCam)
  local deltaX = localX - startDragUIPosX
  local deltaAbsNum = math.abs(deltaX)
  if deltaAbsNum > MaxDragDeltaNum then
    return
  end
  local lerpRate = deltaAbsNum / MaxDragDeltaNum
  local paiRateNum = lerpRate * 3.1415 / 2
  local sinRateNum = math.sin(paiRateNum)
  local inputDeltaNum = sinRateNum * MaxDragDeltaNum
  if deltaX < 0 then
    inputDeltaNum = -inputDeltaNum
  end
  UILuaHelper.SetLocalPosition(self.m_root_hero, curTypePos[1] + inputDeltaNum, curTypePos[2], 0)
  if self.m_spineDitherExtension then
    self.m_spineDitherExtension.DitherNum = lerpRate
  end
end

function Form_AttractMain:TryChangeCurHero(toHeroIndex)
  local curShowHeroData = self.m_allHeroList[toHeroIndex]
  if curShowHeroData == nil then
    return
  end
  
  local function OnDownloadComplete(ret)
    self:PlayTouchDisappearAnimation()
    local tParam = self.m_csui.m_param
    tParam.curShowHeroData = curShowHeroData
    tParam.chooseHeroIndex = toHeroIndex
    self.m_curChooseHeroIndex = toHeroIndex
    self.m_curShowHeroData = self.m_allHeroList[self.m_curChooseHeroIndex]
    self:StopCurPlayingVoice()
    self:ResetInfo()
    self:OnRefreshHeroSpine()
    self:FreshHeroInfo()
    self:FreshAttractMain()
    self:FreshGiftMain()
  end
  
  local vPackage = {}
  vPackage[#vPackage + 1] = {
    sName = tostring(curShowHeroData.characterCfg.m_HeroID),
    eType = DownloadManager.ResourcePackageType.Character
  }
  DownloadManager:DownloadResourceWithUI(vPackage, nil, "UI_Form_AttractMain_ChangeHero_" .. tostring(curShowHeroData.characterCfg.m_HeroID), nil, nil, OnDownloadComplete)
end

function Form_AttractMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_AttractMain", Form_AttractMain)
return Form_AttractMain
