//+------------------------------------------------------------------+
//|                                                     TimeLine.mq5 |
//|                                        Copyright 2018, AZ-iNVEST |
//|                                          http://www.az-invest.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, AZ-iNVEST"
#property link      "http://www.az-invest.eu"
#property version   "1.01"
#property indicator_separate_window
#property indicator_plots 0

//#define P_RENKO_BR
//#define P_RENKO_BR_PRO
#include <AZ-INVEST/SDK/MedianRenkoIndicator.mqh>
MedianRenkoIndicator customChartIndicator;

#define PREFIX_SEED "6D4E6"

static long __chartId  = ChartID();
static int  __subWinId = ChartWindowFind();

enum ENUM_DISPLAY_FORMAT
{
   DisplayFormat1 = 0,  // 25 Jan 10:55
   DisplayFormat2,      // 25.01 10:55
};

input color                InpTextColor = clrWhiteSmoke;    // Font color
input int                  InpFontSize  = 9;                // Font size
input int                  InpSpacing = 8;                  // Date/Time spacing
input ENUM_DISPLAY_FORMAT  InpDispFormat = DisplayFormat1;  // Display format

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   IndicatorSetString(INDICATOR_SHORTNAME,"\n");
   IndicatorSetDouble(INDICATOR_MINIMUM,0); 
   IndicatorSetDouble(INDICATOR_MAXIMUM,9);  
   IndicatorSetInteger(INDICATOR_HEIGHT,28);  
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   //---

   customChartIndicator.SetGetTimeFlag();   

   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int r)
{
   ObjectsDeleteAll(__chartId,PREFIX_SEED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(!customChartIndicator.OnCalculate(rates_total,prev_calculated,time))
      return(0);
      
   int start = customChartIndicator.GetPrevCalculated() - 1;
//--- correct position
   if(start<0) 
      start=0;

   if((start == 0) || customChartIndicator.IsNewBar)
   {
      ObjectsDeleteAll(__chartId,PREFIX_SEED);
      DrawTimeLine(0,rates_total,time);            
   }

   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

void DrawTimeLine(const int nPosition, const int nRatesCount, const datetime &canvasTime[])
{
   datetime curBarTime = 0;   
   bool     _start = false;
   int      c = 0;
   
   for(int i=nPosition;i<nRatesCount;i++)
   {
      curBarTime = (datetime)customChartIndicator.Time[i];
      if(curBarTime == 0)
         continue;
      else
         _start = true;
         
      if(c%InpSpacing == 0)
         DrawDateTimeMarker(i,curBarTime,canvasTime[i]);
      
      if(_start)
         c++;
   }   
   
   ChartRedraw();
}

bool DrawDateTimeMarker(const int ix, const datetime timeStamp, const datetime canvasTime)
{
   if(timeStamp == 0)
      return false;
      
   TextCreate(__chartId,PREFIX_SEED+(string)timeStamp,__subWinId,canvasTime,9,NormalizeTime(timeStamp),"Calibri",InpFontSize,InpTextColor);
   return true;
}  

string NormalizeTime(datetime _dt)
{
   static string  __months[12] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
   MqlDateTime    dt;
   
   TimeToStruct(_dt,dt);   
   string minute = (dt.min<10)  ? ("0"+(string)dt.min)  : (string)dt.min;
   string hour   = (dt.hour<10) ? ("0"+(string)dt.hour) : (string)dt.hour;
   
   if(InpDispFormat == DisplayFormat1)
      return ( "'"+(string)dt.day+" "+__months[dt.mon-1]+" "+hour+":"+minute );
   else 
   {
      string month = (dt.mon<10) ? ("0"+(string)dt.mon) : (string)dt.mon;
      return ( "'"+(string)dt.day+"."+month+" "+hour+":"+minute );
   }
}

//
// GUI wrapper function 
// https://www.mql5.com/en/docs/constants/objectconstants/enum_object/obj_text
//

bool TextCreate(const long              chart_ID=0,               // chart's ID 
                const string            name="Text",              // object name 
                const int               sub_window=0,             // subwindow index 
                datetime                time=0,                   // anchor point time 
                double                  price=0,                  // anchor point price 
                const string            text="Text",              // the text itself 
                const string            font="Calibri",           // font 
                const int               font_size=9,              // font size 
                const color             clr=clrWhiteSmoke,        // color 
                const double            angle=0.0,                // text slope 
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                const bool              back=false,               // in the background 
                const bool              selection=false,          // highlight to move 
                const bool              hidden=true,              // hidden in the object list 
                const long              z_order=0)                // priority for mouse click 
{ 
//--- reset the error value 
   ResetLastError(); 
//--- create Text object 
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)) 
   { 
      Print(__FUNCTION__,": failed to create \"Text\" object! Error code = ",GetLastError()); 
      return(false); 
   } 
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the object by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- switch off tooltips   
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,"\n");
//--- successful execution 
   return(true); 
} 
  
  