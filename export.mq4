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
		if(current_year != get_current_year()){
			open_file();
		}
		current_year = get_current_year();
		file.write(Time[0]);
		file.write(Open[0]);
		file.write(High[0]);
		file.write(Low[0]);
		file.write(Close[0]);
		file.flush();
		last_time = Time[0];
		log("Record", str(Time[0]));
	}
	int get_current_year(){
		MqlDateTime time_struct;
		TimeToStruct(Time[0],time_struct);
		// current_year = time_struct.year;
		return time_struct.year;
	}
	void open_file(){
		if(file){
			file.close();
		}
		string file_name = str(get_current_year());
		StringAdd(file_name, ".csv");
		file = new File(file_name);
	}
	virtual void on_new_bar(){
		// log(str(current_year));
		record_current();
	}
	virtual void on_key_down(int key){
		if(key != 84){
			return;
		}
		record = !record;
		if(record){
			current_year = get_current_year();
			open_file();
			record_current();
		}else{
			file.close();
		}
		record_label.set_text(str(record));
		record_label.show();
	}
};

setup(Test);

