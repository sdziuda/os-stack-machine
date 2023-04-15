;%include "macro_print.asm"              ; makro do wypisywania debugowych informacji

global core
extern get_value
extern put_value

section .text

; Argumenty funkcji core:
;   rdi - wartość n
;   rsi - wskaźnik na tablicę znaków
core:
        push    rbp                     ; zapamiętujemy wartość rbp
        mov     rbp, rsp                ; zapisujemy początkową wartość stosu do rbp

.read_loop:
        mov     al, [rsi]               ; wczytujemy znak z tablicy
        test    al, al                  ; sprawdzamy czy nie jest to koniec tablicy
        je      .end                    ; jeśli tak, to kończymy

.check_plus:
        cmp     al, '+'                 ; sprawdzamy czy znak to '+'
        jne     .check_star             ; jeśli nie, to przechodzimy do sprawdzania czy to '*'
        pop     rax                     ; jeśli tak, to pobieramy dwie wartości ze stosu
        pop     rdx
        add     rax, rdx                ; dodajemy je
        push    rax                     ; i wynik wrzucamy na stos
        jmp     .increment              ; pozostałych warunków nie musimy sprawdzać, przechodzimy dalej

.check_star:
        cmp     al, '*'                 ; sprawdzamy czy znak to '*'
        jne     .check_minus            ; jeśli nie, to przechodzimy do sprawdzania czy to '-'
        pop     rax                     ; jeśli tak, to pobieramy dwie wartości ze stosu
        pop     rdx
        mul     rdx                     ; mnożymy je
        push    rax                     ; i wynik wrzucamy na stos
        jmp     .increment

.check_minus:
        cmp     al, '-'                 ; sprawdzamy czy znak to '-'
        jne     .check_n                ; jeśli nie, to przechodzimy do sprawdzania czy to 'n'
        pop     rax                     ; jeśli tak, to pobieramy wartość ze stosu
        neg     rax                     ; negujemy ją arytmetycznie
        push    rax                     ; i wynik wrzucamy na stos
        jmp     .increment

.check_n:
        cmp     al, 'n'                 ; sprawdzamy czy znak to 'n'
        jne     .check_B                ; jeśli nie, to przechodzimy do sprawdzania czy to 'B'
        push    rdi                     ; jeśli tak, to wrzucamy na stos wartość n (trzymaną w rdi)
        jmp     .increment

.check_B:
        cmp     al, 'B'                 ; sprawdzamy czy znak to 'B'
        jne     .check_C                ; jeśli nie, to przechodzimy do sprawdzania czy to 'C'
        pop     rax                     ; jeśli tak, to pobieramy wartość ze stosu
        mov     rdx, [rsp]              ; kopiujemy wartość ze szczytu stosu
        test    rdx, rdx                ; sprawdzamy wartość na szczycie stosu
        je      .increment              ; jeśli jest tam 0, to przechodzimy dalej
        test    rax, rax                ; wpp. porównujemy pobraną wcześniej wartość z 0
        jge     .B_forward              ; jeśli >= 0, to przechodzimy do etykiety .B_forward
        neg     rax                     ; jeśli < 0, to negujemy ją
        sub     rsi, rax                ; i odejmujemy od indeksu
        jmp     .increment
.B_forward:
        add     rsi, rax                ; jeśli wartość>= 0, to dodajemy ją do indeksu
        jmp     .increment

.check_C:
        cmp     al, 'C'                 ; sprawdzamy czy znak to 'C'
        jne     .check_D                ; jeśli nie, to przechodzimy do sprawdzania czy to 'D'
        pop     rax                     ; jeśli tak, to pobieramy wartość ze stosu i nie wrzucamy z powrotem
        jmp     .increment

.check_D:
        cmp     al, 'D'                 ; sprawdzamy czy znak to 'D'
        jne     .check_E                ; jeśli nie, to przechodzimy do sprawdzania czy to 'E'
        pop     rax                     ; jeśli tak, to pobieramy wartość ze stosu
        push    rax                     ; wrzucamy ją na stos
        push    rax                     ; i jeszcze raz
        jmp     .increment

.check_E:
        cmp     al, 'E'                 ; sprawdzamy czy znak to 'E'
        jne     .check_G                ; jeśli nie, to przechodzimy do sprawdzania czy to 'G'
        pop     rax                     ; jeśli tak, to pobieramy dwie wartości ze stosu
        pop     rdx
        push    rax                     ; wrzucamy je na stos w odwrotnej kolejności
        push    rdx
        jmp     .increment

.check_G:
        cmp     al, 'G'                 ; sprawdzamy czy znak to 'G'
        jne     .check_P                ; jeśli nie, to przechodzimy do sprawdzania czy to 'P'
        push    rsi                     ; jeśli tak, to wrzucamy na stos rdi i rsi (aby zachować je przy call)
        push    rdi
        mov     rax, rsp                ; kopiujemy wartość rsp do rax
        and     rax, 15                 ; i wykonujemy operację and z 15 (sprawdzamy czy stos jest wyrównany do 16)
        jz      .G_aligned              ; jeśli tak, to przechodzimy do etykiety .check_G_call
        sub     rsp, 8                  ; wpp. odejmujemy od rsp 8
        call    get_value               ; wołamy funkcję get_value (parametr n jest w rdi)
        add     rsp, 8                  ; dodajemy 8 do rsp
        jmp     .G_end                  ; przechodzimy do końca funkcjonalności 'G'
.G_aligned:
        call    get_value               ; stos jest wyrównany do 16, wołamy get_value (parametr n jest w rdi)
.G_end:
        pop     rdi                     ; przywracamy wartości rdi i rsi
        pop     rsi
        push    rax                     ; wynik wywoływanej funkcji wrzucamy na stos
        jmp     .increment

.check_P:
        cmp     al, 'P'                 ; sprawdzamy czy znak to 'P'
        jne     .check_S                ; jeśli nie, to przechodzimy do sprawdzania czy to 'S'
        mov     rdx, rsi                ; wpp. kopiujemy adres tablicy znaków (rsi) do rdx
        pop     rsi                     ; pobieramy wartość ze stosu do rsi
        push    rdx                     ; wrzucamy adres tablicy znaków i rdi (n) na stos (aby zachować je przy call)
        push    rdi
        mov     rax, rsp                ; kopiujemy wartość rsp do rax
        and     rax, 15                 ; i wykonujemy operację and z 15 (sprawdzamy czy stos jest wyrównany do 16)
        jz      .P_aligned              ; jeśli tak, to przechodzimy do etykiety .check_P_call
        sub     rsp, 8                  ; wpp. odejmujemy od rsp 8
        call    put_value               ; wołamy funkcję put_value (parametr n jest w rdi a v w rsi)
        add     rsp, 8                  ; dodajemy 8 do rsp
        jmp     .P_end                  ; przechodzimy do końca funkcjonalności 'P'
.P_aligned:
        call    put_value               ; stos jest wyrównany do 16, wołamy put_value (parametr n jest w rdi a v w rsi)
.P_end:
        pop     rdi                     ; przywracamy wartość rdi i rsi
        pop     rsi
        jmp     .increment

.check_S:
        cmp     al, 'S'                 ; sprawdzamy czy znak to 'S'
        jne     .number                 ; jeśli nie, to zakładamy, że znak to cyfra 0-9
        jmp     .increment

.number:                                ; zakładamy teraz, że znak to cyfra 0-9
        sub     al, '0'                 ; odejmujemy od znaku '0' aby uzyskać cyfrę
        movzx   eax, al                 ; rozszerzamy cyfrę do 64 bitów (aby móc ją wrzucić na stos)
        push    rax                     ; wrzucamy cyfrę na stos

.increment:
        inc     rsi
        jmp     .read_loop

.end:
        pop     rax                     ; wynik jest na szczycie stosu
        mov     rsp, rbp                ; przywracamy początkową wartość stosu
        pop     rbp                     ; przywracamy początkową wartość rbp
        ret                             ; zwracamy wynik