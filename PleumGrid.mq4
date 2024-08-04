//+------------------------------------------------------------------+
//|                                                    PleumGrid.mq4 |
//|                              Copyright 2024, The Market Survivor |
//|                       https://www.facebook.com/TheMarketSurvivor |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, The Market Survivor"
#property link      "https://www.facebook.com/TheMarketSurvivor"
#property version   "1.00"
#property strict

// Variables for Buy orders
input double MinBuyPrice = 1.1000;    // Minimum price for Buy orders
input double MaxBuyPrice = 1.2000;    // Maximum price for Buy orders
input double BuyLotSize = 0.1;        // Lot size for Buy orders
input double BuyTP_Distance = 50;     // Take Profit distance (points) for Buy orders
input double BuyGrid_Distance = 20;   // Grid distance (points) for opening additional Buy orders
input bool EnableBuy = true;          // Enable or disable Buy orders

// Variables for Sell orders
input double MinSellPrice = 1.2000;   // Minimum price for Sell orders
input double MaxSellPrice = 1.3000;   // Maximum price for Sell orders
input double SellLotSize = 0.1;       // Lot size for Sell orders
input double SellTP_Distance = 50;    // Take Profit distance (points) for Sell orders
input double SellGrid_Distance = 20;  // Grid distance (points) for opening additional Sell orders
input bool EnableSell = true;         // Enable or disable Sell orders

input int Slippage = 3;               // Acceptable slippage
input int MagicNumber = 12345;        // Magic Number for orders

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
   double currentPrice = MarketInfo(Symbol(), MODE_BID); // Current price

   int buyCount = 0;          // Number of Buy orders
   double buyProfit = 0;      // Total profit/loss for Buy orders
   int sellCount = 0;         // Number of Sell orders
   double sellProfit = 0;     // Total profit/loss for Sell orders
   int totalOrders = 0;       // Total number of orders
   double totalProfit = 0;    // Total profit/loss for all orders

// Check all orders to calculate the count and profit/loss
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

         // Calculate the total count and profit/loss of all orders
         totalOrders++;
         totalProfit += OrderProfit();
        }
     }

// Buy orders logic
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

// Sell orders logic
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

// Display results on the screen
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
