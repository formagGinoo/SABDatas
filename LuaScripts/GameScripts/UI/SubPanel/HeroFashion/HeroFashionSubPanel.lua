local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroFashionSubPanel = class("HeroFashionSubPanel", UISubPanelBase)
local MaxShowFashionNum = 3
local InAnimStr = "skinvoice_in"
local DragLimitNum = 50
local MidFreshItemSec = 0.3
local LeftAnimStr = "skinitem_right"
local RightAnimStr = "skinitem_left"

function HeroFashionSubPanel:OnInit()
  self.m_HeroFashion = HeroManager:GetHeroFashion()
  self.m_chooseChangeBackFun = self.m_initData and self.m_initData.backFun or nil
  self.m_heroData = nil
  self.m_heroFashionInfoList = nil
  self.m_curChooseIndex = nil
  self.m_curShowFashion = nil
  self.m_heroCfg = nil
  self.m_allSkinNodes = {}
  self:InitFashionItems()
  self:AddEventListeners()
  self.m_uiCamera = self.m_initData and self.m_initData.uiCamera or nil
  self.m_btn_list_BtnEx = self.m_btn_list_act:GetComponent("ButtonExtensions")
  if self.m_btn_list_BtnEx then
    self.m_btn_list_BtnEx.Clicked = handler(self, self.OnExClick)
    self.m_btn_list_BtnEx.BeginDrag = handler(self, self.OnBeginDrag)
    self.m_btn_list_BtnEx.EndDrag = handler(self, self.OnEndDrag)
  end
  self.m_rect_clickL_Trans = self.m_rect_clickL.transform
  self.m_rect_clickR_Trans = self.m_rect_clickR.transform
end

function HeroFashionSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_SetHeroFashionNewFlag", handler(self, self.OnSetHeroNewFlag))
  self:addEventListener("eGameEvent_Hero_GetNewFashion", handler(self, self.OnNewFashion))
  self:addEventListener("eGameEvent_Hero_SetFashion", handler(self, self.OnSetFashion))
end

function HeroFashionSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HeroFashionSubPanel:OnSetHeroNewFlag(param)
  if param.fashionID == self.m_curShowFashion.m_FashionID then
    self:FreshCurChooseIndexStatus()
  end
end

function HeroFashionSubPanel:OnNewFashion(param)
  local fashionID = self:GetSetServerFashionIDByCfg(self.m_curShowFashion)
  if param.fashionID == fashionID then
    self:FreshCurChooseIndexStatus()
    self:FreshDownStatusShow(self.m_curShowFashion)
  end
end

function HeroFashionSubPanel:OnSetFashion(param)
  if not self.m_heroData then
    return
  end
  if not self.m_curShowFashion then
    return
  end
  local fashionID = self:GetSetServerFashionIDByCfg(self.m_curShowFashion)
  if param.heroID == self.m_heroData.serverData.iHeroId and param.fashionID == fashionID then
    self:FreshSkinItems()
    self:FreshDownStatusShow(self.m_curShowFashion)
  end
end

function HeroFashionSubPanel:GetSetServerFashionIDByCfg(fashionInfoCfg)
  if not fashionInfoCfg then
    return
  end
  if fashionInfoCfg.m_Type == 0 then
    return 0
  else
    return fashionInfoCfg.m_FashionID
  end
end

function HeroFashionSubPanel:OnFreshData()
  self.m_heroData = self.m_panelData.heroData
  self.m_heroCfg = self.m_panelData.heroCfg
  self.m_heroFashionInfoList = self.m_panelData.allFashionList
  local chooseIndex = self.m_panelData.chooseIndex
  self.m_curShowFashion = self.m_heroFashionInfoList[chooseIndex]
  self.m_curChooseIndex = chooseIndex
  self:FreshFashionShow()
end

function HeroFashionSubPanel:FreshFashionShow()
  if not self.m_curChooseIndex then
    return
  end
  self:FreshSkinName()
  self:FreshSkinItems()
  self:FreshDownStatusShow(self.m_curShowFashion)
  self:CheckReqSetNewFlag()
end

function HeroFashionSubPanel:ChangeChooseIndex(chooseIndex)
  if not self.m_heroFashionInfoList then
    return
  end
  self.m_curChooseIndex = chooseIndex
  self.m_curShowFashion = self.m_heroFashionInfoList[chooseIndex]
  self:FreshFashionShow()
end

function HeroFashionSubPanel:OnActivePanel()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, InAnimStr)
end

function HeroFashionSubPanel:OnHidePanel()
end

function HeroFashionSubPanel:OnDestroy()
  self:RemoveAllEventListeners()
  if self.m_midChangeChooseTimer then
    TimeService:KillTimer(self.m_midChangeChooseTimer)
    self.m_midChangeChooseTimer = nil
  end
  if self.m_changeChooseTimer then
    TimeService:KillTimer(self.m_changeChooseTimer)
    self.m_changeChooseTimer = nil
  end
  HeroFashionSubPanel.super.OnDestroy(self)
end

function HeroFashionSubPanel:IsFashionCanBuy(fashionID)
  if not fashionID then
    return
  end
  local activityTab = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not activityTab then
    return
  end
  local isShowStore = activityTab:CheckIsShowFashionStore()
  if isShowStore ~= true then
    return
  end
  local goodsData = activityTab:GetFashionStoreCommodityInfoById(fashionID)
  if not goodsData then
    return
  end
  local goodsPriceStr = IAPManager:GetProductPrice(goodsData.sProductId, true)
  return true, goodsPriceStr
end

function HeroFashionSubPanel:GetCurFashionPayData()
  if not self.m_curShowFashion then
    return
  end
  local fashionID = self.m_curShowFashion.m_FashionID
  if not fashionID then
    return
  end
  local activityTab = ActivityManager:GetActivityByType(MTTD.ActivityType_PayStore)
  if not activityTab then
    return
  end
  local isShowStore = activityTab:CheckIsShowFashionStore()
  if isShowStore ~= true then
    return
  end
  local storeID = activityTab:GetActivityFashionStoreID()
  if storeID == nil or storeID == 0 then
    return
  end
  local goodsData = activityTab:GetFashionStoreCommodityInfoById(fashionID)
  if not goodsData then
    return
  end
  local ProductInfo = {
    StoreID = storeID,
    GoodsID = goodsData.iGoodsId,
    productId = goodsData.sProductId,
    productSubId = goodsData.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActPayStore,
    productName = self.m_curShowFashion.m_mFashionName,
    productDesc = activityTab:getLangText(goodsData.sGoodsDesc),
    iActivityId = activityTab:getID()
  }
  return ProductInfo
end

function HeroFashionSubPanel:InitFashionItems()
  for i = 1, MaxShowFashionNum do
    local skinRootTrans = self["m_pnl_skin" .. i].transform
    local hero_icon = skinRootTrans:Find("img_bg_skinmask/c_hero_icon"):GetComponent(T_Image)
    local img_new = skinRootTrans:Find("c_img_new")
    local img_lock = skinRootTrans:Find("c_img_lock")
    local img_equip = skinRootTrans:Find("c_img_equip")
    local tempNode = {
      rootTrans = skinRootTrans,
      hero_icon = hero_icon,
      img_new = img_new,
      img_lock = img_lock,
      img_equip = img_equip,
      heroSpineObj = nil
    }
    self.m_allSkinNodes[#self.m_allSkinNodes + 1] = tempNode
  end
end

function HeroFashionSubPanel:FreshSkinName()
  if not self.m_curShowFashion then
    return
  end
  self.m_txt_skinname_Text.text = self.m_curShowFashion.m_mFashionTag
end

function HeroFashionSubPanel:FreshDownStatusShow(fashionInfoCfg)
  if not fashionInfoCfg then
    return
  end
  local isHaveHero = self.m_heroData ~= nil
  local isCurEquip = self.m_HeroFashion:IsFashionEquip(fashionInfoCfg.m_FashionID, self.m_heroData)
  local isShowEquipText = isHaveHero and isCurEquip
  UILuaHelper.SetActive(self.m_z_txt_skinequip, isShowEquipText)
  local isHaveFashion = self.m_HeroFashion:IsFashionHave(fashionInfoCfg.m_FashionID)
  local isShowEquipBtn = isHaveHero and isHaveFashion and not isCurEquip
  UILuaHelper.SetActive(self.m_btn_equip, isShowEquipBtn)
  local isShowHaveSkinNoHero = not isHaveHero and isHaveFashion
  UILuaHelper.SetActive(self.m_z_txt_haveskin, isShowHaveSkinNoHero)
  local isGetBuyMoney = fashionInfoCfg.m_GetType == 1
  local isCanBuy = false
  local priceStr = ""
  if isGetBuyMoney then
    isCanBuy, priceStr = self:IsFashionCanBuy(fashionInfoCfg.m_FashionID)
  end
  local isShowBuyBtn = isGetBuyMoney and not isHaveFashion and isCanBuy
  if isShowBuyBtn then
    self.m_txt_buy_Text.text = priceStr
  end
  UILuaHelper.SetActive(self.m_btn_buy, isShowBuyBtn)
  local isShowBuyActNoOpenTxt = isGetBuyMoney and not isHaveFashion and not isCanBuy
  UILuaHelper.SetActive(self.m_z_txt_skinacquire, isShowBuyActNoOpenTxt)
  local isGetInOtherSys = fashionInfoCfg.m_GetType == 2 and fashionInfoCfg.m_JumpID ~= 0
  local isShowBtnAcquireBtn = isGetInOtherSys and not isHaveFashion
  UILuaHelper.SetActive(self.m_btn_acquire, isShowBtnAcquireBtn)
end

function HeroFashionSubPanel:CheckReqSetNewFlag()
  if not self.m_curShowFashion then
    return
  end
  if not self.m_heroData then
    return
  end
  local isNew = self.m_HeroFashion:IsFashionHaveNewFlag(self.m_curShowFashion.m_FashionID)
  if isNew then
    self.m_HeroFashion:SetFashionHaveNewFlag(self.m_curShowFashion.m_FashionID, 1)
  end
end

function HeroFashionSubPanel:FreshSkinItems()
  if not self.m_curShowFashion then
    return
  end
  for i = 1, MaxShowFashionNum do
    local midNum = math.floor(MaxShowFashionNum / 2) + 1
    local tempDeltaIndex = i - midNum
    local showIndex = self.m_curChooseIndex + tempDeltaIndex
    local fashionInfoCfg = self.m_heroFashionInfoList[showIndex]
    local skinItemNode = self.m_allSkinNodes[i]
    UILuaHelper.SetActive(skinItemNode.rootTrans, fashionInfoCfg ~= nil)
    if fashionInfoCfg then
      UILuaHelper.SetAtlasSprite(skinItemNode.hero_icon, fashionInfoCfg.m_FashionPic)
      self:FreshSkinNodeStatus(skinItemNode, fashionInfoCfg)
    end
  end
end

function HeroFashionSubPanel:FreshTempSkinNode(isLeft)
  local skinNodeIndex = isLeft and MaxShowFashionNum or 1
  local skinItemNode = self.m_allSkinNodes[skinNodeIndex]
  if not skinItemNode then
    return
  end
  local skinInfoIndex = isLeft and self.m_curChooseIndex - 2 or self.m_curChooseIndex + 2
  local fashionInfoCfg = self.m_heroFashionInfoList[skinInfoIndex]
  UILuaHelper.SetActive(skinItemNode.rootTrans, fashionInfoCfg ~= nil)
  if fashionInfoCfg then
    UILuaHelper.SetAtlasSprite(skinItemNode.hero_icon, fashionInfoCfg.m_FashionPic)
    self:FreshSkinNodeStatus(skinItemNode, fashionInfoCfg)
  end
  local buttonStatusIndex = isLeft and self.m_curChooseIndex - 1 or self.m_curChooseIndex + 1
  local tempFashionInfoCfg = self.m_heroFashionInfoList[buttonStatusIndex]
  self:FreshDownStatusShow(tempFashionInfoCfg)
end

function HeroFashionSubPanel:FreshSkinNodeStatus(skinItemNode, fashionInfoCfg)
  local isHaveHero = self.m_heroData ~= nil
  local isNew = self.m_HeroFashion:IsFashionHaveNewFlag(fashionInfoCfg.m_FashionID)
  UILuaHelper.SetActive(skinItemNode.img_new, isNew and isHaveHero)
  local isHave = self.m_HeroFashion:IsFashionHave(fashionInfoCfg.m_FashionID)
  UILuaHelper.SetActive(skinItemNode.img_lock, not isHave)
  local isEquip = self.m_HeroFashion:IsFashionEquip(fashionInfoCfg.m_FashionID, self.m_heroData)
  UILuaHelper.SetActive(skinItemNode.img_equip, isEquip and isHaveHero)
end

function HeroFashionSubPanel:FreshCurChooseIndexStatus()
  if not self.m_curChooseIndex then
    return
  end
  local midNum = math.floor(MaxShowFashionNum / 2) + 1
  local itemNode = self.m_allSkinNodes[midNum]
  local fashionInfoCfg = self.m_curShowFashion
  self:FreshSkinNodeStatus(itemNode, fashionInfoCfg)
end

function HeroFashionSubPanel:CheckUnLock()
  if self.m_lockerID and UILockIns:IsValidLocker(self.m_lockerID) then
    UILockIns:Unlock(self.m_lockerID)
  end
  self.m_lockerID = nil
end

function HeroFashionSubPanel:OnLeftClicked()
  if not self.m_curChooseIndex then
    return
  end
  if self.m_curChooseIndex <= 1 then
    return
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_conten, LeftAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_pnl_conten, LeftAnimStr)
  if self.m_midChangeChooseTimer then
    TimeService:KillTimer(self.m_midChangeChooseTimer)
    self.m_midChangeChooseTimer = nil
  end
  self.m_midChangeChooseTimer = TimeService:SetTimer(animLen - MidFreshItemSec, 1, function()
    self:FreshTempSkinNode(true)
    self.m_midChangeChooseTimer = nil
  end)
  if self.m_changeChooseTimer then
    TimeService:KillTimer(self.m_changeChooseTimer)
    self.m_changeChooseTimer = nil
  end
  self:CheckUnLock()
  self.m_lockerID = UILockIns:Lock(animLen)
  self.m_changeChooseTimer = TimeService:SetTimer(animLen, 1, function()
    self:CheckUnLock()
    UILuaHelper.ResetAnimationByName(self.m_pnl_conten, LeftAnimStr)
    self:ChangeChooseIndex(self.m_curChooseIndex - 1)
    if self.m_chooseChangeBackFun then
      self.m_chooseChangeBackFun(self.m_curChooseIndex)
    end
    self.m_changeChooseTimer = nil
  end)
end

function HeroFashionSubPanel:OnRightClicked()
  if not self.m_curChooseIndex then
    return
  end
  if self.m_curChooseIndex >= #self.m_heroFashionInfoList then
    return
  end
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_conten, RightAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_pnl_conten, RightAnimStr)
  if self.m_midChangeChooseTimer then
    TimeService:KillTimer(self.m_midChangeChooseTimer)
    self.m_midChangeChooseTimer = nil
  end
  self.m_midChangeChooseTimer = TimeService:SetTimer(animLen - MidFreshItemSec, 1, function()
    self:FreshTempSkinNode(false)
    self.m_midChangeChooseTimer = nil
  end)
  if self.m_changeChooseTimer then
    TimeService:KillTimer(self.m_changeChooseTimer)
    self.m_changeChooseTimer = nil
  end
  self:CheckUnLock()
  self.m_lockerID = UILockIns:Lock(animLen)
  self.m_changeChooseTimer = TimeService:SetTimer(animLen, 1, function()
    self:CheckUnLock()
    UILuaHelper.ResetAnimationByName(self.m_pnl_conten, RightAnimStr)
    self:ChangeChooseIndex(self.m_curChooseIndex + 1)
    if self.m_chooseChangeBackFun then
      self.m_chooseChangeBackFun(self.m_curChooseIndex)
    end
    self.m_changeChooseTimer = nil
  end)
end

function HeroFashionSubPanel:OnBtnacquireClicked()
  if not self.m_curShowFashion then
    return
  end
  local jumpID = self.m_curShowFashion.m_JumpID
  if jumpID == 0 then
    return
  end
  if self.m_parentLua then
    self.m_parentLua:CloseForm()
  end
  self:broadcastEvent("eGameEvent_Hero_FashionJump")
  QuickOpenFuncUtil:OpenFunc(jumpID)
end

function HeroFashionSubPanel:OnBtnequipClicked()
  if not self.m_curShowFashion then
    return
  end
  if not self.m_heroData then
    return
  end
  local fashionID = self:GetSetServerFashionIDByCfg(self.m_curShowFashion)
  HeroManager:ReqHeroSetFashion(self.m_heroData.serverData.iHeroId, fashionID)
end

function HeroFashionSubPanel:OnBtnbuyClicked()
  if not self.m_curShowFashion then
    return
  end
  local payData = self:GetCurFashionPayData()
  if not payData then
    return
  end
  IAPManager:BuyProductByStoreType(payData, nil, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
    end
  end)
end

function HeroFashionSubPanel:OnExClick(pointerEventData)
  if not pointerEventData then
    return
  end
  local position = pointerEventData.position
  local posX = position.x
  local posY = position.y
  if UILuaHelper.IsScreenPosInUIRect(self.m_rect_clickL_Trans, posX, posY, self.m_uiCamera) then
    self:OnLeftClicked()
  elseif UILuaHelper.IsScreenPosInUIRect(self.m_rect_clickR_Trans, posX, posY, self.m_uiCamera) then
    self:OnRightClicked()
  end
end

function HeroFashionSubPanel:OnBeginDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
end

function HeroFashionSubPanel:OnEndDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_startDragPos.x
  local absDeltaNum = math.abs(deltaNum)
  if absDeltaNum < DragLimitNum then
    return
  end
  if 0 < deltaNum then
    self:OnLeftClicked()
  else
    self:OnRightClicked()
  end
  self.m_startDragPos = nil
end

function HeroFashionSubPanel:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  return vPackage, vResourceExtra
end

return HeroFashionSubPanel
