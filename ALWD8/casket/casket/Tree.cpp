#include "Tree.h"

//| ключ | значение | лево | право | высота |		итого 20 байт
extern "C" int insert_rec(int key, int value, int* head_loc, int* tail_loc, int* capacity_loc, int* size_loc, int ns, int step);

void Tree::insert(int key, int value)
{
	int* head_loc = head;
	int* tail_loc = tail;
	int* capacity_loc = &capacity;
	int* size_loc = &size;
	int ns = NS;
	int step = 4;

	if (size == 0)
	{
		head_loc = (int*)malloc(NS);
		__asm {
			mov eax, head_loc
			xor ebx, ebx

			mov edx, key
			mov[eax], edx

			add eax, step
			mov edx, value
			mov[eax], edx

			add eax, step
			mov[eax], ebx

			add eax, step
			mov[eax], ebx

			add eax, step
			mov[eax], ebx

			inc dword ptr[size_loc]
			inc dword ptr[capacity_loc]

			mov eax, ns
			add tail_loc, eax
		}
		return;
	}
	if (size == capacity)
	{
		head_loc = (int*)realloc(head, size * 2);
		__asm {
			mov eax, dword ptr[capacity_loc]
			mov ebx, 2
			mul ebx
			mov dword ptr[capacity_loc], eax

			mov edx, head_loc
			mov eax, dword ptr[size_loc]
			mov ebx, ns
			mul ebx
			add edx, eax
			mov tail_loc, edx
		}
	}
	insert_rec(key, value, head_loc, tail_loc, capacity_loc, size_loc, ns, step);
}

void Tree::remove(short key, int value)
{
}

short Tree::find(int key, int value)
{
	return 0;
}
