#property indicator_chart_window

#include "sys/context.mqh"
#include "view/label.mqh"

#define MAX 8192

class record_t
{
public:
	datetime time;
	double open;
	double high;
	double low;
	double close;
};

class StockExport : public Context
{
   bool _record;
   Label* _record_label;
   record_t _records[MAX];
   int _record_pos;
public:
	virtual void init(){
		_record = false;
		_record_label = new Label("EXPORT_RECORD_LABEL");
		_record_label.set_corner(0, 1);
		_record_label.set_row(0);
		show_label();
	}
	virtual void deinit(){
		_record_label.hide();
	}
	void show_label(){
		_record_label.set_text("Export Record(T): " + str(_record));
		_record_label.show();
	}
	void record_current(){
		if(!_record){
			return;
		}
		_records[_record_pos].time = Time[0];
		_records[_record_pos].open = Open[0];
		_records[_record_pos].high = High[0];
		_records[_record_pos].low = Low[0];
		_records[_record_pos].close = Close[0];
		_record_pos++;
		log("Record", str(Time[0]));
	}
	void flush(){
		File* file = new File(Symbol() + ".export.csv");
		for(int i = 0; i < _record_pos; i++){
			file.write(_records[i].time);
			file.write(_records[i].open);
			file.write(_records[i].high);
			file.write(_records[i].low);
			file.write(_records[i].close);
			file.flush();
		}
		file.close();
	}
	virtual void on_new_bar(){
		record_current();
	}
	virtual void on_key_down(int key){
		if(key != 84){ //T
			return;
		}
		_record = !_record;
		if(_record){
			// open_file();
			_record_pos = 0;
			record_current();
		}else{
			// file.close();
			flush();
		}
		show_label();
	}
};

setup(StockExport);

