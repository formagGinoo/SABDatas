local BaseObject = require("Base/BaseObject")
local StoreBase = class("StoreBase", BaseObject)
StoreType = {
  Base = 0,
  Editor = 1,
  MSDK = 2,
  QSDK = 3,
  MSDKPc = 4
}

function StoreBase:OnCreate()
end

function StoreBase:OnAfterFreshData()
end

function StoreBase:QueryProductsDetail(callback)
  log.info("--- StoreBase:QueryProductsDetail ---")
end

function StoreBase:ParseTable()
  local StoreCfgIns = ConfigManager:GetConfigInsByName("Store")
  self.m_mProductList = {}
  local all_store_cfg = StoreCfgIns:GetAll()
  local productIds = {}
  for key, v in pairs(all_store_cfg) do
    self.m_mProductList[v.m_ProductID] = v
    productIds[#productIds + 1] = v.m_ProductID
  end
  self.m_sProductList = table.concat(productIds, ",")
end

function StoreBase:InitStore(callback)
  if callback then
    callback(true)
  end
end

function StoreBase:GetProductPrice(productId, withCurrency)
  local product = self.m_mProductList[productId]
  if product then
    local price = product.m_Price
    if ChannelManager:IsChinaChannel() then
      price = product.m_CnPrice
    end
    price = string.format("%.2f", price * 0.01)
    if withCurrency then
      if ChannelManager:IsChinaChannel() then
        return "¥" .. price
      else
        return price
      end
    else
      return price
    end
  end
  return nil
end

function StoreBase:GetProductWelfarePrice(productId)
  local product = self.m_mProductList[productId]
  if product then
    local welfarePrice = product.m_WelfarePrice
    if ChannelManager:IsChinaChannel() then
      welfarePrice = product.m_CnWelfarePrice
    end
    return welfarePrice
  end
  return nil
end

function StoreBase:RealPay(productId, productSubId, OnSdkCallback)
end

function StoreBase:GetStoreType()
  return StoreType.Base
end

function StoreBase:GetIAPReceiptType()
  return MTTDProto.IAPReceiptType_MSDK
end

function StoreBase:Report(productId)
  local iTotalRecharge = RoleManager:GetTotalRecharge()
  if iTotalRecharge and iTotalRecharge == 0 then
    ReportManager:ReportTrackAttributionEvent("first_recharge", {})
  end
  local productCfg = self.m_mProductList[productId]
  if productCfg then
    ReportManager:ReportTrackAttributionEvent("revenue", {
      revenue = productCfg.m_Price / 100,
      currency = "USD"
    })
    ReportManager:ReportTrackAttributionEvent("recharge", {})
  end
end

function StoreBase:EnableCheckValid()
  return true
end

return StoreBase
