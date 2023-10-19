#Definimos nuestras variables globales
MAX_ERROR = 0.001

def sen(x: float):
    #Declaramos e inicializamos nuestras variables locales
    n = 0
    factorial = 0.0
    value = 0.0
    currentError = 1
    endLoop = False

    while not endLoop:
        #Añadimos un término de la serie de potencias

        #Para ello primero calculamos el factorial que toca
        if factorial == 0.0:
            factorial = 1.0
        else:
            for i in range(2*n, 2*n+2):
                factorial = factorial * i

        #Calculamos el error cometido
        currentError = abs(((x**(2*n+1))/factorial))
        print(currentError)

        if currentError > MAX_ERROR:
            #Calculamos el valor de nuestra serie
            value = value + currentError * ((-1)**n)
            #Iteramos
            n += 1
        else:
            endLoop = True
    
    return value

def sen2(x: float):
    n = 0
    factorial = 0.0
    elem = 0.0
    newvalue = 0.0
    oldValue = 0.0
    currentError = 1
    endLoop = False

    while not endLoop:
        #Añadimos un término de la serie de potencias

        #Para ello primero calculamos el factorial que toca
        if factorial == 0.0:
            factorial = 1.0
        else:
            for i in range(2*n, 2*n+2):
                factorial = factorial * i

        elem = ((x**(2*n+1))/factorial) * (-1)**n

        #Calculamos el error cometido
        newvalue = oldValue + elem
        
        currentError = abs(newvalue - oldValue)
        print(currentError)

        if currentError > MAX_ERROR:
            oldValue += elem
            n += 1
        else:
            endLoop = True
    
    return oldValue
if __name__ == "__main__":
    for i in range(-2, 3):
        x = i*3.14
        print(x)
        senX = sen(x)
        print(f"El seno es {senX}\n")
        senX = sen2(x)
        print(f"El seno es {senX}\n")
