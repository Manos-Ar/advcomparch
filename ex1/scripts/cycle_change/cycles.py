from math import log

def adjust(conf, ipc):
    config = conf[:]
    adjusted = []
    length = len(config)
    for i in range(length):
        config[i] = config[i].replace('B', '').replace('K', '')
    base = config[0].split('.')
    base_size = int(base[0])
    base_assoc = int(base[1])
    for i in range(length):
        size, assoc, _ = [int(st) for st in config[i].replace('B', '').replace('K', '').split('.')]
        if size >= base_size:
            exp1 = log(size/base_size, 2)
        else:
            exp1 = -1 * log(base_size/size, 2)
        if assoc >= base_assoc:
            exp2 = log(assoc/base_assoc, 2)
        else:
            exp2 = -1 * log(base_assoc/assoc, 2)
        adjusted.append(ipc[i]/(1.1**exp1)/(1.05**exp2))
    return adjusted
