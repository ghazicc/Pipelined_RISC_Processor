def swap_adjacent_pairs(data):
    swapped_data = []
    for i in range(0, len(data), 4):
        if i + 3 < len(data):
            # Swap pairs (str[i], str[i+1]) with (str[i+2], str[i+3])
            swapped_data.append(data[i + 2:i + 4])
        swapped_data.append(data[i:i + 2])
    return swapped_data

# Get input string from the user
input_string = input("Enter the data string: ")

# Ensure the input string length is a multiple of 4 for proper swapping
if len(input_string) % 4 != 0:
    raise ValueError("The length of the input string must be a multiple of 4.")

# Swap adjacent pairs of characters
swapped_data = swap_adjacent_pairs(input_string)

# Write the swapped data to the output file
with open('memfile.dat', 'w') as outfile:
    for line in swapped_data:
        outfile.write(line + '\n')