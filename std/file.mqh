#include "../kit/log.mqh";

class File
{
private:
	int _fd;
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
	string read_string(){
		return FileReadString(_fd);
	}
}