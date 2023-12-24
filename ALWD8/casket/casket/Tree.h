#pragma once
#include <stdlib.h>
#include <iostream>
class Tree
{
public:
	Tree() : head(nullptr), tail(nullptr), size(0), capacity(0) {}
	void insert(int key, int value);
	void remove(short key, int value);
	short find(int key, int value);

private:
	int* head;
	int* tail;
	int capacity;
	int size;

	void insert_rec(int key, int value, int* head_loc, int* tail_loc, int* capacity_loc, int* size_loc, int ns, int step);
	const short NS = 20;
};

