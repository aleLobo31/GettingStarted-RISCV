#Aquí van la función seno y sinMatrix

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

    potencia_seno: 
        #Esta función toma el valor de la anterior potencia y lo multiplica dos veces por x 

        #Argumentos:
        #fa0 --> potencia acumulada de anteriores iteraciones
        #fa1 --> valor de x
        #a0 --> n

        #Registros utilizados:
        #t0 --> iterador (vale 0 inicialmente)
        #t1 --> cota (2)
        
        
        beq a0, zero, else_potencia_seno  #Si n es igual a 0 simplemente devolvemos x

        li t0, 0
        li t1, 2
        
        while_potencia_seno: bge t0, t1, endWhile_potencia_seno
            fmul.s fa0, fa0, fa1
            addi t0, t0, 1
            j while_potencia_seno
        
        else_potencia_seno: 
            fmv.s fa0, fa1
        
        endWhile_potencia_seno: jr ra  #Devolvemos valor de la potencia en 
        

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
            
            jal ra potencia_seno
            
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

sin_matrix: #Función No Terminal

        #Apilamos los registros "s" que vamos a utilizar y el registro ra
        addi sp, sp, -20
        sw s0, 0(sp)
        sw s1, 4(sp)
        sw s2, 8(sp)
        sw s3, 12(sp)
        sw ra, 16(sp)

        li s0, 0        #Iterador auxiliar
        mul s1, a2, a3      #Numero elementos de la matriz
        mv s2, a0       #Dirección de Inicio Matriz A
        mv s3, a1       #Dirección de Inicio Matriz B

        while_sin_matrix: bge s0, s1, endWhile_sin_matrix
            flw fa0, 0(s2)      #Cargamos valor de la matriz A
            jal ra calculo_seno         #Computamos su seno
            fsw fa0, 0(s3)      #Guardamos valor en la matriz B
            #Iteramos sobre las direcciones
            addi s2, s2, 4
            addi s3, s3, 4
            #Iteramos sobre el número de elementos
            addi s0, s0, 1
            j while_sin_matrix
        endWhile_sin_matrix: 

            #Desapilamos la pila
            lw s0, 0(sp)
            lw s1, 4(sp)
            lw s2, 8(sp)
            lw s3, 12(sp)
            lw ra, 16(sp)
            addi sp, sp, 20

            jr ra
    
    main: addi sp sp -12
    	sw ra 0(sp)
        sw s0 4(sp)
        sw s1 8(sp)
        la a0, A        #Guardamos la dirección de inicio de la matriz A
        la a1, B
        mv s0, a1
        li a2, 3        #Guardamos el número de filas
        li a3, 3        #Guardamos el número de columnas

        jal ra sin_matrix

        la t0, space
        lbu a0, 0(t0)
        li t0, 0
        li s1, 8

        bucle: bge t0, s1, fin
            li a7, 2
            flw fa0 0(s0)
            ecall
            li a7, 11
            ecall
            addi s0, s0, 4
            addi t0, t0, 1
            j bucle
        
        fin: 
        lw s1 8(sp)
        lw s0 4(sp)
        lw ra 0(sp)
        addi sp, sp 12
        jr ra