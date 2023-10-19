.data
    MAX_ERROR: .float 0.001
.text
    factorial: beq a0, zero, else1 #argumentos en fa0 y a0
        #Preparamos los registros que vamos a utilizar en el bucle: 
        #t0 --> iterador ft0 (lo utilizamos para convertir el iterador a coma flotante)
        #t1 --> cota 
        slli t0, a0, 1
        mv t1, t0
        addi t1, t1, 2
        while1: bge t0, t1, endWhile1
            fcvt.s.w ft0, t0
            fmul.s fa0, fa0, ft0
            addi t0, t0, 1
            j while1
        endWhile1: jr ra
        else1: li t0, 1
        fcvt.s.w fa0, t0
        jr ra #Devuelve el nuevo factorial en fa0

    potencia: beq a0, zero, else2 #argumentos en fa0 (potencia Acumulada), fa1 (x) y a0 (n)
        li t0, 0
        li t1, 2
        while2: bge t0, t1, endWhile2
            fmul.s fa0, fa0, fa1
            addi t0, t0, 1
            j while2
        else2: fmv.s fa0, fa1
        endWhile2: jr ra #Devolvemos valor de la potencia en fa0
		
    sumarResultado: li t0, 2 #argumentos en fa0 (Estimación), fa1 (ErrorActual) y a0 (n)
        rem t0, a0, t0 
        beq t0, zero, else3
            fneg.s fa1, fa1
        else3: fadd.s fa0, fa0, fa1 
        jr ra #Devuelve el valor de la estimación en fa0

    calculoSeno: #No terminal

        #Apilamos los registros s y el registro ra
        addi sp, sp, -32    
        fsw fs0 28(sp)
        fsw fs1 24(sp)
        fsw fs2 20(sp)
        fsw fs3 16(sp)
        fsw fs4 12(sp)
        fsw fs5 8(sp)
        sw s0 4(sp)
        sw ra 0(sp)

        #Error máximo --> fs0
        la t0, MAX_ERROR
        flw fs0 0(t0)

        #Estimación --> fs1
        fmv.w.x fs1, zero

        #Error actual --> fs2
        li t0, 1
        fcvt.s.w fs2, t0

        #Factorial --> fs3
        fmv.w.x fs3, zero

        #Valor de x --> fs4
        fmv.s fs4, fa0

        #Valor de la potencia --> fs5
        fcvt.s.w fs5, t0
        
        #n --> s0
        li s0, 0

        while: fmv.s fa0, fs3 #Calculamos el factorial 
            mv a0, s0
            jal ra factorial
            fmv.s fs3, fa0 #Actualizamos el factorial

            #Calculamos la potencia
            fmv.s fa0, fs5
            fmv.s fa1, fs4
            mv a0, s0
            jal ra potencia
            fmv.s fs5, fa0 

            #Calculamos el valor
            fdiv.s fs2, fs5, fs3

            #Calculamos el error --> ft0
            fabs.s ft0, fs2 

            flt.s t0, ft0, fs0 #Guardamos el valor de la comparación en t0
            bne t0, zero, endWhile
                fmv.s fa0, fs1
                fmv.s fa1, fs2
                mv a0, s0
                jal ra sumarResultado
                fmv.s fs1, fa0

                addi s0, s0, 1
                j while

        endWhile: fmv.s fa0, fs1 #Devolvemos valor en fa0
        
        #Deshacemos la pila
        flw fs0 28(sp) 
        flw fs1 24(sp)
        flw fs2 20(sp)
        flw fs3 16(sp)
        flw fs4 12(sp)
        flw fs5 8(sp)
        lw s0 4(sp)
        lw ra 0(sp)
        addi sp, sp, 32

        jr ra

    main:
        li a7, 6
        ecall
        jal ra calculoSeno
        li a7, 2
        ecall