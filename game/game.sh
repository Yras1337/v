#!/bin/bash

MASK_TARGET=$((1 << 0))
MASK_WALL=$((1 << 1))
MASK_BOX=$((1 << 2))
MASK_NOT_EMPTY=$((MASK_WALL | MASK_BOX))
MASK_BOX_ON_TARGET=$((MASK_BOX | MASK_TARGET))

TILE_SOKOMAN='%'
TILES[$MASK_WALL]='#'
TILES[$MASK_BOX]='0'
TILES[$MASK_EMPTY]=' '
TILES[$MASK_TARGET]='_'
TILES[$MASK_BOX_ON_TARGET]='$'

info() {
	echo "# $@" #> /dev/null
}
debug() {
	echo "# $@" > /dev/null
}

load_game_state() {
	board_width=12
	board_head="#"
	for ((i=0; i<$board_width; ++i)); do
		board_head="${board_head}#"
	done
	board_height=5
	total_tiles=$((board_height * board_width))
	for ((i=0; i<$total_tiles; ++i)); do
		board[$i]=0
	done
	moves_taken=0
	set_sokoman_location 1 3
	add_target 0 0
	add_target 11 4
	add_box 2 2
	add_box 11 2
	add_wall 0 1
	add_wall 1 1
	add_wall 2 1
	add_wall 4 1
}

set_sokoman_location() {
	sokoman_x=$1
	sokoman_y=$2
	sokoman_index=$((sokoman_y * board_width + sokoman_x))
}

get_index() {
	local x=$1
	local y=$2
	echo $((y * board_width + x))
}

add_box() {
	add_mask $1 $2 $MASK_BOX
}

add_wall() {
	local index=$(get_index $1 $2)
	board[$index]=$MASK_WALL
}

add_mask() {
	local mask=$3
	local index=$(get_index $1 $2)
	board[$index]=$((board[index] | mask))
}

remove_mask() {
	local index=$(get_index $1 $2)
	local mask=$3
	board[$index]=$((board[index] & !mask))
}

add_target() {
	add_mask $1 $2 $MASK_TARGET
}

do_move() {
	local d_x=$1
	local d_y=$2
	local new_x=$((sokoman_x + d_x))
	local new_y=$((sokoman_y + d_y))

	target_square_content=$(get_square $new_x $new_y)
	if (( $target_square_content & $MASK_WALL )); then return 1; fi
	if (( $target_square_content & $MASK_BOX )); then
		local new_x_2=$((new_x + d_x))
		local new_y_2=$((new_y + d_y))
		if (( $(get_square $new_x_2 $new_y_2) & $MASK_NOT_EMPTY )); then return 1; fi
		remove_mask $new_x $new_y $MASK_BOX
		add_mask $new_x_2 $new_y_2 $MASK_BOX
	fi
	(( ++moves_taken ))
	set_sokoman_location $new_x $new_y
}

process_input() {
	while true; do
		read -s -n 1 in_key
		case $in_key in
			w ) if do_move 0 -1; then break; fi;;
			a ) if do_move -1 0; then break; fi;;
			s ) if do_move 0 1; then break; fi;;
			d ) if do_move 1 0; then break; fi;;
			q )
				echo ""
				echo "> Thanks for playing :¬)"
				exit
		esac
	done
}

draw_hud() {
	echo "> moves: $moves_taken"
	echo ""
}

draw_board() {
	local disp="${board_head}#\n#"
	local counter=$board_width
	for ((i=0; i<$total_tiles; ++i)); do
		if [[ $i == $sokoman_index ]]; then
			local disp="${disp}${TILE_SOKOMAN}"
		else
			local disp="${disp}${TILES[${board[$i]}]}"
		fi
		if ((--counter == 0)); then
			local disp="${disp}#\n#"
			local counter=$board_width
		fi
	done
	echo -e "${disp}${board_head}"
}

get_square() {
	local x=$1
	local y=$2
	if (( $x < 0 || $y < 0 || $x >= $board_width || $y >= $board_height )); then
		echo $MASK_WALL
		return
	fi
	local index=$(get_index $x $y)
	echo ${board[$index]}
}

is_level_complete() {
	for ((i=0; i<$total_tiles; ++i)); do
		if (( board[$i] == $MASK_TARGET )); then
			return 1
		fi
	done
}

reset
load_game_state
while true; do
	clear
	draw_hud
	draw_board
	if is_level_complete; then
		echo ""
		echo "> level completed"
		exit
	else
		process_input
	fi
done

