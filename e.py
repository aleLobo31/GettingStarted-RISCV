MAX_ERROR = 0.001

def number_e():
    value = 0.0
    errorCometido = 1
    factorial = 0.0
    n = 0
    endLoop = False

    while not endLoop:

        if factorial == 0.0:
            factorial = 1.0
        else:
            factorial = factorial * n

        errorCometido = 1/factorial

        if errorCometido > MAX_ERROR:
            value += errorCometido
            n += 1
        else:
            endLoop = True
    
    return value, errorCometido
    
if __name__ == "__main__":
    result, error = number_e()
    print(f"El resultado es {result} y su error correspondiente es {error}")