local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Item_GetList_CS = 10201
CmdId_Item_GetList_SC = 10202
CmdId_Item_Sell_CS = 10203
CmdId_Item_Sell_SC = 10204
CmdId_Item_Use_CS = 10205
CmdId_Item_Use_SC = 10206
CmdId_Item_SellBatch_CS = 10207
CmdId_Item_SellBatch_SC = 10208
CmdId_Item_Buy_CS = 10213
CmdId_Item_Buy_SC = 10214
ItemIdSeg_SpecialItem_Min = 1
ItemIdSeg_SpecialItem_Max = 999
ItemIdSeg_Resource_Min = 1001
ItemIdSeg_Resource_Max = 9999
ItemIdSeg_HeroCard_Min = 20001
ItemIdSeg_HeroCard_Max = 29999
ItemIdSeg_Treasure_Min = 30001
ItemIdSeg_Treasure_Max = 39999
ItemIdSeg_Afk_Min = 40001
ItemIdSeg_Afk_Max = 49999
ItemIdSeg_Fragment_Min = 50001
ItemIdSeg_Fragment_Max = 59999
ItemIdSeg_Legacy_Min = 90001
ItemIdSeg_Legacy_Max = 99999
ItemIdSeg_Equip_Min = 600001
ItemIdSeg_Equip_Max = 699999
ItemIdSeg_Break_Min = 700001
ItemIdSeg_Break_Max = 799999
ItemIdSeg_Attract_Min = 800001
ItemIdSeg_Attract_Max = 899999
ItemIdSeg_LegacyItem_Min = 900001
ItemIdSeg_LegacyItem_Max = 900999
ItemIdSeg_Circulation_Min = 901001
ItemIdSeg_Circulation_Max = 901999
ItemIdSeg_StoreExchange_Min = 110001
ItemIdSeg_StoreExchange_Max = 110999
ItemIdSeg_Head_Min = 1300001
ItemIdSeg_Head_Max = 1399999
ItemIdSeg_HeadFrame_Min = 1400001
ItemIdSeg_HeadFrame_Max = 1499999
ItemIdSeg_ShowBackground_Min = 1500001
ItemIdSeg_ShowBackground_Max = 1599999
ItemIdSeg_MainBackground_Min = 1600001
ItemIdSeg_MainBackground_Max = 1699999
ItemIdSeg_Fashion_Min = 6000001
ItemIdSeg_Fashion_Max = 6999999
ItemType_SpecialItem = 1
ItemType_Resource = 10
ItemType_HeroCard = 20
ItemType_Treasure = 30
ItemType_Afk = 40
ItemType_Fragment = 50
ItemType_Equip = 60
ItemType_HeroBreak = 70
ItemType_Attract = 80
ItemType_Legacy = 90
ItemType_Fashion = 100
ItemType_StoreExchange = 110
ItemType_Head = 130
ItemType_HeadFrame = 140
ItemType_ShowBackground = 150
ItemType_MainBackground = 160
ItemType_ActVirtualItem = 200
ItemSubType_SmallMonthCard = 1
ItemSubType_BigMonthCard = 2
ItemSubType_BattlePass = 3
ItemSubType_Default = 10
ItemSubType_EquipExp = 11
ItemSubType_Treasure = 30
ItemSubType_Selected = 31
ItemSubType_Random = 32
ItemSubType_Afk = 40
ItemSubType_Frag = 50
ItemSubType_FragRandom = 51
ItemSubType_HeroBreak = 70
ItemSubType_Legacy = 90
ItemSubType_Fashion = 100
ItemSubType_VirtualItemResource = 9901
ItemSubType_VirtualItemEquip = 9902
SpecialItem_Exp = 1
SpecialItem_Welfare = 2
SpecialItem_ShowDiamond = 99
SpecialItem_Diamond = 100
SpecialItem_FreeDiamond = 101
SpecialItem_NegDiamond = 102
SpecialItem_StatueExp = 998
SpecialItem_Coin = 999
SpecialItem_EquipExp_R = 1101
SpecialItem_EquipExp_SR = 1102
SpecialItem_Energy = 4
SpecialItem_VipExp = 6
SpecialItem_FreeVipExp = 10
ItemQuality_N = 1
ItemQuality_R = 2
ItemQuality_SR = 3
ItemQuality_SSR = 4
ItemQuality_UR = 5
AttractGiftType_Common = 0
AttractGiftType_Camp1 = 1
AttractGiftType_Camp2 = 2
AttractGiftType_Camp3 = 3
AttractGiftType_Camp4 = 4
AttractGiftType_Camp5 = 5
AttractGiftType_Exclusive = 6
Cmd_Item_GetList_CS = sdp.SdpStruct("Cmd_Item_GetList_CS")
Cmd_Item_GetList_CS.Definition = {}
Cmd_Item_GetList_SC = sdp.SdpStruct("Cmd_Item_GetList_SC")
Cmd_Item_GetList_SC.Definition = {
  "vItemList",
  "iBagLimit",
  "mUniqueItem",
  vItemList = {
    0,
    0,
    sdp.SdpVector(CmdItemData),
    nil
  },
  iBagLimit = {
    1,
    0,
    8,
    0
  },
  mUniqueItem = {
    2,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Item_Sell_CS = sdp.SdpStruct("Cmd_Item_Sell_CS")
Cmd_Item_Sell_CS.Definition = {
  "iItemUid",
  "iNum",
  iItemUid = {
    0,
    0,
    10,
    "0"
  },
  iNum = {
    1,
    0,
    8,
    0
  }
}
Cmd_Item_Sell_SC = sdp.SdpStruct("Cmd_Item_Sell_SC")
Cmd_Item_Sell_SC.Definition = {
  "vItem",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
ItemUseData = sdp.SdpStruct("ItemUseData")
ItemUseData.Definition = {
  "mIndexIdNum",
  mIndexIdNum = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Item_Use_CS = sdp.SdpStruct("Cmd_Item_Use_CS")
Cmd_Item_Use_CS.Definition = {
  "iItemBaseId",
  "iNum",
  "stItemUseData",
  iItemBaseId = {
    0,
    0,
    8,
    0
  },
  iNum = {
    1,
    0,
    8,
    0
  },
  stItemUseData = {
    2,
    0,
    ItemUseData,
    nil
  }
}
Cmd_Item_Use_SC = sdp.SdpStruct("Cmd_Item_Use_SC")
Cmd_Item_Use_SC.Definition = {
  "vItem",
  "mChangeReward",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  mChangeReward = {
    1,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  }
}
Cmd_Item_SellBatch_CS = sdp.SdpStruct("Cmd_Item_SellBatch_CS")
Cmd_Item_SellBatch_CS.Definition = {
  "mItemBatch",
  mItemBatch = {
    0,
    0,
    sdp.SdpMap(10, 8),
    nil
  }
}
Cmd_Item_SellBatch_SC = sdp.SdpStruct("Cmd_Item_SellBatch_SC")
Cmd_Item_SellBatch_SC.Definition = {
  "vItem",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Item_Buy_CS = sdp.SdpStruct("Cmd_Item_Buy_CS")
Cmd_Item_Buy_CS.Definition = {
  "iBaseId",
  "iNum",
  iBaseId = {
    0,
    0,
    8,
    0
  },
  iNum = {
    1,
    0,
    8,
    0
  }
}
Cmd_Item_Buy_SC = sdp.SdpStruct("Cmd_Item_Buy_SC")
Cmd_Item_Buy_SC.Definition = {}
