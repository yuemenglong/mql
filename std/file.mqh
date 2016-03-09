#include "../kit/log.mqh";
#include "../std/array.mqh";

class File
{
private:
	int _fd;
	STR_ARRAY _cache;
public:
	File(string path, int flag = FILE_CSV){
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
			_cache.push_back(items);
		}
		return _cache.pop_front();
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
};