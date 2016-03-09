#include "../kit/log.mqh";
#include "../kit/array.mqh";

ARRAY_DEFINE(string, STR_ARRAY);

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
	string read_string(){
		return FileReadString(_fd);
	}
}