local Form_CastleEventMain = class("Form_CastleEventMain", require("UI/UIFrames/Form_CastleEventMainUI"))
local CastleStoryPerformAutoTime = tonumber(ConfigManager:GetGlobalSettingsByKey("CastleStoryPerformAutoTime"))
local CardMaxCount = 4
local LeadList = {}
local StoryPlayType = {Manual = 1, Auto = 2}
local TextEnterAniEnum = {
  [1] = "m_pnl_paper_dialogue_in1",
  [2] = "m_pnl_paper_dialogue_in2",
  [3] = "m_pnl_paper_dialogue_in3"
}
local CardAniList = {
  [1] = {
    ani_in = "m_pnl_leftrole_pic1_in",
    ani_out = "m_pnl_leftrole_pic1_out",
    ani_shock = "m_pnl_leftrole_pic1_shock",
    ani_jump = "m_pnl_leftrole_pic1_jump"
  },
  [2] = {
    ani_in = "m_pnl_right_role_pic2_in",
    ani_out = "m_pnl_right_role_pic2_out",
    ani_shock = "m_pnl_right_role_pic2_shock",
    ani_jump = "m_pnl_right_role_pic2_jump"
  },
  [3] = {
    ani_in = "m_pnl_leftrole_pic3_in",
    ani_out = "m_pnl_leftrole_pic3_out",
    ani_shock = "m_pnl_leftrole_pic3_shock",
    ani_jump = "m_pnl_leftrole_pic3_jump"
  },
  [4] = {
    ani_in = "m_pnl_right_role_pic4_in",
    ani_out = "m_pnl_right_role_pic4_out",
    ani_shock = "m_pnl_right_role_pic4_shock",
    ani_jump = "m_pnl_right_role_pic4_jump"
  }
}

function Form_CastleEventMain:SetInitParam(param)
end

function Form_CastleEventMain:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  local GlobalManagerIns = ConfigManager:GetConfigInsByName("GlobalSettings")
  local str = tonumber(GlobalManagerIns:GetValue_ByName("CastleStoryLead").m_Value)
  local data = string.split(str, ";")
  for i, v in pairs(data) do
    LeadList[#LeadList + 1] = tonumber(v)
  end
  self:InitCompnents()
  self:InitButtons()
end

function Form_CastleEventMain:OnActive()
  self.super.OnActive(self)
  local iStoryId = self.m_csui.m_param.cfg.m_StoryID
  self.m_showStoryType = self.m_csui.m_param.showStoryType
  self.mCharacter = utils.changeCSArrayToLuaTable(self.m_csui.m_param.cfg.m_Character)
  self.cfg = CastleStoryManager:GetCastleStoryPerformCfgByStoryID(iStoryId)
  self.curTextID = {
    [1] = 1
  }
  self.LoadedHeroList = {}
  self.mTextCache = {}
  self.m_storyPlayType = StoryPlayType.Manual
  self.m_chooseState = false
  self:StopAutoPlayStoryTimer()
  self:FreshUI()
  self:RefreshPlayTypeBtnState()
  self:ResetUI()
  self:ShowCurText()
end

function Form_CastleEventMain:OnInactive()
  self.super.OnInactive(self)
  self:StopAutoPlayStoryTimer()
  self:CheckRecycleAllSpine()
  if not self.m_enterAnimTimer then
    TimeService:KillTimer(self.m_enterAnimTimer)
    self.m_enterAnimTimer = nil
  end
  self.m_chooseState = false
end

function Form_CastleEventMain:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleAllSpine()
end

function Form_CastleEventMain:InitCompnents()
  self.mCradCompnents = {}
  for i = 1, CardMaxCount do
    local emotions = {}
    local expressionTrans = self["m_pnl_ expressionl" .. i].transform
    for j = 1, expressionTrans.childCount do
      local name = expressionTrans:GetChild(j - 1).name
      local res = string.split(name, tostring(i))
      if res and res[2] then
        emotions[res[2]] = self[name]
      end
    end
    self.mCradCompnents[i] = {
      obj = self["m_img_pic" .. i],
      img = self["m_img_hero" .. i .. "_Image"],
      spineRoot = self["m_root_hero" .. i],
      ownFrame = self["m_img_headown" .. i],
      otherFrame = self["m_img_headother" .. i],
      maskobj = self["m_head_black_mask" .. i],
      emotions = emotions
    }
  end
  self.mTextCompnents = {}
  local helper = self.m_paper_dialogue:GetComponent("PrefabHelper")
  helper:RegisterCallback(function(go, index)
    local transform = go.transform
    self.mTextCompnents[index + 1] = {
      go = go,
      mCanvasGroup = go:GetComponent("CanvasGroup"),
      m_BG_Normal = transform:Find("bg_Normal").gameObject,
      m_GrayNormal = transform:Find("c_bg_Normal_mask").gameObject,
      m_BG_Important = transform:Find("bg_Important").gameObject,
      m_GrayImportant = transform:Find("c_bg_Important_mask").gameObject,
      mNullTitle = transform:Find("pnl_eventtitleNull").gameObject,
      mTitle = transform:Find("pnl_eventtitle1").gameObject,
      mNormalObj = transform:Find("pnl_eventtitle1/c_txt_eventtitle1").gameObject,
      mImportantObj = transform:Find("pnl_eventtitle1/c_txt_playername1").gameObject,
      mTxtNormal_Text = transform:Find("pnl_eventtitle1/c_txt_eventtitle1"):GetComponent("TMPPro"),
      mTxtImportant_Text = transform:Find("pnl_eventtitle1/c_txt_playername1"):GetComponent("TMPPro"),
      m_TxtContent_Text = transform:Find("c_txt_eventinformation1"):GetComponent("TMPPro")
    }
  end)
  helper:CheckAndCreateObjs(4)
  for _, v in ipairs(self.mTextCompnents) do
    v.mCanvasGroup.alpha = 0
  end
end

function Form_CastleEventMain:InitButtons()
  self.m_pnl_blood_type1:SetActive(false)
  self.m_btn_type1_BtnEx = self.m_btn_type1:GetComponent("ButtonExtensions")
  if self.m_btn_type1_BtnEx then
    function self.m_btn_type1_BtnEx.Down()
      self.m_pnl_blood_type1:SetActive(true)
    end
    
    function self.m_btn_type1_BtnEx.Up()
      self.m_pnl_blood_type1:SetActive(false)
    end
    
    self.m_btn_type1_BtnEx.Clicked = handler(self, self.OnClickChoose01)
  end
  self.m_btn_choose1_BtnEx = self.m_btn_choose1:GetComponent("ButtonExtensions")
  if self.m_btn_choose1_BtnEx then
    function self.m_btn_choose1_BtnEx.Down()
      self.m_pnl_blood_choose1:SetActive(true)
    end
    
    function self.m_btn_choose1_BtnEx.Up()
      self.m_pnl_blood_choose1:SetActive(false)
    end
    
    self.m_btn_choose1_BtnEx.Clicked = handler(self, self.OnClickChoose01)
  end
  self.m_btn_choose2_BtnEx = self.m_btn_choose2:GetComponent("ButtonExtensions")
  if self.m_btn_choose2_BtnEx then
    function self.m_btn_choose2_BtnEx.Down()
      self.m_pnl_blood_choose2:SetActive(true)
    end
    
    function self.m_btn_choose2_BtnEx.Up()
      self.m_pnl_blood_choose2:SetActive(false)
    end
    
    self.m_btn_choose2_BtnEx.Clicked = handler(self, self.OnClickChoose02)
  end
  self.m_btn_ok_BtnEx = self.m_btn_ok:GetComponent("ButtonExtensions")
  if self.m_btn_ok_BtnEx then
    function self.m_btn_ok_BtnEx.Down()
      self.m_pnl_bloodok:SetActive(true)
    end
    
    function self.m_btn_ok_BtnEx.Up()
      self.m_pnl_bloodok:SetActive(false)
    end
    
    self.m_btn_ok_BtnEx.Clicked = handler(self, self.OnClickChoose02)
  end
  self.m_btn_yes_BtnEx = self.m_btn_yes:GetComponent("ButtonExtensions")
  if self.m_btn_yes_BtnEx then
    function self.m_btn_yes_BtnEx.Down()
      self.m_pnl_bloodyes:SetActive(true)
    end
    
    function self.m_btn_yes_BtnEx.Up()
      self.m_pnl_bloodyes:SetActive(false)
    end
    
    self.m_btn_yes_BtnEx.Clicked = handler(self, self.OnClickChoose01)
  end
  self.m_btn_no_BtnEx = self.m_btn_no:GetComponent("ButtonExtensions")
  if self.m_btn_no_BtnEx then
    function self.m_btn_no_BtnEx.Down()
      self.m_pnl_bloodno:SetActive(true)
    end
    
    function self.m_btn_no_BtnEx.Up()
      self.m_pnl_bloodno:SetActive(false)
    end
    
    self.m_btn_no_BtnEx.Clicked = handler(self, self.OnClickChoose03)
  end
end

function Form_CastleEventMain:FreshUI()
  local placeID = self.m_csui.m_param.cfg.m_PlaceID
  local placeCfg = CastleManager:GetCastlePlaceCfgByID(placeID)
  self.m_txt_placename_Text.text = placeCfg.m_mName
end

function Form_CastleEventMain:RefreshPlayTypeBtnState()
  self.m_btn_manual:SetActive(self.m_storyPlayType == StoryPlayType.Manual)
  self.m_btn_auto:SetActive(self.m_storyPlayType == StoryPlayType.Auto)
end

function Form_CastleEventMain:AutoPlayStoryTimer(time)
  if not time or time == 0 then
    time = CastleStoryPerformAutoTime
  end
  self:StopAutoPlayStoryTimer()
  self.m_autoPlayStoryTimer = TimeService:SetTimer(time, 1, function()
    self:StopAutoPlayStoryTimer()
    self:DoNextStep()
  end)
end

function Form_CastleEventMain:StopAutoPlayStoryTimer()
  if self.m_autoPlayStoryTimer then
    TimeService:KillTimer(self.m_autoPlayStoryTimer)
    self.m_autoPlayStoryTimer = nil
  end
end

function Form_CastleEventMain:ResetUI()
  for i, v in ipairs(self.mCradCompnents) do
    v.obj:SetActive(false)
    if i == 1 or i == 3 then
      v.obj.transform:SetAsLastSibling()
    end
  end
  for _, v in ipairs(self.mTextCompnents) do
    v.mCanvasGroup.alpha = 0
  end
  self.curLeft = nil
  self.curRight = nil
  self.curTextAniIdx = 1
  self.curTextComIdx = 1
  self.m_btn_block:SetActive(false)
end

function Form_CastleEventMain:ResetBtns()
  if self.m_btn_type1.activeSelf then
    UILuaHelper.PlayAnimationByName(self.m_btn_type1, "m_pnl_down_type1_out")
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_btn_type1, "m_pnl_down_type1_out")
    TimeService:SetTimer(aniLen, 1, function()
      self.m_btn_type1:SetActive(false)
    end)
  end
  if self.m_pnl_type2.activeSelf then
    UILuaHelper.PlayAnimationByName(self.m_pnl_type2, "m_pnl_down_type2_out")
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_type2, "m_pnl_down_type2_out")
    TimeService:SetTimer(aniLen, 1, function()
      self.m_pnl_type2:SetActive(false)
    end)
  end
  if self.m_pnl_group_btn.activeSelf then
    UILuaHelper.PlayAnimationByName(self.m_pnl_group_btn, "m_pnl_down_group_out")
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_group_btn, "m_pnl_down_group_out")
    TimeService:SetTimer(aniLen, 1, function()
      self.m_pnl_group_btn:SetActive(false)
    end)
  end
  self.m_btn_click:SetActive(false)
  self.m_btn_continue:SetActive(false)
  self.m_btn_next:SetActive(false)
end

function Form_CastleEventMain:ShowCurText()
  if self.curTextID[1] == 0 then
    return
  end
  self:ResetBtns()
  local info = self.cfg[self.curTextID[1]]
  local speaker = info.m_Speaker
  local SpecailSpeaker = info.m_SpecailSpeaker
  local heroID, iconPath
  if speaker and 0 < speaker then
    heroID = self.mCharacter[speaker]
  end
  if SpecailSpeaker and SpecailSpeaker ~= "" then
    local temp = string.split(SpecailSpeaker, "/")
    if temp then
      local specialType = tonumber(temp[1])
      if specialType == 1 then
        heroID = tonumber(temp[2])
      elseif specialType == 2 then
        heroID = nil
        iconPath = temp[2] .. "/" .. temp[3]
      end
    end
  end
  local is_leader = self:IsLeader(heroID)
  local textCom = self.mTextCompnents[self.curTextComIdx]
  textCom.mCanvasGroup.alpha = 0
  local textType = info.m_TextType
  self:ChangeBg(info)
  if textType == CastleStoryManager.TextTypeEnum.Speak then
    textCom.m_BG_Normal:SetActive(false)
    textCom.m_BG_Important:SetActive(true)
    textCom.mTitle:SetActive(true)
    textCom.mNullTitle:SetActive(false)
    if is_leader then
      textCom.mNormalObj:SetActive(false)
      textCom.mImportantObj:SetActive(true)
      self.mCradCompnents[speaker].ownFrame:SetActive(true)
      self.mCradCompnents[speaker].otherFrame:SetActive(false)
    else
      textCom.mNormalObj:SetActive(true)
      textCom.mImportantObj:SetActive(false)
      self.mCradCompnents[speaker].ownFrame:SetActive(false)
      self.mCradCompnents[speaker].otherFrame:SetActive(true)
    end
    textCom.mTxtNormal_Text.text = info.m_mName
    textCom.mTxtImportant_Text.text = info.m_mName
    textCom.m_TxtContent_Text.text = info.m_mText
    if heroID then
      local heroCfg = HeroManager:GetHeroConfigByID(heroID)
      self.mCradCompnents[speaker].img.gameObject:SetActive(false)
      self.mCradCompnents[speaker].spineRoot:SetActive(true)
      if not self.LoadedHeroList[heroID] then
        self:LoadHeroSpine(heroID, heroCfg.m_Spine, self.mCradCompnents[speaker].spineRoot, function()
          self.mCradCompnents[speaker].obj:SetActive(true)
          self:PlayAniAndChangeOrder(speaker, true)
        end)
      else
        self.mCradCompnents[speaker].obj:SetActive(true)
        self:PlayAniAndChangeOrder(speaker)
      end
    else
      self.mCradCompnents[speaker].obj:SetActive(true)
      self:PlayAniAndChangeOrder(speaker)
      self.mCradCompnents[speaker].spineRoot:SetActive(false)
      self.mCradCompnents[speaker].img.gameObject:SetActive(true)
      UILuaHelper.SetAtlasSprite(self.mCradCompnents[speaker].img, iconPath)
    end
  elseif textType == CastleStoryManager.TextTypeEnum.Text then
    textCom.mTitle:SetActive(false)
    textCom.mNullTitle:SetActive(true)
    textCom.m_BG_Normal:SetActive(true)
    textCom.m_BG_Important:SetActive(false)
    textCom.mNormalObj:SetActive(true)
    textCom.mImportantObj:SetActive(false)
    textCom.m_TxtContent_Text.text = info.m_mText
    textCom.mTxtNormal_Text.text = info.m_mName
  end
  if info.m_Voice and info.m_Voice ~= "" then
    UILuaHelper.StartPlaySFX(info.m_Voice)
  end
  if info.m_Music and 0 < info.m_Music then
    CS.GlobalManager.Instance:TriggerWwiseBGMState(info.m_Music)
  end
  for role, v in ipairs(self.mCradCompnents) do
    for emotionStr, go in pairs(v.emotions) do
      go:SetActive(emotionStr == info["m_Role" .. role .. "Emotion"])
    end
    if info["m_Role" .. role .. "Effect"] == 1 then
      UILuaHelper.PlayAnimationByName(v.obj, CardAniList[role].ani_shock)
    end
    if role == speaker then
      self.mCradCompnents[role].maskobj:SetActive(false)
    else
      self.mCradCompnents[role].maskobj:SetActive(true)
    end
  end
  self:SpeakerGoOut(info)
  if info.m_ItemPic and info.m_ItemPic ~= "" then
    self.m_txt_iconname_Text.text = info.m_mItemName
    UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, info.m_ItemPic)
    self.m_pnl_item:SetActive(true)
  elseif self.m_pnl_item.activeSelf then
    UILuaHelper.PlayAnimationByName(self.m_pnl_item, "m_pnl_information_item1_out")
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_item, "m_pnl_information_item1_out")
    TimeService:SetTimer(aniLen, 1, function()
      self.m_pnl_item:SetActive(false)
    end)
  end
  self.mTextCache[#self.mTextCache + 1] = {
    textType = textType,
    ID = self.curTextID,
    is_leader = is_leader
  }
  local aniName = TextEnterAniEnum[self.curTextAniIdx]
  textCom.mCanvasGroup.alpha = 1
  textCom.go.transform:SetAsLastSibling()
  UILuaHelper.PlayAnimationByName(textCom.go, aniName)
  local aniLen = UILuaHelper.GetAnimationLengthByName(textCom.go, aniName)
  if not self.m_enterAnimTimer then
    TimeService:KillTimer(self.m_enterAnimTimer)
    self.m_enterAnimTimer = nil
  end
  self.m_enterAnimTimer = TimeService:SetTimer(aniLen, 1, function()
    if not utils.isNull(self.m_btn_continue) then
      self.m_btn_continue:SetActive(true)
      self.m_btn_next:SetActive(true)
      self:CheckShowEnd()
    end
  end)
  for i, v in ipairs(self.mTextCompnents) do
    if self.curTextComIdx ~= i then
      if v.m_BG_Normal.activeSelf then
        v.m_GrayNormal:SetActive(true)
      else
        v.m_GrayImportant:SetActive(true)
      end
    else
      v.m_GrayNormal:SetActive(false)
      v.m_GrayImportant:SetActive(false)
    end
  end
  if 3 > self.curTextAniIdx then
    self.curTextAniIdx = self.curTextAniIdx + 1
  else
    self.curTextAniIdx = 1
  end
  if self.curTextComIdx < 4 then
    self.curTextComIdx = self.curTextComIdx + 1
  else
    self.curTextComIdx = 1
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(217)
  if self.m_storyPlayType == StoryPlayType.Auto and info.m_AutoTime then
    self:AutoPlayStoryTimer(info.m_AutoTime)
  end
end

function Form_CastleEventMain:SpeakerGoOut(info)
  if not info then
    return
  end
  local outSpeakerList = utils.changeCSArrayToLuaTable(info.m_OutSpeaker)
  if table.getn(outSpeakerList) > 0 then
    for i, outSpeaker in ipairs(outSpeakerList) do
      local heroID
      if outSpeaker and 0 < outSpeaker then
        heroID = self.mCharacter[outSpeaker]
      end
      if heroID then
        UILuaHelper.PlayAnimationByName(self.mCradCompnents[outSpeaker].obj, CardAniList[outSpeaker].ani_out)
        local aniLen = UILuaHelper.GetAnimationLengthByName(self.mCradCompnents[outSpeaker].obj, CardAniList[outSpeaker].ani_out)
        local sequenceJump = Tweening.DOTween.Sequence()
        sequenceJump:AppendInterval(aniLen)
        sequenceJump:OnComplete(function()
          if not utils.isNull(self.mCradCompnents[outSpeaker].obj) then
            self.mCradCompnents[outSpeaker].obj:SetActive(false)
          end
        end)
        sequenceJump:SetAutoKill(true)
      end
    end
  end
end

function Form_CastleEventMain:ChangeBg(info)
  if not info then
    return
  end
  if info.m_PlaceBG and info.m_PlaceBG ~= "" then
    UILuaHelper.SetAtlasSprite(self.m_img_bg_Image, info.m_PlaceBG)
  end
  local placeID = self.m_csui.m_param.cfg.m_PlaceID
  local placeCfg = CastleManager:GetCastlePlaceCfgByID(placeID)
  local flag = ConfigManager:CheckConfigFieldStrIsEmpty(info.m_mPlaceSubName)
  if not flag and placeCfg then
    self.m_txt_placename_Text.text = placeCfg.m_mName .. tostring(info.m_mPlaceSubName)
  end
end

function Form_CastleEventMain:ShowCurChoose()
  local nextIDs = self.curTextID
  local count = #nextIDs
  self:ResetBtns()
  if count == 1 then
    self.m_btn_type1:SetActive(true)
    UILuaHelper.PlayAnimationByName(self.m_btn_type1, "m_pnl_down_type1_in")
    local info = self.cfg[nextIDs[1]]
    self.m_txt_type1_Text.text = info.m_mText
  elseif count == 2 then
    self.m_pnl_type2:SetActive(true)
    UILuaHelper.PlayAnimationByName(self.m_pnl_type2, "m_pnl_down_type2_in")
    local info01 = self.cfg[nextIDs[1]]
    self.m_txt_choose1_Text.text = info01.m_mText
    local info02 = self.cfg[nextIDs[2]]
    self.m_txt_choose2_Text.text = info02.m_mText
  elseif count == 3 then
    self.m_pnl_group_btn:SetActive(true)
    UILuaHelper.PlayAnimationByName(self.m_pnl_group_btn, "m_pnl_down_group_in")
    local info01 = self.cfg[nextIDs[1]]
    self.m_txt_tryyes_Text.text = info01.m_mText
    local info02 = self.cfg[nextIDs[2]]
    self.m_txt_ok_Text.text = info02.m_mText
    local info03 = self.cfg[nextIDs[3]]
    self.m_txt_no_Text.text = info03.m_mText
  end
  self.mTextCache[#self.mTextCache + 1] = {
    textType = CastleStoryManager.TextTypeEnum.Choose,
    ID = nextIDs,
    chooseIdx = nil
  }
end

function Form_CastleEventMain:DoNextStep()
  local info
  if self.curChoose then
    info = self.cfg[self.curTextID[self.curChoose]]
    self.mTextCache[#self.mTextCache].chooseIdx = self.curChoose
    self.curChoose = nil
    self.m_chooseState = false
  else
    info = self.cfg[self.curTextID[1]]
  end
  if not info then
    log.error("Form_CastleEventMain:DoNextStep() info is nil---" .. self.curTextID[1])
    return
  end
  local nextIDs = utils.changeCSArrayToLuaTable(info.m_Next_ID)
  local nextID = nextIDs[1]
  if nextID and 0 < nextID then
    self.curTextID = nextIDs
    if not self.cfg[nextID] then
      log.error("Form_CastleEventMain:DoNextStep() nextID is nil---" .. nextID)
      return
    end
    if self.cfg[nextID].m_TextType == CastleStoryManager.TextTypeEnum.Choose then
      self:StopAutoPlayStoryTimer()
      self:ShowCurChoose()
      self.m_chooseState = true
    else
      self:ShowCurText()
    end
  end
end

function Form_CastleEventMain:IsLeader(heroID)
  for key, v in pairs(LeadList) do
    if heroID == v then
      return true
    end
  end
  return false
end

function Form_CastleEventMain:CheckShowEnd()
  local info = self.cfg[self.curTextID[1]]
  local nextid = info.m_Next_ID[0]
  if nextid == 0 then
    self:ResetBtns()
    self.m_btn_click:SetActive(true)
    self.m_btn_block:SetActive(true)
  end
end

function Form_CastleEventMain:PlayAniAndChangeOrder(speaker, is_first)
  if (speaker == 1 or speaker == 3) and self.curLeft ~= speaker then
    if is_first then
      UILuaHelper.SetLocalPosition(self.mCradCompnents[speaker].obj, 10000, 0, 0)
      UILuaHelper.PlayAnimationByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_in)
      self.mCradCompnents[speaker].obj.transform:SetAsLastSibling()
    else
      UILuaHelper.PlayAnimationByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_out)
      local aniLen = UILuaHelper.GetAnimationLengthByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_out)
      TimeService:SetTimer(aniLen, 1, function()
        UILuaHelper.PlayAnimationByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_in)
        self.mCradCompnents[speaker].obj.transform:SetAsLastSibling()
      end)
    end
    self.curLeft = speaker
  elseif (speaker == 2 or speaker == 4) and self.curRight ~= speaker then
    if is_first then
      UILuaHelper.SetLocalPosition(self.mCradCompnents[speaker].obj, 10000, 0, 0)
      UILuaHelper.PlayAnimationByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_in)
      self.mCradCompnents[speaker].obj.transform:SetAsLastSibling()
    else
      UILuaHelper.PlayAnimationByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_out)
      local aniLen = UILuaHelper.GetAnimationLengthByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_out)
      TimeService:SetTimer(aniLen, 1, function()
        UILuaHelper.PlayAnimationByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_in)
        self.mCradCompnents[speaker].obj.transform:SetAsLastSibling()
      end)
    end
    self.curRight = speaker
  else
    UILuaHelper.PlayAnimationByName(self.mCradCompnents[speaker].obj, CardAniList[speaker].ani_jump)
  end
end

function Form_CastleEventMain:RqsFinishEvent(is_skip)
  CastleStoryManager:RqsCastleDoPlaceStory(self.m_csui.m_param.cfg.m_StoryID, is_skip, function()
    self:CloseForm()
  end)
end

function Form_CastleEventMain:CheckRecycleAllSpine()
  if not self.LoadedHeroList then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  local heroSpineObjKey = next(self.LoadedHeroList)
  if heroSpineObjKey then
    local heroSpineObj = self.LoadedHeroList[heroSpineObjKey]
    if heroSpineObj then
      UILuaHelper.SpineResetMatParam(heroSpineObj.spineObj)
    end
  end
  for i, tempHeroSpineObj in pairs(self.LoadedHeroList) do
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(tempHeroSpineObj)
  end
  self.LoadedHeroList = {}
end

function Form_CastleEventMain:CheckRecycleSpine(heroID)
  if self.m_HeroSpineDynamicLoader and self.LoadedHeroList[heroID] ~= nil then
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.LoadedHeroList[heroID])
    self.LoadedHeroList[heroID] = nil
  end
end

function Form_CastleEventMain:LoadHeroSpine(heroID, heroSpineAssetName, uiParent, loadSucBack)
  if not heroID then
    return
  end
  if not heroSpineAssetName then
    return
  end
  local showTypeStr = "herocastlestorycard"
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine(heroID)
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine(heroID)
      self.LoadedHeroList[heroID] = spineLoadObj
      local spineObj = spineLoadObj.spineObj
      UILuaHelper.SetActive(spineObj, true)
      UILuaHelper.SpineResetInit(spineObj)
      UILuaHelper.SetSpineTimeScale(spineObj, 0)
      local heroSpineTrans = spineLoadObj.spineTrans
      if heroSpineTrans:GetComponent("SpineSkeletonPosControl") then
        heroSpineTrans:GetComponent("SpineSkeletonPosControl"):OnResetInit()
      end
      if loadSucBack then
        loadSucBack()
      end
    end)
  end
end

function Form_CastleEventMain:OnBtnautoClicked()
  self.m_storyPlayType = StoryPlayType.Manual
  self:RefreshPlayTypeBtnState()
  self:StopAutoPlayStoryTimer()
end

function Form_CastleEventMain:OnBtnmanualClicked()
  self.m_storyPlayType = StoryPlayType.Auto
  self:RefreshPlayTypeBtnState()
  if self.m_chooseState then
    return
  end
  self:AutoPlayStoryTimer()
end

function Form_CastleEventMain:OnBtnreviewClicked()
  self:OnBtnautoClicked()
  StackPopup:Push(UIDefines.ID_FORM_CASTLEEVENTSTORY, {
    cache = self.mTextCache,
    cfg = self.cfg
  })
end

function Form_CastleEventMain:OnBtnskipClicked()
  if self.m_showStoryType == CastleStoryManager.ShowStoryType.Playback then
    self:CloseForm()
  else
    utils.popUpDirectionsUI({
      tipsID = 1179,
      func1 = function()
        self:RqsFinishEvent(true)
      end
    })
  end
end

function Form_CastleEventMain:OnBtnblockClicked()
  if self.m_showStoryType == CastleStoryManager.ShowStoryType.Playback then
    self:CloseForm()
  else
    self:RqsFinishEvent()
  end
end

function Form_CastleEventMain:OnBtncontinue1Clicked()
  self:DoNextStep()
end

function Form_CastleEventMain:OnBtncontinue2Clicked()
  self:DoNextStep()
end

function Form_CastleEventMain:OnBtnnextClicked()
  self:DoNextStep()
end

function Form_CastleEventMain:OnClickChoose01()
  self.curChoose = 1
  self:DoNextStep()
end

function Form_CastleEventMain:OnClickChoose02()
  self.curChoose = 2
  self:DoNextStep()
end

function Form_CastleEventMain:OnClickChoose03()
  self.curChoose = 3
  self:DoNextStep()
end

function Form_CastleEventMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleEventMain", Form_CastleEventMain)
return Form_CastleEventMain
