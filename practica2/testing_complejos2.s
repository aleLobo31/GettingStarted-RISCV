.data
    a: .word 35, 15
    b: .word 10, 20
    c: .zero 8
.text
# Implementar con instrucciones RISC-V (sin la extensión)
    # if (a == b):
    # return a * b;
    # else
    # return a + b;

no_ext:
    lw t0, 0(a0)
    lw t1, 4(a0)
    lw t2, 0(a1)
    lw t3, 4(a1)

    la a0, c

    bne t0, t2, else_no_ext        #Comparamos partes reales
        bne t1, t3, else_no_ext        #Comparamos partes imaginarias
            mul t4, t0, t2
            mul t5, t1, t3
            sub t6, t4, t5
            sw t6, 0(a0)

            mul t4, t0, t3
            mul t5, t1, t2
            add t6, t4, t5
            sw t6, 4(a0)

            ret

    else_no_ext:
        add t6, t0, t2      #Suma de la parte real
        sw t6, 0(a0)
        
        add t6, t1, t3      #Suma de la parte imaginaria
    
        sw t6, 4(a0)
        ret
with_ext:
    lc t0, t1, (a0)
    lc t2, t3, (a1)
    la a0, c
    beqc t0, t1, t2, t3, else_with_ext
        addc t0, t1, t2, t3     
        sc t0, t1, (a0)
        ret
    else_with_ext:
        mulc t0, t1, t2, t3
        sc t0, t1, (a0)
        ret
main: 
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw ra, 12(sp)
    
    rdcycle s0
        la a0, a
        la a1, b
        call with_ext
    rdcycle s1
        sub s1 s1 s0
    rdcycle s0
        la a0, a
        la a1, b
        call no_ext
    rdcycle s2
        sub s2 s2 s0
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16

    hcf 