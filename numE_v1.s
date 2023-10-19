.data
    MAX_ERROR: .float 0.001
.text
    factorial: beq a0, zero, else1 #argumentos en fa0 y a0
                #Preparamos los registros que vamos a utilizar en el bucle: 
                #ft0 (lo utilizamos para convertir a0 a coma flotante)
                fcvt.s.w ft0, a0
                fmul.s fa0, fa0, ft0
                j fin1
            else1: li t0, 1
            fcvt.s.w fa0, t0
            fin1: jr ra #Devuelve el nuevo factorial en fa0

    calculoE: addi sp, sp, -28
        #Apilamos los registros s y el registro ra 
        fsw fs0, 24(sp)
        fsw fs1, 20(sp)
        fsw fs2, 16(sp)
        fsw fs3, 12(sp)
        fsw fs4, 8(sp)
        sw s0, 4(sp)
        sw ra, 0(sp)

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

        #1.0 --> fs4
        fcvt.s.w fs4, t0

        #n --> s0
        li s0, 0

        #Calculamos el factorial
        while: fmv.s fa0, fs3
        mv a0, s0
        jal ra factorial
        fmv.s fs3, fa0

        #Calculamos el error cometido
        fdiv.s fs2, fs4, fs3
        flt.s t0, fs2, fs0
        bne t0, zero, endWhile
            fadd.s fs1, fs1, fs2
            addi s0, s0, 1
            j while 
        endWhile: fmv.s fa0, fs1
        
        #Desapilamos los valores guardados
        flw fs0, 24(sp)
        flw fs1, 20(sp)
        flw fs2, 16(sp)
        flw fs3, 12(sp)
        flw fs4, 8(sp)
        lw s0, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 28

        jr ra
    
    main: jal ra calculoE
    li a7, 2
    ecall