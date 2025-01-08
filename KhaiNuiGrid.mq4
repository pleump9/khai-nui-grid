//+------------------------------------------------------------------+
//|                                                  KhaiNuiGrid.mq4 |
//|                              Copyright 2024, The Market Survivor |
//|                       https://www.facebook.com/TheMarketSurvivor |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, The Market Survivor"
#property link      "https://www.facebook.com/TheMarketSurvivor"
#property version   "1.00"
#property strict

// Variables for Buy orders
input string BuySetting = "----- Buy Orders Settings -----"; // Buy Orders Settings
input bool EnableBuy = true;          // Enable or disable Buy orders
input double MinBuyPrice = 0.0;    // Minimum price for Buy orders
input double MaxBuyPrice = 10000.0;    // Maximum price for Buy orders
input double BuyLotSize = 0.01;        // Lot size for Buy orders
input double BuyTP_Distance = 50;     // Take Profit distance (points) for Buy orders
input double BuyGrid_Distance = 50;   // Grid distance (points) for opening additional Buy orders

// Variables for Sell orders
input string SellSetting = "----- Sell Orders Settings -----"; // Sell Orders Settings
input bool EnableSell = true;         // Enable or disable Sell orders
input double MinSellPrice = 0.0;   // Minimum price for Sell orders
input double MaxSellPrice = 10000.0;   // Maximum price for Sell orders
input double SellLotSize = 0.01;       // Lot size for Sell orders
input double SellTP_Distance = 50;    // Take Profit distance (points) for Sell orders
input double SellGrid_Distance = 50;  // Grid distance (points) for opening additional Sell orders

// Variables for Other Setting
input string OtherSetting = "----- Other settings -----"; // Other settings
input int Slippage = 3;               // Acceptable slippage
input int MagicNumber = 12345;        // Magic Number for orders

string EA_NAME = "KhaiNuiGrid";
string Owner = "The Market Survivor";
string OwnerLink = "https://www.facebook.com/TheMarketSurvivor";

string eaInfo = EA_NAME + "\n" + Owner + "\n" + OwnerLink;

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
   string validateDescription=""; // For Validation
// Validation
   if(!CheckVolumeValue(BuyLotSize, validateDescription) || !CheckVolumeValue(SellLotSize, validateDescription))
     {
      Print("Volume is invalid: ", validateDescription);
      return;
     }


// Logic
   double sellCurrentPrice = MarketInfo(Symbol(), MODE_BID); // Sell Current price
   double buyCurrentPrice = MarketInfo(Symbol(), MODE_ASK); // Buy Current price

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
   if(EnableBuy && buyCurrentPrice >= MinBuyPrice && buyCurrentPrice <= MaxBuyPrice)
     {
      bool buyExists = false;
      double lastBuyOpenPrice = DBL_MAX;

      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber)
           {
            buyExists = true;
            if(OrderOpenPrice() < lastBuyOpenPrice)
              {
               lastBuyOpenPrice = OrderOpenPrice();
              }
           }
        }

      if(!buyExists)
        {
         double buyTPPrice = buyCurrentPrice + BuyTP_Distance * Point;
         int buyTicket = OrderSend(Symbol(), OP_BUY, BuyLotSize, buyCurrentPrice, Slippage, 0, buyTPPrice, "Buy order", MagicNumber, 0, Blue);
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
         double buyGridPrice = lastBuyOpenPrice - BuyGrid_Distance * Point;

         if(buyCurrentPrice <= buyGridPrice)
           {
            double buyTPPrice = buyCurrentPrice + BuyTP_Distance * Point;
            int buyTicket = OrderSend(Symbol(), OP_BUY, BuyLotSize, buyCurrentPrice, Slippage, 0, buyTPPrice, "Grid Buy order", MagicNumber, 0, Blue);
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
   if(EnableSell && sellCurrentPrice >= MinSellPrice && sellCurrentPrice <= MaxSellPrice)
     {
      bool sellExists = false;
      double lastSellOpenPrice = 0;

      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber)
           {
            sellExists = true;
            if(OrderOpenPrice() > lastSellOpenPrice)
              {
               lastSellOpenPrice = OrderOpenPrice();
              }
           }
        }

      if(!sellExists)
        {
         double sellTPPrice = sellCurrentPrice - SellTP_Distance * Point;
         int sellTicket = OrderSend(Symbol(), OP_SELL, SellLotSize, sellCurrentPrice, Slippage, 0, sellTPPrice, "Sell order", MagicNumber, 0, Red);
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
         double sellGridPrice = lastSellOpenPrice + SellGrid_Distance * Point;

         if(sellCurrentPrice >= sellGridPrice)
           {
            double sellTPPrice = sellCurrentPrice - SellTP_Distance * Point;
            int sellTicket = OrderSend(Symbol(), OP_SELL, SellLotSize, sellCurrentPrice, Slippage, 0, sellTPPrice, "Grid Sell order", MagicNumber, 0, Red);
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
      eaInfo +
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
      totalInfo +
      "\n" +
      "--------------------"
   );
  }

//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
