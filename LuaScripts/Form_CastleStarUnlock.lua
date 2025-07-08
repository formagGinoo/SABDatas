local Form_CastleStarUnlock = class("Form_CastleStarUnlock", require("UI/UIFrames/Form_CastleStarUnlockUI"))
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local MaxHeroCount = 4

function Form_CastleStarUnlock:SetInitParam(param)
end

function Form_CastleStarUnlock:AfterInit()
  self.super.AfterInit(self)
  self:addComponent("UITouchMask")
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1133)
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.listPrefab = self.m_Content:GetComponent("PrefabHelper")
  self.m_multiColor = self.m_txt_effect_Text:GetComponent("MultiColorChange")
  self.m_unlockConditionList = {}
  self.m_unlockConditionList[#self.m_unlockConditionList + 1] = {
    root = self.m_pnl_condition1,
    lock = self.m_pnl_condition_nml1,
    lock_txt = self.m_txt_lock_conditon1_Text,
    unlock = self.m_pnl_condition_complete1,
    unlock_txt = self.m_txt_unlock_conditon1_Text
  }
  self.m_unlockConditionList[#self.m_unlockConditionList + 1] = {
    root = self.m_pnl_condition2,
    lock = self.m_pnl_condition_nml2,
    lock_txt = self.m_txt_lock_conditon2_Text,
    unlock = self.m_pnl_condition_complete2,
    unlock_txt = self.m_txt_unlock_conditon2_Text
  }
  self.m_unlockConditionList[#self.m_unlockConditionList + 1] = {
    root = self.m_pnl_condition3,
    lock = self.m_pnl_condition_nml3,
    lock_txt = self.m_txt_lock_conditon3_Text,
    unlock = self.m_pnl_condition_complete3,
    unlock_txt = self.m_txt_unlock_conditon3_Text
  }
  self.m_observeConditionList = {}
  self.m_observeConditionList[#self.m_observeConditionList + 1] = {
    root = self.m_pnl_ob_condition1,
    lock = self.m_pnl_ob_condition_nml1,
    lock_txt = self.m_txt_ob_lock_conditon1_Text,
    unlock = self.m_pnl_ob_condition_complete1,
    unlock_txt = self.m_txt_ob_unlock_conditon1_Text
  }
  self.m_observeConditionList[#self.m_observeConditionList + 1] = {
    root = self.m_pnl_ob_condition2,
    lock = self.m_pnl_ob_condition_nml2,
    lock_txt = self.m_txt_ob_lock_conditon2_Text,
    unlock = self.m_pnl_ob_condition_complete2,
    unlock_txt = self.m_txt_ob_unlock_conditon2_Text
  }
  self.m_observeConditionList[#self.m_observeConditionList + 1] = {
    root = self.m_pnl_ob_condition3,
    lock = self.m_pnl_ob_condition_nml3,
    lock_txt = self.m_txt_ob_lock_conditon3_Text,
    unlock = self.m_pnl_ob_condition_complete3,
    unlock_txt = self.m_txt_ob_unlock_conditon3_Text
  }
  self.m_vDotList = {}
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot8,
    select = self.m_img_dotsel8,
    unselect = self.m_img_dotgrey8
  }
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot7,
    select = self.m_img_dotsel7,
    unselect = self.m_img_dotgrey7
  }
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot6,
    select = self.m_img_dotsel6,
    unselect = self.m_img_dotgrey6
  }
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot5,
    select = self.m_img_dotsel5,
    unselect = self.m_img_dotgrey5
  }
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot4,
    select = self.m_img_dotsel4,
    unselect = self.m_img_dotgrey4
  }
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot3,
    select = self.m_img_dotsel3,
    unselect = self.m_img_dotgrey3
  }
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot2,
    select = self.m_img_dotsel2,
    unselect = self.m_img_dotgrey2
  }
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot1,
    select = self.m_img_dotsel1,
    unselect = self.m_img_dotgrey1
  }
  self.m_vDotList[#self.m_vDotList + 1] = {
    root = self.m_pnl_checkdot0,
    select = self.m_img_dotsel0,
    unselect = self.m_img_dotgrey0
  }
  for k, v in ipairs(self.m_vDotList) do
    v.select:SetActive(false)
    v.unselect:SetActive(true)
  end
  self.m_iMaxDot = #self.m_vDotList
  self.m_vDispatchListPnl = {}
  self.m_vDispatchListPnl[#self.m_vDispatchListPnl + 1] = {
    placeholder = self.m_icon_bg1,
    empty = self.m_img_empty1,
    selected = self.m_common_item1,
    lock = self.m_lock1,
    havenot = self.m_img_havent1
  }
  self.m_vDispatchListPnl[#self.m_vDispatchListPnl + 1] = {
    placeholder = self.m_icon_bg2,
    empty = self.m_img_empty2,
    selected = self.m_common_item2,
    lock = self.m_lock2,
    havenot = self.m_img_havent2
  }
  self.m_vDispatchListPnl[#self.m_vDispatchListPnl + 1] = {
    placeholder = self.m_icon_bg3,
    empty = self.m_img_empty3,
    selected = self.m_common_item3,
    lock = self.m_lock3,
    havenot = self.m_img_havent3
  }
  self.m_vDispatchListPnl[#self.m_vDispatchListPnl + 1] = {
    placeholder = self.m_icon_bg4,
    empty = self.m_img_empty4,
    selected = self.m_common_item4,
    lock = self.m_lock4,
    havenot = self.m_img_havent4
  }
end

function Form_CastleStarUnlock:OnOpen()
  self.super.OnOpen(self)
  ReportManager:ReportSystemModuleOpen("Form_CastleStarUnlock")
end

function Form_CastleStarUnlock:AdaptUI(isStarView)
  if isStarView then
    if self.m_starAdapt == nil then
      TimeService:SetTimer(0.1, 1, function()
        self.m_line_effect:GetComponent("RectTransform").sizeDelta = Vector2.New(self.m_pnl_cond_titletips:GetComponent("RectTransform").rect.width - self.m_z_txt_title_effect:GetComponent("RectTransform").rect.width - 60, self.m_line_effect:GetComponent("RectTransform").sizeDelta.y)
        self.m_line_conditions_titlerule:GetComponent("RectTransform").sizeDelta = Vector2.New(self.m_pnl_cond_titlerule:GetComponent("RectTransform").rect.width - self.m_z_txt_title_conditions1:GetComponent("RectTransform").rect.width - 60, self.m_line_conditions_titlerule:GetComponent("RectTransform").sizeDelta.y)
        self.m_line_hero:GetComponent("RectTransform").sizeDelta = Vector2.New(self.m_pnl_cond_titlerole:GetComponent("RectTransform").rect.width - self.m_z_txt_title_hero:GetComponent("RectTransform").rect.width - 60, self.m_line_hero:GetComponent("RectTransform").sizeDelta.y)
        self.m_starAdapt = true
      end)
    end
  elseif self.m_conAdapt == nil then
    TimeService:SetTimer(0.1, 1, function()
      self.m_line_conditions:GetComponent("RectTransform").sizeDelta = Vector2.New(self.m_pnl_cond_title:GetComponent("RectTransform").rect.width - self.m_z_txt_titleefcheck:GetComponent("RectTransform").rect.width - 60, self.m_line_conditions:GetComponent("RectTransform").sizeDelta.y)
      self.m_line_conditionsefcheck:GetComponent("RectTransform").sizeDelta = Vector2.New(self.m_pnl_cond_titleefcheck:GetComponent("RectTransform").rect.width - self.m_z_txt_titleobc:GetComponent("RectTransform").rect.width - 60, self.m_line_conditionsefcheck:GetComponent("RectTransform").sizeDelta.y)
      self.m_conAdapt = true
    end)
  end
end

function Form_CastleStarUnlock:ClearDispatch()
  for k, v in ipairs(self.m_vDispatchListPnl) do
    v.iHeroId = nil
  end
  StargazingManager:ClearDispatchHero()
  self:ClearAllSelect()
  self.m_bNeedRefreshHeroList = true
end

function Form_CastleStarUnlock:RefreshDispatchInfo(mCharacterList)
  self.m_mSelectHero = {}
  for i = 1, MaxHeroCount do
    local dispathInfo = self.m_vDispatchListPnl[i]
    if mCharacterList[i] then
      dispathInfo.iHeroId = mCharacterList[i]
      dispathInfo.selected:SetActive(true)
      dispathInfo.empty:SetActive(false)
      if dispathInfo.m_itemIcon == nil then
        dispathInfo.m_itemIcon = self:createCommonItem(dispathInfo.selected)
      end
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = mCharacterList[i],
        iNum = 1
      })
      dispathInfo.m_itemIcon:SetItemInfo(processItemData)
      if HeroManager:GetHeroDataByID(mCharacterList[i]) then
        self.m_mSelectHero[mCharacterList[i]] = 1
        dispathInfo.havenot:SetActive(false)
      else
        dispathInfo.havenot:SetActive(true)
      end
    else
      dispathInfo.iHeroId = nil
      dispathInfo.selected:SetActive(false)
      dispathInfo.empty:SetActive(false)
      dispathInfo.lock:SetActive(false)
      dispathInfo.placeholder:SetActive(true)
    end
  end
end

function Form_CastleStarUnlock:OnHeroDispatch(iHeroId, isDispatch)
  if isDispatch then
    local dispathInfo
    for k, v in ipairs(self.m_vDispatchListPnl) do
      if v.iHeroId == nil then
        dispathInfo = v
        break
      end
    end
    if dispathInfo then
      dispathInfo.iHeroId = iHeroId
      dispathInfo.selected:SetActive(true)
      dispathInfo.empty:SetActive(false)
      if dispathInfo.m_itemIcon == nil then
        dispathInfo.m_itemIcon = self:createCommonItem(dispathInfo.selected)
      end
      local processItemData = ResourceUtil:GetProcessRewardData({iID = iHeroId, iNum = 1})
      dispathInfo.m_itemIcon:SetItemInfo(processItemData)
      StargazingManager:SetDispatchHero(iHeroId, true)
    end
  else
    local dispathInfo
    for k, v in ipairs(self.m_vDispatchListPnl) do
      if v.iHeroId == iHeroId then
        dispathInfo = v
        break
      end
    end
    if dispathInfo then
      dispathInfo.iHeroId = nil
      dispathInfo.selected:SetActive(false)
      dispathInfo.empty:SetActive(true)
      StargazingManager:SetDispatchHero(iHeroId, false)
    end
  end
end

function Form_CastleStarUnlock:OnActive()
  self.super.OnActive(self)
  self:addEventListener("eGameEvent_Stargazing_ChangeStar", handler(self, self.OnChangeStar))
  self:InitView()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(60)
end

function Form_CastleStarUnlock:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_CastleStarUnlock:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleStarUnlock:InitView()
  local tParam = self.m_csui.m_param
  local iSelectConstellationID, iSelectStarID
  if tParam.iSelectConstellationID then
    iSelectConstellationID = tParam.iSelectConstellationID
  else
    local starInfo = StargazingManager:GetFirstUnlockStarInfo()
    iSelectConstellationID = starInfo.m_ConstellationID
  end
  self.m_bNeedRefreshHeroList = true
  self:ClearAllSelect()
  self:RefreshConstellation(iSelectConstellationID, iSelectStarID)
  self.m_vConstellationList = StargazingManager:GetConstellationList()
  self.m_maxConstellationIndex = #self.m_vConstellationList
  if self.m_maxConstellationIndex < self.m_iMaxDot then
    for i = self.m_maxConstellationIndex + 1, self.m_iMaxDot do
      self.m_vDotList[i].root:SetActive(false)
    end
  end
  self:InitPositionDot()
  self.m_constellationIndex = self:GetConstellationIndex(iSelectConstellationID)
  self:RefreshPositionDot(self:GetDotPos(self.m_constellationIndex))
  self.m_allHeroList = HeroManager:GetHeroList()
end

function Form_CastleStarUnlock:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local list = StargazingManager:GetConstellationList()
  for k, v in ipairs(list) do
    vResourceExtra[#vResourceExtra + 1] = {
      sName = "ui_castle_starmap" .. v.m_ConstellationID,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

function Form_CastleStarUnlock:GetConstellationIndex(iConstellationID)
  for k, v in ipairs(self.m_vConstellationList) do
    if v.m_ConstellationID == iConstellationID then
      return k
    end
  end
  return 1
end

function Form_CastleStarUnlock:InitPositionDot()
  self.m_startPos = 1
  self.m_endPos = 1 + self.m_iMaxDot - 1
end

function Form_CastleStarUnlock:GetDotPos(iPos)
  if iPos < self.m_startPos then
    self.m_startPos = iPos
    self.m_endPos = self.m_startPos + self.m_iMaxDot - 1
  elseif iPos > self.m_endPos then
    self.m_endPos = iPos
    self.m_startPos = self.m_endPos - self.m_iMaxDot + 1
  end
  return iPos - self.m_startPos + 1
end

function Form_CastleStarUnlock:RefreshPositionDot(iDotPos)
  if self.m_prevDotPos then
    self.m_vDotList[self.m_prevDotPos].unselect:SetActive(true)
    self.m_vDotList[self.m_prevDotPos].select:SetActive(false)
  end
  self.m_vDotList[iDotPos].unselect:SetActive(false)
  self.m_vDotList[iDotPos].select:SetActive(true)
  self.m_prevDotPos = iDotPos
end

function Form_CastleStarUnlock:OnBtnleftClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  if self.m_constellationIndex <= 1 then
    self.m_constellationIndex = self.m_maxConstellationIndex
  else
    self.m_constellationIndex = self.m_constellationIndex - 1
  end
  self:RefreshPositionDot(self:GetDotPos(self.m_constellationIndex))
  self:PlayLeftChangeAnimation(true, function()
    self:RefreshConstellation(self.m_vConstellationList[self.m_constellationIndex].m_ConstellationID)
  end)
end

function Form_CastleStarUnlock:OnBtnrightClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  if self.m_constellationIndex >= self.m_maxConstellationIndex then
    self.m_constellationIndex = 1
  else
    self.m_constellationIndex = self.m_constellationIndex + 1
  end
  self:RefreshPositionDot(self:GetDotPos(self.m_constellationIndex))
  self:PlayLeftChangeAnimation(false, function()
    self:RefreshConstellation(self.m_vConstellationList[self.m_constellationIndex].m_ConstellationID)
  end)
end

function Form_CastleStarUnlock:ClearAllSelect()
  self.m_mSelectHero = {}
end

function Form_CastleStarUnlock:RefreshConstellation(iConstellationID, iStarID, iUnlockStarID)
  self.m_isPlayingAnim = false
  self:ClearDispatch()
  local constellationInfo = StargazingManager:GetConstellationInfo(iConstellationID)
  local _iStarID = iStarID
  self.m_pnl_dispath_R:SetActive(false)
  self.m_pnl_dispath_L:SetActive(false)
  self.m_pnl_right:SetActive(false)
  self.m_pnl_left:SetActive(true)
  self.m_pnl_righttitle:SetActive(true)
  self.m_txt_unlocktitle_Text.text = constellationInfo.m_mConstellationName
  self.m_txt_unlockc_Text.text = constellationInfo.m_mConstellationDes
  if not StargazingManager:IsConstellationUnlock(iConstellationID) then
    self.m_txt_constellation_name:SetActive(true)
    self.m_txt_constellation_name_Text.text = constellationInfo.m_mConstellationName
    self.m_txt_star_name:SetActive(false)
    self.m_z_txt_check:SetActive(true)
    self.m_pnl_right:SetActive(true)
    for k, v in ipairs(self.m_unlockConditionList) do
      v.root:SetActive(false)
    end
    self.m_bg_pic:SetActive(false)
    local iUnlockIndex = 1
    local allConidtionSatisfied = true
    local needUnlockPreConstellation = false
    if constellationInfo.m_FrontConstellation > 0 then
      local conditionInfo = self.m_unlockConditionList[iUnlockIndex]
      conditionInfo.root:SetActive(true)
      local preConstellationInfo = StargazingManager:GetConstellationInfo(constellationInfo.m_FrontConstellation)
      local strTips = CommonTextIns:GetValue_ById(100085).m_mMessage
      strTips = string.gsub(strTips, "{0}", preConstellationInfo.m_mConstellationName)
      needUnlockPreConstellation = StargazingManager:IsConstellationAllStarActivate(constellationInfo.m_FrontConstellation) == false
      if needUnlockPreConstellation then
        conditionInfo.lock:SetActive(true)
        conditionInfo.unlock:SetActive(false)
        conditionInfo.lock_txt.text = strTips
        allConidtionSatisfied = false
      else
        conditionInfo.unlock:SetActive(true)
        conditionInfo.lock:SetActive(false)
        conditionInfo.unlock_txt.text = strTips
      end
      iUnlockIndex = iUnlockIndex + 1
    end
    local conditionTypeArray = utils.changeCSArrayToLuaTable(constellationInfo.m_UnlockConditionType)
    local conditionDataArray = utils.changeCSArrayToLuaTable(constellationInfo.m_UnlockConditionData)
    for k, v in ipairs(conditionTypeArray) do
      local conditionInfo = self.m_unlockConditionList[iUnlockIndex]
      conditionInfo.root:SetActive(true)
      if v == 1 then
        conditionInfo.root:SetActive(false)
        break
      elseif v == 3 then
        local stageId = conditionDataArray[k][1]
        local cfg = LevelManager:GetMainLevelCfgById(stageId)
        local strTips = CommonTextIns:GetValue_ById(3).m_mMessage
        strTips = string.gsub(strTips, "{0}", cfg.m_LevelName)
        if LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, stageId) == false then
          conditionInfo.lock_txt.text = strTips
          conditionInfo.unlock:SetActive(false)
          conditionInfo.lock:SetActive(true)
          allConidtionSatisfied = false
        else
          conditionInfo.unlock_txt.text = strTips
          conditionInfo.lock:SetActive(false)
          conditionInfo.unlock:SetActive(true)
        end
      elseif v == 21 then
        local itemId = conditionDataArray[k][1]
        local cfg = ItemManager:GetItemConfigById(itemId)
        local strTips = CommonTextIns:GetValue_ById(21).m_mMessage
        strTips = string.gsub(strTips, "{0}", cfg.m_mItemName)
        if 0 < ItemManager:GetItemNum(itemId) then
          conditionInfo.unlock_txt.text = strTips
          conditionInfo.lock:SetActive(false)
          conditionInfo.unlock:SetActive(true)
        else
          conditionInfo.lock_txt.text = strTips
          conditionInfo.unlock:SetActive(false)
          conditionInfo.lock:SetActive(true)
          allConidtionSatisfied = false
        end
        self.m_bg_pic:SetActive(true)
        local processItemData = ResourceUtil:GetProcessRewardData({iID = itemId, iNum = 1})
        UILuaHelper.SetAtlasSprite(self.m_btn_pic_Image, processItemData.icon_name)
        self.m_unlockItemId = itemId
      end
      iUnlockIndex = iUnlockIndex + 1
    end
    if needUnlockPreConstellation then
      self.m_btn_go:SetActive(true)
      self.m_btn_unlock:SetActive(false)
      self.m_btn_unlock_gray:SetActive(false)
      self.m_btn_unlock_resource:SetActive(false)
    else
      self.m_btn_go:SetActive(false)
      self.m_btn_unlock_resource:SetActive(true)
      local itemConsume = constellationInfo.m_ItemConsume[0]
      self.m_itemConsume = itemConsume
      local bEnough = itemConsume[1] <= ItemManager:GetItemNum(itemConsume[0])
      self.m_bUnlockEnough = bEnough
      self.m_allConidtionSatisfied = allConidtionSatisfied
      if allConidtionSatisfied and bEnough then
        self.m_btn_unlock:SetActive(true)
        self.m_btn_unlock_gray:SetActive(false)
      else
        self.m_btn_unlock:SetActive(false)
        self.m_btn_unlock_gray:SetActive(true)
      end
      UILuaHelper.SetAtlasSprite(self.m_unlock_icon_Image, "Atlas_Item/" .. itemConsume[0])
      self.m_txt_unlock_resource_Text.text = "x" .. itemConsume[1]
      if self.m_unlockOldColor == nil then
        self.m_unlockOldColor = self.m_txt_unlock_resource_Text.color
      end
      if not bEnough then
        self.m_txt_unlock_resource_Text.color = Color.red
      else
        self.m_txt_unlock_resource_Text.color = self.m_unlockOldColor
      end
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_btn_unlock_resource)
    end
    local cfgs = StargazingManager:GetCastleStarTechInfo(iConstellationID)
    utils.ShowPrefabHelper(self.listPrefab, function(go, index, cfg)
      local m_pnl_unlock = go.transform:Find("item_root/pnl_unlock").gameObject
      local m_pnl_lock = go.transform:Find("item_root/pnl_lock").gameObject
      local m_txt_title_lock_Text = go.transform:Find("item_root/pnl_lock/img_starbg/txt_title_lock"):GetComponent("TMPPro")
      local m_txt_desc_lock_Text = go.transform:Find("item_root/pnl_lock/txt_desc_lock"):GetComponent("TMPPro")
      m_pnl_unlock:SetActive(false)
      m_pnl_lock:SetActive(true)
      m_txt_title_lock_Text.text = cfg.m_mStarName
      m_txt_desc_lock_Text.text = cfg.m_mEffectDes
    end, cfgs)
    self:AdaptUI(false)
  else
    self.m_txt_constellation_name:SetActive(true)
    self.m_txt_star_name:SetActive(true)
    self.m_z_txt_check:SetActive(false)
    self.m_txt_constellation_name_Text.text = constellationInfo.m_mConstellationName
    self.m_pnl_dispath_R:SetActive(true)
    if _iStarID == nil then
      _iStarID = StargazingManager:GetFirstUnlockStarInfoByConstellation(iConstellationID)
    end
    for k, v in ipairs(self.m_observeConditionList) do
      v.root:SetActive(false)
    end
    local starInfo = StargazingManager:GetStarInfo(iConstellationID, _iStarID)
    self.m_txt_star_name_Text.text = starInfo.m_mStarName
    local iUnlockIndex = 1
    local allConidtionSatisfied = true
    self.m_txt_effect_Text.text = starInfo.m_mEffectDes
    if 0 < starInfo.m_FrontStar then
      local conditionInfo = self.m_observeConditionList[iUnlockIndex]
      conditionInfo.root:SetActive(true)
      local preStarInfo = StargazingManager:GetStarInfo(nil, starInfo.m_FrontStar)
      local strTips = CommonTextIns:GetValue_ById(100086).m_mMessage
      strTips = string.gsub(strTips, "{0}", preStarInfo.m_mStarName)
      if not StargazingManager:IsStarUnlock(preStarInfo.m_ConstellationID, preStarInfo.m_StarID) then
        conditionInfo.lock:SetActive(true)
        conditionInfo.unlock:SetActive(false)
        conditionInfo.lock_txt.text = strTips
        allConidtionSatisfied = false
      else
        conditionInfo.unlock:SetActive(true)
        conditionInfo.lock:SetActive(false)
        conditionInfo.unlock_txt.text = strTips
      end
      iUnlockIndex = iUnlockIndex + 1
    else
      local conditionInfo = self.m_observeConditionList[iUnlockIndex]
      conditionInfo.root:SetActive(true)
      local preStarInfo = StargazingManager:GetStarInfo(nil, starInfo.m_FrontStar)
      local strTips = CommonTextIns:GetValue_ById(100103).m_mMessage
      conditionInfo.unlock:SetActive(true)
      conditionInfo.lock:SetActive(false)
      conditionInfo.unlock_txt.text = strTips
      iUnlockIndex = iUnlockIndex + 1
    end
    self.m_starUnlockConditionSatisfied = allConidtionSatisfied
    self.m_needDispatchCount = starInfo.m_CharacterCount
    for k, v in ipairs(self.m_vDispatchListPnl) do
      if k <= self.m_needDispatchCount then
        v.placeholder:SetActive(false)
        v.lock:SetActive(false)
        v.empty:SetActive(true)
        v.selected:SetActive(false)
      else
        v.placeholder:SetActive(true)
        v.lock:SetActive(false)
        v.empty:SetActive(false)
        v.selected:SetActive(false)
      end
    end
    local mCharacterList = utils.changeCSArrayToLuaTable(starInfo.m_CharacterList)
    self:RefreshDispatchInfo(mCharacterList)
    if StargazingManager:IsStarUnlock(iConstellationID, _iStarID) then
      self.m_btn_confirm:SetActive(false)
      self.m_btn_confirm_gray:SetActive(false)
      self.m_btn_observe_resource:SetActive(false)
      self.m_img_complete:SetActive(true)
      if not StargazingManager:IsAllStarUnlock() then
        self.m_btn_go_star:SetActive(true)
      else
        self.m_btn_go_star:SetActive(false)
      end
      self.m_multiColor:SetColorByIndex(1)
    else
      self.m_img_complete:SetActive(false)
      self.m_btn_confirm:SetActive(false)
      self.m_btn_confirm_gray:SetActive(false)
      self.m_btn_observe_resource:SetActive(false)
      self.m_multiColor:SetColorByIndex(0)
      if allConidtionSatisfied then
        self.m_btn_go_star:SetActive(false)
        self.m_btn_confirm_gray:SetActive(true)
        if starInfo.m_ItemConsume.Length == 0 then
          self.m_bObserveEnough = true
        else
          self.m_btn_observe_resource:SetActive(true)
          local itemConsume = starInfo.m_ItemConsume[0]
          local bEnough = itemConsume[1] <= ItemManager:GetItemNum(itemConsume[0])
          self.m_bObserveEnough = bEnough
          self.m_itemConsume = itemConsume
          UILuaHelper.SetAtlasSprite(self.m_observe_icon_Image, "Atlas_Item/" .. itemConsume[0])
          self.m_txt_observe_resource_Text.text = "x" .. itemConsume[1]
          if self.m_observeOldColor == nil then
            self.m_observeOldColor = self.m_txt_observe_resource_Text.color
          end
          if not bEnough then
            self.m_txt_observe_resource_Text.color = Color.red
          else
            self.m_txt_observe_resource_Text.color = self.m_observeOldColor
          end
          UILuaHelper.ForceRebuildLayoutImmediate(self.m_btn_observe_resource)
        end
        self:RefreshObserveStatus()
      else
        for k, v in ipairs(self.m_vDispatchListPnl) do
          if k <= self.m_needDispatchCount then
            v.placeholder:SetActive(false)
            v.lock:SetActive(true)
            v.empty:SetActive(false)
            v.selected:SetActive(false)
          end
        end
        self.m_btn_go_star:SetActive(true)
      end
    end
    self:AdaptUI(true)
  end
  self.m_iSelectStarID = _iStarID
  if iConstellationID == self.m_iSelectConstellationID then
    if self.m_subPanelLua then
      self.m_subPanelLua:FreshStarInfo(_iStarID)
    end
    return
  end
  self.m_iSelectConstellationID = iConstellationID
  if self.m_oldUiObject then
    CS.UnityEngine.Object.DestroyImmediate(self.m_oldUiObject)
    self.m_oldUiObject = nil
  end
  self.m_subPanelLua = nil
  self:setTouchMaskEnabled(true)
  local prefabName = "ui_castle_starmap" .. iConstellationID
  UIManager:LoadUIPrefab(prefabName, function(nameStr, uiObject)
    local luaPath = "UI/SubPanel/CastleStarUnlockSubPanel"
    self.m_oldUiObject = uiObject
    self.m_subPanelLua = require(luaPath).new()
    self.m_subPanelLua:Init(self.m_pnl_constellation, uiObject, self, nil, {iConstellationID = iConstellationID, iStarID = _iStarID})
    self:setTouchMaskEnabled(false)
  end, function(errorStr)
    log.info("Form_CastleStarUnlock LoadConstellation Fail errorStr: ", errorStr)
  end)
end

function Form_CastleStarUnlock:RefreshObserveStatus()
  if self.m_bObserveEnough == false or self.m_starUnlockConditionSatisfied == false then
    return
  end
  local dispatchCount = 0
  for k, v in pairs(self.m_mSelectHero) do
    dispatchCount = dispatchCount + 1
  end
  if dispatchCount >= self.m_needDispatchCount then
    self.m_btn_confirm:SetActive(true)
    self.m_btn_confirm_gray:SetActive(false)
  else
    self.m_btn_confirm:SetActive(false)
    self.m_btn_confirm_gray:SetActive(true)
  end
end

function Form_CastleStarUnlock:CloseDispatchView()
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_dispath_L, "CastleStarUnlock_pnl_L_out")
  UILuaHelper.PlayAnimationByName(self.m_pnl_dispath_L, "CastleStarUnlock_pnl_L_out")
  self.m_dispatchTimer = TimeService:SetTimer(animLen, 1, function()
    self.m_pnl_dispath_L:SetActive(false)
    self.m_pnl_left:SetActive(true)
  end)
end

function Form_CastleStarUnlock:PlayLeftChangeAnimation(toLeft, callback)
  if self.m_starmapTimer then
    TimeService:KillTimer(self.m_starmapTimer)
    self.m_starmapTimer = nil
    if toLeft then
      UILuaHelper.PlayAnimationByName(self.m_pnl_constellation, "castle_starmap_L_in")
    else
      UILuaHelper.PlayAnimationByName(self.m_pnl_constellation, "castle_starmap_R_in")
    end
    if callback then
      callback()
    end
    return
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_constellation, "castle_starmap_out")
  UILuaHelper.PlayAnimationByName(self.m_pnl_constellation, "castle_starmap_out")
  self.m_starmapTimer = TimeService:SetTimer(animLen, 1, function()
    if toLeft then
      UILuaHelper.PlayAnimationByName(self.m_pnl_constellation, "castle_starmap_L_in")
    else
      UILuaHelper.PlayAnimationByName(self.m_pnl_constellation, "castle_starmap_R_in")
    end
    self.m_starmapTimer = nil
    if callback then
      callback()
    end
  end)
end

function Form_CastleStarUnlock:PlayRightChangeAnimation(isDispatch)
end

function Form_CastleStarUnlock:OnBtnunlockresourceClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  utils.openItemDetailPop({
    iID = self.m_itemConsume[0],
    iNum = 1
  })
end

function Form_CastleStarUnlock:OnBtnobserveresourceClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  utils.openItemDetailPop({
    iID = self.m_itemConsume[0],
    iNum = 1
  })
end

function Form_CastleStarUnlock:OnBtnplantClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  StackFlow:Push(UIDefines.ID_FORM_CASTLESTARMAIN, {
    iConstellationID = self.m_iSelectConstellationID
  })
end

function Form_CastleStarUnlock:OnBtngoClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  local starInfo = StargazingManager:GetFirstUnlockStarInfo()
  local iSelectConstellationID = starInfo.m_ConstellationID
  local toLeft = false
  if iSelectConstellationID < self.m_iSelectConstellationID then
    toLeft = true
  end
  self:PlayLeftChangeAnimation(toLeft, function()
    self:RefreshConstellation(iSelectConstellationID)
    self.m_constellationIndex = self:GetConstellationIndex(iSelectConstellationID)
    self:RefreshPositionDot(self:GetDotPos(self.m_constellationIndex))
  end)
end

function Form_CastleStarUnlock:OnBtngostarClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  local starInfo = StargazingManager:GetFirstUnlockStarInfo()
  local iSelectConstellationID = starInfo.m_ConstellationID
  local toLeft = false
  if iSelectConstellationID < self.m_iSelectConstellationID then
    toLeft = true
  end
  local needJump = false
  if iSelectConstellationID ~= self.m_iSelectConstellationID then
    needJump = true
  end
  if needJump then
    self:PlayLeftChangeAnimation(toLeft, function()
      self:RefreshConstellation(iSelectConstellationID)
      self.m_constellationIndex = self:GetConstellationIndex(iSelectConstellationID)
      self:RefreshPositionDot(self:GetDotPos(self.m_constellationIndex))
    end)
  else
    self:RefreshConstellation(iSelectConstellationID)
  end
end

function Form_CastleStarUnlock:OnBtnunlockClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  StargazingManager:ReqUnlockConstella(self.m_iSelectConstellationID, function()
    if self.m_subPanelLua then
      self.m_subPanelLua:PlayConstellaUnlockAnimation()
    end
    self:RefreshConstellation(self.m_iSelectConstellationID)
  end)
end

function Form_CastleStarUnlock:OnBtnunlockgrayClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  if self.m_allConidtionSatisfied == false then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20050)
    return
  end
  if self.m_bUnlockEnough == false then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20053)
    return
  end
end

function Form_CastleStarUnlock:OnBtnconfirmClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  if self.m_isPlayingAnim then
    return
  end
  local vHero = {}
  for k, v in pairs(self.m_mSelectHero) do
    vHero[#vHero + 1] = k
  end
  self:CloseDispatchView()
  StargazingManager:ReqSeeStar(self.m_iSelectConstellationID, self.m_iSelectStarID, vHero, function(iUnlockStarID)
    StackPopup:Push(UIDefines.ID_FORM_CASTLESTAREXCITINGWINDOW, {
      id = self.m_iSelectConstellationID,
      starId = self.m_iSelectStarID,
      callback = function()
        self.m_isPlayingAnim = true
        local starInfo = StargazingManager:GetFirstUnlockStarInfo()
        iSelectConstellationID = starInfo.m_ConstellationID
        iSelectStarID = starInfo.m_StarID
        self:ClearDispatch()
        
        local function _next()
          if iSelectConstellationID ~= self.m_iSelectConstellationID then
            self:PlayLeftChangeAnimation(false, function()
              self.m_constellationIndex = self:GetConstellationIndex(iSelectConstellationID)
              self:RefreshPositionDot(self:GetDotPos(self.m_constellationIndex))
              self:RefreshConstellation(iSelectConstellationID, iSelectStarID)
            end)
          else
            self:RefreshConstellation(iSelectConstellationID, iSelectStarID)
          end
        end
        
        if iUnlockStarID and self.m_subPanelLua ~= nil then
          self.m_subPanelLua:PlayStarUnlockAnimation(iUnlockStarID, function()
            _next()
          end)
        else
          _next()
        end
      end
    })
  end)
end

function Form_CastleStarUnlock:OnBtnconfirgrayClicked()
  self.m_txt_constellation_name:SetActive(true)
  self.m_node_pnl_lock:SetActive(false)
  if self.m_starUnlockConditionSatisfied == false then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20051)
    return
  end
  if self.m_bObserveEnough == false then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20053)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20052)
end

function Form_CastleStarUnlock:OnChangeStar(iStarID)
  if StargazingManager:IsConstellationUnlock(self.m_iSelectConstellationID) then
    self:RefreshConstellation(self.m_iSelectConstellationID, iStarID)
  else
    self:ShowStarInfoTips(iStarID)
    if self.m_subPanelLua then
      self.m_subPanelLua:FreshStarInfo(iStarID)
    end
  end
end

function Form_CastleStarUnlock:ShowStarInfoTips(iStarID)
  local starInfo = StargazingManager:GetStarInfo(self.m_iSelectConstellationID, iStarID)
  StackTop:Push(UIDefines.ID_FORM_SKILLSPEDESCTIPS, {
    title = starInfo.m_mStarName,
    desc = starInfo.m_mEffectDes,
    callback = function()
      if self.m_subPanelLua then
        self.m_subPanelLua:FreshStarInfo()
      end
    end
  })
end

function Form_CastleStarUnlock:OnBtntouchotherClicked()
  if self.m_node_pnl_lock.activeSelf then
    self.m_txt_constellation_name:SetActive(true)
    self.m_node_pnl_lock:SetActive(false)
  end
end

function Form_CastleStarUnlock:OnBtnpicClicked()
  utils.openItemDetailPop({
    iID = self.m_unlockItemId,
    iNum = 1
  })
end

function Form_CastleStarUnlock:OnBackClk()
  if self.m_pnl_dispath_L.activeSelf then
    self:CloseDispatchView()
  else
    self:CloseForm()
  end
end

function Form_CastleStarUnlock:OnBtnstarinforClicked()
  self.m_txt_constellation_name:SetActive(false)
  self.m_node_pnl_lock:SetActive(true)
end

function Form_CastleStarUnlock:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:ChangeGameScene(GameSceneManager.SceneID.MainCity)
end

function Form_CastleStarUnlock:IsFullScreen()
  return true
end

function Form_CastleStarUnlock:IsOpenGuassianBlur()
  return false
end

function Form_CastleStarUnlock:OnItemClick(itemID, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

ActiveLuaUI("Form_CastleStarUnlock", Form_CastleStarUnlock)
return Form_CastleStarUnlock
