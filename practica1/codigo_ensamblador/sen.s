#Versión 1.0 (No hay función y no está optimizado)

.data
    #Almacenamos como variable global el máximo error que toleramos
    maxError: .float 0.001
.text
    main:
        #Hasta futuras versiones almacenamos temporalmente en un registro el valor cuyo seno queremos calcular.
        li t6, 5

        #Registros enteros
        #t0 Iterador global (n)
        #t1 Iterador local y registro auxiliar
        #t2 Factorial
        #t3 2*n + 1
        #t4 registro auxiliar
        #t5 Guarda la contante 2
        li t0, 0 #Iterador global
        li t5, 2 #Almacenamos la constante 2 -> Nos lo llevamos a variable global
        
        #Registros de coma flotante
        #ft1 Valor de cada iteración
        #ft2 Error de cada iteración
        #ft3 Error máximo permitido
        #ft5 Valor final
        #ft6 registro auxiliar
        la t1, maxError
        flw ft3, 0(t1)
        
        #Calculamos el factorial
    while3: bne t0, zero, else1
            li t2, 1
            fcvt.s.w ft2, t2
            j endWhile1
        else1: mv t3, t0 #Copiamos en el registro t3 lo que vale n
            mul t3, t3, t5 #Lo multiplicamos por 2
            addi t4, t3, 2 
            #Creamos un bucle para calcular el factorial
    while1: bge t3, t4 endWhile1
                fcvt.s.w ft6, t3
                fmul.s ft2, ft2, ft6
                addi t3, t3, 1
                j while1
        endWhile1: li t1, 1 #Calculamos el valor
        mv t3, t0
        mul t3, t3, t5
        addi t3, t3, 1
        fcvt.s.w ft4, t6
        fcvt.s.w ft6, t6
        #Primero calculamos la potencia con un bucle 
    while2: bge t1, t3, endWhile2
            fmul.s ft4, ft4, ft6
            addi t1, t1, 1
            j while2
        endWhile2: fdiv.s ft1, ft4, ft2 #Hacemos conversiones para que los enteros con los que vayamos a operar sean ieee 754
        		
        rem t1, t0, t5
        beq t1, zero, else2
            fneg.s ft1, ft1
        else2: fabs.s ft6, ft1 #El error es el valor en valor absoluto

        flt.s t4, ft6, ft3 
        bne t4, zero, endWhile3
            fadd.s ft5, ft5, ft1
            addi t0, t0, 1
            j while3
        endWhile3: li a7, 2
        fmv.s fa0, ft5
        ecall
        jr ra