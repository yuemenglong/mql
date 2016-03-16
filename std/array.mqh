#include "../kit/log.mqh";

#define ARRAY_SIZE 512

#define ARRAY_DEFINE_I(T, NAME) \
struct NAME \
{ \
	int _head; \
	int _tail; \
	int _capacity; \
	T _array[ARRAY_SIZE]; \
	\
	NAME(){ \
		_capacity = ARRAY_SIZE; \
		_head = 0; \
		_tail = 1; \
	} \
	bool full(){ \
		return size() == _capacity - 1; \
	} \
	int size(){ \
		return (_capacity + _tail - _head - 1) % _capacity ; \
	} \
	int capacity(){ \
		return _capacity; \
	} \
	int pos(int idx){ \
		if(idx >= 0){ \
			return (_head + 1 + idx) % _capacity; \
		} else { \
			return (_tail + idx + _capacity) % _capacity; \
		} \
	} \
	T operator[](int idx){ \
		return _array[pos(idx)]; \
	} \
	void fix(){ \
		_head = (_capacity + _head) % _capacity; \
		_tail = (_capacity + _tail) % _capacity; \
	} \
	void push_back(T t){ \
		if(full()){ \
			return; \
		} \
		_array[_tail] = t; \
		_tail++; \
		fix(); \	
		return; \
	} \
	T pop_back(){ \
		if(size() == 0){ \
			return _array[0]; \
		} \
		_tail--; \
		fix(); \
		return _array[_tail]; \
	} \
	void push_front(T t){ \
		if(full()){ \
			return; \
		} \
		_array[_head] = t; \
		_head--; \
		fix(); \
		return; \
	} \
	T pop_front(){ \
		if(size() == 0){ \
			return _array[0]; \	
		} \
		_head++; \
		fix(); \
		return _array[_head]; \
	} \
	int find(T t, int from = 0){ \
		for(int i = from; i < size(); i++){ \
			if(_array[pos(i)] == t){ \
				return i; \
			} \
		} \
		return -1; \
	} \
	void remove_head(int idx){ \
		T tmp[ARRAY_SIZE]; \
		ArrayCopy(tmp, _array, 0, _head + 1, idx); \
		ArrayCopy(_array, tmp, _head + 2, 0, idx); \
		_head++; \
		fix(); \
	} \
	void remove_tail(int idx){ \
		T tmp[ARRAY_SIZE]; \
		int pos = pos(idx); \
		ArrayCopy(tmp, _array, 0, pos + 1, size() - idx - 1); \
		ArrayCopy(_array, tmp, pos, 0, size() - idx - 1); \
		_tail--; \
		fix(); \
	} \
	void remove(int idx){ \
		if(idx >= size()){ \
			return; \
		} \
		if(idx == 0){ \
			pop_front(); \
			return; \
		} else if(idx == size() - 1){ \
			pop_back(); \
			return; \
		} \
		int pos = pos(idx); \
		if(_tail <= _head && pos < _tail){ \
			remove_tail(idx); \
		} else if(_tail <= _head && pos > _head){ \
			remove_head(idx); \
		} else if(pos < (_head + _tail) / 2){ \
			remove_head(idx); \
		} else{ \
			remove_tail(idx); \
		} \
	} \
	void sub(T t){ \
		int idx = find(t); \	
		if(idx < 0){ \
			return; \
		} \
		remove(idx); \
	} \
	void sort(){ \
		if(_head >= _tail){ \
			T tmp[ARRAY_SIZE]; \
			int size = size(); \
			ArrayCopy(tmp, _array, 0, _head+1, ARRAY_SIZE-_head-1); \
			ArrayCopy(tmp, _array, ARRAY_SIZE-_head-1, 0, _tail); \
			ArrayCopy(_array, tmp, 1, 0, size); \
			_head = 0; \
			_tail = size + 1; \
		} \
		ArraySort(_array, size(), _head+1); \
	} \
}; \

ARRAY_DEFINE_I(int, INT_ARRAY);
ARRAY_DEFINE_I(double, DOUBLE_ARRAY);
ARRAY_DEFINE_I(string, STR_ARRAY);

class ArrayItem
{
public:
	virtual bool eq(ArrayItem* other){
		return false;
	}
};

#define ARRAY_DEFINE(T, NAME) \
struct NAME \
{ \
	int _head; \
	int _tail; \
	int _capacity; \
	T* _array[ARRAY_SIZE]; \
	\
	NAME(){ \
		_capacity = ARRAY_SIZE; \
		reset(); \
	} \
	void reset(){ \
		_head = 0; \
		_tail = 1; \
	} \
	bool full(){ \
		return size() == _capacity - 1; \
	} \
	int size(){ \
		return (_capacity + _tail - _head - 1) % _capacity ; \
	} \
	int capacity(){ \
		return _capacity; \
	} \
	int pos(int idx){ \
		if(idx >= 0){ \
			return (_head + 1 + idx) % _capacity; \
		} else { \
			return (_tail + idx + _capacity) % _capacity; \
		} \
	} \
	T* operator[](int idx){ \
		return _array[pos(idx)]; \
	} \
	void fix(){ \
		_head = (_capacity + _head) % _capacity; \
		_tail = (_capacity + _tail) % _capacity; \
	} \
	void push_back(T* t){ \
		if(full()){ \
			return; \
		} \
		_array[_tail] = t; \
		_tail++; \
		fix(); \	
		return; \
	} \
	T* pop_back(){ \
		if(size() == 0){ \
			return _array[0]; \
		} \
		_tail--; \
		fix(); \
		return _array[_tail]; \
	} \
	void push_front(T* t){ \
		if(full()){ \
			return; \
		} \
		_array[_head] = t; \
		_head--; \
		fix(); \
		return; \
	} \
	T* pop_front(){ \
		if(size() == 0){ \
			return _array[0]; \	
		} \
		_head++; \
		fix(); \
		return _array[_head]; \
	} \
	int find(T* t, int from = 0){ \
		for(int i = from; i < size(); i++){ \
			if(_array[pos(i)]==t || _array[pos(i)].eq(t)){ \
				return i; \
			} \
		} \
		return -1; \
	} \
	void remove_head(int idx){ \
		T* tmp[ARRAY_SIZE]; \
		ArrayCopy(tmp, _array, 0, _head + 1, idx); \
		ArrayCopy(_array, tmp, _head + 2, 0, idx); \
		_head++; \
		fix(); \
	} \
	void remove_tail(int idx){ \
		T* tmp[ARRAY_SIZE]; \
		int pos = pos(idx); \
		ArrayCopy(tmp, _array, 0, pos + 1, size() - idx - 1); \
		ArrayCopy(_array, tmp, pos, 0, size() - idx - 1); \
		_tail--; \
		fix(); \
	} \
	void remove(int idx){ \
		if(idx >= size()){ \
			return; \
		} \
		if(idx == 0){ \
			pop_front(); \
			return; \
		} else if(idx == size() - 1){ \
			pop_back(); \
			return; \
		} \
		int pos = pos(idx); \
		if(_tail <= _head && pos < _tail){ \
			remove_tail(idx); \
		} else if(_tail <= _head && pos > _head){ \
			remove_head(idx); \
		} else if(pos < (_head + _tail) / 2){ \
			remove_head(idx); \
		} else{ \
			remove_tail(idx); \
		} \
		return; \
	} \
	void remove(T* t){ \
		int idx = find(t); \	
		if(idx < 0){ \
			return; \
		} \
		remove(idx); \
	} \
	void del(int idx){ \
		delete _array[pos(idx)]; \
		_array[pos(idx)] = NULL; \
		remove(idx); \
	} \
	void del(T* t){ \
		int idx = find(t); \	
		if(idx < 0){ \
			return; \
		} \
		del(idx); \
	} \
	void del(){ \
		for(int i = 0; i < size(); i++){ \
			delete _array[pos(i)]; \
			_array[pos(i)] = NULL; \
		} \
		reset(); \
	} \
	void clear(){ \
		reset(); \
	} \
}; \
