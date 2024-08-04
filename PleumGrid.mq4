//+------------------------------------------------------------------+
//|                                                    PleumGrid.mq4 |
//|                              Copyright 2024, The Market Survivor |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, The Market Survivor"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// กำหนดตัวแปรสำหรับฝั่ง Buy
input double MinBuyPrice = 1.1000;    // ราคาน้อยสุดที่กำหนดสำหรับฝั่ง Buy
input double MaxBuyPrice = 1.2000;    // ราคามากสุดที่กำหนดสำหรับฝั่ง Buy
input double BuyLotSize = 0.1;        // ขนาดล็อตของออเดอร์ Buy
input double BuyTP_Distance = 50;     // ระยะ Take Profit (จุด) สำหรับฝั่ง Buy
input double BuyGrid_Distance = 20;   // ระยะ Grid (จุด) สำหรับเปิดออเดอร์ Buy เพิ่ม
input bool EnableBuy = true;          // เปิดหรือปิดการเปิดออเดอร์ Buy

// กำหนดตัวแปรสำหรับฝั่ง Sell
input double MinSellPrice = 1.2000;   // ราคาน้อยสุดที่กำหนดสำหรับฝั่ง Sell
input double MaxSellPrice = 1.3000;   // ราคามากสุดที่กำหนดสำหรับฝั่ง Sell
input double SellLotSize = 0.1;       // ขนาดล็อตของออเดอร์ Sell
input double SellTP_Distance = 50;    // ระยะ Take Profit (จุด) สำหรับฝั่ง Sell
input double SellGrid_Distance = 20;  // ระยะ Grid (จุด) สำหรับเปิดออเดอร์ Sell เพิ่ม
input bool EnableSell = true;         // เปิดหรือปิดการเปิดออเดอร์ Sell

input int Slippage = 3;               // ค่า Slippage ที่ยอมรับได้
input int MagicNumber = 12345;        // Magic Number สำหรับออเดอร์

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

   int buyCount = 0;          // จำนวนไม้ Buy
   double buyProfit = 0;      // ผลรวมกำไร/ขาดทุนของฝั่ง Buy
   int sellCount = 0;         // จำนวนไม้ Sell
   double sellProfit = 0;     // ผลรวมกำไร/ขาดทุนของฝั่ง Sell
   int totalOrders = 0;       // จำนวนออเดอร์ทั้งหมด
   double totalProfit = 0;    // ผลรวมกำไร/ขาดทุนของทุกออเดอร์

// ตรวจสอบทุกออเดอร์เพื่อคำนวณจำนวนและกำไร/ขาดทุน
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber)
           {
            buyCount++;
            buyProfit += OrderProfit();
           }
         else
            if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber)
              {
               sellCount++;
               sellProfit += OrderProfit();
              }

         // คำนวณจำนวนและกำไร/ขาดทุนรวมของทุกออเดอร์
         totalOrders++;
         totalProfit += OrderProfit();
        }
     }

// ฝั่ง Buy
   if(EnableBuy && currentPrice >= MinBuyPrice && currentPrice <= MaxBuyPrice)
     {
      bool buyExists = false;
      double minBuyOpenPrice = DBL_MAX;

      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber)
           {
            buyExists = true;
            if(OrderOpenPrice() < minBuyOpenPrice)
              {
               minBuyOpenPrice = OrderOpenPrice();
              }
           }
        }

      if(!buyExists)
        {
         double buyTPPrice = currentPrice + BuyTP_Distance * Point;
         int buyTicket = OrderSend(Symbol(), OP_BUY, BuyLotSize, currentPrice, Slippage, 0, buyTPPrice, "Buy order", MagicNumber, 0, Blue);
         if(buyTicket < 0)
           {
            Print("Error opening Buy order: ", GetLastError());
           }
         else
           {
            Print("Buy order opened successfully: ", buyTicket);
           }
        }
      else
        {
         double buyGridPrice = minBuyOpenPrice - BuyGrid_Distance * Point;

         if(currentPrice <= buyGridPrice)
           {
            double buyTPPrice = currentPrice + BuyTP_Distance * Point;
            int buyTicket = OrderSend(Symbol(), OP_BUY, BuyLotSize, currentPrice, Slippage, 0, buyTPPrice, "Grid Buy order", MagicNumber, 0, Blue);
            if(buyTicket < 0)
              {
               Print("Error opening Grid Buy order: ", GetLastError());
              }
            else
              {
               Print("Grid Buy order opened successfully: ", buyTicket);
              }
           }
        }
     }

// ฝั่ง Sell
   if(EnableSell && currentPrice >= MinSellPrice && currentPrice <= MaxSellPrice)
     {
      bool sellExists = false;
      double maxSellOpenPrice = 0;

      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber)
           {
            sellExists = true;
            if(OrderOpenPrice() > maxSellOpenPrice)
              {
               maxSellOpenPrice = OrderOpenPrice();
              }
           }
        }

      if(!sellExists)
        {
         double sellTPPrice = currentPrice - SellTP_Distance * Point;
         int sellTicket = OrderSend(Symbol(), OP_SELL, SellLotSize, currentPrice, Slippage, 0, sellTPPrice, "Sell order", MagicNumber, 0, Red);
         if(sellTicket < 0)
           {
            Print("Error opening Sell order: ", GetLastError());
           }
         else
           {
            Print("Sell order opened successfully: ", sellTicket);
           }
        }
      else
        {
         double sellGridPrice = maxSellOpenPrice + SellGrid_Distance * Point;

         if(currentPrice >= sellGridPrice)
           {
            double sellTPPrice = currentPrice - SellTP_Distance * Point;
            int sellTicket = OrderSend(Symbol(), OP_SELL, SellLotSize, currentPrice, Slippage, 0, sellTPPrice, "Grid Sell order", MagicNumber, 0, Red);
            if(sellTicket < 0)
              {
               Print("Error opening Grid Sell order: ", GetLastError());
              }
            else
              {
               Print("Grid Sell order opened successfully: ", sellTicket);
              }
           }
        }
     }

// แสดงผลบนหน้าจอ
   string sellInfo = StringFormat("Sell Orders: %d \nSell Profit: %.2f", sellCount, sellProfit);
   string buyInfo = StringFormat("Buy Orders: %d \nBuy Profit: %.2f", buyCount, buyProfit);
   string totalInfo = StringFormat("Total Orders: %d \nTotal Profit: %.2f", totalOrders, totalProfit);
   Comment(
      "\n" +
      "--------------------" +
      "\n" +
      "PleumGrid" +
      "\n" +
      "--------------------" +
      "\n" +
      sellInfo +
      "\n" +
      "--------------------" +
      "\n" +
      buyInfo +
      "\n" +
      "--------------------" +
      "\n" +
      totalInfo
   );
  }
//+------------------------------------------------------------------+
