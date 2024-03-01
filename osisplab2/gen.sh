#!/bin/bash

# Функция для генерации случайного числа в заданном диапазоне
function random_number {
    echo $((RANDOM % 10))
}

# Функция для генерации CSV-матрицы
function generate_matrix {
    rows=$1
    cols=$2
    output_file=$3

    # Создаем пустой файл
    > $output_file

    # Генерируем случайные числа и записываем их в файл
    for ((i=1; i<=$rows; i++)); do
        for ((j=1; j<=$cols; j++)); do
            echo -n $(random_number 100) >> $output_file

            # Добавляем запятую, если не последний столбец
            if [ $j -lt $cols ]; then
                echo -n "," >> $output_file
            fi
        done
        # Переходим на новую строку
        echo "" >> $output_file
    done

    echo "Matrix generated and saved to $output_file"
}

# Проверка на количество аргументов
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 rows cols output_file" >&2
    exit 1
fi

rows=$1
cols=$2
output_file=$3

generate_matrix $rows $cols $output_file

