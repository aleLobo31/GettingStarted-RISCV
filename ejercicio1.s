#Aquí van las funciones numero e, coseno, seno y tangente
.data

.text
    factorialNumE: #argumentos en fa0 y a0
        beq a0, zero, elseFactorialNumE #En n = 0 devolvemos un 1.
            fcvt.s.w ft0, a0 #ft0 (lo utilizamos para convertir a0 a coma flotante)
            fmul.s fa0, fa0, ft0
            j finFactorialNumE
        elseFactorialNumE: li t0, 1
            fcvt.s.w fa0, t0
        finFactorialNumE: jr ra #Devuelve el nuevo factorial en fa0

    calculoE: 
        #Apilamos los registros "s" y el registro "ra"
        addi sp, sp, -28
        fsw fs0, 24(sp)
        fsw fs1, 20(sp)
        fsw fs2, 16(sp)
        fsw fs3, 12(sp)
        fsw fs4, 8(sp)
        sw s0, 4(sp)
        sw ra, 0(sp)

        #Error máximo (0.001 = 1/1000)--> fs0
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

        #1.0 --> fs4
        fcvt.s.w fs4, t0

        #n --> s0
        li s0, 0

        #Calculamos el factorial
        whileCalculoE: fmv.s fa0, fs3
        mv a0, s0
        jal ra factorialNumE
        fmv.s fs3, fa0

        #Calculamos el error cometido
        fdiv.s fs2, fs4, fs3
        flt.s t0, fs2, fs0
        bne t0, zero, endWhileCalculoE
            fadd.s fs1, fs1, fs2
            addi s0, s0, 1
            j whileCalculoE
        endWhileCalculoE: fmv.s fa0, fs1
        
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