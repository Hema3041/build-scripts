import os
import struct
import lzma
import sys
import argparse
#from pylzma import compress


# Define the structure format
header_format = 'IIIIIIII'

# Example usage
#in_file_path = sys.argv[1] #'OTA_All.bin'
#envFile = sys.argv[3]
#out_file_path = sys.argv[2] #'OTA_Comp_All.xz.bin'


#                   Validity    Pattern     Checksum   CompImgLen   OrgImgLen     ENVsize   BootSize      RSVD3
# header_values = (0x000000FF, 0xA5A5A5A5, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)

# Function to add a header to a binary file
def add_header_to_bin_file(i_file_path, BootFile, o_file_path):
        
        # Check if the file exists
        if os.path.exists(i_file_path):
            #Open the input file
            with open(i_file_path, 'rb') as Infile:
                # Get the size of the file in bytes
                file_size = os.path.getsize(i_file_path)
                # Create the stuct and write the orginal file size to struct
                header_values = (0x000000FE, 0xA5A5A5A5, 0xFFFFFFFF, 0xFFFFFFFF, file_size, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF) #Suvarna: modified
                print(f"The size of '{i_file_path}' is {file_size} bytes.")

                # Read the existing data
                data = Infile.read()

                ######Read Boot_file data#######

                BootLSize = os.path.getsize(BootFile)
                print(BootLSize)
                if(BootLSize > 0):
                    header_values_lst = list(header_values)
                    header_values_lst[6] = BootLSize
                    header_values_lst[4] += BootLSize
                    header_values = tuple(header_values_lst)

                    BootFileObj = open(BootFile, 'rb')
                    BootLData = BootFileObj.read()
                    data = bytearray(data)
                    print('header_values', header_values)
                    print('BootLData', type(BootLData))
                    print('data', type(data))
                    #sys.exit()
                    #print('Previous', data)
                    data.extend(BootLData)
                    #sys.exit()
                    #print('After', data)
                
                #print(data[file_size:file_size+29].hex())
                #print(data[file_size:file_size+29])
                ##############################
                # Compress the file with pylzma
                compressed_data = lzma.compress(data, preset=5, check=lzma.CHECK_CRC64, format=lzma.FORMAT_XZ)
                len_comp_data = len(compressed_data)

                # Create a new tuple with the modified CompImgLen and Checksum values
                header_values = (*header_values[:3], len_comp_data, *header_values[4:])
                print(f"Compressed data size : {len_comp_data}")
                #print('header_values', header_values)
                checksum = 0

                # Add each byte to the checksum
                for byte in compressed_data:
                    checksum += byte

                 # Create a new tuple with the modified Checksum value
                header_values = (*header_values[:2], checksum, *header_values[3:])
                print(f"Calculated Checksum: {checksum}")
                #print('header_values', header_values)
                with open(o_file_path, 'wb') as output_file:
                    
                    # Go back to the beginning of the file
                    output_file.seek(0)

                    # Pack the header values into bytes
                    header_data = struct.pack(header_format, *header_values)

                    #Write the header first
                    output_file.write(header_data)
                    print('header_value', header_values)
                    print('header_data', header_data.hex())

                    # Write compressed data
                    output_file.write(compressed_data)

        else:
            print(f"The file '{i_file_path}' doesn't exist.")


def main():
    parser = argparse.ArgumentParser(description='Hoags OTA image creator tool')
    parser.add_argument('-i', '--inputFw', help='Input fw-image file', required=True)
    parser.add_argument('-b', '--inputBootL', help='Input BootL file', required=True)
    parser.add_argument('-o', '--outputImage', help='Output OTA image', required=True)
    
    args = vars(parser.parse_args())
    inputFw = args['inputFw']
    inputBootL = args['inputBootL']
    outputImage = args['outputImage']

    add_header_to_bin_file(inputFw, inputBootL, outputImage)

if __name__=="__main__":
    main()




