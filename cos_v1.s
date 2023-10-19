.data

.text
    factorialCoseno: #argumentos en fa0 (factorial calculado anteriormente) y a0 (n)
        beq a0, zero, elseFactorialCoseno #Si n = 0, directamente devolvemos que el factorial es 1.
            #Preparamos los registros que vamos a utilizar en el bucle: 
            slli t0, a0, 1
            mv t1, t0
            addi t0, t0, -1 #t0 = 2*n - 1; es el valor sobre el que vamos a iterar.
            addi t1, t1, 1 #t1 = 2*n + 1; es la cota que limita el número de iteraciones.
            whileFactorialCoseno: bge t0, t1, endWhileFactorialCoseno
                fcvt.s.w ft0, t0 #Utilizamos ft0 para convertir el valor del iterador a coma flotante
                fmul.s fa0, fa0, ft0
                addi t0, t0, 1
                j whileFactorialCoseno
            endWhileFactorialCoseno: jr ra #Devuelve el factorial calculado en fa0
        elseFactorialCoseno: li t0, 1
        fcvt.s.w fa0, t0
        jr ra #Devuelve el factorial calculado en fa0

    potencia: #argumentos en fa0 (potencia Acumulada), fa1 (x) y a0 (n)
        beq a0, zero, endWhilePotencia
            li t0, 0
            li t1, 2
            whilePotencia: bge t0, t1, endWhilePotencia
                fmul.s fa0, fa0, fa1
                addi t0, t0, 1
                j whilePotencia
        endWhilePotencia: jr ra #Devuelve el valor de la potencia en fa0

    sumarResultado: #argumentos en fa0 (Estimación), fa1 (ErrorActual) y a0 (n)
        #Le aplicamos el (-1)**n al error calculado y se lo sumamos a la estimación.
        li t0, 2
        rem t0, a0, t0 
        beq t0, zero, elseSumarResultado
            fneg.s fa1, fa1
        elseSumarResultado: fadd.s fa0, fa0, fa1 
        jr ra #Devuelve el valor de la estimación en fa0

    calculoCoseno: #No terminal

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

        #Error máximo (0.001 = 1/1000) --> fs0
        li t0, 1
        fcvt.s.w ft0, t0
        li t0, 1000
        fcvt.s.w ft1, t0
        fdiv.s fs0, ft0, ft1

        #Estimación --> fs1
        fmv.w.x fs1, zero

        #Error actual --> fs2
        li t0, 1
        fcvt.s.w fs2, t0

        #Factorial --> fs3
        fmv.w.x fs3, zero

        #Valor de x --> fs4
        fmv.s fs4, fa0
        
        #Valor de la potencia acumulada --> fs5
		fcvt.s.w fs5, t0
        
        #n --> s0
        li s0, 0

        whileCalculoCoseno: fmv.s fa0, fs3 #Calculamos el factorial 
            mv a0, s0
            jal ra factorialCoseno
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
            bne t0, zero, endWhileCalculoCoseno
                fmv.s fa0, fs1
                fmv.s fa1, fs2
                mv a0, s0
                jal ra sumarResultado
                fmv.s fs1, fa0

                addi s0, s0, 1
                j whileCalculoCoseno

        endWhileCalculoCoseno: fmv.s fa0, fs1
        
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
        jal ra calculoCoseno
        li a7, 2
        ecall