#include "log.mqh";

#define ARRAY_SIZE 128

#define ARRAY(T, name) \
class ARRAY_##T##_##name \
{ \
private: \
	int _head; \
	int _tail; \
	int _capacity; \
	T _arr[ARRAY_SIZE]; \
public: \
	ARRAY_##T##_##name(); \
	int size(); \
	void push_back(T t); \
	T pop_back(); \
	T operator [] (const int idx); \
	void remove(int idx, int count = 1); \
}; \
ARRAY_##T##_##name::ARRAY_##T##_##name(){ \
	_head = ARRAY_SIZE / 4; \
	_tail = ARRAY_SIZE / 4 + 1; \
	_capacity = ARRAY_SIZE; \
} \
int ARRAY_##T##_##name::size(){ \
	return _tail - _head - 1; \
} \
void ARRAY_##T##_##name::push_back(T t){ \
	_arr[_tail] = t; \
	_tail++; \
} \
T ARRAY_##T##_##name::pop_back(){ \
	_tail--; \
	return _arr[_tail]; \
} \
T ARRAY_##T##_##name::operator[](int idx){ \
	return _arr[_head + idx + 1]; \
} \
void ARRAY_##T##_##name::remove(int idx, int count){ \
	for(int i = _head + idx + 1, t = 0; t < size() - count; i++, t++){ \
		_arr[i] = _arr[i + count]; \
	} \
	_tail -= count; \
} \
ARRAY_##T##_##name name; \