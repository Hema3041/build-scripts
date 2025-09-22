import os
import struct
import lzma
import sys
#from pylzma import compress


# Define the structure format
header_format = 'IIIIIIII'

# Example usage
in_file_path = sys.argv[1] #'OTA_All.bin'
out_file_path = sys.argv[2] #'OTA_Comp_All.xz.bin'


#                   Validity    Pattern     Checksum   CompImgLen   OrgImgLen     RSVD1       RSVD2      RSVD3
# header_values = (0x000000FF, 0xA5A5A5A5, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)

# Function to add a header to a binary file
def add_header_to_bin_file(i_file_path, o_file_path):
        
        # Check if the file exists
        if os.path.exists(i_file_path):
            #Open the input file
            with open(i_file_path, 'rb') as Infile:
                # Get the size of the file in bytes
                file_size = os.path.getsize(i_file_path)
                # Create the stuct and write the orginal file size to struct
                header_values = (0x000000FE, 0xA5A5A5A5, 0xFFFFFFFF, 0xFFFFFFFF, file_size, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)
                print(f"The size of '{i_file_path}' is {file_size} bytes.")

                # Read the existing data
                data = Infile.read()

                # Compress the file with pylzma
                compressed_data = lzma.compress(data, preset=5, check=lzma.CHECK_CRC64, format=lzma.FORMAT_XZ)
                len_comp_data = len(compressed_data)

                # Create a new tuple with the modified CompImgLen and Checksum values
                header_values = (*header_values[:3], len_comp_data, *header_values[4:])
                print(f"Compressed data size : {len_comp_data}")

                checksum = 0

                # Add each byte to the checksum
                for byte in compressed_data:
                    checksum += byte

                 # Create a new tuple with the modified Checksum value
                header_values = (*header_values[:2], checksum, *header_values[3:])
                print(f"Calculated Checksum: {checksum}")
                
                with open(o_file_path, 'wb') as output_file:
                    
                    # Go back to the beginning of the file
                    output_file.seek(0)

                    # Pack the header values into bytes
                    header_data = struct.pack(header_format, *header_values)

                    #Write the header first
                    output_file.write(header_data)

                    # Write compressed data
                    output_file.write(compressed_data)

        else:
            print(f"The file '{i_file_path}' doesn't exist.")


add_header_to_bin_file(in_file_path, out_file_path)

