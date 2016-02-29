#import "kernel32.dll"
void OutputDebugStringA(string msg);
void OutputDebugStringW(string msg);
#import

string str(int val)
{
    return IntegerToString(val);
}
string str(double val)
{
    return DoubleToString(val);
}
string str(string val)
{
    return val;
}
string str(datetime val)
{
    return TimeToString(val);
}
string join(
   string s1, 
   string s2="", 
   string s3="", 
   string s4="", 
   string s5="", 
   string s6="", 
   string s7="", 
   string s8=""
   )
{
   string out = StringTrimRight(StringConcatenate(
    s1, s2, s3, s4, s5, s6, s7, s8
    ));
   return out;
}
/**
* send information to OutputDebugString() to be viewed and logged
* by SysInternals DebugView (free download from microsoft)
* This is ideal for debugging as an alternative to Print().
* The function will take up to 8 string (or numeric) arguments 
* to be concatenated into one debug message.
*/
void log(
 string s1, 
 string s2="", 
 string s3="", 
 string s4="", 
 string s5="", 
 string s6="", 
 string s7="", 
 string s8=""
 ){
 string out = StringTrimRight(StringConcatenate(
  WindowExpertName(), ".mq4 ", Symbol(), 
  " ", s1, 
  " ", s2, 
  " ", s3, 
  " ", s4, 
  " ", s5, 
  " ", s6, 
  " ", s7, 
  " ", s8
  ));
 OutputDebugStringW(out);
}