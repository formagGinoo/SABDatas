local Form_ActivityAnnounceLotterypage = class("Form_ActivityAnnounceLotterypage", require("UI/UIFrames/Form_ActivityAnnounceLotterypageUI"))
local TopTab = {
  ActivityAnnouncement = 1,
  SystemAnnouncement = 2,
  ConsultAnnouncement = 3
}
local ContentPrefabType = {
  PicturePre = 1,
  TextPre = 2,
  SpacePre = 3,
  Title = 4,
  LongPic = 5,
  BigTitle = 6
}
local JumpType = {
  Activity = 0,
  URL = 1,
  System = 2,
  Elva = 3,
  Navel = 4,
  NoJump = 5,
  WebTokenUrl = 6
}

function Form_ActivityAnnounceLotterypage:SetInitParam(param)
end

function Form_ActivityAnnounceLotterypage:AfterInit()
  self.super.AfterInit(self)
  self.contentPrefab = {
    [ContentPrefabType.PicturePre] = self.m_img_cdnpic,
    [ContentPrefabType.TextPre] = self.m_pnl_activityview,
    [ContentPrefabType.SpacePre] = self.m_img_Space,
    [ContentPrefabType.Title] = self.m_pnl_activity_title,
    [ContentPrefabType.BigTitle] = self.m_pnl_activity_titleBig
  }
  self.m_totalDataList = {}
  self.m_activityDataList = {}
  self.m_systemDataList = {}
  self.m_consultDataList = {}
  self.m_TabItemCache = {}
  self.curShowList = {}
  self.curChooseTopTab = TopTab.ActivityAnnouncement
  self.cur_leftselect_idx = 1
  self.curChooseActivity = {}
  self.contentParent = self.m_img_cdnpic.transform.parent
  self.contentShowPicListPool = {
    [1] = self.m_img_cdnpic
  }
  self.m_img_cdnpic:SetActive(false)
  self.contentShowPicListCatch = {}
  self.contentShowTextListPool = {
    [1] = self.m_pnl_activityview
  }
  self.m_pnl_activityview:SetActive(false)
  self.contentShowTextListCatch = {}
  self.contentShowSpaceListPool = {
    [1] = self.m_img_Space
  }
  self.m_img_Space:SetActive(false)
  self.contentShowSpaceListCatch = {}
  self.contentShowTitleListPool = {
    [1] = self.m_pnl_activity_title
  }
  self.m_pnl_activity_title:SetActive(false)
  self.contentShowTitleListCatch = {}
  self.contentShowBigTitleListPool = {
    [1] = self.m_pnl_activity_titleBig
  }
  self.m_pnl_activity_titleBig:SetActive(false)
  self.contentShowBigTitleListCatch = {}
  self:CheckRegisterRedDot()
end

function Form_ActivityAnnounceLotterypage:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:UpdateActivityData()
  if #self.m_consultDataList > 0 then
    self.curChooseTopTab = TopTab.ConsultAnnouncement
  end
  if 0 < #self.m_systemDataList then
    self.curChooseTopTab = TopTab.SystemAnnouncement
  end
  if 0 < #self.m_activityDataList then
    self.curChooseTopTab = TopTab.ActivityAnnouncement
  end
  self.cur_leftselect_idx = 1
  self:RefreshUI()
end

function Form_ActivityAnnounceLotterypage:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityAnnounceLotterypage:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_AnywayReload", handler(self, self.OnGetActivityResetData))
end

function Form_ActivityAnnounceLotterypage:OnGetActivityResetData()
  self:UpdateActivityData()
  if #self.m_consultDataList > 0 then
    self.curChooseTopTab = TopTab.ConsultAnnouncement
  end
  if 0 < #self.m_systemDataList then
    self.curChooseTopTab = TopTab.SystemAnnouncement
  end
  if 0 < #self.m_activityDataList then
    self.curChooseTopTab = TopTab.ActivityAnnouncement
  end
  self.cur_leftselect_idx = 1
  self:RefreshUI()
end

function Form_ActivityAnnounceLotterypage:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_ActivityAnnounceLotterypage:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_img_reddot_activitygrey, RedDotDefine.ModuleType.AnnouncementTopTabActivity)
  self:RegisterOrUpdateRedDotItem(self.m_img_reddot_activitysel, RedDotDefine.ModuleType.AnnouncementTopTabActivity)
  self:RegisterOrUpdateRedDotItem(self.m_img_reddot_systemgrey, RedDotDefine.ModuleType.AnnouncementTopTabSystem)
  self:RegisterOrUpdateRedDotItem(self.m_img_reddot_systemsel, RedDotDefine.ModuleType.AnnouncementTopTabSystem)
  self:RegisterOrUpdateRedDotItem(self.m_img_reddot_askgrey, RedDotDefine.ModuleType.AnnouncementTopTabConsult)
  self:RegisterOrUpdateRedDotItem(self.m_img_reddot_ask, RedDotDefine.ModuleType.AnnouncementTopTabConsult)
end

function Form_ActivityAnnounceLotterypage:RefreshUI()
  self.m_stActivity = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_GameNotice)
  self:UpdateActivityData()
  self:RefreshTopTab()
  self:RefreshLeftTab()
  self:RefreshContent()
end

function Form_ActivityAnnounceLotterypage:RefreshTopTab()
  UILuaHelper.SetActive(self.m_z_txt_greyactive, TopTab.ActivityAnnouncement ~= self.curChooseTopTab)
  UILuaHelper.SetActive(self.m_img_selactive, TopTab.ActivityAnnouncement == self.curChooseTopTab)
  UILuaHelper.SetActive(self.m_z_txt_greysystem, TopTab.SystemAnnouncement ~= self.curChooseTopTab)
  UILuaHelper.SetActive(self.m_img_selsystem, TopTab.SystemAnnouncement == self.curChooseTopTab)
  UILuaHelper.SetActive(self.m_z_txt_ask, TopTab.ConsultAnnouncement ~= self.curChooseTopTab)
  UILuaHelper.SetActive(self.m_img_selask, TopTab.ConsultAnnouncement == self.curChooseTopTab)
end

function Form_ActivityAnnounceLotterypage:RefreshLeftTab()
  self.m_TabItemCache = {}
  self.curShowList = {}
  if self.curChooseTopTab == TopTab.ActivityAnnouncement then
    self.curShowList = self.m_activityDataList
  elseif self.curChooseTopTab == TopTab.SystemAnnouncement then
    self.curShowList = self.m_systemDataList
  elseif self.curChooseTopTab == TopTab.ConsultAnnouncement then
    self.curShowList = self.m_consultDataList
  end
  local panelRoot = self.m_btn_percent.transform.parent
  local childCount = panelRoot.childCount
  for i = 0, childCount - 1 do
    local child = panelRoot:GetChild(i)
    if child.gameObject.activeSelf then
      child.gameObject:SetActive(false)
    end
  end
  local elementCount = #self.curShowList
  if childCount < elementCount then
    for index = childCount, elementCount do
      GameObject.Instantiate(self.m_btn_percent, panelRoot)
    end
  end
  for i, v in ipairs(self.curShowList) do
    local child = panelRoot:GetChild(i - 1).gameObject
    child:SetActive(true)
    self:OnInitTabItem(child, i - 1)
  end
end

function Form_ActivityAnnounceLotterypage:OnInitTabItem(go, index)
  local idx = index + 1
  local transform = go.transform
  local item = self.m_TabItemCache[idx]
  local data = self.curShowList[idx].m_stSdpConfig.stClientCfg
  if not item then
    item = {
      btn = transform:GetComponent(T_Button),
      m_tab_select = transform:Find("m_img_percenti_select").gameObject,
      m_tab_unselect = transform:Find("m_img_percent_grey").gameObject,
      m_img_reddot_tabview = transform:Find("m_img_reddot_tabview").gameObject
    }
    self.m_TabItemCache[idx] = item
    if ActivityManager:CanShowRedCurrentLogin(self.curShowList[idx].m_stActivityData.iActivityId) then
      item.m_img_reddot_tabview:SetActive(true)
      if idx == 1 then
        item.m_img_reddot_tabview:SetActive(false)
        ActivityManager:SetShowRedCurrentLogin(self.curShowList[idx].m_stActivityData.iActivityId, self.curShowList[idx].m_stActivityData.iShowReddotNew)
      end
    else
      item.m_img_reddot_tabview:SetActive(false)
    end
  end
  local m_txt_percent_seltitle = transform:Find("m_img_percent_grey/m_txt_percent_greytitle"):GetComponent(T_TextMeshProUGUI)
  m_txt_percent_seltitle.text = self.curShowList[idx]:getLangText(tostring(data.sTitle))
  local textUnselected = transform:Find("m_img_percenti_select/m_txt_percent_seltitle"):GetComponent(T_TextMeshProUGUI)
  textUnselected.text = self.curShowList[idx]:getLangText(tostring(data.sTitle))
  item.m_tab_select:SetActive(self.cur_leftselect_idx == idx)
  item.m_tab_unselect:SetActive(self.cur_leftselect_idx ~= idx)
  if item.btn then
    UILuaHelper.BindButtonClickManual(item.btn, function()
      self.cur_leftselect_idx = idx
      self.m_img_reddot_tabview:SetActive(false)
      ActivityManager:SetShowRedCurrentLogin(self.curShowList[idx].m_stActivityData.iActivityId, self.curShowList[idx].m_stActivityData.iShowReddotNew)
      self:RefreshLeftTab()
      self:RefreshContent()
      UILuaHelper.PlayAnimationByName(self.m_pnl_group_activity, "lotterypage_content_in")
    end)
  end
end

function Form_ActivityAnnounceLotterypage:RefreshContent()
  self:CheckActivityAnnounmentReddot()
  self:CheckSystemAnnounmentReddot()
  self:CheckConsultAnnounmentReddot()
  if #self.curShowList < self.cur_leftselect_idx then
    self.m_pnl_activity:SetActive(false)
    self.m_btn_go:SetActive(false)
    return
  end
  self.m_pnl_activity:SetActive(true)
  self.m_btn_go:SetActive(true)
  local announceCfg = self.curShowList[self.cur_leftselect_idx].m_stSdpConfig.stClientCfg
  if not announceCfg then
    return
  end
  local contentInfo = announceCfg.vContentConfig
  if not contentInfo then
    return
  end
  self:RefreshBottomJump(announceCfg)
  self:DealPoolList()
  for i = 1, #contentInfo do
    if contentInfo[i].iType == ContentPrefabType.PicturePre then
      local obj
      if #self.contentShowPicListPool > 0 then
        obj = self.contentShowPicListPool[1]
        table.insert(self.contentShowPicListCatch, obj)
        table.remove(self.contentShowPicListPool, 1)
      else
        obj = GameObject.Instantiate(self.m_img_cdnpic, self.contentParent)
        table.insert(self.contentShowPicListCatch, obj)
      end
      if obj then
        obj:SetActive(true)
        if obj.transform:Find("m_txt_type") then
          local objTxt = obj.transform:Find("m_txt_type")
          UILuaHelper.SetActive(objTxt, false)
        end
        obj.transform:SetSiblingIndex(i - 1)
        do
          local BtnComponent = obj.transform:GetComponent(T_Button)
          local imageComponent = obj.transform:GetComponent(T_Image)
          local stActivityData = ActivityManager:GetActivityDataByID(self.curShowList[self.cur_leftselect_idx].m_stActivityData.iActivityId)
          if BtnComponent then
            UILuaHelper.BindButtonClickManual(BtnComponent, function()
              self:DealJump(contentInfo[i].iJumpType, contentInfo[i].sJumpParam)
            end)
          end
          if contentInfo[i].sContent ~= "" then
            ActivityManager:SetActivityImage(stActivityData, imageComponent, contentInfo[i].sContent, function()
              if imageComponent.sprite then
                local spriteRect = imageComponent.sprite.rect
                local originalWidth = spriteRect.width
                local originalHeight = spriteRect.height
                local imageRect = imageComponent.gameObject:GetComponent("RectTransform")
                local imageWidth = imageRect.rect.width
                local shouldShowHeight = originalHeight / originalWidth * imageWidth
                imageRect.sizeDelta = Vector2.New(imageWidth, shouldShowHeight)
                if contentInfo[i].sTextContent and contentInfo[i].sTextContent ~= "" and obj.transform:Find("m_txt_type") then
                  local objTxt = obj.transform:Find("m_txt_type")
                  UILuaHelper.SetActive(objTxt, true)
                  UILuaHelper.SetLocalPosition(objTxt, contentInfo[i].iOffsetX, -contentInfo[i].iOffsetY, 0)
                  local txtObj_Text = obj.transform:Find("m_txt_type"):GetComponent(T_TextMeshProUGUI)
                  if txtObj_Text then
                    txtObj_Text.text = self.curShowList[self.cur_leftselect_idx]:getLangText(contentInfo[i].sTextContent)
                  end
                end
              end
            end)
          end
        end
      end
    elseif contentInfo[i].iType == ContentPrefabType.TextPre then
      local obj
      if #self.contentShowTextListPool > 0 then
        obj = self.contentShowTextListPool[1]
        obj:SetActive(true)
        table.insert(self.contentShowTextListCatch, obj)
        table.remove(self.contentShowTextListPool, 1)
      else
        obj = GameObject.Instantiate(self.m_pnl_activityview, self.contentParent)
        table.insert(self.contentShowTextListCatch, obj)
      end
      if obj then
        obj.transform:SetSiblingIndex(i - 1)
        local objText = obj.transform:Find("m_txt_activityinfor"):GetComponent(T_TextMeshProUGUI)
        if objText then
          objText.text = self.curShowList[self.cur_leftselect_idx]:getLangText(tostring(contentInfo[i].sContent))
        end
      end
    elseif contentInfo[i].iType == ContentPrefabType.SpacePre then
      local obj
      if 0 < #self.contentShowSpaceListPool then
        obj = self.contentShowSpaceListPool[1]
        obj:SetActive(true)
        table.insert(self.contentShowSpaceListCatch, obj)
        table.remove(self.contentShowSpaceListPool, 1)
      else
        obj = GameObject.Instantiate(self.m_img_Space, self.contentParent)
        table.insert(self.contentShowSpaceListCatch, obj)
      end
      if obj then
        obj.transform:SetSiblingIndex(i - 1)
      end
    elseif contentInfo[i].iType == ContentPrefabType.BigTitle then
      local obj
      if 0 < #self.contentShowBigTitleListPool then
        obj = self.contentShowBigTitleListPool[1]
        obj:SetActive(true)
        table.insert(self.contentShowBigTitleListCatch, obj)
        table.remove(self.contentShowBigTitleListPool, 1)
      else
        obj = GameObject.Instantiate(self.m_pnl_activity_titleBig, self.contentParent)
        table.insert(self.contentShowBigTitleListCatch, obj)
      end
      if obj then
        obj.transform:SetSiblingIndex(i - 1)
        local objText = obj.transform:Find("m_txt_title_activity"):GetComponent(T_TextMeshProUGUI)
        objText.text = self.curShowList[self.cur_leftselect_idx]:getLangText(tostring(contentInfo[i].sContent))
      end
    else
      local obj
      if 0 < #self.contentShowTitleListPool then
        obj = self.contentShowTitleListPool[1]
        obj:SetActive(true)
        table.insert(self.contentShowTitleListCatch, obj)
        table.remove(self.contentShowTitleListPool, 1)
      else
        obj = GameObject.Instantiate(self.m_pnl_activity_title, self.contentParent)
        table.insert(self.contentShowTitleListCatch, obj)
      end
      if obj then
        obj.transform:SetSiblingIndex(i - 1)
        local objText = obj.transform:GetComponent(T_TextMeshProUGUI)
        objText.text = self.curShowList[self.cur_leftselect_idx]:getLangText(tostring(contentInfo[i].sContent))
      end
    end
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_group_activity)
end

function Form_ActivityAnnounceLotterypage:RefreshBottomJump(announceCfg)
  if announceCfg.iJumpTypeLast ~= JumpType.NoJump then
    self.m_btn_go:SetActive(true)
    self.m_txt_go_Text.text = self.curShowList[self.cur_leftselect_idx]:getLangText(tostring(announceCfg.sJumpContent))
  else
    self.m_btn_go:SetActive(false)
  end
end

function Form_ActivityAnnounceLotterypage:CheckActivityAnnounmentReddot()
  local shouldShowRed = 0
  for i = 1, #self.m_activityDataList do
    if ActivityManager:CanShowRedCurrentLogin(self.m_activityDataList[i].m_stActivityData.iActivityId) then
      shouldShowRed = shouldShowRed + 1
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.AnnouncementTopTabActivity,
    count = shouldShowRed
  })
end

function Form_ActivityAnnounceLotterypage:CheckSystemAnnounmentReddot()
  local shouldShowRed = 0
  for i = 1, #self.m_systemDataList do
    if ActivityManager:CanShowRedCurrentLogin(self.m_systemDataList[i].m_stActivityData.iActivityId) then
      shouldShowRed = shouldShowRed + 1
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.AnnouncementTopTabSystem,
    count = shouldShowRed
  })
end

function Form_ActivityAnnounceLotterypage:CheckConsultAnnounmentReddot()
  local shouldShowRed = 0
  for i = 1, #self.m_consultDataList do
    if ActivityManager:CanShowRedCurrentLogin(self.m_consultDataList[i].m_stActivityData.iActivityId) then
      shouldShowRed = shouldShowRed + 1
    end
  end
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.AnnouncementTopTabConsult,
    count = shouldShowRed
  })
end

function Form_ActivityAnnounceLotterypage:UpdateActivityData()
  self.m_totalDataList = {}
  self.m_totalDataList = ActivityManager:GetActivityListByType(MTTD.ActivityType_GameNotice)
  if not self.m_totalDataList then
    return
  end
  self.m_activityDataList = {}
  self.m_systemDataList = {}
  self.m_consultDataList = {}
  for _, v in ipairs(self.m_totalDataList) do
    local cfgEntireInfo = v
    local cfgDataInfo = v.m_stSdpConfig.stClientCfg
    if cfgEntireInfo:checkCondition() then
      if cfgDataInfo.iNoticeType == 1 then
        table.insert(self.m_activityDataList, cfgEntireInfo)
      elseif cfgDataInfo.iNoticeType == 2 then
        table.insert(self.m_systemDataList, cfgEntireInfo)
      elseif cfgDataInfo.iNoticeType == 3 then
        table.insert(self.m_consultDataList, cfgEntireInfo)
      elseif cfgDataInfo.iNoticeType == 4 and v:CanShowAddResPre() then
        table.insert(self.m_systemDataList, cfgEntireInfo)
      end
    end
  end
  table.sort(self.m_activityDataList, function(a, b)
    return a.m_stSdpConfig.stClientCfg.iShowWeight > b.m_stSdpConfig.stClientCfg.iShowWeight
  end)
  self.m_tabactive:SetActive(table.getn(self.m_activityDataList) > 0)
  table.sort(self.m_systemDataList, function(a, b)
    return a.m_stSdpConfig.stClientCfg.iShowWeight > b.m_stSdpConfig.stClientCfg.iShowWeight
  end)
  self.m_tabsystem:SetActive(table.getn(self.m_systemDataList) > 0)
  table.sort(self.m_consultDataList, function(a, b)
    return a.m_stSdpConfig.stClientCfg.iShowWeight > b.m_stSdpConfig.stClientCfg.iShowWeight
  end)
  self.m_tabask:SetActive(table.getn(self.m_consultDataList) > 0)
end

function Form_ActivityAnnounceLotterypage:IsShowSurveyAnnounce(cfgDataInfo)
  local paramArray = string.split(cfgDataInfo.sJumpParamLast, "|")
  if paramArray[1] and paramArray[2] then
    local activity = ActivityManager:GetActivityByID(tonumber(paramArray[2]))
    if activity then
      local activityType = activity:getType()
      if activityType == MTTD.ActivityType_SurveyReward and paramArray[3] and tonumber(paramArray[3]) == 0 and activity:IsSubmitSurvey() then
        return false
      end
    end
  end
  return true
end

function Form_ActivityAnnounceLotterypage:DealJump(jumpType, param)
  if param == "" and not jumpType then
    log.info("跳转参数配置错误")
    return
  end
  
  local function func()
  end
  
  if jumpType == JumpType.Activity then
    function func()
      local paramArray = string.split(param, "|")
      
      local activity = ActivityManager:GetActivityByID(tonumber(paramArray[2]))
      if activity then
        local activityType = activity:getType()
        if activityType == MTTD.ActivityType_SurveyReward then
          activity:RequestGetSurveyLink(1)
        else
          QuickOpenFuncUtil:OpenFunc(tonumber(paramArray[1]), {
            activityId = tonumber(paramArray[2])
          })
          self:CloseForm()
        end
      end
    end
  elseif jumpType == JumpType.URL then
    local sURL = ""
    if string.startsWith(param, "LANG_") then
      sURL = self.curShowList[self.cur_leftselect_idx]:getLangText(param)
    else
      sURL = param
    end
    
    function func()
      CS.DeviceUtil.OpenURLNew(sURL)
    end
  elseif jumpType == JumpType.System then
    function func()
      QuickOpenFuncUtil:OpenFunc(tonumber(param))
      
      self:CloseForm()
    end
  elseif jumpType == JumpType.Elva then
    function func()
      SettingManager:PullAiHelpMessage()
    end
  elseif jumpType == JumpType.Navel then
    function func()
    end
  else
    if jumpType == JumpType.WebTokenUrl then
      function func()
        RoleManager:ReqGetUserToken(param)
      end
    else
    end
  end
  func()
end

function Form_ActivityAnnounceLotterypage:DealPoolList()
  if #self.contentShowPicListCatch > 0 then
    for i = #self.contentShowPicListCatch, 1, -1 do
      self.contentShowPicListCatch[i]:SetActive(false)
      local img = self.contentShowPicListCatch[i].transform:GetComponent(T_Image)
      img.sprite = nil
      local btn = self.contentShowPicListCatch[i].transform:GetComponent(T_Button)
      if btn then
        btn.onClick:RemoveAllListeners()
      end
      if self.contentShowPicListCatch[i].transform:Find("m_txt_type") then
        local obj = self.contentShowPicListCatch[i].transform:Find("m_txt_type")
        obj.transform:GetComponent(T_TextMeshProUGUI).text = ""
        UILuaHelper.SetActive(obj, false)
        UILuaHelper.SetLocalPosition(obj, 0, 0, 0)
      end
      table.insert(self.contentShowPicListPool, self.contentShowPicListCatch[i])
    end
    self.contentShowPicListCatch = {}
  end
  if 0 < #self.contentShowTextListCatch then
    for i = #self.contentShowTextListCatch, 1, -1 do
      self.contentShowTextListCatch[i]:SetActive(false)
      local txt = self.contentShowTextListCatch[i].transform:Find("m_txt_activityinfor"):GetComponent(T_TextMeshProUGUI)
      if txt then
        txt.text = ""
      end
      table.insert(self.contentShowTextListPool, self.contentShowTextListCatch[i])
    end
    self.contentShowTextListCatch = {}
  end
  if 0 < #self.contentShowSpaceListCatch then
    for i = #self.contentShowSpaceListCatch, 1, -1 do
      self.contentShowSpaceListCatch[i]:SetActive(false)
      table.insert(self.contentShowSpaceListPool, self.contentShowSpaceListCatch[i])
    end
    self.contentShowSpaceListCatch = {}
  end
  if 0 < #self.contentShowTitleListCatch then
    for i = #self.contentShowTitleListCatch, 1, -1 do
      self.contentShowTitleListCatch[i]:SetActive(false)
      local txt = self.contentShowTitleListCatch[i].transform:GetComponent(T_TextMeshProUGUI)
      if txt then
        txt.text = ""
      end
      table.insert(self.contentShowTitleListPool, self.contentShowTitleListCatch[i])
    end
    self.contentShowTitleListCatch = {}
  end
  if 0 < #self.contentShowBigTitleListCatch then
    for i = #self.contentShowBigTitleListCatch, 1, -1 do
      self.contentShowBigTitleListCatch[i]:SetActive(false)
      local txt = self.contentShowBigTitleListCatch[i].transform:Find("m_txt_title_activity").transform:GetComponent(T_TextMeshProUGUI)
      if txt then
        txt.text = ""
      end
      table.insert(self.contentShowBigTitleListPool, self.contentShowBigTitleListCatch[i])
    end
    self.contentShowBigTitleListCatch = {}
  end
end

function Form_ActivityAnnounceLotterypage:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_ActivityAnnounceLotterypage:OnTabactiveClicked()
  if self.curChooseTopTab == TopTab.ActivityAnnouncement then
    return
  end
  self.curChooseTopTab = TopTab.ActivityAnnouncement
  self.cur_leftselect_idx = 1
  UILuaHelper.PlayAnimationByName(self.m_pnl_mask, "lotterypage_tab_in")
  self:RefreshUI()
end

function Form_ActivityAnnounceLotterypage:OnTabsystemClicked()
  if self.curChooseTopTab == TopTab.SystemAnnouncement then
    return
  end
  self.curChooseTopTab = TopTab.SystemAnnouncement
  self.cur_leftselect_idx = 1
  UILuaHelper.PlayAnimationByName(self.m_pnl_mask, "lotterypage_tab_in")
  self:RefreshUI()
end

function Form_ActivityAnnounceLotterypage:OnTabaskClicked()
  if self.curChooseTopTab == TopTab.ConsultAnnouncement then
    return
  end
  self.curChooseTopTab = TopTab.ConsultAnnouncement
  self.cur_leftselect_idx = 1
  UILuaHelper.PlayAnimationByName(self.m_pnl_mask, "lotterypage_tab_in")
  self:RefreshUI()
end

function Form_ActivityAnnounceLotterypage:OnBtngoClicked()
  local announceCfg = self.curShowList[self.cur_leftselect_idx].m_stSdpConfig.stClientCfg
  if announceCfg.iNoticeType == 4 then
    DownloadManager:DownloadPreChangeStatus(true)
  end
  self:DealJump(announceCfg.iJumpTypeLast, announceCfg.sJumpParamLast)
end

function Form_ActivityAnnounceLotterypage:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_ActivityAnnounceLotterypage:IsOpenGuassianBlur()
  return true
end

function Form_ActivityAnnounceLotterypage:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  PushFaceManager:CheckShowNextPopPanel()
end

local fullscreen = true
ActiveLuaUI("Form_ActivityAnnounceLotterypage", Form_ActivityAnnounceLotterypage)
return Form_ActivityAnnounceLotterypage
