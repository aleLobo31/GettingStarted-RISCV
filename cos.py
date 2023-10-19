#Definimos nuestras variables globales
MAX_ERROR = 0.001

def cos(x: float):
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
            for i in range(2*n-1, 2*n+1):
                factorial = factorial * i
        print(factorial)

        #Calculamos el error cometido
        currentError = abs(((x**(2*n))/factorial))


        if currentError > MAX_ERROR:
            #Calculamos el valor de nuestra serie
            value = value + ((x**(2*n))/factorial) * ((-1)**n)
            #Iteramos
            n += 1
        else:
            endLoop = True
    
    return (value, currentError)

        

if __name__ == "__main__":
    result, error = cos(0.2)
    print(f"El resultado es {result} y el error cometido es {error}.")