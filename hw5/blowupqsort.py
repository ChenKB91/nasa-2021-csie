def qsort(arr: list):
    n = len(arr)
    if n == 0:
        return arr
    pivot = arr[n // 2]
    print(pivot)
    l = [i for i in arr if i < pivot]
    g = [i for i in arr if i > pivot]
    cnt = arr.count(pivot)
    return qsort(l) + [pivot] * cnt + qsort(g)


def blowup():
    s = '0'
    i = 0
    for _ in range(1000):
        i += 1
        if i % 2:
            s = f'{s} {i}'
        else:
            s = f'{i} {s}'
    return s

qsort([ int(i) for i in blowup().split()])  
# print(s)
# print(len(s))
