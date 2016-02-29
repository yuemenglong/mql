#include "kit.mqh"
#include "log.mqh"

struct _wave_t
{
	datetime time;
	double open;
	double close;
	double high;
	double low;
	int type;
	int no;
};

_wave_t _waves[2048] = {0};
int _wave_pos = 0;

void _insert_wave(int idx, int type)
{
	_waves[_wave_pos].time = Time[idx];
	_waves[_wave_pos].open = Open[idx];
	_waves[_wave_pos].close = Close[idx];
	_waves[_wave_pos].high = High[idx];
	_waves[_wave_pos].low = Low[idx];
	_waves[_wave_pos].type = type;
	_waves[_wave_pos].no = Bars - idx - 1;
	if(_wave_pos >= 1)
	{
		DrawLine(join("WAVE", str(_wave_pos)),
			_waves[_wave_pos].time, _waves[_wave_pos].close, 
			_waves[_wave_pos - 1].time, _waves[_wave_pos - 1].close, clrBlue, 2);
	}
	_wave_pos++;

}

void wave_init()
{
	for(int i = Bars - 2; i >= 1; i--)
	{
		//top
		if(Close[i+1] < Close[i] && Close[i] > Close[i-1])
		{
			_insert_wave(i, 1);
		}
		//bottom
		else if(Close[i+1] > Close[i] && Close[i] < Close[i-1])
		{
			_insert_wave(i, 1);
		}
	}
	// DrawLine("WAVE", _waves[_wave_pos - 2].time, _waves[_wave_pos - 2].close, 
	// 	_waves[_wave_pos - 1].time, _waves[_wave_pos - 1].close);
}

void wave_deinit()
{
	string ObjName;
	int obj_count = ObjectsTotal();
	for (int i = 0; i < obj_count; i++)
	{
		ObjName = ObjectName(i);
		int index = StringFind(ObjName, "WAVE", 0);
		if(index == 0){
			if(ObjectDelete(ObjName)==true){
				i = i - 1;
				obj_count=ObjectsTotal();
			}
		}    
	}
}

void wave_cycle()
{
	int i = iBarShift(Symbol(), 0, _waves[_wave_pos - 1].time);
	for(; i >= 1; i--)
	{
		//top
		if(Close[i+1] < Close[i] && Close[i] > Close[i-1])
		{
			_insert_wave(i, 1);
		}
		//bottom
		else if(Close[i+1] > Close[i] && Close[i] < Close[i-1])
		{
			_insert_wave(i, 1);
		}
	}
}