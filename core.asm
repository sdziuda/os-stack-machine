%include "macro_print.asm"              ; makro do wypisywania debugowych informacji

global core
extern get_value
extern put_value

section .text

; Argumenty funkcji core:
;   rdi - wartość n
;   rsi - wskaźnik na tablicę znaków
core:
        mov     rcx, 0                  ; ustawiamy rcx (indeks) na 0
        push    rbp                     ; zapamiętujemy wartość rbp
        mov     rbp, rsp                ; zapisujemy początkową wartość stosu do rbp

.read_loop:
        mov     al, [rsi+rcx*1]         ; wczytujemy znak z tablicy
        test    al, al                  ; sprawdzamy czy nie jest to koniec tablicy
        je      .end                    ; jeśli tak, to kończymy

.check_plus:
        cmp     al, '+'                 ; sprawdzamy czy znak to '+'
        jne     .check_star             ; jeśli nie, to sprawdzamy czy to '*'
        pop     rax                     ; jeśli tak, to pobieramy dwie wartości ze stosu
        pop     rdx
        add     rax, rdx                ; dodajemy je
        push    rax                     ; i wynik wrzucamy na stos
        jmp     .increment              ; przechodzimy dalej

.check_star:
        cmp     al, '*'                 ; sprawdzamy czy znak to '*'
        jne     .check_minus            ; jeśli nie, to sprawdzamy czy to '-'
        pop     rax                     ; jeśli tak, to pobieramy dwie wartości ze stosu
        pop     rdx
        imul    rax, rdx                ; mnożymy je
        push    rax                     ; i wynik wrzucamy na stos
        jmp     .increment              ; przechodzimy dalej

.check_minus:
        cmp     al, '-'                 ; sprawdzamy czy znak to '-'
        jne     .check_n                ; jeśli nie, to sprawdzamy czy to 'n'
        pop     rax                     ; jeśli tak, to pobieramy wartość ze stosu
        neg     rax                     ; negujemy ją arytmetycznie
        push    rax                     ; i wynik wrzucamy na stos
        jmp     .increment              ; przechodzimy dalej

.check_n:
        cmp     al, 'n'                 ; sprawdzamy czy znak to 'n'
        jne     .check_B                ; jeśli nie, to sprawdzamy czy to 'B'
        push    rdi                     ; jeśli tak, to wrzucamy na stos wartość n (trzymaną w rdi)
        jmp     .increment              ; przechodzimy dalej

.check_B:
        cmp     al, 'B'                 ; sprawdzamy czy znak to 'B'
        jne     .check_C                ; jeśli nie, to sprawdzamy czy to 'C'
        jmp     .increment              ; przechodzimy dalej

.check_C:
        cmp     al, 'C'                 ; sprawdzamy czy znak to 'C'
        jne     .check_D                ; jeśli nie, to sprawdzamy czy to 'D'
        pop     rax                     ; jeśli tak, to pobieramy wartość ze stosu i nie wrzucamy z powrotem
        jmp     .increment              ; przechodzimy dalej

.check_D:
        cmp     al, 'D'                 ; sprawdzamy czy znak to 'D'
        jne     .check_E                ; jeśli nie, to sprawdzamy czy to 'E'
        pop     rax                     ; jeśli tak, to pobieramy wartość ze stosu
        push    rax                     ; wrzucamy ją na stos
        push    rax                     ; i jeszcze raz
        jmp     .increment              ; przechodzimy dalej

.check_E:
        cmp     al, 'E'                 ; sprawdzamy czy znak to 'E'
        jne     .check_G                ; jeśli nie, to sprawdzamy czy to 'G'
        pop     rax                     ; jeśli tak, to pobieramy dwie wartości ze stosu
        pop     rdx
        push    rax                     ; wrzucamy je na stos w odwrotnej kolejności
        push    rdx
        jmp     .increment              ; przechodzimy dalej

.check_G:
        cmp     al, 'G'                 ; sprawdzamy czy znak to 'G'
        jne     .check_P                ; jeśli nie, to sprawdzamy czy to 'P'
        call    get_value               ; jeśli tak, to wołamy funkcję get_value (parametr n jest w rdi)
        push    rax                     ; i jej wynik wrzucamy na stos
        jmp     .increment              ; przechodzimy dalej

.check_P:
        cmp     al, 'P'                 ; sprawdzamy czy znak to 'P'
        jne     .check_S                ; jeśli nie, to sprawdzamy czy to 'S'
        mov     rdx, rsi                ; wpp. kopiujemy adres tablicy znaków (rsi) do rdx
        pop     rsi                     ; pobieramy wartość ze stosu do rsi
        push    rdx                     ; wrzucamy adres tablicy znaków na stos (aby został zachowany przy call)
        call    put_value               ; wołamy funkcję put_value (parametr n jest w rdi a v w rsi)
        pop     rsi                     ; przywracamy wartość rsi
        jmp     .increment              ; przechodzimy dalej

.check_S:
        cmp     al, 'S'                 ; sprawdzamy czy znak to 'S'
        jne     .check_number           ; jeśli nie, to sprawdzamy czy to cyfra
        jmp     .increment              ; przechodzimy dalej

.check_number:                          ; zakładamy teraz, że znak to cyfra 0-9
        sub     al, '0'                 ; odejmujemy od znaku '0' aby uzyskać cyfrę
        movzx   eax, al                 ; rozszerzamy cyfrę do 64 bitów (aby móc ją wrzucić na stos)
        push    rax                     ; wrzucamy cyfrę na stos

.increment:
        inc     rcx                     ; zwiększamy indeks
        jmp     .read_loop              ; powtarzamy pętlę

.end:
        pop     rax                     ; wynik jest na szczycie stosu
        mov     rsp, rbp                ; przywracamy początkową wartość stosu
        pop     rbp                     ; przywracamy początkową wartość rbp
        ret                             ; zwracamy wynik