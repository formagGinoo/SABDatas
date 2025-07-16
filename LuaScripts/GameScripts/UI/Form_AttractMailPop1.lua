local Form_AttractMailPop1 = class("Form_AttractMailPop1", require("UI/UIFrames/Form_AttractMailPop1UI"))

function Form_AttractMailPop1:SetInitParam(param)
end

function Form_AttractMailPop1:AfterInit()
  self.super.AfterInit(self)
  self.m_scroll = self.m_scrollView:GetComponent("ScrollRect")
  self.m_scroll2 = self.m_scrollView2:GetComponent("ScrollRect")
end

function Form_AttractMailPop1:OnActive()
  self.super.OnActive(self)
  local tempParams = self.m_csui.m_param
  self.callback = tempParams.callback
  self.attractArchiveCfg = tempParams.attractArchiveCfg
  self:FreshUI()
end

function Form_AttractMailPop1:OnInactive()
  self.super.OnInactive(self)
  if self.callback then
    self.callback()
    self.callback = nil
  end
end

function Form_AttractMailPop1:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_AttractMailPop1:FreshUI()
  if self.attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.NormalStory or self.attractArchiveCfg.m_ArchiveType == AttractManager.ArchiveType.File then
    self.m_pnl_txt1:SetActive(true)
    self.m_pnl_txt2:SetActive(false)
    self.m_txt_title_Text.text = self.attractArchiveCfg.m_mTitle
    self.m_txt_desc_Text.text = self.attractArchiveCfg.m_mText
    self.m_scroll.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
  else
    self.m_pnl_txt1:SetActive(false)
    self.m_pnl_txt2:SetActive(true)
    if self.attractArchiveCfg.m_ArchiveSubType == AttractManager.ArchiveSubType.SpecialStory3 then
      UILuaHelper.SetAtlasSprite(self.m_icon_paper_Image, self.attractArchiveCfg.m_ArchivePic)
      self.m_icon_paper:SetActive(true)
      self.m_img_bg_item:SetActive(false)
    else
      UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, self.attractArchiveCfg.m_ArchivePic)
      self.m_icon_paper:SetActive(false)
      self.m_img_bg_item:SetActive(true)
    end
    self.m_txt_title2_Text.text = self.attractArchiveCfg.m_mTitle
    self.m_txt_desc2_Text.text = self.attractArchiveCfg.m_mText
    self.m_scroll2.normalizedPosition = CS.UnityEngine.Vector2(0, 1)
  end
end

function Form_AttractMailPop1:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_AttractMailPop1:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_AttractMailPop1", Form_AttractMailPop1)
return Form_AttractMailPop1
