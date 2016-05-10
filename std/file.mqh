#include "../kit/log.mqh";
#include "../std/array.mqh";

class File
{
private:
	int _fd;
	STR_ARRAY _cache;
public:
	File(string path, int flag = FILE_CSV | FILE_READ | FILE_WRITE | FILE_SHARE_READ){
		_fd = FileOpen(path, flag);
		if(_fd == INVALID_HANDLE){
			log("Open File Fail", path);
		}
	}
	void close(){
		FileClose(_fd);
	}
	string read_line(){
		return FileReadString(_fd);
	}
	bool reach_end(){
		return FileIsEnding(_fd);
	}
	string read_string(){
		if(_cache.size() == 0){
			string line = read_line();
			if(line == ""){
				return "";
			}
			string items[];
			StringSplit(line, ',', items);
			for(int i = 0; i < ArraySize(items); i++){
				_cache.push_back(items[i]);
			}
		}
		string ret = _cache.pop_front();
		return ret;
	}
	int read_integer(){
		return (int)StringToInteger(read_string());
	}
	double read_double(){
		return StringToDouble(read_string());
	}
	datetime read_time(){
		return StringToTime(read_string());
	}
	void write(string str){
		_cache.push_back(str);
	}
	void write(double d){
		_cache.push_back(str(d));
	}
	void write(int i){
		_cache.push_back(str(i));
	}
	void write(datetime t){
		_cache.push_back(str(t));
	}
	void flush(){
		string output;
		for(int i = 0; i < _cache.size(); i++){
			// _cache.push_back(items[i]);
			if(i != 0){
				StringAdd(output, ",");
			}
			StringAdd(output, _cache[i]);
		}
		_cache.clear();
		FileWrite(_fd, output);
	}
};