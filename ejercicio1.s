.text
    factorial_seno:
        #Esta función toma el valor del anterior factorial calculado, y lo multiplica por 2n y por 2n + 1, obteniendo asi (2n + 1)!
        
        #Argumentos:
        #a0 --> n
        #fa0 --> anterior factorial
        
        #Registros que vamos a utilizar en el bucle: 
        #t0 --> Iterador (empezará siendo 2n al principio)
        #t1 --> 2n + 2
        #ft0 --> Valor de t0 en coma flotante para poder multiplicarlo con fa0

        beq a0, zero, else_factorial_seno

        slli t0, a0, 1
        mv t1, t0
        addi t1, t1, 2
        
        while_factorial_seno: 
            bge t0, t1, endWhile_factorial_seno
            fcvt.s.w ft0, t0
            fmul.s fa0, fa0, ft0
            addi t0, t0, 1
            j while_factorial_seno
        
        endWhile_factorial_seno: 
            jr ra       #Devuelve el nuevo factorial en fa0
        
        else_factorial_seno: 
            li t0, 1
            fcvt.s.w fa0, t0
            jr ra       #Devuelve el nuevo factorial en fa0

    potencia_seno_coseno: 
        #Esta función toma el valor de la anterior potencia y lo multiplica dos veces por x obteniendo así x^(2n + 1)

        #Argumentos:
        #fa0 --> potencia acumulada de anteriores iteraciones
        #fa1 --> valor de x
        #a0 --> n

        #Registros utilizados:
        #t0 --> iterador (vale 0 inicialmente)
        #t1 --> cota (2)
        
        
        beq a0, zero, else_potencia  #Si n es igual a 0 simplemente devolvemos x

        li t0, 0
        li t1, 2
        
        while_potencia: bge t0, t1, endWhile_potencia
            fmul.s fa0, fa0, fa1
            addi t0, t0, 1
            j while_potencia
        
        else_potencia: 
            fmv.s fa0, fa1
        
        endWhile_potencia: jr ra  #Devolvemos valor de la potencia en fa0
		
    sumar_resultado_seno_coseno: 
        #Esta función suma (si n es par) o resta (si n es impar) el valor obtenido en la iteración al resto del resultado

        #Argumentos:
        #fa0 --> Valor en el que vamos acumulando el resultado
        #fa1 --> Valor actual de la iteración
        #a0 --> n
        
        #Registros utilizados:
        #t0 --> Vale 2 (Se usa para hacer n%2)

        li t0, 2 
        rem t0, a0, t0      #t0 = a0 % t0
        beq t0, zero, else3     
        fneg.s fa1, fa1     #fa1 = -fa1
        
        else3: 
            fadd.s fa0, fa0, fa1 #Sumamos y devolvemos en fa0 
            jr ra       

    calculo_seno: 
        #Esta función utiliza las anteriores conjuntamente para calcular el seno con un error menor a 0.001

        #Argumentos:
        #fa0 --> Valor del que queremos calcular el seno (x)

        #Registros utilizados:
        #fs0 --> Error máximo (0.001) 
        #fs1 --> Valor acumulado del seno (resultado)
        #fs2 --> Error actual (valor de la iteración)
        #fs3 --> Factorial acumulado
        #fs4 --> Valor de x
        #fs5 --> Valor de la potencia (x^(2n + 1))
        #s0 --> n
        

        #Al ser una función no terminal, apilamos los registros s y el registro ra
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
        li t0, 1
        li t1, 1000
        fcvt.s.w ft0, t0
        fcvt.s.w ft1, t1
        fdiv.s fs0, ft0, ft1    #fs0 = 1 / 1000 (0.001)

        #Valor acumulado del seno (resultado) --> fs1
        fmv.w.x fs1, zero

        #Error actual (valor de la iteración actual) --> fs2
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

        while_seno: 
            #Calculamos el factorial
            fmv.s fa0, fs3      #fa0 = fs3 (anterior factorial)  
            mv a0, s0           #ao = s0 (n)

            jal ra factorial_seno
            
            fmv.s fs3, fa0      #Actualizamos el factorial

            #Calculamos la potencia
            fmv.s fa0, fs5      #fa0 = fs5 (potencia acumulada)
            fmv.s fa1, fs4      #fa1 = fs4 (x)
            mv a0, s0           #a0 = s0 (n)
            
            jal ra potencia_seno_coseno
            
            fmv.s fs5, fa0      #Actualizamos la potencia acumulada 

            #Calculamos el valor de la iteración
            fdiv.s fs2, fs5, fs3

            #Calculamos el error --> ft0 (Es el valor absoluto de lo que hayamos obtenido en la iteración)
            fabs.s ft0, fs2 

            flt.s t0, ft0, fs0      #if (ft0 < fs0) then (t0 = 1) else (t0 = 0)
                                    #Si se diera el caso de que fuera menor que el error (0.001), pararíamos el bucle
            bne t0, zero, endWhile_seno
                fmv.s fa0, fs1      #fa0 = fs1 (valor acumulado del seno)
                fmv.s fa1, fs2      #fa1 = fs2 (valor de la iteración)
                mv a0, s0           #a0 = s0 (n)
                
                jal ra sumar_resultado_seno_coseno
                
                fmv.s fs1, fa0      #fs1 = fa0 (el nuevo valor acumulado del seno, tras sumar o restar (en función de n)el valor de la iteración)

                addi s0, s0, 1      #s0 += 1 (n += 1)
                j while_seno

        endWhile_seno: fmv.s fa0, fs1 #Devolvemos valor del seno en fa0
        
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

    factorial_coseno: #argumentos en fa0 (factorial calculado anteriormente) y a0 (n)
        beq a0, zero, else_factorial_coseno #Si n = 0, directamente devolvemos que el factorial es 1.
            #Preparamos los registros que vamos a utilizar en el bucle: 
            slli t0, a0, 1
            mv t1, t0
            addi t0, t0, -1 #t0 = 2*n - 1; es el valor sobre el que vamos a iterar.
            addi t1, t1, 1 #t1 = 2*n + 1; es la cota que limita el número de iteraciones.
            while_factorial_coseno: bge t0, t1, endWhile_factorial_coseno
                fcvt.s.w ft0, t0 #Utilizamos ft0 para convertir el valor del iterador a coma flotante
                fmul.s fa0, fa0, ft0
                addi t0, t0, 1
                j while_factorial_coseno
            endWhile_factorial_coseno: jr ra #Devuelve el factorial calculado en fa0
        else_factorial_coseno: li t0, 1
        fcvt.s.w fa0, t0
        jr ra #Devuelve el factorial calculado en fa0

    calculo_coseno: #No terminal

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

        while_calculo_coseno: fmv.s fa0, fs3 #Calculamos el factorial 
            mv a0, s0
            jal ra factorial_coseno
            fmv.s fs3, fa0 #Actualizamos el factorial

            #Calculamos la potencia
            fmv.s fa0, fs5
            fmv.s fa1, fs4
            mv a0, s0
            jal ra potencia_seno_coseno
            fmv.s fs5, fa0

            #Calculamos el valor
            fdiv.s fs2, fs5, fs3

            #Calculamos el error --> ft0
            fabs.s ft0, fs2 

            flt.s t0, ft0, fs0 #Guardamos el valor de la comparación en t0
            bne t0, zero, endWhile_calculo_coseno
                fmv.s fa0, fs1
                fmv.s fa1, fs2
                mv a0, s0
                jal ra sumar_resultado_seno_coseno
                fmv.s fs1, fa0

                addi s0, s0, 1
                j while_calculo_coseno

        endWhile_calculo_coseno: fmv.s fa0, fs1
        
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

    factorial_numE: #argumentos en fa0 y a0
        beq a0, zero, else_Factorial_numE #En n = 0 devolvemos un 1.
            fcvt.s.w ft0, a0 #ft0 (lo utilizamos para convertir a0 a coma flotante)
            fmul.s fa0, fa0, ft0
            j fin_factorial_numE
        else_factorial_numE: li t0, 1
            fcvt.s.w fa0, t0
        fin_factorial_numE: jr ra #Devuelve el nuevo factorial en fa0

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
        while_calculoE: fmv.s fa0, fs3
        mv a0, s0
        jal ra factorial_numE
        fmv.s fs3, fa0

        #Calculamos el error cometido
        fdiv.s fs2, fs4, fs3
        flt.s t0, fs2, fs0
        bne t0, zero, endWhile_calculoE
            fadd.s fs1, fs1, fs2
            addi s0, s0, 1
            j while_calculoE
        endWhile_calculoE: fmv.s fa0, fs1
        
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

    calculo_tan:
        #Esta función calcula la tangente de un número dado x

        #Argumentos:
        #fa0 --> El número del que queremos calcular la tangente (x)

        #Registros a usar:
        #fs0 --> El valor de x
        #fs1 --> El valor del coseno de x
        #fs2 --> El valor del seno de x

        #Apilamos los registros s y el registro ra
        addi, sp, sp, -16
        fsw fs0, 12(sp)
        fsw fs1, 8(sp)
        fsw fs2, 4(sp)
        sw ra, 0(sp)

        fmv.s fs0, fa0      #Almacenamos en fs0 el valor de x

        jal ra calculo_coseno        #Calculamos el coseno y lo almacenamos en fs1
        fmv.s fs1, fa0
        
        fcvt.s.w ft0, zero
        feq.s t0, fs1, ft0

        beq t0, zero, else_tan      #Si el coseno es 0, como es el denominador devolvemos infinito
            li t1, 0x7F800000
            fmv.w.x fa0, t1
            j fin_tan

        else_tan:

        fmv.s fa0, fs0
        
        jal ra calculo_seno      #Calculamos el seno y lo almacenamos en fs2
        fmv.s fs2, fa0

        fdiv.s fa0, fs2, fs1        #fa0 = fs2 / fs1 (sen/cos)

        fin_tan:
            #Desapilamos los registros s y ra
            flw fs0, 12(sp)
            flw fs1, 8(sp)
            flw fs0, 4(sp)
            lw ra, 0(sp)
            addi sp, sp, 16
            jr ra
    main:
        li a7, 6
        ecall
        jal ra calculo_tan
        li a7, 2
        ecall