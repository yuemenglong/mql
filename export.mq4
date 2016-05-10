#property indicator_chart_window

#include "sys/context.mqh"
#include "view/label.mqh"

class Test : public Context
{
   File* file;
   bool record;
   Label* record_label;
   int current_year;
   datetime last_time;
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
		if(last_time >= Time[0]){
			return;
		}
		file.write(Time[0]);
		file.write(Open[0]);
		file.write(High[0]);
		file.write(Low[0]);
		file.write(Close[0]);
		file.flush();
		last_time = Time[0];
	}
	virtual void on_new_bar(){
		MqlDateTime time_struct;
		TimeToStruct(Time[0],time_struct);
		// log(str(time_struct.year));
		current_year = time_struct.year;
		log(str(current_year));
		record_current();
	}
	virtual void on_key_down(int key){
		if(key != 84){
			return;
		}
		record = !record;
		if(record){
			string file_name = str(current_year);
			StringAdd(file_name, ".csv");
			file = new File(file_name);
			record_current();
		}else{
			file.close();
		}
		record_label.set_text(str(record));
		record_label.show();
	}
};

setup(Test);

