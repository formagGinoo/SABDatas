local Form_activity106_Dialogueclue = class("Form_activity106_Dialogueclue", require("UI/UIFrames/Form_activity106_DialogueclueUI"))

function Form_activity106_Dialogueclue:SetInitParam(param)
end

function Form_activity106_Dialogueclue:AfterInit()
  self.super.AfterInit(self)
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_AniRoot = self.m_rootTrans:Find("content_node")
  self.TypeEnum = {Left = 1, Right = 2}
  self.m_scrollRectL = self.m_txt_scrollview_l:GetComponent("ScrollRect")
  self.m_scrollRectR = self.m_txt_scrollview_r:GetComponent("ScrollRect")
end

function Form_activity106_Dialogueclue:OnActive()
  self.super.OnActive(self)
  self.iCurPage = self.iCurPage or 1
  UILuaHelper.ResetAnimationByName(self.m_AniRoot, "Activity106_Dialogueclue_cutover_l")
  UILuaHelper.ResetAnimationByName(self.m_AniRoot, "Activity106_Dialogueclue_cutover_r")
  self:InitData()
  self:RefreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(350)
end

function Form_activity106_Dialogueclue:OnInactive()
  self.super.OnInactive(self)
end

function Form_activity106_Dialogueclue:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_activity106_Dialogueclue:InitData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.iActivityID = tonumber(tParam.iActivityId)
    self.iStoryID = tonumber(tParam.iStoryID)
    self.bIsSolo = tParam.bIsSolo
    self.m_csui.m_param = nil
  end
  if self.bIsSolo then
    return
  end
  local vCfgs = HeroActivityManager:GetAllActLostStoryCfg(self.iActivityID)
  if not vCfgs or #vCfgs <= 0 then
    return
  end
  local cfgs = {}
  for _, v in ipairs(vCfgs) do
    if self.m_levelHelper:IsLevelHavePass(v.m_LevelID) then
      table.insert(cfgs, v)
    end
  end
  self.vCfgs = cfgs
end

function Form_activity106_Dialogueclue:RefreshUI()
  if self.bIsSolo then
    self.m_btn_arrow_l:SetActive(false)
    self.m_btn_arrow_r:SetActive(false)
    self:FreshPageInfo(self.iStoryID)
  else
    self.m_btn_arrow_l:SetActive(true)
    self.m_btn_arrow_r:SetActive(true)
    local cfg = self.vCfgs[self.iCurPage]
    self:FreshPageInfo(cfg.m_StoryID)
    self:FreshPageBtn()
  end
end

function Form_activity106_Dialogueclue:FreshPageInfo(iStoryID)
  local cfg = HeroActivityManager:GetActLostStoryCfgByID(iStoryID)
  if cfg then
    local iType = cfg.m_Type
    if iType == self.TypeEnum.Left then
      self.m_pnl_l:SetActive(true)
      self.m_pnl_r:SetActive(false)
      self.m_txt_title_l_Text.text = cfg.m_mTitle
      self.m_txt_des_l_Text.text = cfg.m_mText
      self.m_scrollRectL.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
      UILuaHelper.SetAtlasSprite(self.m_img_l_Image, cfg.m_StoryPic)
      self.m_txt_number_l_Text.text = cfg.m_mFootnote
    elseif iType == self.TypeEnum.Right then
      self.m_pnl_l:SetActive(false)
      self.m_pnl_r:SetActive(true)
      self.m_txt_title_r_Text.text = cfg.m_mTitle
      self.m_txt_des_r_Text.text = cfg.m_mText
      self.m_scrollRectR.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
      UILuaHelper.SetAtlasSprite(self.m_img_r_Image, cfg.m_StoryPic)
      self.m_txt_number_r_Text.text = cfg.m_mFootnote
    end
  end
end

function Form_activity106_Dialogueclue:FreshPageBtn()
  if self.iCurPage == 1 then
    self.m_btn_arrow_l:SetActive(false)
  else
    self.m_btn_arrow_l:SetActive(true)
  end
  if self.iCurPage == #self.vCfgs then
    self.m_btn_arrow_r:SetActive(false)
  else
    self.m_btn_arrow_r:SetActive(true)
  end
end

function Form_activity106_Dialogueclue:OnBtnarrowlClicked()
  self.iCurPage = self.iCurPage - 1
  if self.iCurPage < 1 then
    self.iCurPage = 1
  end
  UILuaHelper.PlayAnimationByName(self.m_AniRoot, "Activity106_Dialogueclue_cutover_l")
  self:RefreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(354)
end

function Form_activity106_Dialogueclue:OnBtnarrowrClicked()
  self.iCurPage = self.iCurPage + 1
  if self.iCurPage > #self.vCfgs then
    self.iCurPage = #self.vCfgs
  end
  UILuaHelper.PlayAnimationByName(self.m_AniRoot, "Activity106_Dialogueclue_cutover_r")
  self:RefreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(354)
end

function Form_activity106_Dialogueclue:OnBackClk()
  self:CloseForm()
end

function Form_activity106_Dialogueclue:OnBtnCloseClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_activity106_Dialogueclue", Form_activity106_Dialogueclue)
return Form_activity106_Dialogueclue
