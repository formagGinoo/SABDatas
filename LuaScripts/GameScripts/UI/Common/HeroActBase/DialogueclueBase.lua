local DialogueclueBase = class("DialogueclueBase", require("UI/Common/UIBase"))

function DialogueclueBase:AfterInit()
  DialogueclueBase.super.AfterInit(self)
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_AniRoot = self.m_rootTrans:Find("content_node")
  self.TypeEnum = {Left = 1, Right = 2}
  if not utils.isNull(self.m_txt_scrollview_l) then
    self.m_scrollRectL = self.m_txt_scrollview_l:GetComponent("ScrollRect")
  end
  if not utils.isNull(self.m_txt_scrollview_r) then
    self.m_scrollRectR = self.m_txt_scrollview_r:GetComponent("ScrollRect")
  end
  self.sAniName1 = "Activity106_Dialogueclue_cutover_l"
  self.sAniName2 = "Activity106_Dialogueclue_cutover_r"
end

function DialogueclueBase:OnActive()
  DialogueclueBase.super.OnActive(self)
  self.iCurPage = self.iCurPage or 1
  UILuaHelper.ResetAnimationByName(self.m_AniRoot, self.sAniName1)
  UILuaHelper.ResetAnimationByName(self.m_AniRoot, self.sAniName2)
  self:InitData()
  self:RefreshUI()
end

function DialogueclueBase:OnInactive()
  DialogueclueBase.super.OnInactive(self)
end

function DialogueclueBase:OnDestroy()
  DialogueclueBase.super.OnDestroy(self)
end

function DialogueclueBase:InitData()
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

function DialogueclueBase:RefreshUI()
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

function DialogueclueBase:FreshPageInfo(iStoryID)
  local cfg = HeroActivityManager:GetActLostStoryCfgByID(iStoryID)
  if cfg then
    local iType = cfg.m_Type
    if iType == self.TypeEnum.Left then
      if not utils.isNull(self.m_pnl_l) then
        self.m_pnl_l:SetActive(true)
      end
      if not utils.isNull(self.m_pnl_r) then
        self.m_pnl_r:SetActive(false)
      end
      if not utils.isNull(self.m_txt_title_l_Text) then
        self.m_txt_title_l_Text.text = cfg.m_mTitle
      end
      if not utils.isNull(self.m_txt_des_l_Text) then
        self.m_txt_des_l_Text.text = cfg.m_mText
      end
      if not utils.isNull(self.m_scrollRectL) then
        self.m_scrollRectL.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
      end
      if not utils.isNull(self.m_img_l_Image) then
        UILuaHelper.SetAtlasSprite(self.m_img_l_Image, cfg.m_StoryPic)
      end
      if not utils.isNull(self.m_img_maskl_Image) then
        UILuaHelper.SetUITexture(self.m_img_maskl_Image, cfg.m_StoryPic)
      end
      if not utils.isNull(self.m_txt_number_l_Text) then
        self.m_txt_number_l_Text.text = cfg.m_mFootnote
      end
      if self.bIsSolo then
        UILuaHelper.PlayAnimationByName(self.m_pnl_l, "Activity112_Dialogueclue_PicGreyUnlock")
      elseif not utils.isNull(self.m_img_maskl) then
        self.m_img_maskl:SetActive(false)
        self.m_img_l:SetActive(true)
      end
    elseif iType == self.TypeEnum.Right then
      if not utils.isNull(self.m_pnl_l) then
        self.m_pnl_l:SetActive(false)
      end
      if not utils.isNull(self.m_pnl_r) then
        self.m_pnl_r:SetActive(true)
      end
      if not utils.isNull(self.m_txt_title_r_Text) then
        self.m_txt_title_r_Text.text = cfg.m_mTitle
      end
      if not utils.isNull(self.m_txt_des_r_Text) then
        self.m_txt_des_r_Text.text = cfg.m_mText
      end
      if not utils.isNull(self.m_scrollRectR) then
        self.m_scrollRectR.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
      end
      if not utils.isNull(self.m_img_r_Image) then
        UILuaHelper.SetAtlasSprite(self.m_img_r_Image, cfg.m_StoryPic)
      end
      if not utils.isNull(self.m_txt_number_r_Text) then
        self.m_txt_number_r_Text.text = cfg.m_mFootnote
      end
    end
  end
end

function DialogueclueBase:FreshPageBtn()
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

function DialogueclueBase:OnBtnarrowlClicked()
  self.iCurPage = self.iCurPage - 1
  if self.iCurPage < 1 then
    self.iCurPage = 1
  end
  UILuaHelper.PlayAnimationByName(self.m_AniRoot, self.sAniName1)
  self:RefreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(354)
end

function DialogueclueBase:OnBtnarrowrClicked()
  self.iCurPage = self.iCurPage + 1
  if self.iCurPage > #self.vCfgs then
    self.iCurPage = #self.vCfgs
  end
  UILuaHelper.PlayAnimationByName(self.m_AniRoot, self.sAniName2)
  self:RefreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(354)
end

function DialogueclueBase:OnBackClk()
  self:CloseForm()
end

function DialogueclueBase:OnBtnCloseClicked()
  self:CloseForm()
end

return DialogueclueBase
