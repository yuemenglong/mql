#property indicator_chart_window

#include "sys/context.mqh"
#include "view/label.mqh"

class StockExport : public Context
{
   File* file;
   bool record;
   Label* record_label;
public:
	virtual void init(){
		record = false;
		record_label = new Label("EXPORT_RECORD_LABEL");
		record_label.set_text(str(record));
		record_label.show();
	}
	void record_current(){
		if(!record){
			return;
		}
		file.write(Time[0]);
		file.write(Open[0]);
		file.write(High[0]);
		file.write(Low[0]);
		file.write(Close[0]);
		file.write(ema(108));
		file.flush();
		log("Record", str(Time[0]));
	}
	void open_file(){
		if(file){
			file.close();
		}
		string file_name = Symbol();
		StringAdd(file_name, ".csv.txt");
		file = new File(file_name);
	}
	virtual void on_new_bar(){
		record_current();
	}
	virtual void on_key_down(int key){
		if(key != 84){ //T
			return;
		}
		record = !record;
		if(record){
			open_file();
			record_current();
		}else{
			file.close();
		}
		record_label.set_text(str(record));
		record_label.show();
	}
};

setup(StockExport);

