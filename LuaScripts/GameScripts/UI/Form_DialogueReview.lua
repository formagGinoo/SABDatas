local Form_DialogueReview = class("Form_DialogueReview", require("UI/UIFrames/Form_DialogueReviewUI"))

function Form_DialogueReview:SetInitParam(param)
end

function Form_DialogueReview:GetRootTransformType()
  return UIRootTransformType.Story
end

function Form_DialogueReview:AfterInit()
  self.super.AfterInit(self)
  self.m_btn_home:SetActive(false)
  self.m_btn_symbol:SetActive(false)
  self.playingId = -1
end

function Form_DialogueReview:OnActive()
  self.super.OnActive(self)
  local review = self.m_csui.m_param
  self.onClose = review.onClose
  local count = #review.data
  local root = self.m_Content.transform
  self:UpdateChildCount(root, count)
  for i = 1, count do
    local data = review.data[i]
    local child = root:GetChild(i - 1)
    self:FillReviewElement(i, data, child)
  end
  local scrollRect = self.m_scrollview_story:GetComponent("ScrollRect")
  scrollRect.verticalNormalizedPosition = 0
end

function Form_DialogueReview:FillReviewElement(index, reviewData, transform)
  local selectRoot = transform:Find("pnl_selectrcord")
  local noralmalRoot = transform:Find("pnl_role")
  selectRoot.gameObject:SetActive(reviewData.Type == 1)
  noralmalRoot.gameObject:SetActive(reviewData.Type == 0)
  if reviewData.Type == 0 then
    noralmalRoot:Find("c_txt_rolename"):GetComponent("TMPPro").text = reviewData.RoleName
    noralmalRoot:Find("c_txt_roletalk"):GetComponent("TMPPro").text = reviewData.DialogueContent
    local btnTrans = noralmalRoot:Find("c_txt_rolename/img_talkrole")
    if not string.IsNullOrEmpty(reviewData.Voice) then
      btnTrans.gameObject:SetActive(true)
      local btn = btnTrans:GetComponent(T_Button)
      btn.onClick:RemoveAllListeners()
      btn.onClick:AddListener(function()
        self:OnVoiceClick(index)
      end)
    else
      btnTrans.gameObject:SetActive(false)
    end
  else
    local listRoot = selectRoot:Find("pnl_choose")
    self:UpdateChildCount(listRoot, #reviewData.Options)
    local selectedIdx = reviewData.SelectedIndex
    selectedIdx = selectedIdx or 0
    for i, v in ipairs(reviewData.Options) do
      local child = listRoot:GetChild(i - 1)
      local txt_choose_Text = child:Find("c_txt_choose"):GetComponent("TMPPro")
      txt_choose_Text.text = v
      local txt_choosesel_Text = child:Find("pnl_choosesel/c_txt_choosesel"):GetComponent("TMPPro")
      txt_choosesel_Text.text = v
      local obj_sel = child:Find("pnl_choosesel").gameObject
      obj_sel:SetActive(i == selectedIdx)
    end
  end
end

function Form_DialogueReview:OnVoiceClick(index)
  local review = self.m_csui.m_param
  local data = review.data[index]
  if data.Type == 0 then
    CS.UI.UILuaHelper.StartPlaySFX(data.Voice, nil, handler(self, self.OnPlaySFXStart), handler(self, self.OnPlaySFXFinish))
  end
end

function Form_DialogueReview:StopSFX()
  if self.playingId > 0 then
    CS.UI.UILuaHelper.StopPlaySFX(self.playingId)
    self.playingId = -1
  end
end

function Form_DialogueReview:OnPlaySFXStart(playingId)
  self.playingId = playingId
end

function Form_DialogueReview:OnPlaySFXFinish(playingId)
  if self.playingId == playingId then
    self.playingId = -1
  end
end

function Form_DialogueReview:UpdateChildCount(root, count)
  local childCount = root.childCount
  while count > childCount do
    local first = root:GetChild(0)
    instantiateToParentInWorldSpace(first, root, false)
    childCount = childCount + 1
  end
  for i = 1, childCount do
    local child = root:GetChild(i - 1)
    child.gameObject:SetActive(count >= i)
  end
end

function Form_DialogueReview:OnInactive()
  self.super.OnInactive(self)
  self:StopSFX()
end

function Form_DialogueReview:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_DialogueReview:OnBtnbackClicked()
  self:CloseForm()
  if self.onClose then
    self.onClose()
    self.onClose = nil
  end
end

function Form_DialogueReview:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_DialogueReview", Form_DialogueReview)
return Form_DialogueReview
