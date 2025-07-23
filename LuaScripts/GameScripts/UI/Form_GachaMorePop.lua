local Form_GachaMorePop = class("Form_GachaMorePop", require("UI/UIFrames/Form_GachaMorePopUI"))
local GachaIns = ConfigManager:GetConfigInsByName("Gacha")
local GachaDisplayIns = ConfigManager:GetConfigInsByName("GachaDisplay")
local GachaPoolIns = ConfigManager:GetConfigInsByName("GachaPool")
local GachaTemplateIns = ConfigManager:GetConfigInsByName("GachaTemplate")
local GACHA_RECORD_MAX_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("GachapoolRecord") or 0)
local GACHA_RECORD_CNT = 10
local List_Type_Enum = {
  HeroList = 1,
  Des = 2,
  Record = 3
}
local Card_Sort_Enum = {
  SSR_UP = 1,
  SR_UP = 2,
  SSR = 3,
  SR = 4,
  R = 5
}
local ShowUpHero = 3
local GACHA_CFG_RATE = 100
local IntervalNum = 2

function Form_GachaMorePop:SetInitParam(param)
end

function Form_GachaMorePop:AfterInit()
  self.super.AfterInit(self)
  self.m_percentScrollViewItemsTemplate = self.m_scrollView_percent:GetComponent("ScrollRect").content.transform:Find("pnl_item").gameObject
  self.m_percentScrollViewItemsTemplate:SetActive(false)
  self.m_vPercentScrollViewItems = {}
  self.m_percentItemTemplate = self.m_percentScrollViewItemsTemplate.transform:Find("pnl_bg/pnl_item").gameObject
  self.m_percentItemTemplate:SetActive(false)
  self.m_vPercentItem = {}
  self.m_heroListScrollViewItemsTemplate = self.m_scrollView_heroList:GetComponent("ScrollRect").content.transform:Find("pnl_item").gameObject
  self.m_heroListScrollViewItemsTemplate:SetActive(false)
  self.m_vHeroListScrollViewItems = {}
  self.m_heroListItemTemplate = self.m_heroListScrollViewItemsTemplate.transform:Find("pnl_bg/pnl_item").gameObject
  self.m_heroListItemTemplate:SetActive(false)
  self.m_vHeroListItem = {}
  self.m_updateQueueItemBig = self:addComponent("UpdateQueue", IntervalNum)
  self.m_load_end = false
end

function Form_GachaMorePop:OnActive()
  self.super.OnActive(self)
  self.m_load_end = false
  local tParam = self.m_csui.m_param
  self.m_gachaId = tParam.gacha_id
  self.m_selIndex = 0
  local selIndex = List_Type_Enum.HeroList
  self.m_updateQueueItemBig:clear()
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_tab_left)
  self:ChangeList(selIndex)
  self:AddEventListeners()
  GachaManager:ReqGachaGetRecordListCS(self.m_gachaId, 1, GACHA_RECORD_CNT)
end

function Form_GachaMorePop:OnInactive()
  self.super.OnInactive(self)
  self.m_updateQueueItemBig:clear()
  self:RemoveAllEventListeners()
  self.m_load_end = false
  self.m_loop_scroll_view = nil
end

function Form_GachaMorePop:AddEventListeners()
  self:addEventListener("eGameEvent_GetGachaRecord", handler(self, self.PullRefreshUI))
end

function Form_GachaMorePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GachaMorePop:CheckDisplayDataIsShow()
  local data = self:GetGachaDisplayData()
  local isShow = false
  if data then
    for i, v in ipairs(data) do
      if #v.heroIds ~= 0 then
        isShow = true
      end
    end
  end
  return isShow
end

function Form_GachaMorePop:ChangeList(index)
  if self.m_selIndex == index then
    return
  end
  self.m_pnl_tips:SetActive(List_Type_Enum.HeroList == index)
  if List_Type_Enum.HeroList == index then
    self:ShowDailyTimesData()
    self:RefreshHeroList()
  elseif List_Type_Enum.Des == index then
    self:RefreshDes()
  elseif List_Type_Enum.Record == index then
    self:RefreshRecordList()
  end
  self.m_scrollView_heroList:SetActive(List_Type_Enum.HeroList == index)
  self.m_scrollView_gachadesc:SetActive(List_Type_Enum.Des == index)
  self.m_pnl_record:SetActive(List_Type_Enum.Record == index)
  self.m_img_herolist_unselect:SetActive(List_Type_Enum.HeroList ~= index)
  self.m_img_herolist_select:SetActive(List_Type_Enum.HeroList == index)
  self.m_img_gachadesc_unselect:SetActive(List_Type_Enum.Des ~= index)
  self.m_img_gachadesc_select:SetActive(List_Type_Enum.Des == index)
  self.m_img_gacharecord_select:SetActive(List_Type_Enum.Record == index)
  self.m_img_gacharecord_unselect:SetActive(List_Type_Enum.Record ~= index)
  self.m_selIndex = index
end

function Form_GachaMorePop:GetGachaConfig(gachaId)
  local gachaCfg = GachaIns:GetValue_ByGachaID(gachaId)
  if gachaCfg:GetError() then
    log.error("Form_GachaMorePop GetValue_ByGachaID is error " .. tostring(gachaId))
    return
  end
  return gachaCfg
end

function Form_GachaMorePop:GetGachaHeroList()
  local poolIdMap = {}
  local heroIdMap = {}
  local heroIdList = {}
  local gachaCfg = self:GetGachaConfig(self.m_gachaId)
  local gachaTemplate = utils.changeCSArrayToLuaTable(gachaCfg.m_GachaTemplate)
  for i, v in ipairs(gachaTemplate) do
    local gachaTemplateCfgList = GachaTemplateIns:GetValue_ByGachaTemplate(v[1])
    if gachaTemplateCfgList then
      for m, cfgItem in pairs(gachaTemplateCfgList) do
        local poolIds = utils.changeCSArrayToLuaTable(cfgItem.m_PoolID)
        for p, id in ipairs(poolIds) do
          poolIdMap[id] = id
        end
      end
    end
  end
  for i, poolId in pairs(poolIdMap) do
    local cfg = GachaPoolIns:GetValue_ByPoolID(poolId)
    local poolContent = utils.changeCSArrayToLuaTable(cfg.m_PoolContent)
    if ActivityManager:IsInCensorOpen() then
      poolContent = utils.changeCSArrayToLuaTable(cfg.m_CensorPoolContent)
    end
    for m, n in pairs(poolContent) do
      heroIdMap[n[1]] = n[1]
    end
  end
  for m, id in pairs(heroIdMap) do
    local stItemData = ResourceUtil:GetProcessRewardData({iID = id, iNum = 1})
    if stItemData then
      if stItemData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
        if not heroIdList[Card_Sort_Enum.SSR] then
          heroIdList[Card_Sort_Enum.SSR] = {}
        end
        table.insert(heroIdList[Card_Sort_Enum.SSR], id)
      elseif stItemData.quality == GlobalConfig.QUALITY_COMMON_ENUM.SR then
        if not heroIdList[Card_Sort_Enum.SR] then
          heroIdList[Card_Sort_Enum.SR] = {}
        end
        table.insert(heroIdList[Card_Sort_Enum.SR], id)
      elseif stItemData.quality == GlobalConfig.QUALITY_COMMON_ENUM.R then
        if not heroIdList[Card_Sort_Enum.R] then
          heroIdList[Card_Sort_Enum.R] = {}
        end
        table.insert(heroIdList[Card_Sort_Enum.R], id)
      end
    else
      log.error("can not get heroCfg by id == " .. tostring(id))
    end
  end
  return heroIdList
end

function Form_GachaMorePop:GetCardPoolDes(index)
  local heroQualityDes = ""
  local des = ""
  local gachaCfg = self:GetGachaConfig(self.m_gachaId)
  local displayCfg = GachaDisplayIns:GetValue_ByDisplayID(gachaCfg.m_DisplayID)
  if displayCfg:GetError() then
    log.error("Form_GachaMorePop GetValue_ByDisplayID is error " .. tostring(gachaCfg.m_DisplayID))
    return
  end
  if index == Card_Sort_Enum.SSR then
    heroQualityDes = ConfigManager:GetCommonTextById(1004)
    des = string.format(ConfigManager:GetCommonTextById(100013), displayCfg.m_SSRTotalWeight / GACHA_CFG_RATE)
  elseif index == Card_Sort_Enum.SR then
    heroQualityDes = ConfigManager:GetCommonTextById(1003)
    des = string.format(ConfigManager:GetCommonTextById(100014), displayCfg.m_SRTotalWeight / GACHA_CFG_RATE)
  elseif index == Card_Sort_Enum.R then
    heroQualityDes = ConfigManager:GetCommonTextById(1002)
    des = string.format(ConfigManager:GetCommonTextById(100015), displayCfg.m_RTotalWeight / GACHA_CFG_RATE)
  end
  return heroQualityDes, des
end

function Form_GachaMorePop:RefreshHeroList()
  local panelItemList = self.m_scrollView_heroList:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.y = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local mItemInfo = self:GetGachaHeroAndRate()
  local iCount = 0
  local iItemIcount = 0
  local iUpItemIcount = 0
  for i = 1, #mItemInfo do
    local vItemInfo = mItemInfo[i]
    if vItemInfo then
      iCount = iCount + 1
      do
        local panelProbabilityItemInfo = self.m_vHeroListScrollViewItems[iCount]
        if panelProbabilityItemInfo == nil then
          panelProbabilityItemInfo = {}
          panelProbabilityItemInfo.go = CS.UnityEngine.GameObject.Instantiate(self.m_heroListScrollViewItemsTemplate, panelItemList)
          self.m_vHeroListScrollViewItems[iCount] = panelProbabilityItemInfo
        end
        local goProbabilityItemInfo = panelProbabilityItemInfo.go
        goProbabilityItemInfo.transform:Find("img_percent_bg").gameObject:SetActive(i < ShowUpHero)
        goProbabilityItemInfo.transform:Find("m_img_herolist_bg").gameObject:SetActive(i >= ShowUpHero)
        goProbabilityItemInfo:SetActive(true)
        if i < ShowUpHero then
          if 1 > #vItemInfo.heroIds then
            goProbabilityItemInfo:SetActive(false)
          end
          local textProbability = goProbabilityItemInfo.transform:Find("img_percent_bg/txt_percent_ssr/m_txt_percent_ssrdesc"):GetComponent(T_TextMeshProUGUI)
          local strFormat = i == 1 and ConfigManager:GetCommonTextById(100011) or ConfigManager:GetCommonTextById(100012)
          textProbability.text = string.format(strFormat, vItemInfo.weight / GACHA_CFG_RATE)
          local panelItemContent = goProbabilityItemInfo.transform:Find("pnl_bg")
          for j = 1, #vItemInfo.heroIds do
            iUpItemIcount = iUpItemIcount + 1
            local heroId = vItemInfo.heroIds[j]
            local panelItem = self.m_vPercentItem[iUpItemIcount]
            if panelItem == nil then
              panelItem = {}
              panelItem.go = CS.UnityEngine.GameObject.Instantiate(self.m_percentItemTemplate, panelItemContent)
              panelItem.widgetItemIcon = self:createHeroIcon(panelItem.go.transform:Find("c_common_hero_middle").gameObject)
              self.m_vPercentItem[iUpItemIcount] = panelItem
            else
              panelItem.go.transform:SetParent(panelItemContent)
            end
            panelItem.go:SetActive(true)
            local chance = self:GetHeroRate(heroId) or 0
            panelItem.widgetItemIcon:SetHeroData({
              iHeroId = heroId,
              iLevel = nil,
              chance = chance / 10000
            }, nil, true)
            panelItem.widgetItemIcon:SetHeroIconClickCB(function()
              StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {heroID = heroId})
            end)
          end
        else
          local textRarity = goProbabilityItemInfo.transform:Find("m_img_herolist_bg/m_txt_herolist_ssr"):GetComponent(T_TextMeshProUGUI)
          local heroQualityDes, des = self:GetCardPoolDes(i)
          textRarity.text = heroQualityDes
          local colorTop = GlobalConfig.COLOR_GRADIENT_TOP[i - 2]
          local colorBottom = GlobalConfig.COLOR_GRADIENT_BOTTOM[i - 2]
          UILuaHelper.SetColorVerticalGradient(textRarity, colorTop[1], colorTop[2], colorTop[3], colorBottom[1], colorBottom[2], colorBottom[3])
          local textProbability = goProbabilityItemInfo.transform:Find("m_img_herolist_bg/m_txt_herolist_ssr/m_txt_herolist_ssr2"):GetComponent(T_TextMeshProUGUI)
          textProbability.text = des
          local txt_wish = goProbabilityItemInfo.transform:Find("m_img_herolist_bg/txt_wish_tips").gameObject
          txt_wish:SetActive(false)
          local img_wish_line = goProbabilityItemInfo.transform:Find("m_img_herolist_bg/img_wish_line").gameObject
          img_wish_line:SetActive(false)
          local img_line = goProbabilityItemInfo.transform:Find("m_img_herolist_bg/img_line").gameObject
          img_line:SetActive(true)
          local panelItemContent = goProbabilityItemInfo.transform:Find("pnl_bg")
          for j = 1, #vItemInfo do
            local chanceWish = (vItemInfo[j][2] or 0) / 10000
            self.m_updateQueueItemBig:addWait(function()
              iItemIcount = iItemIcount + 1
              local heroId = vItemInfo[j][1]
              local chance = (vItemInfo[j][2] or 0) / 10000
              local panelItem = self.m_vHeroListItem[iItemIcount]
              if panelItem == nil then
                panelItem = {}
                panelItem.go = CS.UnityEngine.GameObject.Instantiate(self.m_heroListItemTemplate, panelItemContent)
                panelItem.widgetItemIcon = self:createHeroIcon(panelItem.go.transform:Find("c_common_hero_middle").gameObject)
                self.m_vHeroListItem[iItemIcount] = panelItem
              else
                panelItem.go.transform:SetParent(panelItemContent)
              end
              panelItem.go:SetActive(true)
              panelItem.widgetItemIcon:SetHeroData({
                iHeroId = heroId,
                iLevel = nil,
                chance = chance
              }, nil, true)
              panelItem.widgetItemIcon:SetHeroIconClickCB(function()
                StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {heroID = heroId})
              end)
              return true
            end)
            if chanceWish == 0 then
              txt_wish:SetActive(true)
              img_wish_line:SetActive(true)
              img_line:SetActive(false)
            end
          end
          CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(panelItemContent:GetComponent("RectTransform"))
          UILuaHelper.ForceRebuildLayoutImmediate(goProbabilityItemInfo)
        end
      end
    end
  end
  for i = iCount + 1, #self.m_vHeroListScrollViewItems do
    self.m_vHeroListScrollViewItems[i].go:SetActive(false)
  end
  for i = iItemIcount + 1, #self.m_vHeroListItem do
    self.m_vHeroListItem[i].go:SetActive(false)
  end
  for i = iUpItemIcount + 1, #self.m_vPercentItem do
    self.m_vPercentItem[i].go:SetActive(false)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_heroList_content)
end

function Form_GachaMorePop:RefreshDes()
  local gachaCfg = self:GetGachaConfig(self.m_gachaId)
  local infoId = gachaCfg.m_Info
  if infoId and type(infoId) == "number" then
    self.m_txt_gachadesc_Text.text = ConfigManager:GetCommonTextById(infoId) or ""
  end
end

function Form_GachaMorePop:GetGachaDisplayData()
  local displayData = {}
  local gachaCfg = self:GetGachaConfig(self.m_gachaId)
  local displayCfg = GachaDisplayIns:GetValue_ByDisplayID(gachaCfg.m_DisplayID)
  if displayCfg:GetError() then
    log.error("Form_GachaMorePop GetValue_ByDisplayID is error " .. tostring(gachaCfg.m_DisplayID))
    return
  end
  displayData[1] = {
    weight = displayCfg.m_UpSSRWeight,
    heroIds = {}
  }
  displayData[2] = {
    weight = displayCfg.m_UpSRWeight,
    heroIds = {}
  }
  local heroIdList = utils.changeCSArrayToLuaTable(displayCfg.m_DisplayUpContent)
  for m, id in ipairs(heroIdList) do
    local quality = HeroManager:GetHeroQualityById(id)
    if quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
      table.insert(displayData[1].heroIds, id)
    elseif quality == GlobalConfig.QUALITY_COMMON_ENUM.SR then
      table.insert(displayData[2].heroIds, id)
    end
  end
  return displayData
end

function Form_GachaMorePop:RefreshRecordList()
  self.m_txt_recordtips_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20326), GACHA_RECORD_MAX_CNT)
  self.m_txt_recordtips_desc_Text.text = ConfigManager:GetCommonTextById(20350)
  self:refreshLoopScroll()
end

function Form_GachaMorePop:PullRefreshUI()
  self.m_load_end = true
  if List_Type_Enum.Record == self.m_selIndex then
    self:RefreshRecordList()
  end
end

function Form_GachaMorePop:refreshLoopScroll()
  local data = GachaManager:GetGachaRecordListById(self.m_gachaId) or {}
  self.m_empty:SetActive(#data == 0)
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scrollviewrecord
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end,
      pull_refresh = function()
        self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
        local dataCount = table.getn(data)
        if dataCount < GACHA_RECORD_MAX_CNT then
          local addCount = math.min(GACHA_RECORD_MAX_CNT - dataCount, GACHA_RECORD_CNT)
          local recordNum = GachaManager:GetGachaRecordTotalById(self.m_gachaId)
          if recordNum then
            local maxNum = math.min(recordNum, dataCount + addCount)
            local minNum = math.min(recordNum, dataCount + 1)
            if maxNum >= minNum and dataCount < maxNum then
              GachaManager:ReqGachaGetRecordListCS(self.m_gachaId, minNum, maxNum)
            end
          end
        end
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        local tab = string.split(click_name, "m_item_hero")
        if tab and tab[1] then
          local heroId = cell_data.vItem[tonumber(tab[1])]
          StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {heroID = heroId})
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    self.m_loop_scroll_view:moveToCellIndex(1)
  else
    self.m_loop_scroll_view:reloadData(data, true)
    if self.m_load_end == true then
      self:PullRefreshListOffset()
    end
  end
end

function Form_GachaMorePop:PullRefreshListOffset()
  if self.last_offsety then
    local now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    local position = (self.last_offsety - now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
    self.m_load_end = false
  end
end

function Form_GachaMorePop:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local iTime = cell_data.iTime
  local vItem = cell_data.vItem
  local iGachaId = cell_data.iGachaId
  for i = 1, 10 do
    if vItem[i] then
      local characterCfg = HeroManager:GetHeroConfigByID(vItem[i])
      if characterCfg then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_item_hero" .. i, true)
        local m_item_hero = LuaBehaviourUtil.findGameObject(luaBehaviour, "m_item_hero" .. i)
        local item_luaBehaviour = UIUtil.findLuaBehaviour(m_item_hero.transform)
        LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "m_img_tem_bg_r", characterCfg.m_Quality ~= GlobalConfig.QUALITY_COMMON_ENUM.SSR)
        LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "m_icon_item_grade_ssr", characterCfg.m_Quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
        LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "m_pnl_r", characterCfg.m_Quality == GlobalConfig.QUALITY_COMMON_ENUM.R)
        LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "m_pnl_sr", characterCfg.m_Quality == GlobalConfig.QUALITY_COMMON_ENUM.SR)
        LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "m_pnl_ssr", characterCfg.m_Quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR)
        local szIcon = ResourceUtil:GetHeroIconPath(vItem[i], characterCfg)
        LuaBehaviourUtil.setImg(item_luaBehaviour, "m_img_head", szIcon)
        LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "m_icon_up", GachaManager:CheckIsUpHero(iGachaId, vItem[i]))
      end
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_item_hero" .. i, characterCfg ~= nil)
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_item_hero" .. i, false)
    end
  end
  if index < 10 then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_record_num", "0" .. index)
  else
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_record_num", index)
  end
  local timeStr = TimeUtil:TimerToString3(iTime)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_record_time", tostring(timeStr))
end

function Form_GachaMorePop:GetGachaHeroAndRate()
  local heroIdMap = {}
  local heroIdList = {}
  local gachaCfg = self:GetGachaConfig(self.m_gachaId)
  local displayCfg = GachaDisplayIns:GetValue_ByDisplayID(gachaCfg.m_DisplayID)
  if displayCfg:GetError() then
    log.error("Form_GachaMorePop GetValue_ByDisplayID is error " .. tostring(gachaCfg.m_DisplayID))
    return
  end
  heroIdList[1] = {
    weight = displayCfg.m_UpSSRWeight,
    heroIds = {}
  }
  heroIdList[2] = {
    weight = displayCfg.m_UpSRWeight,
    heroIds = {}
  }
  local heroIdListData = utils.changeCSArrayToLuaTable(displayCfg.m_DisplayUpContent)
  if heroIdListData and 0 < #heroIdListData then
    for m, id in ipairs(heroIdListData) do
      local quality = HeroManager:GetHeroQualityById(id)
      if quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
        table.insert(heroIdList[1].heroIds, id)
      elseif quality == GlobalConfig.QUALITY_COMMON_ENUM.SR then
        table.insert(heroIdList[2].heroIds, id)
      end
    end
  end
  local poolId = displayCfg.m_PoolID
  local cfg = GachaPoolIns:GetValue_ByPoolID(poolId)
  if cfg and not cfg:GetError() then
    local poolContent = utils.changeCSArrayToLuaTable(cfg.m_PoolContent)
    if ActivityManager:IsInCensorOpen() then
      poolContent = utils.changeCSArrayToLuaTable(cfg.m_CensorPoolContent)
    end
    for m, n in pairs(poolContent) do
      if not table.keyof(heroIdListData, n[1]) then
        heroIdMap[n[1]] = {
          n[1],
          n[3]
        }
      end
    end
  end
  local wishHeroIdMap = GachaManager:GetWishHeroChance(self.m_gachaId)
  local campList = GachaManager:GetWishHeroCamp(self.m_gachaId)
  for id, v in pairs(heroIdMap) do
    local heroCfg = HeroManager:GetHeroConfigByID(id)
    local quality = heroCfg.m_Quality
    if quality then
      if quality == GlobalConfig.QUALITY_COMMON_ENUM.SSR then
        if not heroIdList[Card_Sort_Enum.SSR] then
          heroIdList[Card_Sort_Enum.SSR] = {}
        end
        local heroData = v
        if wishHeroIdMap and 0 < table.getn(wishHeroIdMap) and campList[heroCfg.m_Camp] then
          if wishHeroIdMap and wishHeroIdMap[v[1]] then
            heroData = {
              v[1],
              wishHeroIdMap[v[1]]
            }
          else
            heroData = {
              v[1],
              0
            }
          end
        end
        table.insert(heroIdList[Card_Sort_Enum.SSR], heroData)
      elseif quality == GlobalConfig.QUALITY_COMMON_ENUM.SR then
        if not heroIdList[Card_Sort_Enum.SR] then
          heroIdList[Card_Sort_Enum.SR] = {}
        end
        table.insert(heroIdList[Card_Sort_Enum.SR], v)
      elseif quality == GlobalConfig.QUALITY_COMMON_ENUM.R then
        if not heroIdList[Card_Sort_Enum.R] then
          heroIdList[Card_Sort_Enum.R] = {}
        end
        table.insert(heroIdList[Card_Sort_Enum.R], v)
      end
    else
      log.error("can not get heroCfg by id == " .. tostring(id))
    end
  end
  
  local function sortFun(data1, data2)
    return data1[2] > data2[2]
  end
  
  if heroIdList[Card_Sort_Enum.SSR] then
    table.sort(heroIdList[Card_Sort_Enum.SSR], sortFun)
  end
  if heroIdList[Card_Sort_Enum.SR] then
    table.sort(heroIdList[Card_Sort_Enum.SSR], sortFun)
  end
  if heroIdList[Card_Sort_Enum.R] then
    table.sort(heroIdList[Card_Sort_Enum.SSR], sortFun)
  end
  return heroIdList
end

function Form_GachaMorePop:GetHeroRate(heroId)
  local heroIdMap = {}
  local gachaCfg = self:GetGachaConfig(self.m_gachaId)
  local displayCfg = GachaDisplayIns:GetValue_ByDisplayID(gachaCfg.m_DisplayID)
  if displayCfg:GetError() then
    log.error("Form_GachaMorePop GetValue_ByDisplayID is error " .. tostring(gachaCfg.m_DisplayID))
    return
  end
  local poolId = displayCfg.m_PoolID
  local cfg = GachaPoolIns:GetValue_ByPoolID(poolId)
  if cfg and not cfg:GetError() then
    local poolContent = utils.changeCSArrayToLuaTable(cfg.m_PoolContent)
    if ActivityManager:IsInCensorOpen() then
      poolContent = utils.changeCSArrayToLuaTable(cfg.m_CensorPoolContent)
    end
    for m, n in pairs(poolContent) do
      heroIdMap[n[1]] = n[3]
    end
  end
  return heroIdMap[heroId]
end

function Form_GachaMorePop:ShowDailyTimesData()
  local gachaConfig = self:GetGachaConfig(self.m_gachaId)
  if gachaConfig.m_DailyMax <= 0 then
    UILuaHelper.SetActive(self.m_pnl_tips, false)
    return
  end
  local dailyTimes = GachaManager:GetGachaDailyTimesById(self.m_gachaId)
  dailyTimes = gachaConfig.m_DailyMax - dailyTimes
  if dailyTimes <= 0 then
    dailyTimes = 0
    dailyTimes = "<color=#B2452B>" .. dailyTimes .. "</color>"
  end
  self.m_txt_lefttips_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100095), dailyTimes, gachaConfig.m_DailyMax)
end

function Form_GachaMorePop:OnBtnherolistClicked()
  self:ChangeList(List_Type_Enum.HeroList)
end

function Form_GachaMorePop:OnBtngachadescClicked()
  self:ChangeList(List_Type_Enum.Des)
end

function Form_GachaMorePop:OnBtngacharecordClicked()
  self:ChangeList(List_Type_Enum.Record)
end

function Form_GachaMorePop:OnBtnCloseClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GACHAMOREPOP)
end

function Form_GachaMorePop:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GACHAMOREPOP)
end

function Form_GachaMorePop:IsOpenGuassianBlur()
  return true
end

function Form_GachaMorePop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GachaMorePop", Form_GachaMorePop)
return Form_GachaMorePop
