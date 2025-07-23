local Form_RankListMain = class("Form_RankListMain", require("UI/UIFrames/Form_RankListMainUI"))
local SubRankCount = 4

function Form_RankListMain:SetInitParam(param)
end

function Form_RankListMain:AfterInit()
  self.super.AfterInit(self)
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1162)
  self.m_LeftPrefabHelper = self.m_pnl_itemContent1:GetComponent("PrefabHelper")
  self.m_LeftPrefabHelper:RegisterCallback(handler(self, self.OnInitLeftRankItem))
  self.m_RightPrefabHelper = self.m_pnl_itemContent2:GetComponent("PrefabHelper")
  self.m_RightPrefabHelper:RegisterCallback(handler(self, self.OnInitRightRankItem))
  local levelRankBtn = self.m_btn_ClickLevelRank:GetComponent("ButtonExtensions")
  if levelRankBtn then
    levelRankBtn.Clicked = handler(self, self.OnBtnClickLevelRankClicked)
  end
  local towerRankBtn = self.m_btn_ClickTowerRank:GetComponent("ButtonExtensions")
  if towerRankBtn then
    towerRankBtn.Clicked = handler(self, self.OnBtnClickTowerRankClicked)
  end
  self.allRankInfoCfg = GlobalRankManager:GetAllRankInfoConfig()
  self:InitRankCompnents()
  self.timerlist = {}
  self.m_scrollview = self.m_scrollview_main:GetComponent("ScrollRect")
end

function Form_RankListMain:OnActive()
  self.super.OnActive(self)
  self.m_scrollview.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
  self:RefreshUI()
end

function Form_RankListMain:OnUncoverd()
  self.m_scrollview.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
end

function Form_RankListMain:OnInactive()
  self.super.OnInactive(self)
  if self.timerlist then
    for _, v in pairs(self.timerlist) do
      TimeService:KillTimer(v)
    end
  end
  self.timerlist = {}
end

function Form_RankListMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RankListMain:InitRankCompnents()
  self.RankCompnents = {}
  self.RankCompnents[self.allRankInfoCfg[1].m_RankID] = {
    node_head = self.m_pnl_levelrank_head,
    node_none = self.m_img_levelrank_none,
    node_lock = self.m_pnl_levelrank_lock,
    img_head = self.m_levelrank_head_Image,
    txt_name = self.m_txt_levelrank_name_Text,
    txt_guildname = self.m_txt_levelrank_guildname_Text,
    cfg = self.allRankInfoCfg[1],
    redDot = self.m_levelrank_redpoint,
    aniGo1 = self.m_pnl_left1
  }
  self.RankCompnents[self.allRankInfoCfg[6].m_RankID] = {
    node_head = self.m_pnl_towerrank_head,
    node_none = self.m_none_head_towerrank,
    node_lock = self.m_pnl_lock_towerrank,
    img_head = self.m_towerrank_head_Image,
    txt_name = self.m_txt_towerrank_name_Text,
    txt_guildname = self.m_txt_towerrank_guildname_Text,
    cfg = self.allRankInfoCfg[6],
    redDot = self.m_towerrank_redpoint,
    aniGo2 = self.m_pnl_left2
  }
  self.m_LeftPrefabHelper:CheckAndCreateObjs(SubRankCount)
  self.m_RightPrefabHelper:CheckAndCreateObjs(SubRankCount)
end

function Form_RankListMain:OnInitLeftRankItem(go, index)
  local idx = index + 1
  local transform = go.transform
  local cfg = self.allRankInfoCfg[idx + 1]
  self.RankCompnents[cfg.m_RankID] = {
    node_head = transform:Find("m_levelitem_normal").gameObject,
    node_none = transform:Find("m_levelitem_none").gameObject,
    node_lock = transform:Find("m_levelitem_lock").gameObject,
    img_head = transform:Find("m_levelitem_normal/m_levelitem_circle_head/pnl_head_mask/c_img_head"):GetComponent("Image"),
    txt_name = transform:Find("m_levelitem_normal/m_txt_levelitem_name"):GetComponent("TMPPro"),
    txt_guildname = transform:Find("m_levelitem_normal/m_txt_levelitem_guildname"):GetComponent("TMPPro"),
    cfg = cfg,
    redDot = transform:Find("m_levelitem_redpoint").gameObject,
    aniGo3 = go
  }
  local img_campIcon = transform:Find("m_levelitem_normal/m_levelitem_campicon"):GetComponent("Image")
  local img_campIconNone = transform:Find("m_levelitem_none/m_levelitem_campicon_none"):GetComponent("Image")
  local img_campIconLock = transform:Find("m_levelitem_lock/m_levelitem_campicon_lock"):GetComponent("Image")
  UILuaHelper.SetAtlasSprite(img_campIcon, cfg.m_ICON)
  UILuaHelper.SetAtlasSprite(img_campIconNone, cfg.m_ICON)
  UILuaHelper.SetAtlasSprite(img_campIconLock, cfg.m_ICON)
  local button = transform:Find("m_btn_ClickLevelItem"):GetComponent("ButtonExtensions")
  
  function button.Clicked()
    self:OnRankItemClicked(idx + 1)
  end
  
  local frame = transform:Find("m_img_framelevelrank").gameObject
  frame:SetActive(idx < 4)
end

function Form_RankListMain:OnInitRightRankItem(go, index)
  local idx = index + 1
  local transform = go.transform
  local cfg = self.allRankInfoCfg[idx + 6]
  self.RankCompnents[cfg.m_RankID] = {
    node_head = transform:Find("m_toweritem_normal").gameObject,
    node_none = transform:Find("m_toweritem_none").gameObject,
    node_lock = transform:Find("m_toweritem_lock").gameObject,
    img_head = transform:Find("m_toweritem_normal/m_toweritem_circle_head/pnl_head_mask/c_img_head"):GetComponent("Image"),
    txt_name = transform:Find("m_toweritem_normal/m_txt_toweritem_name"):GetComponent("TMPPro"),
    txt_guildname = transform:Find("m_toweritem_normal/m_txt_toweritem_guildname"):GetComponent("TMPPro"),
    cfg = cfg,
    redDot = transform:Find("m_toweritem_redpoint").gameObject,
    aniGo4 = go
  }
  local img_campIcon = transform:Find("m_toweritem_normal/m_toweritem_campicon"):GetComponent("Image")
  local img_campIconNone = transform:Find("m_toweritem_none/m_toweritem_campicon_none"):GetComponent("Image")
  local img_campIconLock = transform:Find("m_toweritem_lock/m_toweritem_campicon_lock"):GetComponent("Image")
  UILuaHelper.SetAtlasSprite(img_campIcon, cfg.m_ICON)
  UILuaHelper.SetAtlasSprite(img_campIconNone, cfg.m_ICON)
  UILuaHelper.SetAtlasSprite(img_campIconLock, cfg.m_ICON)
  local button = transform:Find("m_btn_ClickTowerItem"):GetComponent("ButtonExtensions")
  
  function button.Clicked()
    self:OnRankItemClicked(idx + 6)
  end
  
  local frame = transform:Find("m_img_frametower").gameObject
  frame:SetActive(idx < 4)
end

function Form_RankListMain:RefreshUI()
  local mTopRole = GlobalRankManager:GetRankListTopRole()
  for rankID, v in pairs(self.RankCompnents) do
    local data = mTopRole[rankID]
    local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(v.cfg.m_SystemID)
    if not openFlag then
      v.node_head:SetActive(false)
      v.node_none:SetActive(true)
      v.node_lock:SetActive(true)
    else
      if not data then
        v.node_head:SetActive(false)
        v.node_none:SetActive(true)
        v.node_lock:SetActive(false)
      else
        v.node_head:SetActive(true)
        v.node_none:SetActive(false)
        v.node_lock:SetActive(false)
        self:RefreshRoleInfo(rankID, data, v)
      end
      if LocalDataManager:GetIntSimple("RankListMain" .. rankID, 0) == 0 then
        LocalDataManager:SetIntSimple("RankListMain" .. rankID, 1)
        v.node_lock:SetActive(true)
        local aniLen
        if v.aniGo1 then
          UILuaHelper.PlayAnimationByName(v.aniGo1, "RankListMain_unlock")
          aniLen = UILuaHelper.GetAnimationLengthByName(self.aniGo1, "RankListMain_unlock")
        elseif v.aniGo2 then
          UILuaHelper.PlayAnimationByName(v.aniGo2, "RankListMain_unlock2")
          aniLen = UILuaHelper.GetAnimationLengthByName(self.aniGo2, "RankListMain_unlock2")
        elseif v.aniGo3 then
          UILuaHelper.PlayAnimationByName(v.aniGo3, "RankListMain_unlock_s2")
          aniLen = UILuaHelper.GetAnimationLengthByName(self.aniGo3, "RankListMain_unlock_s2")
        elseif v.aniGo4 then
          UILuaHelper.PlayAnimationByName(v.aniGo4, "RankListMain_unlock_s")
          aniLen = UILuaHelper.GetAnimationLengthByName(self.aniGo4, "RankListMain_unlock_s")
        end
        self.timerlist[rankID] = TimeService:SetTimer(aniLen, 1, function()
          v.node_lock:SetActive(false)
        end)
      end
    end
    self:RegisterOrUpdateRedDotItem(v.redDot, RedDotDefine.ModuleType.GlobalRankTab, {rankID})
  end
end

function Form_RankListMain:RefreshRoleInfo(rankID, roleInfo, compnonegts)
  GlobalRankManager:ReqRoleSeeBusinessCard(roleInfo.iRoleUid, roleInfo.iZoneId, function(data)
    local vTopHero = data.vTopHero
    if vTopHero and 0 < #vTopHero then
      local heroid = vTopHero[1].iHeroId
      local iFasionId = vTopHero[1].iFashion or 0
      if iFasionId and 0 < iFasionId then
        local fashionCfg = HeroManager:GetHeroFashion():GetFashionInfoByHeroIDAndFashionID(heroid, iFasionId)
        if not fashionCfg or fashionCfg:GetError() then
          ResourceUtil:CreateHeroHeadIcon(compnonegts.img_head, heroid)
          log.error("BattlePass skinCfgID Cannot Find Check Config: " .. iFasionId)
          return
        end
        local performanceID = fashionCfg.m_PerformanceID[0]
        local presentationData = CS.CData_Presentation.GetInstance():GetValue_ByPerformanceID(performanceID)
        local szIcon = presentationData.m_UIkeyword .. "001"
        UILuaHelper.SetAtlasSprite(compnonegts.img_head, szIcon)
      else
        ResourceUtil:CreateHeroHeadIcon(compnonegts.img_head, heroid)
      end
    end
  end)
  compnonegts.txt_name.text = roleInfo.sName
  compnonegts.txt_guildname.text = roleInfo.sAllianceName ~= "" and roleInfo.sAllianceName or ConfigManager:GetCommonTextById(20111) or ""
end

function Form_RankListMain:OnBtnClickLevelRankClicked()
  self:OnRankItemClicked(1)
end

function Form_RankListMain:OnBtnClickTowerRankClicked()
  self:OnRankItemClicked(6)
end

function Form_RankListMain:OnRankItemClicked(idx)
  local cfg = self.allRankInfoCfg[idx]
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(cfg.m_SystemID)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_RANKLISTCHARTS, {
    rankID = cfg.m_RankID
  })
end

function Form_RankListMain:OnBtncollectClicked()
  StackPopup:Push(UIDefines.ID_FORM_RANKLISTREWARDPOP)
end

function Form_RankListMain:OnBackClk()
  self:CloseForm()
end

function Form_RankListMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RankListMain", Form_RankListMain)
return Form_RankListMain
