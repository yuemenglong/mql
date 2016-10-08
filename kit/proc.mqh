#import "shell32.dll" 
int ShellExecuteA(int hwnd,string Operation,string file,string Parameters,string Directory,int ShowCmd); 
int ShellExecuteW(int hwnd,string Operation,string file,string Parameters,string Directory,int ShowCmd); 
#import

#import "kernel32.dll"
int GetModuleFileNameA(int hModule, string& lpFilename, int nSize);
int GetModuleFileNameW(int hModule, string& lpFilename, int nSize);
#import

class Process
{
public:
	static string cwd(){
		uchar buffer[1024];
		string out = CharArrayToString(buffer);
		GetModuleFileNameW(0, out, 1024);
		string ret = StringSubstr(out, 0, StringLen(out) - 12);
		return ret;
	}
	static int shell(string file, string param = NULL, string cwd = NULL){
		return ShellExecuteW(0, "Open", file, param, cwd, 1);
	}
	static int node(string param = NULL, string cwd = NULL){
		return shell("node", param, cwd);
	}
};



