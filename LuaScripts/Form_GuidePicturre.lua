local Form_GuidePicturre = class("Form_GuidePicturre", require("UI/UIFrames/Form_GuidePicturreUI"))

function Form_GuidePicturre:SetInitParam(param)
end

function Form_GuidePicturre:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuidePicturre:OnActive()
  self.lockTime = CS.UnityEngine.Time.realtimeSinceStartup + 1
  self.tipsId = tonumber(self.m_csui.m_param)
  self:InitView()
end

function Form_GuidePicturre:OnInactive()
  for i = 1, #self.pageItems do
    CS.UnityEngine.GameObject.Destroy(self.pageItems[i])
  end
  self.pageItems = nil
end

function Form_GuidePicturre:OnUpdate(dt)
end

function Form_GuidePicturre:OnDestroy()
end

function Form_GuidePicturre:InitView()
  self.tipConfDatas = {}
  self.totalPage = 0
  local datas = CS.CData_TutorialTips.GetInstance():GetAll()
  for k, v in pairs(datas) do
    for k2, v2 in pairs(v) do
      if v2.m_TutorialTipsID == self.tipsId then
        self.tipConfDatas[v2.m_Page] = v2
        self.totalPage = self.totalPage + 1
      end
    end
  end
  self.currentPage = 1
  self:UpdateItemView()
end

function Form_GuidePicturre:UpdateItemView()
  local confData = self.tipConfDatas[self.currentPage]
  self.m_txt_title_Text.text = confData.m_mTitle
  self.m_pnl_1:SetActive(false)
  self.m_pnl_2:SetActive(false)
  self.m_pnl_3:SetActive(false)
  if confData.m_Template == 1 then
    self.m_pnl_1:SetActive(true)
    self.m_txt_desc_1_1_Text.text = confData.m_mText1
    if confData.m_MultiLanguagePic1 > 0 then
      self.m_img_1_1_Image.gameObject:SetActive(true)
      CS.UI.UILuaHelper.SetAtlasSprite_MultiLan(self.m_img_1_1_Image, confData.m_MultiLanguagePic1)
    else
      self.m_img_1_1_Image.gameObject:SetActive(false)
    end
  elseif confData.m_Template == 2 then
    self.m_pnl_2:SetActive(true)
    self.m_txt_desc_2_1_Text.text = confData.m_mText1
    self.m_txt_desc_2_2_Text.text = confData.m_mText2
    if confData.m_MultiLanguagePic1 > 0 then
      self.m_img_2_1_Image.gameObject:SetActive(true)
      CS.UI.UILuaHelper.SetAtlasSprite_MultiLan(self.m_img_2_1_Image, confData.m_MultiLanguagePic1)
    else
      self.m_img_2_1_Image.gameObject:SetActive(false)
    end
    if 0 < confData.m_MultiLanguagePic2 then
      self.m_img_2_2_Image.gameObject:SetActive(true)
      CS.UI.UILuaHelper.SetAtlasSprite_MultiLan(self.m_img_2_2_Image, confData.m_MultiLanguagePic2)
    else
      self.m_img_2_2_Image.gameObject:SetActive(false)
    end
  elseif confData.m_Template == 3 then
    self.m_pnl_3:SetActive(true)
    self.m_txt_desc_3_1_Text.text = confData.m_mText1
    self.m_txt_desc_3_2_Text.text = confData.m_mText2
    self.m_txt_desc_3_3_Text.text = confData.m_mText3
    if confData.m_MultiLanguagePic1 > 0 then
      self.m_img_3_1_Image.gameObject:SetActive(true)
      CS.UI.UILuaHelper.SetAtlasSprite_MultiLan(self.m_img_3_1_Image, confData.m_MultiLanguagePic1)
    else
      self.m_img_3_1_Image.gameObject:SetActive(false)
    end
    if 0 < confData.m_MultiLanguagePic2 then
      self.m_img_3_2_Image.gameObject:SetActive(true)
      CS.UI.UILuaHelper.SetAtlasSprite_MultiLan(self.m_img_3_2_Image, confData.m_MultiLanguagePic2)
    else
      self.m_img_3_2_Image.gameObject:SetActive(false)
    end
    if 0 < confData.m_MultiLanguagePic3 then
      self.m_img_3_3_Image.gameObject:SetActive(true)
      CS.UI.UILuaHelper.SetAtlasSprite_MultiLan(self.m_img_3_3_Image, confData.m_MultiLanguagePic3)
    else
      self.m_img_3_3_Image.gameObject:SetActive(false)
    end
  end
  if self.pageItems == nil then
    self.pageItems = {}
    for i = 1, self.totalPage do
      local item = CS.UnityEngine.GameObject.Instantiate(self.m_page_item, self.m_pnl_page.transform)
      item:SetActive(true)
      table.insert(self.pageItems, item)
    end
  end
  for i = 1, #self.pageItems do
    local c_img_selected = self.pageItems[i].transform:Find("c_img_selected")
    local c_img_normal = self.pageItems[i].transform:Find("c_img_normal")
    c_img_selected.gameObject:SetActive(i == self.currentPage)
    c_img_normal.gameObject:SetActive(i ~= self.currentPage)
  end
  self.m_bttn_left:SetActive(1 < self.totalPage and self.currentPage > 1)
  self.m_bttn_right:SetActive(1 < self.totalPage and self.currentPage < self.totalPage)
end

function Form_GuidePicturre:OnBtnmaskClicked()
  if CS.UnityEngine.Time.realtimeSinceStartup < self.lockTime then
    return
  end
  self:CloseForm()
end

function Form_GuidePicturre:OnBtnreturnClicked()
  self:OnBtnmaskClicked()
end

function Form_GuidePicturre:OnBttnleftClicked()
  self.currentPage = self.currentPage - 1
  if self.currentPage < 1 then
    self.currentPage = 1
  end
  self:UpdateItemView()
end

function Form_GuidePicturre:OnBttnrightClicked()
  self.currentPage = self.currentPage + 1
  if self.currentPage > self.totalPage then
    self.currentPage = self.totalPage
  end
  self:UpdateItemView()
end

function Form_GuidePicturre:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuidePicturre", Form_GuidePicturre)
return Form_GuidePicturre
