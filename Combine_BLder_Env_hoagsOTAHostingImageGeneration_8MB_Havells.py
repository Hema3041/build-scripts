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


#                   Validity    Pattern     Checksum   CompImgLen   OrgImgLen     ENVsize  BootLoader      RSVD3
# header_values = (0x000000FF, 0xA5A5A5A5, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF)

# Function to add a header to a binary file
def add_header_to_bin_file(i_file_path, envFile, BootLFile, o_file_path):
        
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
                compressed_data = lzma.compress(data, preset=5, check=lzma.CHECK_CRC64, format=lzma.FORMAT_XZ)
                data = compressed_data
                #print('Compressed application size', len(data))
                #sys.exit()

                ######Read envfile data#######
            if os.path.exists(envFile):
                 envSize = os.path.getsize(envFile)
                 print(envSize)
                 if(envSize > 0):
                    header_values_lst = list(header_values)
                    header_values_lst[5] = envSize
                    header_values_lst[4] += envSize
                    header_values = tuple(header_values_lst)

                    envFileObj = open(envFile, 'rb')
                    envData = envFileObj.read()
                    data = bytearray(data)
                    print('header_values', header_values)
                    print('envData', type(envData))
                    print('data', type(data))
                    data.extend(envData)
                    
            ##############BootLoader##############################
            if os.path.exists(BootLFile):
                BootLSize = os.path.getsize(BootLFile)
                print(BootLSize)
                if(BootLSize > 0):
                    header_values_lst = list(header_values)
                    header_values_lst[6] = BootLSize
                    header_values_lst[4] += BootLSize
                    header_values = tuple(header_values_lst)

                    BootLFileObj = open(BootLFile, 'rb')
                    BootLData = BootLFileObj.read()
                    data = bytearray(data)
                    print('header_values', header_values)
                    print('BootLData', type(BootLData))
                    print('data', type(data))
                    data.extend(BootLData)
                
                #print(data[file_size:file_size+29].hex())
                #print(data[file_size:file_size+29])
                ##############################
                # Compress the file with pylzma
            #compressed_data = lzma.compress(data, preset=5, check=lzma.CHECK_CRC64, format=lzma.FORMAT_XZ)
            #len_comp_data = len(compressed_data)
            len_comp_data = len(data)

                # Create a new tuple with the modified CompImgLen and Checksum values
            header_values = (*header_values[:3], len_comp_data, *header_values[4:])
            print(f"Compressed data size : {len_comp_data}")
                #print('header_values', header_values)
            checksum = 0

                # Add each byte to the checksum
            counter = 0;
            for byte in data:
              checksum += byte
              #print("Checksum-", counter, "=", hex(byte), hex(checksum))
              counter += 1 

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
                len_headr=len(header_data)
                print('header size',len_headr)

                    # Write compressed data
                output_file.write(data)

        else:
            print(f"The file '{i_file_path}' doesn't exist.")


def main():
    parser = argparse.ArgumentParser(description='Hoags OTA image creator tool')
    parser.add_argument('-i', '--inputFw', help='Input fw-image file', required=True)
    parser.add_argument('-e', '--inputEnv', help='Input env file', required=True)
    parser.add_argument('-b', '--inputBootL', help='Input BootL file', required=True)
    parser.add_argument('-o', '--outputImage', help='Output OTA image', required=True)
    
    args = vars(parser.parse_args())
    inputFw = args['inputFw']
    inputEnv = args['inputEnv']
    inputBootL = args['inputBootL']
    outputImage = args['outputImage']

    add_header_to_bin_file(inputFw, inputEnv, inputBootL, outputImage)

if __name__=="__main__":
    main()




