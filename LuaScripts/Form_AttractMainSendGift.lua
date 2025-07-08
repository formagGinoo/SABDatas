local Form_AttractMainSendGift = class("Form_AttractMainSendGift", require("UI/UIFrames/Form_AttractMainSendGiftUI"))

function Form_AttractMainSendGift:SetInitParam(param)
end

function Form_AttractMainSendGift:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  local initGiftGridData = {
    itemClkBackFun = handler(self, self.OnGiftItemClk),
    itemDelClkBackFun = handler(self, self.OnItemDeleteClk),
    itemLongClkBackFun = handler(self, self.OnItemLongClk)
  }
  self.m_giftInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_item_list_InfinityGrid, "Attract/UIAttractGiftItem", initGiftGridData)
  self.m_abilityInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_ScrollView_ability_InfinityGrid, "Attract/UIAttractAbilityItem")
end

function Form_AttractMainSendGift:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:CheckFreshRedDot()
  self:FreshGiftMain()
  self:FreshAttractAttr()
  self:FreshHeroCard()
  AttractManager:SetRaycastOn(false)
  AttractManager:SetOtherModelActive(false)
end

function Form_AttractMainSendGift:OnInactive()
  self.super.OnInactive(self)
end

function Form_AttractMainSendGift:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_AttractMainSendGift:FreshHeroCard()
  local characterCfg = self.m_curShowHeroData.characterCfg
  self.m_txt_hero_name_Text.text = characterCfg.m_mFullName
  self.m_txt_hero_nike_name_Text.text = characterCfg.m_mTitle
end

function Form_AttractMainSendGift:PlayVoice(voiceInfo)
  CS.UI.UILuaHelper.StartPlaySFX(voiceInfo.voice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playSubIndex = self.m_playSubIndex + 1
    local nextVoice = self.m_vVoiceText[self.m_playSubIndex]
    if nextVoice ~= nil then
      self:PlayVoice(nextVoice)
    else
      self.m_playingId = nil
    end
  end)
end

function Form_AttractMainSendGift:StopCurPlayingVoice()
  self.m_playSubIndex = 1
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function Form_AttractMainSendGift:InitData()
  self.m_curShowHeroData = self.m_csui.m_param.curShowHeroData
  self.m_attractInfo = AttractManager:GetHeroAttractById(self.m_curShowHeroData.serverData.iHeroId) or {}
  self.m_expList = AttractManager:GetExpList(self.m_curShowHeroData.characterCfg.m_AttractRankTemplate)
  self.m_oldRank = self.m_curShowHeroData.serverData.iAttractRank
  self.m_maxBreakNum = HeroManager:GetHeroMaxBreakNum(self.m_curShowHeroData.serverData.iHeroId)
end

function Form_AttractMainSendGift:CheckFreshRedDot()
end

function Form_AttractMainSendGift:FreshGiftMain()
  self:FreshRankGift()
  self:FreshGiftList()
  self:UpdateSendButtonStatus()
end

function Form_AttractMainSendGift:FreshRankGift()
  self.m_txt_rank_before_num_Text.text = self.m_curShowHeroData.serverData.iAttractRank
  self.m_startAttractRank = self.m_curShowHeroData.serverData.iAttractRank
  self.m_startExp = self.m_attractInfo.iAttractExp or 0
  self:FreshExpProgressGift(self.m_startAttractRank)
end

function Form_AttractMainSendGift:FreshGiftList()
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
  local ItemCfgIns = ConfigManager:GetConfigInsByName("Item")
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
  self.m_giftInfinityGrid:LocateTo(0)
  if 0 < #self.m_vGiftList then
    self.m_img_bg_empty:SetActive(false)
  else
    self.m_img_bg_empty:SetActive(true)
  end
end

function Form_AttractMainSendGift:UpdateSendButtonStatus()
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

function Form_AttractMainSendGift:FreshExpProgressGift(iAttractRank, iCurExp)
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
  local nextExp = nextExpInfo.exp
  self.m_nextExpGift = nextExp
  self:FreshExpGift(curExp, nextExp, baseExp)
end

function Form_AttractMainSendGift:FreshExpGift(curExp, nextExp, baseExp, bFull)
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

function Form_AttractMainSendGift:GetRankLevelByExp(curExp)
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

function Form_AttractMainSendGift:ChangeExp(changeValue)
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

function Form_AttractMainSendGift:FreshAttractAttr()
  local serverData = self.m_curShowHeroData.serverData
  local iAttractAddTemplate = self.m_curShowHeroData.characterCfg.m_AttractAddTemplate
  local AttractAddCfgIns = ConfigManager:GetConfigInsByName("AttractAdd")
  local iPropertyID = AttractAddCfgIns:GetValue_ByAttractAddTemplateIDAndRankID(iAttractAddTemplate, serverData.iAttractRank).m_PropertyID
  local attractAttrInfoList = AttractManager:GetBaseAttr(iPropertyID)
  self.m_abilityInfinityGrid:ShowItemList(attractAttrInfoList)
end

function Form_AttractMainSendGift:ClearSelect()
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

function Form_AttractMainSendGift:SetUpGradeNum(itemIcon, index, num)
  self.m_vGiftList[index].select_num = num
  if itemIcon then
    itemIcon:SetUpGradeNum(num)
  end
end

function Form_AttractMainSendGift:IsFavoriteGift(giftID, index)
  return self.m_mSendGift[giftID] or self.m_mSelectCount[index].isSameCamp == true
end

function Form_AttractMainSendGift:PlayFavouriteEffect()
  GlobalManagerIns:TriggerWwiseBGMState(69)
end

function Form_AttractMainSendGift:ShowAttractLevelUp()
  local newRank = self.m_curShowHeroData.serverData.iAttractRank
  StackFlow:Push(UIDefines.ID_FORM_ATTRACTLEVELUP, {
    curShowHeroData = self.m_curShowHeroData,
    iOldRank = self.m_oldRank,
    iNewRank = newRank
  })
  self.m_oldRank = self.m_curShowHeroData.serverData.iAttractRank
end

function Form_AttractMainSendGift:ShowAttractTips(totalAddExp)
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

function Form_AttractMainSendGift:OnGiftItemClk(index, curGiftItem, itemIcon)
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

function Form_AttractMainSendGift:OnItemDeleteClk(index, curGiftItem, itemIcon)
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

function Form_AttractMainSendGift:OnItemLongClk(itemId)
  utils.openItemDetailPop({iID = itemId, iNum = 1})
end

function Form_AttractMainSendGift:OnBtnautoselectClicked()
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

function Form_AttractMainSendGift:OnBtnsendClicked()
end

function Form_AttractMainSendGift:OnBtnsendlightClicked()
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
        self:FreshAttractAttr()
      else
        self:ShowAttractTips(iAddExp)
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

function Form_AttractMainSendGift:OnBtnresetClicked()
  self:ClearSelect()
  self:FreshRankGift()
  self:UpdateSendButtonStatus()
end

function Form_AttractMainSendGift:OnBackClk()
  self:ClearSelect()
  self:CloseForm()
end

function Form_AttractMainSendGift:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_AttractMainSendGift", Form_AttractMainSendGift)
return Form_AttractMainSendGift
