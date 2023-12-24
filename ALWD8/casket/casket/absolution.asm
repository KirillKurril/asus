.686P
.model flat, c


.data
key dd 0
value dd 0
head_loc dd 0
tail_loc dd 0
capacity_loc dd 0
size_loc dd 0
ns dd 0
step dd 0
.code

insert_rec proc
	push ebp
	push ebx
	mov ebp, esp
	add ebp, 4

	mov edx, dword ptr [ebp + 8]
	mov step, edx

	mov edx, dword ptr [ebp + 12]
	mov ns, edx
	
	mov edx, dword ptr [ebp + 16]
	mov size_loc, edx
	
	mov edx, dword ptr [ebp + 20]
	mov capacity_loc, edx
	
	mov edx, dword ptr [ebp + 24]
	mov tail_loc, edx
	
	mov edx, dword ptr [ebp + 28]
	mov head_loc, edx
	
	mov edx, dword ptr [ebp + 32]
	mov value, edx
	
	mov edx, dword ptr [ebp + 36]
	mov key, edx


mov eax, head_loc

insert_ proc



		mov ebx, dword ptr [eax]
		cmp key, ebx
		je insert_exit
		jb right
		ja left

right:
		mov edx, dword ptr [eax + 12]
		test edx, edx
		je new_node
		mov eax, edx
		call insert_
		jmp insert_exit

left:
		mov edx, dword ptr [eax + 8]
		test edx, edx
		je new_node
		mov eax, edx
		call insert_
		jmp insert_exit

new_node:


insert_exit:
	ret
	insert_ endp

mov eax, ebx
pop ebx
pop ebp
ret
insert_rec endp


end