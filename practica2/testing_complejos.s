.data
 a: .word 35, 15
 b: .word 10, 20

.text
    no_ext:
        # Implementar con instrucciones RISC-V (sin la extensión)
        # if (a == b):
        # return a * b;
        # else
        # return a + b;
        ret
        bne a0, a2 else
            bne a1, a3 else
                #Calculamos el resultado de la parte real
                mul t0, a0, a2
                mul t1, a1, a3
                sub a0, t0, t1

                #Calculamos el resutlado de la parte imaginaria
                mul t0, a0, a3
                mul t1, a1, a2
                add a1, t0, t1

                jr ra
        else:
            add a0, a0, a2
            add a1, a1, a3
            jr ra

    with_ext:
        # Implementar con instrucciones RISC-V (con la extensión)
        # if (a == b):
        # return a * b;
        # else
        # return a + b;
        ret

        beqz a0, a1, a2, a3 elsez
            addc a0, a1, a2, a3
            jr ra
        elsez: 
            mulc a0, a1, a2, a3
            jr ra

    main: 
        #Creamos espacio en pila
        addi sp, sp, -20
        sw ra, 16(sp)
        sw s0, 12(sp)
        sw s1, 8(sp)
        sw s2, 4(sp)
        sw s3, 0(sp)

        #Probamos la ejecución del programa con nuestro set de instrucciones
        rdcycle s2
        la s0, a
        la s1, b
        lc a0, a1, s0
        lc a2, a3, s1
        call with_ext
        sc a0, a1, s0
        rdcycle s3
        sub a0 s3 s2
        li a7, 1
        ecall

        #Probamos la ejecución del programa sin nuestro set de instrucciones
        rdcycle s2
        la s0, a
        la s1, b
        lw a0, 0(s0)
        lw a1, 4(s0)
        lw a2, 0(s1)
        lw a3, 4(s1)
        call no_ext
        sw a0, 0(s0)
        sw a1, 4(s0)
        rdcycle s3
        sub a0 s3 s2
        li a7, 1
        ecall

        #Deshacemos el espacio en pila
        lw ra, 16(sp)
        lw s0, 12(sp)
        lw s1, 8(sp)
        lw s2, 4(sp)
        lw s3, 0(sp)
        addi sp, sp, 20