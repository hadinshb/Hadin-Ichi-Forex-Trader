//+------------------------------------------------------------------+
//|                                            Hadin Ichimoku.mq4 |
//|                                                Hadin Ichimoku|
//|                                              https://hsbteam.com |
//+------------------------------------------------------------------+
#property copyright "Hadin Ichimoku"
#property version   "1.00"
#property strict

//--- input parameters
input int _MagicNumber="30000"; //ID For Orders
string IndName_1="FibonacciScalper"; // Indicator_1 Name
int IndName_1_UPcode=0; // Indicator_1 UpCode
int IndName_1_Downcode=1; // Indicator_1 DownCode
//input string IndName_2=""; // Indicator_2 Name
//input int IndName_2_UPcode=0; // Indicator_2 UpCode
//input int IndName_2_Downcode=1; // Indicator_2 DownCode
//input string IndName_3="SignalRange"; // Indicator_3 Name

double Lot=0.01; // Lots
input double TakeProfit=0; // TakeProfit
input double Stoploss=0; // Stoploss
input bool AutoLot=false; //Auto Lot
input double FixedLot=0.01;// FixedLot
double Risk=0.8;//RiskPercent

double FirstTargetToSetStoplossToEntryPoint=90000000000.0; // FirstTargetToSetStoplossToEntryPoint
datetime LastActiontime;
double GetInd_iCustom[101];
double GetInd_iCustom_old[101];
double GetInd_iCustom_changed[101];
double GetInd_iCustom_maxInt[101];
double GetInd_iCustom_minInt[101];
double GetInd_iCustom_Zero[101];
double GetInd_iCustom_NewNotMax[101];
double GetInd_iCustom_OldNotMax[101];

double ConsExp;
double ConsExp_old;
double Up_arrow;
double Down_arrow;
double Up_verification;
double  Down_verification;
double orderPrice;
double verifiedTakeProfit;
bool checkstoploss=true;
string GetInd_iCustom_changed_Cons;
string GetInd_iCustom_maxInt_Cons;
string GetInd_iCustom_minInt_Cons;
string GetInd_iCustom_Zero_Cons;
string GetInd_iCustom_NewNotMax_Cons;
string GetInd_iCustom_OldNotMax_Cons;
string previusOrder="";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Create_Label(string id="",string lbl_text = "",int x="",int y="")
  {
   if(ObjectFind(id) == -1)
     {
      ObjectCreate(id, OBJ_LABEL, 0, 0, 0);
      ObjectSet(id, OBJPROP_CORNER, 1);
      ObjectSet(id, OBJPROP_XDISTANCE, x);
      ObjectSet(id, OBJPROP_YDISTANCE, y);
     }

   ObjectSetText(id, lbl_text, 10, "Arial", Black);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalOrder(int magic)
  {
   double GetTotalOrder = 0;
   for(int cnt = 0; cnt < OrdersTotal(); cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == magic)
        {
         GetTotalOrder+=1;
        }
     }
   return(GetTotalOrder);
  }


extern double Risk_P=4;
extern double Max_Lots=0.05;
double Lots;
int StopLoss = 100;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeVolume(const double volume,string symbol=NULL)
  {
   if(symbol==NULL || symbol=="")
      symbol=_Symbol;
   double volumeStep=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double volumeMin=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double volumeMax=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double volumeNormalized=int(volume/volumeStep)*volumeStep;
   return(volumeNormalized<volumeMin?0.0:(volumeNormalized>volumeMax?volumeMax:volumeNormalized));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLots()
  {
   if(AutoLot)
     {
      Lots=NormalizeDouble((AccountBalance()*(Risk_P/(1000*StopLoss))),2);
     }
   else
     {
      Lots=FixedLot;
     }

   Lots=NormalizeVolume(Lots,NULL);
   if(Lots<0.01)
      Lots=0.01;
   if(Lots>Max_Lots)
      Lots=Max_Lots;
   return (Lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OpenTrade(string trade="")
  {
   int type;
   double price;
   double sl=0;
   double tp=0;
   double Lots=GetLots();

   int tickett=-1;

   int _GetLastError = 0;
   int _OrdersTotal = TotalOrder(_MagicNumber);


   int count=10;


   if(_OrdersTotal==0)
     {

      if(previusOrder!=trade)
        {

         if(trade == "Buy")
           {
            type = OP_BUY;
            price = Ask;
            orderPrice=price;
            sl = Stoploss > 0 ? NormalizeDouble(price - (double)Stoploss*_Point,_Digits):0.0;
            tp = TakeProfit > 0 ? NormalizeDouble(price + (double)TakeProfit*_Point,_Digits):0.0;
            verifiedTakeProfit=tp;
            previusOrder="Buy";
           }
         else
            if(trade == "Sell")
              {
               type = OP_SELL;
               price = Bid;
               orderPrice=price;
               sl = Stoploss > 0 ? NormalizeDouble(price + (double)Stoploss*_Point,_Digits):0.0;
               tp = TakeProfit > 0 ? NormalizeDouble(price - (double)TakeProfit*_Point,_Digits):0.0;
               verifiedTakeProfit=tp;
               previusOrder="Sell";
              }
         checkstoploss=true;
         while(tickett<0 && count>0)
           {
            tickett=  OrderSend(_Symbol,type,Lots,price,3,sl,tp,"Order By Hadin Fibo",_MagicNumber,clrLime);
            count--;
           }

        }

     }


   else
     {




      CloseOrders();
      CloseOrders();
      CloseOrders();
      CloseOrders();


      //---- if a BUY position is opened,
      if(previusOrder =="Buy")
        {

         if(trade=="Sell")
           {

            previusOrder="Sell";

            type = OP_SELL;
            price = Bid;
            orderPrice=price;
            sl = Stoploss > 0 ? NormalizeDouble(price + (double)Stoploss*_Point,_Digits):0.0;
            tp = TakeProfit > 0 ? NormalizeDouble(price - (double)TakeProfit*_Point,_Digits):0.0;
            verifiedTakeProfit=tp;
            checkstoploss=true;

            while(tickett<0 && count>0)
              {
               tickett=   OrderSend(_Symbol,type,Lots,price,3,sl,tp,"Order By Hadin Fibo",_MagicNumber,clrLime);
               count--;
              }
           }
        }
      //---- if a SELL position is opened,
      else
         if(previusOrder =="Sell")
           {


            if(trade=="Buy")
              {

               previusOrder="Buy";

               type = OP_BUY;
               price = Ask;
               orderPrice=price;
               sl = Stoploss > 0 ? NormalizeDouble(price - (double)Stoploss*_Point,_Digits):0.0;
               tp = TakeProfit > 0 ? NormalizeDouble(price + (double)TakeProfit*_Point,_Digits):0.0;
               verifiedTakeProfit=tp;
               checkstoploss=true;
               while(tickett<0 && count>0)
                 {
                  tickett=   OrderSend(_Symbol,type,Lots,price,3,sl,tp,"Order By Hadin Fibo",_MagicNumber,clrLime);
                  count--;
                 }


              }





           }




     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders()
  {

//Update the exchange rates before closing the orders
   RefreshRates();
//Log in the terminal the total of orders, current and past
   Print(OrdersTotal());

//Start a loop to scan all the orders
//The loop starts from the last otherwise it would miss orders
   for(int i=(OrdersTotal()-1); i>=0; i--)
     {

      //If the order cannot be selected throw and log an error
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        {
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
        }
      if(OrderMagicNumber() == _MagicNumber)
        {

         //Create the required variables
         //Result variable, to check if the operation is successful or not
         bool res=false;

         //Allowed Slippage, which is the difference between current price and close price
         int Slippage=0;

         //Bid and Ask Price for the Instrument of the order
         double BidPrice=MarketInfo(OrderSymbol(),MODE_BID);
         double AskPrice=MarketInfo(OrderSymbol(),MODE_ASK);

         //Closing the order using the correct price depending on the type of order
         if(OrderType()==OP_BUY)
           {
            res=OrderClose(OrderTicket(),OrderLots(),BidPrice,Slippage);
           }
         if(OrderType()==OP_SELL)
           {
            res=OrderClose(OrderTicket(),OrderLots(),AskPrice,Slippage);
           }

         //If there was an error log it
         if(res==false)
            Print("ERROR - Unable to close the order - ",OrderTicket()," - ",GetLastError());
        }
     }
  }
string lastsignal1;
string lastsignal5;
string lastsignal15;
string lastsignal30;
string lastsignal60;
string lastsignal240;
string lastsignal1440;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Create_Label("M1",_Symbol+" M1 : NULL",16,15);
   Create_Label("M5",_Symbol+" M5 : NULL",16,38);
   Create_Label("M15",_Symbol+" M15 : NULL",16,61);
   Create_Label("M30",_Symbol+" M30 : NULL",16,84);
   Create_Label("H1",_Symbol+" H1 : NULL",16,107);
   Create_Label("H4",_Symbol+" H4 : NULL",16,130);
   Create_Label("D1",_Symbol+" D1 : NULL",16,153);



   lastsignal1=_Symbol+" M1 : NULL";
   lastsignal5=_Symbol+" M5 : NULL";
   lastsignal15=_Symbol+" M15 : NULL";
   lastsignal30=_Symbol+" M30 : NULL";
   lastsignal60=_Symbol+" H1 : NULL";
   lastsignal240=_Symbol+" H4 : NULL";
   lastsignal1440=_Symbol+" D1 : NULL";


   return(0);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {


   return(0);
  }


//-----------------------------------------------------------------------------
// function: deinit()
// Description: Custom indicator deinitialization function.
//-----------------------------------------------------------------------------
int deinit()
  {
   return (0);
  }



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//          TRAILING                                                 |
//+------------------------------------------------------------------+
void AdjustTrail()
  {
   if(OrdersTotal()==0)
     {
      previusOrder="";
     }
//buy order section
   int TrailAmount=1000;
   for(int b=OrdersTotal()-1; b>=0; b--)
     {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))

         if(OrderSymbol()==Symbol())
            if(OrderType()==OP_BUY)
              {
               double newsl;
               if(OrderStopLoss()==0)
                 {
                  newsl=OrderOpenPrice();
                 }
               else
                 {
                  newsl=OrderStopLoss();
                 };

               if(Ask-newsl>=TrailAmount*Point)
                 {
                  // if(OrderStopLoss()<Bid-Point*TrailAmount)

                  OrderModify(OrderTicket(),OrderOpenPrice(),newsl+(Point*500),OrderTakeProfit(),0,CLR_NONE);
                 }
              }
     }
//sell order section
   for(int s=OrdersTotal()-1; s>=0; s--)
     {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))

         if(OrderSymbol()==Symbol())
            if(OrderType()==OP_SELL)
              {
               double newsl;
               if(OrderStopLoss()==0)
                 {
                  newsl=OrderOpenPrice();
                 }
               else
                 {
                  newsl=OrderStopLoss();
                 };
               if(newsl-Bid>=TrailAmount*Point)
                 {

                  // if((OrderStopLoss()>Ask+TrailAmount*Point) || (OrderStopLoss()==0))
                  OrderModify(OrderTicket(),OrderOpenPrice(),newsl-(500*Point),OrderTakeProfit(),0,CLR_NONE);
                 }
              }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



string TakCrossJahat_current="";
string TakCrossJahat_M1="";
string TakCrossJahat_M5="";
string TakCrossJahat_M15="";
string TakCrossJahat_M30="";
string TakCrossJahat_H1="";
string TakCrossJahat_H4="";
string TakCrossJahat_D1="";



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckSitucation(int peroid)
  {

//Current Time Frame
   double tenkan_sen_current=iIchimoku(NULL,peroid,9,26,52,MODE_TENKANSEN,1);

   double tenkan_sen_previous=iIchimoku(NULL,peroid,9,26,52,MODE_TENKANSEN,2);




   double kijun_sen_current=iIchimoku(NULL,peroid,9,26,52,MODE_KIJUNSEN,1);

   double kijun_sen_previous=iIchimoku(NULL,peroid,9,26,52,MODE_KIJUNSEN,2);




   bool  isUp = tenkan_sen_current > kijun_sen_current;
   bool wasUp = tenkan_sen_previous > kijun_sen_previous;
   bool  isDown = tenkan_sen_current < kijun_sen_current;
   bool wasDown = tenkan_sen_previous < kijun_sen_previous;




   double spanA_current1=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANA,-26);

   double spanA_previous1=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANA,-25);




   double spanB_current1=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANB,-26);

   double spanB_previous1=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANB,-25);




   bool  isUpSpan1 = spanA_current1 > spanB_current1;
   bool wasUpSpan1 = spanA_previous1 > spanB_previous1;
   bool  isDownSpan1 = spanA_current1 < spanB_current1;
   bool wasDownSpan1 = spanA_previous1 < spanB_previous1;









   double spanA_current2=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANA,-25);

   double spanA_previous2=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANA,-24);




   double spanB_current2=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANB,-25);

   double spanB_previous2=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANB,-24);




   bool  isUpSpan2 = spanA_current2 > spanB_current2;
   bool wasUpSpan2 = spanA_previous2 > spanB_previous2;
   bool  isDownSpan2 = spanA_current2 < spanB_current2;
   bool wasDownSpan2 = spanA_previous2 < spanB_previous2;






   double spanA_current3=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANA,-24);

   double spanA_previous3=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANA,-23);




   double spanB_current3=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANB,-24);

   double spanB_previous3=iIchimoku(NULL,peroid,9,26,52,MODE_SENKOUSPANB,-23);




   bool  isUpSpan3 = spanA_current3 > spanB_current3;
   bool wasUpSpan3 = spanA_previous3 > spanB_previous3;
   bool  isDownSpan3 = spanA_current3 < spanB_current3;
   bool wasDownSpan3 = spanA_previous3 < spanB_previous3;


   if(isUp && !wasUp) //red be green
     {

      bool isTakCross=true;
      for(int i=2; i<=27; i++)
        {

         double tenkan_sen=iIchimoku(NULL,peroid,9,26,52,MODE_TENKANSEN,i);
         double kijun_sen=iIchimoku(NULL,peroid,9,26,52,MODE_KIJUNSEN,i);

         if(tenkan_sen>=kijun_sen)
           {
            isTakCross=false;
           }

        }


      if(isTakCross)
        {

         switch(peroid)
           {
            case 0:
              {
               TakCrossJahat_current="Buy-Only";

               ObjectCreate(Time[0], OBJ_ARROW, 0, Time[1], tenkan_sen_previous);
               ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet(Time[0], OBJPROP_ARROWCODE, 108);
               ObjectSet(Time[0], OBJPROP_COLOR,Blue);
               ObjectSet(Time[0], OBJPROP_WIDTH,5);
               break;
              }

            case 1:
              {
               TakCrossJahat_M1="Buy-Only";
               break;
              }
            case 5:
              {
               TakCrossJahat_M5="Buy-Only";
               break;
              }
            case 15:
              {
               TakCrossJahat_M15="Buy-Only";
               break;
              }
            case 30:
              {
               TakCrossJahat_M30="Buy-Only";
               break;
              }
            case 60:
              {
               TakCrossJahat_H1="Buy-Only";
               break;
              }
            case 240:
              {
               TakCrossJahat_H4="Buy-Only";
               break;
              }
            case 1440:
              {
               TakCrossJahat_D1="Buy-Only";
               break;
              }

           }//end of switch


        }

      else
        {

         string TakCrossJahat="";
         string TimeFrame="";

         switch(peroid)
           {
            case 0:
              {
               TakCrossJahat=TakCrossJahat_current;
               TimeFrame="CurrentTimeFrame";
               break;
              }

            case 1:
              {
               TakCrossJahat=TakCrossJahat_M1;
               TimeFrame="M1";
               break;
              }
            case 5:
              {
               TakCrossJahat=TakCrossJahat_M5;
               TimeFrame="M5";
               break;
              }
            case 15:
              {
               TakCrossJahat=TakCrossJahat_M15;
               TimeFrame="M15";
               break;
              }
            case 30:
              {
               TakCrossJahat=TakCrossJahat_M30;
               TimeFrame="M30";
               break;
              }
            case 60:
              {
               TakCrossJahat=TakCrossJahat_H1;
               TimeFrame="H1";
               break;
              }
            case 240:
              {
               TakCrossJahat=TakCrossJahat_H4;
               TimeFrame="H4";
               break;
              }
            case 1440:
              {
               TakCrossJahat=TakCrossJahat_D1;
               TimeFrame="D1";
               break;
              }

           }//end of switch

         if(TakCrossJahat=="Buy-Only" && ((isUpSpan1 && !wasUpSpan1)||(isUpSpan2 && !wasUpSpan2)||(isUpSpan2 && !wasUpSpan2)))
           {

            if(TimeFrame=="CurrentTimeFrame")
              {
               ObjectCreate(Time[0], OBJ_ARROW, 0, Time[1], High[1]-90*Point); //draw an up arrow
               ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet(Time[0], OBJPROP_ARROWCODE,  SYMBOL_ARROWUP);
               ObjectSet(Time[0], OBJPROP_COLOR,Blue);
               ObjectSet(Time[0], OBJPROP_WIDTH,8);
              }
            ObjectSetText(TimeFrame,_Symbol+" "+TimeFrame+" : BUY SIGNAL AT "+Time[0],NULL,NULL,NULL);


           }

        }



     }
   else
      if(isDown && !wasDown) //green be red
        {



         bool isTakCross=true;
         for(int i=2; i<=27; i++)
           {

            double tenkan_sen=iIchimoku(NULL,peroid,9,26,52,MODE_TENKANSEN,i);
            double kijun_sen=iIchimoku(NULL,peroid,9,26,52,MODE_KIJUNSEN,i);

            if(tenkan_sen<=kijun_sen)
              {
               isTakCross=false;
              }

           }


         if(isTakCross)
           {

            switch(peroid)
              {
               case 0:
                 {
                  TakCrossJahat_current="Sell-Only";


                  ObjectCreate(Time[0],OBJ_ARROW, 0, Time[1], tenkan_sen_previous); //draw a dn arrow
                  ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet(Time[0], OBJPROP_ARROWCODE, 108);
                  ObjectSet(Time[0], OBJPROP_COLOR,Red);
                  ObjectSet(Time[0], OBJPROP_WIDTH,5);
                  break;
                 }

               case 1:
                 {
                  TakCrossJahat_M1="Sell-Only";
                  break;
                 }
               case 5:
                 {
                  TakCrossJahat_M5="Sell-Only";
                  break;
                 }
               case 15:
                 {
                  TakCrossJahat_M15="Sell-Only";
                  break;
                 }
               case 30:
                 {
                  TakCrossJahat_M30="Sell-Only";
                  break;
                 }
               case 60:
                 {
                  TakCrossJahat_H1="Sell-Only";
                  break;
                 }
               case 240:
                 {
                  TakCrossJahat_H4="Sell-Only";
                  break;
                 }
               case 1440:
                 {
                  TakCrossJahat_D1="Sell-Only";
                  break;
                 }

              }//end of switch



           }
         else
           {
            string TakCrossJahat="";
            string TimeFrame="";

            switch(peroid)
              {
               case 0:
                 {
                  TakCrossJahat=TakCrossJahat_current;
                  TimeFrame="CurrentTimeFrame";
                  break;
                 }

               case 1:
                 {
                  TakCrossJahat=TakCrossJahat_M1;
                  TimeFrame="M1";
                  break;
                 }
               case 5:
                 {
                  TakCrossJahat=TakCrossJahat_M5;
                  TimeFrame="M5";
                  break;
                 }
               case 15:
                 {
                  TakCrossJahat=TakCrossJahat_M15;
                  TimeFrame="M15";
                  break;
                 }
               case 30:
                 {
                  TakCrossJahat=TakCrossJahat_M30;
                  TimeFrame="M30";
                  break;
                 }
               case 60:
                 {
                  TakCrossJahat=TakCrossJahat_H1;
                  TimeFrame="H1";
                  break;
                 }
               case 240:
                 {
                  TakCrossJahat=TakCrossJahat_H4;
                  TimeFrame="H4";
                  break;
                 }
               case 1440:
                 {
                  TakCrossJahat=TakCrossJahat_D1;
                  TimeFrame="D1";
                  break;
                 }

              }//end of switch

            if(TakCrossJahat=="Sell-Only" && ((isDownSpan1 && !wasDownSpan1)||(isDownSpan2 && !wasDownSpan2)||(isDownSpan3 && !wasDownSpan3)))
              {

               if(TimeFrame=="CurrentTimeFrame")
                 {
                  ObjectCreate(Time[0],OBJ_ARROW, 0, Time[1], Low[1]+50*Point); //draw a dn arrow
                  ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet(Time[0], OBJPROP_ARROWCODE,  SYMBOL_ARROWDOWN);
                  ObjectSet(Time[0], OBJPROP_COLOR,Red);
                  ObjectSet(Time[0], OBJPROP_WIDTH,8);
                 }
               ObjectSetText(TimeFrame,_Symbol+" "+TimeFrame+" : SELL SIGNAL AT "+Time[0],NULL,NULL,NULL);

              }

           }


        }




   if(kijun_sen_current==tenkan_sen_current) // agar rood croos bod
     {

      //check shavad aya tak kros ast ya kheir




      bool isTakCross=true;

      double tenkan_sen_old=iIchimoku(NULL,peroid,9,26,52,MODE_TENKANSEN,2);
      double kijun_sen_old=iIchimoku(NULL,peroid,9,26,52,MODE_KIJUNSEN,2);

      for(int i=2; i<=27; i++)
        {

         double tenkan_sen=iIchimoku(NULL,peroid,9,26,52,MODE_TENKANSEN,i);
         double kijun_sen=iIchimoku(NULL,peroid,9,26,52,MODE_KIJUNSEN,i);

         if(tenkan_sen>=kijun_sen && tenkan_sen_old  <kijun_sen_old)
           {
            isTakCross=false;
           }

         else
            if(tenkan_sen<=kijun_sen  && tenkan_sen_old >kijun_sen_old)
              {
               isTakCross=false;
              }
            else
               if(tenkan_sen_old  ==kijun_sen_old)
                 {
                  isTakCross=false;
                 }

        }


      double tenkan_sen_cur=iIchimoku(NULL,peroid,9,26,52,MODE_TENKANSEN,0);
      double kijun_sen_cur=iIchimoku(NULL,peroid,9,26,52,MODE_KIJUNSEN,0);

      if(isTakCross &&tenkan_sen_cur> kijun_sen_cur)
        {
         switch(peroid)
           {
            case 0:
              {
               TakCrossJahat_current="Buy-Only";

               ObjectCreate(Time[0], OBJ_ARROW, 0, Time[1], tenkan_sen_previous);
               ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet(Time[0], OBJPROP_ARROWCODE, 108);
               ObjectSet(Time[0], OBJPROP_COLOR,Blue);
               ObjectSet(Time[0], OBJPROP_WIDTH,5);
               break;
              }

            case 1:
              {
               TakCrossJahat_M1="Buy-Only";
               break;
              }
            case 5:
              {
               TakCrossJahat_M5="Buy-Only";
               break;
              }
            case 15:
              {
               TakCrossJahat_M15="Buy-Only";
               break;
              }
            case 30:
              {
               TakCrossJahat_M30="Buy-Only";
               break;
              }
            case 60:
              {
               TakCrossJahat_H1="Buy-Only";
               break;
              }
            case 240:
              {
               TakCrossJahat_H4="Buy-Only";
               break;
              }
            case 1440:
              {
               TakCrossJahat_D1="Buy-Only";
               break;
              }

           }//end of switch

        }
      else

         if(isTakCross &&tenkan_sen_cur< kijun_sen_cur)
           {

            switch(peroid)
              {
               case 0:
                 {
                  TakCrossJahat_current="Sell-Only";


                  ObjectCreate(Time[0],OBJ_ARROW, 0, Time[1], tenkan_sen_previous); //draw a dn arrow
                  ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet(Time[0], OBJPROP_ARROWCODE, 108);
                  ObjectSet(Time[0], OBJPROP_COLOR,Red);
                  ObjectSet(Time[0], OBJPROP_WIDTH,5);
                  break;
                 }

               case 1:
                 {
                  TakCrossJahat_M1="Sell-Only";
                  break;
                 }
               case 5:
                 {
                  TakCrossJahat_M5="Sell-Only";
                  break;
                 }
               case 15:
                 {
                  TakCrossJahat_M15="Sell-Only";
                  break;
                 }
               case 30:
                 {
                  TakCrossJahat_M30="Sell-Only";
                  break;
                 }
               case 60:
                 {
                  TakCrossJahat_H1="Sell-Only";
                  break;
                 }
               case 240:
                 {
                  TakCrossJahat_H4="Sell-Only";
                  break;
                 }
               case 1440:
                 {
                  TakCrossJahat_D1="Sell-Only";
                  break;
                 }

              }//end of switch

           }


      string TakCrossJahat="";
      string TimeFrame="";

      switch(peroid)
        {
         case 0:
           {
            TakCrossJahat=TakCrossJahat_current;
            TimeFrame="CurrentTimeFrame";
            break;
           }

         case 1:
           {
            TakCrossJahat=TakCrossJahat_M1;
            TimeFrame="M1";
            break;
           }
         case 5:
           {
            TakCrossJahat=TakCrossJahat_M5;
            TimeFrame="M5";
            break;
           }
         case 15:
           {
            TakCrossJahat=TakCrossJahat_M15;
            TimeFrame="M15";
            break;
           }
         case 30:
           {
            TakCrossJahat=TakCrossJahat_M30;
            TimeFrame="M30";
            break;
           }
         case 60:
           {
            TakCrossJahat=TakCrossJahat_H1;
            TimeFrame="H1";
            break;
           }
         case 240:
           {
            TakCrossJahat=TakCrossJahat_H4;
            TimeFrame="H4";
            break;
           }
         case 1440:
           {
            TakCrossJahat=TakCrossJahat_D1;
            TimeFrame="D1";
            break;
           }

        }//end of switch

      if(TakCrossJahat=="Buy-Only" && ((isUpSpan1 && !wasUpSpan1)||(isUpSpan2 && !wasUpSpan2)||(isUpSpan2 && !wasUpSpan2)))
        {

         if(TimeFrame=="CurrentTimeFrame")
           {
            ObjectCreate(Time[0], OBJ_ARROW, 0, Time[1], High[1]-90*Point); //draw an up arrow
            ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(Time[0], OBJPROP_ARROWCODE,  SYMBOL_ARROWUP);
            ObjectSet(Time[0], OBJPROP_COLOR,Blue);
            ObjectSet(Time[0], OBJPROP_WIDTH,8);
           }
         ObjectSetText(TimeFrame,_Symbol+" "+TimeFrame+" : BUY SIGNAL AT "+Time[0],NULL,NULL,NULL);






        }


      else
         if(TakCrossJahat=="Sell-Only" && ((isDownSpan1 && !wasDownSpan1)||(isDownSpan2 && !wasDownSpan2)||(isDownSpan3 && !wasDownSpan3)))
           {

            if(TimeFrame=="CurrentTimeFrame")
              {
               ObjectCreate(Time[0],OBJ_ARROW, 0, Time[1], Low[1]+50*Point); //draw a dn arrow
               ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet(Time[0], OBJPROP_ARROWCODE,  SYMBOL_ARROWDOWN);
               ObjectSet(Time[0], OBJPROP_COLOR,Red);
               ObjectSet(Time[0], OBJPROP_WIDTH,8);
              }
            ObjectSetText(TimeFrame,_Symbol+" "+TimeFrame+" : SELL SIGNAL AT "+Time[0],NULL,NULL,NULL);

           }



     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  GetFirstCandleBeforeRoodIndex(int peroid,int Shoroindex)
  {
   int result=-100;//null
   int Startindex=Shoroindex;

   while(result==-100)
     {


      double tenkan_sen=iIchimoku(NULL,peroid,9,26,52,MODE_TENKANSEN,Startindex);
      double kijun_sen=iIchimoku(NULL,peroid,9,26,52,MODE_KIJUNSEN,Startindex);
      if(tenkan_sen>kijun_sen)
        {
         result=Startindex;
        }
      else
         if(tenkan_sen<kijun_sen)
           {
            result=Startindex;
           }
         else
           {
            Startindex++;
           }

     }
   return result;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---




   CheckSitucation(0);
   CheckSitucation(1);
   CheckSitucation(5);
   CheckSitucation(15);
   CheckSitucation(30);
   CheckSitucation(60);
   CheckSitucation(240);
   CheckSitucation(1440);


   string temp1,temp5,temp15,temp30,temp60,temp240,temp1440;
   temp1=ObjectDescription("M1");
   temp5=ObjectDescription("M5");
   temp15=ObjectDescription("M15");
   temp30=ObjectDescription("M30");
   temp60=ObjectDescription("H1");
   temp240=ObjectDescription("H4");
   temp1440=ObjectDescription("D1");


   if(lastsignal1!=temp1)
     {
      lastsignal1=temp1;
      Alert(temp1);
      SendNotification(temp1);
     }

   if(lastsignal5!=temp5)
     {
      lastsignal5=temp5;
      Alert(temp5);
      SendNotification(temp5);
     }


   if(lastsignal15!=temp15)
     {
      lastsignal15=temp15;
      Alert(temp15);
      SendNotification(temp15);
     }


   if(lastsignal30!=temp30)
     {
      lastsignal30=temp30;
      Alert(temp30);
      SendNotification(temp30);
     }


   if(lastsignal60!=temp60)
     {
      lastsignal60=temp60;
      Alert(temp60);
      SendNotification(temp60);
     }


   if(lastsignal240!=temp240)
     {
      lastsignal240=temp240;
      Alert(temp240);
      SendNotification(temp240);
     }


   if(lastsignal1440!=temp1440)
     {
      lastsignal1440=temp1440;
      Alert(temp1440);
      SendNotification(temp1440);
     }




   if(LastActiontime!=Time[0])
     {
      //Code to execute once in the bar
      //  Print("This code is executed only once in the bar started ",Time[0]);




      LastActiontime=Time[0];



      /*
            double MAFast12Cur = iMA(_Symbol,_Period,12,0,MODE_EMA,PRICE_CLOSE,1);
            double MAFast12Pre = iMA(_Symbol,_Period,12,0,MODE_EMA,PRICE_CLOSE,2);




            double MASlow100Cur = iMA(_Symbol,_Period,100,0,MODE_EMA,PRICE_CLOSE,1);
            double MASlow100Pre = iMA(_Symbol,_Period,100,0,MODE_EMA,PRICE_CLOSE,2);

            bool  isUp = MAFast12Cur > MASlow100Cur;
            bool wasUp = MAFast12Pre > MASlow100Pre;
            bool  isDown = MAFast12Cur < MASlow100Cur;
            bool wasDown = MAFast12Pre < MASlow100Pre;




            if(isUp && !wasUp)
              {

               Create_Label("status","Buy Signal Verificed",10,40);
               ObjectCreate(Time[0], OBJ_ARROW, 0, Time[0], High[0]-90*Point); //draw an up arrow
               ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
               ObjectSet(Time[0], OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
               ObjectSet(Time[0], OBJPROP_COLOR,Blue);
               ObjectSet(Time[0], OBJPROP_WIDTH,10);


               OpenTrade("Buy");


              }
            else
               if(isDown && !wasDown)
                 {
                  Create_Label("status","Sell Signal Verificed",10,40);
                  ObjectCreate(Time[0],OBJ_ARROW, 0, Time[0], Low[0]+50*Point); //draw a dn arrow
                  ObjectSet(Time[0], OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet(Time[0], OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
                  ObjectSet(Time[0], OBJPROP_COLOR,Red);
                  ObjectSet(Time[0], OBJPROP_WIDTH,10);

                  OpenTrade("Sell");

                 }



      */



     }
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
