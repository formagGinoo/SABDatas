local Form_TripartitePayment = class("Form_TripartitePayment", require("UI/UIFrames/Form_TripartitePaymentUI"))

function Form_TripartitePayment:SetInitParam(param)
end

function Form_TripartitePayment:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_grid = require("UI/Common/UIInfinityGrid").new(self.m_scrollview_tripartitepayment_InfinityGrid, "StoreMsdkPc/UIStoreMsdkPcItem", initGridData)
end

function Form_TripartitePayment:OnActive()
  self.super.OnActive(self)
  self.m_skuInfo = self.m_csui.m_param.skuInfo
  self.m_detailInfo = self.m_csui.m_param.detailInfo
  self.m_priceInfo = self.m_csui.m_param.priceInfo
  self.m_callback = self.m_csui.m_param.callback
  self:RefreshView()
end

function Form_TripartitePayment:OnInactive()
  self.super.OnInactive(self)
end

function Form_TripartitePayment:RefreshView()
  local data = {}
  local channelList = self.m_detailInfo.pay_channel_sub_list
  for i = 0, channelList.Count - 1 do
    data[#data + 1] = {
      channelInfo = channelList[i],
      skuInfo = self.m_skuInfo,
      priceInfo = self.m_priceInfo
    }
  end
  self.m_grid:ShowItemList(data)
  self.m_scrollview_tripartitepayment:GetComponent("ScrollRect").verticalNormalizedPosition = 1
end

function Form_TripartitePayment:OnItemClk(data)
  if self.m_callback then
    self.m_callback(false, data)
  end
  self:CloseForm()
end

function Form_TripartitePayment:OnBtnreturnClicked()
  if self.m_callback then
    self.m_callback(true)
  end
  self:CloseForm()
end

function Form_TripartitePayment:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_TripartitePayment:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_TripartitePayment", Form_TripartitePayment)
return Form_TripartitePayment
