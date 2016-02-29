bool IsDoubleClick(const int id,         
                  const long& lparam,   
                  const double& dparam, 
                  const string& sparam  
                  )
{
    static uint _last_click = 0;
    if(id == CHARTEVENT_CLICK){
        uint now = GetTickCount();
        if(now - _last_click < 200){
            _last_click = 0;
        	return true;
        }else{
            _last_click = now;
            return false;
        }
    }
    else{
    	return false;
    }
}

void DrawLine(string name, datetime x1, double y1, datetime x2, double y2, int clr = clrBlue, int width = 2)
{
    ObjectCreate(name, OBJ_TREND, 0, x1, y1, x2, y2);
    ObjectSet(name, OBJPROP_RAY, false);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}