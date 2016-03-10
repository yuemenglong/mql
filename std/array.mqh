#include "../kit/log.mqh";
#define ARRAY_SIZE 512

#define ARRAY_DEFINE(T, NAME) \
struct NAME \
{ \
	int _head; \
	int _tail; \
	int _capacity; \
	T _array[ARRAY_SIZE]; \
	\
	NAME(); \
	void remove_head(int idx); \
	void remove_tail(int idx); \
	void fix(); \
	int size(); \
	int capacity(); \
	bool full(); \
	int pos(int idx); \
	bool push_back(); \
	bool pop_back(); \
	bool push_front(); \
	bool pop_front(); \
}; \
NAME::NAME(){ \
	_capacity = ARRAY_SIZE; \
	_head = 0; \
	_tail = 1; \
} \
bool NAME::full(){ \
	return size() == _capacity - 1; \
} \
int NAME::size(){ \
	return (_capacity + _tail - _head - 1) % _capacity ; \
} \
int NAME::capacity(){ \
	return _capacity; \
} \
int NAME::pos(int idx){ \
	return (_head + 1 + idx) % _capacity; \
} \
void NAME::fix(){ \
	_head = (_capacity + _head) % _capacity; \
	_tail = (_capacity + _tail) % _capacity; \
} \
bool NAME::push_back(){ \
	if(full()){ \
		return false; \
	} \
	_tail++; \
	fix(); \	
	return true; \
} \
bool NAME::pop_back(){ \
	if(size() == 0){ \
		return false; \
	} \
	_tail--; \
	fix(); \
	return true; \
} \
bool NAME::push_front(){ \
	if(full()){ \
		return false; \
	} \
	_head--; \
	fix(); \
	return true; \
} \
bool NAME::pop_front(){ \
	if(size() == 0){ \
		return false; \	
	} \
	_head++; \
	fix(); \
	return true; \
} \

#define array_front(array) \
(array._array[array.pos(0)])

#define array_back(array) \
(array._array[array.pos(array.size() - 1)])

#define array_get(array, idx) \
(array._array[array.pos(idx)])

#define iter(array) \
(array._array[array.pos(__IDX)])

#define array_each(array) \
for(int __IDX = 0; __IDX < array.size(); __IDX++)

#define array_push(array) \
for(int __IDX = array.size(), __ONCE = 1; \
	__ONCE && array.push_back(); \
	__ONCE--)


ARRAY_DEFINE(int, INT_ARRAY);
ARRAY_DEFINE(string, STR_ARRAY);