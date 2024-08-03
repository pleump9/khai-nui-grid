//+------------------------------------------------------------------+
//|                                                    PleumGrid.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// กำหนดตัวแปรสำหรับราคาน้อยสุดและมากสุด
input double MinPrice = 1.1000;  // ราคาน้อยสุดที่กำหนด
input double MaxPrice = 1.2000;  // ราคามากสุดที่กำหนด
input double LotSize = 0.1;      // ขนาดล็อตของออเดอร์
input int Slippage = 3;          // ค่า Slippage ที่ยอมรับได้
input int MagicNumber = 12345;   // Magic Number สำหรับออเดอร์
input double TP_Distance = 50;   // ระยะ Take Profit (จุด)
input double Grid_Distance = 20; // ระยะ Grid (จุด) สำหรับเปิดออเดอร์เพิ่ม

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double currentPrice = MarketInfo(Symbol(), MODE_BID); // ราคาปัจจุบัน

// ตรวจสอบว่าราคาปัจจุบันอยู่ในช่วงที่กำหนด
   if(currentPrice >= MinPrice && currentPrice <= MaxPrice)
     {
      // ตรวจสอบว่ามีออเดอร์ Buy ที่เปิดอยู่โดย EA นี้หรือไม่
      bool buyExists = false;
      double minOpenPrice = DBL_MAX; // กำหนดค่าเริ่มต้นเป็นค่ามากที่สุดที่เป็นไปได้

      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber)
           {
            buyExists = true;
            if(OrderOpenPrice() < minOpenPrice)
              {
               minOpenPrice = OrderOpenPrice(); // หา openPrice ที่ต่ำที่สุด
              }
           }
        }

      // ถ้าไม่มีออเดอร์ Buy อยู่ จะเปิดออเดอร์ Buy ใหม่
      if(!buyExists)
        {
         double tpPrice = currentPrice + TP_Distance * Point;
         int ticket = OrderSend(Symbol(), OP_BUY, LotSize, currentPrice, Slippage, 0, tpPrice, "Buy order", MagicNumber, 0, Blue);
         if(ticket < 0)
           {
            Print("Error opening order: ", GetLastError());
           }
         else
           {
            Print("Order opened successfully: ", ticket);
           }
        }
      else
        {
         // ตรวจสอบเพื่อเปิดออเดอร์เพิ่มในระยะ Grid
         double gridPrice = minOpenPrice - Grid_Distance * Point;

         if(currentPrice <= gridPrice)
           {
            double tpPrice = currentPrice + TP_Distance * Point;
            int ticket = OrderSend(Symbol(), OP_BUY, LotSize, currentPrice, Slippage, 0, tpPrice, "Grid Buy order", MagicNumber, 0, Blue);
            if(ticket < 0)
              {
               Print("Error opening grid order: ", GetLastError());
              }
            else
              {
               Print("Grid order opened successfully: ", ticket);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
