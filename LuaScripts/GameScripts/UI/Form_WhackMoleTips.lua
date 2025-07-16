local Form_WhackMoleTips = class("Form_WhackMoleTips", require("UI/UIFrames/Form_WhackMoleTipsUI"))

function Form_WhackMoleTips:SetInitParam(param)
end

function Form_WhackMoleTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_WhackMoleTips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.formType = tParam.type
  self.backFun_Yes = tParam.backFun_Yes
  self.backFun_No = tParam.backFun_No
  self.backFun_Sure = tParam.backFun_Sure
  self:FreshData()
end

function Form_WhackMoleTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_WhackMoleTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_WhackMoleTips:FreshData()
  if self.formType then
    UILuaHelper.SetActive(self.m_pnl_txt1, self.formType == 1)
    UILuaHelper.SetActive(self.m_pnl_txt2, self.formType == 2)
    if self.formType == 2 then
      local bossConfig = self.m_csui.m_param.bossConfig
      if bossConfig then
        UILuaHelper.SetAtlasSprite(self.m_icon_boss_Image, bossConfig.m_Icon)
        self.m_txt_title2_Text.text = bossConfig.m_mName
        self.m_txt_desc2_Text.text = bossConfig.m_mDesc
      end
    end
  end
end

function Form_WhackMoleTips:OnBtnCloseClicked()
  self:CloseForm()
  if self.backFun_No then
    self.backFun_No()
  end
end

function Form_WhackMoleTips:OnBtnnoClicked()
  self:OnBtnCloseClicked()
end

function Form_WhackMoleTips:OnBtnyesClicked()
  self:CloseForm()
  if self.backFun_Yes then
    self.backFun_Yes()
  end
end

function Form_WhackMoleTips:OnBtnsureClicked()
  self:CloseForm()
  if self.backFun_Sure then
    self.backFun_Sure()
  end
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleTips", Form_WhackMoleTips)
return Form_WhackMoleTips
