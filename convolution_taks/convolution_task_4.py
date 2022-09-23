import numpy as np

# 2-D input
imagem = np.array([ [0,   0,   0,   0,   0,  0, 0],
                    [0, 119,  43, 104,  62, 83, 0], #1
                    [0,  64, 119,  72,  69, 85, 0], #2
                    [0, 137,  66,  46, 143, 85, 0], #3
                    [0, 132,  81,  30,  28, 54, 0], #4
                    [0,  38,  37, 113, 141, 60, 0], #5
                    [0,   0,   0,   0,   0,  0, 0]])

# 2-D filter kernel
filter = np.array([ [0, -1, 0],
                    [-1, 5, -1],
                    [0, -1, 0]])


def convolution (img, filter, row):
    result = []
    k = filter.shape[0]
    for c in range(0, len(img[row])-2):
        mat = img[row:row+k, c:c+k]
        result.append(np.sum(np.multiply(mat, filter)))

    with open('local_update.txt', 'w', encoding = 'utf-8') as f:
        f.write('Result for row: {0}\n'.format(row))
        f.write(', '.join(map(str, result)))

convolution(imagem, filter, 3)