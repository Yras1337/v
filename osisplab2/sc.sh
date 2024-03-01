#!/bin/bash

# Функция для сложения двух матриц
function add_matrices {
    awk -F, 'NR==FNR{split($0,a,",");next}{split($0,b,",");for(i=1;i<=NF;i++){$i=a[i]+b[i]};print}' $1 $2
}

# Функция для вычитания одной матрицы из другой
function subtract_matrices {
    awk -F, 'NR==FNR{split($0,a,",");next}{split($0,b,",");for(i=1;i<=NF;i++){$i=a[i]-b[i]};print}' $1 $2
}

# Функция для умножения матрицы на скаляр
function multiply_matrix_scalar {
    awk -v scalar="$3" -F, '{for(i=1;i<=NF;i++){$i=$i*scalar};print}' $1 > temp.csv
    cat temp.csv
    rm temp.csv
}

# Функция для умножения двух матриц
function multiply_matrices {
    awk -F, 'NR==FNR{split($0,a,",");next}{for(i=1;i<=NF;i++) for(j=1;j<=NF;j++) c[i,j]+=$i*$j} END{for(i=1;i<=NF;i++) {for(j=1;j<=NF;j++) printf "%s%s", c[i,j], (j<NF ? "," : "\n")} }' $1 $2
}

# Проверка на количество аргументов
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 operation matrix1.csv matrix2.csv [scalar]" >&2
    exit 1
fi

operation=$1
matrix1=$2
matrix2=$3

# Проверка существования файлов
if [ ! -f "$matrix1" ]; then
    echo "File $matrix1 not found." >&2
    exit 1
fi

if [ ! -f "$matrix2" ]; then
    echo "File $matrix2 not found." >&2
    exit 1
fi

case $operation in
    "add")
        add_matrices $matrix1 $matrix2
        ;;
    "subtract")
        subtract_matrices $matrix1 $matrix2
        ;;
    "multiply")
        multiply_matrices $matrix1 $matrix2
        ;;
    "multiply_scalar")
        if [ "$#" -ne 4 ]; then
            echo "Usage: $0 multiply_scalar matrix.csv scalar" >&2
            exit 1
        fi
        multiply_matrix_scalar $matrix1 $matrix2 $4
        ;;
    *)
        echo "Invalid operation. Available operations: add, subtract, multiply, multiply_scalar" >&2
        exit 1
        ;;
esac

